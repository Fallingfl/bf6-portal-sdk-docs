# Working with Teams

Learn team management, auto-balancing, and team-based gameplay mechanics.

**Difficulty:** ★★☆☆☆ | **Time:** 20 minutes | **Prerequisites:** Basic event hooks knowledge

---

## What You'll Build

A 2-team game mode with:
- **Automatic team balancing** - Players distributed evenly
- **Team scoring** - Kills contribute to team score
- **Team-specific loadouts** - Different weapons per team
- **Victory condition** - First team to 100 points wins

---

## Understanding Teams

Portal supports up to **9 teams** (`Team1` through `Team9`) plus individual players.

```typescript
// Available teams
mod.Team.Team1
mod.Team.Team2
mod.Team.Team3
// ... up to Team9
```

---

## Step 1: Basic Team Assignment

The simplest approach: alternate players between Team1 and Team2.

```typescript
import * as mod from 'bf-portal-api';

let playerCount = 0;

export async function OnPlayerJoinGame(player: mod.Player) {
  playerCount++;

  // Assign alternating teams
  const team = playerCount % 2 === 0 ? mod.Team.Team1 : mod.Team.Team2;
  mod.SetTeam(player, team);

  console.log(`Assigned ${mod.GetPlayerName(player)} to ${team}`);

  // Deploy player
  mod.DeployPlayer(player);
}
```

**Problem:** If Player 1 leaves, teams become unbalanced (3v2 instead of 3v3).

---

## Step 2: Auto-Balancing Teams

Track team sizes and assign to the smaller team.

```typescript
let team1Count = 0;
let team2Count = 0;

export async function OnPlayerJoinGame(player: mod.Player) {
  // Assign to team with fewer players
  let assignedTeam: mod.Team;

  if (team1Count <= team2Count) {
    assignedTeam = mod.Team.Team1;
    team1Count++;
  } else {
    assignedTeam = mod.Team.Team2;
    team2Count++;
  }

  mod.SetTeam(player, assignedTeam);

  console.log(`Team counts: Team1=${team1Count}, Team2=${team2Count}`);

  mod.DeployPlayer(player);
}

export async function OnPlayerLeaveGame(playerId: string) {
  // Decrement team count
  // NOTE: We don't have the Player object here, only the playerId string
  // Need to track which team they were on
}
```

**Problem:** We lose track of which team a player was on when they leave.

---

## Step 3: Proper Team Tracking

Store player-team associations to handle disconnects.

```typescript
const playerTeams = new Map<string, mod.Team>();  // playerId -> Team

export async function OnPlayerJoinGame(player: mod.Player) {
  const playerId = mod.GetPlayerId(player);

  // Count current players in each team
  const team1Players = modlib.ConvertArray(mod.GetPlayersInTeam(mod.Team.Team1));
  const team2Players = modlib.ConvertArray(mod.GetPlayersInTeam(mod.Team.Team2));

  // Assign to smaller team
  const assignedTeam = team1Players.length <= team2Players.length
    ? mod.Team.Team1
    : mod.Team.Team2;

  mod.SetTeam(player, assignedTeam);

  // Track assignment
  playerTeams.set(playerId, assignedTeam);

  console.log(`Assigned to ${assignedTeam}. Team sizes: ${team1Players.length + 1} vs ${team2Players.length}`);

  mod.DeployPlayer(player);
}

export async function OnPlayerLeaveGame(playerId: string) {
  const team = playerTeams.get(playerId);

  if (team) {
    console.log(`Player left from ${team}`);
    playerTeams.delete(playerId);
  }
}
```

---

## Step 4: Configure Team Appearance

Set team names and colors.

```typescript
export async function OnGameModeStarted() {
  // Team 1 - Red (Attackers)
  mod.SetTeamName(mod.Team.Team1, mod.Message("Attackers"));
  mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);

  // Team 2 - Blue (Defenders)
  mod.SetTeamName(mod.Team.Team2, mod.Message("Defenders"));
  mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);

  // Available team colors:
  // Red, Blue, Green, Yellow, Orange, Purple, Pink, Teal, Gray,
  // White, Black, Brown, LightBlue, DarkGreen
}
```

---

## Step 5: Team-Based Scoring

Award points to the killer's team.

```typescript
export async function OnPlayerEarnedKill(player: mod.Player, victim: mod.Player) {
  // Get killer's team
  const team = mod.GetTeam(player);

  // Increment team score
  const currentScore = mod.GetGameModeScore(team);
  mod.SetGameModeScore(team, currentScore + 1);

  console.log(`${team} score: ${currentScore + 1}`);

  // Check for victory
  if (currentScore + 1 >= 100) {
    mod.SetWinningTeam(team);
    mod.EndGameMode(team);
  }
}
```

---

## Step 6: Team-Specific Loadouts

Give different weapons to each team.

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  const team = mod.GetTeam(player);

  if (team === mod.Team.Team1) {
    // Attackers: Assault loadout
    mod.AddEquipment(player, mod.Weapons.M5A3, 1);
    mod.AddEquipment(player, mod.Gadgets.Frag_Grenade, 1);
    mod.AddEquipment(player, mod.Gadgets.Medkit, 1);
  } else if (team === mod.Team.Team2) {
    // Defenders: Support loadout
    mod.AddEquipment(player, mod.Weapons.PKP_BP, 1);
    mod.AddEquipment(player, mod.Gadgets.Ammo_Crate, 1);
    mod.AddEquipment(player, mod.Gadgets.Deployable_Shield, 1);
  }
}
```

---

## Step 7: Team-Specific Spawn Points

Spawn teams in different locations.

```typescript
let team1Spawners: mod.Spawner[] = [];
let team2Spawners: mod.Spawner[] = [];

export async function OnGameModeStarted() {
  // Get spawners by ID (set in Godot editor)
  team1Spawners = [
    mod.GetSpawner(1),
    mod.GetSpawner(2),
    mod.GetSpawner(3)
  ];

  team2Spawners = [
    mod.GetSpawner(4),
    mod.GetSpawner(5),
    mod.GetSpawner(6)
  ];
}

export async function OnPlayerDeployed(player: mod.Player) {
  const team = mod.GetTeam(player);

  // Select random spawner for player's team
  let spawners = team === mod.Team.Team1 ? team1Spawners : team2Spawners;
  let randomSpawner = spawners[Math.floor(Math.random() * spawners.length)];

  // Get spawn position
  const spawnPos = mod.GetSpawnerTransform(randomSpawner).position;
  const spawnRot = mod.GetSpawnerTransform(randomSpawner).rotation;

  // Teleport player to team spawn
  mod.TeleportPlayer(player, spawnPos, spawnRot);

  // Give team loadout
  giveTeamLoadout(player);
}

function giveTeamLoadout(player: mod.Player) {
  const team = mod.GetTeam(player);

  if (team === mod.Team.Team1) {
    mod.AddEquipment(player, mod.Weapons.M5A3, 1);
  } else {
    mod.AddEquipment(player, mod.Weapons.AK_24, 1);
  }
}
```

---

## Complete Example: 2v2 TDM

Here's a full implementation combining all concepts:

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from '../modlib';

const WINNING_SCORE = 50;
const RESPAWN_TIME = 5;

const playerTeams = new Map<string, mod.Team>();

export async function OnGameModeStarted() {
  console.log("Team Deathmatch - 2v2");

  // Configure teams
  mod.SetTeamName(mod.Team.Team1, mod.Message("Red Team"));
  mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);

  mod.SetTeamName(mod.Team.Team2, mod.Message("Blue Team"));
  mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);

  // Set victory condition
  mod.SetGameModeScoreToWin(WINNING_SCORE);

  mod.EnablePlayerJoin();
}

export async function OnPlayerJoinGame(player: mod.Player) {
  const playerId = mod.GetPlayerId(player);

  // Auto-balance
  const team1 = modlib.ConvertArray(mod.GetPlayersInTeam(mod.Team.Team1));
  const team2 = modlib.ConvertArray(mod.GetPlayersInTeam(mod.Team.Team2));

  const assignedTeam = team1.length <= team2.length ? mod.Team.Team1 : mod.Team.Team2;

  mod.SetTeam(player, assignedTeam);
  playerTeams.set(playerId, assignedTeam);

  mod.SetGameModeScore(player, 0);
  mod.DeployPlayer(player);

  // Welcome message
  mod.DisplayCustomNotificationMessage(
    mod.Message(`Welcome to ${mod.GetTeamName(assignedTeam)}!`),
    mod.CustomNotificationSlots.HeaderText,
    5,
    player
  );
}

export async function OnPlayerDeployed(player: mod.Player) {
  const team = mod.GetTeam(player);

  // Team-specific loadout
  if (team === mod.Team.Team1) {
    mod.AddEquipment(player, mod.Weapons.M5A3, 1);
  } else {
    mod.AddEquipment(player, mod.Weapons.AK_24, 1);
  }

  mod.AddEquipment(player, mod.Gadgets.Medkit, 1);
}

export async function OnPlayerDied(player: mod.Player) {
  await mod.Wait(RESPAWN_TIME);
  mod.Revive(player);
  mod.DeployPlayer(player);
}

export async function OnPlayerEarnedKill(player: mod.Player, victim: mod.Player) {
  const team = mod.GetTeam(player);

  // Team score
  const teamScore = mod.GetGameModeScore(team);
  mod.SetGameModeScore(team, teamScore + 1);

  // Player score
  const playerScore = mod.GetGameModeScore(player);
  mod.SetGameModeScore(player, playerScore + 1);

  // Check victory
  if (teamScore + 1 >= WINNING_SCORE) {
    mod.SetWinningTeam(team);
    mod.EndGameMode(team);
  }
}

export async function OnPlayerLeaveGame(playerId: string) {
  playerTeams.delete(playerId);
}
```

---

## Advanced: 4-Team Free-For-All

```typescript
const TEAMS = [mod.Team.Team1, mod.Team.Team2, mod.Team.Team3, mod.Team.Team4];
const TEAM_COLORS = [mod.TeamColor.Red, mod.TeamColor.Blue, mod.TeamColor.Green, mod.TeamColor.Yellow];
const TEAM_NAMES = ["Red Squad", "Blue Squad", "Green Squad", "Yellow Squad"];

export async function OnGameModeStarted() {
  // Configure 4 teams
  for (let i = 0; i < 4; i++) {
    mod.SetTeamName(TEAMS[i], mod.Message(TEAM_NAMES[i]));
    mod.SetTeamColor(TEAMS[i], TEAM_COLORS[i]);
  }
}

export async function OnPlayerJoinGame(player: mod.Player) {
  // Find team with fewest players
  let smallestTeam = TEAMS[0];
  let smallestSize = modlib.ConvertArray(mod.GetPlayersInTeam(TEAMS[0])).length;

  for (let i = 1; i < TEAMS.length; i++) {
    const size = modlib.ConvertArray(mod.GetPlayersInTeam(TEAMS[i])).length;
    if (size < smallestSize) {
      smallestTeam = TEAMS[i];
      smallestSize = size;
    }
  }

  mod.SetTeam(player, smallestTeam);
  mod.DeployPlayer(player);
}
```

---

## Best Practices

### ✅ DO:

- **Use `GetPlayersInTeam()`** for accurate team sizes
- **Track player-team associations** by playerId for disconnect handling
- **Give visual team indicators** (colors, names, HUD elements)
- **Test team balance** with multiple players

### ❌ DON'T:

- **Hard-code team sizes** - use dynamic balancing
- **Forget to handle disconnects** - teams can become unbalanced
- **Mix team/player scoring** - be clear what score represents what
- **Skip team configuration** - default team names are confusing

---

## Common Patterns

### Team Size Limits

```typescript
const MAX_TEAM_SIZE = 8;

export async function OnPlayerJoinGame(player: mod.Player) {
  const team1Size = modlib.ConvertArray(mod.GetPlayersInTeam(mod.Team.Team1)).length;
  const team2Size = modlib.ConvertArray(mod.GetPlayersInTeam(mod.Team.Team2)).length;

  if (team1Size >= MAX_TEAM_SIZE && team2Size >= MAX_TEAM_SIZE) {
    // Both teams full - kick player or make spectator
    mod.DisplayCustomNotificationMessage(
      mod.Message("Server full!"),
      mod.CustomNotificationSlots.HeaderText,
      5,
      player
    );
    return;
  }

  const assignedTeam = team1Size <= team2Size ? mod.Team.Team1 : mod.Team.Team2;
  mod.SetTeam(player, assignedTeam);
  mod.DeployPlayer(player);
}
```

### Team Switching Mid-Game

```typescript
let switchAllowed = true;

export async function OnPlayerSwitchTeam(player: mod.Player, newTeam: mod.Team) {
  if (!switchAllowed) {
    // Prevent switching
    const oldTeam = mod.GetTeam(player);
    mod.SetTeam(player, oldTeam);  // Revert

    mod.DisplayCustomNotificationMessage(
      mod.Message("Team switching is disabled!"),
      mod.CustomNotificationSlots.MessageText1,
      3,
      player
    );
  }
}
```

---

## Next Steps

- **[Checkpoint System](/tutorials/checkpoint-system)** - Team-based checkpoint racing
- **[Round-Based Systems](/tutorials/round-based)** - Team switching between rounds
- **[Complex UI Layouts](/tutorials/complex-ui)** - Team scoreboards

---

★ Insight ─────────────────────────────────────
**Team Balance Design**
1. **Dynamic Sizing** - Using `GetPlayersInTeam()` ensures accurate counts even after disconnects, avoiding manual tracking errors
2. **ID-Based Tracking** - Storing associations by playerId string (not Player object) enables cleanup in OnPlayerLeaveGame where objects no longer exist
3. **Per-Team Resources** - Team-specific spawners, loadouts, and colors provide clear identity and tactical asymmetry
─────────────────────────────────────────────────
