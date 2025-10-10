# Object System

Learn how the SDK's opaque type system works and how to properly work with game objects like players, vehicles, and spatial objects.

## Overview

The BF6 Portal SDK uses **opaque types** - you cannot create them directly, only obtain them through API functions. This ensures game integrity and prevents invalid object references.

## Core Concept

### What Are Opaque Types?

```typescript
// ❌ You CANNOT do this:
let player = new mod.Player();  // ERROR: Cannot construct

// ✅ You MUST get them from API:
const players = mod.GetPlayers();
const player = mod.GetArrayElement(players, 0);
```

**Why Opaque?**
- Prevents creating invalid objects
- Ensures objects exist in the game world
- Maintains synchronization between client and server

### 22 Core Object Types

The SDK provides these opaque types:

#### Player & Team
- `mod.Player` - A player in the game
- `mod.Team` - A team (enum: Team1-Team9)

#### Vehicles & AI
- `mod.Vehicle` - A vehicle instance
- `mod.AI` - An AI bot

#### Spawners
- `mod.Spawner` - Generic spawner
- `mod.VehicleSpawner` - Vehicle spawn point
- `mod.AISpawner` - AI spawn point

#### Gameplay Objects
- `mod.SpatialObject` - Placed object from Godot
- `mod.AreaTrigger` - Trigger zone
- `mod.InteractPoint` - Interaction point
- `mod.CapturePoint` - Capture zone
- `mod.WorldIcon` - 3D icon marker

#### Effects
- `mod.VFX` - Visual effect
- `mod.Audio` - Audio source

#### Data Types
- `mod.Vector` - 3D position/direction
- `mod.Transform` - Position + rotation
- `mod.Array` - Collection of items

## Working with Players

### Getting Players

```typescript
// Get all players
const allPlayers = mod.GetPlayers();  // Returns mod.Array<mod.Player>

// Get specific player
const player = mod.GetPlayerById(playerId);  // Returns mod.Player | undefined

// Get players in a team
const team1Players = mod.GetPlayersInTeam(mod.Team.Team1);
```

### Player Properties

```typescript
// Get player information
const name = mod.GetPlayerName(player);
const id = mod.GetPlayerId(player);
const team = mod.GetPlayerTeam(player);
const score = mod.GetPlayerScore(player);
const health = mod.GetPlayerHealth(player);

// Get player position
const transform = mod.GetPlayerTransform(player);
const position = transform.position;  // mod.Vector
```

### Modifying Players

```typescript
// Set properties
mod.SetPlayerTeam(player, mod.Team.Team2);
mod.SetPlayerScore(player, 1000);
mod.SetPlayerMaxHealth(player, 150);
mod.SetPlayerVisibility(player, false);  // Make invisible

// Movement
mod.Teleport(player, position, orientation);
mod.SetMovementSpeedScale(player, 1.5);  // 50% faster
mod.SetJumpHeightScale(player, 1.3);     // 30% higher jumps

// Equipment
mod.AddEquipment(player, mod.Weapons.AK24);
mod.RemoveEquipment(player, mod.Weapons.AK24);
mod.SetPlayerAmmo(player, weapon, magazineAmmo, reserveAmmo);

// Health
mod.DealDamage(player, 50);  // Damage 50 HP
mod.Kill(player);             // Instant kill
mod.Revive(player);           // Respawn
```

### Iterating Over Players

```typescript
// Option 1: Convert to JavaScript array (recommended)
import * as modlib from './modlib';

const players = modlib.ConvertArray(mod.GetPlayers());
for (const player of players) {
  console.log(mod.GetPlayerName(player));
}

// Option 2: Manual iteration
const playersArray = mod.GetPlayers();
const count = mod.GetArrayLength(playersArray);
for (let i = 0; i < count; i++) {
  const player = mod.GetArrayElement(playersArray, i);
  console.log(mod.GetPlayerName(player));
}

// Option 3: Filtering
const alivePlayers = players.filter(p => mod.GetPlayerHealth(p) > 0);
const team1Players = players.filter(p => mod.GetPlayerTeam(p) === mod.Team.Team1);
```

## Working with Teams

### Team Enumeration

```typescript
// Available teams
mod.Team.Team1
mod.Team.Team2
mod.Team.Team3
mod.Team.Team4
mod.Team.Team5
mod.Team.Team6
mod.Team.Team7
mod.Team.Team8
mod.Team.Team9
```

### Team Configuration

```typescript
// Set team name
mod.SetTeamName(mod.Team.Team1, "Attackers");
mod.SetTeamName(mod.Team.Team2, "Defenders");

// Set team color
mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);
mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);

// Team scoring
mod.SetTeamScore(mod.Team.Team1, 500);
const score = mod.GetTeamScore(mod.Team.Team1);

// Victory
mod.SetWinningTeam(mod.Team.Team1);
```

### Team Operations

```typescript
// Get players in team
const team1Players = modlib.ConvertArray(
  mod.GetPlayersInTeam(mod.Team.Team1)
);

// Count players per team
const team1Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team1));
const team2Count = mod.GetArrayLength(mod.GetPlayersInTeam(mod.Team.Team2));

// Move player between teams
mod.SetPlayerTeam(player, mod.Team.Team2);
```

## Working with Spatial Objects

### Getting Objects from Godot

Objects placed in Godot are retrieved by their **Obj Id**:

```typescript
// In Godot: Set "Obj Id" = 1 in Inspector
// In TypeScript: Get by that ID

const spawner = mod.GetSpawner(1);
const trigger = mod.GetAreaTrigger(10);
const aiSpawner = mod.GetAISpawner(100);
const vehicleSpawner = mod.GetVehicleSpawner(50);
const capturePoint = mod.GetCapturePoint(20);
const interactPoint = mod.GetInteractPoint(30);
```

::: warning Obj IDs Must Match
The ID you use in `GetSpawner(id)` must match the "Obj Id" field you set in the Godot Inspector!
:::

### Spawners

```typescript
// Get spawner
const spawner = mod.GetSpawner(1);
if (!spawner) {
  console.log("ERROR: Spawner 1 not found!");
  return;
}

// Use spawner
mod.SpawnPlayerFromSpawnPoint(player, spawner);

// Get spawner transform
const transform = mod.GetSpawnerTransform(spawner);
const position = transform.position;
```

### Area Triggers

```typescript
// Get trigger
const trigger = mod.GetAreaTrigger(10);

// Check if player is in trigger
if (mod.IsPlayerInAreaTrigger(player, trigger)) {
  console.log("Player entered trigger zone!");
}

// Typical usage in game loop
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
```

### Generic Spatial Objects

```typescript
// Get any spatial object by ID
const spatialObj = mod.GetSpatialObject(42);

// Get transform
const transform = mod.GetObjectTransform(spatialObj);
const position = transform.position;

// Move object
const newPosition = new mod.Vector(100, 0, 50);
mod.MoveObject(spatialObj, newPosition);

// Enable/disable
mod.EnableObject(spatialObj, false);  // Hide/disable
mod.EnableObject(spatialObj, true);   // Show/enable

// Spawn/despawn runtime objects
const objType = "PropContainer_Large";
const spawnedObj = mod.SpawnObject(objType, position, rotation);
mod.DespawnObject(spawnedObj);
```

## Working with Vehicles

### Spawning Vehicles

```typescript
// Method 1: From vehicle spawner (placed in Godot)
const vehicleSpawner = mod.GetVehicleSpawner(50);
const vehicle = mod.SpawnVehicleFromSpawner(vehicleSpawner);

// Method 2: Spawn at position
const position = new mod.Vector(100, 0, 50);
const vehicle = mod.SpawnVehicle(mod.Vehicles.M1A5, position, 0);
```

### Vehicle Properties

```typescript
// Get vehicle info
const driver = mod.GetVehicleDriver(vehicle);
const passengers = mod.GetVehiclePassengers(vehicle);
const health = mod.GetVehicleHealth(vehicle);

// Modify vehicle
mod.SetVehicleHealth(vehicle, 100);
mod.SetVehicleMaxSpeed(vehicle, 1.5);  // 50% faster
mod.SetVehicleDamageMultiplier(vehicle, 0.5);  // Take 50% damage

// Destroy
mod.DestroyVehicle(vehicle);

// Repair
mod.RepairVehicle(vehicle);

// Eject players
const allPassengers = modlib.ConvertArray(mod.GetVehiclePassengers(vehicle));
for (const passenger of allPassengers) {
  mod.EjectFromVehicle(passenger);
}
```

## Working with AI

### Spawning AI

```typescript
// Method 1: From AI spawner (placed in Godot)
const aiSpawner = mod.GetAISpawner(100);
const ai = mod.SpawnAIFromAISpawner(aiSpawner);

// Method 2: Spawn at position
const position = new mod.Vector(100, 0, 50);
const ai = mod.SpawnAI(position, mod.Team.Team2);
```

### AI Behaviors

```typescript
// Set behavior
mod.SetAIBehavior(ai, mod.AIBehavior.BattlefieldAI);  // Standard combat
mod.SetAIBehavior(ai, mod.AIBehavior.DefendLocation);  // Guard position
mod.SetAIBehavior(ai, mod.AIBehavior.WaypointPatrol);  // Patrol route

// Combat control
mod.SetAIShootingEnabled(ai, true);
mod.SetAITarget(ai, player);
mod.SetAIDamageModifier(ai, 0.5);  // AI takes 50% damage

// Movement
mod.SetAIMovementSpeed(ai, 1.5);  // 50% faster
mod.SetAIStance(ai, mod.AIStance.Crouch);
```

### AI Waypoint Patrol

```typescript
// Create waypoint path
const waypoints = [
  new mod.Vector(100, 0, 50),
  new mod.Vector(200, 0, 50),
  new mod.Vector(200, 0, 150),
  new mod.Vector(100, 0, 150)
];

const patrolPath = mod.CreateWaypointPatrolPath(waypoints);

// Assign to AI
mod.SetAIBehavior(ai, mod.AIBehavior.WaypointPatrol);
mod.SetAIWaypointPath(ai, patrolPath);
```

## Working with Vectors

### Creating Vectors

```typescript
// Create new vector
const position = new mod.Vector(x, y, z);

// Example positions
const origin = new mod.Vector(0, 0, 0);
const highUp = new mod.Vector(0, 0, 100);
const forward = new mod.Vector(100, 0, 0);
```

### Vector Operations

```typescript
// Get distance between two points
const pos1 = new mod.Vector(0, 0, 0);
const pos2 = new mod.Vector(100, 0, 0);
const distance = mod.GetDistance(pos1, pos2);  // Returns 100

// Vector from player
const playerTransform = mod.GetPlayerTransform(player);
const playerPos = playerTransform.position;
```

### Common Vector Uses

```typescript
// Teleport to position
const destination = new mod.Vector(500, 200, 10);
mod.Teleport(player, destination, 0);

// Spawn vehicle at position
const spawnPos = new mod.Vector(100, 0, 50);
const vehicle = mod.SpawnVehicle(mod.Vehicles.M1A5, spawnPos, 0);

// Check distance
const checkpointPos = new mod.Vector(1000, 500, 50);
const playerPos = mod.GetPlayerTransform(player).position;
const dist = mod.GetDistance(playerPos, checkpointPos);

if (dist < 10) {
  console.log("Player reached checkpoint!");
}
```

## Working with Transforms

### Transform Structure

```typescript
// Get transform
const transform = mod.GetPlayerTransform(player);

// Transform contains:
transform.position  // mod.Vector - location
transform.rotation  // Rotation data
```

### Using Transforms

```typescript
// Get object position
const spawnerTransform = mod.GetSpawnerTransform(spawner);
const spawnerPosition = spawnerTransform.position;

// Teleport to transform position
mod.Teleport(player, spawnerPosition, 0);

// Set object transform
const newTransform = {
  position: new mod.Vector(100, 0, 50),
  rotation: { /* rotation data */ }
};
mod.SetObjectTransform(spatialObject, newTransform);
```

## Working with Arrays

### mod.Array vs JavaScript Array

The SDK uses `mod.Array` which is NOT a JavaScript array:

```typescript
// SDK returns mod.Array
const players = mod.GetPlayers();  // mod.Array<mod.Player>

// ❌ Cannot use JavaScript array methods
players.forEach(...)  // ERROR
players.map(...)      // ERROR
players.filter(...)   // ERROR

// ✅ Convert to JavaScript array first
import * as modlib from './modlib';
const playersJS = modlib.ConvertArray(players);

// Now you can use array methods
playersJS.forEach(p => console.log(mod.GetPlayerName(p)));
playersJS.filter(p => mod.GetPlayerTeam(p) === mod.Team.Team1);
```

### Array Operations

```typescript
// Get length
const count = mod.GetArrayLength(players);

// Get element
const firstPlayer = mod.GetArrayElement(players, 0);

// Iterate manually
for (let i = 0; i < mod.GetArrayLength(players); i++) {
  const player = mod.GetArrayElement(players, i);
  // Do something with player
}
```

## Object Lifecycle

### Creation

Objects are created by:
- Placement in Godot (spawners, triggers, etc.)
- Runtime spawning (vehicles, AI, VFX)
- SDK functions (UI widgets)

### Destruction

Objects are destroyed by:
- Game end
- Explicit despawn: `mod.DespawnObject()`, `mod.DestroyVehicle()`
- Player disconnect (for `mod.Player` objects)

### Persistence

::: warning Objects Don't Persist Between Games
All objects are destroyed when the experience ends. You cannot save object references between game sessions.
:::

## Object Validation

### Always Check for null/undefined

```typescript
// ❌ Dangerous - might crash
const spawner = mod.GetSpawner(999);
mod.SpawnPlayerFromSpawnPoint(player, spawner);  // Crash if spawner doesn't exist!

// ✅ Safe - validate first
const spawner = mod.GetSpawner(999);
if (!spawner) {
  console.log("ERROR: Spawner 999 not found!");
  return;
}
mod.SpawnPlayerFromSpawnPoint(player, spawner);
```

### Validate Player Objects

```typescript
// Player might have disconnected
function teleportPlayer(player: mod.Player) {
  // Check if player still exists
  const currentPlayers = modlib.ConvertArray(mod.GetPlayers());
  const playerExists = currentPlayers.includes(player);

  if (!playerExists) {
    console.log("Player no longer in game");
    return;
  }

  // Safe to teleport
  mod.Teleport(player, destination, 0);
}
```

## Best Practices

### 1. Use Helper Functions

```typescript
// Create helpers for common object operations
function getPlayersByTeam(team: mod.Team): mod.Player[] {
  const allPlayers = modlib.ConvertArray(mod.GetPlayers());
  return allPlayers.filter(p => mod.GetPlayerTeam(p) === team);
}

function findClosestPlayer(position: mod.Vector): mod.Player | null {
  const players = modlib.ConvertArray(mod.GetPlayers());
  let closest: mod.Player | null = null;
  let closestDist = Infinity;

  for (const player of players) {
    const playerPos = mod.GetPlayerTransform(player).position;
    const dist = mod.GetDistance(position, playerPos);

    if (dist < closestDist) {
      closestDist = dist;
      closest = player;
    }
  }

  return closest;
}
```

### 2. Cache Object References

```typescript
// ❌ Bad - lookup every frame
async function gameLoop() {
  while (true) {
    const spawner = mod.GetSpawner(1);  // Wasteful
    checkSpawner(spawner);
    await mod.Wait(0.1);
  }
}

// ✅ Good - cache on startup
let spawners: mod.Spawner[] = [];

export async function OnGameModeStarted() {
  // Cache all spawners once
  for (let i = 1; i <= 10; i++) {
    const spawner = mod.GetSpawner(i);
    if (spawner) {
      spawners.push(spawner);
    }
  }
}

async function gameLoop() {
  while (true) {
    for (const spawner of spawners) {
      checkSpawner(spawner);
    }
    await mod.Wait(0.1);
  }
}
```

### 3. Document Obj IDs

```typescript
// ========================================
// OBJECT ID REFERENCE
// ========================================
// Spawners (1-20):
const BLUE_HQ_SPAWNER = 1;
const RED_HQ_SPAWNER = 2;
const NEUTRAL_SPAWNER_1 = 3;

// Triggers (21-40):
const CAPTURE_POINT_A = 21;
const CAPTURE_POINT_B = 22;
const OUT_OF_BOUNDS = 23;

// AI Spawners (41-60):
const ENEMY_PATROL_1 = 41;
const ENEMY_GUARD_1 = 46;

// Usage
const spawner = mod.GetSpawner(BLUE_HQ_SPAWNER);
const trigger = mod.GetAreaTrigger(CAPTURE_POINT_A);
```

### 4. Type Safety

```typescript
// Use TypeScript types for clarity
interface PlayerData {
  player: mod.Player;
  lastSpawner: mod.Spawner;
  currentCheckpoint: number;
}

function setupPlayer(player: mod.Player, spawner: mod.Spawner) {
  const data: PlayerData = {
    player: player,
    lastSpawner: spawner,
    currentCheckpoint: 0
  };

  playerDataList.push(data);
}
```

## Next Steps

- 📖 [Teams & Players](/guides/teams-players) - Deep dive into player/team systems
- 📖 [Map Objects](/guides/map-objects) - Working with spatial objects
- 🎓 [Tutorials](/tutorials/) - Hands-on examples
- 📚 [API Reference](/api/) - Complete function docs

---

::: tip Quick Reference
- **Get objects**: Use `mod.GetSpawner()`, `mod.GetAreaTrigger()`, etc.
- **Convert arrays**: Use `modlib.ConvertArray()` for JavaScript arrays
- **Always validate**: Check if objects exist before using
- **Cache references**: Store object references on startup
- **Match Obj IDs**: Godot Inspector IDs must match TypeScript IDs
:::
