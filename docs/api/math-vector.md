# Math & Vector API Reference

Complete reference for vector operations and mathematical utilities in the BF6 Portal SDK.

## Overview

The Math & Vector system provides:
- **Vector creation** - 3D vector construction
- **Vector operations** - Arithmetic, normalization, distance
- **Utility functions** - Random numbers, clamping, math helpers
- **Position/rotation** - 3D coordinate manipulation

---

## Vector Type

Vectors represent 3D positions, directions, rotations, and colors in the SDK.

### Vector Structure

```typescript
interface Vector {
  x: number;
  y: number;
  z: number;
}
```

**Common Uses:**
- **Position**: `(x, y, z)` world coordinates
- **Rotation**: `(pitch, yaw, roll)` in degrees
- **Direction**: `(x, y, z)` unit vector
- **Color**: `(r, g, b)` with values 0-1
- **Scale**: `(x, y, z)` scale factors

---

## Vector Creation

### CreateVector

Create a 3D vector:

```typescript
mod.CreateVector(x: number, y: number, z: number): Vector
```

**Examples:**
```typescript
// Position vector
const position = mod.CreateVector(100, 50, 200);

// Direction vector (forward)
const forward = mod.CreateVector(0, 0, 1);

// RGB color (red)
const red = mod.CreateVector(1, 0, 0);

// UI position (2D, z ignored)
const uiPos = mod.CreateVector(100, 50, 0);

// Rotation (pitch, yaw, roll in degrees)
const rotation = mod.CreateVector(0, 90, 0);  // 90° yaw
```

---

## Vector Operations

### Vector Arithmetic

Use standard JavaScript operators:

```typescript
// Addition
const sum = mod.CreateVector(
  pos1.x + pos2.x,
  pos1.y + pos2.y,
  pos1.z + pos2.z
);

// Subtraction (direction from A to B)
const direction = mod.CreateVector(
  posB.x - posA.x,
  posB.y - posA.y,
  posB.z - posA.z
);

// Scalar multiplication
const scaled = mod.CreateVector(
  vec.x * 2,
  vec.y * 2,
  vec.z * 2
);

// Scalar division
const half = mod.CreateVector(
  vec.x / 2,
  vec.y / 2,
  vec.z / 2
);
```

### Vector Length (Magnitude)

```typescript
function vectorLength(v: mod.Vector): number {
  return Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

// Usage
const vel = mod.GetSoldierState(player, mod.SoldierStateVector.GetLinearVelocity);
const speed = vectorLength(vel);
console.log(`Player speed: ${speed} m/s`);
```

### Vector Normalization

Convert to unit vector (length = 1):

```typescript
function normalize(v: mod.Vector): mod.Vector {
  const len = vectorLength(v);
  if (len === 0) return mod.CreateVector(0, 0, 0);

  return mod.CreateVector(v.x / len, v.y / len, v.z / len);
}

// Usage - Get direction from player to target
const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
const targetPos = mod.GetSoldierState(target, mod.SoldierStateVector.GetPosition);

const direction = mod.CreateVector(
  targetPos.x - playerPos.x,
  targetPos.y - playerPos.y,
  targetPos.z - playerPos.z
);

const normalizedDir = normalize(direction);  // Unit vector pointing at target
```

### Distance Between Points

```typescript
function distance(a: mod.Vector, b: mod.Vector): number {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const dz = b.z - a.z;

  return Math.sqrt(dx * dx + dy * dy + dz * dz);
}

// Usage
const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
const objectPos = mod.GetObjectTransform(obj).position;

if (distance(playerPos, objectPos) < 5) {
  console.log("Player is within 5 meters of object");
}
```

### 2D Distance (Ignore Height)

```typescript
function distance2D(a: mod.Vector, b: mod.Vector): number {
  const dx = b.x - a.x;
  const dz = b.z - a.z;

  return Math.sqrt(dx * dx + dz * dz);
}

// Useful for horizontal range checks
```

### Dot Product

Measure alignment between vectors:

```typescript
function dotProduct(a: mod.Vector, b: mod.Vector): number {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}

// Usage - Check if player is facing target
const facingDir = mod.GetSoldierState(player, mod.SoldierStateVector.GetFacingDirection);
const toTarget = normalize(mod.CreateVector(
  targetPos.x - playerPos.x,
  targetPos.y - playerPos.y,
  targetPos.z - playerPos.z
));

const dot = dotProduct(facingDir, toTarget);

if (dot > 0.9) {
  console.log("Player is facing target (within ~25°)");
}
```

**Dot Product Values:**
- `1.0` - Vectors point same direction (0°)
- `0.0` - Vectors perpendicular (90°)
- `-1.0` - Vectors point opposite directions (180°)

---

## Math Utilities

### Random Numbers

JavaScript's `Math.random()` is available:

```typescript
// Random float [0, 1)
const rand = Math.random();

// Random integer [min, max]
function randomInt(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Random float [min, max]
function randomFloat(min: number, max: number): number {
  return Math.random() * (max - min) + min;
}

// Random vector within bounds
function randomPosition(bounds: number): mod.Vector {
  return mod.CreateVector(
    randomFloat(-bounds, bounds),
    randomFloat(0, 10),
    randomFloat(-bounds, bounds)
  );
}
```

### Clamping

Restrict value to range:

```typescript
function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

// Usage
const damage = clamp(damageAmount, 0, maxHealth);
```

### Lerp (Linear Interpolation)

Blend between two values:

```typescript
function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t;
}

// Vector lerp
function lerpVector(a: mod.Vector, b: mod.Vector, t: number): mod.Vector {
  return mod.CreateVector(
    lerp(a.x, b.x, t),
    lerp(a.y, b.y, t),
    lerp(a.z, b.z, t)
  );
}

// Usage - Smooth movement
async function moveObjectSmoothly(obj: mod.SpatialObject, from: mod.Vector, to: mod.Vector) {
  for (let t = 0; t <= 1; t += 0.05) {
    const currentPos = lerpVector(from, to, t);
    mod.SetObjectTransform(obj, currentPos, mod.CreateVector(0, 0, 0));
    await mod.Wait(0.05);
  }
}
```

---

## Common Patterns

### Proximity Detection

```typescript
function getPlayersNearPosition(position: mod.Vector, radius: number): mod.Player[] {
  const players = modlib.ConvertArray(mod.AllPlayers());
  const nearbyPlayers: mod.Player[] = [];

  for (const player of players) {
    const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);

    if (distance(position, playerPos) <= radius) {
      nearbyPlayers.push(player);
    }
  }

  return nearbyPlayers;
}
```

### Circular Zone Check

```typescript
function isPlayerInCircle(player: mod.Player, center: mod.Vector, radius: number): boolean {
  const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
  return distance2D(playerPos, center) <= radius;
}
```

### Look-At Direction

```typescript
function getLookAtDirection(from: mod.Vector, to: mod.Vector): mod.Vector {
  const direction = mod.CreateVector(
    to.x - from.x,
    to.y - from.y,
    to.z - from.z
  );

  return normalize(direction);
}
```

### Velocity-Based Position Prediction

```typescript
function predictPosition(currentPos: mod.Vector, velocity: mod.Vector, time: number): mod.Vector {
  return mod.CreateVector(
    currentPos.x + velocity.x * time,
    currentPos.y + velocity.y * time,
    currentPos.z + velocity.z * time
  );
}

// Usage - Predict where player will be in 1 second
const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
const playerVel = mod.GetSoldierState(player, mod.SoldierStateVector.GetLinearVelocity);
const futurePos = predictPosition(playerPos, playerVel, 1.0);
```

### Spawn in Circle Pattern

```typescript
function getCirclePosition(center: mod.Vector, radius: number, angle: number): mod.Vector {
  const radians = angle * (Math.PI / 180);

  return mod.CreateVector(
    center.x + radius * Math.cos(radians),
    center.y,
    center.z + radius * Math.sin(radians)
  );
}

// Spawn players in circle
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

### Grid Layout

```typescript
function getGridPosition(index: number, gridWidth: number, spacing: number, origin: mod.Vector): mod.Vector {
  const row = Math.floor(index / gridWidth);
  const col = index % gridWidth;

  return mod.CreateVector(
    origin.x + col * spacing,
    origin.y,
    origin.z + row * spacing
  );
}
```

---

## Coordinate System

### Axis Orientation

- **X**: East (+) / West (-)
- **Y**: Up (+) / Down (-)
- **Z**: North (+) / South (-)

### Rotation

Rotations are in **degrees**:

```typescript
// Face north
const north = mod.CreateVector(0, 0, 0);

// Face east (90° yaw)
const east = mod.CreateVector(0, 90, 0);

// Face south (180° yaw)
const south = mod.CreateVector(0, 180, 0);

// Face west (270° yaw)
const west = mod.CreateVector(0, 270, 0);
```

---

## Best Practices

### 1. Normalize Directions

```typescript
// ✅ Good - Normalized direction for consistent speed
const direction = normalize(toTarget);
const moveVector = mod.CreateVector(
  direction.x * speed,
  direction.y * speed,
  direction.z * speed
);

// ❌ Bad - Unnormalized direction causes variable speed
const moveVector = mod.CreateVector(
  toTarget.x * speed,  // Speed depends on distance!
  toTarget.y * speed,
  toTarget.z * speed
);
```

### 2. Use 2D Distance When Appropriate

```typescript
// ✅ Good - Ignore height for ground-based range
if (distance2D(playerPos, objectPos) < 5) {
  // Within 5m horizontally
}

// ❌ Bad - Height matters when it shouldn't
if (distance(playerPos, objectPos) < 5) {
  // Player above/below object fails check
}
```

### 3. Avoid Division by Zero

```typescript
// ✅ Good - Check for zero length
function normalize(v: mod.Vector): mod.Vector {
  const len = vectorLength(v);
  if (len === 0) return mod.CreateVector(0, 0, 0);
  return mod.CreateVector(v.x / len, v.y / len, v.z / len);
}

// ❌ Bad - Division by zero crash
function normalize(v: mod.Vector): mod.Vector {
  const len = vectorLength(v);
  return mod.CreateVector(v.x / len, v.y / len, v.z / len);
}
```

### 4. Cache Expensive Calculations

```typescript
// ✅ Good - Calculate once
const len = vectorLength(v);
const normalized = mod.CreateVector(v.x / len, v.y / len, v.z / len);

// ❌ Bad - Calculate three times
const normalized = mod.CreateVector(
  v.x / vectorLength(v),
  v.y / vectorLength(v),
  v.z / vectorLength(v)
);
```

---

## API Functions Summary

| Category | Functions/Utilities |
|----------|-------------------|
| **Vector Creation** | CreateVector |
| **Vector Operations** | Length, normalize, distance, dot product (custom helpers) |
| **Math Utilities** | Random, clamp, lerp (JavaScript Math + custom helpers) |

**Note:** Most vector operations require custom helper functions built on CreateVector and JavaScript Math.

---

## See Also

- 📖 [Object Transform](/api/object-transform) - Apply vectors to objects
- 📖 [Player State](/api/player-state) - Get player position/velocity
- 📖 [VFX & Audio](/api/vfx-audio) - 3D positioned effects
- 📚 [API Overview](/api/) - Complete API reference

---

★ Insight ─────────────────────────────────────
**Vector System Design**
1. **Simple Structure** - Vectors are plain {x, y, z} objects without built-in methods, requiring custom helper functions
2. **Multi-Purpose Vectors** - Same Vector type represents positions, rotations, directions, colors, and scales through context
3. **Degrees Not Radians** - Rotations use degrees (0-360) unlike most 3D engines, avoiding conversion overhead for game logic
─────────────────────────────────────────────────
