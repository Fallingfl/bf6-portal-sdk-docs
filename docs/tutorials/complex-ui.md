# Complex UI Layouts

Master advanced UI techniques for building scoreboards and dynamic layouts.

**Difficulty:** ★★★★☆ | **Time:** 40 minutes

---

## What You'll Learn

- Container hierarchies
- Dynamic UI generation
- UI animations (fade in/out)
- Responsive layouts

---

## Container Hierarchy

```typescript
// Root container
const rootContainer = mod.AddUIContainer(
  "root",
  mod.CreateVector(0, 0, 0),
  mod.CreateVector(600, 400, 0),
  mod.UIAnchor.Center,
  null,
  true,
  0,
  mod.CreateVector(0, 0, 0),
  0.8,
  mod.UIBgFill.Solid,
  player
);

// Header (child of root)
const header = mod.AddUIContainer(
  "header",
  mod.CreateVector(0, 0, 0),
  mod.CreateVector(600, 60, 0),
  mod.UIAnchor.TopCenter,
  rootContainer,
  true,
  10,
  mod.CreateVector(0.2, 0.2, 0.2),
  1.0,
  mod.UIBgFill.Solid,
  player
);

// Content (child of root, below header)
const content = mod.AddUIContainer(
  "content",
  mod.CreateVector(0, 60, 0),
  mod.CreateVector(600, 340, 0),
  mod.UIAnchor.TopCenter,
  rootContainer,
  true,
  10,
  mod.CreateVector(0.1, 0.1, 0.1),
  1.0,
  mod.UIBgFill.Solid,
  player
);
```

---

## Dynamic Scoreboard

```typescript
function createScoreboard(player: mod.Player) {
  const players = modlib.ConvertArray(mod.AllPlayers());

  // Sort by score
  players.sort((a, b) => mod.GetGameModeScore(b) - mod.GetGameModeScore(a));

  // Container
  const scoreboard = mod.AddUIContainer(
    "scoreboard",
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(500, 60 + players.length * 40, 0),
    mod.UIAnchor.Center,
    null,
    true,
    10,
    mod.CreateVector(0, 0, 0),
    0.9,
    mod.UIBgFill.Solid,
    player
  );

  // Title
  mod.AddUIText(
    "title",
    mod.Message("SCOREBOARD"),
    mod.CreateVector(0, 10, 0),
    mod.CreateVector(480, 40, 0),
    mod.UIAnchor.TopCenter,
    scoreboard,
    true,
    24,
    mod.CreateVector(1, 1, 1),
    1.0,
    player
  );

  // Player rows
  for (let i = 0; i < players.length; i++) {
    createPlayerRow(player, scoreboard, players[i], i, 60 + i * 40);
  }
}

function createPlayerRow(
  viewer: mod.Player,
  parent: mod.UIWidget,
  player: mod.Player,
  rank: number,
  yPos: number
) {
  // Row container
  const row = mod.AddUIContainer(
    `row_${rank}`,
    mod.CreateVector(10, yPos, 0),
    mod.CreateVector(480, 35, 0),
    mod.UIAnchor.TopLeft,
    parent,
    true,
    5,
    mod.CreateVector(0.15, 0.15, 0.15),
    1.0,
    mod.UIBgFill.Solid,
    viewer
  );

  // Rank
  mod.AddUIText(
    `rank_${rank}`,
    mod.Message(`#${rank + 1}`),
    mod.CreateVector(5, 0, 0),
    mod.CreateVector(40, 35, 0),
    mod.UIAnchor.TopLeft,
    row,
    true,
    18,
    mod.CreateVector(1, 1, 0),
    1.0,
    viewer
  );

  // Name
  mod.AddUIText(
    `name_${rank}`,
    mod.Message(mod.GetPlayerName(player)),
    mod.CreateVector(50, 0, 0),
    mod.CreateVector(300, 35, 0),
    mod.UIAnchor.TopLeft,
    row,
    true,
    18,
    mod.CreateVector(1, 1, 1),
    1.0,
    viewer
  );

  // Score
  mod.AddUIText(
    `score_${rank}`,
    mod.Message(`${mod.GetGameModeScore(player)}`),
    mod.CreateVector(360, 0, 0),
    mod.CreateVector(110, 35, 0),
    mod.UIAnchor.TopLeft,
    row,
    true,
    18,
    mod.CreateVector(0, 1, 0),
    1.0,
    viewer
  );
}
```

---

## Fade In/Out

```typescript
async function fadeIn(widget: mod.UIWidget, player: mod.Player) {
  for (let alpha = 0; alpha <= 1; alpha += 0.1) {
    mod.SetUIAlpha(widget, alpha, player);
    await mod.Wait(0.05);
  }
}

async function fadeOut(widget: mod.UIWidget, player: mod.Player) {
  for (let alpha = 1; alpha >= 0; alpha -= 0.1) {
    mod.SetUIAlpha(widget, alpha, player);
    await mod.Wait(0.05);
  }
}

// Usage
async function showNotification(player: mod.Player, message: string) {
  const notification = mod.AddUIText(...);
  await fadeIn(notification, player);
  await mod.Wait(3);
  await fadeOut(notification, player);
  mod.RemoveUIWidget(notification, player);
}
```

---

## Next Steps

- [Building a Simple UI](/tutorials/simple-ui)
- [UI Widgets API](/api/ui-widgets)

---

★ Insight ─────────────────────────────────────
**UI Hierarchy**
1. **Parent Relative Positioning** - Child widgets position relative to parent, making layout adjustments easier
2. **Dynamic Generation** - Creating UI in loops enables scoreboards that scale with player count
3. **Alpha Animations** - Smooth fade transitions improve perceived polish without complex animation systems
─────────────────────────────────────────────────
