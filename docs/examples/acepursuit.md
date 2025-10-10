# AcePursuit: Vehicle Racing Mode

Complete walkthrough of the AcePursuit example game mode - an 8-player vehicle racing game with lap tracking, checkpoint systems, and rubber-banding mechanics.

## Overview

**AcePursuit** is a fully-featured vehicle racing game mode demonstrating:
- **Lap-based racing** - Multiple laps with checkpoint validation
- **Checkpoint system** - Ordered waypoint tracking with skip prevention
- **Vehicle spawning** - Automatic vehicle assignment at race start
- **UI system** - Real-time HUD, scoreboard, and placement displays
- **Rubber-banding** - Catchup mechanics for trailing players
- **AI competitors** - Optional AI racers (14 spawn points)

**Complexity:** ~800 lines | **Players:** 1-8 | **Difficulty:** Advanced

---

## Core Architecture

### Data Structures

```typescript
type Checkpoint = {
    id: number;
    position: Vector3;
    checkpointStart: Vector3;
    checkpointEnd: Vector3;
    flipdir?: boolean;
};

type RaceTrack = {
    trackId: string;
    name: string;
    laps: number;
    gametype: GameType;
    availableVehicles: mod.VehicleList[];
    checkPoints: Checkpoint[];
};

class PlayerProfile {
    player: mod.Player;
    lap: number = 0;
    checkpoint: number = 0;
    completedTrack: boolean = false;
    playerRaceTime: number = 0;
    readyUp: boolean = false;
    vehicle: mod.Vehicle | undefined;
    // ... UI components
}

class TrackData {
    trackId: string;
    checkPoints: Checkpoint[];
    laps: number;
    playersInRace: PlayerProfile[] = [];
    raceTime: number = 0;
    winner: boolean = false;
    winnerPlayer: PlayerProfile | undefined;
    trackState: TrackState;
    // ... race management
}
```

### Race States

```typescript
enum TrackState {
    none,           // No race active
    selected,       // Track selected, waiting for players
    readyup,        // Players ready-up phase
    countdown,      // 3-2-1 countdown
    racing,         // Race in progress
    winnerFound,    // First player finished
    over            // Race complete
}
```

---

## Key Systems

### 1. Checkpoint Tracking

**Challenge:** Detect when players pass through checkpoints in the correct order.

**Solution:** Area triggers with sequential validation.

```typescript
async function checkpointLoop(playerProfile: PlayerProfile) {
    while (playerProfile.completedTrack === false) {
        const currentCheckpoint = currentRace.checkPoints[playerProfile.checkpoint];
        const areaTrigger = mod.GetAreaTrigger(currentCheckpoint.id);

        // Check if player is in checkpoint area
        if (mod.IsPlayerInAreaTrigger(playerProfile.player, areaTrigger)) {
            // Player passed checkpoint
            playerProfile.checkpoint++;

            // Check if completed lap
            if (playerProfile.checkpoint >= currentRace.checkPoints.length) {
                playerProfile.lap++;
                playerProfile.checkpoint = 0;

                // Check if finished race
                if (playerProfile.lap >= currentRace.laps) {
                    currentRace.PlayerCompletedTrack(playerProfile);
                    break;
                }
            }

            // Update HUD
            updateCheckpointUI(playerProfile);
        }

        await mod.Wait(0.1);  // Check 10 times per second
    }
}
```

**Key Points:**
- Each checkpoint is an area trigger placed in the Godot editor
- Sequential validation prevents skipping checkpoints
- Lap counter increments when all checkpoints are passed
- Race completion triggers when lap count reaches target

---

### 2. Vehicle System

**Challenge:** Spawn and assign vehicles to players at race start.

**Solution:** Vehicle spawners with automatic assignment.

```typescript
async function spawnPlayerVehicle(playerProfile: PlayerProfile) {
    // Get random vehicle from track's allowed vehicles
    const vehicleType = getRandomVehicle(currentRace.availableVehicles);

    // Get vehicle spawner
    const spawner = mod.GetVehicleSpawner(playerProfile.vehicleSpawnerId);

    // Configure spawner
    mod.SetVehicleSpawnerType(spawner, vehicleType);
    mod.SetVehicleSpawnerRespawnTime(spawner, 5);  // 5 second respawn
    mod.SetVehicleSpawnerAutoSpawn(spawner, true);

    // Wait for spawn
    await mod.Wait(0.5);

    // Get spawned vehicle
    playerProfile.vehicle = mod.GetVehicleAtSpawner(spawner);

    // Teleport player to vehicle
    const vehiclePos = mod.GetVehicleTransform(playerProfile.vehicle).position;
    mod.TeleportPlayer(playerProfile.player, vehiclePos, mod.CreateVector(0, 0, 0));
}
```

**Vehicle Types Used:**
- Light vehicles (ATVs, buggies) for agile tracks
- Heavy vehicles (trucks) for off-road courses
- Mixed vehicle types for variety

---

### 3. Ready-Up System

**Challenge:** Wait for players to ready-up before starting race.

**Solution:** Countdown timer with ready status tracking.

```typescript
async function readyUpPhase() {
    currentRace.trackState = TrackState.readyup;
    let countdownTime = 35;  // 35 seconds to ready-up

    // Show ready-up UI to all players
    currentRace.playersInRace.forEach(pp => {
        pp.readyUpUI?.Open(countdownTime);
    });

    while (countdownTime > 0) {
        // Check if all players ready
        const allReady = currentRace.playersInRace.every(pp => pp.readyUp);

        if (allReady) {
            console.log("All players ready!");
            break;
        }

        // Update countdown
        currentRace.playersInRace.forEach(pp => {
            pp.readyUpUI?.update(countdownTime);
        });

        await mod.Wait(1);
        countdownTime--;
    }

    // Start race countdown
    await raceCountdown();
}

// Player input handling
export async function OnPlayerButtonPressed(player: mod.Player, button: mod.UIButton) {
    const playerProfile = PlayerProfile.get(player);

    if (button === readyButton) {
        playerProfile.readyUp = true;
        playerProfile.readyUpUI?.SetReadyStatus(true);
    }
}
```

---

### 4. Scoreboard System

**Challenge:** Display real-time race positions and lap progress.

**Solution:** Dynamic UI updates with player ranking.

```typescript
class ScoreboardUI {
    container: mod.UIWidget;
    rows: Map<mod.Player, UIRow> = new Map();

    update() {
        // Sort players by race progress
        const sortedPlayers = currentRace.playersInRace.sort((a, b) => {
            // Sort by: laps completed > checkpoints passed > distance to next checkpoint
            if (a.lap !== b.lap) return b.lap - a.lap;
            if (a.checkpoint !== b.checkpoint) return b.checkpoint - a.checkpoint;

            // Calculate distance to next checkpoint
            const aDistance = calculateCheckpointDistance(a);
            const bDistance = calculateCheckpointDistance(b);
            return aDistance - bDistance;
        });

        // Update UI rows
        sortedPlayers.forEach((playerProfile, index) => {
            const row = this.rows.get(playerProfile.player);

            // Update position
            mod.SetUITextLabel(row.position, mod.Message(`#${index + 1}`));

            // Update lap counter
            mod.SetUITextLabel(
                row.lapText,
                mod.Message(`Lap ${playerProfile.lap + 1}/${currentRace.laps}`)
            );

            // Update checkpoint counter
            mod.SetUITextLabel(
                row.checkpointText,
                mod.Message(`CP ${playerProfile.checkpoint}/${currentRace.checkPoints.length}`)
            );
        });
    }
}
```

**Update Frequency:** Every 0.5 seconds during race.

---

### 5. Rubber-Banding (Catchup Mechanic)

**Challenge:** Keep races competitive by helping trailing players.

**Solution:** Speed boost for players far behind the leader.

```typescript
async function rubberBandingLoop() {
    while (currentRace.trackState === TrackState.racing) {
        // Find leader
        const leader = findLeadingPlayer();

        // Apply catchup to trailing players
        currentRace.playersInRace.forEach(playerProfile => {
            if (playerProfile === leader) return;  // Skip leader

            // Calculate race progress difference
            const progressDiff = calculateProgressDifference(leader, playerProfile);

            // Apply speed boost if far behind
            if (progressDiff > 2) {  // More than 2 checkpoints behind
                const vehicle = playerProfile.vehicle;

                if (vehicle) {
                    // Increase vehicle speed
                    mod.SetVehicleMaxSpeed(vehicle, 1.2);  // 20% faster

                    // Optional: Disable sprint to balance
                    if (catchupMechanicSprintDisable) {
                        mod.EnableInputRestriction(
                            playerProfile.player,
                            mod.RestrictedInputs.Sprint,
                            true
                        );
                    }
                }
            } else {
                // Remove catchup boost
                const vehicle = playerProfile.vehicle;
                if (vehicle) {
                    mod.SetVehicleMaxSpeed(vehicle, 1.0);  // Normal speed
                }
            }
        });

        await mod.Wait(2);  // Check every 2 seconds
    }
}
```

**Balancing:**
- Only activates when 2+ checkpoints behind
- 20% speed increase
- Optional sprint disable to prevent abuse

---

### 6. Winner Detection & End Game

**Challenge:** Handle race completion and show final results.

**Solution:** Track first finisher, then countdown for remaining players.

```typescript
async function handleRaceCompletion(playerProfile: PlayerProfile) {
    playerProfile.playerRaceTime = mod.GetMatchTimeElapsed();
    playerProfile.completedTrack = true;

    // Update all scoreboards
    currentRace.playersInRace.forEach(pp => {
        pp.ScoreboardUI?.update();
    });

    // First finisher = winner
    if (currentRace.winnerPlayer === undefined) {
        currentRace.winnerPlayer = playerProfile;
        currentRace.trackState = TrackState.winnerFound;

        // Show victory message
        playerProfile.PlacementUI?.Open("VICTORY!", 0, 85);

        await mod.Wait(2);

        // Start countdown for remaining racers
        let countdown = 45;
        currentRace.playersInRace.forEach(pp => {
            pp.EndingCountDownUI?.Open(countdown);
        });

        // Countdown loop
        while (countdown > 0 && hasActiveRacers()) {
            currentRace.playersInRace.forEach(pp => {
                pp.EndingCountDownUI?.update(countdown);
            });
            await mod.Wait(1);
            countdown--;
        }

        // End game
        currentRace.trackState = TrackState.over;
        mod.EndGameMode(playerProfile.player);

    } else {
        // Subsequent finishers
        const placement = calculatePlacement(playerProfile);
        playerProfile.PlacementUI?.Open(`PLACE #${placement}`, placement, 45);
    }
}

function hasActiveRacers(): boolean {
    return currentRace.playersInRace.some(pp => pp.completedTrack === false);
}
```

---

## Advanced Features

### AI Competitors

**14 AI spawn points** for bot racers:

```typescript
async function spawnAICompetitors() {
    const aiSpawnPoints = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];

    for (const spawnId of aiSpawnPoints) {
        const aiSpawner = mod.GetAISpawner(spawnId);

        // Spawn AI
        const ai = mod.SpawnAIFromAISpawner(aiSpawner);

        // Give AI vehicle
        await spawnAIVehicle(ai);

        // Set AI behavior
        mod.AISetBehavior(ai, mod.AIBehaviors.WaypointPatrol);
        mod.AISetMoveSpeed(ai, mod.MoveSpeed.Fast);
    }
}
```

### Track Definition System

Multiple tracks with different configurations:

```typescript
const tracks: RaceTrack[] = [
    {
        trackId: "city_circuit",
        name: "City Circuit",
        laps: 3,
        gametype: GameType.race,
        availableVehicles: [
            mod.VehicleList.LATV4_Recon,
            mod.VehicleList.Polaris_RZR
        ],
        checkPoints: [
            { id: 1, position: {x: 100, y: 0, z: 50}, ... },
            { id: 2, position: {x: 200, y: 0, z: 100}, ... },
            // ... more checkpoints
        ]
    },
    // ... more tracks
];
```

### Time Survival Mode

Alternative game mode (not just racing):

```typescript
enum GameType {
    race = 0,         // Standard lap-based race
    timeSurvival = 1  // Survive for longest time
}
```

---

## UI Components

### HUD Elements

1. **Lap Counter** - Current lap / total laps
2. **Checkpoint Counter** - Current checkpoint / total checkpoints
3. **Position Indicator** - Current race position (#1, #2, etc.)
4. **Speed Meter** - Current vehicle speed
5. **Mini-Map** - Optional track overview

### Menu Screens

1. **Ready-Up Screen** - Countdown with ready button
2. **Race Countdown** - 3-2-1-GO animation
3. **Placement Screen** - Final position display
4. **Scoreboard** - Live rankings during race

---

## Implementation Checklist

To create a similar racing mode:

- [ ] Place checkpoint area triggers in Godot
- [ ] Configure vehicle spawners (1 per player)
- [ ] Create track data structure with checkpoint positions
- [ ] Implement PlayerProfile class for state tracking
- [ ] Build checkpoint detection loop
- [ ] Create ready-up system with UI
- [ ] Implement race countdown
- [ ] Build dynamic scoreboard
- [ ] Add rubber-banding mechanics (optional)
- [ ] Handle winner detection and end game
- [ ] Test with multiple players

---

## Key Takeaways

### Architecture Patterns

1. **Class-Based State Management** - PlayerProfile and TrackData classes encapsulate complex state
2. **State Machine Pattern** - TrackState enum controls race flow
3. **Async Loops** - Separate loops for checkpoints, UI updates, rubber-banding
4. **Data-Driven Tracks** - Track configurations separate from game logic

### Performance Considerations

- Checkpoint detection runs at 10 Hz (0.1s intervals)
- Scoreboard updates at 2 Hz (0.5s intervals)
- Rubber-banding checks at 0.5 Hz (2s intervals)
- UI updates batched to minimize calls

### SDK Features Demonstrated

- ✅ Vehicle spawning and control
- ✅ Area trigger detection
- ✅ Complex UI system with multiple components
- ✅ Player state tracking
- ✅ AI integration
- ✅ Game mode lifecycle management

---

## See Also

- 📖 [Vehicle API](/api/vehicles) - Vehicle spawning and control
- 📖 [Gameplay Objects](/api/gameplay-objects) - Area triggers and spawners
- 📖 [UI Widgets](/api/ui-widgets) - Building race HUD
- 📖 [Game Mode API](/api/game-mode) - Race lifecycle management

---

★ Insight ─────────────────────────────────────
**Racing Game Design**
1. **Sequential Validation** - Checkpoint system prevents exploits by requiring players to pass through checkpoints in order
2. **Progress-Based Sorting** - Ranking considers laps, checkpoints, and distance to next checkpoint for accurate positions even mid-lap
3. **Balanced Catchup** - Rubber-banding only activates when significantly behind (2+ checkpoints), preventing leader punishment while keeping races competitive
─────────────────────────────────────────────────
