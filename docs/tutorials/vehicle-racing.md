# Vehicle Racing Mechanics

Create a vehicle-based racing game with lap tracking and leaderboards.

**Difficulty:** ★★★★☆ | **Time:** 40 minutes

---

## What You'll Build

- Vehicle spawning and assignment
- Lap counter system
- Real-time leaderboard
- Rubber-banding mechanics

---

## Step 1: Spawn Vehicles

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Get vehicle spawner (set ID in Godot)
  const vehicleSpawner = mod.GetVehicleSpawner(1);

  // Configure spawner
  mod.SetVehicleSpawnerType(vehicleSpawner, mod.VehicleList.LATV4_Recon);
  mod.SetVehicleSpawnerRespawnTime(vehicleSpawner, 5);
  mod.SetVehicleSpawnerAutoSpawn(vehicleSpawner, true);

  // Wait for vehicle to spawn
  await mod.Wait(0.5);

  // Get the spawned vehicle
  const vehicle = mod.GetVehicleAtSpawner(vehicleSpawner);

  // Teleport player to vehicle
  const vehiclePos = mod.GetVehicleTransform(vehicle).position;
  mod.TeleportPlayer(player, vehiclePos, mod.CreateVector(0, 0, 0));
}
```

---

## Step 2: Track Laps

```typescript
interface RacerData {
  lap: number;
  checkpoint: number;
  completed: boolean;
}

const racerData = new Map<mod.Player, RacerData>();
const TOTAL_LAPS = 3;
const CHECKPOINTS_PER_LAP = 4;

export async function OnPlayerJoinGame(player: mod.Player) {
  racerData.set(player, {
    lap: 0,
    checkpoint: 0,
    completed: false
  });

  mod.DeployPlayer(player);
}

export async function OnPlayerDeployed(player: mod.Player) {
  // ... vehicle spawning code ...

  // Start lap tracking
  lapTrackingLoop(player);
}

async function lapTrackingLoop(player: mod.Player) {
  const data = racerData.get(player);
  if (!data) return;

  while (!data.completed && mod.IsAlive(player)) {
    const nextCheckpoint = data.checkpoint + 1;
    const trigger = mod.GetAreaTrigger(nextCheckpoint);

    if (mod.IsPlayerInAreaTrigger(player, trigger)) {
      data.checkpoint++;

      // Completed a lap?
      if (data.checkpoint >= CHECKPOINTS_PER_LAP) {
        data.lap++;
        data.checkpoint = 0;

        mod.DisplayCustomNotificationMessage(
          mod.Message(`Lap ${data.lap}/${TOTAL_LAPS}`),
          mod.CustomNotificationSlots.HeaderText,
          2,
          player
        );

        // Completed race?
        if (data.lap >= TOTAL_LAPS) {
          data.completed = true;
          handleRaceCompletion(player);
        }
      }
    }

    await mod.Wait(0.1);
  }
}
```

---

## Step 3: Rubber-Banding

Help trailing players catch up.

```typescript
async function rubberBandingLoop() {
  while (true) {
    const racers = Array.from(racerData.entries())
      .sort((a, b) => {
        // Sort by lap, then checkpoint
        if (a[1].lap !== b[1].lap) return b[1].lap - a[1].lap;
        return b[1].checkpoint - a[1].checkpoint;
      });

    if (racers.length === 0) {
      await mod.Wait(2);
      continue;
    }

    const leader = racers[0];

    // Apply catchup to trailing racers
    for (let i = 1; i < racers.length; i++) {
      const racer = racers[i];
      const progressDiff = 
        (leader[1].lap - racer[1].lap) * CHECKPOINTS_PER_LAP +
        (leader[1].checkpoint - racer[1].checkpoint);

      // If 2+ checkpoints behind, apply boost
      if (progressDiff >= 2) {
        const vehicle = getPlayerVehicle(racer[0]);
        if (vehicle) {
          mod.SetVehicleMaxSpeed(vehicle, 1.2); // 20% faster
        }
      } else {
        const vehicle = getPlayerVehicle(racer[0]);
        if (vehicle) {
          mod.SetVehicleMaxSpeed(vehicle, 1.0); // Normal speed
        }
      }
    }

    await mod.Wait(2);
  }
}

function getPlayerVehicle(player: mod.Player): mod.Vehicle | null {
  // Implementation depends on how you track player vehicles
  return null; // Placeholder
}
```

---

## Complete Example

See [AcePursuit](/examples/acepursuit) for a full vehicle racing implementation with:
- Ready-up system
- Countdown
- Dynamic leaderboard UI
- AI racers
- Multiple tracks

---

## Next Steps

- [AcePursuit Example](/examples/acepursuit)
- [Checkpoint System](/tutorials/checkpoint-system)
- [Vehicle API](/api/vehicles)

---

★ Insight ─────────────────────────────────────
**Vehicle Racing Design**
1. **Checkpoint-Based Progress** - Don't rely on position/distance; use discrete checkpoints for deterministic progress tracking
2. **Rubber-Banding Threshold** - Only activate catchup when significantly behind (2+ checkpoints) to avoid punishing leaders
3. **Vehicle Persistence** - Vehicles persist after player exits; track vehicle-player associations to apply speed modifications
─────────────────────────────────────────────────
