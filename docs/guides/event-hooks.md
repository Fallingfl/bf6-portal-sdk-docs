# Event Hooks

Event hooks are callback functions that the SDK automatically calls when specific game events occur. Understanding and properly implementing these hooks is essential for creating custom game modes.

## Overview

The BF6 Portal SDK provides **7 event hooks** that cover all major game events:

| Hook | Trigger | Required |
|------|---------|----------|
| `OnGameModeStarted` | Game mode initializes | ✅ Yes |
| `OnPlayerJoinGame` | Player joins lobby | Recommended |
| `OnPlayerLeaveGame` | Player disconnects | Recommended |
| `OnPlayerDeployed` | Player spawns into map | Recommended |
| `OnPlayerDied` | Player dies | Recommended |
| `OnPlayerEarnedKill` | Player gets a kill | Optional |
| `OnPlayerSwitchTeam` | Player changes teams | Optional |

::: tip Required vs Optional
Only `OnGameModeStarted` is truly required. However, most game modes need at least the first 5 hooks to function properly.
:::

## Hook Execution Flow

Understanding when hooks are called:

```
Game Launch
    ↓
[OnGameModeStarted] ← Called ONCE
    ↓
Player Connects
    ↓
[OnPlayerJoinGame] ← Called for EACH player
    ↓
Player Clicks Deploy
    ↓
[OnPlayerDeployed] ← Player spawns
    ↓
Gameplay...
    ↓
Player Kills Enemy
    ↓
[OnPlayerEarnedKill] ← Killer's perspective
[OnPlayerDied] ← Victim's perspective
    ↓
Player Disconnects
    ↓
[OnPlayerLeaveGame] ← Cleanup
```

## OnGameModeStarted

### When Called

Once when the experience starts, before any players join.

### Purpose

Initialize your game mode:
- Configure game settings (time limits, player counts)
- Set up teams and their properties
- Initialize global variables
- Start background systems (game loops, timers)
- Load map-specific data

### Function Signature

```typescript
export async function OnGameModeStarted(): Promise<void>
```

### Example: Basic Setup

```typescript
export async function OnGameModeStarted() {
  console.log("=== GAME MODE STARTED ===");

  // Configure game settings
  mod.SetGameTimeLimit(900);  // 15 minutes
  mod.SetMaxPlayerCount(32);  // 32 players max

  // Set up teams
  mod.SetTeamName(mod.Team.Team1, "Attackers");
  mod.SetTeamName(mod.Team.Team2, "Defenders");
  mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);
  mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);

  // Initialize systems
  gameRunning = true;
  gameLoop();  // Start background loop

  console.log("Game mode ready for players!");
}
```

### Example: Lobby System

```typescript
export async function OnGameModeStarted() {
  // Wait for players to join
  mod.DisablePlayerJoin();  // Close lobby temporarily

  console.log("Waiting for players...");
  await mod.Wait(30);  // 30 second lobby

  // Countdown
  announceToAll("Game starting in 10 seconds!");
  await mod.Wait(10);

  // Start game
  mod.EnablePlayerJoin();
  gameStarted = true;

  console.log("Game started!");
}
```

### Example: Map-Specific Setup

```typescript
export async function OnGameModeStarted() {
  const currentMap = mod.GetCurrentMap();

  if (currentMap === mod.Maps.MP_Dumbo) {
    // Manhattan Bridge specific setup
    setupBridgeCheckpoints();
  } else if (currentMap === mod.Maps.MP_Abbasid) {
    // Cairo specific setup
    setupDesertObjectives();
  }

  console.log("Map setup complete:", currentMap);
}
```

### Common Tasks

- ✅ Set time limits: `mod.SetGameTimeLimit(seconds)`
- ✅ Configure player counts: `mod.SetMaxPlayerCount(count)`
- ✅ Set up teams: `mod.SetTeamName()`, `mod.SetTeamColor()`
- ✅ Initialize global variables
- ✅ Start background loops
- ✅ Load gameplay objects: `mod.GetSpawner()`, `mod.GetAreaTrigger()`
- ✅ Configure weather/time of day (if supported)

::: warning Don't Await Background Loops
When starting game loops, DON'T use `await` or the function will never complete:

```typescript
// ❌ Bad - blocks forever
export async function OnGameModeStarted() {
  await gameLoop();  // Never returns!
}

// ✅ Good - runs in background
export async function OnGameModeStarted() {
  gameLoop();  // Starts independently
}
```
:::

## OnPlayerJoinGame

### When Called

When a player joins the lobby (before they spawn/deploy).

### Purpose

Set up new players:
- Assign to team
- Create player data tracking
- Show welcome messages
- Configure initial state

### Function Signature

```typescript
export async function OnPlayerJoinGame(player: mod.Player): Promise<void>
```

### Parameters

- `player` - The player who just joined

### Example: Basic Welcome

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  const playerName = mod.GetPlayerName(player);
  console.log("Player joined:", playerName);

  // Assign to a team
  mod.SetPlayerTeam(player, mod.Team.Team1);

  // Show welcome message
  modlib.DisplayCustomNotificationMessage(
    "Welcome to the server!",
    mod.NotificationSlot.HeaderText,
    5,
    player
  );
}
```

### Example: Team Assignment

```typescript
let playerCount = 0;

export async function OnPlayerJoinGame(player: mod.Player) {
  // Round-robin team assignment
  const teams = [mod.Team.Team1, mod.Team.Team2];
  const teamIndex = playerCount % teams.length;
  mod.SetPlayerTeam(player, teams[teamIndex]);

  playerCount++;

  console.log(`Player ${playerCount} assigned to team ${teamIndex + 1}`);
}
```

### Example: Player Data Tracking

```typescript
interface PlayerData {
  player: mod.Player;
  kills: number;
  deaths: number;
  score: number;
  joinTime: number;
}

let playerData: PlayerData[] = [];

export async function OnPlayerJoinGame(player: mod.Player) {
  // Create data entry
  const data: PlayerData = {
    player: player,
    kills: 0,
    deaths: 0,
    score: 0,
    joinTime: mod.GetGameTime()
  };

  playerData.push(data);

  console.log("Player data created. Total players:", playerData.length);
}
```

### Example: Show Rules

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  // Assign team
  mod.SetPlayerTeam(player, mod.Team.Team1);

  // Show rules sequentially
  modlib.DisplayCustomNotificationMessage(
    "OBJECTIVE: Capture all control points",
    mod.NotificationSlot.HeaderText,
    5,
    player
  );

  await mod.Wait(3);

  modlib.DisplayCustomNotificationMessage(
    "First team to 1000 points wins!",
    mod.NotificationSlot.MessageText1,
    5,
    player
  );

  await mod.Wait(3);

  modlib.DisplayCustomNotificationMessage(
    "Press DEPLOY when ready",
    mod.NotificationSlot.MessageText2,
    3,
    player
  );
}
```

### Common Tasks

- ✅ Assign player to team: `mod.SetPlayerTeam(player, team)`
- ✅ Create player data tracking
- ✅ Show welcome/rules messages
- ✅ Check for minimum players to start game
- ✅ Balance teams

## OnPlayerLeaveGame

### When Called

When a player disconnects or quits the game.

### Purpose

Clean up player data and handle team rebalancing.

### Function Signature

```typescript
export async function OnPlayerLeaveGame(playerId: string): Promise<void>
```

### Parameters

- `playerId` - **String ID** of the player (NOT a `mod.Player` object!)

::: danger Important
You receive a `string` ID, not a `mod.Player` object. The player has already left and no longer exists!
:::

### Example: Basic Cleanup

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  console.log("Player left:", playerId);

  // Remove from tracking
  playerData = playerData.filter(p => mod.GetPlayerId(p.player) !== playerId);

  console.log("Players remaining:", playerData.length);
}
```

### Example: Team Rebalancing

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  // Remove from data
  playerData = playerData.filter(p => mod.GetPlayerId(p.player) !== playerId);

  // Check team balance
  const team1Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team1));
  const team2Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team2));

  console.log(`Team balance: ${team1Count} vs ${team2Count}`);

  // Auto-balance if difference is > 2
  if (Math.abs(team1Count - team2Count) > 2) {
    balanceTeams();
  }
}
```

### Example: End Game if Empty

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  playerData = playerData.filter(p => mod.GetPlayerId(p.player) !== playerId);

  // End game if no players left
  if (playerData.length === 0) {
    console.log("No players remaining. Ending game...");
    gameRunning = false;
    mod.EndGame();
  }
}
```

### Common Tasks

- ✅ Remove player from tracking arrays
- ✅ Update team counts
- ✅ Rebalance teams if needed
- ✅ End game if minimum players not met
- ✅ Save player statistics (if using external storage)

## OnPlayerDeployed

### When Called

When a player clicks the Deploy button and spawns into the map.

### Purpose

Spawn the player at the correct location with proper equipment and state.

### Function Signature

```typescript
export async function OnPlayerDeployed(player: mod.Player): Promise<void>
```

### Parameters

- `player` - The player who is deploying

### Example: Basic Spawn

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  console.log("Player deployed:", mod.GetPlayerName(player));

  // Get spawn point
  const spawner = mod.GetSpawner(1);

  // Spawn player
  mod.SpawnPlayerFromSpawnPoint(player, spawner);

  // Set health
  mod.SetPlayerMaxHealth(player, 100);
}
```

### Example: Team-Based Spawning

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  const playerTeam = mod.GetPlayerTeam(player);

  // Spawn at team-specific location
  if (playerTeam === mod.Team.Team1) {
    const blueSpawner = mod.GetSpawner(1);
    mod.SpawnPlayerFromSpawnPoint(player, blueSpawner);
  } else if (playerTeam === mod.Team.Team2) {
    const redSpawner = mod.GetSpawner(2);
    mod.SpawnPlayerFromSpawnPoint(player, redSpawner);
  }

  console.log("Spawned at team spawn point");
}
```

### Example: Custom Loadout

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Spawn player
  const spawner = mod.GetSpawner(1);
  mod.SpawnPlayerFromSpawnPoint(player, spawner);

  // Remove default equipment
  const currentWeapons = mod.GetPlayerEquipment(player);
  const weaponCount = mod.GetArrayLength(currentWeapons);
  for (let i = 0; i < weaponCount; i++) {
    const weapon = mod.GetArrayElement(currentWeapons, i);
    mod.RemoveEquipment(player, weapon);
  }

  // Give custom loadout
  mod.AddEquipment(player, mod.Weapons.AK24);
  mod.AddEquipment(player, mod.Gadgets.Medkit);
  mod.SetPlayerAmmo(player, mod.Weapons.AK24, 30, 120);

  console.log("Custom loadout applied");
}
```

### Example: Player Modifiers

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Spawn player
  const spawner = mod.GetSpawner(1);
  mod.SpawnPlayerFromSpawnPoint(player, spawner);

  // Apply modifiers based on game mode
  mod.SetMovementSpeedScale(player, 1.5);  // 50% faster
  mod.SetJumpHeightScale(player, 1.3);     // 30% higher jumps
  mod.SetPlayerMaxHealth(player, 150);     // 150 HP instead of 100

  // Show HUD
  showPlayerHUD(player);

  console.log("Player modifiers applied");
}
```

### Common Tasks

- ✅ Spawn at spawn point: `mod.SpawnPlayerFromSpawnPoint()`
- ✅ Set health: `mod.SetPlayerMaxHealth()`
- ✅ Give equipment: `mod.AddEquipment()`
- ✅ Set ammo: `mod.SetPlayerAmmo()`
- ✅ Apply movement modifiers
- ✅ Show UI elements
- ✅ Play spawn effects/sounds

## OnPlayerDied

### When Called

When a player dies (health reaches 0).

### Purpose

Handle death, respawn logic, and update statistics.

### Function Signature

```typescript
export async function OnPlayerDied(player: mod.Player): Promise<void>
```

### Parameters

- `player` - The player who died

### Example: Auto-Respawn

```typescript
export async function OnPlayerDied(player: mod.Player) {
  console.log("Player died:", mod.GetPlayerName(player));

  // Update stats
  const data = findPlayerData(player);
  if (data) {
    data.deaths++;
  }

  // Show death message
  modlib.DisplayCustomNotificationMessage(
    "You died! Respawning in 5 seconds...",
    mod.NotificationSlot.MessageText1,
    5,
    player
  );

  // Wait before respawn
  await mod.Wait(5);

  // Respawn
  mod.Revive(player);

  console.log("Player respawned");
}
```

### Example: Limited Respawns

```typescript
interface PlayerData {
  player: mod.Player;
  respawnsRemaining: number;
}

let playerData: PlayerData[] = [];

export async function OnPlayerDied(player: mod.Player) {
  const data = findPlayerData(player);

  if (data && data.respawnsRemaining > 0) {
    data.respawnsRemaining--;

    modlib.DisplayCustomNotificationMessage(
      `Respawning... (${data.respawnsRemaining} lives left)`,
      mod.NotificationSlot.HeaderText,
      5,
      player
    );

    await mod.Wait(5);
    mod.Revive(player);
  } else {
    // Out of respawns - spectate
    modlib.DisplayCustomNotificationMessage(
      "OUT OF RESPAWNS - You are now spectating",
      mod.NotificationSlot.HeaderText,
      10,
      player
    );
  }
}
```

### Example: Round-Based (No Respawn)

```typescript
export async function OnPlayerDied(player: mod.Player) {
  console.log("Player eliminated:", mod.GetPlayerName(player));

  // Don't respawn during round
  modlib.DisplayCustomNotificationMessage(
    "You are out! Spectating until next round...",
    mod.NotificationSlot.HeaderText,
    5,
    player
  );

  // Check if round should end
  checkRoundEnd();
}
```

### Common Tasks

- ✅ Update death statistics
- ✅ Wait before respawn: `await mod.Wait()`
- ✅ Respawn player: `mod.Revive()`
- ✅ Show death messages
- ✅ Check victory conditions
- ✅ Handle limited lives/respawns
- ✅ Apply respawn penalties (lose points, etc.)

## OnPlayerEarnedKill

### When Called

When a player kills another player.

### Purpose

Award points, update kill statistics, show kill feed.

### Function Signature

```typescript
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
): Promise<void>
```

### Parameters

- `killer` - Player who got the kill
- `victim` - Player who was killed
- `deathType` - How they died (enum)
- `weapon` - Weapon used (enum)

### Example: Basic Scoring

```typescript
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  console.log(
    "Kill:",
    mod.GetPlayerName(killer),
    "→",
    mod.GetPlayerName(victim)
  );

  // Award points
  const currentScore = mod.GetPlayerScore(killer);
  mod.SetPlayerScore(killer, currentScore + 100);

  // Show notification
  modlib.DisplayCustomNotificationMessage(
    "+100 points!",
    mod.NotificationSlot.MessageText2,
    2,
    killer
  );

  // Check for victory
  if (currentScore + 100 >= 3000) {
    mod.SetWinningPlayer(killer);
    mod.EndGame();
  }
}
```

### Example: Weapon-Based Scoring

```typescript
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  // Different points for different weapons
  let points = 100;  // Default

  if (weapon === mod.Weapons.Knife) {
    points = 500;  // Melee kills worth more
  } else if (weapon === mod.Weapons.SniperRifle_SRR61) {
    points = 150;  // Sniper kills bonus
  }

  // Award points
  const currentScore = mod.GetPlayerScore(killer);
  mod.SetPlayerScore(killer, currentScore + points);

  modlib.DisplayCustomNotificationMessage(
    `+${points} | ${mod.GetWeaponName(weapon)}`,
    mod.NotificationSlot.MessageText2,
    2,
    killer
  );
}
```

### Example: Kill Streaks

```typescript
interface PlayerData {
  player: mod.Player;
  killStreak: number;
}

let playerData: PlayerData[] = [];

export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  // Update killer streak
  const killerData = findPlayerData(killer);
  if (killerData) {
    killerData.killStreak++;

    // Reward at milestones
    if (killerData.killStreak === 5) {
      modlib.DisplayCustomNotificationMessage(
        "KILLING SPREE! +500 bonus",
        mod.NotificationSlot.HeaderText,
        3,
        killer
      );
      mod.SetPlayerScore(killer, mod.GetPlayerScore(killer) + 500);
    }
  }

  // Reset victim streak
  const victimData = findPlayerData(victim);
  if (victimData) {
    victimData.killStreak = 0;
  }
}
```

### Common Tasks

- ✅ Award points: `mod.SetPlayerScore()`
- ✅ Update kill statistics
- ✅ Show kill notifications
- ✅ Check victory conditions
- ✅ Track kill streaks
- ✅ Award weapon-specific bonuses
- ✅ Update team scores

## OnPlayerSwitchTeam

### When Called

When a player manually switches teams (using in-game menu).

### Purpose

Handle team changes, reset player state, rebalance.

### Function Signature

```typescript
export async function OnPlayerSwitchTeam(
  player: mod.Player,
  newTeam: mod.Team
): Promise<void>
```

### Parameters

- `player` - Player switching teams
- `newTeam` - Team they switched to

### Example: Basic Team Switch

```typescript
export async function OnPlayerSwitchTeam(
  player: mod.Player,
  newTeam: mod.Team
) {
  console.log(
    mod.GetPlayerName(player),
    "switched to",
    mod.GetTeamName(newTeam)
  );

  // Show message
  modlib.DisplayCustomNotificationMessage(
    `Switched to ${mod.GetTeamName(newTeam)}`,
    mod.NotificationSlot.HeaderText,
    3,
    player
  );

  // Kill and respawn at new team spawn
  mod.Kill(player);
  await mod.Wait(2);
  mod.Revive(player);
}
```

### Example: Reset Progress

```typescript
export async function OnPlayerSwitchTeam(
  player: mod.Player,
  newTeam: mod.Team
) {
  // Reset player stats
  const data = findPlayerData(player);
  if (data) {
    data.kills = 0;
    data.deaths = 0;
    data.score = 0;
  }

  mod.SetPlayerScore(player, 0);

  // Respawn at new team
  mod.Kill(player);
  await mod.Wait(2);
  mod.Revive(player);

  console.log("Player progress reset after team switch");
}
```

### Example: Prevent Team Switching

```typescript
export async function OnPlayerSwitchTeam(
  player: mod.Player,
  newTeam: mod.Team
) {
  // Switch back to original team
  const originalTeam = mod.Team.Team1;  // Determine original team
  mod.SetPlayerTeam(player, originalTeam);

  // Show message
  modlib.DisplayCustomNotificationMessage(
    "Team switching is disabled!",
    mod.NotificationSlot.HeaderText,
    3,
    player
  );

  console.log("Prevented team switch");
}
```

### Common Tasks

- ✅ Reset player statistics
- ✅ Kill and respawn player
- ✅ Update team balance
- ✅ Show team change message
- ✅ Prevent switching (if game mode requires)

## Best Practices

### 1. Always Log Events

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  console.log("[JOIN]", mod.GetPlayerName(player), "joined the game");
  // ... rest of logic
}

export async function OnPlayerDied(player: mod.Player) {
  console.log("[DEATH]", mod.GetPlayerName(player), "died");
  // ... rest of logic
}
```

### 2. Handle Edge Cases

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  const spawner = mod.GetSpawner(1);

  // Check if spawner exists
  if (!spawner) {
    console.log("ERROR: Spawner not found!");
    return;
  }

  mod.SpawnPlayerFromSpawnPoint(player, spawner);
}
```

### 3. Keep Hooks Fast

```typescript
// ❌ Bad - long operation in hook
export async function OnPlayerJoinGame(player: mod.Player) {
  await mod.Wait(30);  // Don't make players wait!
  setupPlayer(player);
}

// ✅ Good - offload to separate function
export async function OnPlayerJoinGame(player: mod.Player) {
  setupPlayer(player);  // Returns immediately
  delayedSetup(player);  // Runs independently
}

async function delayedSetup(player: mod.Player) {
  await mod.Wait(5);
  // Additional setup
}
```

### 4. Clean Up Properly

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  // Remove all traces of player
  playerData = playerData.filter(p => mod.GetPlayerId(p.player) !== playerId);
  activeUI = activeUI.filter(ui => mod.GetPlayerId(ui.player) !== playerId);
  pendingActions = pendingActions.filter(a => a.playerId !== playerId);

  console.log("Player fully cleaned up");
}
```

## Next Steps

- 📖 [TypeScript Scripting](/guides/typescript-scripting) - Learn TypeScript patterns
- 📖 [Object System](/guides/object-system) - Working with SDK types
- 🎓 [Your First Game Mode](/tutorials/first-game-mode) - Hands-on tutorial
- 📚 [Examples](/examples/) - Study complete implementations

---

::: tip Event Hook Summary
1. `OnGameModeStarted` - Initialize game (REQUIRED)
2. `OnPlayerJoinGame` - Setup new players
3. `OnPlayerLeaveGame` - Clean up disconnected players
4. `OnPlayerDeployed` - Spawn players correctly
5. `OnPlayerDied` - Handle respawns
6. `OnPlayerEarnedKill` - Award kills (optional)
7. `OnPlayerSwitchTeam` - Handle team changes (optional)
:::
