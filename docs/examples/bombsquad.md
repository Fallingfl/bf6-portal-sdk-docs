# BombSquad: Tactical Defuse Mode

Complete walkthrough of the BombSquad example game mode - a 5v5 tactical bomb defusal game with economy system, buy phases, and round-based gameplay.

## Overview

**BombSquad** is a Counter-Strike-style tactical shooter demonstrating:
- **Round-based gameplay** - 14 rounds with team switching at halftime
- **Economy system** - Earn money, buy weapons/equipment
- **Bomb mechanics** - Plant/defuse with progress bars
- **Buy phase** - Pre-round equipment purchase period
- **Win conditions** - Elimination, time limit, or objective completion

**Complexity:** ~800 lines | **Players:** 2-10 (5v5 optimal) | **Difficulty:** Advanced

---

## Core Architecture

### Data Structures

```typescript
type PlayerData = {
    player: mod.Player;
    team: mod.Team;
    money: number;
    alive: boolean;
    hasBomb: boolean;
    kills: number;
    deaths: number;
};

type RoundState = {
    roundNumber: number;
    attackers: mod.Team;
    defenders: mod.Team;
    buyPhaseActive: boolean;
    roundActive: boolean;
    bombPlanted: boolean;
    bombPlantTime: number;
    bombDefusing: boolean;
    defuseProgress: number;
};

enum RoundResult {
    AttackersWin_Elimination,
    DefendersWin_Elimination,
    AttackersWin_BombDetonated,
    DefendersWin_BombDefused,
    DefendersWin_TimeExpired
}
```

### Game Constants

```typescript
const ROUNDS_PER_HALF = 7;
const TOTAL_ROUNDS = 14;
const ROUNDS_TO_WIN = 8;

const BUY_PHASE_TIME = 30;    // 30 seconds to buy
const ROUND_TIME = 120;        // 2 minutes per round

const PLANT_TIME = 5;          // 5 seconds to plant bomb
const DEFUSE_TIME = 7;         // 7 seconds to defuse bomb
const BOMB_TIMER = 45;         // 45 seconds until detonation

const STARTING_MONEY = 800;
const ROUND_LOSS_MONEY = 1400;
const ROUND_WIN_MONEY = 3250;
const KILL_REWARD = 300;
```

---

## Key Systems

### 1. Round Flow

**Challenge:** Manage round lifecycle with multiple phases.

**Solution:** State machine with async phase transitions.

```typescript
async function playRound(roundNumber: number) {
    console.log(`=== ROUND ${roundNumber} START ===`);

    // Determine teams
    if (roundNumber === 1) {
        roundState.attackers = mod.Team.Team1;
        roundState.defenders = mod.Team.Team2;
    } else if (roundNumber === ROUNDS_PER_HALF + 1) {
        // Switch sides at halftime
        const temp = roundState.attackers;
        roundState.attackers = roundState.defenders;
        roundState.defenders = temp;
    }

    // Reset round state
    resetRound();

    // Phase 1: Buy Phase
    await buyPhase();

    // Phase 2: Spawn Players
    spawnAllPlayers();

    // Phase 3: Combat Phase
    await roundLoop();

    // Phase 4: Round End
    const result = determineRoundWinner();
    await showRoundResults(result);

    // Award money
    awardMoney(result);

    // Check match winner
    if (checkMatchEnd()) {
        endMatch();
    } else {
        // Next round
        await playRound(roundNumber + 1);
    }
}

function resetRound() {
    roundState.roundNumber++;
    roundState.buyPhaseActive = false;
    roundState.roundActive = false;
    roundState.bombPlanted = false;
    roundState.bombDefusing = false;

    // Reset all players
    playerData.forEach(pd => {
        pd.alive = true;
        pd.hasBomb = false;
    });
}
```

---

### 2. Economy System

**Challenge:** Track player money and enable purchases.

**Solution:** Currency tracking with shop UI.

```typescript
type ShopItem = {
    name: string;
    cost: number;
    weapon?: mod.Weapons;
    gadget?: mod.Gadgets;
    category: "primary" | "secondary" | "equipment";
};

const shopItems: ShopItem[] = [
    // Primary Weapons
    { name: "AK-24", cost: 2700, weapon: mod.Weapons.AK24, category: "primary" },
    { name: "M5A3", cost: 2900, weapon: mod.Weapons.M5A3, category: "primary" },
    { name: "LCMG", cost: 3000, weapon: mod.Weapons.LCMG, category: "primary" },

    // Secondary Weapons
    { name: "MP9", cost: 600, weapon: mod.Weapons.MP9, category: "secondary" },
    { name: "G57", cost: 300, weapon: mod.Weapons.G57, category: "secondary" },

    // Equipment
    { name: "Medic Crate", cost: 300, gadget: mod.Gadgets.MedicalCrate, category: "equipment" },
    { name: "Ammo Crate", cost: 300, gadget: mod.Gadgets.AmmoCrate, category: "equipment" },
    { name: "Frag Grenade", cost: 400, gadget: mod.Gadgets.FragGrenade, category: "equipment" },
];

async function buyPhase() {
    roundState.buyPhaseActive = true;

    // Show shop UI to all players
    playerData.forEach(pd => {
        showShopUI(pd);
    });

    // Countdown
    for (let time = BUY_PHASE_TIME; time > 0; time--) {
        // Update timer UI
        playerData.forEach(pd => {
            updateBuyPhaseTimer(pd, time);
        });

        await mod.Wait(1);
    }

    // Close shop
    roundState.buyPhaseActive = false;
    playerData.forEach(pd => {
        closeShopUI(pd);
    });
}

function purchaseItem(playerData: PlayerData, item: ShopItem): boolean {
    if (playerData.money < item.cost) {
        // Can't afford
        mod.DisplayCustomNotificationMessage(
            mod.Message("Not enough money!"),
            mod.CustomNotificationSlots.MessageText1,
            2,
            playerData.player
        );
        return false;
    }

    // Deduct money
    playerData.money -= item.cost;

    // Give item
    if (item.weapon) {
        mod.AddEquipment(playerData.player, item.weapon);
    } else if (item.gadget) {
        mod.AddEquipment(playerData.player, item.gadget);
    }

    // Update money display
    updateMoneyUI(playerData);

    return true;
}
```

---

### 3. Bomb Mechanics

**Challenge:** Implement plant/defuse interactions with progress tracking.

**Solution:** Interact points with progress bars.

#### Bomb Plant

```typescript
const BOMB_SITES = {
    A: { id: 100, position: mod.CreateVector(50, 0, 100) },
    B: { id: 101, position: mod.CreateVector(-50, 0, -100) }
};

async function bombPlantLoop() {
    while (roundState.roundActive) {
        // Find bomb carrier
        const bombCarrier = playerData.find(pd => pd.hasBomb && pd.alive);

        if (!bombCarrier) {
            await mod.Wait(0.1);
            continue;
        }

        // Check if at bomb site
        const siteA = mod.GetInteractPoint(BOMB_SITES.A.id);
        const siteB = mod.GetInteractPoint(BOMB_SITES.B.id);

        const atSiteA = mod.IsPlayerNearInteractPoint(bombCarrier.player, siteA, 5);
        const atSiteB = mod.IsPlayerNearInteractPoint(bombCarrier.player, siteB, 5);

        if (atSiteA || atSiteB) {
            // Show plant prompt
            showPlantPrompt(bombCarrier);

            // Check for plant input
            if (isPlayerHoldingInteract(bombCarrier.player)) {
                await plantBomb(bombCarrier, atSiteA ? siteA : siteB);
            }
        }

        await mod.Wait(0.1);
    }
}

async function plantBomb(playerData: PlayerData, site: mod.InteractPoint) {
    // Show progress bar
    const progressBar = createProgressBar(playerData.player, "PLANTING BOMB");

    for (let progress = 0; progress <= PLANT_TIME; progress += 0.1) {
        // Check if still near site
        if (!mod.IsPlayerNearInteractPoint(playerData.player, site, 5)) {
            removeProgressBar(progressBar);
            return;  // Canceled
        }

        // Update progress bar
        updateProgressBar(progressBar, progress / PLANT_TIME);

        await mod.Wait(0.1);
    }

    // Plant successful
    roundState.bombPlanted = true;
    roundState.bombPlantTime = mod.GetMatchTimeElapsed();

    mod.DisplayCustomNotificationMessage(
        mod.Message("BOMB HAS BEEN PLANTED!"),
        mod.CustomNotificationSlots.HeaderText,
        3
    );

    // Start bomb timer
    bombTimerLoop();

    removeProgressBar(progressBar);
}
```

#### Bomb Defuse

```typescript
async function bombDefuseLoop() {
    while (roundState.bombPlanted && roundState.roundActive) {
        // Find defenders near bomb
        const defenders = playerData.filter(pd =>
            pd.team === roundState.defenders &&
            pd.alive
        );

        for (const defender of defenders) {
            const bombPos = getBombPosition();
            const playerPos = mod.GetSoldierState(
                defender.player,
                mod.SoldierStateVector.GetPosition
            );

            const distance = calculateDistance(playerPos, bombPos);

            if (distance < 3 && isPlayerHoldingInteract(defender.player)) {
                await defuseBomb(defender);
            }
        }

        await mod.Wait(0.1);
    }
}

async function defuseBomb(playerData: PlayerData) {
    roundState.bombDefusing = true;

    const progressBar = createProgressBar(playerData.player, "DEFUSING BOMB");

    for (let progress = 0; progress <= DEFUSE_TIME; progress += 0.1) {
        // Check if interrupted (moved or died)
        if (!playerData.alive || movedTooFar(playerData)) {
            roundState.bombDefusing = false;
            removeProgressBar(progressBar);
            return;
        }

        updateProgressBar(progressBar, progress / DEFUSE_TIME);

        await mod.Wait(0.1);
    }

    // Defuse successful
    roundState.bombPlanted = false;
    roundState.bombDefusing = false;

    mod.DisplayCustomNotificationMessage(
        mod.Message("BOMB DEFUSED! DEFENDERS WIN!"),
        mod.CustomNotificationSlots.HeaderText,
        3
    );

    endRound(RoundResult.DefendersWin_BombDefused);

    removeProgressBar(progressBar);
}
```

#### Bomb Timer

```typescript
async function bombTimerLoop() {
    const plantTime = roundState.bombPlantTime;

    while (roundState.bombPlanted && roundState.roundActive) {
        const elapsed = mod.GetMatchTimeElapsed() - plantTime;
        const remaining = BOMB_TIMER - elapsed;

        // Show timer to all players
        playerData.forEach(pd => {
            updateBombTimerUI(pd, remaining);
        });

        if (remaining <= 0) {
            // Bomb explodes
            explodeBomb();
            endRound(RoundResult.AttackersWin_BombDetonated);
            break;
        }

        await mod.Wait(0.1);
    }
}

function explodeBomb() {
    const bombPos = getBombPosition();

    // Visual explosion
    const vfx = mod.GetVFX(explosionVFXId);
    mod.MoveVFX(vfx, bombPos, mod.CreateVector(0, 0, 0));
    mod.SetVFXScale(vfx, 3.0);  // Large explosion
    mod.EnableVFX(vfx, true);

    // Sound
    mod.PlaySound(mod.SFX.Explosion_Large, 1.0, bombPos, 100);

    // Damage nearby players
    playerData.forEach(pd => {
        if (!pd.alive) return;

        const playerPos = mod.GetSoldierState(
            pd.player,
            mod.SoldierStateVector.GetPosition
        );

        const distance = calculateDistance(playerPos, bombPos);

        if (distance < 20) {
            mod.DealDamage(pd.player, 100);  // Instant kill
        }
    });
}
```

---

### 4. Round Win Conditions

**Challenge:** Determine winner with multiple conditions.

**Solution:** Priority-based condition checking.

```typescript
function determineRoundWinner(): RoundResult {
    // Check bomb detonated
    if (roundState.bombPlanted && !roundState.bombDefusing) {
        const elapsed = mod.GetMatchTimeElapsed() - roundState.bombPlantTime;
        if (elapsed >= BOMB_TIMER) {
            return RoundResult.AttackersWin_BombDetonated;
        }
    }

    // Check bomb defused
    if (!roundState.bombPlanted && roundState.bombDefusing) {
        return RoundResult.DefendersWin_BombDefused;
    }

    // Check team elimination
    const attackersAlive = playerData.filter(pd =>
        pd.team === roundState.attackers && pd.alive
    ).length;

    const defendersAlive = playerData.filter(pd =>
        pd.team === roundState.defenders && pd.alive
    ).length;

    if (attackersAlive === 0) {
        return RoundResult.DefendersWin_Elimination;
    }

    if (defendersAlive === 0) {
        return RoundResult.AttackersWin_Elimination;
    }

    // Check time expired
    const roundTime = mod.GetMatchTimeElapsed();
    if (roundTime >= ROUND_TIME) {
        return RoundResult.DefendersWin_TimeExpired;
    }

    // Round still active (shouldn't reach here)
    return RoundResult.DefendersWin_TimeExpired;
}
```

---

### 5. Money Award System

**Challenge:** Reward players for performance.

**Solution:** Tiered rewards based on round result and kills.

```typescript
function awardMoney(result: RoundResult) {
    const attackersWon = result === RoundResult.AttackersWin_Elimination ||
                         result === RoundResult.AttackersWin_BombDetonated;

    playerData.forEach(pd => {
        // Base round reward
        if ((pd.team === roundState.attackers && attackersWon) ||
            (pd.team === roundState.defenders && !attackersWon)) {
            // Winning team
            pd.money += ROUND_WIN_MONEY;
        } else {
            // Losing team
            pd.money += ROUND_LOSS_MONEY;
        }

        // Kill rewards
        pd.money += pd.kills * KILL_REWARD;

        // Reset kill counter
        pd.kills = 0;

        // Update UI
        updateMoneyUI(pd);
    });
}
```

---

## Advanced Features

### Team Balancing

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
    const team1Count = playerData.filter(pd => pd.team === mod.Team.Team1).length;
    const team2Count = playerData.filter(pd => pd.team === mod.Team.Team2).length;

    // Assign to smaller team
    const assignedTeam = team1Count <= team2Count ? mod.Team.Team1 : mod.Team.Team2;

    const newPlayerData: PlayerData = {
        player: player,
        team: assignedTeam,
        money: STARTING_MONEY,
        alive: false,
        hasBomb: false,
        kills: 0,
        deaths: 0
    };

    playerData.push(newPlayerData);
    mod.SetTeam(player, assignedTeam);
}
```

### Bomb Carrier Selection

```typescript
function assignBombCarrier() {
    const attackers = playerData.filter(pd =>
        pd.team === roundState.attackers && pd.alive
    );

    if (attackers.length === 0) return;

    // Random attacker gets bomb
    const randomIndex = Math.floor(Math.random() * attackers.length);
    const carrier = attackers[randomIndex];

    carrier.hasBomb = true;

    mod.DisplayCustomNotificationMessage(
        mod.Message("YOU HAVE THE BOMB!"),
        mod.CustomNotificationSlots.HeaderText,
        3,
        carrier.player
    );

    // Show bomb icon on HUD
    showBombIcon(carrier);
}
```

---

## UI Components

### Buy Menu

- **Categories:** Primary, Secondary, Equipment
- **Item Cards:** Name, price, weapon stats
- **Money Display:** Current balance
- **Purchase Confirmation:** Visual feedback

### In-Game HUD

- **Money Counter:** Current balance (top-right)
- **Round Timer:** Time remaining (top-center)
- **Bomb Timer:** Countdown after plant (center, large)
- **Team Scores:** Rounds won (top-left)
- **Kill Feed:** Recent eliminations (right side)

### Progress Bars

- **Plant Progress:** 0-100% over 5 seconds
- **Defuse Progress:** 0-100% over 7 seconds
- **Color-coded:** Green (defuse), Red (plant)

---

## Implementation Checklist

- [ ] Create 2 bomb sites with interact points
- [ ] Implement economy system and shop UI
- [ ] Build buy phase with countdown
- [ ] Create bomb plant/defuse mechanics with progress bars
- [ ] Implement round timer and bomb timer
- [ ] Add win condition logic
- [ ] Build money reward system
- [ ] Create scoreboard with round wins
- [ ] Add team switching at halftime
- [ ] Implement match end detection

---

## Key Takeaways

### Game Design Patterns

1. **Buy Phase Isolation** - Players frozen and UI-only during buy phase prevents exploits
2. **Progress Interruption** - Plant/defuse canceled if player moves or takes damage, adding tension
3. **Multiple Win Paths** - Elimination, time, bomb detonation, or defuse creates varied strategies

### Economy Balance

- Starting: $800 (pistol + light equipment)
- Round loss: $1400 (forces eco rounds)
- Round win: $3250 (enables full buy)
- Kill reward: $300 (encourages aggressive play)

### SDK Features Demonstrated

- ✅ Interact points for bomb sites
- ✅ Progress tracking with UI bars
- ✅ Complex round-based state machine
- ✅ Team switching and rebalancing
- ✅ Custom economy system
- ✅ Multi-phase game loop

---

## See Also

- 📖 [Game Mode API](/api/game-mode) - Round lifecycle and events
- 📖 [Teams & Scoring](/api/teams-scoring) - Team management
- 📖 [UI Widgets](/api/ui-widgets) - Shop and HUD creation
- 📖 [Gameplay Objects](/api/gameplay-objects) - Interact points

---

★ Insight ─────────────────────────────────────
**Tactical Shooter Design**
1. **Economy Risk/Reward** - Loss bonus money prevents complete steamrolls, keeping matches competitive even after losing rounds
2. **Interrupt-Based Actions** - Plant/defuse require continuous proximity, making them vulnerable and creating defender/attacker tension
3. **Asymmetric Objectives** - Attackers must complete objective (plant), defenders can win by doing nothing (time), creating distinct playstyles
─────────────────────────────────────────────────
