# Exfil: Extraction Mode

Complete walkthrough of the Exfil example game mode - a 4-team objective extraction game with item pickup/drop mechanics, AI enemies, and dynamic extraction points.

## Overview

**Exfil** is a high-stakes extraction mode demonstrating:
- **4-team competition** - Simultaneous team objectives
- **Item pickup/drop** - Physical object collection and delivery
- **AI enemies** - 13 spawn points with hostile NPCs
- **Dynamic extraction** - Per-team extraction zones
- **Status effects** - Speed/health modifiers while carrying items
- **Time pressure** - Match timer with extraction windows

**Complexity:** ~1000 lines | **Players:** 4-16 (4 teams) | **Difficulty:** Advanced

---

## Core Architecture

### Data Structures

```typescript
type TeamData = {
    team: mod.Team;
    extractionPoint: mod.InteractPoint;
    extractionZone: mod.AreaTrigger;
    itemsExtracted: number;
    score: number;
};

type ItemData = {
    itemId: number;
    spatialObject: mod.SpatialObject;
    position: mod.Vector;
    carrier: mod.Player | null;
    homeTeam: mod.Team | null;  // Team that can extract it
    pickedUp: boolean;
};

type PlayerData = {
    player: mod.Player;
    team: mod.Team;
    carryingItem: ItemData | null;
    kills: number;
    extractions: number;
};

enum GamePhase {
    Lobby,
    Starting,
    Active,
    Extraction,
    Complete
}
```

### Game Constants

```typescript
const TEAMS = [mod.Team.Team1, mod.Team.Team2, mod.Team.Team3, mod.Team.Team4];
const ITEMS_TO_WIN = 5;
const MATCH_TIME = 600;  // 10 minutes

const EXTRACTION_WINDOW = 60;  // 60 seconds to extract
const ITEMS_PER_TEAM = 3;      // 3 items spawn per team

// Item carrier effects
const CARRIER_SPEED_MULTIPLIER = 0.7;   // 30% slower
const CARRIER_HEALTH_MULTIPLIER = 0.8;  // 20% less health
```

---

## Key Systems

### 1. Item Spawn & Pickup

**Challenge:** Spawn physical items and detect pickup/drop.

**Solution:** Spatial objects with proximity detection.

```typescript
function spawnItems() {
    const itemSpawnPoints = [
        { id: 1, pos: mod.CreateVector(100, 0, 100) },
        { id: 2, pos: mod.CreateVector(-100, 0, 100) },
        { id: 3, pos: mod.CreateVector(100, 0, -100) },
        // ... 12 total spawn points
    ];

    itemSpawnPoints.forEach((spawn, index) => {
        const spatialObj = mod.GetSpatialObject(spawn.id);

        const item: ItemData = {
            itemId: index,
            spatialObject: spatialObj,
            position: spawn.pos,
            carrier: null,
            homeTeam: null,  // Any team can pick up initially
            pickedUp: false
        };

        items.push(item);

        // Make item visible
        mod.EnableObject(spatialObj, true);
    });
}

async function itemPickupLoop() {
    while (gamePhase === GamePhase.Active) {
        for (const item of items) {
            if (item.carrier !== null) continue;  // Already carried

            // Check all players
            for (const playerData of players) {
                const playerPos = mod.GetSoldierState(
                    playerData.player,
                    mod.SoldierStateVector.GetPosition
                );

                const distance = calculateDistance(playerPos, item.position);

                if (distance < 2.0 && playerData.carryingItem === null) {
                    // Player can pick up item
                    showPickupPrompt(playerData);

                    if (isPlayerPressedInteract(playerData.player)) {
                        pickupItem(playerData, item);
                    }
                }
            }
        }

        await mod.Wait(0.1);
    }
}

function pickupItem(playerData: PlayerData, item: ItemData) {
    // Assign item to player
    item.carrier = playerData.player;
    item.pickedUp = true;
    playerData.carryingItem = item;

    // Hide item object
    mod.EnableObject(item.spatialObject, false);

    // Apply carrier effects
    applyCarrierEffects(playerData);

    // Show HUD indicator
    showCarryingItemUI(playerData);

    mod.DisplayCustomNotificationMessage(
        mod.Message("Item picked up! Take to extraction!"),
        mod.CustomNotificationSlots.MessageText1,
        3,
        playerData.player
    );
}

function applyCarrierEffects(playerData: PlayerData) {
    // Reduce movement speed
    mod.SetMovementSpeedScale(playerData.player, CARRIER_SPEED_MULTIPLIER);
    mod.SetSprintSpeedScale(playerData.player, CARRIER_SPEED_MULTIPLIER);

    // Reduce max health
    const currentMaxHealth = mod.GetSoldierState(
        playerData.player,
        mod.SoldierStateNumber.MaxHealth
    );

    mod.SetPlayerMaxHealth(
        playerData.player,
        currentMaxHealth * CARRIER_HEALTH_MULTIPLIER
    );

    // Visual indicator (glowing effect)
    showCarrierGlow(playerData.player);
}
```

---

### 2. Item Drop Mechanics

**Challenge:** Handle item drops on death or manual drop.

**Solution:** Event-driven drop with position restoration.

```typescript
function dropItem(playerData: PlayerData) {
    const item = playerData.carryingItem;
    if (!item) return;

    // Get player's current position
    const dropPos = mod.GetSoldierState(
        playerData.player,
        mod.SoldierStateVector.GetPosition
    );

    // Update item state
    item.carrier = null;
    item.position = dropPos;
    item.pickedUp = false;

    // Move spatial object to drop position
    mod.SetObjectTransform(
        item.spatialObject,
        dropPos,
        mod.CreateVector(0, 0, 0)
    );

    // Make item visible again
    mod.EnableObject(item.spatialObject, true);

    // Remove from player
    playerData.carryingItem = null;

    // Remove carrier effects
    removeCarrierEffects(playerData);

    // Hide UI indicator
    hideCarryingItemUI(playerData);
}

export async function OnPlayerDied(player: mod.Player) {
    const playerData = findPlayerData(player);

    // Drop carried item
    if (playerData.carryingItem) {
        dropItem(playerData);

        mod.DisplayCustomNotificationMessage(
            mod.Message("Item dropped!"),
            mod.CustomNotificationSlots.HeaderText,
            2
        );
    }
}

// Manual drop (press key)
export async function OnPlayerPressedKey(player: mod.Player, key: string) {
    if (key === "G") {  // G key to drop
        const playerData = findPlayerData(player);

        if (playerData.carryingItem) {
            dropItem(playerData);

            mod.DisplayCustomNotificationMessage(
                mod.Message("Item dropped"),
                mod.CustomNotificationSlots.MessageText1,
                1,
                player
            );
        }
    }
}
```

---

### 3. Extraction System

**Challenge:** Create team-specific extraction zones with progress tracking.

**Solution:** Per-team zones with timed extraction windows.

```typescript
function setupExtractionPoints() {
    const extractionConfigs = [
        { team: mod.Team.Team1, pointId: 10, zoneId: 20 },
        { team: mod.Team.Team2, pointId: 11, zoneId: 21 },
        { team: mod.Team.Team3, pointId: 12, zoneId: 22 },
        { team: mod.Team.Team4, pointId: 13, zoneId: 23 }
    ];

    extractionConfigs.forEach(config => {
        const teamData: TeamData = {
            team: config.team,
            extractionPoint: mod.GetInteractPoint(config.pointId),
            extractionZone: mod.GetAreaTrigger(config.zoneId),
            itemsExtracted: 0,
            score: 0
        };

        teams.push(teamData);
    });
}

async function extractionLoop() {
    while (gamePhase === GamePhase.Active || gamePhase === GamePhase.Extraction) {
        for (const teamData of teams) {
            // Find team members carrying items
            const carriers = players.filter(pd =>
                pd.team === teamData.team &&
                pd.carryingItem !== null
            );

            for (const carrier of carriers) {
                // Check if in extraction zone
                const inZone = mod.IsPlayerInAreaTrigger(
                    carrier.player,
                    teamData.extractionZone
                );

                if (inZone) {
                    await extractItem(carrier, teamData);
                }
            }
        }

        await mod.Wait(0.1);
    }
}

async function extractItem(playerData: PlayerData, teamData: TeamData) {
    const item = playerData.carryingItem;
    if (!item) return;

    // Show extraction progress
    const progressBar = createProgressBar(playerData.player, "EXTRACTING");

    const extractionTime = 3;  // 3 seconds to extract

    for (let progress = 0; progress <= extractionTime; progress += 0.1) {
        // Check still in zone
        if (!mod.IsPlayerInAreaTrigger(playerData.player, teamData.extractionZone)) {
            removeProgressBar(progressBar);
            return;  // Canceled
        }

        updateProgressBar(progressBar, progress / extractionTime);
        await mod.Wait(0.1);
    }

    // Extraction successful
    teamData.itemsExtracted++;
    teamData.score += 100;
    playerData.extractions++;

    // Remove item permanently
    items = items.filter(i => i !== item);

    // Remove from player
    playerData.carryingItem = null;
    removeCarrierEffects(playerData);

    // Update scoreboard
    mod.SetGameModeScore(teamData.team, teamData.score);

    mod.DisplayCustomNotificationMessage(
        mod.Message(`Item extracted! ${teamData.itemsExtracted}/${ITEMS_TO_WIN}`),
        mod.CustomNotificationSlots.HeaderText,
        3,
        playerData.player
    );

    removeProgressBar(progressBar);

    // Check win condition
    if (teamData.itemsExtracted >= ITEMS_TO_WIN) {
        endMatch(teamData.team);
    }
}
```

---

### 4. AI Enemy System

**Challenge:** Populate map with hostile AI that attack all players.

**Solution:** AI spawners with aggressive behavior.

```typescript
const AI_SPAWN_POINTS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];

async function spawnAIEnemies() {
    for (const spawnId of AI_SPAWN_POINTS) {
        const aiSpawner = mod.GetAISpawner(spawnId);

        // Configure spawner
        mod.SetAISpawnerRespawnTime(aiSpawner, 30);  // 30 sec respawn
        mod.SetAISpawnerAutoSpawn(aiSpawner, true);

        // Spawn initial AI
        const ai = mod.SpawnAIFromAISpawner(aiSpawner);

        configureAI(ai);
    }
}

function configureAI(ai: mod.Player) {
    // Aggressive behavior
    mod.AISetBehavior(ai, mod.AIBehaviors.BattlefieldAI);
    mod.AIEnableShooting(ai, true);
    mod.AIEnableTargeting(ai, true);

    // Movement settings
    mod.AISetMoveSpeed(ai, mod.MoveSpeed.Normal);
    mod.AISetStance(ai, mod.Stance.Stand);

    // Damage settings (make AI tougher)
    mod.SetPlayerMaxHealth(ai, 150);  // 50% more health

    // AI doesn't drop items (not a player)
}

async function aiTargetingLoop() {
    while (gamePhase === GamePhase.Active) {
        const aiPlayers = getAllAI();

        for (const ai of aiPlayers) {
            // Find nearest player
            const nearestPlayer = findNearestPlayer(ai);

            if (nearestPlayer) {
                const distance = calculateDistance(
                    mod.GetSoldierState(ai, mod.SoldierStateVector.GetPosition),
                    mod.GetSoldierState(nearestPlayer, mod.SoldierStateVector.GetPosition)
                );

                // Attack if in range
                if (distance < 50) {
                    mod.AISetTarget(ai, nearestPlayer);
                    mod.AIForceFire(ai, 1.0);
                }
            }
        }

        await mod.Wait(1);  // Update every second
    }
}
```

---

### 5. Extraction Window System

**Challenge:** Create urgency with timed extraction opportunities.

**Solution:** Intermittent extraction windows with countdown.

```typescript
async function extractionWindowLoop() {
    const windowInterval = 120;  // Every 2 minutes
    const windowDuration = 60;   // 60 second window

    while (gamePhase === GamePhase.Active) {
        // Wait for next window
        await mod.Wait(windowInterval);

        // Open extraction window
        gamePhase = GamePhase.Extraction;

        mod.DisplayCustomNotificationMessage(
            mod.Message("EXTRACTION WINDOW OPEN!"),
            mod.CustomNotificationSlots.HeaderText,
            5
        );

        // Activate extraction zones (visual effects)
        teams.forEach(teamData => {
            activateExtractionZone(teamData);
        });

        // Countdown
        for (let time = windowDuration; time > 0; time--) {
            // Show countdown to all
            mod.DisplayCustomNotificationMessage(
                mod.Message(`Extraction closes in ${time}s`),
                mod.CustomNotificationSlots.MessageText4,
                1.1
            );

            await mod.Wait(1);
        }

        // Close extraction window
        gamePhase = GamePhase.Active;

        mod.DisplayCustomNotificationMessage(
            mod.Message("EXTRACTION WINDOW CLOSED"),
            mod.CustomNotificationSlots.HeaderText,
            3
        );

        // Deactivate zones
        teams.forEach(teamData => {
            deactivateExtractionZone(teamData);
        });
    }
}

function activateExtractionZone(teamData: TeamData) {
    const vfx = mod.GetVFX(teamData.extractionVFXId);

    // Team-colored smoke
    const color = getTeamColor(teamData.team);
    mod.SetVFXColor(vfx, color);
    mod.SetVFXScale(vfx, 2.0);
    mod.EnableVFX(vfx, true);

    // Sound cue
    const zonePos = getExtractionPosition(teamData);
    mod.PlaySound(mod.SFX.ExtractionOpen, 0.8, zonePos, 50);
}
```

---

## Advanced Features

### Item Reassignment

Items can be assigned to specific teams after first pickup:

```typescript
function pickupItem(playerData: PlayerData, item: ItemData) {
    // ... pickup logic ...

    // Assign item to picker's team (first pickup only)
    if (item.homeTeam === null) {
        item.homeTeam = playerData.team;

        mod.DisplayCustomNotificationMessage(
            mod.Message("Item claimed for your team!"),
            mod.CustomNotificationSlots.MessageText2,
            3,
            playerData.player
        );
    }
}

function canExtractItem(playerData: PlayerData, item: ItemData): boolean {
    // Can only extract items belonging to your team
    return item.homeTeam === playerData.team;
}
```

### Carrier Visibility

Players carrying items are more visible:

```typescript
function showCarrierGlow(player: mod.Player) {
    // Enable screen effect for all OTHER players
    const allPlayers = modlib.ConvertArray(mod.AllPlayers());

    allPlayers.forEach(otherPlayer => {
        if (otherPlayer === player) return;  // Skip self

        // Highlight carrier
        mod.SetPlayerVisibility(player, mod.PlayerVisibility.AlwaysVisible);
    });

    // Add world icon above carrier
    const worldIcon = mod.GetWorldIcon(carrierIconId);
    mod.AttachWorldIconToPlayer(worldIcon, player);
    mod.SetWorldIconVisibility(worldIcon, true);
}
```

---

## UI Components

### HUD Elements

1. **Item Counter** - Items extracted / Items to win
2. **Extraction Timer** - Window open/closed countdown
3. **Carrier Indicator** - "CARRYING ITEM" message
4. **Team Scores** - All 4 teams' progress
5. **Extraction Zone Marker** - On-screen arrow to extraction

### Status Effects Display

- **Speed Debuff Icon** - Red boot symbol
- **Health Debuff Icon** - Red heart symbol
- **Carrier Glow** - Yellow outline around player model

---

## Implementation Checklist

- [ ] Place 12+ item spawn points in Godot
- [ ] Create 4 extraction zones (1 per team)
- [ ] Set up 13 AI spawners
- [ ] Implement item pickup/drop with spatial objects
- [ ] Build carrier status effect system
- [ ] Create extraction progress mechanic
- [ ] Add extraction window timer system
- [ ] Implement AI enemy spawning and targeting
- [ ] Build team score tracking
- [ ] Add win condition detection

---

## Key Takeaways

### Game Design Patterns

1. **Risk/Reward Carriers** - Speed/health debuffs make item carriers vulnerable, forcing team coordination
2. **Extraction Windows** - Timed opportunities create urgency and concentration of action
3. **Neutral Items** - Items claimable by any team encourage early aggression

### Balancing Considerations

- **Carrier debuffs** (30% speed, 20% health) prevent solo runs
- **AI enemies** create PvE threat, preventing camping
- **Extraction timer** (3 seconds) allows interruption by enemies
- **Window intervals** (2 minutes) give losing teams comeback opportunities

### SDK Features Demonstrated

- ✅ 4-team simultaneous objectives
- ✅ Spatial object manipulation
- ✅ Complex pickup/drop mechanics
- ✅ Status effect system
- ✅ AI spawning and behavior
- ✅ Timed gameplay phases
- ✅ Dynamic objective zones

---

## See Also

- 📖 [Gameplay Objects](/api/gameplay-objects) - Interact points and area triggers
- 📖 [Object Transform](/api/object-transform) - Moving spatial objects
- 📖 [AI Overview](/api/ai-overview) - AI spawning and control
- 📖 [Player Control](/api/player-control) - Status effects and restrictions

---

★ Insight ─────────────────────────────────────
**Extraction Mode Design**
1. **Physical Items as State** - Using actual spatial objects instead of abstract "flags" makes the objective tangible and creates dynamic item movement across the map
2. **Negative Carrier Effects** - Speed/health debuffs transform carriers into high-value targets, forcing team protection and creating emergent teamwork
3. **Intermittent Extraction** - Timed windows concentrate action at specific moments, preventing drawn-out stalemates and creating natural pacing
─────────────────────────────────────────────────
