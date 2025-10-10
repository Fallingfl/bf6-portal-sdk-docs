# modlib - Helper Library

The `modlib` library provides **720 lines** of utility functions that simplify common Portal scripting tasks. Located at `code/modlib/index.ts`, it wraps complex Portal API calls with easier-to-use functions.

## Importing modlib

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';
```

::: tip Why Use modlib?
- **Simpler arrays** - Convert Portal arrays to JavaScript arrays
- **Easy UI building** - Declarative JSON syntax instead of verbose API calls
- **State tracking** - Per-player, per-team, per-vehicle condition management
- **Better notifications** - Cleaner notification display functions
- **Less boilerplate** - Common patterns already implemented
:::

---

## Array Operations

### ConvertArray

Convert Portal's `mod.Array` to JavaScript array for easier manipulation.

```typescript
function ConvertArray(array: mod.Array): any[]
```

**Why You Need This:**
Portal's `mod.Array` requires `CountOf()` and `ValueInArray()` to access elements. JavaScript arrays give you `.length`, `.forEach()`, `.map()`, `.filter()`, etc.

**Example:**

```typescript
// Without modlib (verbose)
const portalArray = mod.AllPlayers();
const count = mod.CountOf(portalArray);
const players: mod.Player[] = [];
for (let i = 0; i < count; i++) {
  players.push(mod.ValueInArray(portalArray, i) as mod.Player);
}

// With modlib (clean)
const players = modlib.ConvertArray(mod.AllPlayers());

// Now use normal JavaScript array methods
players.forEach(player => {
  console.log(mod.GetPlayerName(player));
});

const alivePlayers = players.filter(p => !mod.IsPlayerDead(p));
const playerCount = players.length;  // Simple!
```

---

### FilteredArray

Filter Portal array based on condition.

```typescript
function FilteredArray(
  array: mod.Array,
  condition: (element: any) => boolean
): mod.Array
```

**Example:**

```typescript
// Get only alive players
const allPlayers = mod.AllPlayers();
const alivePlayersArray = modlib.FilteredArray(
  allPlayers,
  (player) => !mod.IsPlayerDead(player)
);

// Get players on specific team
const team1PlayersArray = modlib.FilteredArray(
  allPlayers,
  (player) => mod.GetTeam(player) === mod.Team.Team1
);
```

::: tip Modern Alternative
If you've already converted to JS array, use built-in `.filter()`:
```typescript
const players = modlib.ConvertArray(mod.AllPlayers());
const alivePlayers = players.filter(p => !mod.IsPlayerDead(p));
```
:::

---

### IsTrueForAll

Check if condition is true for every element (like `Array.every()`).

```typescript
function IsTrueForAll(
  array: mod.Array,
  condition: (element: any, arg: any) => boolean,
  arg?: any
): boolean
```

**Example:**

```typescript
const allPlayers = mod.AllPlayers();

// Check if all players are dead
const everyoneDead = modlib.IsTrueForAll(
  allPlayers,
  (player) => mod.IsPlayerDead(player)
);

if (everyoneDead) {
  console.log("Round over - all players eliminated");
}

// Check if all players are on same team
const allSameTeam = modlib.IsTrueForAll(
  allPlayers,
  (player, team) => mod.GetTeam(player) === team,
  mod.Team.Team1  // arg parameter
);
```

---

### IsTrueForAny

Check if condition is true for at least one element (like `Array.some()`).

```typescript
function IsTrueForAny(
  array: mod.Array,
  condition: (element: any, arg: any) => boolean,
  arg?: any
): boolean
```

**Example:**

```typescript
const allPlayers = mod.AllPlayers();

// Check if anyone is alive
const someoneAlive = modlib.IsTrueForAny(
  allPlayers,
  (player) => !mod.IsPlayerDead(player)
);

// Check if anyone on Team1 is alive
const team1Alive = modlib.IsTrueForAny(
  allPlayers,
  (player, team) => {
    return mod.GetTeam(player) === team && !mod.IsPlayerDead(player);
  },
  mod.Team.Team1
);
```

---

### SortedArray

Sort JavaScript array with custom compare function.

```typescript
function SortedArray(
  array: any[],
  compare: (a: any, b: any) => number
): any[]
```

**Example:**

```typescript
const players = modlib.ConvertArray(mod.AllPlayers());

// Sort by score (highest first)
const sortedByScore = modlib.SortedArray(players, (a, b) => {
  const scoreA = mod.GetPlayerScore(a);
  const scoreB = mod.GetPlayerScore(b);
  return scoreB - scoreA;  // Descending order
});

// Sort by name alphabetically
const sortedByName = modlib.SortedArray(players, (a, b) => {
  const nameA = mod.GetPlayerName(a);
  const nameB = mod.GetPlayerName(b);
  return nameA.localeCompare(nameB);
});

console.log("Top player:", mod.GetPlayerName(sortedByScore[0]));
```

---

### IndexOfFirstTrue

Find index of first element matching condition.

```typescript
function IndexOfFirstTrue(
  array: mod.Array,
  condition: (element: any, arg: any) => boolean,
  arg?: any
): number
```

**Returns:** Index of first match, or `-1` if not found

**Example:**

```typescript
const allPlayers = mod.AllPlayers();

// Find first dead player
const firstDeadIndex = modlib.IndexOfFirstTrue(
  allPlayers,
  (player) => mod.IsPlayerDead(player)
);

if (firstDeadIndex !== -1) {
  const deadPlayer = mod.ValueInArray(allPlayers, firstDeadIndex);
  console.log(`First dead player: ${mod.GetPlayerName(deadPlayer)}`);
}
```

---

## Team Utilities

### getPlayersInTeam

Get all players on a specific team as JavaScript array.

```typescript
function getPlayersInTeam(team: mod.Team): mod.Player[]
```

**Example:**

```typescript
// Get Team1 players
const team1 = modlib.getPlayersInTeam(mod.Team.Team1);
console.log(`Team 1 has ${team1.length} players`);

team1.forEach(player => {
  console.log(mod.GetPlayerName(player));
});

// Count alive players per team
function countAlivePerTeam() {
  const team1 = modlib.getPlayersInTeam(mod.Team.Team1);
  const team2 = modlib.getPlayersInTeam(mod.Team.Team2);

  const team1Alive = team1.filter(p => !mod.IsPlayerDead(p)).length;
  const team2Alive = team2.filter(p => !mod.IsPlayerDead(p)).length;

  console.log(`Team 1: ${team1Alive} alive, Team 2: ${team2Alive} alive`);
}
```

---

## ID Utilities

### getPlayerId

Get unique ID for a player.

```typescript
function getPlayerId(player: mod.Player): number
```

**Example:**

```typescript
const playerId = modlib.getPlayerId(player);
console.log(`Player ID: ${playerId}`);

// Use for tracking/indexing
const playerScores: { [id: number]: number } = {};
playerScores[modlib.getPlayerId(player)] = 100;
```

---

### getTeamId

Get unique ID for a team.

```typescript
function getTeamId(team: mod.Team): number
```

**Example:**

```typescript
const teamId = modlib.getTeamId(mod.Team.Team1);
console.log(`Team ID: ${teamId}`);

// Track team scores
const teamScores: { [id: number]: number } = {};
teamScores[modlib.getTeamId(mod.Team.Team1)] = 500;
teamScores[modlib.getTeamId(mod.Team.Team2)] = 300;
```

---

## Condition State Tracking

The most powerful feature of modlib is **state tracking**. These functions detect when conditions **transition** from false to true, preventing duplicate triggers.

### ConditionState Class

Tracks state changes for edge-triggered events.

```typescript
class ConditionState {
  update(newState: boolean): boolean
}
```

**How It Works:**
- First call with `true` → returns `true` (trigger!)
- Subsequent calls with `true` → returns `false` (already triggered)
- Call with `false` → resets state
- Next call with `true` → returns `true` again (new trigger!)

**Example:**

```typescript
const doorOpen = new modlib.ConditionState();

// Game loop
export async function OngoingGlobal() {
  while (true) {
    const isDoorNearby = checkIfPlayerNearDoor();

    // Only triggers ONCE when player gets close
    if (doorOpen.update(isDoorNearby)) {
      console.log("Door opened!");
      openDoor();
    }

    // When player walks away, isDoorNearby becomes false
    // Next time they approach, it will trigger again

    await mod.Wait(0.5);
  }
}
```

---

### getPlayerCondition

Get condition state tracker for a specific player.

```typescript
function getPlayerCondition(
  player: mod.Player,
  conditionNumber: number
): ConditionState
```

**Parameters:**
- `player` - The player to track
- `conditionNumber` - Unique number for this condition (0, 1, 2, etc.)

**Example:**

```typescript
const CONDITION_IN_ZONE = 0;
const CONDITION_HAS_FLAG = 1;
const CONDITION_LOW_HEALTH = 2;

export async function OngoingGlobal() {
  const players = modlib.ConvertArray(mod.AllPlayers());

  while (true) {
    for (const player of players) {
      // Check if player just entered zone
      const inZone = isPlayerInZone(player);
      const zoneCondition = modlib.getPlayerCondition(player, CONDITION_IN_ZONE);

      if (zoneCondition.update(inZone)) {
        modlib.DisplayCustomNotificationMessage(
          mod.Message("Entered zone!"),
          mod.CustomNotificationSlots.MessageText1,
          2,
          player
        );
      }

      // Check if player just picked up flag
      const hasFlag = playerHasFlag(player);
      const flagCondition = modlib.getPlayerCondition(player, CONDITION_HAS_FLAG);

      if (flagCondition.update(hasFlag)) {
        modlib.DisplayCustomNotificationMessage(
          mod.Message("Flag captured!"),
          mod.CustomNotificationSlots.MessageText1,
          3,
          player
        );
      }
    }

    await mod.Wait(0.5);
  }
}
```

---

### getTeamCondition

Get condition state tracker for a specific team.

```typescript
function getTeamCondition(
  team: mod.Team,
  conditionNumber: number
): ConditionState
```

**Example:**

```typescript
const TEAM_WON_ROUND = 0;
const TEAM_LOST_OBJECTIVE = 1;

export async function checkTeamConditions() {
  const team1 = mod.Team.Team1;

  // Check if Team1 just won
  const team1Won = checkIfTeamWon(team1);
  const winCondition = modlib.getTeamCondition(team1, TEAM_WON_ROUND);

  if (winCondition.update(team1Won)) {
    // Triggers only once when team wins
    modlib.ShowEventGameModeMessage(
      mod.Message("Team 1 wins!")
    );
  }
}
```

---

### getVehicleCondition

Get condition state tracker for a specific vehicle.

```typescript
function getVehicleCondition(
  vehicle: mod.Vehicle,
  conditionNumber: number
): ConditionState
```

**Example:**

```typescript
const VEHICLE_DAMAGED = 0;
const VEHICLE_STOLEN = 1;

export async function monitorVehicles() {
  const vehicles = getAllVehicles();  // Custom tracking

  while (true) {
    for (const vehicle of vehicles) {
      // Check if vehicle just got damaged
      const isDamaged = mod.GetVehicleHealth(vehicle) < 50;
      const damageCondition = modlib.getVehicleCondition(vehicle, VEHICLE_DAMAGED);

      if (damageCondition.update(isDamaged)) {
        console.log("Vehicle is now damaged!");
        // Trigger repair notification or spawn repair kit
      }
    }

    await mod.Wait(1);
  }
}
```

---

### getCapturePointCondition

Track condition for capture points.

```typescript
function getCapturePointCondition(
  capturePoint: mod.CapturePoint,
  conditionNumber: number
): ConditionState
```

---

### getMCOMCondition

Track condition for MCOM objectives.

```typescript
function getMCOMCondition(
  mcom: mod.MCOM,
  conditionNumber: number
): ConditionState
```

---

### getGlobalCondition

Get global condition state tracker (not tied to any object).

```typescript
function getGlobalCondition(conditionNumber: number): ConditionState
```

**Example:**

```typescript
const GAME_STARTED = 0;
const ROUND_ENDING = 1;

export async function OngoingGlobal() {
  while (true) {
    const roundEnding = checkIfRoundEnding();
    const endingCondition = modlib.getGlobalCondition(ROUND_ENDING);

    if (endingCondition.update(roundEnding)) {
      // Triggers once when round starts ending
      console.log("Round is ending!");
      startEndGameSequence();
    }

    await mod.Wait(0.5);
  }
}
```

---

## UI Builder

### ParseUI

Create UI from declarative JSON object instead of verbose API calls.

```typescript
function ParseUI(...params: UIParams[]): mod.UIWidget | undefined
```

**Why Use This:**
Compare building UI the normal way vs. with `ParseUI`:

<table>
<tr>
<th>Normal API (Verbose)</th>
<th>ParseUI (Clean)</th>
</tr>
<tr>
<td>

```typescript
mod.AddUIContainer(
  "MainContainer",
  mod.CreateVector(10, 10, 0),
  mod.CreateVector(300, 200, 0),
  mod.UIAnchor.TopLeft,
  mod.GetUIRoot(),
  true,
  8,
  mod.CreateVector(0.2, 0.2, 0.2),
  0.8,
  mod.UIBgFill.Solid
);

const container = mod.FindUIWidgetWithName("MainContainer");

mod.AddUIText(
  "ScoreText",
  mod.CreateVector(0, 0, 0),
  mod.CreateVector(300, 50, 0),
  mod.UIAnchor.TopCenter,
  container,
  true,
  8,
  mod.CreateVector(0, 0, 0),
  0,
  mod.UIBgFill.None,
  mod.Message("Score: 100"),
  24,
  mod.CreateVector(1, 1, 1),
  1,
  mod.UIAnchor.Center
);
```

</td>
<td>

```typescript
modlib.ParseUI({
  type: "Container",
  name: "MainContainer",
  position: [10, 10],
  size: [300, 200],
  bgColor: [0.2, 0.2, 0.2],
  bgAlpha: 0.8,
  children: [
    {
      type: "Text",
      name: "ScoreText",
      position: [0, 0],
      size: [300, 50],
      textLabel: "Score: 100",
      textSize: 24,
      textColor: [1, 1, 1],
      anchor: mod.UIAnchor.TopCenter
    }
  ]
});
```

</td>
</tr>
</table>

**Full Example:**

```typescript
// Build scoreboard UI
modlib.ParseUI({
  type: "Container",
  name: "Scoreboard",
  position: [10, 10],
  size: [400, 300],
  anchor: mod.UIAnchor.TopLeft,
  bgColor: [0.1, 0.1, 0.1],
  bgAlpha: 0.9,
  bgFill: mod.UIBgFill.Solid,
  children: [
    // Header
    {
      type: "Text",
      position: [0, 10],
      size: [400, 40],
      textLabel: "SCOREBOARD",
      textSize: 32,
      textColor: [1, 1, 0],
      textAnchor: mod.UIAnchor.Center,
      bgFill: mod.UIBgFill.None
    },
    // Player 1 score
    {
      type: "Text",
      position: [20, 60],
      size: [360, 30],
      textLabel: "Player 1: 500",
      textSize: 20,
      textColor: [1, 1, 1],
      bgFill: mod.UIBgFill.None
    },
    // Player 2 score
    {
      type: "Text",
      position: [20, 100],
      size: [360, 30],
      textLabel: "Player 2: 300",
      textSize: 20,
      textColor: [1, 1, 1],
      bgFill: mod.UIBgFill.None
    },
    // Close button
    {
      type: "Button",
      position: [100, 250],
      size: [200, 40],
      anchor: mod.UIAnchor.TopLeft,
      buttonEnabled: true,
      children: [
        {
          type: "Text",
          position: [0, 0],
          size: [200, 40],
          textLabel: "CLOSE",
          textSize: 20,
          textAnchor: mod.UIAnchor.Center,
          bgFill: mod.UIBgFill.None
        }
      ]
    }
  ]
});
```

**Per-Player UI:**

```typescript
// Show UI only to specific player
modlib.ParseUI({
  type: "Container",
  position: [10, 10],
  size: [200, 100],
  playerId: player,  // Only this player sees it!
  children: [
    {
      type: "Text",
      textLabel: "Your personal message",
      textSize: 20
    }
  ]
});

// Show UI only to Team1
modlib.ParseUI({
  type: "Container",
  position: [10, 10],
  size: [200, 100],
  teamId: mod.Team.Team1,  // Only Team1 sees it!
  children: [
    {
      type: "Text",
      textLabel: "Team 1 message",
      textSize: 20
    }
  ]
});
```

---

## Notification Helpers

### DisplayCustomNotificationMessage

Simplified custom notification display.

```typescript
function DisplayCustomNotificationMessage(
  message: mod.Message,
  slot: mod.CustomNotificationSlots,
  duration: number,
  target?: mod.Player | mod.Team
): void
```

**Slots:**
- `mod.CustomNotificationSlots.HeaderText` - Large header (slot 0)
- `mod.CustomNotificationSlots.MessageText1` - Sub-message 1 (slot 1)
- `mod.CustomNotificationSlots.MessageText2` - Sub-message 2 (slot 2)
- `mod.CustomNotificationSlots.MessageText3` - Sub-message 3 (slot 3)
- `mod.CustomNotificationSlots.MessageText4` - Sub-message 4 (slot 4)

**Example:**

```typescript
// Show to everyone
modlib.DisplayCustomNotificationMessage(
  mod.Message("Round Starting!"),
  mod.CustomNotificationSlots.HeaderText,
  5  // 5 seconds
);

// Show to specific player
modlib.DisplayCustomNotificationMessage(
  mod.Message("You captured the flag!"),
  mod.CustomNotificationSlots.MessageText1,
  3,
  player
);

// Show to team
modlib.DisplayCustomNotificationMessage(
  mod.Message("Your team is winning!"),
  mod.CustomNotificationSlots.MessageText2,
  4,
  mod.Team.Team1
);

// Multiple messages at once
modlib.DisplayCustomNotificationMessage(
  mod.Message("GAME OVER"),
  mod.CustomNotificationSlots.HeaderText,
  10
);
modlib.DisplayCustomNotificationMessage(
  mod.Message("Team 1 Wins!"),
  mod.CustomNotificationSlots.MessageText1,
  10
);
modlib.DisplayCustomNotificationMessage(
  mod.Message("Final Score: 500 - 300"),
  mod.CustomNotificationSlots.MessageText2,
  10
);
```

---

### ClearCustomNotificationMessage

Clear a specific notification slot.

```typescript
function ClearCustomNotificationMessage(
  slot: mod.CustomNotificationSlots,
  target?: mod.Player | mod.Team
): void
```

**Example:**

```typescript
// Clear header for everyone
modlib.ClearCustomNotificationMessage(
  mod.CustomNotificationSlots.HeaderText
);

// Clear message for specific player
modlib.ClearCustomNotificationMessage(
  mod.CustomNotificationSlots.MessageText1,
  player
);
```

---

### ClearAllCustomNotificationMessages

Clear all notification slots for a player.

```typescript
function ClearAllCustomNotificationMessages(player: mod.Player): void
```

**Example:**

```typescript
// Clear all notifications for player
modlib.ClearAllCustomNotificationMessages(player);

// Common pattern: clear old messages when showing new ones
export async function showPlayerStats(player: mod.Player) {
  modlib.ClearAllCustomNotificationMessages(player);

  modlib.DisplayCustomNotificationMessage(
    mod.Message("YOUR STATS"),
    mod.CustomNotificationSlots.HeaderText,
    10,
    player
  );
  modlib.DisplayCustomNotificationMessage(
    mod.Message(`Kills: ${getKills(player)}`),
    mod.CustomNotificationSlots.MessageText1,
    10,
    player
  );
  modlib.DisplayCustomNotificationMessage(
    mod.Message(`Deaths: ${getDeaths(player)}`),
    mod.CustomNotificationSlots.MessageText2,
    10,
    player
  );
}
```

---

### ShowEventGameModeMessage

Display large game mode message at top of screen.

```typescript
function ShowEventGameModeMessage(
  event: mod.Message,
  target?: mod.Player | mod.Team
): void
```

**Example:**

```typescript
// Show to everyone
modlib.ShowEventGameModeMessage(
  mod.Message("ROUND 1 STARTING")
);

// Show to specific team
modlib.ShowEventGameModeMessage(
  mod.Message("Your team won!"),
  mod.Team.Team1
);
```

---

### ShowHighlightedGameModeMessage

Display highlighted message in world log.

```typescript
function ShowHighlightedGameModeMessage(
  event: mod.Message,
  target?: mod.Player | mod.Team
): void
```

---

### ShowNotificationMessage

Display standard notification message.

```typescript
function ShowNotificationMessage(
  message: mod.Message,
  target?: mod.Player | mod.Team
): void
```

---

## Utility Functions

### And

Combine multiple boolean conditions.

```typescript
function And(...conditions: boolean[]): boolean
```

**Example:**

```typescript
const canCapture = modlib.And(
  playerIsAlive,
  playerInZone,
  playerHasFlag,
  !roundEnded
);

if (canCapture) {
  capturePoint();
}
```

---

### AndFn

Combine multiple condition functions.

```typescript
function AndFn(...conditions: (() => boolean)[]): boolean
```

**Example:**

```typescript
const canShoot = modlib.AndFn(
  () => mod.IsPlayerAlive(player),
  () => hasAmmo(player),
  () => !isReloading(player)
);
```

---

### IfThenElse

Inline if-then-else expression.

```typescript
function IfThenElse<T>(
  condition: boolean,
  ifTrue: () => T,
  ifFalse: () => T
): T
```

**Example:**

```typescript
const message = modlib.IfThenElse(
  playerWon,
  () => "You won!",
  () => "You lost!"
);

const color = modlib.IfThenElse(
  isEnemy,
  () => mod.CreateVector(1, 0, 0),  // Red
  () => mod.CreateVector(0, 1, 0)   // Green
);
```

---

### WaitUntil

Wait for a condition to become false (with timeout).

```typescript
async function WaitUntil(
  delay: number,
  condition: () => boolean
): Promise<void>
```

**Example:**

```typescript
// Wait up to 30 seconds for all players to ready up
await modlib.WaitUntil(30, () => !allPlayersReady());

// If condition is still true after 30s, continues anyway
```

---

### Concat

Concatenate two strings.

```typescript
function Concat(s1: string, s2: string): string
```

**Example:**

```typescript
const fullName = modlib.Concat("Player", "123");
console.log(fullName);  // "Player123"
```

---

### Equals

Safe equality check (handles null/undefined).

```typescript
function Equals(a: any, b: any): boolean
```

---

## Complete Example: Using modlib in a Game Mode

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';

// Condition numbers for state tracking
const PLAYER_IN_CAPTURE_ZONE = 0;
const TEAM_OWNS_ALL_POINTS = 1;

let captureZoneCenter: mod.Vector;
let captureRadius = 50;

export async function OnGameModeStarted() {
  captureZoneCenter = mod.CreateVector(100, 0, 100);

  // Build UI
  buildScoreboardUI();

  // Start monitoring loop
  monitorCaptureZone();
}

export async function OnPlayerJoinGame(player: mod.Player) {
  // Welcome message
  modlib.DisplayCustomNotificationMessage(
    mod.Message("Welcome to Capture Mode!"),
    mod.CustomNotificationSlots.HeaderText,
    5,
    player
  );

  modlib.DisplayCustomNotificationMessage(
    mod.Message("Capture the zone to win!"),
    mod.CustomNotificationSlots.MessageText1,
    5,
    player
  );
}

async function monitorCaptureZone() {
  while (true) {
    const players = modlib.ConvertArray(mod.AllPlayers());

    for (const player of players) {
      const playerPos = mod.GetPlayerTransform(player).position;
      const distance = mod.DistanceBetween(playerPos, captureZoneCenter);
      const inZone = distance < captureRadius;

      // Use condition tracking for edge-triggered event
      const zoneCondition = modlib.getPlayerCondition(player, PLAYER_IN_CAPTURE_ZONE);

      if (zoneCondition.update(inZone)) {
        // Triggers once when player enters zone
        modlib.DisplayCustomNotificationMessage(
          mod.Message("Capturing zone..."),
          mod.CustomNotificationSlots.MessageText2,
          3,
          player
        );

        await captureZoneForPlayer(player);
      }
    }

    await mod.Wait(0.5);
  }
}

async function captureZoneForPlayer(player: mod.Player) {
  await mod.Wait(5);  // 5 second capture time

  // Check still in zone
  const playerPos = mod.GetPlayerTransform(player).position;
  const distance = mod.DistanceBetween(playerPos, captureZoneCenter);

  if (distance < captureRadius && !mod.IsPlayerDead(player)) {
    // Captured!
    const team = mod.GetTeam(player);
    const teamPlayers = modlib.getPlayersInTeam(team);

    // Award points
    teamPlayers.forEach(p => {
      const currentScore = mod.GetPlayerScore(p);
      mod.SetPlayerScore(p, currentScore + 100);
    });

    // Show message
    modlib.ShowEventGameModeMessage(
      mod.Message(`${mod.GetPlayerName(player)} captured the zone!`)
    );
  }
}

function buildScoreboardUI() {
  modlib.ParseUI({
    type: "Container",
    name: "ScoreDisplay",
    position: [10, 10],
    size: [300, 100],
    anchor: mod.UIAnchor.TopRight,
    bgColor: [0.1, 0.1, 0.1],
    bgAlpha: 0.7,
    children: [
      {
        type: "Text",
        name: "Team1Score",
        position: [10, 10],
        size: [280, 40],
        textLabel: "Team 1: 0",
        textSize: 24,
        textColor: [0, 0.5, 1],
        bgFill: mod.UIBgFill.None
      },
      {
        type: "Text",
        name: "Team2Score",
        position: [10, 55],
        size: [280, 40],
        textLabel: "Team 2: 0",
        textSize: 24,
        textColor: [1, 0.3, 0],
        bgFill: mod.UIBgFill.None
      }
    ]
  });
}
```

---

## Summary

**modlib provides:**
- ✅ **Array utilities** - Easy conversion & manipulation
- ✅ **State tracking** - Edge-triggered events per player/team/vehicle/object
- ✅ **UI builder** - Declarative JSON syntax
- ✅ **Notifications** - Simplified message display
- ✅ **Team utilities** - Quick player filtering
- ✅ **Helper functions** - Common patterns already implemented

**Always import modlib:**

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';
```

**Most commonly used:**
1. `modlib.ConvertArray()` - Convert every Portal array
2. `modlib.getPlayerCondition()` - Track player states
3. `modlib.ParseUI()` - Build UI easily
4. `modlib.DisplayCustomNotificationMessage()` - Show messages
5. `modlib.getPlayersInTeam()` - Filter by team

---

## Related APIs

- [UI Overview](/api/ui-overview) - Full UI system documentation
- [Player State](/api/player-state) - Getting player information
- [Types](/api/types) - Core types used by modlib

## See Also

- All example mods use modlib extensively
- [AcePursuit Example](/examples/acepursuit) - Heavy modlib usage
- [Vertigo Example](/examples/vertigo) - Condition tracking examples
