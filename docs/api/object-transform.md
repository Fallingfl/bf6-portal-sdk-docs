# Object Transform

Functions for manipulating object positions, rotations, and transformations in 3D space.

## Overview

The object transform system provides:
- Full 3D position and rotation control
- Movement and orbit animations
- Transform queries for spatial objects
- Vector-based transformation operations
- Runtime object manipulation

## Transform Structure

### Transform Object

A Transform contains position and orientation vectors:

```typescript
interface Transform {
  position: Vector;    // World position (x, y, z)
  right: Vector;       // Right direction vector
  up: Vector;          // Up direction vector
  front: Vector;       // Forward direction vector
}
```

The three direction vectors (right, up, front) define the object's rotation in 3D space using a right-handed coordinate system.

**Example:**
```typescript
// Identity transform (no rotation)
const identityTransform = {
  position: mod.CreateVector(0, 0, 0),
  right: mod.CreateVector(1, 0, 0),    // X-axis
  up: mod.CreateVector(0, 1, 0),       // Y-axis
  front: mod.CreateVector(0, 0, 1)     // Z-axis
};

// Rotated 90 degrees around Y-axis
const rotatedTransform = {
  position: mod.CreateVector(100, 0, 50),
  right: mod.CreateVector(0, 0, -1),   // Facing -Z
  up: mod.CreateVector(0, 1, 0),       // Still up
  front: mod.CreateVector(1, 0, 0)     // Facing +X
};
```

## Transform Functions

### GetObjectTransform

```typescript
GetObjectTransform(object: SpatialObject): Transform
GetPlayerTransform(player: Player): Transform
```

Get the current transform of an object or player.

**Example:**
```typescript
// Get object transform
const PLATFORM_ID = 100;
const platform = mod.GetSpatialObject(PLATFORM_ID);
const transform = mod.GetObjectTransform(platform);

console.log(`Platform at: ${transform.position.x}, ${transform.position.y}, ${transform.position.z}`);

// Get player transform
export async function OnPlayerDeployed(player: mod.Player) {
  const playerTransform = mod.GetPlayerTransform(player);
  const spawnPos = playerTransform.position;

  console.log(`Player spawned at: ${spawnPos.x}, ${spawnPos.y}, ${spawnPos.z}`);
}
```

### SetObjectTransform

```typescript
SetObjectTransform(object: SpatialObject, transform: Transform): void
```

Set the complete transform of an object.

**Example:**
```typescript
// Move and rotate platform
const platform = mod.GetSpatialObject(100);
const currentTransform = mod.GetObjectTransform(platform);

// Move 10 units up
currentTransform.position = mod.Add(
  currentTransform.position,
  mod.CreateVector(0, 10, 0)
);

// Apply new transform
mod.SetObjectTransform(platform, currentTransform);

// Create new transform from scratch
const newTransform = {
  position: mod.CreateVector(500, 100, 250),
  right: mod.CreateVector(1, 0, 0),
  up: mod.CreateVector(0, 1, 0),
  front: mod.CreateVector(0, 0, 1)
};

mod.SetObjectTransform(platform, newTransform);
```

### MoveObject

```typescript
MoveObject(object: SpatialObject, position: Vector, rotation: number): void
```

Move and rotate an object using simplified parameters.

**Parameters:**
- `object` - The object to move
- `position` - New world position
- `rotation` - Rotation in degrees around Y-axis

**Example:**
```typescript
// Simple movement
const barrier = mod.GetSpatialObject(50);
const newPos = mod.CreateVector(100, 0, 50);

mod.MoveObject(barrier, newPos, 45);  // Move and rotate 45 degrees

// Create moving platform
async function createMovingPlatform(platformId: number) {
  const platform = mod.GetSpatialObject(platformId);
  const startPos = mod.CreateVector(0, 0, 0);
  const endPos = mod.CreateVector(100, 0, 0);

  while (true) {
    // Move to end
    for (let i = 0; i <= 100; i += 2) {
      const t = i / 100;
      const currentPos = mod.CreateVector(t * 100, 0, 0);
      mod.MoveObject(platform, currentPos, 0);
      await mod.Wait(0.1);
    }

    // Move back to start
    for (let i = 100; i >= 0; i -= 2) {
      const t = i / 100;
      const currentPos = mod.CreateVector(t * 100, 0, 0);
      mod.MoveObject(platform, currentPos, 0);
      await mod.Wait(0.1);
    }
  }
}
```

### EnableObject

```typescript
EnableObject(object: SpatialObject, enabled: boolean): void
```

Show or hide an object (also affects collision).

**Example:**
```typescript
// Disappearing platforms puzzle
const platforms = [100, 101, 102, 103, 104];

async function disappearingPlatformSequence() {
  while (true) {
    // Hide platforms one by one
    for (const platformId of platforms) {
      const platform = mod.GetSpatialObject(platformId);
      mod.EnableObject(platform, false);
      await mod.Wait(1);
    }

    // Show them again
    for (const platformId of platforms) {
      const platform = mod.GetSpatialObject(platformId);
      mod.EnableObject(platform, true);
      await mod.Wait(1);
    }

    await mod.Wait(3);  // Pause before repeating
  }
}
```

## Orbit and Animation

### OrbitObjectOverTime

```typescript
OrbitObjectOverTime(object: SpatialObject, center: Vector, axis: Vector, angularSpeed: number, duration: number): void
OrbitObjectOverTime(object: SpatialObject, center: Vector, axis: Vector, angularSpeed: number): void
```

Make an object orbit around a point.

**Parameters:**
- `center` - Center point of orbit
- `axis` - Axis of rotation (normalized vector)
- `angularSpeed` - Speed in degrees per second
- `duration` - Duration in seconds (omit for infinite)

**Example:**
```typescript
// Orbiting platforms around central point
export async function OnGameModeStarted() {
  const centerPoint = mod.CreateVector(500, 50, 500);
  const platformIds = [100, 101, 102, 103];

  platformIds.forEach((id, index) => {
    const platform = mod.GetSpatialObject(id);
    const angle = (index / platformIds.length) * 360;

    // Position platforms in circle
    const radius = 50;
    const radians = angle * Math.PI / 180;
    const startPos = mod.CreateVector(
      centerPoint.x + Math.cos(radians) * radius,
      centerPoint.y,
      centerPoint.z + Math.sin(radians) * radius
    );

    mod.MoveObject(platform, startPos, 0);

    // Start orbiting
    const yAxis = mod.CreateVector(0, 1, 0);
    mod.OrbitObjectOverTime(platform, centerPoint, yAxis, 30);  // 30 deg/sec
  });
}

// Orbit for limited time
function temporaryOrbit(objectId: number, duration: number) {
  const object = mod.GetSpatialObject(objectId);
  const center = mod.CreateVector(0, 0, 0);
  const axis = mod.CreateVector(0, 1, 0);

  mod.OrbitObjectOverTime(object, center, axis, 45, duration);
}
```

## Transform Manipulation Patterns

### Interpolated Movement

```typescript
// Smooth movement between two points
async function smoothMove(
  object: mod.SpatialObject,
  startPos: mod.Vector,
  endPos: mod.Vector,
  duration: number
) {
  const steps = 50;
  const stepDelay = duration / steps;

  for (let i = 0; i <= steps; i++) {
    const t = i / steps;

    // Linear interpolation
    const currentPos = mod.CreateVector(
      startPos.x + (endPos.x - startPos.x) * t,
      startPos.y + (endPos.y - startPos.y) * t,
      startPos.z + (endPos.z - startPos.z) * t
    );

    mod.MoveObject(object, currentPos, 0);
    await mod.Wait(stepDelay);
  }
}

// Usage
const platform = mod.GetSpatialObject(100);
const start = mod.CreateVector(0, 0, 0);
const end = mod.CreateVector(100, 0, 0);

smoothMove(platform, start, end, 5);  // Move over 5 seconds
```

### Smooth Rotation

```typescript
// Rotate object smoothly
async function smoothRotate(
  object: mod.SpatialObject,
  startAngle: number,
  endAngle: number,
  duration: number
) {
  const steps = 50;
  const stepDelay = duration / steps;
  const transform = mod.GetObjectTransform(object);

  for (let i = 0; i <= steps; i++) {
    const t = i / steps;
    const currentAngle = startAngle + (endAngle - startAngle) * t;

    mod.MoveObject(object, transform.position, currentAngle);
    await mod.Wait(stepDelay);
  }
}

// Spin object 360 degrees
async function spin360(objectId: number, duration: number) {
  const object = mod.GetSpatialObject(objectId);
  await smoothRotate(object, 0, 360, duration);
}
```

### Pendulum Movement

```typescript
// Create pendulum swing
async function pendulumSwing(objectId: number, amplitude: number, period: number) {
  const object = mod.GetSpatialObject(objectId);
  const centerTransform = mod.GetObjectTransform(object);
  const centerPos = centerTransform.position;

  let time = 0;
  const steps = 100;
  const stepDelay = period / steps;

  while (true) {
    // Sine wave for smooth oscillation
    const offset = Math.sin(time) * amplitude;
    const currentPos = mod.CreateVector(
      centerPos.x + offset,
      centerPos.y,
      centerPos.z
    );

    mod.MoveObject(object, currentPos, 0);

    time += (Math.PI * 2) / steps;
    await mod.Wait(stepDelay);
  }
}

// Swinging bridge
pendulumSwing(100, 5, 4);  // Swing 5 units over 4 seconds
```

### Circular Path

```typescript
// Move object in circle
async function circularPath(
  objectId: number,
  center: mod.Vector,
  radius: number,
  period: number
) {
  const object = mod.GetSpatialObject(objectId);
  const steps = 100;
  const stepDelay = period / steps;

  while (true) {
    for (let i = 0; i < steps; i++) {
      const angle = (i / steps) * Math.PI * 2;
      const pos = mod.CreateVector(
        center.x + Math.cos(angle) * radius,
        center.y,
        center.z + Math.sin(angle) * radius
      );

      // Rotate to face forward along path
      const lookAngle = (angle * 180 / Math.PI) + 90;
      mod.MoveObject(object, pos, lookAngle);

      await mod.Wait(stepDelay);
    }
  }
}
```

### Elevator Movement

```typescript
// Vertical elevator
class Elevator {
  private objectId: number;
  private bottomY: number;
  private topY: number;
  private speed: number;
  private isMoving: boolean = false;

  constructor(objectId: number, bottomY: number, topY: number, speed: number) {
    this.objectId = objectId;
    this.bottomY = bottomY;
    this.topY = topY;
    this.speed = speed;
  }

  async moveToTop() {
    if (this.isMoving) return;
    this.isMoving = true;

    const object = mod.GetSpatialObject(this.objectId);
    const transform = mod.GetObjectTransform(object);
    const currentPos = transform.position;

    const distance = Math.abs(this.topY - currentPos.y);
    const duration = distance / this.speed;
    const steps = Math.floor(duration * 10);
    const stepDelay = duration / steps;

    for (let i = 0; i <= steps; i++) {
      const t = i / steps;
      const y = currentPos.y + (this.topY - currentPos.y) * t;
      const pos = mod.CreateVector(currentPos.x, y, currentPos.z);

      mod.MoveObject(object, pos, 0);
      await mod.Wait(stepDelay);
    }

    this.isMoving = false;
  }

  async moveToBottom() {
    if (this.isMoving) return;
    this.isMoving = true;

    const object = mod.GetSpatialObject(this.objectId);
    const transform = mod.GetObjectTransform(object);
    const currentPos = transform.position;

    const distance = Math.abs(this.bottomY - currentPos.y);
    const duration = distance / this.speed;
    const steps = Math.floor(duration * 10);
    const stepDelay = duration / steps;

    for (let i = 0; i <= steps; i++) {
      const t = i / steps;
      const y = currentPos.y + (this.bottomY - currentPos.y) * t;
      const pos = mod.CreateVector(currentPos.x, y, currentPos.z);

      mod.MoveObject(object, pos, 0);
      await mod.Wait(stepDelay);
    }

    this.isMoving = false;
  }

  async autoLoop(waitTime: number) {
    while (true) {
      await this.moveToTop();
      await mod.Wait(waitTime);
      await this.moveToBottom();
      await mod.Wait(waitTime);
    }
  }
}

// Usage
const elevator = new Elevator(100, 0, 50, 10);  // Object 100, 0-50 height, 10 units/sec
elevator.autoLoop(3);  // Wait 3 seconds at each end
```

## Advanced Transformation

### Matrix-Style Rotation

```typescript
// Rotate transform around arbitrary axis
function rotateTransform(
  transform: mod.Transform,
  axis: mod.Vector,
  angleDegrees: number
): mod.Transform {
  const radians = angleDegrees * Math.PI / 180;
  const cos = Math.cos(radians);
  const sin = Math.sin(radians);

  // Normalize axis
  const axisNorm = mod.Normalize(axis);
  const x = axisNorm.x;
  const y = axisNorm.y;
  const z = axisNorm.z;

  // Rodrigues' rotation formula (simplified for game use)
  // This is a basic implementation - for complex rotations,
  // use the orbit functions instead

  return {
    position: transform.position,
    right: transform.right,  // Would need full matrix math
    up: transform.up,
    front: transform.front
  };
}
```

### Local vs World Space

```typescript
// Move object in its local space
function moveObjectLocal(
  object: mod.SpatialObject,
  localOffset: mod.Vector
) {
  const transform = mod.GetObjectTransform(object);

  // Convert local offset to world space
  const worldOffset = mod.CreateVector(
    localOffset.x * transform.right.x + localOffset.y * transform.up.x + localOffset.z * transform.front.x,
    localOffset.x * transform.right.y + localOffset.y * transform.up.y + localOffset.z * transform.front.y,
    localOffset.x * transform.right.z + localOffset.y * transform.up.z + localOffset.z * transform.front.z
  );

  // Move in world space
  const newPos = mod.Add(transform.position, worldOffset);
  mod.MoveObject(object, newPos, 0);
}

// Example: Move 5 units forward in object's local space
const object = mod.GetSpatialObject(100);
moveObjectLocal(object, mod.CreateVector(0, 0, 5));
```

## Transform Tracking

### Position Tracking System

```typescript
// Track object positions over time
class PositionTracker {
  private positions: Map<mod.SpatialObject, mod.Vector[]> = new Map();
  private maxHistorySize: number;

  constructor(maxHistorySize: number = 100) {
    this.maxHistorySize = maxHistorySize;
  }

  recordPosition(object: mod.SpatialObject) {
    const transform = mod.GetObjectTransform(object);
    const position = transform.position;

    if (!this.positions.has(object)) {
      this.positions.set(object, []);
    }

    const history = this.positions.get(object)!;
    history.push(position);

    // Limit history size
    if (history.length > this.maxHistorySize) {
      history.shift();
    }
  }

  getAveragePosition(object: mod.SpatialObject): mod.Vector | null {
    const history = this.positions.get(object);
    if (!history || history.length === 0) return null;

    let sumX = 0, sumY = 0, sumZ = 0;
    for (const pos of history) {
      sumX += pos.x;
      sumY += pos.y;
      sumZ += pos.z;
    }

    return mod.CreateVector(
      sumX / history.length,
      sumY / history.length,
      sumZ / history.length
    );
  }

  getTotalDistance(object: mod.SpatialObject): number {
    const history = this.positions.get(object);
    if (!history || history.length < 2) return 0;

    let totalDistance = 0;
    for (let i = 1; i < history.length; i++) {
      totalDistance += mod.DistanceBetween(history[i - 1], history[i]);
    }

    return totalDistance;
  }
}

// Usage
const tracker = new PositionTracker(50);

async function trackPlatform(objectId: number) {
  const object = mod.GetSpatialObject(objectId);

  while (true) {
    tracker.recordPosition(object);
    await mod.Wait(0.1);  // Track 10 times per second
  }
}
```

## Common Transform Patterns

### Follow Target

```typescript
// Make object follow a target
async function followTarget(
  follower: mod.SpatialObject,
  target: mod.Player,
  distance: number,
  height: number
) {
  while (true) {
    if (!mod.IsPlayerValid(target)) break;

    const targetPos = mod.GetSoldierState(target, mod.SoldierStateVector.GetPosition);
    const lookDir = mod.GetSoldierState(target, mod.SoldierStateVector.GetViewDirection);

    // Position behind target
    const followPos = mod.CreateVector(
      targetPos.x - lookDir.x * distance,
      targetPos.y + height,
      targetPos.z - lookDir.z * distance
    );

    mod.MoveObject(follower, followPos, 0);
    await mod.Wait(0.1);
  }
}
```

### Snap to Grid

```typescript
// Snap object position to grid
function snapToGrid(object: mod.SpatialObject, gridSize: number) {
  const transform = mod.GetObjectTransform(object);
  const pos = transform.position;

  const snappedPos = mod.CreateVector(
    Math.round(pos.x / gridSize) * gridSize,
    Math.round(pos.y / gridSize) * gridSize,
    Math.round(pos.z / gridSize) * gridSize
  );

  mod.MoveObject(object, snappedPos, 0);
}
```

### Look At Target

```typescript
// Rotate object to look at target
function lookAtTarget(object: mod.SpatialObject, targetPos: mod.Vector) {
  const transform = mod.GetObjectTransform(object);
  const objPos = transform.position;

  // Calculate direction
  const direction = mod.Subtract(targetPos, objPos);

  // Calculate angle
  const angle = Math.atan2(direction.x, direction.z) * 180 / Math.PI;

  mod.MoveObject(object, objPos, angle);
}
```

## Performance Considerations

### Batching Transforms

```typescript
// Update multiple objects efficiently
async function batchUpdateObjects(objects: mod.SpatialObject[], interval: number) {
  while (true) {
    // Update all objects in one frame
    for (const obj of objects) {
      const transform = mod.GetObjectTransform(obj);
      // Modify transform...
      mod.SetObjectTransform(obj, transform);
    }

    await mod.Wait(interval);
  }
}
```

### Caching Transforms

```typescript
// Cache transforms to avoid repeated queries
const transformCache = new Map<mod.SpatialObject, mod.Transform>();

function getCachedTransform(object: mod.SpatialObject): mod.Transform {
  if (!transformCache.has(object)) {
    const transform = mod.GetObjectTransform(object);
    transformCache.set(object, transform);
  }
  return transformCache.get(object)!;
}

function updateCachedTransform(object: mod.SpatialObject, transform: mod.Transform) {
  transformCache.set(object, transform);
  mod.SetObjectTransform(object, transform);
}
```

## Best Practices

### 1. Use Appropriate Methods

```typescript
// ✅ Good - Simple movement
mod.MoveObject(object, position, rotation);

// ✅ Good - Complex rotation needs
mod.SetObjectTransform(object, customTransform);

// ✅ Good - Continuous orbit
mod.OrbitObjectOverTime(object, center, axis, speed);
```

### 2. Validate Objects

```typescript
function safeTransform(objectId: number) {
  const object = mod.GetSpatialObject(objectId);
  if (!object) {
    console.log(`Object ${objectId} not found`);
    return;
  }

  const transform = mod.GetObjectTransform(object);
  // Safe to use transform
}
```

### 3. Smooth Animations

```typescript
// Use sufficient steps for smooth movement
const SMOOTH_STEPS = 50;  // Good
const CHOPPY_STEPS = 5;   // Too few

// Balance smoothness with performance
async function balancedAnimation(object: mod.SpatialObject) {
  const steps = 30;  // 30 steps is usually smooth enough
  const delay = 0.05;  // 20 fps is acceptable for most animations

  for (let i = 0; i < steps; i++) {
    // Update transform
    await mod.Wait(delay);
  }
}
```

### 4. Clean Up Animations

```typescript
// Store animation state to cancel if needed
let isAnimating = false;

async function cancelableAnimation(object: mod.SpatialObject) {
  if (isAnimating) return;

  isAnimating = true;
  try {
    // Run animation
    for (let i = 0; i < 100 && isAnimating; i++) {
      // Transform object
      await mod.Wait(0.1);
    }
  } finally {
    isAnimating = false;
  }
}

function cancelAnimation() {
  isAnimating = false;
}
```

## Next Steps

- 📖 [Object Spawning](/api/object-spawning) - Creating objects at runtime
- 📖 [Gameplay Objects](/api/gameplay-objects) - Interactive game objects
- 📖 [Math & Vector](/api/math-vector) - Vector mathematics
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip Object Transform Summary
- **Full 3D control** - Position and rotation manipulation
- **Smooth animations** - Interpolated movement and orbit
- **Transform queries** - Get current object state
- **Performance** - Cache transforms when possible
- **Validation** - Always check object references
:::
