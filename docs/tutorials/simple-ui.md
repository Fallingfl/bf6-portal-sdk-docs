# Building a Simple UI

Create your first heads-up display with text, images, and buttons.

**Difficulty:** ★★☆☆☆ | **Time:** 25 minutes | **Prerequisites:** Basic TypeScript knowledge

---

## What You'll Build

A functional player HUD with:
- **Score display** - Shows player's current score
- **Kill counter** - Tracks kills this life
- **Team indicator** - Shows player's team color
- **Ready button** - Interactive button for player input

---

## Understanding the UI System

Portal's UI system consists of **5 widget types**:

| Widget | Purpose | Example Use |
|--------|---------|-------------|
| **Container** | Layout box for grouping widgets | Scoreboard panel |
| **Text** | Display text labels | "Score: 100" |
| **Image** | Display icons/sprites | Team logo |
| **Button** | Clickable buttons | "Ready Up" button |
| **ProgressBar** | Visual progress indicator | Health bar |

**Key Concept:** UI is **per-player**. Each player sees their own UI independently.

---

## Step 1: Create a Simple Text Label

Let's start with the simplest UI element - a text label showing the player's score.

```typescript
import * as mod from 'bf-portal-api';

export async function OnPlayerDeployed(player: mod.Player) {
  // Create a text label at the top-left of the screen
  const scoreText = mod.AddUIText(
    "playerScore",               // Unique name
    mod.Message("Score: 0"),     // Initial text
    mod.CreateVector(10, 10, 0), // Position (x, y, z)
    mod.CreateVector(200, 50, 0),// Size (width, height, 0)
    mod.UIAnchor.TopLeft,        // Anchor point
    null,                        // Parent widget (null = root)
    true,                        // Visible
    24,                          // Font size
    mod.CreateVector(1, 1, 1),   // Text color (white)
    1.0,                         // Alpha (opacity)
    player                       // Which player sees it
  );

  console.log(`Created score UI for ${mod.GetPlayerName(player)}`);
}
```

**Test it:** Deploy into the game and you'll see "Score: 0" in the top-left corner.

---

## Step 2: Update the Text Dynamically

Now let's make the score update when the player gets kills.

```typescript
// Store widget reference globally so we can update it
const playerScoreWidgets = new Map<mod.Player, mod.UIWidget>();

export async function OnPlayerDeployed(player: mod.Player) {
  const scoreText = mod.AddUIText(
    "playerScore",
    mod.Message("Score: 0"),
    mod.CreateVector(10, 10, 0),
    mod.CreateVector(200, 50, 0),
    mod.UIAnchor.TopLeft,
    null,
    true,
    24,
    mod.CreateVector(1, 1, 1),
    1.0,
    player
  );

  // Save reference for later updates
  playerScoreWidgets.set(player, scoreText);
}

export async function OnPlayerEarnedKill(player: mod.Player) {
  const currentScore = mod.GetGameModeScore(player);
  const newScore = currentScore + 1;
  mod.SetGameModeScore(player, newScore);

  // Update the UI
  const scoreWidget = playerScoreWidgets.get(player);
  if (scoreWidget) {
    mod.SetUITextLabel(scoreWidget, mod.Message(`Score: ${newScore}`));
  }
}
```

**Test it:** Get a kill and watch your score update!

---

## Step 3: Add a Background Container

Text floating on the screen looks basic. Let's add a background panel.

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // 1. Create a container (background panel)
  const scoreContainer = mod.AddUIContainer(
    "scorePanel",
    mod.CreateVector(10, 10, 0),    // Position
    mod.CreateVector(220, 60, 0),   // Size (bigger than text)
    mod.UIAnchor.TopLeft,
    null,                            // No parent
    true,                            // Visible
    10,                              // Padding
    mod.CreateVector(0, 0, 0),       // Background color (black)
    0.7,                             // Alpha (70% opaque)
    mod.UIBgFill.Solid,             // Fill type
    player
  );

  // 2. Create text INSIDE the container
  const scoreText = mod.AddUIText(
    "playerScore",
    mod.Message("Score: 0"),
    mod.CreateVector(0, 0, 0),       // Position relative to parent
    mod.CreateVector(200, 40, 0),
    mod.UIAnchor.Center,             // Centered in container
    scoreContainer,                  // Parent is the container
    true,
    24,
    mod.CreateVector(1, 1, 1),
    1.0,
    player
  );

  playerScoreWidgets.set(player, scoreText);
}
```

**Key Change:** `scoreContainer` is now the **parent** of `scoreText`. The text positions itself relative to the container.

---

## Step 4: Build a Complete HUD

Let's create a full HUD with multiple stats.

```typescript
interface PlayerHUD {
  scoreText: mod.UIWidget;
  killsText: mod.UIWidget;
  deathsText: mod.UIWidget;
  teamIndicator: mod.UIWidget;
}

const playerHUDs = new Map<mod.Player, PlayerHUD>();
const playerKills = new Map<mod.Player, number>();
const playerDeaths = new Map<mod.Player, number>();

export async function OnPlayerJoinGame(player: mod.Player) {
  // Initialize stats
  playerKills.set(player, 0);
  playerDeaths.set(player, 0);
  mod.SetGameModeScore(player, 0);
}

export async function OnPlayerDeployed(player: mod.Player) {
  // Main HUD container
  const hudContainer = mod.AddUIContainer(
    "hudPanel",
    mod.CreateVector(10, 10, 0),
    mod.CreateVector(300, 120, 0),
    mod.UIAnchor.TopLeft,
    null,
    true,
    10,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.8,
    mod.UIBgFill.Solid,
    player
  );

  // Team color indicator (top of HUD)
  const team = mod.GetTeam(player);
  const teamColor = team === mod.Team.Team1
    ? mod.CreateVector(1, 0, 0)  // Red
    : mod.CreateVector(0, 0, 1); // Blue

  const teamIndicator = mod.AddUIContainer(
    "teamIndicator",
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(300, 10, 0),
    mod.UIAnchor.TopCenter,
    hudContainer,
    true,
    0,
    teamColor,
    1.0,
    mod.UIBgFill.Solid,
    player
  );

  // Score text
  const scoreText = mod.AddUIText(
    "scoreLabel",
    mod.Message(`Score: ${mod.GetGameModeScore(player)}`),
    mod.CreateVector(10, 20, 0),
    mod.CreateVector(280, 30, 0),
    mod.UIAnchor.TopLeft,
    hudContainer,
    true,
    20,
    mod.CreateVector(1, 1, 1),
    1.0,
    player
  );

  // Kills text
  const killsText = mod.AddUIText(
    "killsLabel",
    mod.Message(`Kills: ${playerKills.get(player)}`),
    mod.CreateVector(10, 50, 0),
    mod.CreateVector(140, 30, 0),
    mod.UIAnchor.TopLeft,
    hudContainer,
    true,
    18,
    mod.CreateVector(0.5, 1, 0.5),  // Green
    1.0,
    player
  );

  // Deaths text
  const deathsText = mod.AddUIText(
    "deathsLabel",
    mod.Message(`Deaths: ${playerDeaths.get(player)}`),
    mod.CreateVector(150, 50, 0),
    mod.CreateVector(140, 30, 0),
    mod.UIAnchor.TopLeft,
    hudContainer,
    true,
    18,
    mod.CreateVector(1, 0.5, 0.5),  // Red
    1.0,
    player
  );

  // Store references
  playerHUDs.set(player, {
    scoreText,
    killsText,
    deathsText,
    teamIndicator
  });
}

export async function OnPlayerEarnedKill(player: mod.Player) {
  // Update stats
  const kills = (playerKills.get(player) || 0) + 1;
  playerKills.set(player, kills);

  const score = mod.GetGameModeScore(player) + 1;
  mod.SetGameModeScore(player, score);

  // Update HUD
  const hud = playerHUDs.get(player);
  if (hud) {
    mod.SetUITextLabel(hud.scoreText, mod.Message(`Score: ${score}`));
    mod.SetUITextLabel(hud.killsText, mod.Message(`Kills: ${kills}`));
  }
}

export async function OnPlayerDied(player: mod.Player) {
  // Update deaths
  const deaths = (playerDeaths.get(player) || 0) + 1;
  playerDeaths.set(player, deaths);

  // Update HUD (if it exists - player is dead but HUD persists)
  const hud = playerHUDs.get(player);
  if (hud) {
    mod.SetUITextLabel(hud.deathsText, mod.Message(`Deaths: ${deaths}`));
  }

  // Respawn
  await mod.Wait(5);
  mod.Revive(player);
  mod.DeployPlayer(player);
}
```

---

## Step 5: Add an Interactive Button

Let's add a "Ready Up" button players can click.

```typescript
let readyButton: mod.UIButton;

export async function OnGameModeStarted() {
  // Create a global button ID (all players can interact)
  readyButton = mod.AddButtonDefinition("readyButton");
}

const playerReadyStatus = new Map<mod.Player, boolean>();

export async function OnPlayerJoinGame(player: mod.Player) {
  playerReadyStatus.set(player, false);
}

export async function OnPlayerDeployed(player: mod.Player) {
  // ... existing HUD code ...

  // Add ready button (separate from HUD)
  const buttonContainer = mod.AddUIContainer(
    "readyButtonPanel",
    mod.CreateVector(0, -100, 0),   // Bottom-center
    mod.CreateVector(200, 60, 0),
    mod.UIAnchor.BottomCenter,
    null,
    true,
    5,
    mod.CreateVector(0.2, 0.2, 0.2),
    0.9,
    mod.UIBgFill.Solid,
    player
  );

  const button = mod.AddUIButton(
    "readyButtonWidget",
    readyButton,                    // Button definition from OnGameModeStarted
    mod.Message("Ready Up"),
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(190, 50, 0),
    mod.UIAnchor.Center,
    buttonContainer,
    true,                           // Enabled
    true,                           // Visible
    20,
    mod.CreateVector(1, 1, 1),
    1.0,
    player
  );
}

// Handle button clicks
export async function OnPlayerButtonPressed(player: mod.Player, button: mod.UIButton) {
  if (button === readyButton) {
    const isReady = !playerReadyStatus.get(player);
    playerReadyStatus.set(player, isReady);

    // Show notification
    mod.DisplayCustomNotificationMessage(
      mod.Message(isReady ? "You are READY!" : "You are NOT READY"),
      mod.CustomNotificationSlots.MessageText1,
      2,
      player
    );

    console.log(`${mod.GetPlayerName(player)} ready status: ${isReady}`);
  }
}
```

---

## UI Positioning Guide

### Anchor Points

```typescript
// Common anchors:
mod.UIAnchor.TopLeft       // (0,0) is top-left of screen
mod.UIAnchor.TopCenter     // (0,0) is top-center
mod.UIAnchor.TopRight      // (0,0) is top-right
mod.UIAnchor.BottomLeft    // (0,0) is bottom-left
mod.UIAnchor.BottomCenter  // (0,0) is bottom-center
mod.UIAnchor.Center        // (0,0) is screen center
```

### Position Examples

```typescript
// Top-left corner
mod.CreateVector(10, 10, 0)

// Top-right corner (negative X pulls left from right edge)
mod.CreateVector(-10, 10, 0)

// Bottom-center
mod.CreateVector(0, -50, 0)  // 50px from bottom

// Centered
mod.CreateVector(0, 0, 0)  // With UIAnchor.Center
```

---

## Best Practices

### ✅ DO:

- **Store widget references** in Maps to update them later
- **Use containers** as parents to group related UI elements
- **Anchor appropriately** - use TopLeft for fixed UI, Center for modals
- **Clean up on death/leave** - remove widgets if needed

### ❌ DON'T:

- **Spam AddUI calls** - create once, update with SetUITextLabel
- **Forget parent widgets** - null parent works but limits layout options
- **Use huge font sizes** - 12-24 is readable, 60+ is excessive
- **Block on UI updates** - UI calls are fast, but avoid loops

---

## Common Patterns

### Countdown Timer UI

```typescript
async function showCountdown(player: mod.Player) {
  const timerText = mod.AddUIText(
    "countdown",
    mod.Message("3"),
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(200, 100, 0),
    mod.UIAnchor.Center,
    null,
    true,
    72,
    mod.CreateVector(1, 1, 0),  // Yellow
    1.0,
    player
  );

  for (let i = 3; i > 0; i--) {
    mod.SetUITextLabel(timerText, mod.Message(`${i}`));
    await mod.Wait(1);
  }

  mod.SetUITextLabel(timerText, mod.Message("GO!"));
  await mod.Wait(1);

  mod.RemoveUIWidget(timerText, player);
}
```

### Progress Bar (Health Bar)

```typescript
async function createHealthBar(player: mod.Player): Promise<mod.UIWidget> {
  return mod.AddUIProgressBar(
    "healthBar",
    100,                         // Max value
    100,                         // Current value
    mod.CreateVector(-150, -50, 0),
    mod.CreateVector(300, 20, 0),
    mod.UIAnchor.BottomCenter,
    null,
    true,
    mod.CreateVector(0, 1, 0),   // Green bar
    mod.CreateVector(0.2, 0.2, 0.2), // Dark background
    1.0,
    player
  );
}

// Update it based on health
async function updateHealthBar(player: mod.Player, healthBar: mod.UIWidget) {
  const health = mod.GetPlayerHealth(player);
  mod.SetUIProgressBarValue(healthBar, health);
}
```

---

## Debugging UI

### Check if widgets are created:

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  console.log("Creating UI...");

  const widget = mod.AddUIText(...);

  console.log(`Widget created: ${widget !== null}`);
}
```

### Verify visibility:

```typescript
// Toggle visibility to test
mod.SetUIVisible(widget, false, player);  // Hide
await mod.Wait(2);
mod.SetUIVisible(widget, true, player);   // Show
```

---

## Next Steps

- **[Working with Teams](/tutorials/teams-tutorial)** - Add team-specific UI
- **[Complex UI Layouts](/tutorials/complex-ui)** - Build scoreboards and menus
- **[Checkpoint System](/tutorials/checkpoint-system)** - Add checkpoint UI indicators

**API Reference:**
- [UI Widgets](/api/ui-widgets) - Complete UI function reference
- [UI Notifications](/api/ui-notifications) - Notification system

---

★ Insight ─────────────────────────────────────
**Per-Player UI Architecture**
1. **Independent Rendering** - Each player receives their own widget instances; updating one player's UI doesn't affect others
2. **Parent-Child Hierarchy** - Containers enable relative positioning, making complex layouts easier to manage and maintain
3. **State External to Widgets** - Widgets themselves don't store game state; use Maps/global variables and update UI to reflect state changes
─────────────────────────────────────────────────
