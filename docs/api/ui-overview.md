# UI System Overview

The BF6 Portal SDK provides a comprehensive UI system with 104 functions for creating custom interfaces, HUDs, and notifications.

## Overview

The UI system supports:
- **5 widget types** - Container, Text, Image, Button, ProgressBar
- **Per-player UI** - Each player sees their own UI instance
- **Hierarchical layout** - Parent-child widget relationships
- **Dynamic updates** - Real-time content changes
- **World icons** - 3D markers in game world
- **Notifications** - Various message types and positions

## UI Architecture

### Widget Hierarchy

```
Root
├── Container (HUD)
│   ├── Text (Score)
│   ├── Image (Icon)
│   └── ProgressBar (Health)
├── Container (Menu)
│   ├── Button (Start)
│   └── Button (Quit)
└── Container (Scoreboard)
    └── Text (Players)
```

### Per-Player UI

Each player has their own UI instance:

```typescript
// This creates separate UI for EACH player
const players = modlib.ConvertArray(mod.AllPlayers());
for (const player of players) {
  const container = mod.AddUIContainer(
    "playerHUD",
    mod.CreateVector(10, 10, 0),
    mod.CreateVector(200, 100, 0),
    mod.UIAnchor.TopLeft,
    null,
    true,
    0,
    mod.CreateVector(0, 0, 0),
    0.8,
    mod.UIBgFill.Stretch,
    player  // Per-player UI
  );
}
```

## Widget Types

### Containers

Group and organize other widgets:

```typescript
mod.AddUIContainer(
  name: string,
  position: Vector,
  size: Vector,
  anchor: UIAnchor,
  parent?: UIWidget,
  visible?: boolean,
  padding?: number,
  bgColor?: Vector,
  bgAlpha?: number,
  bgFill?: UIBgFill,
  visibility?: Player | Team
): UIWidget
```

### Text

Display text labels and values:

```typescript
mod.AddUIText(
  name: string,
  position: Vector,
  size: Vector,
  anchor: UIAnchor,
  parent: UIWidget,
  visible: boolean,
  padding: number,
  bgColor: Vector,
  bgAlpha: number,
  bgFill: UIBgFill,
  textLabel: Message,
  textSize: number,
  textColor: Vector,
  textAlpha: number,
  textAnchor: UIAnchor,
  visibility?: Player | Team
): UIWidget
```

### Images

Show icons and graphics:

```typescript
mod.AddUIImage(
  name: string,
  position: Vector,
  size: Vector,
  anchor: UIAnchor,
  parent: UIWidget,
  visible: boolean,
  padding: number,
  bgColor: Vector,
  bgAlpha: number,
  bgFill: UIBgFill,
  imageType: UIImageType,
  imageColor: Vector,
  imageAlpha: number,
  visibility?: Player | Team
): UIWidget
```

### Buttons

Interactive clickable elements:

```typescript
mod.AddUIButton(
  name: string,
  position: Vector,
  size: Vector,
  anchor: UIAnchor,
  parent: UIWidget,
  visible: boolean,
  padding: number,
  bgColor: Vector,
  bgAlpha: number,
  bgFill: UIBgFill,
  buttonEnabled: boolean,
  buttonColorBase: Vector,
  buttonAlphaBase: number,
  buttonColorDisabled: Vector,
  buttonAlphaDisabled: number,
  buttonColorPressed: Vector,
  buttonAlphaPressed: number,
  buttonColorHover: Vector,
  buttonAlphaHover: number,
  buttonColorFocused: Vector,
  buttonAlphaFocused: number,
  visibility?: Player | Team
): UIWidget
```

### Progress Bars

Visual progress indicators:

```typescript
mod.AddUIProgressBar(
  name: string,
  position: Vector,
  size: Vector,
  anchor: UIAnchor,
  parent: UIWidget,
  visible: boolean,
  padding: number,
  bgColor: Vector,
  bgAlpha: number,
  bgFill: UIBgFill,
  progress: number,  // 0.0 to 1.0
  barColor: Vector,
  barAlpha: number,
  visibility?: Player | Team
): UIWidget
```

## UI Positioning

### Anchors

Nine anchor positions for UI alignment:

```typescript
mod.UIAnchor.TopLeft
mod.UIAnchor.TopCenter
mod.UIAnchor.TopRight
mod.UIAnchor.CenterLeft
mod.UIAnchor.Center
mod.UIAnchor.CenterRight
mod.UIAnchor.BottomLeft
mod.UIAnchor.BottomCenter
mod.UIAnchor.BottomRight
```

### Coordinate System

- **Position** is relative to anchor point
- **Size** is in pixels
- **Origin** depends on anchor:
  - TopLeft: (0,0) is top-left corner
  - Center: (0,0) is screen center
  - BottomRight: (0,0) is bottom-right corner

```typescript
// Top-left positioned element
mod.AddUIContainer(
  "topLeft",
  mod.CreateVector(10, 10, 0),     // 10px from top-left
  mod.CreateVector(200, 100, 0),    // 200x100 size
  mod.UIAnchor.TopLeft
);

// Centered element
mod.AddUIContainer(
  "centered",
  mod.CreateVector(-100, -50, 0),   // Offset from center
  mod.CreateVector(200, 100, 0),    // 200x100 size
  mod.UIAnchor.Center
);
```

## Common UI Patterns

### Player HUD

```typescript
function createPlayerHUD(player: mod.Player) {
  // Main HUD container
  const hud = mod.AddUIContainer(
    "hud",
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(1920, 1080, 0),
    mod.UIAnchor.TopLeft,
    null,
    true,
    0,
    mod.CreateVector(0, 0, 0),
    0,
    mod.UIBgFill.Stretch,
    player
  );

  // Health bar
  const healthBar = mod.AddUIProgressBar(
    "health",
    mod.CreateVector(10, 10, 0),
    mod.CreateVector(200, 20, 0),
    mod.UIAnchor.BottomLeft,
    hud,
    true,
    0,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.5,
    mod.UIBgFill.Stretch,
    1.0,  // Full health
    mod.CreateVector(0, 1, 0),  // Green
    1.0,
    player
  );

  // Ammo counter
  const ammoText = mod.AddUIText(
    "ammo",
    mod.CreateVector(10, 40, 0),
    mod.CreateVector(100, 30, 0),
    mod.UIAnchor.BottomLeft,
    hud,
    true,
    2,
    mod.CreateVector(0, 0, 0),
    0,
    mod.UIBgFill.Stretch,
    mod.Message("30/120"),
    20,
    mod.CreateVector(1, 1, 1),
    1.0,
    mod.UIAnchor.CenterLeft,
    player
  );

  // Score display
  const scoreText = mod.AddUIText(
    "score",
    mod.CreateVector(10, 10, 0),
    mod.CreateVector(150, 40, 0),
    mod.UIAnchor.TopRight,
    hud,
    true,
    5,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.7,
    mod.UIBgFill.Stretch,
    mod.Message("Score: 0"),
    24,
    mod.CreateVector(1, 1, 0),  // Yellow
    1.0,
    mod.UIAnchor.Center,
    player
  );

  return { hud, healthBar, ammoText, scoreText };
}
```

### Menu System

```typescript
function createMainMenu(player: mod.Player) {
  // Menu background
  const menu = mod.AddUIContainer(
    "mainMenu",
    mod.CreateVector(-300, -200, 0),
    mod.CreateVector(600, 400, 0),
    mod.UIAnchor.Center,
    null,
    true,
    10,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.95,
    mod.UIBgFill.Stretch,
    player
  );

  // Title
  mod.AddUIText(
    "title",
    mod.CreateVector(0, 20, 0),
    mod.CreateVector(580, 60, 0),
    mod.UIAnchor.TopCenter,
    menu,
    true,
    0,
    mod.CreateVector(0, 0, 0),
    0,
    mod.UIBgFill.Stretch,
    mod.Message("GAME MODE SELECTION"),
    32,
    mod.CreateVector(1, 1, 1),
    1.0,
    mod.UIAnchor.Center,
    player
  );

  // Start button
  const startBtn = mod.AddUIButton(
    "startBtn",
    mod.CreateVector(-100, -50, 0),
    mod.CreateVector(200, 50, 0),
    mod.UIAnchor.Center,
    menu,
    true,
    5,
    mod.CreateVector(0.2, 0.2, 0.2),
    1.0,
    mod.UIBgFill.Stretch,
    true,  // Enabled
    mod.CreateVector(0.3, 0.3, 0.3),  // Base color
    1.0,
    mod.CreateVector(0.1, 0.1, 0.1),  // Disabled
    0.5,
    mod.CreateVector(0.4, 0.4, 0.4),  // Pressed
    1.0,
    mod.CreateVector(0.5, 0.5, 0.5),  // Hover
    1.0,
    mod.CreateVector(0.6, 0.6, 0.6),  // Focused
    1.0,
    player
  );

  // Button text
  mod.AddUIText(
    "startText",
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(200, 50, 0),
    mod.UIAnchor.Center,
    startBtn,
    true,
    0,
    mod.CreateVector(0, 0, 0),
    0,
    mod.UIBgFill.Stretch,
    mod.Message("START GAME"),
    20,
    mod.CreateVector(1, 1, 1),
    1.0,
    mod.UIAnchor.Center,
    player
  );

  return menu;
}
```

### Dynamic Scoreboard

```typescript
interface ScoreboardData {
  container: mod.UIWidget;
  rows: Map<mod.Player, mod.UIWidget>;
}

function createScoreboard(): ScoreboardData {
  const container = mod.AddUIContainer(
    "scoreboard",
    mod.CreateVector(-400, -300, 0),
    mod.CreateVector(800, 600, 0),
    mod.UIAnchor.Center,
    null,
    false,  // Hidden initially
    10,
    mod.CreateVector(0, 0, 0),
    0.9,
    mod.UIBgFill.Stretch
  );

  const rows = new Map<mod.Player, mod.UIWidget>();

  return { container, rows };
}

function updateScoreboard(data: ScoreboardData) {
  const players = modlib.ConvertArray(mod.AllPlayers());

  // Sort by score
  players.sort((a, b) => mod.GetPlayerScore(b) - mod.GetPlayerScore(a));

  let yOffset = 60;

  for (const player of players) {
    let row = data.rows.get(player);

    if (!row) {
      // Create new row
      row = mod.AddUIContainer(
        `row_${mod.GetPlayerId(player)}`,
        mod.CreateVector(10, yOffset, 0),
        mod.CreateVector(780, 40, 0),
        mod.UIAnchor.TopLeft,
        data.container,
        true,
        2,
        mod.CreateVector(0.1, 0.1, 0.1),
        0.5,
        mod.UIBgFill.Stretch
      );

      data.rows.set(player, row);
    }

    // Update position
    mod.UpdateUIContainerPosition(row, mod.CreateVector(10, yOffset, 0));

    // Update content
    updateScoreboardRow(row, player);

    yOffset += 45;
  }
}
```

## UI Updates

### Dynamic Content

```typescript
// Update text
mod.UpdateUIText(textWidget, mod.Message("New Text"));

// Update image
mod.UpdateUIImage(imageWidget, mod.UIImageType.NewIcon);

// Update progress bar
mod.UpdateUIProgressBar(progressWidget, 0.75);  // 75%

// Update position
mod.UpdateUIContainerPosition(widget, mod.CreateVector(100, 50, 0));

// Update size
mod.UpdateUIContainerSize(widget, mod.CreateVector(300, 200, 0));
```

### Real-Time Updates

```typescript
async function updatePlayerHUD() {
  while (gameRunning) {
    const players = modlib.ConvertArray(mod.AllPlayers());

    for (const player of players) {
      // Get player data
      const health = mod.GetSoldierState(player, mod.SoldierStateNumber.CurrentHealth);
      const maxHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.MaxHealth);
      const ammo = mod.GetSoldierState(player, mod.SoldierStateNumber.Ammo);
      const score = mod.GetPlayerScore(player);

      // Find player's UI widgets
      const healthBar = mod.FindUIWidgetWithName("health", player);
      const ammoText = mod.FindUIWidgetWithName("ammo", player);
      const scoreText = mod.FindUIWidgetWithName("score", player);

      // Update UI
      if (healthBar) {
        mod.UpdateUIProgressBar(healthBar, health / maxHealth);
      }

      if (ammoText) {
        mod.UpdateUIText(ammoText, mod.Message(`Ammo: ${ammo}`));
      }

      if (scoreText) {
        mod.UpdateUIText(scoreText, mod.Message(`Score: ${score}`));
      }
    }

    await mod.Wait(0.1);  // Update 10 times per second
  }
}
```

## UI Management

### Finding Widgets

```typescript
// Find by name (global)
const widget = mod.FindUIWidgetWithName("myWidget");

// Find by name (per-player)
const playerWidget = mod.FindUIWidgetWithName("playerHUD", player);

// Check if exists
if (mod.HasUIWidgetWithName("myWidget")) {
  // Widget exists
}
```

### Visibility Control

```typescript
// Show/hide widget
mod.SetUIWidgetVisibility(widget, true);   // Show
mod.SetUIWidgetVisibility(widget, false);  // Hide

// Toggle visibility
function toggleWidget(widget: mod.UIWidget) {
  const isVisible = getWidgetVisibility(widget);
  mod.SetUIWidgetVisibility(widget, !isVisible);
}
```

### Deleting Widgets

```typescript
// Delete single widget
mod.DeleteUIWidget(widget);

// Clean up player UI
function cleanupPlayerUI(player: mod.Player) {
  const widgets = ["hud", "menu", "scoreboard"];

  for (const name of widgets) {
    if (mod.HasUIWidgetWithName(name, player)) {
      const widget = mod.FindUIWidgetWithName(name, player);
      mod.DeleteUIWidget(widget);
    }
  }
}
```

## Input Mode

### Enable UI Input

Allow players to interact with UI (shows cursor):

```typescript
// Enable UI input with cursor
mod.EnableUIInputMode(player, true, true);

// Disable UI input
mod.EnableUIInputMode(player, false, false);
```

**Example: Menu Toggle**
```typescript
let menuOpen = false;

function toggleMenu(player: mod.Player) {
  menuOpen = !menuOpen;

  const menu = mod.FindUIWidgetWithName("mainMenu", player);

  if (menuOpen) {
    mod.SetUIWidgetVisibility(menu, true);
    mod.EnableUIInputMode(player, true, true);  // Enable cursor
    mod.EnableInputRestriction(player, mod.RestrictedInputs.FireWeapon, true);
  } else {
    mod.SetUIWidgetVisibility(menu, false);
    mod.EnableUIInputMode(player, false, false);  // Disable cursor
    mod.EnableInputRestriction(player, mod.RestrictedInputs.FireWeapon, false);
  }
}
```

## Best Practices

### 1. Use Descriptive Names

```typescript
// ❌ Bad
mod.AddUIContainer("c1", ...);
mod.AddUIText("t1", ...);

// ✅ Good
mod.AddUIContainer("playerHUD", ...);
mod.AddUIText("healthDisplay", ...);
```

### 2. Organize with Containers

```typescript
// Create logical groupings
const hudContainer = createHUDContainer();
const healthSection = createHealthSection(hudContainer);
const ammoSection = createAmmoSection(hudContainer);
const scoreSection = createScoreSection(hudContainer);
```

### 3. Cache Widget References

```typescript
// Store references instead of searching repeatedly
interface PlayerUI {
  player: mod.Player;
  hud: mod.UIWidget;
  healthBar: mod.UIWidget;
  ammoText: mod.UIWidget;
  scoreText: mod.UIWidget;
}

let playerUICache: PlayerUI[] = [];
```

### 4. Clean Up on Player Leave

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  // Clean up UI for disconnected player
  const cache = playerUICache.find(ui => mod.GetPlayerId(ui.player) === playerId);

  if (cache) {
    mod.DeleteUIWidget(cache.hud);
    playerUICache = playerUICache.filter(ui => ui !== cache);
  }
}
```

## Next Steps

- 📖 [UI Widgets](/api/ui-widgets) - Detailed widget documentation
- 📖 [UI Notifications](/api/ui-notifications) - Message system
- 📖 [modlib Helpers](/api/modlib) - UI utility functions
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip UI System Summary
- **104 UI functions** for complete interface control
- **5 widget types** - Container, Text, Image, Button, ProgressBar
- **Per-player UI** - Each player has independent UI
- **Dynamic updates** - Real-time content changes
- **Hierarchical layout** - Parent-child organization
:::