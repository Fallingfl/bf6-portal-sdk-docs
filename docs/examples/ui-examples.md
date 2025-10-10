# UI Code Examples

Pre-built UI components you can copy and adapt for your game modes.

---

## Simple Scoreboard

```typescript
function createSimpleScoreboard(player: mod.Player) {
  const container = mod.AddUIContainer(
    "scoreboard",
    mod.CreateVector(10, 10, 0),
    mod.CreateVector(300, 100, 0),
    mod.UIAnchor.TopRight,
    null,
    true,
    10,
    mod.CreateVector(0, 0, 0),
    0.8,
    mod.UIBgFill.Solid,
    player
  );

  const team1Score = mod.GetGameModeScore(mod.Team.Team1);
  const team2Score = mod.GetGameModeScore(mod.Team.Team2);

  mod.AddUIText(
    "team1Score",
    mod.Message(`Red Team: ${team1Score}`),
    mod.CreateVector(10, 10, 0),
    mod.CreateVector(280, 35, 0),
    mod.UIAnchor.TopLeft,
    container,
    true,
    20,
    mod.CreateVector(1, 0, 0),
    1.0,
    player
  );

  mod.AddUIText(
    "team2Score",
    mod.Message(`Blue Team: ${team2Score}`),
    mod.CreateVector(10, 50, 0),
    mod.CreateVector(280, 35, 0),
    mod.UIAnchor.TopLeft,
    container,
    true,
    20,
    mod.CreateVector(0, 0, 1),
    1.0,
    player
  );
}
```

---

## Health Bar

```typescript
function createHealthBar(player: mod.Player): mod.UIWidget {
  return mod.AddUIProgressBar(
    "healthBar",
    100,                             // Max value
    mod.GetPlayerHealth(player),     // Current value
    mod.CreateVector(0, -80, 0),
    mod.CreateVector(300, 25, 0),
    mod.UIAnchor.BottomCenter,
    null,
    true,
    mod.CreateVector(0, 1, 0),       // Green bar
    mod.CreateVector(0.2, 0.2, 0.2), // Dark background
    1.0,
    player
  );
}

// Update health bar
async function healthBarLoop(player: mod.Player, healthBar: mod.UIWidget) {
  while (mod.IsAlive(player)) {
    const health = mod.GetPlayerHealth(player);
    mod.SetUIProgressBarValue(healthBar, health);
    await mod.Wait(0.5);
  }
}
```

---

## Kill Feed

```typescript
const killFeedMessages: string[] = [];
const MAX_KILL_FEED_SIZE = 5;

export async function OnPlayerEarnedKill(killer: mod.Player, victim: mod.Player) {
  const message = `${mod.GetPlayerName(killer)} killed ${mod.GetPlayerName(victim)}`;
  killFeedMessages.push(message);

  if (killFeedMessages.length > MAX_KILL_FEED_SIZE) {
    killFeedMessages.shift(); // Remove oldest
  }

  updateKillFeed();
}

function updateKillFeed() {
  const players = modlib.ConvertArray(mod.AllPlayers());

  for (const player of players) {
    // Remove old kill feed
    // ... (store widget references to remove)

    // Create new kill feed
    createKillFeedWidget(player);
  }
}

function createKillFeedWidget(player: mod.Player) {
  const container = mod.AddUIContainer(
    "killFeed",
    mod.CreateVector(10, 200, 0),
    mod.CreateVector(400, 25 * killFeedMessages.length, 0),
    mod.UIAnchor.TopRight,
    null,
    true,
    5,
    mod.CreateVector(0, 0, 0),
    0.6,
    mod.UIBgFill.Solid,
    player
  );

  for (let i = 0; i < killFeedMessages.length; i++) {
    mod.AddUIText(
      `killMsg_${i}`,
      mod.Message(killFeedMessages[i]),
      mod.CreateVector(5, i * 25, 0),
      mod.CreateVector(390, 25, 0),
      mod.UIAnchor.TopLeft,
      container,
      true,
      14,
      mod.CreateVector(1, 1, 1),
      1.0,
      player
    );
  }
}
```

---

## Timer Display

```typescript
async function createTimer(player: mod.Player, duration: number): Promise<mod.UIWidget> {
  const timerWidget = mod.AddUIText(
    "timer",
    mod.Message(`Time: ${duration}s`),
    mod.CreateVector(0, 10, 0),
    mod.CreateVector(200, 40, 0),
    mod.UIAnchor.TopCenter,
    null,
    true,
    24,
    mod.CreateVector(1, 1, 0),
    1.0,
    player
  );

  // Start countdown
  countdownTimer(player, timerWidget, duration);

  return timerWidget;
}

async function countdownTimer(player: mod.Player, widget: mod.UIWidget, duration: number) {
  for (let time = duration; time >= 0; time--) {
    mod.SetUITextLabel(widget, mod.Message(`Time: ${time}s`));

    // Change color when time is low
    if (time <= 10) {
      mod.SetUITextColor(widget, mod.CreateVector(1, 0, 0), player); // Red
    }

    await mod.Wait(1);
  }

  mod.SetUITextLabel(widget, mod.Message("TIME'S UP!"));
}
```

---

## Ready-Up Menu

```typescript
let readyButton: mod.UIButton;
const playerReadyStatus = new Map<mod.Player, boolean>();

export async function OnGameModeStarted() {
  readyButton = mod.AddButtonDefinition("readyButton");
}

function createReadyUpMenu(player: mod.Player) {
  const container = mod.AddUIContainer(
    "readyMenu",
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(400, 300, 0),
    mod.UIAnchor.Center,
    null,
    true,
    20,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.95,
    mod.UIBgFill.Solid,
    player
  );

  // Title
  mod.AddUIText(
    "readyTitle",
    mod.Message("Waiting for Players"),
    mod.CreateVector(0, 20, 0),
    mod.CreateVector(360, 50, 0),
    mod.UIAnchor.TopCenter,
    container,
    true,
    28,
    mod.CreateVector(1, 1, 1),
    1.0,
    player
  );

  // Ready button
  mod.AddUIButton(
    "readyBtn",
    readyButton,
    mod.Message("READY"),
    mod.CreateVector(0, 100, 0),
    mod.CreateVector(300, 60, 0),
    mod.UIAnchor.TopCenter,
    container,
    true,
    true,
    24,
    mod.CreateVector(0, 1, 0),
    1.0,
    player
  );

  // Player count
  const readyCount = Array.from(playerReadyStatus.values()).filter(r => r).length;
  const totalPlayers = modlib.ConvertArray(mod.AllPlayers()).length;

  mod.AddUIText(
    "playerCount",
    mod.Message(`${readyCount}/${totalPlayers} Ready`),
    mod.CreateVector(0, 200, 0),
    mod.CreateVector(360, 40, 0),
    mod.UIAnchor.TopCenter,
    container,
    true,
    20,
    mod.CreateVector(0.8, 0.8, 0.8),
    1.0,
    player
  );
}

export async function OnPlayerButtonPressed(player: mod.Player, button: mod.UIButton) {
  if (button === readyButton) {
    playerReadyStatus.set(player, true);

    mod.DisplayCustomNotificationMessage(
      mod.Message("You are READY!"),
      mod.CustomNotificationSlots.MessageText1,
      2,
      player
    );

    // Update all players' ready menus
    updateReadyMenus();
  }
}
```

---

## Notification Banner

```typescript
async function showBanner(player: mod.Player, message: string, duration: number) {
  const banner = mod.AddUIContainer(
    "banner",
    mod.CreateVector(0, 100, 0),
    mod.CreateVector(600, 80, 0),
    mod.UIAnchor.TopCenter,
    null,
    true,
    10,
    mod.CreateVector(0.2, 0.6, 0.2),
    0.9,
    mod.UIBgFill.Solid,
    player
  );

  mod.AddUIText(
    "bannerText",
    mod.Message(message),
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(580, 60, 0),
    mod.UIAnchor.Center,
    banner,
    true,
    32,
    mod.CreateVector(1, 1, 1),
    1.0,
    player
  );

  await mod.Wait(duration);
  mod.RemoveUIWidget(banner, player);
}
```

---

## Objective Marker

```typescript
function createObjectiveMarker(player: mod.Player, objectiveName: string, objectivePos: mod.Vector) {
  // Calculate distance
  const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
  const distance = Math.sqrt(
    Math.pow(objectivePos.x - playerPos.x, 2) +
    Math.pow(objectivePos.z - playerPos.z, 2)
  );

  const container = mod.AddUIContainer(
    "objectiveMarker",
    mod.CreateVector(0, 150, 0),
    mod.CreateVector(300, 80, 0),
    mod.UIAnchor.TopCenter,
    null,
    true,
    10,
    mod.CreateVector(0.8, 0.6, 0),
    0.8,
    mod.UIBgFill.Solid,
    player
  );

  // Objective name
  mod.AddUIText(
    "objName",
    mod.Message(objectiveName),
    mod.CreateVector(0, 5, 0),
    mod.CreateVector(280, 35, 0),
    mod.UIAnchor.TopCenter,
    container,
    true,
    22,
    mod.CreateVector(1, 1, 1),
    1.0,
    player
  );

  // Distance
  mod.AddUIText(
    "objDistance",
    mod.Message(`${Math.floor(distance)}m`),
    mod.CreateVector(0, 40, 0),
    mod.CreateVector(280, 30, 0),
    mod.UIAnchor.TopCenter,
    container,
    true,
    18,
    mod.CreateVector(0.9, 0.9, 0.9),
    1.0,
    player
  );
}
```

---

★ Insight ─────────────────────────────────────
**UI Component Patterns**
1. **Container-First Design** - Always create a container parent for related elements; enables grouped positioning and removal
2. **Anchoring Strategy** - TopCenter/BottomCenter for notifications, TopRight for scoreboards, Center for modals
3. **Color Psychology** - Red for danger/time warnings, green for health/positive actions, yellow for attention/timers
─────────────────────────────────────────────────
