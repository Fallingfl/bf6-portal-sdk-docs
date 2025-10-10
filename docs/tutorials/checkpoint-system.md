# Checkpoint System

Build a checkpoint-based progression system with area triggers and validation.

**Difficulty:** ★★★☆☆ | **Time:** 30 minutes | **Prerequisites:** Event hooks, UI basics

---

## What You'll Build

A racing checkpoint system with:
- **Sequential checkpoints** - Must pass through in order
- **Progress tracking** - Track each player's checkpoint progress
- **Visual feedback** - UI showing current checkpoint
- **Victory condition** - First to complete all checkpoints wins

---

## Understanding Area Triggers

**Area Triggers** are invisible zones in the game world that detect when players enter them.

```typescript
// Get an area trigger by ID (set in Godot editor)
const trigger = mod.GetAreaTrigger(1);

// Check if player is inside
const isInside = mod.IsPlayerInAreaTrigger(player, trigger);
```

---

## Step 1: Create Checkpoints in Godot

1. Open your level in Godot editor
2. Add `AreaTrigger` objects from the Global tab
3. Position them where you want checkpoints
4. Set unique "Obj Id" for each (1, 2, 3, etc.)
5. Export the level

---

## Step 2: Define Checkpoint Data

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from '../modlib';

const TOTAL_CHECKPOINTS = 5;

interface PlayerProgress {
  currentCheckpoint: number;
  completed: boolean;
  startTime: number;
}

const playerProgress = new Map<mod.Player, PlayerProgress>();
```

---

## Step 3: Initialize Players

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  // Initialize progress
  playerProgress.set(player, {
    currentCheckpoint: 0,
    completed: false,
    startTime: mod.GetMatchTimeElapsed()
  });

  mod.DeployPlayer(player);
}
```

---

## Step 4: Checkpoint Detection Loop

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Start checkpoint detection loop
  checkpointLoop(player);
}

async function checkpointLoop(player: mod.Player) {
  const progress = playerProgress.get(player);
  if (!progress) return;

  while (!progress.completed && mod.IsAlive(player)) {
    const checkpointId = progress.currentCheckpoint;

    // Get the area trigger for the next checkpoint
    const trigger = mod.GetAreaTrigger(checkpointId + 1); // IDs start at 1

    // Check if player entered the checkpoint
    if (mod.IsPlayerInAreaTrigger(player, trigger)) {
      // Player reached checkpoint!
      progress.currentCheckpoint++;

      // Show notification
      mod.DisplayCustomNotificationMessage(
        mod.Message(`Checkpoint ${progress.currentCheckpoint}/${TOTAL_CHECKPOINTS}`),
        mod.CustomNotificationSlots.MessageText1,
        2,
        player
      );

      // Check if completed all checkpoints
      if (progress.currentCheckpoint >= TOTAL_CHECKPOINTS) {
        progress.completed = true;
        handleCompletion(player);
        break;
      }
    }

    await mod.Wait(0.1); // Check 10 times per second
  }
}
```

---

## Step 5: Handle Completion

```typescript
let winner: mod.Player | null = null;

function handleCompletion(player: mod.Player) {
  const progress = playerProgress.get(player)!;
  const completionTime = mod.GetMatchTimeElapsed() - progress.startTime;

  console.log(`${mod.GetPlayerName(player)} completed in ${completionTime} seconds`);

  if (winner === null) {
    // First player to finish wins!
    winner = player;

    mod.DisplayCustomNotificationMessage(
      mod.Message("VICTORY!"),
      mod.CustomNotificationSlots.HeaderText,
      5,
      player
    );

    // End game after 5 seconds
    setTimeout(() => {
      mod.SetWinningPlayer(player);
      mod.EndGameMode(player);
    }, 5000);
  } else {
    // Subsequent finishers
    mod.DisplayCustomNotificationMessage(
      mod.Message(`Completed! Time: ${completionTime.toFixed(1)}s`),
      mod.CustomNotificationSlots.HeaderText,
      5,
      player
    );
  }
}
```

---

## Step 6: Add Progress UI

```typescript
const playerCheckpointUI = new Map<mod.Player, mod.UIWidget>();

export async function OnPlayerDeployed(player: mod.Player) {
  // Create checkpoint UI
  const cpText = mod.AddUIText(
    "checkpointProgress",
    mod.Message("Checkpoint: 0/5"),
    mod.CreateVector(10, 60, 0),
    mod.CreateVector(300, 40, 0),
    mod.UIAnchor.TopLeft,
    null,
    true,
    20,
    mod.CreateVector(1, 1, 0), // Yellow
    1.0,
    player
  );

  playerCheckpointUI.set(player, cpText);

  // Start checkpoint loop
  checkpointLoop(player);
}

// Update UI when checkpoint reached
function updateCheckpointUI(player: mod.Player) {
  const progress = playerProgress.get(player);
  const ui = playerCheckpointUI.get(player);

  if (progress && ui) {
    mod.SetUITextLabel(
      ui,
      mod.Message(`Checkpoint: ${progress.currentCheckpoint}/${TOTAL_CHECKPOINTS}`)
    );
  }
}

// Call this in checkpointLoop after incrementing currentCheckpoint
```

---

## Advanced: Checkpoint Skip Prevention

Ensure players can't skip checkpoints.

```typescript
async function checkpointLoop(player: mod.Player) {
  const progress = playerProgress.get(player);
  if (!progress) return;

  while (!progress.completed && mod.IsAlive(player)) {
    const nextCheckpointId = progress.currentCheckpoint + 1;

    // Check if player is in the NEXT checkpoint
    const nextTrigger = mod.GetAreaTrigger(nextCheckpointId);

    if (mod.IsPlayerInAreaTrigger(player, nextTrigger)) {
      // Valid checkpoint reached
      progress.currentCheckpoint++;
      updateCheckpointUI(player);

      if (progress.currentCheckpoint >= TOTAL_CHECKPOINTS) {
        progress.completed = true;
        handleCompletion(player);
        break;
      }
    } else {
      // Check if player is in a FUTURE checkpoint (skipping)
      for (let i = nextCheckpointId + 1; i <= TOTAL_CHECKPOINTS; i++) {
        const futureTrigger = mod.GetAreaTrigger(i);

        if (mod.IsPlayerInAreaTrigger(player, futureTrigger)) {
          // Player skipped a checkpoint!
          mod.DisplayCustomNotificationMessage(
            mod.Message(`You skipped checkpoint ${nextCheckpointId}!`),
            mod.CustomNotificationSlots.MessageText1,
            3,
            player
          );
        }
      }
    }

    await mod.Wait(0.1);
  }
}
```

---

## Complete Example

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from '../modlib';

const TOTAL_CHECKPOINTS = 5;

interface PlayerProgress {
  currentCheckpoint: number;
  completed: boolean;
  startTime: number;
}

const playerProgress = new Map<mod.Player, PlayerProgress>();
const playerCheckpointUI = new Map<mod.Player, mod.UIWidget>();
let winner: mod.Player | null = null;

export async function OnGameModeStarted() {
  console.log("Checkpoint Race started");
  mod.EnablePlayerJoin();
}

export async function OnPlayerJoinGame(player: mod.Player) {
  playerProgress.set(player, {
    currentCheckpoint: 0,
    completed: false,
    startTime: mod.GetMatchTimeElapsed()
  });

  mod.DeployPlayer(player);
}

export async function OnPlayerDeployed(player: mod.Player) {
  // Create UI
  const cpText = mod.AddUIText(
    "checkpointProgress",
    mod.Message(`Checkpoint: 0/${TOTAL_CHECKPOINTS}`),
    mod.CreateVector(10, 60, 0),
    mod.CreateVector(300, 40, 0),
    mod.UIAnchor.TopLeft,
    null,
    true,
    22,
    mod.CreateVector(1, 1, 0),
    1.0,
    player
  );

  playerCheckpointUI.set(player, cpText);

  // Start detection
  checkpointLoop(player);
}

async function checkpointLoop(player: mod.Player) {
  const progress = playerProgress.get(player);
  if (!progress) return;

  while (!progress.completed && mod.IsAlive(player)) {
    const nextCheckpointId = progress.currentCheckpoint + 1;
    const trigger = mod.GetAreaTrigger(nextCheckpointId);

    if (mod.IsPlayerInAreaTrigger(player, trigger)) {
      progress.currentCheckpoint++;

      // Update UI
      const ui = playerCheckpointUI.get(player);
      if (ui) {
        mod.SetUITextLabel(
          ui,
          mod.Message(`Checkpoint: ${progress.currentCheckpoint}/${TOTAL_CHECKPOINTS}`)
        );
      }

      // Check completion
      if (progress.currentCheckpoint >= TOTAL_CHECKPOINTS) {
        progress.completed = true;
        handleCompletion(player);
        break;
      }
    }

    await mod.Wait(0.1);
  }
}

function handleCompletion(player: mod.Player) {
  const progress = playerProgress.get(player)!;
  const time = mod.GetMatchTimeElapsed() - progress.startTime;

  if (winner === null) {
    winner = player;
    mod.SetWinningPlayer(player);
    mod.EndGameMode(player);
  }

  mod.DisplayCustomNotificationMessage(
    mod.Message(`Completed in ${time.toFixed(1)}s`),
    mod.CustomNotificationSlots.HeaderText,
    5,
    player
  );
}
```

---

## Next Steps

- [Vehicle Racing Mechanics](/tutorials/vehicle-racing) - Combine checkpoints with vehicles
- [Custom Spawning Logic](/tutorials/custom-spawning) - Respawn at last checkpoint
- [AcePursuit Example](/examples/acepursuit) - Full racing mode implementation

**API Reference:**
- [Gameplay Objects](/api/gameplay-objects) - Area triggers, spawners

---

★ Insight ─────────────────────────────────────
**Polling vs Events**
1. **No Event Callbacks** - Area triggers don't fire events; must poll with loops checking `IsPlayerInAreaTrigger()`
2. **Update Frequency** - 0.1s (10 Hz) balances responsiveness with performance; faster polling increases CPU usage
3. **State-Based Detection** - Loop continues until player completes or dies, automatically resuming on respawn
─────────────────────────────────────────────────
