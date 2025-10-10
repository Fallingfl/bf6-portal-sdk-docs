# Object Spawning

Functions for spawning, despawning, and managing runtime objects in your game modes.

## Overview

The object spawning system allows:
- Runtime spawning of 14,000+ objects
- Per-map object libraries
- Global objects available on all maps
- Transform control after spawning
- Object lifecycle management

## Object Categories

### Map-Specific Objects

Each map has unique objects:

| Map | Object Count | Examples |
|-----|-------------|----------|
| MP_Dumbo | 1,668 | Brooklyn props, barriers |
| MP_Abbasid | 1,474 | Desert structures, ruins |
| MP_Tungsten | 1,417 | Mountain terrain, rocks |
| MP_Outskirts | 1,523 | City buildings, vehicles |
| MP_Aftermath | 1,456 | Destroyed urban props |
| MP_Battery | 1,389 | Military fortifications |
| MP_Capstone | 1,401 | Arctic structures |
| MP_Firestorm | 1,412 | Industrial equipment |
| MP_Limestone | 1,445 | Medieval architecture |

### Global Objects

629 objects available on all maps:
- Basic props and barriers
- Gameplay elements
- Effects and triggers
- Common structures

## Spawning Functions

### SpawnObject

```typescript
SpawnObject(objectName: string, position: Vector, rotation: number): SpatialObject
```

Spawn an object at position with rotation.

**Example:**
```typescript
// Spawn a concrete barrier
export async function OnGameModeStarted() {
  const barrierPos = mod.CreateVector(100, 0, 50);
  const barrier = mod.SpawnObject(
    "MP_Dumbo_Props_Concrete_Barrier_01",
    barrierPos,
    45  // 45 degree rotation
  );

  if (barrier) {
    console.log("Barrier spawned successfully");
  }
}

// Spawn multiple objects in formation
function createBarricade(startPos: mod.Vector, count: number) {
  const barriers: mod.SpatialObject[] = [];

  for (let i = 0; i < count; i++) {
    const pos = mod.Add(startPos, mod.CreateVector(i * 5, 0, 0));
    const barrier = mod.SpawnObject(
      "Global_Props_Barriers_ConcreteBarrier_01",
      pos,
      0
    );
    barriers.push(barrier);
  }

  return barriers;
}
```

### SpawnObjectWithTransform

```typescript
SpawnObjectWithTransform(objectName: string, transform: Transform): SpatialObject
```

Spawn with full transform control.

**Example:**
```typescript
// Spawn with precise transform
function spawnPlatform(position: mod.Vector) {
  const transform = {
    position: position,
    right: mod.CreateVector(1, 0, 0),
    up: mod.CreateVector(0, 1, 0),
    front: mod.CreateVector(0, 0, 1)
  };

  const platform = mod.SpawnObjectWithTransform(
    "MP_Tungsten_Props_Platform_Metal_Large",
    transform
  );

  return platform;
}

// Create ramp with angled transform
function createRamp(basePos: mod.Vector, angle: number) {
  const radians = angle * Math.PI / 180;

  const transform = {
    position: basePos,
    right: mod.CreateVector(Math.cos(radians), 0, -Math.sin(radians)),
    up: mod.CreateVector(Math.sin(radians) * 0.5, Math.cos(radians), 0),
    front: mod.CreateVector(Math.sin(radians), 0, Math.cos(radians))
  };

  return mod.SpawnObjectWithTransform(
    "Global_Props_Ramps_Metal_01",
    transform
  );
}
```

### DespawnObject

```typescript
DespawnObject(object: SpatialObject): void
```

Remove a spawned object from the world.

**Example:**
```typescript
// Temporary platforms
const temporaryPlatforms: mod.SpatialObject[] = [];

function spawnTemporaryPlatform(position: mod.Vector) {
  const platform = mod.SpawnObject(
    "Global_Props_Platform_Concrete_Small",
    position,
    0
  );

  temporaryPlatforms.push(platform);

  // Auto-despawn after 30 seconds
  setTimeout(() => {
    mod.DespawnObject(platform);
    const index = temporaryPlatforms.indexOf(platform);
    if (index > -1) {
      temporaryPlatforms.splice(index, 1);
    }
  }, 30000);

  return platform;
}

// Clear all temporary objects
function clearTemporaryObjects() {
  for (const platform of temporaryPlatforms) {
    mod.DespawnObject(platform);
  }
  temporaryPlatforms.length = 0;
}
```

## Object Management

### GetSpatialObject

```typescript
GetSpatialObject(objectId: number): SpatialObject
```

Get reference to object by Obj Id (set in Godot).

**Example:**
```typescript
// Pre-placed objects in Godot
const DOOR_ID = 100;
const BRIDGE_ID = 101;

export async function OnGameModeStarted() {
  // Get pre-placed objects
  const door = mod.GetSpatialObject(DOOR_ID);
  const bridge = mod.GetSpatialObject(BRIDGE_ID);

  if (!door || !bridge) {
    console.log("ERROR: Required objects not found!");
    return;
  }

  // Hide initially
  mod.EnableObject(door, false);
  mod.EnableObject(bridge, false);
}

// Show objects when needed
function openPath() {
  const door = mod.GetSpatialObject(DOOR_ID);
  const bridge = mod.GetSpatialObject(BRIDGE_ID);

  mod.EnableObject(door, true);
  mod.EnableObject(bridge, true);

  console.log("Path opened!");
}
```

### EnableObject

```typescript
EnableObject(object: SpatialObject, enabled: boolean): void
```

Show or hide an object.

**Example:**
```typescript
// Disappearing platforms
async function disappearingPlatformSequence() {
  const platforms = [];

  // Spawn platforms
  for (let i = 0; i < 5; i++) {
    const pos = mod.CreateVector(i * 10, 0, 0);
    const platform = mod.SpawnObject("Global_Platform_01", pos, 0);
    platforms.push(platform);
  }

  // Make them disappear in sequence
  for (const platform of platforms) {
    await mod.Wait(2);
    mod.EnableObject(platform, false);  // Hide

    await mod.Wait(1);
    mod.EnableObject(platform, true);   // Show again
  }
}
```

## Spawning Patterns

### Object Pooling

```typescript
class ObjectPool {
  private available: mod.SpatialObject[] = [];
  private inUse: mod.SpatialObject[] = [];
  private objectType: string;
  private maxSize: number;

  constructor(objectType: string, maxSize: number) {
    this.objectType = objectType;
    this.maxSize = maxSize;
    this.initialize();
  }

  private initialize() {
    // Pre-spawn objects
    for (let i = 0; i < this.maxSize; i++) {
      const obj = mod.SpawnObject(
        this.objectType,
        mod.CreateVector(0, -1000, 0),  // Hide below map
        0
      );
      mod.EnableObject(obj, false);
      this.available.push(obj);
    }
  }

  spawn(position: mod.Vector, rotation: number): mod.SpatialObject | null {
    if (this.available.length === 0) {
      console.log("Object pool exhausted!");
      return null;
    }

    const obj = this.available.pop()!;
    this.inUse.push(obj);

    // Position and show
    const transform = mod.GetObjectTransform(obj);
    transform.position = position;
    mod.SetObjectTransform(obj, transform);
    mod.EnableObject(obj, true);

    return obj;
  }

  despawn(obj: mod.SpatialObject) {
    const index = this.inUse.indexOf(obj);
    if (index === -1) return;

    this.inUse.splice(index, 1);
    this.available.push(obj);

    // Hide object
    mod.EnableObject(obj, false);
    const transform = mod.GetObjectTransform(obj);
    transform.position = mod.CreateVector(0, -1000, 0);
    mod.SetObjectTransform(obj, transform);
  }

  despawnAll() {
    while (this.inUse.length > 0) {
      this.despawn(this.inUse[0]);
    }
  }
}

// Usage
const projectilePool = new ObjectPool("Global_Props_Projectile_01", 50);

function fireProjectile(origin: mod.Vector, direction: mod.Vector) {
  const projectile = projectilePool.spawn(origin, 0);
  if (!projectile) return;

  // Move projectile
  animateProjectile(projectile, direction);
}
```

### Procedural Generation

```typescript
// Generate random obstacle course
function generateObstacleCourse(length: number, width: number) {
  const obstacles: mod.SpatialObject[] = [];
  const obstacleTypes = [
    "Global_Props_Barriers_Concrete_01",
    "Global_Props_Barriers_Metal_01",
    "Global_Props_Crates_Large_01",
    "Global_Props_Containers_Blue_01"
  ];

  for (let x = 0; x < length; x += 20) {
    for (let z = 0; z < width; z += 15) {
      // Random chance to place obstacle
      if (Math.random() > 0.3) continue;

      const type = obstacleTypes[Math.floor(Math.random() * obstacleTypes.length)];
      const pos = mod.CreateVector(x, 0, z);
      const rotation = Math.random() * 360;

      const obstacle = mod.SpawnObject(type, pos, rotation);
      obstacles.push(obstacle);
    }
  }

  return obstacles;
}
```

### Dynamic Structures

```typescript
// Build structures from multiple objects
class Structure {
  private parts: mod.SpatialObject[] = [];
  private centerPos: mod.Vector;

  constructor(centerPos: mod.Vector) {
    this.centerPos = centerPos;
  }

  addWall(offset: mod.Vector, rotation: number) {
    const wallPos = mod.Add(this.centerPos, offset);
    const wall = mod.SpawnObject(
      "Global_Props_Walls_Concrete_Large",
      wallPos,
      rotation
    );
    this.parts.push(wall);
    return wall;
  }

  addRoof(height: number) {
    const roofPos = mod.Add(
      this.centerPos,
      mod.CreateVector(0, height, 0)
    );
    const roof = mod.SpawnObject(
      "Global_Props_Roofs_Metal_01",
      roofPos,
      0
    );
    this.parts.push(roof);
    return roof;
  }

  destroy() {
    for (const part of this.parts) {
      // Spawn destruction effect
      const pos = mod.GetObjectTransform(part).position;
      mod.SpawnVFX(mod.GetVFX(mod.VFXSlots.Explosion_Medium), pos);

      // Remove part
      mod.DespawnObject(part);
    }
    this.parts = [];
  }

  hide() {
    for (const part of this.parts) {
      mod.EnableObject(part, false);
    }
  }

  show() {
    for (const part of this.parts) {
      mod.EnableObject(part, true);
    }
  }
}

// Create a bunker
function createBunker(position: mod.Vector) {
  const bunker = new Structure(position);

  // Four walls
  bunker.addWall(mod.CreateVector(10, 0, 0), 0);    // East
  bunker.addWall(mod.CreateVector(-10, 0, 0), 180); // West
  bunker.addWall(mod.CreateVector(0, 0, 10), 90);   // North
  bunker.addWall(mod.CreateVector(0, 0, -10), 270); // South

  // Roof
  bunker.addRoof(5);

  return bunker;
}
```

### Map-Aware Spawning

```typescript
// Spawn objects based on current map
function spawnMapSpecificProps() {
  const currentMap = getCurrentMap();  // Your map detection

  switch(currentMap) {
    case "MP_Dumbo":  // Brooklyn
      spawnUrbanProps();
      break;

    case "MP_Abbasid":  // Desert
      spawnDesertProps();
      break;

    case "MP_Tungsten":  // Mountain
      spawnMountainProps();
      break;

    default:
      spawnGlobalProps();
  }
}

function spawnUrbanProps() {
  const props = [
    "MP_Dumbo_Props_Cars_Sedan_01",
    "MP_Dumbo_Props_Dumpster_01",
    "MP_Dumbo_Props_Streetlight_01",
    "MP_Dumbo_Props_Mailbox_01"
  ];

  props.forEach((prop, i) => {
    const pos = mod.CreateVector(i * 15, 0, 0);
    mod.SpawnObject(prop, pos, Math.random() * 360);
  });
}

function spawnDesertProps() {
  const props = [
    "MP_Abbasid_Props_Ruins_Wall_01",
    "MP_Abbasid_Props_Palm_Tree_01",
    "MP_Abbasid_Props_Market_Stall_01"
  ];

  // Spawn in desert-appropriate pattern
  props.forEach((prop, i) => {
    const angle = (i / props.length) * Math.PI * 2;
    const radius = 20;
    const pos = mod.CreateVector(
      Math.cos(angle) * radius,
      0,
      Math.sin(angle) * radius
    );
    mod.SpawnObject(prop, pos, angle * 180 / Math.PI);
  });
}
```

## Performance Optimization

### Batch Spawning

```typescript
// Spawn many objects efficiently
async function batchSpawn(objectType: string, positions: mod.Vector[]) {
  const objects: mod.SpatialObject[] = [];
  const batchSize = 10;

  for (let i = 0; i < positions.length; i += batchSize) {
    const batch = positions.slice(i, i + batchSize);

    // Spawn batch
    for (const pos of batch) {
      const obj = mod.SpawnObject(objectType, pos, 0);
      objects.push(obj);
    }

    // Brief pause between batches
    if (i + batchSize < positions.length) {
      await mod.Wait(0.1);
    }
  }

  return objects;
}
```

### LOD Management

```typescript
// Distance-based object management
class LODManager {
  private objects: Map<mod.SpatialObject, {
    highDetail: string;
    lowDetail: string;
    position: mod.Vector;
  }> = new Map();

  addObject(obj: mod.SpatialObject, highDetail: string, lowDetail: string) {
    const transform = mod.GetObjectTransform(obj);
    this.objects.set(obj, {
      highDetail,
      lowDetail,
      position: transform.position
    });
  }

  async updateLODs(playerPos: mod.Vector) {
    for (const [obj, data] of this.objects.entries()) {
      const distance = mod.DistanceBetween(playerPos, data.position);

      if (distance > 100) {
        // Switch to low detail
        mod.DespawnObject(obj);
        const lowObj = mod.SpawnObject(data.lowDetail, data.position, 0);
        // Update reference...
      } else {
        // Keep high detail
      }
    }
  }
}
```

### Object Limits

```typescript
// Track and respect object limits
class SpawnManager {
  private static MAX_OBJECTS = 500;  // Platform dependent
  private spawnedObjects: mod.SpatialObject[] = [];

  canSpawn(): boolean {
    return this.spawnedObjects.length < SpawnManager.MAX_OBJECTS;
  }

  spawn(objectType: string, position: mod.Vector): mod.SpatialObject | null {
    if (!this.canSpawn()) {
      console.log("Object limit reached!");
      return null;
    }

    const obj = mod.SpawnObject(objectType, position, 0);
    if (obj) {
      this.spawnedObjects.push(obj);
    }
    return obj;
  }

  despawn(obj: mod.SpatialObject) {
    const index = this.spawnedObjects.indexOf(obj);
    if (index > -1) {
      this.spawnedObjects.splice(index, 1);
      mod.DespawnObject(obj);
    }
  }

  getCount(): number {
    return this.spawnedObjects.length;
  }

  clearAll() {
    for (const obj of this.spawnedObjects) {
      mod.DespawnObject(obj);
    }
    this.spawnedObjects = [];
  }
}
```

## Best Practices

### 1. Validate Object Names

```typescript
function safeSpawn(objectName: string, position: mod.Vector): mod.SpatialObject | null {
  try {
    const obj = mod.SpawnObject(objectName, position, 0);
    if (!obj) {
      console.log(`Failed to spawn: ${objectName}`);
    }
    return obj;
  } catch (error) {
    console.log(`Invalid object name: ${objectName}`);
    return null;
  }
}
```

### 2. Clean Up on Mode End

```typescript
const allSpawnedObjects: mod.SpatialObject[] = [];

export async function OnGameModeEnded() {
  // Clean up all spawned objects
  for (const obj of allSpawnedObjects) {
    mod.DespawnObject(obj);
  }
  allSpawnedObjects.length = 0;
}
```

### 3. Use Object Pooling

```typescript
// Reuse objects instead of spawn/despawn
const pool = new ObjectPool("Global_Projectile", 100);
// Use pool.spawn() and pool.despawn()
```

### 4. Document Object Requirements

```typescript
// Map-specific object requirements
const REQUIRED_OBJECTS = {
  "MP_Dumbo": [
    "MP_Dumbo_Props_Concrete_Barrier_01",
    "MP_Dumbo_Props_Container_Red_01"
  ],
  "Global": [
    "Global_Props_Platform_01",
    "Global_Props_Barriers_01"
  ]
};
```

## Next Steps

- 📖 [Object Transform](/api/object-transform) - Moving objects
- 📖 [Gameplay Objects](/api/gameplay-objects) - Interactive objects
- 📖 [Map Objects](/guides/map-objects) - Pre-placed objects
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip Object Spawning Summary
- **14,000+ objects** - Varies by map
- **Runtime spawning** - Create objects during gameplay
- **Object pooling** - Reuse for performance
- **Transform control** - Full position/rotation
- **Lifecycle management** - Enable/disable/despawn
:::