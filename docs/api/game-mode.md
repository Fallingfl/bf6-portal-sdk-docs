# Game Mode API Reference

Complete reference for game mode lifecycle, player deployment, and match control functions in the BF6 Portal SDK.

## Overview

The Game Mode API provides control over:
- **Match lifecycle** - Start, pause, end game modes
- **Player deployment** - Control when and how players spawn
- **Join control** - Enable/disable player joining
- **Time management** - Time limits, pausing, and timers
- **Event hooks** - React to game mode events

---

## Event Hooks

Seven event hooks are available to respond to game mode events:

### OnGameModeStarted

Called once when the game mode initializes:

```typescript
export async function OnGameModeStarted() {
  // Initialize game mode
  console.log("Game mode started!");

  // Setup initial state
  initializeScoreboard();
  setupGameRules();

  // Start countdown
  await startCountdown(3);

  // Deploy players
  mod.DeployAllPlayers();
}
```

**Common Uses:**
- Initialize game state
- Configure rules and settings
- Start countdown timers
- Deploy all players

---

### OnPlayerJoinGame

Called when a player joins the match:

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  const playerName = mod.GetPlayerName(player);
  console.log(`${playerName} joined the game`);

  // Assign to team
  assignPlayerToTeam(player);

  // Initialize player score
  mod.SetGameModeScore(player, 0);

  // Welcome message
  mod.DisplayCustomNotificationMessage(
    mod.Message(`Welcome, ${playerName}!`),
    mod.CustomNotificationSlots.HeaderText,
    3,
    player
  );

  // Deploy player if game is in progress
  if (gameInProgress) {
    await mod.Wait(5);  // 5 second delay
    mod.SpawnPlayerFromSpawnPoint(player, getSpawnPoint());
  }
}
```

**Parameters:**
- `player` - The player who joined

**Common Uses:**
- Team assignment
- Initialize player score/stats
- Show welcome message
- Deploy player if game is in progress

---

### OnPlayerLeaveGame

Called when a player disconnects:

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  console.log(`Player ${playerId} left the game`);

  // Clean up player data
  playerStats.delete(playerId);

  // Rebalance teams if needed
  balanceTeams();

  // Check if match should end (not enough players)
  const players = modlib.ConvertArray(mod.AllPlayers());
  if (players.length < 2) {
    console.log("Not enough players, ending match");
    gameInProgress = false;
  }
}
```

**Parameters:**
- `playerId` - String ID of the player who left (NOT a Player object)

::: warning Player Already Gone
The player has already disconnected when this hook is called, so you cannot perform actions on their `Player` object. Use the `playerId` string to clean up data structures.
:::

**Common Uses:**
- Clean up player-specific data
- Rebalance teams
- Check minimum player count
- Update scoreboards

---

### OnPlayerDeployed

Called when a player spawns/deploys:

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  console.log(`${mod.GetPlayerName(player)} deployed`);

  // Give initial loadout
  givePlayerLoadout(player);

  // Apply spawn protection
  applySpawnProtection(player);

  // Show objective
  showObjectiveToPlayer(player);
}
```

**Parameters:**
- `player` - The player who deployed

**Common Uses:**
- Apply spawn protection
- Give custom loadouts
- Show objectives
- Start player-specific loops

---

### OnPlayerDied

Called when a player dies:

```typescript
export async function OnPlayerDied(player: mod.Player) {
  const playerName = mod.GetPlayerName(player);
  console.log(`${playerName} died`);

  // Update stats
  updatePlayerDeaths(player);

  // Clear UI
  mod.ClearAllCustomNotificationMessages(player);

  // Respawn after delay
  await mod.Wait(5);
  if (mod.GetSoldierState(player, mod.SoldierStateBool.IsDead)) {
    mod.ForceRevive(player);
  }
}
```

**Parameters:**
- `player` - The player who died

**Common Uses:**
- Update death statistics
- Implement respawn delay
- Clear player UI
- Check round-end conditions

---

### OnPlayerEarnedKill

Called when a player kills another player:

```typescript
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  const killerName = mod.GetPlayerName(killer);
  const victimName = mod.GetPlayerName(victim);

  console.log(`${killerName} killed ${victimName} with ${weapon}`);

  // Award points
  const score = mod.GetGameModeScore(killer);
  mod.SetGameModeScore(killer, score + 100);

  // Notify players
  mod.DisplayCustomNotificationMessage(
    mod.Message(`You eliminated ${victimName}`),
    mod.CustomNotificationSlots.MessageText1,
    2,
    killer
  );

  // Check victory
  if (mod.GetGameModeScore(killer) >= 10) {
    mod.EndGameMode(killer);
  }
}
```

**Parameters:**
- `killer` - Player who got the kill
- `victim` - Player who died
- `deathType` - Type of death (headshot, melee, etc.)
- `weapon` - Weapon used for the kill

**Common Uses:**
- Award kill points
- Update kill statistics
- Show kill feed
- Check victory conditions

---

### OnPlayerSwitchTeam

Called when a player changes teams:

```typescript
export async function OnPlayerSwitchTeam(player: mod.Player, team: mod.Team) {
  const playerName = mod.GetPlayerName(player);
  console.log(`${playerName} switched to team ${team}`);

  // Undeploy player
  mod.UndeployPlayer(player);

  // Notify player
  mod.DisplayCustomNotificationMessage(
    mod.Message(`You switched to ${getTeamName(team)}`),
    mod.CustomNotificationSlots.HeaderText,
    3,
    player
  );

  // Redeploy after delay
  await mod.Wait(3);
  mod.SpawnPlayerFromSpawnPoint(player, getTeamSpawnPoint(team));
}
```

**Parameters:**
- `player` - The player who switched
- `team` - The team they switched to

**Common Uses:**
- Undeploy/redeploy player
- Update team rosters
- Show team switch notification
- Rebalance teams if needed

---

## Player Deployment

### DeployAllPlayers

Deploy all players simultaneously:

```typescript
mod.DeployAllPlayers(): void
```

**Example - Match Start:**
```typescript
export async function OnGameModeStarted() {
  await showCountdown(3);
  mod.DeployAllPlayers();  // Everyone spawns at once
}
```

---

### UndeployAllPlayers

Remove all players from the game field:

```typescript
mod.UndeployAllPlayers(): void
```

**Example - Round End:**
```typescript
async function endRound() {
  mod.UndeployAllPlayers();
  await mod.Wait(5);  // Show scoreboard
  startNextRound();
}
```

---

### UndeployPlayer

Remove a specific player from the game field:

```typescript
mod.UndeployPlayer(player: Player): void
```

**Example - Penalty:**
```typescript
function penalizePlayer(player: mod.Player) {
  mod.UndeployPlayer(player);
  mod.DisplayCustomNotificationMessage(
    mod.Message("Team kill penalty - respawn in 10s"),
    mod.CustomNotificationSlots.HeaderText,
    10,
    player
  );
}
```

---

### EnablePlayerDeploy

Control whether a specific player can deploy:

```typescript
mod.EnablePlayerDeploy(player: Player, deployAllowed: boolean): void
```

**Example - Spectator Mode:**
```typescript
function setPlayerAsSpectator(player: mod.Player) {
  mod.UndeployPlayer(player);
  mod.EnablePlayerDeploy(player, false);  // Can't respawn
}

function removeSpectatorMode(player: mod.Player) {
  mod.EnablePlayerDeploy(player, true);
  mod.SpawnPlayerFromSpawnPoint(player, getSpawnPoint());
}
```

---

### EnableAllPlayerDeploy

Control whether any players can deploy:

```typescript
mod.EnableAllPlayerDeploy(enablePlayerDeploy: boolean): void
```

**Example - Freeze Period:**
```typescript
async function buyPhase() {
  mod.UndeployAllPlayers();
  mod.EnableAllPlayerDeploy(false);  // No one can spawn

  await mod.Wait(30);  // 30 second buy phase

  mod.EnableAllPlayerDeploy(true);
  mod.DeployAllPlayers();
}
```

---

### SetRedeployTime

Set respawn delay for a player:

```typescript
mod.SetRedeployTime(player: Player, redeployTime: number): void
```

**Example - Dynamic Respawn Timer:**
```typescript
export async function OnPlayerDied(player: mod.Player) {
  const deaths = getPlayerDeaths(player);

  // Longer respawn time for repeat deaths
  const respawnDelay = Math.min(5 + deaths * 2, 15);  // Max 15s

  mod.SetRedeployTime(player, respawnDelay);
}
```

---

## Player Join Control

### DisablePlayerJoin

Prevent new players from joining:

```typescript
mod.DisablePlayerJoin(): void
```

**Example - Lock Lobby:**
```typescript
export async function OnGameModeStarted() {
  await mod.Wait(30);  // 30 second join window

  mod.DisablePlayerJoin();  // Lock the lobby
  console.log("Lobby locked - no new players allowed");
}
```

::: warning No EnablePlayerJoin
There is **no** `EnablePlayerJoin()` function. Once disabled, player joining cannot be re-enabled during the match.
:::

---

## Time Management

### SetGameModeTimeLimit

Set maximum match duration:

```typescript
mod.SetGameModeTimeLimit(newTimeLimit: number): void
```

**Parameters:**
- `newTimeLimit` - Time in seconds (0 = no limit)

**Example - 10 Minute Match:**
```typescript
export async function OnGameModeStarted() {
  mod.SetGameModeTimeLimit(600);  // 10 minutes
}
```

**Example - Dynamic Time Extension:**
```typescript
async function checkOvertime() {
  const timeLimit = 600;

  while (gameRunning) {
    if (mod.GetGameTime() >= timeLimit) {
      const team1Score = mod.GetGameModeScore(mod.Team.Team1);
      const team2Score = mod.GetGameModeScore(mod.Team.Team2);

      if (team1Score === team2Score) {
        // Tied - extend time
        mod.SetGameModeTimeLimit(timeLimit + 120);  // +2 minutes
        announceOvertime();
      }
    }

    await mod.Wait(1);
  }
}
```

---

### PauseGameModeTime

Pause or resume the match timer:

```typescript
mod.PauseGameModeTime(pauseTimer: boolean): void
```

**Example - Pause During Buy Phase:**
```typescript
async function buyPhaseWithPause() {
  mod.PauseGameModeTime(true);   // Pause timer

  await buyPhase(30);  // 30s buy phase (doesn't count toward match time)

  mod.PauseGameModeTime(false);  // Resume timer
}
```

---

### ResetGameModeTime

Reset the match timer to zero:

```typescript
mod.ResetGameModeTime(): void
```

**Example - New Round:**
```typescript
function startNewRound() {
  mod.ResetGameModeTime();
  mod.DeployAllPlayers();
}
```

---

## Match Control

### EndGameMode

End the match with a winner:

```typescript
// Player wins
mod.EndGameMode(player: Player): void

// Team wins
mod.EndGameMode(team: Team): void
```

**Example - First to 10 Kills:**
```typescript
export async function OnPlayerEarnedKill(killer: mod.Player) {
  const kills = mod.GetGameModeScore(killer);

  if (kills + 1 >= 10) {
    mod.EndGameMode(killer);  // Killer wins
  }
}
```

**Example - Team Victory:**
```typescript
function checkTeamVictory() {
  const team1Points = getCapturePoints(mod.Team.Team1);
  const team2Points = getCapturePoints(mod.Team.Team2);

  if (team1Points >= 3) {
    mod.EndGameMode(mod.Team.Team1);
  } else if (team2Points >= 3) {
    mod.EndGameMode(mod.Team.Team2);
  }
}
```

---

## Common Patterns

### Countdown System

```typescript
async function showCountdown(seconds: number) {
  for (let i = seconds; i > 0; i--) {
    mod.DisplayCustomNotificationMessage(
      mod.Message(i.toString()),
      mod.CustomNotificationSlots.HeaderText,
      1
    );
    await mod.Wait(1);
  }

  mod.DisplayCustomNotificationMessage(
    mod.Message("GO!"),
    mod.CustomNotificationSlots.HeaderText,
    1
  );
}

export async function OnGameModeStarted() {
  await showCountdown(3);
  mod.DeployAllPlayers();
}
```

---

### Lobby System

```typescript
let lobbyOpen = true;
let lobbyCountdownStarted = false;
const minPlayers = 4;

export async function OnPlayerJoinGame(player: mod.Player) {
  const players = modlib.ConvertArray(mod.AllPlayers());

  if (lobbyOpen && !lobbyCountdownStarted && players.length >= minPlayers) {
    lobbyCountdownStarted = true;
    startLobbyCountdown();
  }
}

async function startLobbyCountdown() {
  await mod.Wait(10);  // 10 second countdown

  lobbyOpen = false;
  mod.DisablePlayerJoin();

  await showCountdown(3);
  mod.DeployAllPlayers();
  gameInProgress = true;
}
```

---

### Round-Based System

```typescript
let currentRound = 1;
const maxRounds = 5;
let team1Wins = 0;
let team2Wins = 0;

async function playRound() {
  // Reset round
  mod.ResetGameModeTime();
  mod.DeployAllPlayers();

  // Play round
  const winner = await waitForRoundEnd();

  // Award round win
  if (winner === mod.Team.Team1) team1Wins++;
  else if (winner === mod.Team.Team2) team2Wins++;

  // Check match winner
  if (team1Wins > maxRounds / 2) {
    mod.EndGameMode(mod.Team.Team1);
  } else if (team2Wins > maxRounds / 2) {
    mod.EndGameMode(mod.Team.Team2);
  } else {
    // Next round
    currentRound++;
    mod.UndeployAllPlayers();
    await mod.Wait(5);
    playRound();
  }
}
```

---

### Spawn Wave System

```typescript
let deadPlayers: mod.Player[] = [];
const waveInterval = 15;  // Respawn every 15 seconds

export async function OnPlayerDied(player: mod.Player) {
  mod.EnablePlayerDeploy(player, false);
  deadPlayers.push(player);
}

async function spawnWaveLoop() {
  while (gameRunning) {
    await mod.Wait(waveInterval);

    // Respawn all dead players
    for (const player of deadPlayers) {
      mod.EnablePlayerDeploy(player, true);
      mod.SpawnPlayerFromSpawnPoint(player, getSpawnPoint());
    }

    deadPlayers = [];
  }
}
```

---

## Best Practices

### 1. Always Use OnGameModeStarted

```typescript
// ✅ Good - Initialize in OnGameModeStarted
export async function OnGameModeStarted() {
  mod.SetGameModeTimeLimit(600);
  mod.SetGameModeTargetScore(1000);
  setupGameRules();
}

// ❌ Bad - Global initialization (runs at wrong time)
mod.SetGameModeTimeLimit(600);  // May run before game mode starts
```

### 2. Handle Player Disconnects

```typescript
// ✅ Good - Clean up player data
export async function OnPlayerLeaveGame(playerId: string) {
  playerData.delete(playerId);
  checkMinimumPlayers();
}

// ❌ Bad - Ignore disconnects (memory leak)
export async function OnPlayerLeaveGame(playerId: string) {
  // No cleanup - playerData grows forever
}
```

### 3. Check Victory Conditions

```typescript
// ✅ Good - Multiple victory paths
export async function OnPlayerEarnedKill(killer: mod.Player) {
  updateScore(killer);

  // Check score victory
  if (mod.GetGameModeScore(killer) >= mod.GetTargetScore()) {
    mod.EndGameMode(killer);
  }

  // Check time victory
  if (mod.GetGameTime() >= mod.GetGameModeTimeLimit()) {
    endGameByTime();
  }
}
```

### 4. Use Deployment Control

```typescript
// ✅ Good - Control deployment flow
async function intermission() {
  mod.UndeployAllPlayers();
  mod.EnableAllPlayerDeploy(false);

  await showScoreboard(10);

  mod.EnableAllPlayerDeploy(true);
  mod.DeployAllPlayers();
}

// ❌ Bad - Players can deploy during intermission
async function intermission() {
  mod.UndeployAllPlayers();
  await mod.Wait(10);  // Players may deploy themselves
  mod.DeployAllPlayers();
}
```

---

## API Functions Summary

| Category | Functions |
|----------|-----------|
| **Event Hooks** | OnGameModeStarted, OnPlayerJoinGame, OnPlayerLeaveGame, OnPlayerDeployed, OnPlayerDied, OnPlayerEarnedKill, OnPlayerSwitchTeam |
| **Deployment** | DeployAllPlayers, UndeployAllPlayers, UndeployPlayer, EnablePlayerDeploy, EnableAllPlayerDeploy, SetRedeployTime |
| **Join Control** | DisablePlayerJoin |
| **Time Management** | SetGameModeTimeLimit, PauseGameModeTime, ResetGameModeTime |
| **Match Control** | EndGameMode |

**Total: ~15 game mode control functions + 7 event hooks**

---

## See Also

- 📖 [Teams & Scoring](/api/teams-scoring) - Team assignment and scoring
- 📖 [Player Spawning](/api/player-spawning) - Spawn points and deployment
- 📖 [Player Control](/api/player-control) - Player state and control
- 📖 [modlib Helpers](/api/modlib) - Utility functions

---

★ Insight ─────────────────────────────────────
**Game Mode Lifecycle Design**
1. **Event-Driven Architecture** - Seven hooks provide complete coverage of game mode lifecycle without polling
2. **Deployment as State Machine** - Players can be deployed, undeployed, and have deployment permission toggled independently
3. **OnPlayerLeaveGame String ID** - Uses string instead of Player object since player is already disconnected, preventing invalid object references
─────────────────────────────────────────────────
