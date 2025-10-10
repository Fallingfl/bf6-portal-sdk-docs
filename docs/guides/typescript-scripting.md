# TypeScript Scripting

Learn how to write game logic for your custom Battlefield Portal modes using TypeScript and the complete SDK API.

## Overview

TypeScript is the programming language used to define game logic in Portal SDK. Unlike the web-based Blockly editor, TypeScript gives you:

- **Full API Access** - All 545 functions available
- **Type Safety** - Catch errors before uploading
- **IDE Support** - Autocomplete and documentation
- **Complex Logic** - Loops, conditions, classes, async/await
- **Code Reusability** - Functions, modules, helpers

## Basic Structure

Every game mode TypeScript file follows this pattern:

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';

// Global variables (game state)
let gameStarted = false;
let playerData = [];

// Event Hooks (required exports)
export async function OnGameModeStarted() {
  // Initialize game mode
}

export async function OnPlayerJoinGame(player: mod.Player) {
  // Handle new player
}

// ... other event hooks

// Helper functions (optional)
function myCustomFunction() {
  // Reusable logic
}
```

## Event Hooks

The SDK calls these exported functions automatically at specific game events.

### OnGameModeStarted

**When Called:** Once when the experience starts

**Purpose:** Initialize game mode, configure settings, start background systems

```typescript
export async function OnGameModeStarted() {
  // Set game rules
  mod.SetGameTimeLimit(600);  // 10 minutes
  mod.SetMaxPlayerCount(32);  // Max 32 players

  // Configure teams
  mod.SetTeamName(mod.Team.Team1, "Attackers");
  mod.SetTeamName(mod.Team.Team2, "Defenders");
  mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);
  mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);

  // Start background systems
  gameLoop();  // Don't await - runs independently

  console.log("Game mode started!");
}
```

**Common Tasks:**
- Set time limits and player counts
- Configure team names and colors
- Initialize global variables
- Start background loops
- Disable player join during setup

### OnPlayerJoinGame

**When Called:** When a player joins the lobby (before spawning)

**Purpose:** Setup new player, assign team, show welcome messages

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  // Assign to a team
  mod.SetPlayerTeam(player, mod.Team.Team1);

  // Store player data
  playerData.push({
    player: player,
    score: 0,
    kills: 0
  });

  // Show welcome message
  modlib.DisplayCustomNotificationMessage(
    "Welcome! Press DEPLOY to spawn.",
    mod.NotificationSlot.HeaderText,
    5,
    player
  );

  console.log("Player joined:", mod.GetPlayerName(player));
}
```

**Common Tasks:**
- Assign player to team
- Create player data tracking
- Show welcome notifications
- Configure initial loadout
- Display rules or instructions

### OnPlayerLeaveGame

**When Called:** When a player disconnects or quits

**Purpose:** Cleanup player data, handle team rebalancing

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  // Remove from tracking
  playerData = playerData.filter(p => mod.GetPlayerId(p.player) !== playerId);

  // Rebalance teams if needed
  if (playerData.length < 4) {
    // Handle low player count
  }

  console.log("Player left:", playerId);
}
```

**Important:** You receive a `string` ID, not a `mod.Player` object!

### OnPlayerDeployed

**When Called:** When a player clicks the Deploy button and spawns into the map

**Purpose:** Spawn player at correct location, give equipment, show HUD

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Get spawn point
  const spawner = mod.GetSpawner(1);

  // Spawn player
  mod.SpawnPlayerFromSpawnPoint(player, spawner);

  // Give equipment
  mod.AddEquipment(player, mod.Weapons.AK24);
  mod.AddEquipment(player, mod.Gadgets.MedicBag);

  // Set health
  mod.SetPlayerMaxHealth(player, 100);

  // Show HUD
  showPlayerHUD(player);

  console.log("Player deployed!");
}
```

**Common Tasks:**
- Spawn at appropriate spawn point
- Give weapons and gadgets
- Set health and armor
- Display UI elements
- Apply player modifiers (speed, jump height, etc.)

### OnPlayerDied

**When Called:** When a player dies

**Purpose:** Handle respawn, update scores, show death screen

```typescript
export async function OnPlayerDied(player: mod.Player) {
  // Update stats
  const data = findPlayerData(player);
  data.deaths++;

  // Show death message
  modlib.DisplayCustomNotificationMessage(
    "You died! Respawning in 5 seconds...",
    mod.NotificationSlot.MessageText1,
    5,
    player
  );

  // Wait before respawn
  await mod.Wait(5);

  // Respawn player
  mod.Revive(player);

  console.log("Player died!");
}
```

**Common Tasks:**
- Wait before respawn
- Update death statistics
- Revive player
- Reset player state
- Handle special death mechanics

### OnPlayerEarnedKill

**When Called:** When a player kills another player

**Purpose:** Award points, update stats, show kill feed

```typescript
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  // Award points
  const currentScore = mod.GetPlayerScore(killer);
  mod.SetPlayerScore(killer, currentScore + 100);

  // Update stats
  const killerData = findPlayerData(killer);
  killerData.kills++;

  // Show kill notification
  modlib.DisplayCustomNotificationMessage(
    `+100 | ${mod.GetWeaponName(weapon)}`,
    mod.NotificationSlot.MessageText2,
    2,
    killer
  );

  // Check for victory
  if (currentScore + 100 >= 3000) {
    mod.SetWinningPlayer(killer);
    mod.EndGame();
  }

  console.log("Kill:", mod.GetPlayerName(killer), "→", mod.GetPlayerName(victim));
}
```

**Common Tasks:**
- Award points/currency
- Update kill statistics
- Check victory conditions
- Show notifications
- Trigger killstreak rewards

### OnPlayerSwitchTeam

**When Called:** When a player manually switches teams

**Purpose:** Handle team rebalancing, reset player state

```typescript
export async function OnPlayerSwitchTeam(
  player: mod.Player,
  newTeam: mod.Team
) {
  // Reset player stats for new team
  const data = findPlayerData(player);
  data.score = 0;

  // Kill and respawn
  mod.Kill(player);
  await mod.Wait(2);
  mod.Revive(player);

  // Show team change message
  modlib.DisplayCustomNotificationMessage(
    `Switched to ${mod.GetTeamName(newTeam)}`,
    mod.NotificationSlot.HeaderText,
    3,
    player
  );

  console.log("Player switched teams!");
}
```

**Common Tasks:**
- Reset player progress
- Kill and respawn at new team's spawn
- Update team statistics
- Rebalance teams if needed

## TypeScript Basics for SDK

### Variables and Types

```typescript
// Numbers
let score: number = 0;
let health: number = 100.0;

// Strings
let playerName: string = "Soldier";

// Booleans
let isAlive: boolean = true;
let hasFlag: boolean = false;

// Arrays
let players: mod.Player[] = [];
let scores: number[] = [0, 0, 0];

// Objects
let playerData = {
  player: null as mod.Player,
  kills: 0,
  deaths: 0
};

// SDK Types (opaque - get from API only)
let player: mod.Player;
let team: mod.Team = mod.Team.Team1;
let vehicle: mod.Vehicle;
```

### Functions

```typescript
// Basic function
function calculateScore(kills: number, deaths: number): number {
  return (kills * 100) - (deaths * 50);
}

// Async function (required for event hooks)
async function delayedAction() {
  console.log("Starting...");
  await mod.Wait(5);  // Wait 5 seconds
  console.log("Done!");
}

// Function with SDK types
function teleportToSpawn(player: mod.Player) {
  const spawner = mod.GetSpawner(1);
  const transform = mod.GetSpawnerTransform(spawner);
  mod.Teleport(player, transform.position, 0);
}
```

### Loops

```typescript
// For loop (traditional)
for (let i = 0; i < 10; i++) {
  console.log("Count:", i);
}

// For...of loop (arrays)
const players = modlib.ConvertArray(mod.GetPlayers());
for (const player of players) {
  mod.SetPlayerMaxHealth(player, 150);
}

// While loop (game loops)
async function gameLoop() {
  while (gameRunning) {
    checkVictoryConditions();
    updateScoreboard();
    await mod.Wait(1);  // Wait 1 second between checks
  }
}
```

### Conditionals

```typescript
// If/Else
if (score >= 1000) {
  announceWinner();
} else if (score >= 500) {
  announceLeading();
} else {
  announceProgress();
}

// Ternary operator
const message = isAlive ? "You're alive!" : "You died!";

// Switch statement
switch (team) {
  case mod.Team.Team1:
    color = mod.TeamColor.Red;
    break;
  case mod.Team.Team2:
    color = mod.TeamColor.Blue;
    break;
  default:
    color = mod.TeamColor.White;
}
```

### Classes

```typescript
class PlayerProfile {
  player: mod.Player;
  kills: number = 0;
  deaths: number = 0;
  score: number = 0;

  constructor(player: mod.Player) {
    this.player = player;
  }

  addKill() {
    this.kills++;
    this.score += 100;
  }

  addDeath() {
    this.deaths++;
  }

  getKDRatio(): number {
    return this.deaths > 0 ? this.kills / this.deaths : this.kills;
  }
}

// Usage
let profiles: PlayerProfile[] = [];

export async function OnPlayerJoinGame(player: mod.Player) {
  const profile = new PlayerProfile(player);
  profiles.push(profile);
}
```

## Common Patterns

### Game Loop Pattern

```typescript
let gameRunning = false;

export async function OnGameModeStarted() {
  gameRunning = true;
  gameLoop();  // Start loop (don't await)
}

async function gameLoop() {
  while (gameRunning) {
    // Check conditions every frame
    checkObjectives();
    updateUI();
    checkVictory();

    // Wait before next iteration
    await mod.Wait(0.1);  // 10 times per second
  }
}
```

### Player Data Tracking

```typescript
interface PlayerData {
  player: mod.Player;
  score: number;
  team: mod.Team;
}

let playerData: PlayerData[] = [];

function findPlayerData(player: mod.Player): PlayerData | undefined {
  return playerData.find(p => p.player === player);
}

function removePlayerData(playerId: string) {
  playerData = playerData.filter(p => mod.GetPlayerId(p.player) !== playerId);
}
```

### Array Iteration (mod.Array)

```typescript
// Option 1: Convert to JavaScript array (recommended)
const players = modlib.ConvertArray(mod.GetPlayers());
for (const player of players) {
  console.log(mod.GetPlayerName(player));
}

// Option 2: Manual iteration
const playersArray = mod.GetPlayers();
const count = mod.GetArrayLength(playersArray);
for (let i = 0; i < count; i++) {
  const player = mod.GetArrayElement(playersArray, i);
  console.log(mod.GetPlayerName(player));
}
```

### Team Assignment Strategies

```typescript
// Round-robin (distribute evenly)
const teams = [mod.Team.Team1, mod.Team.Team2];
let playerCount = 0;

export async function OnPlayerJoinGame(player: mod.Player) {
  const teamIndex = playerCount % teams.length;
  mod.SetPlayerTeam(player, teams[teamIndex]);
  playerCount++;
}

// Balance by team size
function assignToSmallestTeam(player: mod.Player) {
  const team1Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team1));
  const team2Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team2));

  if (team1Count <= team2Count) {
    mod.SetPlayerTeam(player, mod.Team.Team1);
  } else {
    mod.SetPlayerTeam(player, mod.Team.Team2);
  }
}
```

### Async Operations

```typescript
// Sequential operations (one after another)
async function sequentialActions() {
  console.log("Step 1");
  await mod.Wait(2);
  console.log("Step 2");
  await mod.Wait(2);
  console.log("Step 3");
}

// Parallel operations (multiple at once)
async function parallelActions() {
  const players = modlib.ConvertArray(mod.GetPlayers());

  // Start all teleports simultaneously
  for (const player of players) {
    teleportPlayer(player);  // Don't await
  }
}

// Wait for specific condition
async function waitUntilAllPlayersReady() {
  while (true) {
    const players = modlib.ConvertArray(mod.GetPlayers());
    const allReady = players.every(p => isPlayerReady(p));

    if (allReady) break;

    await mod.Wait(0.5);
  }

  console.log("All players ready!");
}
```

## Best Practices

### 1. Use modlib Helpers

```typescript
// ❌ Bad: Manual array conversion
const playersArray = mod.GetPlayers();
const count = mod.GetArrayLength(playersArray);
for (let i = 0; i < count; i++) {
  const player = mod.GetArrayElement(playersArray, i);
  // ...
}

// ✅ Good: Use modlib.ConvertArray
const players = modlib.ConvertArray(mod.GetPlayers());
for (const player of players) {
  // ...
}
```

### 2. Cache Expensive Operations

```typescript
// ❌ Bad: Convert array every frame
async function gameLoop() {
  while (true) {
    const players = modlib.ConvertArray(mod.GetPlayers());
    updateUI(players);
    await mod.Wait(0.1);
  }
}

// ✅ Good: Cache when player count changes
let cachedPlayers: mod.Player[] = [];

export async function OnPlayerJoinGame(player: mod.Player) {
  cachedPlayers = modlib.ConvertArray(mod.GetPlayers());
}

async function gameLoop() {
  while (true) {
    updateUI(cachedPlayers);
    await mod.Wait(0.1);
  }
}
```

### 3. Always Use await with mod.Wait()

```typescript
// ❌ Bad: Busy loop (freezes game)
function badDelay() {
  for (let i = 0; i < 1000000; i++) {
    // Busy waiting
  }
}

// ✅ Good: Proper async waiting
async function goodDelay() {
  await mod.Wait(5);  // Wait 5 seconds properly
}
```

### 4. Handle Player Disconnects

```typescript
// ❌ Bad: No cleanup
export async function OnPlayerJoinGame(player: mod.Player) {
  playerData.push({ player, score: 0 });
}

// ✅ Good: Cleanup on disconnect
export async function OnPlayerJoinGame(player: mod.Player) {
  playerData.push({ player, score: 0 });
}

export async function OnPlayerLeaveGame(playerId: string) {
  playerData = playerData.filter(p => mod.GetPlayerId(p.player) !== playerId);
}
```

### 5. Check for null/undefined

```typescript
// ❌ Bad: No validation
function teleportPlayer(player: mod.Player) {
  const spawner = mod.GetSpawner(1);
  const transform = mod.GetSpawnerTransform(spawner);
  mod.Teleport(player, transform.position, 0);
}

// ✅ Good: Validate before use
function teleportPlayer(player: mod.Player) {
  const spawner = mod.GetSpawner(1);
  if (!spawner) {
    console.log("ERROR: Spawner not found!");
    return;
  }

  const transform = mod.GetSpawnerTransform(spawner);
  mod.Teleport(player, transform.position, 0);
}
```

## Debugging

### Console Logging

```typescript
// Basic logging
console.log("Game started!");
console.log("Player count:", playerData.length);

// Log with variables
const score = mod.GetPlayerScore(player);
console.log("Player score:", score);

// Log complex objects
console.log("Player data:", JSON.stringify(playerData, null, 2));
```

### Error Handling

```typescript
try {
  const spawner = mod.GetSpawner(999);  // Invalid ID
  mod.SpawnPlayerFromSpawnPoint(player, spawner);
} catch (error) {
  console.log("ERROR:", error);
  // Fallback behavior
}
```

### Step-by-Step Testing

```typescript
export async function OnGameModeStarted() {
  console.log("1. Game mode started");

  mod.SetGameTimeLimit(600);
  console.log("2. Time limit set");

  const spawner = mod.GetSpawner(1);
  console.log("3. Spawner retrieved:", spawner ? "SUCCESS" : "FAILED");

  gameLoop();
  console.log("4. Game loop started");
}
```

## IDE Setup

### VS Code Configuration

1. **Install TypeScript**: `npm install -g typescript`

2. **Create tsconfig.json**:
```json
{
  "compilerOptions": {
    "target": "ES2017",
    "module": "ESNext",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
```

3. **Reference Type Definitions**:
```typescript
/// <reference path="../../code/mod/index.d.ts" />
import * as mod from 'bf-portal-api';
```

### Autocomplete Support

With proper setup, you get:
- Function signatures
- Parameter types
- Enum values
- Return types
- Documentation tooltips

## Next Steps

- 📖 [Event Hooks Guide](/guides/event-hooks) - Deep dive into all 7 hooks
- 📖 [Object System](/guides/object-system) - Working with SDK types
- 🎓 [Your First Game Mode](/tutorials/first-game-mode) - Hands-on tutorial
- 📚 [API Reference](/api/) - Complete function documentation

---

::: tip Quick Reference
- **Import SDK**: `import * as mod from 'bf-portal-api';`
- **Import Helpers**: `import * as modlib from './modlib';`
- **Export Event Hooks**: `export async function OnGameModeStarted() {}`
- **Wait**: `await mod.Wait(seconds)`
- **Convert Arrays**: `modlib.ConvertArray(mod.GetPlayers())`
:::
