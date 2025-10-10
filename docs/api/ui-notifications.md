# UI Notifications API Reference

Complete reference for the notification and messaging system in the BF6 Portal SDK.

## Overview

The notification system provides on-screen messages and alerts with:
- **5 notification slots** - Dedicated screen positions
- **Per-player targeting** - Show messages to specific players/teams
- **Timed display** - Auto-dismiss after duration
- **Custom messages** - Full control over content

## Notification Slots

Five distinct slots for displaying notifications:

```typescript
mod.CustomNotificationSlots.HeaderText    // Top-center, large text
mod.CustomNotificationSlots.MessageText1  // Upper-middle
mod.CustomNotificationSlots.MessageText2  // Middle
mod.CustomNotificationSlots.MessageText3  // Lower-middle
mod.CustomNotificationSlots.MessageText4  // Bottom area
```

### Slot Positioning

```
┌───────────────────────────────────┐
│         HeaderText (large)         │  ← CustomNotificationSlots.HeaderText
├───────────────────────────────────┤
│                                    │
│         MessageText1               │  ← CustomNotificationSlots.MessageText1
│                                    │
│         MessageText2               │  ← CustomNotificationSlots.MessageText2
│                                    │
│         MessageText3               │  ← CustomNotificationSlots.MessageText3
│                                    │
│         MessageText4               │  ← CustomNotificationSlots.MessageText4
└───────────────────────────────────┘
```

---

## Displaying Notifications

### DisplayCustomNotificationMessage

Show a message in a specific slot:

```typescript
// Basic notification (all players)
mod.DisplayCustomNotificationMessage(
  message: Message,
  slot: CustomNotificationSlots,
  duration: number  // Seconds to display
): void

// Player-specific notification
mod.DisplayCustomNotificationMessage(
  message: Message,
  slot: CustomNotificationSlots,
  duration: number,
  target: Player
): void

// Team-specific notification
mod.DisplayCustomNotificationMessage(
  message: Message,
  slot: CustomNotificationSlots,
  duration: number,
  target: Team
): void
```

**Example - Welcome Message:**
```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  mod.DisplayCustomNotificationMessage(
    mod.Message("Welcome to the server!"),
    mod.CustomNotificationSlots.HeaderText,
    3,  // 3 seconds
    player
  );
}
```

**Example - Kill Notification:**
```typescript
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  // Notify killer
  mod.DisplayCustomNotificationMessage(
    mod.Message(`You eliminated ${mod.GetPlayerName(victim)}`),
    mod.CustomNotificationSlots.MessageText1,
    2,
    killer
  );

  // Notify victim
  mod.DisplayCustomNotificationMessage(
    mod.Message(`Eliminated by ${mod.GetPlayerName(killer)}`),
    mod.CustomNotificationSlots.MessageText1,
    2,
    victim
  );
}
```

**Example - Team Notification:**
```typescript
function announceCapturePoint(team: mod.Team, pointName: string) {
  mod.DisplayCustomNotificationMessage(
    mod.Message(`${pointName} captured!`),
    mod.CustomNotificationSlots.HeaderText,
    3,
    team  // Only show to capturing team
  );
}
```

**Example - Global Announcement:**
```typescript
async function showCountdown() {
  for (let i = 5; i > 0; i--) {
    mod.DisplayCustomNotificationMessage(
      mod.Message(`Game starting in ${i}...`),
      mod.CustomNotificationSlots.HeaderText,
      1  // 1 second per number
    );
    await mod.Wait(1);
  }

  mod.DisplayCustomNotificationMessage(
    mod.Message("GO!"),
    mod.CustomNotificationSlots.HeaderText,
    2
  );
}
```

---

## Clearing Notifications

### ClearCustomNotificationMessage

Clear a specific slot:

```typescript
// Clear for all players
mod.ClearCustomNotificationMessage(slot: CustomNotificationSlots): void

// Clear for specific player
mod.ClearCustomNotificationMessage(slot: CustomNotificationSlots, target: Player): void

// Clear for team
mod.ClearCustomNotificationMessage(slot: CustomNotificationSlots, target: Team): void
```

**Example - Clear Slot:**
```typescript
// Clear header text
mod.ClearCustomNotificationMessage(mod.CustomNotificationSlots.HeaderText);

// Clear player-specific message
mod.ClearCustomNotificationMessage(
  mod.CustomNotificationSlots.MessageText1,
  player
);
```

### ClearAllCustomNotificationMessages

Clear all notification slots for a player:

```typescript
mod.ClearAllCustomNotificationMessages(target: Player): void
```

**Example - Clean UI on Death:**
```typescript
export async function OnPlayerDied(player: mod.Player) {
  // Clear all notifications when player dies
  mod.ClearAllCustomNotificationMessages(player);
}
```

---

## Common Patterns

### Multi-Line Notifications

Use multiple slots for complex messages:

```typescript
function showObjectiveUpdate(player: mod.Player) {
  mod.DisplayCustomNotificationMessage(
    mod.Message("NEW OBJECTIVE"),
    mod.CustomNotificationSlots.HeaderText,
    5,
    player
  );

  mod.DisplayCustomNotificationMessage(
    mod.Message("Capture Point A"),
    mod.CustomNotificationSlots.MessageText1,
    5,
    player
  );

  mod.DisplayCustomNotificationMessage(
    mod.Message("Defend for 60 seconds"),
    mod.CustomNotificationSlots.MessageText2,
    5,
    player
  );
}
```

### Persistent Status Display

Show ongoing status with periodic updates:

```typescript
async function showGameTimer() {
  const matchDuration = 600;  // 10 minutes

  while (gameRunning) {
    const elapsed = mod.GetGameTime();
    const remaining = matchDuration - elapsed;
    const minutes = Math.floor(remaining / 60);
    const seconds = Math.floor(remaining % 60);

    mod.DisplayCustomNotificationMessage(
      mod.Message(`Time: ${minutes}:${seconds.toString().padStart(2, '0')}`),
      mod.CustomNotificationSlots.MessageText4,
      1.5  // Slightly longer than update interval
    );

    await mod.Wait(1);
  }
}
```

### Progressive Notifications

Show sequence of messages:

```typescript
async function showTutorial(player: mod.Player) {
  const tips = [
    "Use WASD to move",
    "Press SPACE to jump",
    "Click to shoot",
    "Press R to reload",
    "Good luck!"
  ];

  for (const tip of tips) {
    mod.DisplayCustomNotificationMessage(
      mod.Message(tip),
      mod.CustomNotificationSlots.MessageText2,
      3,
      player
    );
    await mod.Wait(3.5);  // Slightly longer than display duration
  }
}
```

### Score Notifications

Show score changes:

```typescript
function notifyScoreChange(player: mod.Player, points: number, reason: string) {
  const message = points > 0
    ? `+${points} ${reason}`
    : `${points} ${reason}`;

  const color = points > 0 ? "green" : "red";

  mod.DisplayCustomNotificationMessage(
    mod.Message(message),
    mod.CustomNotificationSlots.MessageText3,
    2,
    player
  );
}

// Usage
export async function OnPlayerEarnedKill(killer: mod.Player) {
  notifyScoreChange(killer, 100, "Kill");
}
```

### Zone Entry/Exit Notifications

```typescript
const CONDITION_IN_ZONE = 0;

async function trackZoneNotifications() {
  const players = modlib.ConvertArray(mod.AllPlayers());

  while (gameRunning) {
    for (const player of players) {
      const inZone = isPlayerInZone(player);
      const zoneCondition = modlib.getPlayerCondition(player, CONDITION_IN_ZONE);

      if (zoneCondition.update(inZone)) {
        // Entered zone
        mod.DisplayCustomNotificationMessage(
          mod.Message("Entered objective area"),
          mod.CustomNotificationSlots.MessageText1,
          2,
          player
        );
      } else if (zoneCondition.updateExit(!inZone)) {
        // Exited zone
        mod.DisplayCustomNotificationMessage(
          mod.Message("Left objective area"),
          mod.CustomNotificationSlots.MessageText1,
          2,
          player
        );
      }
    }

    await mod.Wait(0.5);
  }
}
```

---

## Helper Functions (modlib)

The `modlib` library provides simplified notification functions:

### modlib.DisplayCustomNotificationMessage

Simplified notification display:

```typescript
modlib.DisplayCustomNotificationMessage(
  message: mod.Message,
  slot: mod.CustomNotificationSlots,
  duration: number,
  target?: mod.Player | mod.Team
): void
```

**Advantages:**
- Consistent parameter order
- Optional target (defaults to all players)
- Matches core API signature

**Example:**
```typescript
import * as modlib from './modlib';

// Show to all players
modlib.DisplayCustomNotificationMessage(
  mod.Message("Round starting!"),
  mod.CustomNotificationSlots.HeaderText,
  3
);

// Show to specific player
modlib.DisplayCustomNotificationMessage(
  mod.Message("You are the last player alive!"),
  mod.CustomNotificationSlots.HeaderText,
  5,
  player
);
```

---

## Notification Best Practices

### 1. Use Appropriate Slots

```typescript
// ✅ Good - Header for important events
mod.DisplayCustomNotificationMessage(
  mod.Message("MATCH STARTED"),
  mod.CustomNotificationSlots.HeaderText,
  3
);

// ✅ Good - Lower slots for status updates
mod.DisplayCustomNotificationMessage(
  mod.Message("Ammo pickup available"),
  mod.CustomNotificationSlots.MessageText4,
  2
);

// ❌ Bad - Header for minor events
mod.DisplayCustomNotificationMessage(
  mod.Message("Reloading..."),
  mod.CustomNotificationSlots.HeaderText,  // Too prominent
  1
);
```

### 2. Manage Duration Appropriately

```typescript
// ✅ Good - Short duration for frequent updates
mod.DisplayCustomNotificationMessage(
  mod.Message(`Ammo: ${ammo}`),
  mod.CustomNotificationSlots.MessageText4,
  1  // Updates every second
);

// ✅ Good - Longer duration for important info
mod.DisplayCustomNotificationMessage(
  mod.Message("New objective: Capture Point A"),
  mod.CustomNotificationSlots.HeaderText,
  5  // Player has time to read
);

// ❌ Bad - Too short for important message
mod.DisplayCustomNotificationMessage(
  mod.Message("You must complete objective within 10 seconds"),
  mod.CustomNotificationSlots.MessageText1,
  0.5  // Not enough time to read
);
```

### 3. Target Appropriately

```typescript
// ✅ Good - Personal notifications to specific player
export async function OnPlayerDied(player: mod.Player) {
  mod.DisplayCustomNotificationMessage(
    mod.Message("You died!"),
    mod.CustomNotificationSlots.HeaderText,
    2,
    player  // Only show to dead player
  );
}

// ✅ Good - Team-wide coordination
function notifyTeamObjective(team: mod.Team) {
  mod.DisplayCustomNotificationMessage(
    mod.Message("Your team must defend the objective"),
    mod.CustomNotificationSlots.HeaderText,
    4,
    team  // Only show to relevant team
  );
}

// ❌ Bad - Spamming all players with personal info
function notifyAmmo(player: mod.Player, ammo: number) {
  mod.DisplayCustomNotificationMessage(
    mod.Message(`${mod.GetPlayerName(player)} has ${ammo} ammo`),
    mod.CustomNotificationSlots.MessageText1,
    1
    // Missing target - shows to everyone
  );
}
```

### 4. Avoid Slot Conflicts

```typescript
// ❌ Bad - Overwriting notifications in same slot
async function badNotifications() {
  mod.DisplayCustomNotificationMessage(
    mod.Message("First message"),
    mod.CustomNotificationSlots.MessageText1,
    5
  );

  // This immediately overwrites the first message!
  mod.DisplayCustomNotificationMessage(
    mod.Message("Second message"),
    mod.CustomNotificationSlots.MessageText1,  // Same slot!
    5
  );
}

// ✅ Good - Use different slots or wait
async function goodNotifications() {
  mod.DisplayCustomNotificationMessage(
    mod.Message("First message"),
    mod.CustomNotificationSlots.MessageText1,
    3
  );

  await mod.Wait(3.5);  // Wait for first to finish

  mod.DisplayCustomNotificationMessage(
    mod.Message("Second message"),
    mod.CustomNotificationSlots.MessageText1,
    3
  );
}

// ✅ Better - Use different slots for simultaneous messages
function simultaneousNotifications() {
  mod.DisplayCustomNotificationMessage(
    mod.Message("First message"),
    mod.CustomNotificationSlots.MessageText1,
    5
  );

  mod.DisplayCustomNotificationMessage(
    mod.Message("Second message"),
    mod.CustomNotificationSlots.MessageText2,  // Different slot
    5
  );
}
```

### 5. Clear When Appropriate

```typescript
// ✅ Good - Clear stale information
export async function OnPlayerLeaveGame(playerId: string) {
  const players = modlib.ConvertArray(mod.AllPlayers());

  for (const player of players) {
    // Clear any player-specific messages when someone leaves
    mod.ClearCustomNotificationMessage(
      mod.CustomNotificationSlots.MessageText1,
      player
    );
  }
}

// ✅ Good - Clear on state change
function endRound() {
  const players = modlib.ConvertArray(mod.AllPlayers());

  for (const player of players) {
    mod.ClearAllCustomNotificationMessages(player);
  }
}
```

---

## Notification Limitations

::: warning Notification Constraints
1. **No Styling Control** - Cannot change font, color, or position beyond slot selection
2. **No Icons/Images** - Text-only messages
3. **No Player Dismissal** - Players cannot manually close notifications
4. **No Queue System** - New messages immediately overwrite previous in same slot
:::

**Workaround - Custom Styled Notifications:**

Use the UI Widget system for more control:

```typescript
function showStyledNotification(player: mod.Player, message: string, color: mod.Vector) {
  const notification = mod.AddUIText(
    "customNotif",
    mod.CreateVector(0, -200, 0),
    mod.CreateVector(400, 60, 0),
    mod.UIAnchor.Center,
    null,
    true,
    5,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.9,
    mod.UIBgFill.Stretch,
    mod.Message(message),
    24,
    color,
    1.0,
    mod.UIAnchor.Center,
    player
  );

  // Auto-remove after duration
  setTimeout(() => mod.DeleteUIWidget(notification), 3000);
}
```

---

## API Functions Summary

| Function | Description |
|----------|-------------|
| **DisplayCustomNotificationMessage** | Show message in specific slot (global, player, or team) |
| **ClearCustomNotificationMessage** | Clear specific notification slot |
| **ClearAllCustomNotificationMessages** | Clear all slots for a player |

**Notification Slots:** 5 (HeaderText, MessageText1-4)

---

## See Also

- 📖 [UI Overview](/api/ui-overview) - Complete UI system
- 📖 [UI Widgets](/api/ui-widgets) - Custom UI elements
- 📖 [modlib Helpers](/api/modlib) - Notification utilities
- 📖 [Player Control](/api/player-control) - Player state and events

---

★ Insight ─────────────────────────────────────
**Notification System Design**
1. **Slot-Based Architecture** - Five predefined slots prevent layout conflicts and maintain consistent positioning
2. **Auto-Dismiss Pattern** - Duration-based display eliminates need for manual cleanup in most cases
3. **Flexible Targeting** - Same function signature handles global, player-specific, and team-specific messaging
─────────────────────────────────────────────────
