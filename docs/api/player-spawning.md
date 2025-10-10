# Player Spawning

Functions for spawning, deploying, and managing player spawn points in your game modes.

## Overview

The spawning system controls:
- When and where players spawn
- Auto-spawn vs manual deployment
- Spawn protection and delays
- Team-based spawn points
- Respawn timers

## Spawn Modes

### SetSpawnMode

```typescript
SetSpawnMode(spawnMode: SpawnModes): void
```

Configure whether players spawn automatically or manually.

**Spawn Modes:**
- `mod.SpawnModes.AutoSpawn` - Players spawn immediately
- `mod.SpawnModes.Manual` - Players must click Deploy button

**Example:**
```typescript
export async function OnGameModeStarted() {
  // Manual deployment (players choose when to spawn)
  mod.SetSpawnMode(mod.SpawnModes.Manual);
}
```

## Player Deployment

### DeployPlayer

```typescript
DeployPlayer(player: Player): void
```

Force a player to deploy immediately.

**Example:**
```typescript
// Deploy player after countdown
export async function OnPlayerJoinGame(player: mod.Player) {
  mod.SetPlayerTeam(player, mod.Team.Team1);

  await mod.Wait(3);  // 3 second delay
  mod.DeployPlayer(player);
}
```

### DeployAllPlayers

```typescript
DeployAllPlayers(): void
```

Deploy all players simultaneously.

**Example:**
```typescript
export async function OnGameModeStarted() {
  // Wait for players to join
  await mod.Wait(30);  // 30 second lobby

  // Deploy everyone at once
  mod.DeployAllPlayers();
  console.log("Match started!");
}
```

### UndeployPlayer

```typescript
UndeployPlayer(player: Player): void
```

Remove player from the battlefield (back to deployment screen).

**Example:**
```typescript
// Undeploy player for team switch
export async function OnPlayerSwitchTeam(player: mod.Player, newTeam: mod.Team) {
  mod.UndeployPlayer(player);

  await mod.Wait(2);
  mod.DeployPlayer(player);  // Redeploy on new team
}
```

### UndeployAllPlayers

```typescript
UndeployAllPlayers(): void
```

Remove all players from battlefield.

**Example:**
```typescript
// Round restart
function restartRound() {
  mod.UndeployAllPlayers();

  // Reset game state
  resetObjectives();
  resetScores();

  await mod.Wait(5);
  mod.DeployAllPlayers();
}
```

## Spawn Points

### SpawnPlayerFromSpawnPoint

```typescript
SpawnPlayerFromSpawnPoint(player: Player, spawnPointId: number): void
SpawnPlayerFromSpawnPoint(player: Player, spawnPoint: SpawnPoint): void
```

Spawn player at a specific spawn point.

**Example:**
```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Spawn by ID (from Godot Obj Id)
  mod.SpawnPlayerFromSpawnPoint(player, 1);
}

// Or use spawn point reference
const spawner = mod.GetSpawnPoint(1);
mod.SpawnPlayerFromSpawnPoint(player, spawner);
```

### GetSpawnPoint

```typescript
GetSpawnPoint(spawnPointId: number): SpawnPoint
```

Get spawn point reference by ID.

**Example:**
```typescript
// Cache spawn points on startup
let blueSpawn: mod.SpawnPoint;
let redSpawn: mod.SpawnPoint;

export async function OnGameModeStarted() {
  blueSpawn = mod.GetSpawnPoint(1);
  redSpawn = mod.GetSpawnPoint(2);

  if (!blueSpawn || !redSpawn) {
    console.log("ERROR: Missing spawn points!");
  }
}
```

### GetSpawner

```typescript
GetSpawner(spawnerId: number): Spawner
```

Get generic spawner (used for AI).

**Example:**
```typescript
const aiSpawner = mod.GetSpawner(100);
if (aiSpawner) {
  mod.SpawnAIFromAISpawner(aiSpawner);
}
```

## Deploy Control

### EnablePlayerDeploy

```typescript
EnablePlayerDeploy(player: Player, deployAllowed: boolean): void
```

Control whether a specific player can deploy.

**Example:**
```typescript
// Prevent deployment until ready
export async function OnPlayerJoinGame(player: mod.Player) {
  mod.EnablePlayerDeploy(player, false);  // Disable

  // Show team selection UI
  await showTeamSelection(player);

  mod.EnablePlayerDeploy(player, true);   // Enable
}
```

### EnableAllPlayerDeploy

```typescript
EnableAllPlayerDeploy(enablePlayerDeploy: boolean): void
```

Control deployment for all players.

**Example:**
```typescript
export async function OnGameModeStarted() {
  // Lock deployment during setup
  mod.EnableAllPlayerDeploy(false);

  // Configure game
  setupObjectives();
  setupTeams();

  await mod.Wait(5);

  // Allow deployment
  mod.EnableAllPlayerDeploy(true);
}
```

## Respawn System

### SetRedeployTime

```typescript
SetRedeployTime(player: Player, redeployTime: number): void
```

Set respawn delay for a player (0-60 seconds).

**Example:**
```typescript
export async function OnPlayerDied(player: mod.Player) {
  // Increase respawn time based on deaths
  const deaths = getPlayerDeaths(player);
  const respawnTime = Math.min(5 + (deaths * 2), 30);  // Max 30 seconds

  mod.SetRedeployTime(player, respawnTime);

  // Notify player
  mod.DisplayCustomNotificationMessage(
    mod.Message(`Respawning in ${respawnTime} seconds`),
    mod.CustomNotificationSlots.HeaderText,
    respawnTime,
    player
  );
}
```

### ForceRevive

```typescript
ForceRevive(player: Player): void
```

Instantly revive a dead player.

**Example:**
```typescript
export async function OnPlayerDied(player: mod.Player) {
  // Instant respawn for VIP
  if (isVIP(player)) {
    await mod.Wait(1);
    mod.ForceRevive(player);
    return;
  }

  // Normal respawn delay
  await mod.Wait(5);
  mod.ForceRevive(player);
}
```

## Spawn Strategies

### Team-Based Spawning

```typescript
const TEAM1_SPAWNS = [1, 2, 3];  // Obj IDs
const TEAM2_SPAWNS = [4, 5, 6];

export async function OnPlayerDeployed(player: mod.Player) {
  const team = mod.GetTeam(player);

  let spawnIds: number[];
  if (team === mod.Team.Team1) {
    spawnIds = TEAM1_SPAWNS;
  } else if (team === mod.Team.Team2) {
    spawnIds = TEAM2_SPAWNS;
  } else {
    spawnIds = [7];  // Neutral spawn
  }

  // Random spawn from team's points
  const randomId = spawnIds[Math.floor(Math.random() * spawnIds.length)];
  mod.SpawnPlayerFromSpawnPoint(player, randomId);
}
```

### Squad Spawning

```typescript
function spawnWithSquad(player: mod.Player) {
  const squad = mod.GetSquad(player);
  const squadPlayers = modlib.ConvertArray(mod.AllPlayers()).filter(p =>
    mod.GetSquad(p) === squad &&
    mod.GetSoldierState(p, mod.SoldierStateBool.IsAlive)
  );

  if (squadPlayers.length > 0) {
    // Spawn near squad member
    const squadLeader = squadPlayers[0];
    const leaderPos = mod.GetSoldierState(squadLeader, mod.SoldierStateVector.GetPosition);

    // Offset position slightly
    const spawnPos = mod.Add(leaderPos, mod.CreateVector(5, 0, 0));
    mod.Teleport(player, spawnPos, 0);
  } else {
    // Use normal spawn point
    mod.SpawnPlayerFromSpawnPoint(player, 1);
  }
}
```

### Wave Spawning

```typescript
let waveNumber = 0;
let waveQueue: mod.Player[] = [];

async function waveSpawnSystem() {
  while (gameRunning) {
    // Collect dead players
    const deadPlayers = modlib.ConvertArray(mod.AllPlayers()).filter(p =>
      !mod.GetSoldierState(p, mod.SoldierStateBool.IsAlive)
    );

    waveQueue.push(...deadPlayers);

    // Wait for wave interval
    await mod.Wait(30);  // 30 second waves

    // Spawn entire wave
    waveNumber++;
    console.log(`Spawning wave ${waveNumber} with ${waveQueue.length} players`);

    for (const player of waveQueue) {
      mod.ForceRevive(player);
      const spawner = getRandomSpawner();
      mod.SpawnPlayerFromSpawnPoint(player, spawner);
    }

    waveQueue = [];
  }
}
```

### Progressive Spawn Delay

```typescript
interface PlayerSpawnData {
  player: mod.Player;
  deathCount: number;
}

let spawnData: PlayerSpawnData[] = [];

export async function OnPlayerDied(player: mod.Player) {
  let data = spawnData.find(d => d.player === player);

  if (!data) {
    data = { player, deathCount: 0 };
    spawnData.push(data);
  }

  data.deathCount++;

  // Progressive delay: 5s base + 2s per death (max 30s)
  const delay = Math.min(5 + (data.deathCount * 2), 30);
  mod.SetRedeployTime(player, delay);

  console.log(`${mod.GetPlayerName(player)} respawn delay: ${delay}s`);
}
```

## Spawn Protection

### Invulnerability Period

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Spawn player
  mod.SpawnPlayerFromSpawnPoint(player, 1);

  // Make invulnerable for 3 seconds
  mod.SetPlayerIncomingDamageMultiplier(player, 0);  // No damage

  // Visual indicator
  mod.DisplayCustomNotificationMessage(
    mod.Message("Spawn Protection Active"),
    mod.CustomNotificationSlots.MessageText2,
    3,
    player
  );

  await mod.Wait(3);

  // Remove protection
  mod.SetPlayerIncomingDamageMultiplier(player, 1);  // Normal damage
}
```

### Safe Spawn Detection

```typescript
function isSafeSpawn(spawnPoint: mod.SpawnPoint): boolean {
  const transform = mod.GetSpawnerTransform(spawnPoint);
  const spawnPos = transform.position;

  // Check for enemies near spawn
  const players = modlib.ConvertArray(mod.AllPlayers());
  const enemiesNearby = players.filter(p => {
    const team = mod.GetTeam(p);
    if (team === mod.Team.Team1) return false;  // Same team

    const playerPos = mod.GetSoldierState(p, mod.SoldierStateVector.GetPosition);
    const distance = mod.DistanceBetween(spawnPos, playerPos);

    return distance < 20;  // Within 20 meters
  });

  return enemiesNearby.length === 0;
}

// Find safe spawn point
function getSafeSpawnPoint(team: mod.Team): mod.SpawnPoint | null {
  const spawnIds = team === mod.Team.Team1 ? TEAM1_SPAWNS : TEAM2_SPAWNS;

  for (const id of spawnIds) {
    const spawn = mod.GetSpawnPoint(id);
    if (spawn && isSafeSpawn(spawn)) {
      return spawn;
    }
  }

  return null;  // No safe spawns
}
```

## Spawn Validation

### Check Spawn Exists

```typescript
function validateSpawnPoints() {
  const requiredSpawns = [1, 2, 3, 4];
  const missingSpawns: number[] = [];

  for (const id of requiredSpawns) {
    const spawn = mod.GetSpawnPoint(id);
    if (!spawn) {
      missingSpawns.push(id);
    }
  }

  if (missingSpawns.length > 0) {
    console.log("ERROR: Missing spawn points:", missingSpawns);
    return false;
  }

  return true;
}

export async function OnGameModeStarted() {
  if (!validateSpawnPoints()) {
    console.log("CRITICAL: Cannot start game - missing spawn points!");
    return;
  }

  // Continue setup...
}
```

### Handle Missing Spawns

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  const spawnId = getSpawnIdForPlayer(player);
  const spawner = mod.GetSpawnPoint(spawnId);

  if (!spawner) {
    console.log(`WARNING: Spawn point ${spawnId} not found!`);

    // Fallback to default spawn
    const defaultSpawn = mod.GetSpawnPoint(1);
    if (defaultSpawn) {
      mod.SpawnPlayerFromSpawnPoint(player, defaultSpawn);
    } else {
      // Emergency: teleport to origin
      mod.Teleport(player, mod.CreateVector(0, 0, 100), 0);
    }
    return;
  }

  mod.SpawnPlayerFromSpawnPoint(player, spawner);
}
```

## Common Patterns

### Spawn Selection Menu

```typescript
function showSpawnSelection(player: mod.Player) {
  const container = mod.AddUIContainer(
    "spawnSelect",
    mod.CreateVector(-200, -150, 0),
    mod.CreateVector(400, 300, 0),
    mod.UIAnchor.Center,
    null,
    true,
    5,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.9,
    mod.UIBgFill.Stretch,
    player
  );

  // Base spawn button
  mod.AddUIButton(
    "baseSpawn",
    mod.CreateVector(10, 10, 0),
    mod.CreateVector(180, 50, 0),
    mod.UIAnchor.TopLeft,
    container,
    true,
    2,
    // ... button colors
  );

  // Squad spawn button
  mod.AddUIButton(
    "squadSpawn",
    mod.CreateVector(210, 10, 0),
    mod.CreateVector(180, 50, 0),
    mod.UIAnchor.TopLeft,
    container,
    true,
    2,
    // ... button colors
  );
}
```

### Round-Based Spawning

```typescript
let currentRound = 0;
let roundActive = false;

export async function OnPlayerDied(player: mod.Player) {
  if (!roundActive) {
    // No respawn during round intermission
    return;
  }

  // No respawn during active round
  mod.DisplayCustomNotificationMessage(
    mod.Message("Eliminated - Wait for next round"),
    mod.CustomNotificationSlots.HeaderText,
    5,
    player
  );

  checkRoundEnd();
}

async function startNewRound() {
  currentRound++;
  roundActive = false;

  // Respawn all dead players
  const players = modlib.ConvertArray(mod.AllPlayers());
  for (const player of players) {
    if (!mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive)) {
      mod.ForceRevive(player);
    }
  }

  await mod.Wait(5);  // Round start delay
  roundActive = true;
}
```

## Best Practices

### 1. Always Validate Spawn Points

```typescript
const spawner = mod.GetSpawnPoint(1);
if (!spawner) {
  console.log("ERROR: Spawn point not found!");
  // Use fallback
  return;
}
```

### 2. Set Spawn Mode Early

```typescript
export async function OnGameModeStarted() {
  // Set spawn mode FIRST
  mod.SetSpawnMode(mod.SpawnModes.Manual);

  // Then configure other settings
  setupTeams();
}
```

### 3. Handle Edge Cases

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  if (!mod.IsPlayerValid(player)) {
    console.log("Invalid player in deploy!");
    return;
  }

  const team = mod.GetTeam(player);
  if (!team) {
    // Assign default team
    mod.SetTeam(player, mod.Team.Team1);
  }

  // Continue with spawn...
}
```

### 4. Provide Spawn Feedback

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Spawn player
  mod.SpawnPlayerFromSpawnPoint(player, 1);

  // Show spawn message
  mod.DisplayCustomNotificationMessage(
    mod.Message("Deployed at Base"),
    mod.CustomNotificationSlots.MessageText1,
    3,
    player
  );

  // Play spawn sound
  const pos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
  mod.PlaySound(mod.GetSFX(123), 1.0, pos, 10, player);
}
```

## Next Steps

- 📖 [Player Control](/api/player-control) - Managing spawned players
- 📖 [Player State](/api/player-state) - Checking player status
- 📖 [Player Equipment](/api/player-equipment) - Loadouts on spawn
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip Spawning Summary
- **Two spawn modes** - Auto or Manual deployment
- **Spawn point management** - Use GetSpawnPoint() with Obj IDs
- **Respawn control** - Set delays with SetRedeployTime()
- **Always validate** - Check spawn points exist
- **Team-based spawning** - Separate spawns per team
:::