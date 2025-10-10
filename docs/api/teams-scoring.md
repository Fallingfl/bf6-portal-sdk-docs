# Teams & Scoring API Reference

Complete reference for team management, scoring systems, and game victory conditions in the BF6 Portal SDK.

## Overview

The Teams & Scoring system provides:
- **Up to 9 teams** - Team1 through Team9
- **14 team colors** - Customizable visual identification
- **Player/Team scoring** - Independent score tracking
- **Victory conditions** - Win by team or individual player
- **Scoreboard customization** - Custom columns and sorting
- **Game time control** - Time limits and pause functionality

## Team System

### Team Constants

Nine teams are available for assignment:

```typescript
mod.Team.Team1    // Default: Blue
mod.Team.Team2    // Default: Red
mod.Team.Team3    // Default: Green
mod.Team.Team4    // Default: Yellow
mod.Team.Team5    // Default: Orange
mod.Team.Team6    // Default: Purple
mod.Team.Team7    // Default: Cyan
mod.Team.Team8    // Default: White
mod.Team.Team9    // Default: Black
```

### Assigning Players to Teams

#### SetTeam

Assign a player to a team:

```typescript
mod.SetTeam(player: Player, team: Team): void

// Example - Assign to Team 1
mod.SetTeam(player, mod.Team.Team1);
```

**Example - Round-Robin Team Assignment:**
```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  const players = modlib.ConvertArray(mod.AllPlayers());
  const teamCount = 4;

  // Distribute players evenly across teams
  const teamIndex = (players.length - 1) % teamCount;
  const teams = [
    mod.Team.Team1,
    mod.Team.Team2,
    mod.Team.Team3,
    mod.Team.Team4
  ];

  mod.SetTeam(player, teams[teamIndex]);
}
```

**Example - Skill-Based Teams:**
```typescript
function balanceTeams() {
  const players = modlib.ConvertArray(mod.AllPlayers());

  // Sort by score (descending)
  players.sort((a, b) => mod.GetGameModeScore(b) - mod.GetGameModeScore(a));

  // Alternate assignment (1st → Team1, 2nd → Team2, 3rd → Team1, etc.)
  for (let i = 0; i < players.length; i++) {
    const team = (i % 2 === 0) ? mod.Team.Team1 : mod.Team.Team2;
    mod.SetTeam(players[i], team);
  }
}
```

#### GetTeam

Retrieve a player's current team:

```typescript
const team: Team = mod.GetTeam(player: Player);

// Check team membership
if (mod.GetTeam(player) === mod.Team.Team1) {
  // Player is on Team 1
}
```

Get team object by ID:

```typescript
const team: Team = mod.GetTeam(teamId: number);

// Team IDs: 1-9 correspond to Team1-Team9
const team1 = mod.GetTeam(1);  // Returns Team.Team1
const team2 = mod.GetTeam(2);  // Returns Team.Team2
```

### Team Customization

::: warning Team Name/Color Functions Not Exposed
The TypeScript API currently does **not include** `SetTeamName()` or `SetTeamColor()` functions, despite them being mentioned in some documentation. Teams use default colors (Blue, Red, Green, Yellow, etc.).

**Workaround:** Use team-specific UI colors or messages to identify teams:
```typescript
function getTeamColorRGB(team: mod.Team): mod.Vector {
  if (team === mod.Team.Team1) return mod.CreateVector(0, 0.5, 1);    // Blue
  if (team === mod.Team.Team2) return mod.CreateVector(1, 0, 0);      // Red
  if (team === mod.Team.Team3) return mod.CreateVector(0, 1, 0);      // Green
  if (team === mod.Team.Team4) return mod.CreateVector(1, 1, 0);      // Yellow
  return mod.CreateVector(1, 1, 1);  // Default white
}
```
:::

---

## Scoring System

### Player Scoring

#### SetGameModeScore

Set a player's score:

```typescript
mod.SetGameModeScore(player: Player, newScore: number): void

// Set score
mod.SetGameModeScore(player, 100);

// Add to score
const currentScore = mod.GetGameModeScore(player);
mod.SetGameModeScore(player, currentScore + 10);
```

#### GetGameModeScore

Get a player's current score:

```typescript
const score: number = mod.GetGameModeScore(player: Player);

// Display score
console.log(`Player score: ${mod.GetGameModeScore(player)}`);
```

**Example - Kill Reward System:**
```typescript
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  // Award points for kill
  const currentScore = mod.GetGameModeScore(killer);
  mod.SetGameModeScore(killer, currentScore + 100);

  // Check for victory
  if (mod.GetGameModeScore(killer) >= 1000) {
    mod.EndGameMode(killer);
  }
}
```

### Team Scoring

#### SetGameModeScore (Team)

Set a team's score:

```typescript
mod.SetGameModeScore(team: Team, newScore: number): void

// Set team score
mod.SetGameModeScore(mod.Team.Team1, 500);

// Add to team score
const teamScore = mod.GetGameModeScore(mod.Team.Team1);
mod.SetGameModeScore(mod.Team.Team1, teamScore + 50);
```

#### GetGameModeScore (Team)

Get a team's current score:

```typescript
const score: number = mod.GetGameModeScore(team: Team);

// Check team score
if (mod.GetGameModeScore(mod.Team.Team1) > mod.GetGameModeScore(mod.Team.Team2)) {
  // Team 1 is winning
}
```

**Example - Capture Point Scoring:**
```typescript
async function trackCapturePoint(capturePointId: number) {
  const capturePoint = mod.GetCapturePoint(capturePointId);

  while (gameRunning) {
    const controllingTeam = mod.GetCapturePointTeam(capturePoint);

    if (controllingTeam !== null) {
      // Award points to controlling team
      const teamScore = mod.GetGameModeScore(controllingTeam);
      mod.SetGameModeScore(controllingTeam, teamScore + 1);

      // Check for victory
      if (mod.GetGameModeScore(controllingTeam) >= 500) {
        mod.EndGameMode(controllingTeam);
        break;
      }
    }

    await mod.Wait(1);  // Award 1 point per second
  }
}
```

### Target Score

#### SetGameModeTargetScore

Set the score needed to win:

```typescript
mod.SetGameModeTargetScore(newScore: number): void

// Set target to 1000 points
mod.SetGameModeTargetScore(1000);
```

#### GetTargetScore

Get the current target score:

```typescript
const targetScore: number = mod.GetTargetScore();

// Check progress
const playerScore = mod.GetGameModeScore(player);
const remaining = mod.GetTargetScore() - playerScore;
console.log(`${remaining} points to win`);
```

---

## Victory Conditions

### EndGameMode

End the game with a winner:

```typescript
// Player wins
mod.EndGameMode(player: Player): void

// Team wins
mod.EndGameMode(team: Team): void
```

**Example - First to 10 Kills:**
```typescript
export async function OnPlayerEarnedKill(killer: mod.Player, victim: mod.Player) {
  const kills = mod.GetGameModeScore(killer);
  mod.SetGameModeScore(killer, kills + 1);

  if (kills + 1 >= 10) {
    mod.EndGameMode(killer);  // Killer wins
  }
}
```

**Example - Team Deathmatch:**
```typescript
async function checkTeamVictory() {
  while (gameRunning) {
    for (const team of [mod.Team.Team1, mod.Team.Team2]) {
      const score = mod.GetGameModeScore(team);

      if (score >= 75) {  // First to 75 kills
        mod.EndGameMode(team);
        gameRunning = false;
        break;
      }
    }

    await mod.Wait(1);
  }
}
```

---

## Scoreboard Customization

The scoreboard displays player rankings and stats with customizable columns.

### SetScoreboardType

Set scoreboard mode:

```typescript
mod.SetScoreboardType(scoreboardType: ScoreboardType): void

// Available types:
mod.ScoreboardType.Default        // Standard scoreboard
mod.ScoreboardType.Team           // Team-based scoreboard
mod.ScoreboardType.FreeForAll     // FFA scoreboard
```

### SetScoreboardHeader

Set scoreboard title:

```typescript
// Team-based header
mod.SetScoreboardHeader(team1Name: Message, team2Name: Message): void

mod.SetScoreboardHeader(
  mod.Message("ATTACKERS"),
  mod.Message("DEFENDERS")
);

// Single header
mod.SetScoreboardHeader(headerName: Message): void

mod.SetScoreboardHeader(mod.Message("TOP PLAYERS"));
```

### SetScoreboardColumnNames

Customize column labels:

```typescript
// Up to 5 columns
mod.SetScoreboardColumnNames(
  column1Name: Message,
  column2Name?: Message,
  column3Name?: Message,
  column4Name?: Message,
  column5Name?: Message
): void

// Example - Custom columns
mod.SetScoreboardColumnNames(
  mod.Message("KILLS"),
  mod.Message("DEATHS"),
  mod.Message("K/D")
);
```

### SetScoreboardColumnWidths

Set column widths (relative proportions):

```typescript
mod.SetScoreboardColumnWidths(
  column1Width: number,
  column2Width?: number,
  column3Width?: number,
  column4Width?: number,
  column5Width?: number
): void

// Example - Wider first column
mod.SetScoreboardColumnWidths(
  2.0,  // 2x width for first column
  1.0,  // Normal width
  1.0
);
```

### SetScoreboardPlayerValues

Set player's values for scoreboard columns:

```typescript
mod.SetScoreboardPlayerValues(
  player: Player,
  column1Value: number,
  column2Value?: number,
  column3Value?: number,
  column4Value?: number,
  column5Value?: number
): void
```

**Example - K/D Scoreboard:**
```typescript
let playerKills = new Map<string, number>();
let playerDeaths = new Map<string, number>();

export async function OnGameModeStarted() {
  // Setup scoreboard
  mod.SetScoreboardHeader(mod.Message("DEATHMATCH"));
  mod.SetScoreboardColumnNames(
    mod.Message("KILLS"),
    mod.Message("DEATHS"),
    mod.Message("K/D RATIO")
  );
  mod.SetScoreboardColumnWidths(1.0, 1.0, 1.5);
  mod.SetScoreboardSorting(0, true);  // Sort by kills, descending
}

export async function OnPlayerJoinGame(player: mod.Player) {
  const playerId = mod.GetPlayerId(player);
  playerKills.set(playerId, 0);
  playerDeaths.set(playerId, 0);
  updatePlayerScoreboard(player);
}

export async function OnPlayerEarnedKill(killer: mod.Player, victim: mod.Player) {
  const killerId = mod.GetPlayerId(killer);
  const victimId = mod.GetPlayerId(victim);

  // Update stats
  playerKills.set(killerId, (playerKills.get(killerId) || 0) + 1);
  playerDeaths.set(victimId, (playerDeaths.get(victimId) || 0) + 1);

  // Update scoreboard
  updatePlayerScoreboard(killer);
  updatePlayerScoreboard(victim);
}

function updatePlayerScoreboard(player: mod.Player) {
  const playerId = mod.GetPlayerId(player);
  const kills = playerKills.get(playerId) || 0;
  const deaths = playerDeaths.get(playerId) || 0;
  const kd = deaths > 0 ? kills / deaths : kills;

  mod.SetScoreboardPlayerValues(player, kills, deaths, Math.floor(kd * 100) / 100);
}
```

### SetScoreboardSorting

Set which column to sort by:

```typescript
mod.SetScoreboardSorting(
  sortingColumn: number,      // 0-4 (column index)
  reverseSorting?: boolean    // true = descending, false = ascending
): void

// Sort by first column (descending)
mod.SetScoreboardSorting(0, true);

// Sort by third column (ascending)
mod.SetScoreboardSorting(2, false);
```

---

## Game Time Control

### SetGameTimeLimit

Set maximum game duration:

```typescript
mod.SetGameTimeLimit(timeInSeconds: number): void

// 10-minute match
mod.SetGameTimeLimit(600);

// No time limit
mod.SetGameTimeLimit(0);
```

### GetGameTime

Get elapsed game time:

```typescript
const elapsedTime: number = mod.GetGameTime();

// Display time remaining
const timeLimit = 600;
const timeRemaining = timeLimit - mod.GetGameTime();
console.log(`Time remaining: ${Math.floor(timeRemaining)}s`);
```

### SetGamePaused

Pause/unpause the game:

```typescript
mod.SetGamePaused(paused: boolean): void

// Pause game
mod.SetGamePaused(true);

// Resume game
mod.SetGamePaused(false);
```

**Example - Overtime System:**
```typescript
async function checkOvertime() {
  const timeLimit = 600;

  while (gameRunning) {
    const elapsed = mod.GetGameTime();

    if (elapsed >= timeLimit) {
      const team1Score = mod.GetGameModeScore(mod.Team.Team1);
      const team2Score = mod.GetGameModeScore(mod.Team.Team2);

      if (team1Score === team2Score) {
        // Tied - extend time
        mod.SetGameTimeLimit(timeLimit + 120);  // +2 minutes
        announceOvertime();
      } else {
        // Determine winner
        const winner = team1Score > team2Score ? mod.Team.Team1 : mod.Team.Team2;
        mod.EndGameMode(winner);
        gameRunning = false;
      }
    }

    await mod.Wait(1);
  }
}
```

---

## Player Management

### AllPlayers

Get all players in the match:

```typescript
const players: Array = mod.AllPlayers();

// Convert to JavaScript array for easier manipulation
const playerArray = modlib.ConvertArray(mod.AllPlayers());

// Iterate players
for (const player of playerArray) {
  console.log(mod.GetPlayerName(player));
}
```

### DeployAllPlayers

Deploy all players simultaneously:

```typescript
mod.DeployAllPlayers(): void

// Start match
export async function OnGameModeStarted() {
  await mod.Wait(3);  // 3-second countdown
  mod.DeployAllPlayers();
}
```

### UndeployAllPlayers

Remove all players from play:

```typescript
mod.UndeployAllPlayers(): void

// Round end
async function endRound() {
  mod.UndeployAllPlayers();
  await mod.Wait(5);
  startNextRound();
}
```

---

## Common Patterns

### Capture the Flag Scoring

```typescript
let team1Captures = 0;
let team2Captures = 0;

export async function onFlagCaptured(team: mod.Team) {
  if (team === mod.Team.Team1) {
    team1Captures++;
    mod.SetGameModeScore(mod.Team.Team1, team1Captures);
  } else if (team === mod.Team.Team2) {
    team2Captures++;
    mod.SetGameModeScore(mod.Team.Team2, team2Captures);
  }

  // Check victory (first to 3 captures)
  if (team1Captures >= 3) {
    mod.EndGameMode(mod.Team.Team1);
  } else if (team2Captures >= 3) {
    mod.EndGameMode(mod.Team.Team2);
  }
}
```

### Last Man Standing

```typescript
async function checkLastManStanding() {
  while (gameRunning) {
    const alivePlayers = modlib.FilteredArray(
      mod.AllPlayers(),
      (p) => mod.GetSoldierState(p, mod.SoldierStateBool.IsAlive)
    );

    if (alivePlayers.length === 1) {
      // Only one player left - they win
      mod.EndGameMode(alivePlayers[0]);
      gameRunning = false;
    } else if (alivePlayers.length === 0) {
      // Everyone died - draw
      gameRunning = false;
    }

    await mod.Wait(1);
  }
}
```

### Round-Based Scoring

```typescript
let roundScores = new Map<mod.Team, number>();
let currentRound = 1;
const maxRounds = 5;

async function roundVictory(winningTeam: mod.Team) {
  // Award round point
  const teamRounds = (roundScores.get(winningTeam) || 0) + 1;
  roundScores.set(winningTeam, teamRounds);

  // Check if team won majority of rounds
  if (teamRounds > maxRounds / 2) {
    mod.EndGameMode(winningTeam);  // Match victory
  } else {
    // Continue to next round
    currentRound++;
    if (currentRound <= maxRounds) {
      startNextRound();
    } else {
      // Max rounds reached - highest score wins
      declareWinnerByRounds();
    }
  }
}
```

### Free-For-All Leaderboard

```typescript
export async function OnGameModeStarted() {
  // Setup FFA scoreboard
  mod.SetScoreboardType(mod.ScoreboardType.FreeForAll);
  mod.SetScoreboardHeader(mod.Message("FREE FOR ALL"));
  mod.SetScoreboardColumnNames(
    mod.Message("SCORE"),
    mod.Message("KILLS")
  );
  mod.SetScoreboardSorting(0, true);  // Sort by score
}

async function updateLeaderboard() {
  while (gameRunning) {
    const players = modlib.ConvertArray(mod.AllPlayers());

    for (const player of players) {
      const score = mod.GetGameModeScore(player);
      const kills = playerKillCounts.get(mod.GetPlayerId(player)) || 0;

      mod.SetScoreboardPlayerValues(player, score, kills);
    }

    await mod.Wait(1);
  }
}
```

---

## Best Practices

### 1. Initialize Scores

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  // Set initial score
  mod.SetGameModeScore(player, 0);
}
```

### 2. Validate Victory Conditions

```typescript
function checkVictory() {
  const targetScore = mod.GetTargetScore();

  if (targetScore > 0) {  // Only if target is set
    const players = modlib.ConvertArray(mod.AllPlayers());

    for (const player of players) {
      if (mod.GetGameModeScore(player) >= targetScore) {
        mod.EndGameMode(player);
        return true;
      }
    }
  }

  return false;
}
```

### 3. Balance Teams

```typescript
function getTeamPlayerCount(team: mod.Team): number {
  const players = modlib.ConvertArray(mod.AllPlayers());
  return modlib.FilteredArray(players, (p) => mod.GetTeam(p) === team).length;
}

function balanceTeamNumbers() {
  while (Math.abs(getTeamPlayerCount(mod.Team.Team1) - getTeamPlayerCount(mod.Team.Team2)) > 1) {
    // Move players to balance teams
    // ... (implementation)
  }
}
```

### 4. Handle Disconnects

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  // Player scores persist, but team balance may need adjustment
  balanceTeamNumbers();
}
```

---

## API Functions Summary

| Category | Functions |
|----------|-----------|
| **Team Assignment** | SetTeam, GetTeam |
| **Player Scoring** | SetGameModeScore (player), GetGameModeScore (player) |
| **Team Scoring** | SetGameModeScore (team), GetGameModeScore (team) |
| **Target Score** | SetGameModeTargetScore, GetTargetScore |
| **Victory** | EndGameMode (player/team) |
| **Scoreboard** | SetScoreboardType, SetScoreboardHeader, SetScoreboardColumnNames, SetScoreboardColumnWidths, SetScoreboardPlayerValues, SetScoreboardSorting |
| **Game Time** | SetGameTimeLimit, GetGameTime, SetGamePaused |
| **Player Management** | AllPlayers, DeployAllPlayers, UndeployAllPlayers |

**Total: ~30 team & scoring functions**

---

## See Also

- 📖 [Player Control](/api/player-control) - Player management and state
- 📖 [Gameplay Objects](/api/gameplay-objects) - Capture points and objectives
- 📖 [modlib Helpers](/api/modlib) - Array and condition utilities
- 📚 [API Overview](/api/) - Complete API reference

---

★ Insight ─────────────────────────────────────
**Scoring System Architecture**
1. **Dual Scoring Tracks** - Players and teams have independent scores, allowing both individual achievements and team objectives
2. **Declarative Scoreboards** - Configure columns once at game start, then update player values dynamically without rebuilding UI
3. **Victory Flexibility** - EndGameMode() accepts both Player and Team types, enabling mixed game modes (e.g., team scoring with individual winner)
─────────────────────────────────────────────────
