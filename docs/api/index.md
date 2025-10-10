# API Reference

The BF6 Portal SDK provides **545 functions** across 14 major categories, giving you complete control over custom game mode creation.

## API Overview

| Category | Functions | Description |
|----------|-----------|-------------|
| [Player Control](/api/player-control) | 120+ | Movement, health, teleportation, visibility |
| [UI System](/api/ui-overview) | 104 | Widgets, notifications, scoreboards |
| [AI System](/api/ai-overview) | 25+ | Bot behaviors, combat, waypoints |
| [Teams & Scoring](/api/teams-scoring) | 30+ | Team management, scoring, victory conditions |
| [Object Spawning](/api/object-spawning) | 20+ | Runtime object creation, 14,000+ objects |
| [Vehicles](/api/vehicles) | 40+ | Vehicle control, spawning, 47 types |
| [VFX & Audio](/api/vfx-audio) | 45+ | Visual effects, sounds, 100+ effects |
| [Game Mode](/api/game-mode) | 15+ | Time limits, player counts, game state |
| [Spatial Objects](/api/gameplay-objects) | 30+ | Spawners, triggers, capture points |
| [Player Equipment](/api/player-equipment) | 25+ | Weapons, gadgets, ammo |
| [Player Spawning](/api/player-spawning) | 10+ | Deploy, revive, spawn points |
| [Math & Vector](/api/math-vector) | 15+ | Distance, angles, transformations |
| [modlib Helpers](/api/modlib) | 20+ | Utility functions, UI builder |

## Type System

The API uses a **strong type system** with 22 core object types:

### Opaque Types

These represent game objects and can only be obtained through API functions:

```typescript
// Core types
mod.Player        // A player in the game
mod.Team          // A team (Team1-Team9)
mod.Vehicle       // A vehicle instance
mod.AI            // An AI bot
mod.SpatialObject // A placed object
mod.UIWidget      // A UI element

// Spawner types
mod.Spawner           // Generic spawner
mod.VehicleSpawner    // Vehicle spawn point
mod.AISpawner         // AI spawn point

// Gameplay objects
mod.AreaTrigger       // Trigger zone
mod.InteractPoint     // Interaction point
mod.CapturePoint      // Capture zone
mod.WorldIcon         // 3D icon marker

// Effects
mod.VFX              // Visual effect
mod.Audio            // Audio source

// Data types
mod.Vector           // 3D position/direction
mod.Array            // Collection of items
mod.Transform        // Position + rotation
```

### How to Get These Types

You **cannot** create these types directly. Get them through API functions:

```typescript
// Get players
const players = mod.GetPlayers();              // Returns mod.Array<mod.Player>
const player = mod.GetPlayerById(playerId);    // Returns mod.Player

// Get objects from Godot scene (by Obj Id)
const spawner = mod.GetSpawner(1);             // Returns mod.Spawner
const trigger = mod.GetAreaTrigger(10);        // Returns mod.AreaTrigger
const aiSpawner = mod.GetAISpawner(100);       // Returns mod.AISpawner

// Get teams
const team = mod.Team.Team1;                   // Use enum

// Create UI
const widget = mod.AddUIContainer(...);        // Returns mod.UIWidget

// Spawn objects
const vfx = mod.SpawnVFX(...);                 // Returns mod.VFX
const vehicle = mod.SpawnVehicle(...);         // Returns mod.Vehicle
```

## Enumerations

The SDK provides **41 enumerations** for various game elements:

### Maps (9 total)

```typescript
mod.Maps.MP_Abbasid      // Siege of Cairo
mod.Maps.MP_Dumbo        // Manhattan Bridge
mod.Maps.MP_Tungsten     // Mirak Valley
mod.Maps.MP_Outskirts    // New Sobek City
mod.Maps.MP_Aftermath    // Empire State
mod.Maps.MP_Battery      // Iberian Offensive
mod.Maps.MP_Capstone     // Liberation Peak
mod.Maps.MP_Firestorm    // Operation Firestorm
mod.Maps.MP_Limestone    // Saint's Quarter
```

### Teams (9 total)

```typescript
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

### Weapons (163 types)

See [Enumerations page](/api/enums) for complete list.

### Gadgets (47 types)

See [Enumerations page](/api/enums) for complete list.

### Vehicles (47 types)

```typescript
mod.Vehicles.M1A5         // Tank
mod.Vehicles.AH64         // Apache helicopter
mod.Vehicles.F35          // Fighter jet
// ... 44 more vehicles
```

### AI Behaviors (7 types)

```typescript
mod.AIBehavior.BattlefieldAI    // Standard combat AI
mod.AIBehavior.MoveToLocation   // Move to position
mod.AIBehavior.DefendLocation   // Guard position
mod.AIBehavior.DefendPlayer     // Protect player
mod.AIBehavior.Idle             // Stand still
mod.AIBehavior.WaypointPatrol   // Patrol waypoints
mod.AIBehavior.Parachute        // Parachute down
```

### UI Anchors (9 positions)

```typescript
mod.UIAnchor.TopLeft
mod.UIAnchor.TopCenter
mod.UIAnchor.TopRight
mod.UIAnchor.CenterLeft
mod.UIAnchor.Center
mod.UIAnchor.CenterRight
mod.UIAnchor.BottomLeft
mod.UIAnchor.BottomCenter
mod.UIAnchor.BottomRight
```

### Team Colors (14 options)

```typescript
mod.TeamColor.Red
mod.TeamColor.Blue
mod.TeamColor.Green
mod.TeamColor.Yellow
mod.TeamColor.Orange
mod.TeamColor.Purple
mod.TeamColor.Pink
mod.TeamColor.Cyan
mod.TeamColor.White
mod.TeamColor.Black
mod.TeamColor.Brown
mod.TeamColor.Gray
mod.TeamColor.LightBlue
mod.TeamColor.DarkGreen
```

### Restricted Inputs (18 types)

```typescript
mod.RestrictedInputs.Sprint
mod.RestrictedInputs.Crouch
mod.RestrictedInputs.Jump
mod.RestrictedInputs.Prone
mod.RestrictedInputs.FireWeapon
mod.RestrictedInputs.ADS
mod.RestrictedInputs.Reload
mod.RestrictedInputs.SwitchWeapon
mod.RestrictedInputs.UseGadget
mod.RestrictedInputs.EnterVehicle
mod.RestrictedInputs.Melee
// ... and more
```

## Event Hooks

All custom game modes must export these event handler functions:

```typescript
// Required: Called once when game starts
export async function OnGameModeStarted(): Promise<void>

// Called when player joins lobby
export async function OnPlayerJoinGame(player: mod.Player): Promise<void>

// Called when player leaves
export async function OnPlayerLeaveGame(playerId: string): Promise<void>

// Called when player spawns into map
export async function OnPlayerDeployed(player: mod.Player): Promise<void>

// Called when player dies
export async function OnPlayerDied(player: mod.Player): Promise<void>

// Called when player gets a kill
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
): Promise<void>

// Called when player switches teams
export async function OnPlayerSwitchTeam(
  player: mod.Player,
  newTeam: mod.Team
): Promise<void>
```

::: tip All Hooks Are Optional
Only `OnGameModeStarted()` is truly required. Implement the others as needed for your game mode.
:::

## Common Patterns

### Getting All Players as Array

```typescript
import * as modlib from './modlib';

// Convert mod.Array to JavaScript array
const players = modlib.ConvertArray(mod.GetPlayers());

// Now you can use normal array methods
players.forEach(player => {
  console.log("Player found!");
});

players.filter(p => mod.GetPlayerTeam(p) === mod.Team.Team1);
```

### Referencing Objects from Godot

```typescript
// In Godot: Set "Obj Id" to 1 in Inspector
// In TypeScript: Get that object by ID

const spawner = mod.GetSpawner(1);           // Get spawner with ID 1
const trigger = mod.GetAreaTrigger(10);      // Get trigger with ID 10
const aiSpawner = mod.GetAISpawner(100);     // Get AI spawner with ID 100
```

### Waiting for Time

```typescript
// Wait 5 seconds
await mod.Wait(5);

// Wait 0.5 seconds
await mod.Wait(0.5);
```

### Iterating Over mod.Array

```typescript
// Option 1: Convert to JS array (recommended)
const players = modlib.ConvertArray(mod.GetPlayers());
for (const player of players) {
  // Do something with player
}

// Option 2: Use GetArrayLength and GetArrayElement
const players = mod.GetPlayers();
const count = mod.GetArrayLength(players);
for (let i = 0; i < count; i++) {
  const player = mod.GetArrayElement(players, i);
  // Do something with player
}
```

## Dependencies

### Required Imports

Every game mode TypeScript file needs:

```typescript
import * as mod from 'bf-portal-api';
```

### Recommended Imports

For easier development:

```typescript
import * as modlib from './modlib';  // Helper utilities
```

### Type Definitions

The full TypeScript definitions are in:
```
PortalSDK/code/mod/index.d.ts
```

Use this file in your IDE for autocomplete and type checking.

## Next Steps

- 📖 Explore specific API categories in the sidebar
- 🎓 Follow [Tutorials](/tutorials/) for hands-on learning
- 📚 Study [Examples](/examples/) for real-world patterns
- 🔍 Search for specific functions using the search bar

---

::: tip API Documentation Format
Each API page includes:
- Function signatures with types
- Parameter descriptions
- Return value details
- Usage examples
- Common pitfalls
- Related functions
:::
