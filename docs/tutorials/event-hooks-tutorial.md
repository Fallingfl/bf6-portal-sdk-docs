# Understanding Event Hooks

Master the 7 event hooks that power all Portal game modes.

**Difficulty:** ★☆☆☆☆ | **Time:** 15 minutes | **Prerequisites:** None

---

## What Are Event Hooks?

Event hooks are special TypeScript functions that the Portal SDK automatically calls when specific game events occur. They're the **foundation** of all game mode logic.

Think of them like event listeners in web development or callbacks in other frameworks.

---

## The 7 Event Hooks

### 1. OnGameModeStarted

**When it fires:** Once, when the server starts and the game mode initializes.

**Purpose:** Game setup and configuration.

```typescript
export async function OnGameModeStarted() {
  // This runs ONE TIME when the mode starts

  // Common tasks:
  // - Configure teams
  // - Set victory conditions
  // - Initialize global variables
  // - Spawn static objects
  // - Enable/disable player join
}
```

**Example:**

```typescript
export async function OnGameModeStarted() {
  console.log("Game mode starting...");

  // Set up teams
  mod.SetTeamName(mod.Team.Team1, mod.Message("Attackers"));
  mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);

  // Set victory condition
  mod.SetGameModeScoreToWin(100);

  // Show countdown
  for (let i = 3; i > 0; i--) {
    mod.DisplayCustomNotificationMessage(
      mod.Message(`Game starting in ${i}...`),
      mod.CustomNotificationSlots.HeaderText,
      1
    );
    await mod.Wait(1);
  }

  // Allow players to join
  mod.EnablePlayerJoin();

  console.log("Game mode started!");
}
```

**Key Points:**
- ✅ Runs exactly **once**
- ✅ Good place for global setup
- ✅ Can use `await mod.Wait()` for countdowns
- ❌ No players exist yet (they join after this)

---

### 2. OnPlayerJoinGame

**When it fires:** Every time a player connects to the server.

**Purpose:** Initialize new players.

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  // This runs EVERY TIME a player joins

  // Common tasks:
  // - Assign player to team
  // - Initialize player stats/inventory
  // - Show welcome message
  // - Deploy player
}
```

**Example:**

```typescript
let playerCounter = 0;

export async function OnPlayerJoinGame(player: mod.Player) {
  playerCounter++;
  console.log(`Player ${playerCounter} joined: ${mod.GetPlayerName(player)}`);

  // Assign to team
  const team = playerCounter % 2 === 0 ? mod.Team.Team1 : mod.Team.Team2;
  mod.SetTeam(player, team);

  // Initialize score
  mod.SetGameModeScore(player, 0);

  // Show welcome message
  mod.DisplayCustomNotificationMessage(
    mod.Message(`Welcome, ${mod.GetPlayerName(player)}!`),
    mod.CustomNotificationSlots.HeaderText,
    5,
    player
  );

  // Deploy immediately
  mod.DeployPlayer(player);
}
```

**Key Points:**
- ✅ Fires for **each player** that joins
- ✅ Player exists but is **not deployed** yet
- ✅ Use this to assign teams
- ✅ Must call `mod.DeployPlayer()` to spawn the player

---

### 3. OnPlayerDeployed

**When it fires:** When a player spawns into the game world.

**Purpose:** Configure player's initial state.

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // This runs EVERY TIME a player spawns

  // Common tasks:
  // - Give equipment/weapons
  // - Apply buffs/debuffs
  // - Show HUD elements
  // - Teleport to custom spawn location
}
```

**Example:**

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  console.log(`${mod.GetPlayerName(player)} deployed`);

  // Give starter loadout
  mod.AddEquipment(player, mod.Weapons.AK_24, 1);
  mod.AddEquipment(player, mod.Gadgets.Medkit, 1);
  mod.AddEquipment(player, mod.Gadgets.Ammo_Crate, 1);

  // Apply spawn protection (3 seconds)
  mod.SetDamageReductionModifier(player, 0); // Invulnerable
  await mod.Wait(3);
  mod.SetDamageReductionModifier(player, 1); // Normal damage

  // Show HUD
  createPlayerHUD(player);
}
```

**Key Points:**
- ✅ Fires **every spawn** (initial deploy + respawns)
- ✅ Player is now in the game world
- ✅ Position is determined by spawn points (or teleport them here)
- ✅ Good place for loadout/equipment

---

### 4. OnPlayerDied

**When it fires:** When a player's health reaches 0.

**Purpose:** Handle death logic and respawn.

```typescript
export async function OnPlayerDied(player: mod.Player) {
  // This runs EVERY TIME a player dies

  // Common tasks:
  // - Drop items/equipment
  // - Update death counter
  // - Respawn after delay
  // - Check for game over conditions
}
```

**Example:**

```typescript
const playerDeaths = new Map<mod.Player, number>();

export async function OnPlayerDied(player: mod.Player) {
  console.log(`${mod.GetPlayerName(player)} died`);

  // Track deaths
  const deaths = (playerDeaths.get(player) || 0) + 1;
  playerDeaths.set(player, deaths);

  // Show death message
  mod.DisplayCustomNotificationMessage(
    mod.Message(`You died! Deaths: ${deaths}`),
    mod.CustomNotificationSlots.MessageText1,
    3,
    player
  );

  // Respawn after 5 seconds
  await mod.Wait(5);

  mod.Revive(player);
  mod.DeployPlayer(player);
}
```

**Key Points:**
- ✅ Player is **dead** (not in game world)
- ✅ Must call `mod.Revive()` before redeploying
- ✅ Use `await mod.Wait()` for respawn delay
- ❌ Player cannot see UI updates while dead (wait until deployed)

---

### 5. OnPlayerEarnedKill

**When it fires:** When a player gets credit for killing another player.

**Purpose:** Reward kills and update scores.

```typescript
export async function OnPlayerEarnedKill(
  player: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  // This runs EVERY TIME a player gets a kill

  // Common tasks:
  // - Award points/money
  // - Show kill notifications
  // - Track kill streaks
  // - Check for victory conditions
}
```

**Example:**

```typescript
const killStreaks = new Map<mod.Player, number>();

export async function OnPlayerEarnedKill(
  player: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  // Increment killer's score
  const score = mod.GetGameModeScore(player);
  mod.SetGameModeScore(player, score + 1);

  // Track kill streak
  const streak = (killStreaks.get(player) || 0) + 1;
  killStreaks.set(player, streak);

  // Reset victim's streak
  killStreaks.set(victim, 0);

  // Bonus for kill streaks
  if (streak === 5) {
    mod.DisplayCustomNotificationMessage(
      mod.Message("KILLING SPREE!"),
      mod.CustomNotificationSlots.HeaderText,
      3,
      player
    );
  }

  // Show kill feed
  console.log(`${mod.GetPlayerName(player)} killed ${mod.GetPlayerName(victim)} with ${weapon}`);
}
```

**Key Points:**
- ✅ Provides **killer**, **victim**, **death type**, and **weapon**
- ✅ Both players are valid (victim is dead but still exists)
- ✅ Perfect for scoring logic
- ✅ DeathType can distinguish suicides, teamkills, etc.

---

### 6. OnPlayerLeaveGame

**When it fires:** When a player disconnects from the server.

**Purpose:** Cleanup and rebalancing.

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  // This runs EVERY TIME a player disconnects

  // Common tasks:
  // - Clean up player data
  // - Rebalance teams
  // - Drop player's items
  // - Update lobby UI
}
```

**Example:**

```typescript
let team1Count = 0;
let team2Count = 0;

export async function OnPlayerLeaveGame(playerId: string) {
  console.log(`Player ${playerId} left the game`);

  // NOTE: Player object no longer exists!
  // You only get the playerId (string)

  // Clean up tracking data
  // (you'd need to store team assignment by ID to decrement correctly)

  // Example: Update lobby count UI
  const remaining = modlib.ConvertArray(mod.AllPlayers()).length;
  console.log(`${remaining} players remaining`);
}
```

**Key Points:**
- ⚠️ You only get `playerId` (string), **not** the Player object
- ⚠️ Player is already gone from the server
- ✅ Use for cleanup of global tracking Maps/arrays
- ✅ Store player data by ID if you need it here

---

### 7. OnPlayerSwitchTeam

**When it fires:** When a player changes teams (via `mod.SetTeam()` or menu).

**Purpose:** React to team changes.

```typescript
export async function OnPlayerSwitchTeam(player: mod.Player, team: mod.Team) {
  // This runs EVERY TIME a player switches teams

  // Common tasks:
  // - Update team counters
  // - Change player loadout based on team
  // - Show team-specific UI
  // - Rebalance teams if needed
}
```

**Example:**

```typescript
export async function OnPlayerSwitchTeam(player: mod.Player, team: mod.Team) {
  console.log(`${mod.GetPlayerName(player)} switched to ${team}`);

  // Give team-specific loadout
  if (team === mod.Team.Team1) {
    mod.AddEquipment(player, mod.Weapons.M5A3, 1); // Attackers get M5A3
  } else if (team === mod.Team.Team2) {
    mod.AddEquipment(player, mod.Weapons.AC_42, 1); // Defenders get AC-42
  }

  // Show notification
  mod.DisplayCustomNotificationMessage(
    mod.Message(`You joined ${mod.GetTeamName(team)}`),
    mod.CustomNotificationSlots.MessageText1,
    3,
    player
  );
}
```

**Key Points:**
- ✅ Fires when teams change (manual or automatic)
- ✅ Player is still alive and deployed
- ✅ Use to update team-specific state
- ⚠️ Can fire during `OnPlayerJoinGame` if you assign teams there

---

## Hook Execution Order

Here's the typical sequence for a player joining a game:

```
1. OnGameModeStarted()         [Server starts]
   ↓
2. OnPlayerJoinGame(player)    [Player connects]
   ↓
3. OnPlayerSwitchTeam(player)  [If you assigned a team]
   ↓
4. OnPlayerDeployed(player)    [Player spawns]
   ↓
   ... player plays ...
   ↓
5. OnPlayerDied(player)        [Player dies]
   ↓
6. OnPlayerDeployed(player)    [Player respawns]
   ↓
   ... player kills someone ...
   ↓
7. OnPlayerEarnedKill(...)     [Player gets a kill]
   ↓
   ... player disconnects ...
   ↓
8. OnPlayerLeaveGame(playerId) [Player disconnects]
```

---

## Common Patterns

### Pattern 1: Global State Tracking

```typescript
// Track player stats globally
const playerStats = new Map<mod.Player, {
  kills: number;
  deaths: number;
  score: number;
}>();

export async function OnPlayerJoinGame(player: mod.Player) {
  // Initialize stats
  playerStats.set(player, { kills: 0, deaths: 0, score: 0 });
}

export async function OnPlayerEarnedKill(player: mod.Player) {
  const stats = playerStats.get(player)!;
  stats.kills++;
}

export async function OnPlayerDied(player: mod.Player) {
  const stats = playerStats.get(player)!;
  stats.deaths++;
}

export async function OnPlayerLeaveGame(playerId: string) {
  // Can't clean up by Player object - need to track by ID
  // (This is a limitation - use strings as keys if cleanup needed)
}
```

---

### Pattern 2: Async Loops in Hooks

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Start a loop that runs while player is alive
  regenLoop(player);
}

async function regenLoop(player: mod.Player) {
  while (mod.IsAlive(player)) {
    const health = mod.GetPlayerHealth(player);

    if (health < 100) {
      mod.SetPlayerHealth(player, health + 1); // Regen 1 HP/sec
    }

    await mod.Wait(1);
  }
}
```

---

### Pattern 3: Countdown in OnGameModeStarted

```typescript
export async function OnGameModeStarted() {
  // Prevent players from joining during countdown
  mod.DisablePlayerJoin();

  // Show countdown
  for (let i = 10; i > 0; i--) {
    mod.DisplayCustomNotificationMessage(
      mod.Message(`Starting in ${i}...`),
      mod.CustomNotificationSlots.HeaderText,
      1
    );
    await mod.Wait(1);
  }

  // Start the game
  mod.EnablePlayerJoin();
  mod.DisplayCustomNotificationMessage(
    mod.Message("GO!"),
    mod.CustomNotificationSlots.HeaderText,
    2
  );
}
```

---

## Best Practices

### ✅ DO:

- Use `async/await` for delays and sequencing
- Log to console for debugging (`console.log()`)
- Initialize player state in `OnPlayerJoinGame`
- Use Maps or objects to track per-player data
- Handle null/undefined cases (players can disconnect mid-function)

### ❌ DON'T:

- Block the hook with infinite loops without `await mod.Wait()`
- Assume players exist (always check `IsAlive`, etc.)
- Forget to call `DeployPlayer()` after `OnPlayerJoinGame`
- Try to access Player objects in `OnPlayerLeaveGame` (only have playerId string)

---

## Debugging Hooks

### Check if a hook is firing:

```typescript
export async function OnPlayerDied(player: mod.Player) {
  console.log("OnPlayerDied fired!");  // Add this
  console.log(`Player name: ${mod.GetPlayerName(player)}`);

  // ... rest of your code
}
```

### Check hook order:

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  console.log("1. OnPlayerJoinGame");
}

export async function OnPlayerSwitchTeam(player: mod.Player, team: mod.Team) {
  console.log("2. OnPlayerSwitchTeam");
}

export async function OnPlayerDeployed(player: mod.Player) {
  console.log("3. OnPlayerDeployed");
}
```

---

## Practice Exercise

Try creating a mode that uses all 7 hooks:

1. **OnGameModeStarted**: Show a countdown before the game starts
2. **OnPlayerJoinGame**: Assign players to teams and deploy them
3. **OnPlayerDeployed**: Give players a random weapon
4. **OnPlayerDied**: Respawn after 3 seconds
5. **OnPlayerEarnedKill**: Award 10 points per kill
6. **OnPlayerLeaveGame**: Announce when players leave
7. **OnPlayerSwitchTeam**: Give team-specific loadouts

---

## Next Steps

- **[Your First Game Mode](/tutorials/first-game-mode)** - Build a complete TDM mode using hooks
- **[Building a Simple UI](/tutorials/simple-ui)** - Add UI elements in hooks
- **[Working with Teams](/tutorials/teams-tutorial)** - Advanced team management

---

★ Insight ─────────────────────────────────────
**Hook Lifecycle Design**
1. **Separation of Concerns** - Each hook handles a specific lifecycle event, preventing monolithic initialization code
2. **Async-First** - All hooks are async, allowing game logic to span multiple frames without blocking the game loop
3. **Per-Event Granularity** - Having separate hooks for Join/Deploy/Die allows precise control over when state is initialized vs. when players enter the world
─────────────────────────────────────────────────
