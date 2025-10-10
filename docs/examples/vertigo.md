# Vertigo - Vertical Climbing Race

**Vertigo** is a 4-team vertical climbing race game mode. It's the simplest example mod (308 lines) and perfect for learning core SDK concepts.

## Overview

| Property | Value |
|----------|-------|
| **File** | `mods/Vertigo/Vertigo.ts` |
| **Lines of Code** | 308 |
| **Difficulty** | ⭐ Beginner |
| **Teams** | 4 teams (FFA scoring) |
| **Map** | Any (uses vertical checkpoints) |
| **Key Concepts** | Checkpoints, teleportation, team mechanics, UI |

## Game Mode Mechanics

### Objective
Be the first player to reach all checkpoints by climbing vertically through the map.

### How It Works
1. Players spawn at the bottom of the map
2. Must reach checkpoints in order
3. Each checkpoint teleports player to the next one
4. First to reach final checkpoint wins
5. Players compete individually but organized in 4 teams

### Core Features
- ✅ Checkpoint system with validation
- ✅ Teleportation between checkpoints
- ✅ Team assignment (4 teams)
- ✅ Victory detection
- ✅ Player state tracking
- ✅ Simple lobby system

## Code Walkthrough

### Data Structures

The mod uses a class to track per-player state:

```typescript
class PlayerProfile {
  player: mod.Player;
  currentCheckpoint: number = 0;  // Which checkpoint player is at
  hasWon: boolean = false;         // Did player finish?

  constructor(player: mod.Player) {
    this.player = player;
  }
}
```

### Global State

```typescript
// Track all players in the game
let playersInGame: PlayerProfile[] = [];

// Track teams (4 teams for FFA-style competition)
const teams = [
  mod.Team.Team1,
  mod.Team.Team2,
  mod.Team.Team3,
  mod.Team.Team4
];

// Game state
let gameStarted = false;
```

### Game Initialization

```typescript
export async function OnGameModeStarted() {
  // Configure game settings
  mod.SetGameTimeLimit(600);  // 10 minutes
  mod.SetMaxPlayerCount(16);  // Max 16 players

  // Set up checkpoints
  setupCheckpoints();

  // Start lobby countdown
  await lobbyCountdown();

  gameStarted = true;
}
```

### Player Join Handler

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  // Create player profile
  const profile = new PlayerProfile(player);
  playersInGame.push(profile);

  // Assign to a team (round-robin)
  const teamIndex = playersInGame.length % 4;
  mod.SetPlayerTeam(player, teams[teamIndex]);

  // Spawn player at starting position
  const startSpawner = mod.GetSpawner(1);
  mod.SpawnPlayerFromSpawnPoint(player, startSpawner);

  // Show welcome message
  modlib.DisplayCustomNotificationMessage(
    "Reach all checkpoints to win!",
    mod.NotificationSlot.HeaderText,
    5,
    player
  );
}
```

### Checkpoint System

The core mechanic uses area triggers:

```typescript
// Checkpoint triggers are placed in Godot with Obj IDs 10-14
const checkpointTriggers = [
  mod.GetAreaTrigger(10),  // Checkpoint 1
  mod.GetAreaTrigger(11),  // Checkpoint 2
  mod.GetAreaTrigger(12),  // Checkpoint 3
  mod.GetAreaTrigger(13),  // Checkpoint 4
  mod.GetAreaTrigger(14)   // Final checkpoint
];

// Teleport positions for each checkpoint
const checkpointPositions = [
  new mod.Vector(0, 0, 10),      // Checkpoint 1 position
  new mod.Vector(0, 0, 30),      // Checkpoint 2 position
  new mod.Vector(0, 0, 50),      // Checkpoint 3 position
  new mod.Vector(0, 0, 70),      // Checkpoint 4 position
  new mod.Vector(0, 0, 100)      // Final position
];
```

### Trigger Detection

```typescript
// Check if players are in checkpoint zones
function checkCheckpoints() {
  for (const profile of playersInGame) {
    if (profile.hasWon) continue;  // Skip winners

    const nextCheckpoint = profile.currentCheckpoint;
    if (nextCheckpoint >= checkpointTriggers.length) continue;

    const trigger = checkpointTriggers[nextCheckpoint];

    // Check if player is in the trigger zone
    if (mod.IsPlayerInAreaTrigger(profile.player, trigger)) {
      reachedCheckpoint(profile);
    }
  }
}

// Called every frame (via loop in OnGameModeStarted)
async function gameLoop() {
  while (gameStarted) {
    checkCheckpoints();
    await mod.Wait(0.1);  // Check every 100ms
  }
}
```

### Checkpoint Reached

```typescript
function reachedCheckpoint(profile: PlayerProfile) {
  const checkpointNum = profile.currentCheckpoint;

  // Play sound effect
  const soundPos = mod.GetPlayerTransform(profile.player).position;
  mod.PlaySound(mod.Sounds.CheckpointReached, soundPos);

  // Show notification
  modlib.DisplayCustomNotificationMessage(
    `Checkpoint ${checkpointNum + 1} reached!`,
    mod.NotificationSlot.MessageText1,
    2,
    profile.player
  );

  // Teleport to next checkpoint
  if (checkpointNum < checkpointPositions.length - 1) {
    profile.currentCheckpoint++;
    const nextPos = checkpointPositions[profile.currentCheckpoint];
    mod.Teleport(profile.player, nextPos, 0);
  } else {
    // Reached final checkpoint - player wins!
    playerWon(profile);
  }
}
```

### Victory Condition

```typescript
function playerWon(profile: PlayerProfile) {
  profile.hasWon = true;

  // Award massive points
  mod.SetPlayerScore(profile.player, 10000);

  // Announce winner to everyone
  const allPlayers = modlib.ConvertArray(mod.GetPlayers());
  for (const p of allPlayers) {
    modlib.DisplayCustomNotificationMessage(
      `${mod.GetPlayerName(profile.player)} won the race!`,
      mod.NotificationSlot.HeaderText,
      10,
      p
    );
  }

  // Set winning player and end game
  mod.SetWinningPlayer(profile.player);
  await mod.Wait(5);
  mod.EndGame();
}
```

## Key Concepts Demonstrated

### 1. Player State Tracking

```typescript
// Create a class to track per-player data
class PlayerProfile {
  player: mod.Player;
  currentCheckpoint: number = 0;
  hasWon: boolean = false;

  constructor(player: mod.Player) {
    this.player = player;
  }
}

// Store all player profiles
let playersInGame: PlayerProfile[] = [];
```

**Why This Matters:**
- The SDK doesn't persist custom data on `mod.Player` objects
- You must maintain your own state tracking
- Use classes or objects to associate data with players

### 2. Area Triggers

```typescript
// In Godot: Place AreaTrigger objects, set Obj IDs
// In TypeScript: Get triggers by ID
const trigger = mod.GetAreaTrigger(10);

// Check if player is in trigger zone
if (mod.IsPlayerInAreaTrigger(player, trigger)) {
  // Player entered the zone!
}
```

**Why This Matters:**
- Area triggers detect when players enter/exit zones
- Perfect for checkpoints, capture points, goal zones
- Must be placed in Godot with unique Obj IDs

### 3. Teleportation

```typescript
// Create position vector
const destination = new mod.Vector(x, y, z);

// Teleport player
mod.Teleport(player, destination, orientation);
```

**Why This Matters:**
- Instant player movement without physics
- `orientation` is rotation in degrees (0-360)
- Use for checkpoints, respawns, fast travel

### 4. Game Loop Pattern

```typescript
export async function OnGameModeStarted() {
  // Start background loop
  gameLoop();  // Don't await - let it run independently
}

async function gameLoop() {
  while (gameStarted) {
    // Check conditions every frame
    checkCheckpoints();
    checkVictory();

    // Wait before next check
    await mod.Wait(0.1);  // 100ms = 10 checks per second
  }
}
```

**Why This Matters:**
- Continuous checking for game conditions
- `await mod.Wait()` prevents blocking
- Balance check frequency vs performance

### 5. Team Assignment

```typescript
const teams = [mod.Team.Team1, mod.Team.Team2, mod.Team.Team3, mod.Team.Team4];

// Round-robin team assignment
const teamIndex = playersInGame.length % teams.length;
mod.SetPlayerTeam(player, teams[teamIndex]);
```

**Why This Matters:**
- Distributes players evenly across teams
- Modulo (`%`) operator cycles through teams
- Good for FFA-style modes with team organization

## How to Modify This Mode

### Make It Easier
```typescript
// Disable fall damage
export async function OnPlayerDied(player: mod.Player) {
  // Instantly revive at last checkpoint
  await mod.Wait(0.1);
  mod.Revive(player);

  const profile = findPlayerProfile(player);
  const checkpointPos = checkpointPositions[profile.currentCheckpoint];
  mod.Teleport(player, checkpointPos, 0);
}
```

### Add Rewards
```typescript
function reachedCheckpoint(profile: PlayerProfile) {
  // Award points for each checkpoint
  const currentScore = mod.GetPlayerScore(profile.player);
  mod.SetPlayerScore(profile.player, currentScore + 500);

  // Give speed boost
  mod.SetMovementSpeedScale(profile.player, 1.5);  // 50% faster

  // ... rest of checkpoint logic
}
```

### Add Time Pressure
```typescript
export async function OnGameModeStarted() {
  mod.SetGameTimeLimit(180);  // 3 minutes

  // Countdown warnings
  await mod.Wait(120);  // After 2 minutes
  announceToAll("1 minute remaining!");

  await mod.Wait(30);  // After 2:30
  announceToAll("30 seconds left!");
}
```

### Add Penalties for Death
```typescript
export async function OnPlayerDied(player: mod.Player) {
  const profile = findPlayerProfile(player);

  // Reset to previous checkpoint
  if (profile.currentCheckpoint > 0) {
    profile.currentCheckpoint--;
  }

  // Respawn at new position
  await mod.Wait(3);
  mod.Revive(player);
  const pos = checkpointPositions[profile.currentCheckpoint];
  mod.Teleport(player, pos, 0);
}
```

## Full Code

View the complete source code:
```
PortalSDK/mods/Vertigo/Vertigo.ts
```

## Dependencies

### Required Objects in Godot

Place these objects in your map:

| Object Type | Obj ID | Purpose |
|-------------|--------|---------|
| SpawnPoint | 1 | Starting spawn location |
| AreaTrigger | 10 | Checkpoint 1 trigger |
| AreaTrigger | 11 | Checkpoint 2 trigger |
| AreaTrigger | 12 | Checkpoint 3 trigger |
| AreaTrigger | 13 | Checkpoint 4 trigger |
| AreaTrigger | 14 | Final checkpoint trigger |

### Required Imports

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';
```

## Related Examples

- [AcePursuit](/examples/acepursuit) - Racing with vehicles instead of climbing
- [Checkpoint Tutorial](/tutorials/checkpoint-system) - Deep dive into checkpoint mechanics

## Next Steps

After understanding Vertigo, try:

1. 🔧 **Modify Vertigo**
   - Change checkpoint count
   - Add power-ups at checkpoints
   - Create horizontal race instead of vertical

2. 📖 **Learn More Concepts**
   - [Area Triggers](/api/gameplay-objects#area-triggers)
   - [Teleportation](/api/player-control#teleport)
   - [Victory Conditions](/api/game-mode#victory)

3. 🚀 **Build Your Own**
   - Obstacle course mode
   - Parkour challenges
   - Escape room mode

---

::: tip Why Vertigo Is Great for Learning
1. Simple, focused mechanics
2. Demonstrates core concepts clearly
3. Easy to modify and experiment
4. Shortest example (308 lines)
5. No complex UI or economy systems
:::
