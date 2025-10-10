# Your First Game Mode

Create a simple Team Deathmatch mode from scratch in 20 minutes.

**Difficulty:** ★☆☆☆☆ | **Time:** 20 minutes | **Prerequisites:** SDK installed

---

## What You'll Build

A functional Team Deathmatch (TDM) game mode with:
- 2 teams (Team 1 vs Team 2)
- Automatic team assignment
- Score tracking (kills count toward team score)
- Victory condition (first team to 50 kills wins)
- Player respawn system

---

## Step 1: Create Your Mod Folder

First, create a new directory for your game mode:

```bash
cd /path/to/PortalSDK/mods
mkdir MyFirstTDM
cd MyFirstTDM
```

---

## Step 2: Create the TypeScript File

Create a file named `index.ts` in your mod folder:

```typescript
// MyFirstTDM/index.ts
import * as mod from 'bf-portal-api';
import * as modlib from '../modlib';

// Game configuration
const WINNING_SCORE = 50;
const RESPAWN_TIME = 5; // seconds

// Team assignment tracking
let team1Count = 0;
let team2Count = 0;

/**
 * Called once when the game mode starts
 */
export async function OnGameModeStarted() {
  console.log("Team Deathmatch started!");

  // Set team names and colors
  mod.SetTeamName(mod.Team.Team1, mod.Message("Red Team"));
  mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);

  mod.SetTeamName(mod.Team.Team2, mod.Message("Blue Team"));
  mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);

  // Set victory condition
  mod.SetGameModeScoreToWin(WINNING_SCORE);

  // Allow players to join
  mod.EnablePlayerJoin();
}

/**
 * Called when a player joins the game
 */
export async function OnPlayerJoinGame(player: mod.Player) {
  console.log(`Player ${mod.GetPlayerName(player)} joined`);

  // Assign to team with fewer players
  const assignedTeam = assignTeam();
  mod.SetTeam(player, assignedTeam);

  // Initialize player score
  mod.SetGameModeScore(player, 0);

  // Deploy the player
  mod.DeployPlayer(player);

  // Show welcome message
  mod.DisplayCustomNotificationMessage(
    mod.Message(`Welcome to Team Deathmatch!`),
    mod.CustomNotificationSlots.HeaderText,
    5,
    player
  );
}

/**
 * Called when a player deploys (spawns into the game)
 */
export async function OnPlayerDeployed(player: mod.Player) {
  console.log(`Player ${mod.GetPlayerName(player)} deployed`);

  // Give player basic equipment
  mod.AddEquipment(player, mod.Weapons.AK_24, 1);
  mod.AddEquipment(player, mod.Gadgets.Medkit, 1);
}

/**
 * Called when a player dies
 */
export async function OnPlayerDied(player: mod.Player) {
  console.log(`Player ${mod.GetPlayerName(player)} died`);

  // Wait for respawn time
  await mod.Wait(RESPAWN_TIME);

  // Revive and redeploy
  mod.Revive(player);
  mod.DeployPlayer(player);
}

/**
 * Called when a player gets a kill
 */
export async function OnPlayerEarnedKill(
  player: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  console.log(`${mod.GetPlayerName(player)} killed ${mod.GetPlayerName(victim)}`);

  // Add 1 point to killer's team score
  const team = mod.GetTeam(player);
  const currentScore = mod.GetGameModeScore(team);
  mod.SetGameModeScore(team, currentScore + 1);

  // Add 1 to player's personal score
  const playerScore = mod.GetGameModeScore(player);
  mod.SetGameModeScore(player, playerScore + 1);

  // Check for victory
  if (currentScore + 1 >= WINNING_SCORE) {
    mod.SetWinningTeam(team);
    mod.EndGameMode(team);
  }
}

/**
 * Called when a player leaves the game
 */
export async function OnPlayerLeaveGame(playerId: string) {
  console.log(`Player ${playerId} left the game`);
}

/**
 * Helper function: Assign player to team with fewer players
 */
function assignTeam(): mod.Team {
  if (team1Count <= team2Count) {
    team1Count++;
    return mod.Team.Team1;
  } else {
    team2Count++;
    return mod.Team.Team2;
  }
}
```

---

## Step 3: Understanding the Code

Let's break down what each part does:

### Event Hooks

The SDK calls these functions automatically at specific times:

- **OnGameModeStarted()** - Runs once when the server starts
- **OnPlayerJoinGame()** - Runs when a player connects
- **OnPlayerDeployed()** - Runs when a player spawns
- **OnPlayerDied()** - Runs when a player dies
- **OnPlayerEarnedKill()** - Runs when a player gets a kill

### Game Setup (OnGameModeStarted)

```typescript
mod.SetTeamName(mod.Team.Team1, mod.Message("Red Team"));
mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);
```

This sets the team's display name and color.

```typescript
mod.SetGameModeScoreToWin(WINNING_SCORE);
```

This tells the game to end when a team reaches 50 kills.

### Player Join (OnPlayerJoinGame)

```typescript
const assignedTeam = assignTeam();
mod.SetTeam(player, assignedTeam);
```

Assigns the player to the team with fewer players for balance.

```typescript
mod.DeployPlayer(player);
```

Spawns the player into the game world.

### Respawn System (OnPlayerDied)

```typescript
await mod.Wait(RESPAWN_TIME);
mod.Revive(player);
mod.DeployPlayer(player);
```

Waits 5 seconds, then revives and respawns the player.

### Scoring (OnPlayerEarnedKill)

```typescript
const currentScore = mod.GetGameModeScore(team);
mod.SetGameModeScore(team, currentScore + 1);
```

Increments the team's score by 1 for each kill.

---

## Step 4: Create a Spatial Layout

You need a `.spatial.json` file that defines the map. The easiest way is to use one of the existing maps:

**Option 1: Use an Existing Map**

Copy a spatial file from the SDK:

```bash
cp ../PortalSDK/FbExportData/levels/MP_Dumbo.spatial.json ./level.spatial.json
```

**Option 2: Create in Godot** (Advanced)

1. Open Godot editor
2. Open `GodotProject/levels/MP_Dumbo.tscn`
3. Click "Export Current Level" in BFPortal tab
4. Save as `level.spatial.json`

For this tutorial, using an existing map is fine.

---

## Step 5: Test Your Game Mode

### Upload to Portal

1. Go to https://portal.battlefield.com
2. Log in with your credentials
3. Create a new experience
4. Upload `level.spatial.json` for spatial layout
5. Paste the contents of `index.ts` for game logic
6. Publish and test!

### What to Test

✅ **Players can join** - Connect with multiple accounts
✅ **Teams are balanced** - Players split evenly between teams
✅ **Kills count** - Score increases when you get kills
✅ **Respawning works** - You respawn after 5 seconds
✅ **Victory condition** - Game ends when a team hits 50 kills

---

## Step 6: Common Issues & Fixes

### Issue: Players don't spawn

**Cause:** No spawn points in the map.

**Fix:** Make sure your `.spatial.json` includes spawn points, or use a default map that has them (like MP_Dumbo).

---

### Issue: Teams are unbalanced

**Cause:** `assignTeam()` logic not working correctly.

**Fix:** Add console.log statements to debug:

```typescript
function assignTeam(): mod.Team {
  console.log(`Team counts: Team1=${team1Count}, Team2=${team2Count}`);
  if (team1Count <= team2Count) {
    team1Count++;
    console.log(`Assigned to Team1`);
    return mod.Team.Team1;
  } else {
    team2Count++;
    console.log(`Assigned to Team2`);
    return mod.Team.Team2;
  }
}
```

---

### Issue: Score doesn't increase

**Cause:** `OnPlayerEarnedKill` not firing or scoring logic wrong.

**Fix:** Add debugging:

```typescript
export async function OnPlayerEarnedKill(player: mod.Player, victim: mod.Player) {
  const team = mod.GetTeam(player);
  const currentScore = mod.GetGameModeScore(team);
  console.log(`Kill! Team score before: ${currentScore}`);

  mod.SetGameModeScore(team, currentScore + 1);

  const newScore = mod.GetGameModeScore(team);
  console.log(`Team score after: ${newScore}`);
}
```

---

## Step 7: Enhancements

Now that you have a basic TDM mode working, try these improvements:

### Add Kill Notifications

```typescript
export async function OnPlayerEarnedKill(player: mod.Player, victim: mod.Player) {
  // ... existing code ...

  // Show notification to killer
  mod.DisplayCustomNotificationMessage(
    mod.Message(`You killed ${mod.GetPlayerName(victim)}!`),
    mod.CustomNotificationSlots.MessageText1,
    3,
    player
  );
}
```

### Add Score HUD

```typescript
// In OnPlayerDeployed
const scoreWidget = mod.AddUIContainer(
  "scoreHUD",
  mod.CreateVector(10, 10, 0),
  mod.CreateVector(200, 50, 0),
  mod.UIAnchor.TopLeft,
  null,
  true,
  5,
  mod.CreateVector(0, 0, 0),
  0.8,
  mod.UIBgFill.Solid,
  player
);

mod.AddUIText(
  "scoreText",
  mod.Message(`Score: 0`),
  mod.CreateVector(0, 0, 0),
  mod.CreateVector(200, 50, 0),
  mod.UIAnchor.TopLeft,
  scoreWidget,
  true,
  20,
  mod.CreateVector(1, 1, 1),
  1.0,
  player
);
```

### Add Time Limit

```typescript
export async function OnGameModeStarted() {
  // ... existing code ...

  mod.SetGameTimeLimit(600); // 10 minutes = 600 seconds
}
```

---

## Next Steps

Congratulations! You've created your first Portal game mode. 🎉

### Continue Learning

- **[Understanding Event Hooks](/tutorials/event-hooks-tutorial)** - Deep dive into all 7 event hooks
- **[Building a Simple UI](/tutorials/simple-ui)** - Create HUD elements
- **[Working with Teams](/tutorials/teams-tutorial)** - Advanced team management

### Explore Examples

- **[Vertigo](/examples/vertigo)** - Simple team-based racing mode
- **[BombSquad](/examples/bombsquad)** - Advanced round-based TDM variant

### API Reference

- **[Player Control](/api/player-control)** - All player functions
- **[Teams & Scoring](/api/teams-scoring)** - Team management functions
- **[Game Mode](/api/game-mode)** - Game mode lifecycle functions

---

★ Insight ─────────────────────────────────────
**Event-Driven Architecture**
1. **Hook System** - Portal game modes are entirely event-driven; all game logic runs in response to SDK hooks firing
2. **Async by Default** - All hooks are `async` functions allowing use of `await mod.Wait()` for delays without blocking
3. **State Persistence** - Global variables (like team counts) persist across hook calls, enabling stateful game logic
─────────────────────────────────────────────────
