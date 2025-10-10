# Teams & Players

Learn how to manage teams and players in your custom Battlefield game modes, including team assignment, scoring, and victory conditions.

## Teams Overview

The SDK supports **up to 9 teams** with extensive customization options.

### Available Teams

```typescript
mod.Team.Team1
mod.Team.Team2
mod.Team.Team3
mod.Team.Team4
mod.Team.Team5
mod.Team.Team6
mod.Team.Team7
mod.Team.Team8
mod.Team.Team9
```

### Team Configuration

```typescript
export async function OnGameModeStarted() {
  // Configure Team 1
  mod.SetTeamName(mod.Team.Team1, "Attackers");
  mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);

  // Configure Team 2
  mod.SetTeamName(mod.Team.Team2, "Defenders");
  mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);
}
```

### Available Team Colors

```typescript
mod.TeamColor.Red
mod.TeamColor.Blue
mod.TeamColor.Green
mod.TeamColor.Yellow
mod.TeamColor.Orange
mod.TeamColor.Purple
mod.TeamColor.Pink
mod.TeamColor.Cyan
mod.TeamColor.White
mod.TeamColor.Black
mod.TeamColor.Brown
mod.TeamColor.Gray
mod.TeamColor.LightBlue
mod.TeamColor.DarkGreen
```

## Team Assignment Strategies

### 1. Round-Robin Assignment

Distributes players evenly across teams:

```typescript
let playerCount = 0;
const teams = [mod.Team.Team1, mod.Team.Team2];

export async function OnPlayerJoinGame(player: mod.Player) {
  // Alternate between teams
  const teamIndex = playerCount % teams.length;
  mod.SetPlayerTeam(player, teams[teamIndex]);

  playerCount++;

  console.log(`Player ${playerCount} assigned to Team ${teamIndex + 1}`);
}
```

### 2. Balance by Team Size

Assigns to the team with fewer players:

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  const team1Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team1));
  const team2Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team2));

  if (team1Count <= team2Count) {
    mod.SetPlayerTeam(player, mod.Team.Team1);
  } else {
    mod.SetPlayerTeam(player, mod.Team.Team2);
  }

  console.log(`Balanced assignment: Team1=${team1Count} Team2=${team2Count}`);
}
```

### 3. Free-For-All (FFA)

Each player on their own team:

```typescript
let nextTeam = 0;
const maxTeams = 9;

export async function OnPlayerJoinGame(player: mod.Player) {
  const teamIndex = nextTeam % maxTeams;
  const team = [
    mod.Team.Team1, mod.Team.Team2, mod.Team.Team3,
    mod.Team.Team4, mod.Team.Team5, mod.Team.Team6,
    mod.Team.Team7, mod.Team.Team8, mod.Team.Team9
  ][teamIndex];

  mod.SetPlayerTeam(player, team);
  nextTeam++;

  console.log(`FFA: Player assigned to Team ${teamIndex + 1}`);
}
```

### 4. Random Assignment

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  const teams = [mod.Team.Team1, mod.Team.Team2, mod.Team.Team3, mod.Team.Team4];
  const randomIndex = Math.floor(Math.random() * teams.length);

  mod.SetPlayerTeam(player, teams[randomIndex]);

  console.log(`Random assignment to Team ${randomIndex + 1}`);
}
```

### 5. Player Choice

Let players choose their team:

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  // Start in spectator team
  mod.SetPlayerTeam(player, mod.Team.Team9);

  // Show team selection UI
  showTeamSelectionMenu(player);
}

function showTeamSelectionMenu(player: mod.Player) {
  // Create UI with team selection buttons
  const container = mod.AddUIContainer(
    player,
    [400, 300],  // Position
    [400, 300],  // Size
    mod.UIAnchor.Center
  );

  mod.AddUIButton(
    player,
    container,
    "Join Red Team",
    [10, 10],
    [180, 50],
    () => {
      mod.SetPlayerTeam(player, mod.Team.Team1);
      mod.RemoveUIWidget(player, container);
    }
  );

  mod.AddUIButton(
    player,
    container,
    "Join Blue Team",
    [210, 10],
    [180, 50],
    () => {
      mod.SetPlayerTeam(player, mod.Team.Team2);
      mod.RemoveUIWidget(player, container);
    }
  );
}
```

## Team Operations

### Get Players in Team

```typescript
// Get as mod.Array
const team1Array = mod.GetPlayersInTeam(mod.Team.Team1);

// Convert to JavaScript array
import * as modlib from './modlib';
const team1Players = modlib.ConvertArray(team1Array);

// Iterate
for (const player of team1Players) {
  console.log("Team 1 player:", mod.GetPlayerName(player));
}
```

### Count Players per Team

```typescript
function getTeamCounts(): { [key: string]: number } {
  return {
    team1: mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team1)),
    team2: mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team2)),
    team3: mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team3)),
    team4: mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team4))
  };
}

// Usage
const counts = getTeamCounts();
console.log(`Teams: ${counts.team1} vs ${counts.team2}`);
```

### Team Rebalancing

```typescript
function rebalanceTeams() {
  const team1Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team1));
  const team2Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team2));

  const difference = Math.abs(team1Count - team2Count);

  // Only rebalance if difference > 2
  if (difference > 2) {
    const largerTeam = team1Count > team2Count ? mod.Team.Team1 : mod.Team.Team2;
    const smallerTeam = team1Count > team2Count ? mod.Team.Team2 : mod.Team.Team1;

    // Move one player
    const playersToMove = modlib.ConvertArray(mod.GetPlayersInTeam(largerTeam));
    if (playersToMove.length > 0) {
      mod.SetPlayerTeam(playersToMove[0], smallerTeam);
      console.log("Teams rebalanced!");
    }
  }
}
```

## Player Management

### Player Properties

```typescript
// Get player info
const name = mod.GetPlayerName(player);
const id = mod.GetPlayerId(player);
const team = mod.GetPlayerTeam(player);
const score = mod.GetPlayerScore(player);
const health = mod.GetPlayerHealth(player);

// Get position
const transform = mod.GetPlayerTransform(player);
const position = transform.position;

// Get equipment
const weapons = mod.GetPlayerEquipment(player);
```

### Player Tracking

Create custom data for each player:

```typescript
interface PlayerData {
  player: mod.Player;
  kills: number;
  deaths: number;
  assists: number;
  score: number;
  joinTime: number;
  team: mod.Team;
}

let playerData: PlayerData[] = [];

export async function OnPlayerJoinGame(player: mod.Player) {
  const data: PlayerData = {
    player: player,
    kills: 0,
    deaths: 0,
    assists: 0,
    score: 0,
    joinTime: mod.GetGameTime(),
    team: mod.Team.Team1
  };

  playerData.push(data);
}

export async function OnPlayerLeaveGame(playerId: string) {
  playerData = playerData.filter(p => mod.GetPlayerId(p.player) !== playerId);
}

// Helper function
function findPlayerData(player: mod.Player): PlayerData | undefined {
  return playerData.find(p => p.player === player);
}
```

### Player State Management

```typescript
// Use modlib condition tracking
import * as modlib from './modlib';

// Set player conditions (boolean flags)
modlib.setPlayerCondition(player, 1, true);   // Condition 1 = has flag
modlib.setPlayerCondition(player, 2, false);  // Condition 2 = is invincible

// Check conditions
if (modlib.getPlayerCondition(player, 1)) {
  console.log("Player has the flag!");
}

// You have 100 condition slots (1-100) per player
```

## Team Scoring

### Team Score Management

```typescript
// Set team score
mod.SetTeamScore(mod.Team.Team1, 500);

// Get team score
const score = mod.GetTeamScore(mod.Team.Team1);

// Increment team score
const currentScore = mod.GetTeamScore(mod.Team.Team1);
mod.SetTeamScore(mod.Team.Team1, currentScore + 100);

// Award points to player's team
function awardTeamPoints(player: mod.Player, points: number) {
  const team = mod.GetPlayerTeam(player);
  const currentScore = mod.GetTeamScore(team);
  mod.SetTeamScore(team, currentScore + points);
}
```

### Victory Conditions

```typescript
// Check team score victory
function checkTeamVictory() {
  const team1Score = mod.GetTeamScore(mod.Team.Team1);
  const team2Score = mod.GetTeamScore(mod.Team.Team2);

  if (team1Score >= 1000) {
    mod.SetWinningTeam(mod.Team.Team1);
    mod.EndGame();
  } else if (team2Score >= 1000) {
    mod.SetWinningTeam(mod.Team.Team2);
    mod.EndGame();
  }
}

// Check elimination victory
function checkEliminationVictory() {
  const team1Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team1));
  const team2Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team2));

  if (team1Count === 0) {
    mod.SetWinningTeam(mod.Team.Team2);
    announceToAll("Blue Team Wins!");
    mod.EndGame();
  } else if (team2Count === 0) {
    mod.SetWinningTeam(mod.Team.Team1);
    announceToAll("Red Team Wins!");
    mod.EndGame();
  }
}
```

## Player Scoring

### Individual Scores

```typescript
// Set player score
mod.SetPlayerScore(player, 1000);

// Get player score
const score = mod.GetPlayerScore(player);

// Increment score
const currentScore = mod.GetPlayerScore(player);
mod.SetPlayerScore(player, currentScore + 100);

// Award kill points
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player
) {
  const killerScore = mod.GetPlayerScore(killer);
  mod.SetPlayerScore(killer, killerScore + 100);

  // Show notification
  modlib.DisplayCustomNotificationMessage(
    "+100 points!",
    mod.NotificationSlot.MessageText2,
    2,
    killer
  );
}
```

### Leaderboard

```typescript
function getTopPlayers(count: number): mod.Player[] {
  const allPlayers = modlib.ConvertArray(mod.GetPlayers());

  // Sort by score
  const sorted = allPlayers.sort((a, b) => {
    return mod.GetPlayerScore(b) - mod.GetPlayerScore(a);
  });

  // Return top N
  return sorted.slice(0, count);
}

// Usage
const top3 = getTopPlayers(3);
console.log("1st Place:", mod.GetPlayerName(top3[0]));
console.log("2nd Place:", mod.GetPlayerName(top3[1]));
console.log("3rd Place:", mod.GetPlayerName(top3[2]));
```

### Individual Victory

```typescript
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player
) {
  const killerScore = mod.GetPlayerScore(killer);
  mod.SetPlayerScore(killer, killerScore + 100);

  // Check for individual victory
  if (killerScore + 100 >= 3000) {
    mod.SetWinningPlayer(killer);

    // Announce winner
    const allPlayers = modlib.ConvertArray(mod.GetPlayers());
    for (const player of allPlayers) {
      modlib.DisplayCustomNotificationMessage(
        `${mod.GetPlayerName(killer)} WINS!`,
        mod.NotificationSlot.HeaderText,
        10,
        player
      );
    }

    mod.EndGame();
  }
}
```

## Common Team Patterns

### 2-Team Competitive

Classic Red vs Blue:

```typescript
export async function OnGameModeStarted() {
  mod.SetTeamName(mod.Team.Team1, "Red Team");
  mod.SetTeamName(mod.Team.Team2, "Blue Team");
  mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);
  mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);
}

let playerCount = 0;

export async function OnPlayerJoinGame(player: mod.Player) {
  const team = playerCount % 2 === 0 ? mod.Team.Team1 : mod.Team.Team2;
  mod.SetPlayerTeam(player, team);
  playerCount++;
}
```

### 4-Team Battle Royale

```typescript
export async function OnGameModeStarted() {
  mod.SetTeamName(mod.Team.Team1, "Alpha Squad");
  mod.SetTeamName(mod.Team.Team2, "Bravo Squad");
  mod.SetTeamName(mod.Team.Team3, "Charlie Squad");
  mod.SetTeamName(mod.Team.Team4, "Delta Squad");

  mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);
  mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);
  mod.SetTeamColor(mod.Team.Team3, mod.TeamColor.Green);
  mod.SetTeamColor(mod.Team.Team4, mod.TeamColor.Yellow);
}
```

### Free-For-All

Everyone for themselves:

```typescript
export async function OnGameModeStarted() {
  // Configure all 9 teams
  const teamNames = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India"];
  const teams = [
    mod.Team.Team1, mod.Team.Team2, mod.Team.Team3,
    mod.Team.Team4, mod.Team.Team5, mod.Team.Team6,
    mod.Team.Team7, mod.Team.Team8, mod.Team.Team9
  ];

  for (let i = 0; i < teams.length; i++) {
    mod.SetTeamName(teams[i], teamNames[i]);
  }
}

let nextTeamIndex = 0;

export async function OnPlayerJoinGame(player: mod.Player) {
  const teams = [
    mod.Team.Team1, mod.Team.Team2, mod.Team.Team3,
    mod.Team.Team4, mod.Team.Team5, mod.Team.Team6,
    mod.Team.Team7, mod.Team.Team8, mod.Team.Team9
  ];

  mod.SetPlayerTeam(player, teams[nextTeamIndex % 9]);
  nextTeamIndex++;
}
```

## Team Communication

### Announce to Team

```typescript
function announceToTeam(team: mod.Team, message: string) {
  const teamPlayers = modlib.ConvertArray(mod.GetPlayersInTeam(team));

  for (const player of teamPlayers) {
    modlib.DisplayCustomNotificationMessage(
      message,
      mod.NotificationSlot.HeaderText,
      5,
      player
    );
  }
}

// Usage
announceToTeam(mod.Team.Team1, "Your team is in the lead!");
```

### Announce to All

```typescript
function announceToAll(message: string) {
  const allPlayers = modlib.ConvertArray(mod.GetPlayers());

  for (const player of allPlayers) {
    modlib.DisplayCustomNotificationMessage(
      message,
      mod.NotificationSlot.HeaderText,
      5,
      player
    );
  }
}

// Usage
announceToAll("The game will start in 30 seconds!");
```

### Team-Specific UI

```typescript
function showTeamScoreboard(player: mod.Player) {
  const playerTeam = mod.GetPlayerTeam(player);
  const teamScore = mod.GetTeamScore(playerTeam);
  const teamPlayers = modlib.ConvertArray(mod.GetPlayersInTeam(playerTeam));

  // Create UI showing team info
  const container = mod.AddUIContainer(
    player,
    [10, 10],
    [300, 200],
    mod.UIAnchor.TopLeft
  );

  mod.AddUIText(
    player,
    container,
    `Team: ${mod.GetTeamName(playerTeam)}`,
    [10, 10],
    20
  );

  mod.AddUIText(
    player,
    container,
    `Score: ${teamScore}`,
    [10, 40],
    18
  );

  mod.AddUIText(
    player,
    container,
    `Players: ${teamPlayers.length}`,
    [10, 70],
    18
  );
}
```

## Advanced Team Mechanics

### Team Switching Cooldown

```typescript
interface PlayerTeamData {
  player: mod.Player;
  lastSwitchTime: number;
}

let playerTeamData: PlayerTeamData[] = [];
const SWITCH_COOLDOWN = 60;  // 60 seconds

export async function OnPlayerSwitchTeam(
  player: mod.Player,
  newTeam: mod.Team
) {
  const data = playerTeamData.find(p => p.player === player);
  const currentTime = mod.GetGameTime();

  if (data && (currentTime - data.lastSwitchTime) < SWITCH_COOLDOWN) {
    // Too soon - switch back
    mod.SetPlayerTeam(player, mod.GetPlayerTeam(player));

    modlib.DisplayCustomNotificationMessage(
      "Please wait before switching teams again",
      mod.NotificationSlot.HeaderText,
      3,
      player
    );

    return;
  }

  // Allow switch
  if (data) {
    data.lastSwitchTime = currentTime;
  } else {
    playerTeamData.push({ player, lastSwitchTime: currentTime });
  }
}
```

### Team-Based Spawning

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  const team = mod.GetPlayerTeam(player);

  // Spawn at team-specific location
  let spawner: mod.Spawner;

  if (team === mod.Team.Team1) {
    spawner = mod.GetSpawner(1);  // Red team spawn
  } else if (team === mod.Team.Team2) {
    spawner = mod.GetSpawner(2);  // Blue team spawn
  } else {
    spawner = mod.GetSpawner(3);  // Neutral spawn
  }

  if (spawner) {
    mod.SpawnPlayerFromSpawnPoint(player, spawner);
  }
}
```

### Team Elimination Tracking

```typescript
async function checkTeamElimination() {
  const teams = [mod.Team.Team1, mod.Team.Team2, mod.Team.Team3, mod.Team.Team4];
  let teamsRemaining = 0;
  let winningTeam: mod.Team | null = null;

  for (const team of teams) {
    const teamCount = mod.GetArrayLength(mod.GetPlayersInTeam(team));
    if (teamCount > 0) {
      teamsRemaining++;
      winningTeam = team;
    }
  }

  // Victory if only one team remains
  if (teamsRemaining === 1 && winningTeam) {
    mod.SetWinningTeam(winningTeam);
    announceToAll(`${mod.GetTeamName(winningTeam)} WINS!`);
    mod.EndGame();
  }
}
```

## Best Practices

### 1. Always Set Team Names and Colors

```typescript
export async function OnGameModeStarted() {
  // Always configure teams for clarity
  mod.SetTeamName(mod.Team.Team1, "Attackers");
  mod.SetTeamName(mod.Team.Team2, "Defenders");

  mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);
  mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);
}
```

### 2. Balance Teams Automatically

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  // Auto-balance on join
  assignToSmallestTeam(player);
}

function assignToSmallestTeam(player: mod.Player) {
  const teams = [mod.Team.Team1, mod.Team.Team2];
  let smallestTeam = teams[0];
  let smallestCount = mod.GetArrayLength(mod.GetPlayersInTeam(teams[0]));

  for (const team of teams) {
    const count = mod.GetArrayLength(mod.GetPlayersInTeam(team));
    if (count < smallestCount) {
      smallestCount = count;
      smallestTeam = team;
    }
  }

  mod.SetPlayerTeam(player, smallestTeam);
}
```

### 3. Track Both Team and Player Scores

```typescript
export async function OnPlayerEarnedKill(killer: mod.Player, victim: mod.Player) {
  // Award points to player
  const playerScore = mod.GetPlayerScore(killer);
  mod.SetPlayerScore(killer, playerScore + 100);

  // Award points to team
  const team = mod.GetPlayerTeam(killer);
  const teamScore = mod.GetTeamScore(team);
  mod.SetTeamScore(team, teamScore + 50);
}
```

### 4. Provide Team Feedback

```typescript
function updateTeamScores() {
  const team1Score = mod.GetTeamScore(mod.Team.Team1);
  const team2Score = mod.GetTeamScore(mod.Team.Team2);

  const allPlayers = modlib.ConvertArray(mod.GetPlayers());
  for (const player of allPlayers) {
    modlib.DisplayCustomNotificationMessage(
      `Red: ${team1Score} | Blue: ${team2Score}`,
      mod.NotificationSlot.MessageText4,
      1,
      player
    );
  }
}
```

## Next Steps

- 📖 [Map Objects](/guides/map-objects) - Working with spawners and triggers
- 📖 [Object System](/guides/object-system) - Understanding opaque types
- 🎓 [Teams Tutorial](/tutorials/teams-tutorial) - Hands-on team mechanics
- 📚 [API Reference](/api/teams-scoring) - Complete teams API

---

::: tip Team & Player Summary
- **9 teams available** (Team1-Team9)
- **Assign on join** - Use `OnPlayerJoinGame` hook
- **Balance automatically** - Check team sizes
- **Track scores** - Both team and individual
- **Custom properties** - Use custom data structures
- **Clear victory conditions** - Score, elimination, or time-based
:::
