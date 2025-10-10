# Type System

The BF6 Portal SDK uses a strongly-typed system with **22 core object types** and **41 enumerations** for type-safe game mode development.

## Overview

The SDK uses **opaque types** - you cannot create them directly, only obtain them through API functions. This ensures:

- ✅ Type safety
- ✅ Game integrity
- ✅ No invalid object references
- ✅ IDE autocomplete support

## Core Object Types

### Player & Team Types

```typescript
mod.Player        // A player in the game
mod.Team          // Team reference (Team1-Team9)
mod.Squad         // Squad reference
```

**Usage:**
```typescript
// Get players
const players = mod.AllPlayers();  // Returns mod.Array
const player = players[0];         // Type: mod.Player

// Get team
const team = mod.GetTeam(player);  // Returns mod.Team
```

### Vehicle Types

```typescript
mod.Vehicle          // Vehicle instance
mod.VehicleSpawner   // Vehicle spawn point
```

**Usage:**
```typescript
// Get vehicle spawner
const spawner = mod.GetVehicleSpawner(50);

// Spawn vehicle
mod.ForceVehicleSpawnerSpawn(spawner);
```

### AI Types

```typescript
mod.AI            // AI bot (same as mod.Player for AI)
mod.Spawner       // AI spawner
```

**Usage:**
```typescript
// Get AI spawner
const aiSpawner = mod.GetSpawner(100);

// Spawn AI
mod.SpawnAIFromAISpawner(aiSpawner);
```

### Spatial Types

```typescript
mod.SpatialObject    // Moveable world object
mod.SpawnPoint       // Player spawn point
mod.AreaTrigger      // Trigger zone
mod.InteractPoint    // Interaction point
mod.CapturePoint     // Conquest objective
mod.WorldIcon        // 3D marker icon
```

**Usage:**
```typescript
// Get spawner
const spawner = mod.GetSpawnPoint(1);

// Get trigger
const trigger = mod.GetAreaTrigger(10);

// Check if player in trigger
if (mod.IsPlayerInAreaTrigger(player, trigger)) {
  console.log("Player entered trigger!");
}
```

### Objective Types

```typescript
mod.CapturePoint       // Conquest-style objective
mod.HQ                 // Team headquarters
mod.MCOM               // Rush-style objective
mod.Sector             // Map sector
```

**Usage:**
```typescript
// Set capture point owner
const capturePoint = mod.GetCapturePoint(20);
mod.SetCapturePointOwner(capturePoint, mod.Team.Team1);
```

### Effect Types

```typescript
mod.VFX              // Visual effect
mod.SFX              // Sound effect
mod.VO               // Voice-over
mod.ScreenEffect     // Screen effect (blur, etc.)
```

**Usage:**
```typescript
// Play sound
const sound = mod.GetSFX(123);
mod.PlaySound(sound, 1.0, player);

// Enable VFX
const vfx = mod.GetVFX(456);
mod.EnableVFX(vfx, true);
```

### UI Types

```typescript
mod.UIWidget         // UI element reference
```

**Usage:**
```typescript
// Create UI container
const container = mod.AddUIContainer(
  "myContainer",
  mod.CreateVector(100, 100, 0),
  mod.CreateVector(200, 150, 0),
  mod.UIAnchor.TopLeft
);

// Find widget by name
const widget = mod.FindUIWidgetWithName("myContainer");
```

### Data Types

```typescript
mod.Vector           // 3D vector (x, y, z)
mod.Transform        // 3D transformation
mod.Array            // Collection of items
mod.Variable         // Data storage
mod.Message          // Localized text
```

**Usage:**
```typescript
// Create vector
const position = mod.CreateVector(100, 0, 50);

// Get player position
const playerTransform = mod.GetPlayerTransform(player);
const playerPos = playerTransform.position;  // mod.Vector
```

### Weapon Types

```typescript
mod.WeaponPackage    // Custom weapon config
mod.WeaponUnlock     // Weapon unlock
```

**Usage:**
```typescript
// Create weapon package
const weaponPkg = mod.CreateWeaponPackage();

// Add attachments
mod.AddAttachmentToWeaponPackage(
  mod.WeaponAttachments.ExtendedMag,
  weaponPkg
);

// Give to player
mod.AddEquipment(player, mod.Weapons.AK24, weaponPkg);
```

### Emplacement Types

```typescript
mod.EmplacementSpawner   // Stationary weapon spawner
```

**Usage:**
```typescript
// Force spawn emplacement
const emplacement = mod.GetEmplacementSpawner(60);
mod.ForceEmplacementSpawnerSpawn(emplacement);
```

### AI Waypoint Types

```typescript
mod.WaypointPath     // AI patrol path
```

**Usage:**
```typescript
// Create waypoint path
const waypoints = [
  mod.CreateVector(100, 0, 50),
  mod.CreateVector(200, 0, 50),
  mod.CreateVector(200, 0, 150)
];

const path = mod.CreateWaypointPatrolPath(waypoints);

// Assign to AI
mod.AIWaypointIdleBehavior(aiPlayer, path);
```

### Damage Types

```typescript
mod.DamageType       // Type of damage dealt
mod.DeathType        // How player died
```

**Usage:**
```typescript
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  if (deathType === mod.PlayerDeathTypes.Headshot) {
    console.log("Headshot kill!");
  }
}
```

## How to Get Objects

You **cannot** create opaque types directly. Get them through API:

### ❌ Invalid - Cannot Construct

```typescript
// ERROR: Cannot construct opaque types
const player = new mod.Player();
const vehicle = new mod.Vehicle();
const trigger = new mod.AreaTrigger();
```

### ✅ Valid - Get from API

```typescript
// Get from collections
const players = mod.AllPlayers();
const player = mod.ValueInArray(players, 0);

// Get by ID (from Godot Obj Id)
const spawner = mod.GetSpawnPoint(1);
const trigger = mod.GetAreaTrigger(10);
const aiSpawner = mod.GetSpawner(100);

// Get from game state
const team = mod.GetTeam(player);
const squad = mod.GetSquad(player);

// Create through API
const vector = mod.CreateVector(100, 0, 50);
const message = mod.Message("Hello!");
const weaponPkg = mod.CreateWeaponPackage();
```

## Type Checking

### IsType Function

```typescript
// Check object type at runtime
mod.IsType(object, mod.Types.Player);
mod.IsType(object, mod.Types.Vehicle);
mod.IsType(object, mod.Types.Vector);
```

**Example:**
```typescript
function handleObject(obj: any) {
  if (mod.IsType(obj, mod.Types.Player)) {
    console.log("It's a player!");
    const name = mod.GetPlayerName(obj as mod.Player);
  } else if (mod.IsType(obj, mod.Types.Vehicle)) {
    console.log("It's a vehicle!");
  }
}
```

### Validation

Always validate objects before use:

```typescript
// ❌ Dangerous
const spawner = mod.GetSpawnPoint(1);
mod.SpawnPlayerFromSpawnPoint(player, spawner);  // May crash!

// ✅ Safe
const spawner = mod.GetSpawnPoint(1);
if (!spawner) {
  console.log("ERROR: Spawner 1 not found!");
  return;
}
mod.SpawnPlayerFromSpawnPoint(player, spawner);
```

## Common Type Patterns

### Converting mod.Array to JavaScript Array

```typescript
import * as modlib from './modlib';

// SDK returns mod.Array
const playersArray = mod.AllPlayers();  // Type: mod.Array

// Convert to JavaScript array
const players = modlib.ConvertArray(playersArray);  // Type: any[]

// Now use JavaScript array methods
players.forEach(p => console.log(mod.GetPlayerName(p)));
players.filter(p => mod.GetTeam(p) === mod.Team.Team1);
```

### Working with Vectors

```typescript
// Create vectors
const pos1 = mod.CreateVector(0, 0, 0);
const pos2 = mod.CreateVector(100, 0, 0);

// Vector operations
const distance = mod.DistanceBetween(pos1, pos2);
const sum = mod.Add(pos1, pos2);
const scaled = mod.Multiply(pos1, 2.0);

// Extract components
const x = mod.XComponentOf(pos1);
const y = mod.YComponentOf(pos1);
const z = mod.ZComponentOf(pos1);
```

### Working with Messages

```typescript
// Simple message
const msg1 = mod.Message("Hello!");

// Message with arguments
const score = 100;
const msg2 = mod.Message("Score: {0}", score);

// Multiple arguments
const kills = 5;
const deaths = 2;
const msg3 = mod.Message("K/D: {0}/{1}", kills, deaths);

// Display to player
mod.DisplayNotificationMessage(msg1, player);
```

## Type Hierarchy

### Inheritance

Some types share functionality:

```typescript
// AI is same type as Player
const aiPlayer: mod.Player = mod.SpawnAIFromAISpawner(spawner);

// Can use all player functions on AI
mod.SetTeam(aiPlayer, mod.Team.Team2);
mod.SetPlayerMaxHealth(aiPlayer, 150);
mod.Teleport(aiPlayer, position, 0);
```

### Generic Object Type

```typescript
// Some functions accept generic Object
mod.SpawnObject(objectId, position, rotation);  // Returns Object
mod.UnspawnObject(obj);                         // Takes Object

// Object can be many types
mod.EnableSpatialObject(spatialObj, true);
```

## Type Safety Benefits

### IDE Autocomplete

With proper TypeScript setup:

```typescript
// Type: mod.Player
const player = mod.ValueInArray(mod.AllPlayers(), 0);

// IDE shows available functions for Player
player.  // Autocomplete shows GetPlayerName, GetTeam, etc.
```

### Compile-Time Errors

```typescript
// ❌ Compile error - wrong parameter type
mod.SetTeam(player, "Team1");  // String not allowed

// ✅ Correct - use enum
mod.SetTeam(player, mod.Team.Team1);
```

### Function Overloading

Many functions have multiple signatures:

```typescript
// Different parameter combinations
mod.DealDamage(player, 50);                    // Damage without attacker
mod.DealDamage(player, 50, attackerPlayer);    // Damage with attacker
mod.DealDamage(vehicle, 50);                   // Damage vehicle

// TypeScript knows which overload to use
```

## Best Practices

### 1. Use Descriptive Variable Names

```typescript
// ❌ Bad
const s = mod.GetSpawnPoint(1);
const t = mod.GetAreaTrigger(10);

// ✅ Good
const playerSpawner = mod.GetSpawnPoint(1);
const checkpointTrigger = mod.GetAreaTrigger(10);
```

### 2. Always Validate Objects

```typescript
function spawnPlayer(player: mod.Player, spawnerId: number) {
  const spawner = mod.GetSpawnPoint(spawnerId);

  if (!spawner) {
    console.log(`ERROR: Spawner ${spawnerId} not found!`);
    return false;
  }

  mod.SpawnPlayerFromSpawnPoint(player, spawner);
  return true;
}
```

### 3. Cache Type Conversions

```typescript
// ❌ Bad - convert every frame
async function gameLoop() {
  while (true) {
    const players = modlib.ConvertArray(mod.AllPlayers());  // Wasteful
    updateUI(players);
    await mod.Wait(0.1);
  }
}

// ✅ Good - cache and update on changes
let cachedPlayers: mod.Player[] = [];

export async function OnPlayerJoinGame(player: mod.Player) {
  cachedPlayers = modlib.ConvertArray(mod.AllPlayers());
}

export async function OnPlayerLeaveGame(playerId: string) {
  cachedPlayers = modlib.ConvertArray(mod.AllPlayers());
}

async function gameLoop() {
  while (true) {
    updateUI(cachedPlayers);
    await mod.Wait(0.1);
  }
}
```

### 4. Use Type Annotations

```typescript
// Explicit types for clarity
const spawner: mod.SpawnPoint = mod.GetSpawnPoint(1);
const trigger: mod.AreaTrigger = mod.GetAreaTrigger(10);
const players: mod.Player[] = modlib.ConvertArray(mod.AllPlayers());

// Helps catch errors early
function teleportPlayer(player: mod.Player, destination: mod.Vector) {
  mod.Teleport(player, destination, 0);
}
```

## TypeScript Configuration

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "module": "ESNext",
    "moduleResolution": "node",
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "esModuleInterop": true
  }
}
```

### Type Definitions

Reference the SDK type definitions:

```typescript
/// <reference path="../../code/mod/index.d.ts" />
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';
```

## Next Steps

- 📖 [Enumerations](/api/enums) - All available enum values
- 📖 [Object System](/guides/object-system) - Working with opaque types
- 📚 [Player Control](/api/player-control) - Player API functions
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip Type System Summary
- **22 opaque types** - Cannot construct, only get from API
- **Type safety** - Catch errors at compile time
- **Validation required** - Always check objects exist
- **Use modlib** - Helpers for common type operations
- **Cache conversions** - Don't convert arrays every frame
:::
