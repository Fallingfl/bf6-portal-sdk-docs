# Map Objects

Learn how to work with objects placed in Godot maps, including spawners, triggers, capture points, and runtime object spawning.

## Overview

Map objects are divided into two categories:

1. **Pre-placed Objects** - Placed in Godot, referenced in TypeScript
2. **Runtime Objects** - Spawned dynamically during gameplay

Both types are essential for creating interactive game modes.

## Pre-Placed Objects (From Godot)

These objects are placed in the Godot editor and referenced in your TypeScript code using their **Obj Id**.

### Object Types

| Object Type | Purpose | Get Function |
|-------------|---------|--------------|
| Spawner | Player spawn points | `mod.GetSpawner(id)` |
| VehicleSpawner | Vehicle spawn points | `mod.GetVehicleSpawner(id)` |
| AISpawner | AI bot spawn points | `mod.GetAISpawner(id)` |
| AreaTrigger | Zone detection | `mod.GetAreaTrigger(id)` |
| InteractPoint | Player interaction | `mod.GetInteractPoint(id)` |
| CapturePoint | Conquest-style capture | `mod.GetCapturePoint(id)` |
| WorldIcon | 3D marker icons | `mod.GetWorldIcon(id)` |
| SpatialObject | Generic objects | `mod.GetSpatialObject(id)` |

### Placement Workflow

1. **Open Map in Godot**
   - Scene → Open Scene → levels/YourMap.tscn

2. **Add Object from Library**
   - Find object in bottom panel
   - Use correct map tab or Global tab
   - Drag into scene

3. **Set Obj Id in Inspector**
   - Select object
   - Right panel → Inspector
   - Find "Obj Id" field
   - Enter unique number (1-999)

4. **Position Object**
   - Press W for Move mode
   - Drag arrows to position
   - Or enter coordinates in Inspector

5. **Export Scene**
   - BFPortal tab → Export Current Level
   - Saves as `.spatial.json`

6. **Reference in TypeScript**
   ```typescript
   const spawner = mod.GetSpawner(1);  // ID matches Godot
   ```

## Spawners

### Player Spawners

Used to spawn players at specific locations.

**Types:**
- `PlayerSpawner` - Basic spawn point
- `HQ_PlayerSpawner` - HQ spawn (team-specific)

**Placement:**
```typescript
// In Godot: Place PlayerSpawner with Obj Id = 1

// In TypeScript: Get and use
export async function OnPlayerDeployed(player: mod.Player) {
  const spawner = mod.GetSpawner(1);

  if (!spawner) {
    console.log("ERROR: Spawner 1 not found!");
    return;
  }

  mod.SpawnPlayerFromSpawnPoint(player, spawner);
}
```

**Multiple Spawners:**
```typescript
// Cache spawners on startup
let spawners: mod.Spawner[] = [];

export async function OnGameModeStarted() {
  // Get spawners 1-10
  for (let i = 1; i <= 10; i++) {
    const spawner = mod.GetSpawner(i);
    if (spawner) {
      spawners.push(spawner);
    }
  }

  console.log(`Loaded ${spawners.length} spawners`);
}

// Random spawn
function spawnPlayerRandom(player: mod.Player) {
  const randomIndex = Math.floor(Math.random() * spawners.length);
  const spawner = spawners[randomIndex];
  mod.SpawnPlayerFromSpawnPoint(player, spawner);
}
```

**Team-Based Spawning:**
```typescript
const TEAM1_SPAWNERS = [1, 2, 3];  // Obj IDs
const TEAM2_SPAWNERS = [4, 5, 6];

export async function OnPlayerDeployed(player: mod.Player) {
  const team = mod.GetPlayerTeam(player);

  let spawnerIds: number[];
  if (team === mod.Team.Team1) {
    spawnerIds = TEAM1_SPAWNERS;
  } else {
    spawnerIds = TEAM2_SPAWNERS;
  }

  // Pick random spawner from team's list
  const randomId = spawnerIds[Math.floor(Math.random() * spawnerIds.length)];
  const spawner = mod.GetSpawner(randomId);

  if (spawner) {
    mod.SpawnPlayerFromSpawnPoint(player, spawner);
  }
}
```

**Get Spawner Transform:**
```typescript
const spawner = mod.GetSpawner(1);
const transform = mod.GetSpawnerTransform(spawner);
const position = transform.position;

console.log(`Spawner at: x=${position.x}, y=${position.y}, z=${position.z}`);
```

### Vehicle Spawners

Used to spawn vehicles at specific locations.

**Placement:**
```typescript
// In Godot: Place VehicleSpawner with Obj Id = 50

// In TypeScript: Spawn vehicle
const vehicleSpawner = mod.GetVehicleSpawner(50);
if (vehicleSpawner) {
  const vehicle = mod.SpawnVehicleFromSpawner(vehicleSpawner);
  console.log("Vehicle spawned!");
}
```

**Respawn Timer:**
```typescript
const vehicleSpawners: mod.VehicleSpawner[] = [];
const vehicleRespawnTime = 30;  // seconds

export async function OnGameModeStarted() {
  // Load vehicle spawners
  for (let i = 50; i <= 55; i++) {
    const spawner = mod.GetVehicleSpawner(i);
    if (spawner) {
      vehicleSpawners.push(spawner);
      spawnVehicleAt(spawner);  // Initial spawn
    }
  }

  // Start respawn loop
  vehicleRespawnLoop();
}

async function vehicleRespawnLoop() {
  while (gameRunning) {
    for (const spawner of vehicleSpawners) {
      // Check if vehicle exists at spawner
      // If destroyed, respawn after delay
    }

    await mod.Wait(1);
  }
}

function spawnVehicleAt(spawner: mod.VehicleSpawner) {
  const vehicle = mod.SpawnVehicleFromSpawner(spawner);
  return vehicle;
}
```

### AI Spawners

Used to spawn AI bots at specific locations.

**Placement:**
```typescript
// In Godot: Place AISpawner with Obj Id = 100

// In TypeScript: Spawn AI
const aiSpawner = mod.GetAISpawner(100);
if (aiSpawner) {
  const ai = mod.SpawnAIFromAISpawner(aiSpawner);

  // Configure AI
  mod.SetAIBehavior(ai, mod.AIBehavior.BattlefieldAI);
  mod.SetAIShootingEnabled(ai, true);
  mod.SetAITarget(ai, player);  // Attack player
}
```

**AI Patrol System:**
```typescript
const AI_SPAWNERS = [100, 101, 102, 103, 104];

export async function OnGameModeStarted() {
  // Spawn AI at each location
  for (const id of AI_SPAWNERS) {
    const spawner = mod.GetAISpawner(id);
    if (spawner) {
      const ai = mod.SpawnAIFromAISpawner(spawner);

      // Set up patrol behavior
      const waypoints = [
        new mod.Vector(100, 0, 50),
        new mod.Vector(200, 0, 50),
        new mod.Vector(200, 0, 150),
        new mod.Vector(100, 0, 150)
      ];

      const patrolPath = mod.CreateWaypointPatrolPath(waypoints);
      mod.SetAIBehavior(ai, mod.AIBehavior.WaypointPatrol);
      mod.SetAIWaypointPath(ai, patrolPath);
    }
  }
}
```

## Area Triggers

Invisible zones that detect when players enter/exit.

### Basic Trigger Detection

```typescript
// In Godot: Place AreaTrigger with Obj Id = 10

// In TypeScript: Check if player is in trigger
const checkpointTrigger = mod.GetAreaTrigger(10);

async function checkTriggers() {
  while (gameRunning) {
    const players = modlib.ConvertArray(mod.GetPlayers());

    for (const player of players) {
      if (mod.IsPlayerInAreaTrigger(player, checkpointTrigger)) {
        onCheckpointReached(player);
      }
    }

    await mod.Wait(0.1);  // Check 10 times per second
  }
}

function onCheckpointReached(player: mod.Player) {
  console.log("Player reached checkpoint!");
  modlib.DisplayCustomNotificationMessage(
    "Checkpoint reached!",
    mod.NotificationSlot.HeaderText,
    3,
    player
  );
}
```

### Checkpoint System

```typescript
interface Checkpoint {
  trigger: mod.AreaTrigger;
  position: mod.Vector;
  name: string;
}

let checkpoints: Checkpoint[] = [];

export async function OnGameModeStarted() {
  // Set up checkpoints
  checkpoints = [
    {
      trigger: mod.GetAreaTrigger(10),
      position: new mod.Vector(100, 0, 50),
      name: "Checkpoint 1"
    },
    {
      trigger: mod.GetAreaTrigger(11),
      position: new mod.Vector(200, 0, 100),
      name: "Checkpoint 2"
    },
    {
      trigger: mod.GetAreaTrigger(12),
      position: new mod.Vector(300, 0, 150),
      name: "Checkpoint 3"
    }
  ];

  // Start checking
  checkCheckpoints();
}

interface PlayerProgress {
  player: mod.Player;
  currentCheckpoint: number;
}

let playerProgress: PlayerProgress[] = [];

async function checkCheckpoints() {
  while (gameRunning) {
    for (const progress of playerProgress) {
      const nextCheckpointIndex = progress.currentCheckpoint;

      if (nextCheckpointIndex >= checkpoints.length) {
        continue;  // Player finished
      }

      const checkpoint = checkpoints[nextCheckpointIndex];
      if (mod.IsPlayerInAreaTrigger(progress.player, checkpoint.trigger)) {
        // Player reached next checkpoint
        progress.currentCheckpoint++;

        modlib.DisplayCustomNotificationMessage(
          `${checkpoint.name} reached!`,
          mod.NotificationSlot.HeaderText,
          3,
          progress.player
        );

        // Teleport to next checkpoint
        if (progress.currentCheckpoint < checkpoints.length) {
          const nextPos = checkpoints[progress.currentCheckpoint].position;
          mod.Teleport(progress.player, nextPos, 0);
        } else {
          // Player finished all checkpoints
          playerWon(progress.player);
        }
      }
    }

    await mod.Wait(0.1);
  }
}
```

### Capture Zones

```typescript
// Out of bounds zone
const outOfBounds = mod.GetAreaTrigger(20);

async function checkOutOfBounds() {
  while (gameRunning) {
    const players = modlib.ConvertArray(mod.GetPlayers());

    for (const player of players) {
      if (mod.IsPlayerInAreaTrigger(player, outOfBounds)) {
        // Kill player for being out of bounds
        mod.Kill(player);

        modlib.DisplayCustomNotificationMessage(
          "Out of bounds!",
          mod.NotificationSlot.HeaderText,
          3,
          player
        );
      }
    }

    await mod.Wait(0.5);
  }
}
```

## Capture Points

Conquest-style capture mechanics.

### Basic Capture Point

```typescript
// In Godot: Place CapturePoint with Obj Id = 20

const capturePointA = mod.GetCapturePoint(20);

// Set initial owner
mod.SetCapturePointTeam(capturePointA, mod.Team.Team1);

// Check current owner
const owner = mod.GetCapturePointTeam(capturePointA);
```

### Capture System

```typescript
interface CaptureZone {
  capturePoint: mod.CapturePoint;
  trigger: mod.AreaTrigger;
  name: string;
  controllingTeam: mod.Team | null;
}

let captureZones: CaptureZone[] = [];

export async function OnGameModeStarted() {
  captureZones = [
    {
      capturePoint: mod.GetCapturePoint(20),
      trigger: mod.GetAreaTrigger(21),
      name: "Point A",
      controllingTeam: null
    },
    {
      capturePoint: mod.GetCapturePoint(22),
      trigger: mod.GetAreaTrigger(23),
      name: "Point B",
      controllingTeam: null
    }
  ];

  // Start capture system
  capturePointLoop();
}

async function capturePointLoop() {
  while (gameRunning) {
    for (const zone of captureZones) {
      checkCaptureProgress(zone);
    }

    await mod.Wait(1);
  }
}

function checkCaptureProgress(zone: CaptureZone) {
  // Count players in trigger by team
  const players = modlib.ConvertArray(mod.GetPlayers());
  let team1Count = 0;
  let team2Count = 0;

  for (const player of players) {
    if (mod.IsPlayerInAreaTrigger(player, zone.trigger)) {
      const team = mod.GetPlayerTeam(player);
      if (team === mod.Team.Team1) team1Count++;
      if (team === mod.Team.Team2) team2Count++;
    }
  }

  // Determine capturing team
  if (team1Count > team2Count) {
    // Team 1 capturing
    if (zone.controllingTeam !== mod.Team.Team1) {
      zone.controllingTeam = mod.Team.Team1;
      mod.SetCapturePointTeam(zone.capturePoint, mod.Team.Team1);

      announceToAll(`${zone.name} captured by Red Team!`);
    }
  } else if (team2Count > team1Count) {
    // Team 2 capturing
    if (zone.controllingTeam !== mod.Team.Team2) {
      zone.controllingTeam = mod.Team.Team2;
      mod.SetCapturePointTeam(zone.capturePoint, mod.Team.Team2);

      announceToAll(`${zone.name} captured by Blue Team!`);
    }
  }
}
```

## Interact Points

Points where players can interact (press button).

```typescript
// In Godot: Place InteractPoint with Obj Id = 30

const interactPoint = mod.GetInteractPoint(30);

// Detect interaction
async function checkInteractions() {
  while (gameRunning) {
    const players = modlib.ConvertArray(mod.GetPlayers());

    for (const player of players) {
      if (mod.IsPlayerInteractingWith(player, interactPoint)) {
        onPlayerInteract(player);
      }
    }

    await mod.Wait(0.1);
  }
}

function onPlayerInteract(player: mod.Player) {
  console.log("Player interacted!");

  // Example: Give weapon
  mod.AddEquipment(player, mod.Weapons.AK24);

  modlib.DisplayCustomNotificationMessage(
    "Weapon acquired!",
    mod.NotificationSlot.HeaderText,
    3,
    player
  );
}
```

## World Icons

3D markers visible in the world.

```typescript
// In Godot: Place WorldIcon with Obj Id = 40

const objectiveIcon = mod.GetWorldIcon(40);

// Show/hide icon
mod.SetWorldIconVisibility(objectiveIcon, true);   // Show
mod.SetWorldIconVisibility(objectiveIcon, false);  // Hide

// Change icon appearance
mod.SetWorldIconType(objectiveIcon, mod.WorldIconType.Objective);
mod.SetWorldIconColor(objectiveIcon, mod.TeamColor.Red);
```

## Runtime Object Spawning

Spawn objects dynamically during gameplay.

### Spawning Objects

```typescript
// Spawn a prop
const position = new mod.Vector(100, 0, 50);
const rotation = 0;  // Degrees

const obj = mod.SpawnObject("PropContainer_Large", position, rotation);

// Later, despawn it
mod.DespawnObject(obj);
```

### Available Objects

**14,000+ spawnable objects** varying by map:
- **Global**: 629 objects (usable on all maps)
- **MP_Dumbo**: 1,668 objects
- **MP_Abbasid**: 1,474 objects
- **MP_Tungsten**: 1,417 objects

::: tip Finding Object Names
Check `FbExportData/asset_types.json` in the SDK for available object names per map.
:::

### Moving Objects

```typescript
const obj = mod.SpawnObject("PropContainer_Large", position, 0);

// Move object to new position
const newPosition = new mod.Vector(200, 0, 100);
mod.MoveObject(obj, newPosition);

// Get current transform
const transform = mod.GetObjectTransform(obj);
console.log("Object position:", transform.position);

// Set full transform
mod.SetObjectTransform(obj, newTransform);
```

### Enable/Disable Objects

```typescript
// Hide object
mod.EnableObject(obj, false);

// Show object
mod.EnableObject(obj, true);
```

## Object ID Management

### Recommended ID Ranges

Organize your Obj IDs for clarity:

```typescript
// ========================================
// OBJECT ID REFERENCE
// ========================================

// Player Spawners (1-20)
const BLUE_HQ = 1;
const RED_HQ = 2;
const NEUTRAL_SPAWNS = [3, 4, 5, 6, 7, 8, 9, 10];

// Triggers (21-50)
const CHECKPOINT_1 = 21;
const CHECKPOINT_2 = 22;
const CAPTURE_A_TRIGGER = 25;
const CAPTURE_B_TRIGGER = 26;
const OUT_OF_BOUNDS = 30;

// Vehicle Spawners (51-70)
const TANK_SPAWN_1 = 51;
const HELI_SPAWN_1 = 52;

// AI Spawners (71-100)
const ENEMY_PATROL_1 = 71;
const ENEMY_GUARD_1 = 76;

// Capture Points (101-120)
const CAPTURE_POINT_A = 101;
const CAPTURE_POINT_B = 102;

// Interact Points (121-140)
const WEAPON_PICKUP = 121;
const AMMO_CRATE = 122;

// World Icons (141-160)
const OBJECTIVE_ICON = 141;
```

### Validation Helper

```typescript
function validateObjects() {
  const errors: string[] = [];

  // Check spawners
  if (!mod.GetSpawner(BLUE_HQ)) {
    errors.push("Missing: Blue HQ spawner (ID 1)");
  }

  if (!mod.GetSpawner(RED_HQ)) {
    errors.push("Missing: Red HQ spawner (ID 2)");
  }

  // Check triggers
  if (!mod.GetAreaTrigger(CHECKPOINT_1)) {
    errors.push("Missing: Checkpoint 1 trigger (ID 21)");
  }

  if (errors.length > 0) {
    console.log("=== OBJECT VALIDATION ERRORS ===");
    for (const error of errors) {
      console.log(error);
    }
    return false;
  }

  console.log("✅ All objects validated successfully");
  return true;
}

export async function OnGameModeStarted() {
  if (!validateObjects()) {
    console.log("ERROR: Object validation failed!");
    return;
  }

  // Continue with game setup...
}
```

## Best Practices

### 1. Cache Object References

```typescript
// ❌ Bad - lookup every frame
async function gameLoop() {
  while (true) {
    const trigger = mod.GetAreaTrigger(10);  // Wasteful
    checkTrigger(trigger);
    await mod.Wait(0.1);
  }
}

// ✅ Good - cache on startup
let triggers: mod.AreaTrigger[] = [];

export async function OnGameModeStarted() {
  triggers = [
    mod.GetAreaTrigger(10),
    mod.GetAreaTrigger(11),
    mod.GetAreaTrigger(12)
  ];
}

async function gameLoop() {
  while (true) {
    for (const trigger of triggers) {
      checkTrigger(trigger);
    }
    await mod.Wait(0.1);
  }
}
```

### 2. Always Validate Objects

```typescript
const spawner = mod.GetSpawner(1);

if (!spawner) {
  console.log("ERROR: Spawner 1 not found! Check Godot scene.");
  return;
}

// Safe to use
mod.SpawnPlayerFromSpawnPoint(player, spawner);
```

### 3. Use Meaningful Names

```typescript
// ❌ Bad
const s1 = mod.GetSpawner(1);
const t10 = mod.GetAreaTrigger(10);

// ✅ Good
const blueTeamHQSpawner = mod.GetSpawner(1);
const checkpoint1Trigger = mod.GetAreaTrigger(10);
```

### 4. Document Your Objects

Add comments explaining each object's purpose:

```typescript
// Spawners
const BLUE_HQ_SPAWN = 1;      // Main HQ for blue team
const RED_HQ_SPAWN = 2;       // Main HQ for red team
const FORWARD_SPAWN_1 = 3;    // Forward spawn near Point A

// Triggers
const CHECKPOINT_START = 10;  // Race start line
const CHECKPOINT_MID = 11;    // Mid-race checkpoint
const CHECKPOINT_FINISH = 12; // Finish line
```

## Next Steps

- 📖 [TypeScript Scripting](/guides/typescript-scripting) - Write game logic
- 📖 [Godot Editor](/guides/godot-editor) - Learn editor controls
- 🎓 [Checkpoint Tutorial](/tutorials/checkpoint-system) - Build checkpoint system
- 📚 [API Reference](/api/gameplay-objects) - Complete objects API

---

::: tip Map Objects Summary
- **Pre-place in Godot** - Set Obj IDs in Inspector
- **Reference in TypeScript** - Use `GetSpawner()`, `GetAreaTrigger()`, etc.
- **Match IDs** - Godot Obj Id must match TypeScript getter
- **Validate on startup** - Check objects exist
- **Cache references** - Store once, use many times
- **Organize IDs** - Use ID ranges for different object types
:::
