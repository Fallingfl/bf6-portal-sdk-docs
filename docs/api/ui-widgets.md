# UI Widgets API Reference

Complete reference for all UI widget types and their manipulation functions in the BF6 Portal SDK.

## Overview

The widget system provides 5 widget types with comprehensive control over appearance, behavior, and layout. All widgets support:
- **Hierarchical organization** - Parent-child relationships
- **Per-player visibility** - Each player sees their own UI
- **Dynamic updates** - Real-time property modification
- **Flexible positioning** - 9 anchor points for alignment

## Widget Types

### Container Widgets

Containers group and organize other widgets, providing layout structure and background styling.

#### AddUIContainer

Create a new container widget:

```typescript
// Simple container
mod.AddUIContainer(
  "myContainer",
  mod.CreateVector(10, 10, 0),
  mod.CreateVector(200, 100, 0),
  mod.UIAnchor.TopLeft
);

// Full-featured container
mod.AddUIContainer(
  name: string,               // Unique identifier
  position: Vector,           // Position relative to anchor
  size: Vector,               // Width, height in pixels
  anchor: UIAnchor,           // Alignment point
  parent: UIWidget | null,    // Parent widget (null for root)
  visible: boolean,           // Initial visibility
  padding: number,            // Internal padding in pixels
  bgColor: Vector,            // Background RGB (0-1 per channel)
  bgAlpha: number,            // Background opacity (0-1)
  bgFill: UIBgFill,           // Fill mode (Stretch, Fit, Tile)
  receiver?: Player | Team    // Who sees this widget
): UIWidget
```

**Example - HUD Container:**
```typescript
const hudContainer = mod.AddUIContainer(
  "playerHUD",
  mod.CreateVector(0, 0, 0),
  mod.CreateVector(1920, 1080, 0),
  mod.UIAnchor.TopLeft,
  null,                       // Root-level widget
  true,                       // Visible
  0,                          // No padding
  mod.CreateVector(0, 0, 0),  // Black background
  0,                          // Fully transparent
  mod.UIBgFill.Stretch,
  player                      // Player-specific UI
);
```

---

### Text Widgets

Display text labels, scores, messages, and dynamic content.

#### AddUIText

Create a text widget:

```typescript
// Simple text
mod.AddUIText(
  "scoreLabel",
  mod.CreateVector(10, 10, 0),
  mod.CreateVector(150, 30, 0),
  mod.UIAnchor.TopRight,
  mod.Message("Score: 0")
);

// Full-featured text
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
  textLabel: Message,         // Text content
  textSize: number,           // Font size in pixels
  textColor: Vector,          // Text RGB color
  textAlpha: number,          // Text opacity
  textAnchor: UIAnchor,       // Text alignment within widget
  receiver?: Player | Team
): UIWidget
```

**Example - Score Display:**
```typescript
const scoreText = mod.AddUIText(
  "playerScore",
  mod.CreateVector(10, 10, 0),
  mod.CreateVector(200, 40, 0),
  mod.UIAnchor.TopRight,
  hudContainer,
  true,
  5,
  mod.CreateVector(0.1, 0.1, 0.1),  // Dark gray background
  0.8,
  mod.UIBgFill.Stretch,
  mod.Message("Score: 0"),
  24,                                 // Font size
  mod.CreateVector(1, 1, 0),         // Yellow text
  1.0,
  mod.UIAnchor.Center,               // Center text in widget
  player
);
```

#### SetUITextLabel

Update text content dynamically:

```typescript
// Update score
mod.SetUITextLabel(scoreText, mod.Message(`Score: ${playerScore}`));

// Update timer
mod.SetUITextLabel(timerWidget, mod.Message(`Time: ${Math.floor(timeLeft)}s`));
```

**Color & Styling Functions:**
```typescript
mod.SetUITextColor(widget, mod.CreateVector(1, 0, 0));    // Red
mod.SetUITextAlpha(widget, 0.5);                          // 50% opacity
mod.SetUITextSize(widget, 32);                            // 32px font
mod.SetUITextAnchor(widget, mod.UIAnchor.CenterLeft);    // Left-aligned
```

---

### Image Widgets

Display icons, sprites, and visual elements.

#### AddUIImage

Create an image widget:

```typescript
// Simple image
mod.AddUIImage(
  "healthIcon",
  mod.CreateVector(10, 10, 0),
  mod.CreateVector(32, 32, 0),
  mod.UIAnchor.BottomLeft,
  mod.UIImageType.IconHealth
);

// Full-featured image
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
  imageType: UIImageType,     // Icon/sprite type
  imageColor: Vector,         // Tint color
  imageAlpha: number,         // Image opacity
  receiver?: Player | Team
): UIWidget
```

#### AddUIWeaponImage

Display weapon icons:

```typescript
mod.AddUIWeaponImage(
  "currentWeapon",
  mod.CreateVector(10, 50, 0),
  mod.CreateVector(64, 64, 0),
  mod.UIAnchor.BottomLeft,
  mod.Weapons.AK24,
  hudContainer,
  player
);
```

#### AddUIGadgetImage

Display gadget icons:

```typescript
mod.AddUIGadgetImage(
  "currentGadget",
  mod.CreateVector(10, 120, 0),
  mod.CreateVector(48, 48, 0),
  mod.UIAnchor.BottomLeft,
  mod.Gadgets.MedicalCrate,
  hudContainer,
  player
);
```

**Image Update Functions:**
```typescript
mod.SetUIImageType(widget, mod.UIImageType.IconAmmo);
mod.SetUIImageColor(widget, mod.CreateVector(0, 1, 0));  // Green tint
mod.SetUIImageAlpha(widget, 0.75);
```

---

### Button Widgets

Interactive clickable UI elements.

#### AddUIButton

Create a button widget:

```typescript
// Simple button
mod.AddUIButton(
  "startButton",
  mod.CreateVector(-100, -25, 0),
  mod.CreateVector(200, 50, 0),
  mod.UIAnchor.Center,
  player
);

// Full-featured button
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
  buttonEnabled: boolean,         // Can be clicked
  baseColor: Vector,              // Default state color
  baseAlpha: number,
  disabledColor: Vector,          // Disabled state color
  disabledAlpha: number,
  pressedColor: Vector,           // Clicked state color
  pressedAlpha: number,
  hoverColor: Vector,             // Mouse over color
  hoverAlpha: number,
  focusedColor: Vector,           // Keyboard focus color
  focusedAlpha: number,
  receiver?: Player | Team
): UIWidget
```

**Example - Menu Button:**
```typescript
const startButton = mod.AddUIButton(
  "btnStart",
  mod.CreateVector(-150, 0, 0),
  mod.CreateVector(300, 60, 0),
  mod.UIAnchor.Center,
  menuContainer,
  true,
  5,
  mod.CreateVector(0.2, 0.2, 0.2),
  1.0,
  mod.UIBgFill.Stretch,
  true,                                    // Enabled
  mod.CreateVector(0.3, 0.6, 0.3),        // Green base
  1.0,
  mod.CreateVector(0.2, 0.2, 0.2),        // Gray disabled
  0.5,
  mod.CreateVector(0.2, 0.7, 0.2),        // Bright green pressed
  1.0,
  mod.CreateVector(0.4, 0.7, 0.4),        // Light green hover
  1.0,
  mod.CreateVector(0.5, 0.8, 0.5),        // Lighter green focused
  1.0,
  player
);

// Add button label
mod.AddUIText(
  "btnStartLabel",
  mod.CreateVector(0, 0, 0),
  mod.CreateVector(300, 60, 0),
  mod.UIAnchor.Center,
  startButton,
  true,
  0,
  mod.CreateVector(0, 0, 0),
  0,
  mod.UIBgFill.Stretch,
  mod.Message("START GAME"),
  24,
  mod.CreateVector(1, 1, 1),
  1.0,
  mod.UIAnchor.Center,
  player
);
```

#### Button State Functions

```typescript
// Enable/disable button
mod.SetUIButtonEnabled(button, false);

// Update button colors
mod.SetUIButtonColorBase(button, mod.CreateVector(1, 0, 0));       // Red base
mod.SetUIButtonColorHover(button, mod.CreateVector(1, 0.3, 0.3));  // Light red hover
mod.SetUIButtonColorPressed(button, mod.CreateVector(0.8, 0, 0));  // Dark red pressed

// Update button alphas
mod.SetUIButtonAlphaBase(button, 1.0);
mod.SetUIButtonAlphaDisabled(button, 0.3);
```

#### Button Events

::: warning Button Event System
Button events (click, hover, etc.) are currently **not exposed** in the TypeScript API. Buttons are primarily for visual feedback when using UI input mode with `EnableUIInputMode()`.
:::

---

### Progress Bar Widgets

::: danger Missing Progress Bar API
The `AddUIProgressBar` function is **not currently available** in the SDK TypeScript definitions, despite being mentioned in documentation. Use alternative visualization methods:
- Text with percentage: `"Health: 75%"`
- Image widgets with dynamic sizing
- Multiple image widgets to simulate bar segments
:::

**Workaround - Text-Based Progress:**
```typescript
function updateHealthDisplay(player: mod.Player, health: number, maxHealth: number) {
  const percentage = Math.floor((health / maxHealth) * 100);
  const healthText = mod.FindUIWidgetWithName("healthText", player);

  mod.SetUITextLabel(healthText, mod.Message(`Health: ${percentage}%`));

  // Color-code by health level
  if (percentage > 66) {
    mod.SetUITextColor(healthText, mod.CreateVector(0, 1, 0));  // Green
  } else if (percentage > 33) {
    mod.SetUITextColor(healthText, mod.CreateVector(1, 1, 0));  // Yellow
  } else {
    mod.SetUITextColor(healthText, mod.CreateVector(1, 0, 0));  // Red
  }
}
```

---

## Widget Management

### Finding Widgets

```typescript
// Find widget by name (global search)
const widget = mod.FindUIWidgetWithName("myWidget");

// Find widget by name (player-specific)
const playerWidget = mod.FindUIWidgetWithName("playerHUD", player);

// Find within specific parent
const childWidget = mod.FindUIWidgetWithName("childWidget", parentWidget);

// Check if widget exists
if (mod.HasUIWidgetWithName("scoreDisplay")) {
  // Widget exists
}

if (mod.HasUIWidgetWithName("playerMenu", player)) {
  // Player has this widget
}
```

### Widget Getters

Retrieve widget properties:

```typescript
// Universal widget properties
const name = mod.GetUIWidgetName(widget);
const position = mod.GetUIWidgetPosition(widget);
const size = mod.GetUIWidgetSize(widget);
const anchor = mod.GetUIWidgetAnchor(widget);
const visible = mod.GetUIWidgetVisible(widget);
const parent = mod.GetUIWidgetParent(widget);
const padding = mod.GetUIWidgetPadding(widget);
const bgColor = mod.GetUIWidgetBgColor(widget);
const bgAlpha = mod.GetUIWidgetBgAlpha(widget);
const bgFill = mod.GetUIWidgetBgFill(widget);
const depth = mod.GetUIWidgetDepth(widget);

// Text-specific properties
const textSize = mod.GetUITextSize(textWidget);
const textColor = mod.GetUITextColor(textWidget);
const textAlpha = mod.GetUITextAlpha(textWidget);
const textAnchor = mod.GetUITextAnchor(textWidget);

// Image-specific properties
const imageType = mod.GetUIImageType(imageWidget);
const imageColor = mod.GetUIImageColor(imageWidget);
const imageAlpha = mod.GetUIImageAlpha(imageWidget);

// Button-specific properties
const enabled = mod.GetUIButtonEnabled(buttonWidget);
const baseColor = mod.GetUIButtonColorBase(buttonWidget);
const hoverColor = mod.GetUIButtonColorHover(buttonWidget);
// ... (all button state colors/alphas have getters)
```

### Widget Setters

Update widget properties dynamically:

```typescript
// Universal widget setters
mod.SetUIWidgetName(widget, "newName");
mod.SetUIWidgetPosition(widget, mod.CreateVector(50, 50, 0));
mod.SetUIWidgetSize(widget, mod.CreateVector(300, 200, 0));
mod.SetUIWidgetAnchor(widget, mod.UIAnchor.Center);
mod.SetUIWidgetVisible(widget, true);
mod.SetUIWidgetParent(widget, newParent);
mod.SetUIWidgetPadding(widget, 10);
mod.SetUIWidgetBgColor(widget, mod.CreateVector(0.5, 0.5, 0.5));
mod.SetUIWidgetBgAlpha(widget, 0.9);
mod.SetUIWidgetBgFill(widget, mod.UIBgFill.Fit);
mod.SetUIWidgetDepth(widget, mod.UIDepth.Foreground);
```

### Deleting Widgets

```typescript
// Delete single widget (and all children)
mod.DeleteUIWidget(widget);

// Delete all widgets globally
mod.DeleteAllUIWidgets();

// Clean up player UI on disconnect
export async function OnPlayerLeaveGame(playerId: string) {
  // Widgets are automatically cleaned up when player leaves
  // Manual cleanup not required but can be done if needed
}
```

---

## Common Patterns

### Player HUD System

```typescript
interface PlayerHUD {
  container: mod.UIWidget;
  healthText: mod.UIWidget;
  ammoText: mod.UIWidget;
  scoreText: mod.UIWidget;
}

const playerHUDs = new Map<string, PlayerHUD>();

function createPlayerHUD(player: mod.Player): PlayerHUD {
  const container = mod.AddUIContainer(
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

  const healthText = mod.AddUIText(
    "health",
    mod.CreateVector(10, 10, 0),
    mod.CreateVector(150, 30, 0),
    mod.UIAnchor.BottomLeft,
    container,
    true,
    3,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.7,
    mod.UIBgFill.Stretch,
    mod.Message("Health: 100"),
    20,
    mod.CreateVector(0, 1, 0),
    1.0,
    mod.UIAnchor.CenterLeft,
    player
  );

  const ammoText = mod.AddUIText(
    "ammo",
    mod.CreateVector(10, 45, 0),
    mod.CreateVector(150, 30, 0),
    mod.UIAnchor.BottomLeft,
    container,
    true,
    3,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.7,
    mod.UIBgFill.Stretch,
    mod.Message("Ammo: 30/120"),
    18,
    mod.CreateVector(1, 1, 1),
    1.0,
    mod.UIAnchor.CenterLeft,
    player
  );

  const scoreText = mod.AddUIText(
    "score",
    mod.CreateVector(10, 10, 0),
    mod.CreateVector(200, 40, 0),
    mod.UIAnchor.TopRight,
    container,
    true,
    5,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.8,
    mod.UIBgFill.Stretch,
    mod.Message("Score: 0"),
    24,
    mod.CreateVector(1, 1, 0),
    1.0,
    mod.UIAnchor.Center,
    player
  );

  const hud = { container, healthText, ammoText, scoreText };
  playerHUDs.set(mod.GetPlayerId(player), hud);
  return hud;
}

// Update HUD continuously
async function updateAllHUDs() {
  while (gameRunning) {
    const players = modlib.ConvertArray(mod.AllPlayers());

    for (const player of players) {
      const hud = playerHUDs.get(mod.GetPlayerId(player));
      if (!hud) continue;

      const health = mod.GetSoldierState(player, mod.SoldierStateNumber.CurrentHealth);
      const maxHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.MaxHealth);
      const ammo = mod.GetSoldierState(player, mod.SoldierStateNumber.Ammo);
      const score = mod.GetGameModeScore(player);

      mod.SetUITextLabel(hud.healthText, mod.Message(`Health: ${Math.floor(health)}`));
      mod.SetUITextLabel(hud.ammoText, mod.Message(`Ammo: ${ammo}`));
      mod.SetUITextLabel(hud.scoreText, mod.Message(`Score: ${score}`));
    }

    await mod.Wait(0.1);  // Update 10 times/second
  }
}
```

### Animated Countdown

```typescript
async function showCountdown(player: mod.Player, seconds: number) {
  const countdownText = mod.AddUIText(
    "countdown",
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(200, 100, 0),
    mod.UIAnchor.Center,
    null,
    true,
    0,
    mod.CreateVector(0, 0, 0),
    0,
    mod.UIBgFill.Stretch,
    mod.Message(""),
    72,
    mod.CreateVector(1, 1, 1),
    1.0,
    mod.UIAnchor.Center,
    player
  );

  for (let i = seconds; i > 0; i--) {
    mod.SetUITextLabel(countdownText, mod.Message(i.toString()));

    // Flash effect
    for (let flash = 0; flash < 4; flash++) {
      mod.SetUITextAlpha(countdownText, flash % 2 === 0 ? 1.0 : 0.3);
      await mod.Wait(0.125);
    }
  }

  mod.SetUITextLabel(countdownText, mod.Message("GO!"));
  mod.SetUITextColor(countdownText, mod.CreateVector(0, 1, 0));
  await mod.Wait(1);
  mod.DeleteUIWidget(countdownText);
}
```

### Dynamic Scoreboard

```typescript
interface ScoreboardRow {
  container: mod.UIWidget;
  rank: mod.UIWidget;
  name: mod.UIWidget;
  score: mod.UIWidget;
  kills: mod.UIWidget;
}

const scoreboardRows: ScoreboardRow[] = [];

function createScoreboard(player: mod.Player) {
  const bg = mod.AddUIContainer(
    "scoreboard",
    mod.CreateVector(-500, -400, 0),
    mod.CreateVector(1000, 800, 0),
    mod.UIAnchor.Center,
    null,
    false,  // Hidden initially
    10,
    mod.CreateVector(0, 0, 0),
    0.95,
    mod.UIBgFill.Stretch,
    player
  );

  // Title
  mod.AddUIText(
    "scoreboardTitle",
    mod.CreateVector(0, 20, 0),
    mod.CreateVector(980, 60, 0),
    mod.UIAnchor.TopCenter,
    bg,
    true,
    0,
    mod.CreateVector(0.2, 0.2, 0.2),
    1.0,
    mod.UIBgFill.Stretch,
    mod.Message("SCOREBOARD"),
    36,
    mod.CreateVector(1, 1, 1),
    1.0,
    mod.UIAnchor.Center,
    player
  );

  return bg;
}

function updateScoreboard(scoreboardWidget: mod.UIWidget, player: mod.Player) {
  const players = modlib.ConvertArray(mod.AllPlayers());

  // Sort by score
  players.sort((a, b) => mod.GetGameModeScore(b) - mod.GetGameModeScore(a));

  let yOffset = 100;

  for (let i = 0; i < players.length && i < 16; i++) {
    const p = players[i];

    // Create row if needed
    // ... (create row widgets)

    // Update row data
    const row = scoreboardRows[i];
    mod.SetUITextLabel(row.rank, mod.Message(`#${i + 1}`));
    mod.SetUITextLabel(row.name, mod.Message(mod.GetPlayerName(p)));
    mod.SetUITextLabel(row.score, mod.Message(mod.GetGameModeScore(p).toString()));

    yOffset += 45;
  }
}
```

---

## UI Anchors

Nine anchor positions for widget alignment:

```typescript
mod.UIAnchor.TopLeft       // (0, 0) at top-left
mod.UIAnchor.TopCenter     // (0, 0) at top-center
mod.UIAnchor.TopRight      // (0, 0) at top-right
mod.UIAnchor.CenterLeft    // (0, 0) at middle-left
mod.UIAnchor.Center        // (0, 0) at screen center
mod.UIAnchor.CenterRight   // (0, 0) at middle-right
mod.UIAnchor.BottomLeft    // (0, 0) at bottom-left
mod.UIAnchor.BottomCenter  // (0, 0) at bottom-center
mod.UIAnchor.BottomRight   // (0, 0) at bottom-right
```

**Positioning Behavior:**
- Anchor determines which screen corner/edge is the origin (0,0)
- Position is offset from that anchor point
- Use negative offsets to move toward screen center

**Examples:**
```typescript
// Top-left: 10px from left, 10px from top
position: mod.CreateVector(10, 10, 0),
anchor: mod.UIAnchor.TopLeft

// Center: 100px left of center, 50px above center
position: mod.CreateVector(-100, -50, 0),
anchor: mod.UIAnchor.Center

// Bottom-right: 10px from right edge, 10px from bottom
position: mod.CreateVector(10, 10, 0),
anchor: mod.UIAnchor.BottomRight
```

---

## UI Background Fills

Control how background colors/images fill widget bounds:

```typescript
mod.UIBgFill.Stretch  // Stretch to fill (may distort)
mod.UIBgFill.Fit      // Scale to fit (maintains aspect ratio)
mod.UIBgFill.Tile     // Repeat pattern
```

---

## UI Depth Layers

Control rendering order (z-index):

```typescript
mod.UIDepth.Background   // Render behind other UI
mod.UIDepth.Default      // Normal layer
mod.UIDepth.Foreground   // Render in front of other UI
```

---

## UI Input Mode

Enable cursor and UI interaction:

```typescript
// Enable UI input (shows cursor, allows clicks)
mod.EnableUIInputMode(player, true, true);

// Disable UI input (hides cursor, gameplay resumes)
mod.EnableUIInputMode(player, false, false);
```

::: tip Menu Toggle Pattern
```typescript
let menuOpen = false;

function toggleMenu(player: mod.Player) {
  const menu = mod.FindUIWidgetWithName("mainMenu", player);
  menuOpen = !menuOpen;

  mod.SetUIWidgetVisible(menu, menuOpen);
  mod.EnableUIInputMode(player, menuOpen, menuOpen);

  if (menuOpen) {
    // Prevent shooting while menu is open
    mod.EnableInputRestriction(player, mod.RestrictedInputs.FireWeapon, true);
  } else {
    mod.EnableInputRestriction(player, mod.RestrictedInputs.FireWeapon, false);
  }
}
```
:::

---

## Best Practices

### 1. Use Descriptive Names

```typescript
// ❌ Bad
mod.AddUIContainer("c1", ...);

// ✅ Good
mod.AddUIContainer("playerHealthContainer", ...);
```

### 2. Cache Widget References

```typescript
// ❌ Bad - Searching every frame
async function updateScore() {
  while (true) {
    const widget = mod.FindUIWidgetWithName("score", player);
    mod.SetUITextLabel(widget, mod.Message(`Score: ${score}`));
    await mod.Wait(0.1);
  }
}

// ✅ Good - Cache reference
const scoreWidget = mod.FindUIWidgetWithName("score", player);

async function updateScore() {
  while (true) {
    mod.SetUITextLabel(scoreWidget, mod.Message(`Score: ${score}`));
    await mod.Wait(0.1);
  }
}
```

### 3. Organize with Containers

```typescript
// Create logical hierarchy
const hud = createHUDContainer();
const healthSection = createHealthSection(hud);
const weaponSection = createWeaponSection(hud);
const scoreSection = createScoreSection(hud);
```

### 4. Update Only When Changed

```typescript
let lastHealth = 100;

async function updateHealth() {
  while (true) {
    const currentHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.CurrentHealth);

    // Only update if changed
    if (currentHealth !== lastHealth) {
      mod.SetUITextLabel(healthWidget, mod.Message(`Health: ${currentHealth}`));
      lastHealth = currentHealth;
    }

    await mod.Wait(0.1);
  }
}
```

### 5. Clean Up Properly

```typescript
// Delete parent widget to delete all children
mod.DeleteUIWidget(hudContainer);  // Deletes all child widgets too
```

---

## Widget Functions Summary

| Category | Functions |
|----------|-----------|
| **Create** | AddUIContainer, AddUIText, AddUIImage, AddUIButton, AddUIWeaponImage, AddUIGadgetImage |
| **Find** | FindUIWidgetWithName, HasUIWidgetWithName, GetUIRoot |
| **Universal Getters** | GetUIWidgetName, GetUIWidgetPosition, GetUIWidgetSize, GetUIWidgetAnchor, GetUIWidgetVisible, GetUIWidgetParent, GetUIWidgetPadding, GetUIWidgetBgColor, GetUIWidgetBgAlpha, GetUIWidgetBgFill, GetUIWidgetDepth |
| **Universal Setters** | SetUIWidgetName, SetUIWidgetPosition, SetUIWidgetSize, SetUIWidgetAnchor, SetUIWidgetVisible, SetUIWidgetParent, SetUIWidgetPadding, SetUIWidgetBgColor, SetUIWidgetBgAlpha, SetUIWidgetBgFill, SetUIWidgetDepth |
| **Text Getters** | GetUITextSize, GetUITextColor, GetUITextAlpha, GetUITextAnchor |
| **Text Setters** | SetUITextLabel, SetUITextSize, SetUITextColor, SetUITextAlpha, SetUITextAnchor |
| **Image Getters** | GetUIImageType, GetUIImageColor, GetUIImageAlpha |
| **Image Setters** | SetUIImageType, SetUIImageColor, SetUIImageAlpha |
| **Button Getters** | GetUIButtonEnabled, GetUIButtonColorBase, GetUIButtonAlphaBase, GetUIButtonColorDisabled, GetUIButtonAlphaDisabled, GetUIButtonColorPressed, GetUIButtonAlphaPressed, GetUIButtonColorHover, GetUIButtonAlphaHover, GetUIButtonColorFocused, GetUIButtonAlphaFocused |
| **Button Setters** | SetUIButtonEnabled, SetUIButtonColorBase, SetUIButtonAlphaBase, SetUIButtonColorDisabled, SetUIButtonAlphaDisabled, SetUIButtonColorPressed, SetUIButtonAlphaPressed, SetUIButtonColorHover, SetUIButtonAlphaHover, SetUIButtonColorFocused, SetUIButtonAlphaFocused, EnableUIButtonEvent |
| **Delete** | DeleteUIWidget, DeleteAllUIWidgets |

**Total: ~104 UI widget functions**

---

## See Also

- 📖 [UI Overview](/api/ui-overview) - High-level UI concepts
- 📖 [UI Notifications](/api/ui-notifications) - Message system
- 📖 [modlib.ParseUI()](/api/modlib#parseui) - Declarative UI builder
- 📖 [Player Control](/api/player-control) - Input restrictions and control

---

★ Insight ─────────────────────────────────────
**Widget System Design**
1. **Per-Player Isolation** - Each player's UI exists in a separate instance, preventing interference between players
2. **Hierarchical Cleanup** - Deleting a parent widget automatically deletes all children, preventing memory leaks
3. **State Machine Buttons** - Buttons support 5 visual states (base, disabled, pressed, hover, focused) for rich interaction feedback
─────────────────────────────────────────────────
