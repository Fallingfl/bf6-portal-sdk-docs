# Common Code Patterns

Frequently used code patterns and utilities you can copy into your game modes.

---

## Player Proximity Detection

Find all players within a radius of a position:

```typescript
function getPlayersNearPosition(position: mod.Vector, radius: number): mod.Player[] {
  const players = modlib.ConvertArray(mod.AllPlayers());
  const nearbyPlayers: mod.Player[] = [];

  for (const player of players) {
    const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
    const distance = vectorDistance(position, playerPos);

    if (distance <= radius) {
      nearbyPlayers.push(player);
    }
  }

  return nearbyPlayers;
}

function vectorDistance(a: mod.Vector, b: mod.Vector): number {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const dz = b.z - a.z;
  return Math.sqrt(dx * dx + dy * dy + dz * dz);
}
```

---

## Circular Zone Check

Check if a player is inside a 2D circle (ignores height):

```typescript
function isPlayerInCircle(player: mod.Player, center: mod.Vector, radius: number): boolean {
  const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
  const dx = playerPos.x - center.x;
  const dz = playerPos.z - center.z;
  const distance2D = Math.sqrt(dx * dx + dz * dz);
  return distance2D <= radius;
}
```

---

## Grid Positioning

Position objects or players in a grid pattern:

```typescript
function getGridPosition(
  index: number,
  gridWidth: number,
  spacing: number,
  origin: mod.Vector
): mod.Vector {
  const row = Math.floor(index / gridWidth);
  const col = index % gridWidth;

  return mod.CreateVector(
    origin.x + col * spacing,
    origin.y,
    origin.z + row * spacing
  );
}

// Usage: Spawn players in 4x4 grid
function spawnPlayersInGrid() {
  const players = modlib.ConvertArray(mod.AllPlayers());
  const origin = mod.CreateVector(0, 0, 0);

  for (let i = 0; i < players.length; i++) {
    const spawnPos = getGridPosition(i, 4, 5, origin);
    mod.TeleportPlayer(players[i], spawnPos, mod.CreateVector(0, 0, 0));
  }
}
```

---

## Circle Spawn Pattern

Spawn players in a circle:

```typescript
function getCirclePosition(center: mod.Vector, radius: number, angle: number): mod.Vector {
  const radians = angle * (Math.PI / 180);
  return mod.CreateVector(
    center.x + radius * Math.cos(radians),
    center.y,
    center.z + radius * Math.sin(radians)
  );
}

function spawnPlayersInCircle() {
  const players = modlib.ConvertArray(mod.AllPlayers());
  const centerPos = mod.CreateVector(0, 0, 0);
  const radius = 20;
  const angleStep = 360 / players.length;

  for (let i = 0; i < players.length; i++) {
    const spawnPos = getCirclePosition(centerPos, radius, i * angleStep);
    mod.TeleportPlayer(players[i], spawnPos, mod.CreateVector(0, 0, 0));
  }
}
```

---

## Countdown Timer

Visual countdown with UI:

```typescript
async function showCountdown(player: mod.Player, seconds: number) {
  const timerText = mod.AddUIText(
    "countdown",
    mod.Message(`${seconds}`),
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(200, 100, 0),
    mod.UIAnchor.Center,
    null,
    true,
    72,
    mod.CreateVector(1, 1, 0),
    1.0,
    player
  );

  for (let i = seconds; i > 0; i--) {
    mod.SetUITextLabel(timerText, mod.Message(`${i}`));
    await mod.Wait(1);
  }

  mod.SetUITextLabel(timerText, mod.Message("GO!"));
  await mod.Wait(1);
  mod.RemoveUIWidget(timerText, player);
}
```

---

## Random Element Selection

```typescript
function randomElement<T>(array: T[]): T {
  return array[Math.floor(Math.random() * array.length)];
}

// Usage
const weapons = [mod.Weapons.M5A3, mod.Weapons.AK_24, mod.Weapons.PKP_BP];
const randomWeapon = randomElement(weapons);
mod.AddEquipment(player, randomWeapon, 1);
```

---

## Team Balance Checker

```typescript
function getTeamImbalance(): number {
  const team1 = modlib.ConvertArray(mod.GetPlayersInTeam(mod.Team.Team1));
  const team2 = modlib.ConvertArray(mod.GetPlayersInTeam(mod.Team.Team2));
  return Math.abs(team1.length - team2.length);
}

function isTeamBalanced(maxImbalance: number = 1): boolean {
  return getTeamImbalance() <= maxImbalance;
}
```

---

## Async Retry Logic

```typescript
async function retryOperation<T>(
  operation: () => Promise<T>,
  maxRetries: number = 3,
  delayMs: number = 1000
): Promise<T | null> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      console.log(`Attempt ${attempt + 1} failed: ${error}`);
      if (attempt < maxRetries - 1) {
        await mod.Wait(delayMs / 1000);
      }
    }
  }
  return null;
}
```

---

## Kill Streak Tracker

```typescript
const killStreaks = new Map<mod.Player, number>();

export async function OnPlayerEarnedKill(player: mod.Player) {
  const streak = (killStreaks.get(player) || 0) + 1;
  killStreaks.set(player, streak);

  if (streak === 5) {
    mod.DisplayCustomNotificationMessage(
      mod.Message("KILLING SPREE!"),
      mod.CustomNotificationSlots.HeaderText,
      3,
      player
    );
  } else if (streak === 10) {
    mod.DisplayCustomNotificationMessage(
      mod.Message("UNSTOPPABLE!"),
      mod.CustomNotificationSlots.HeaderText,
      3,
      player
    );
  }
}

export async function OnPlayerDied(player: mod.Player) {
  killStreaks.set(player, 0);
}
```

---

## State Machine Pattern

```typescript
enum GameState {
  Waiting,
  Countdown,
  Active,
  Ending
}

let currentState = GameState.Waiting;

async function stateMachine() {
  while (true) {
    switch (currentState) {
      case GameState.Waiting:
        await handleWaitingState();
        break;

      case GameState.Countdown:
        await handleCountdownState();
        break;

      case GameState.Active:
        await handleActiveState();
        break;

      case GameState.Ending:
        await handleEndingState();
        break;
    }

    await mod.Wait(0.1);
  }
}

async function handleWaitingState() {
  // Wait for minimum players
  const players = modlib.ConvertArray(mod.AllPlayers());
  if (players.length >= 2) {
    currentState = GameState.Countdown;
  }
}

async function handleCountdownState() {
  // Show countdown
  for (let i = 3; i > 0; i--) {
    console.log(`Starting in ${i}...`);
    await mod.Wait(1);
  }
  currentState = GameState.Active;
}

async function handleActiveState() {
  // Game is running
  // Check for end conditions
}

async function handleEndingState() {
  // Show results
  await mod.Wait(5);
  currentState = GameState.Waiting;
}
```

---

## Clamp Utility

```typescript
function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

// Usage
const health = clamp(damage, 0, 100);
```

---

## Linear Interpolation (Lerp)

```typescript
function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t;
}

function lerpVector(a: mod.Vector, b: mod.Vector, t: number): mod.Vector {
  return mod.CreateVector(
    lerp(a.x, b.x, t),
    lerp(a.y, b.y, t),
    lerp(a.z, b.z, t)
  );
}

// Smooth movement
async function moveObjectSmoothly(obj: mod.SpatialObject, from: mod.Vector, to: mod.Vector) {
  for (let t = 0; t <= 1; t += 0.05) {
    const currentPos = lerpVector(from, to, t);
    mod.SetObjectTransform(obj, currentPos, mod.CreateVector(0, 0, 0));
    await mod.Wait(0.05);
  }
}
```

---

★ Insight ─────────────────────────────────────
**Pattern Reusability**
1. **Generic Functions** - TypeScript generics (`<T>`) enable type-safe utility functions that work with any data
2. **Separation of Concerns** - Math utilities (distance, lerp) are pure functions, decoupled from game logic
3. **State Machines** - Explicit state enums prevent invalid transitions and make game flow debuggable
─────────────────────────────────────────────────
