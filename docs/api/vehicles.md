# Vehicle API

Complete vehicle system for spawning, controlling, and modifying vehicles. The Vehicle API includes **40+ functions** and **47 vehicle types**.

## Vehicle Spawning

### ForceVehicleSpawnerSpawn

Force a vehicle spawner to spawn its vehicle immediately.

```typescript
function ForceVehicleSpawnerSpawn(
  vehicleSpawner: mod.VehicleSpawner
): void
```

**Example:**

```typescript
// Spawn vehicle at game start
export async function OnGameModeStarted() {
  const tankSpawner = mod.GetVehicleSpawner(100);
  mod.ForceVehicleSpawnerSpawn(tankSpawner);
}

// Spawn vehicle on player command
export async function OnPlayerInteract(
  player: mod.Player,
  interactPoint: mod.InteractPoint
) {
  const interactId = mod.GetObjId(interactPoint);

  if (interactId === 500) {  // Vehicle spawn button
    const heliSpawner = mod.GetVehicleSpawner(200);
    mod.ForceVehicleSpawnerSpawn(heliSpawner);

    modlib.DisplayCustomNotificationMessage(
      mod.Message("Helicopter spawned!"),
      mod.CustomNotificationSlots.MessageText1,
      3,
      player
    );
  }
}
```

---

### GetVehicleSpawner

Get reference to a vehicle spawner by ID.

```typescript
function GetVehicleSpawner(spawnerId: number): mod.VehicleSpawner
```

**Parameters:**
- `spawnerId` - The Obj Id set in Godot editor

**Example:**

```typescript
// Get spawner reference
const tankSpawner = mod.GetVehicleSpawner(100);
const heliSpawner = mod.GetVehicleSpawner(200);
const jeepSpawner = mod.GetVehicleSpawner(300);

// Configure multiple spawners
const spawnerIds = [100, 101, 102, 103];
for (const id of spawnerIds) {
  const spawner = mod.GetVehicleSpawner(id);
  mod.SetVehicleSpawnerAutoSpawn(spawner, true);
  mod.SetVehicleSpawnerRespawnTime(spawner, 60);
}
```

::: tip Setting Obj IDs in Godot
1. Select VehicleSpawner object in scene tree
2. In Inspector panel, find "Obj Id" property
3. Set unique number (e.g., 100, 200, 300)
4. Use that number in `GetVehicleSpawner(id)`
:::

---

## Vehicle Spawner Configuration

### SetVehicleSpawnerType

Set which vehicle type spawns from this spawner.

```typescript
function SetVehicleSpawnerType(
  vehicleSpawner: mod.VehicleSpawner,
  vehicleType: mod.VehicleList
): void
```

**Example:**

```typescript
// Configure different vehicle types
const tankSpawner = mod.GetVehicleSpawner(100);
mod.SetVehicleSpawnerType(tankSpawner, mod.VehicleList.M1A5);

const heliSpawner = mod.GetVehicleSpawner(200);
mod.SetVehicleSpawnerType(heliSpawner, mod.VehicleList.AH64_Apache);

const jetSpawner = mod.GetVehicleSpawner(300);
mod.SetVehicleSpawnerType(jetSpawner, mod.VehicleList.F35);
```

See [Available Vehicles](#available-vehicles) for complete list of 47 vehicle types.

---

### SetVehicleSpawnerAutoSpawn

Enable or disable automatic vehicle respawning.

```typescript
function SetVehicleSpawnerAutoSpawn(
  vehicleSpawner: mod.VehicleSpawner,
  enabled: boolean
): void
```

**Parameters:**
- `enabled` - `true` = auto-respawn, `false` = manual spawn only

**Example:**

```typescript
// Auto-respawn enabled (default behavior)
mod.SetVehicleSpawnerAutoSpawn(spawner, true);

// Manual spawn only
mod.SetVehicleSpawnerAutoSpawn(spawner, false);

// Player-controlled vehicle spawning
export async function OnPlayerInteract(
  player: mod.Player,
  interactPoint: mod.InteractPoint
) {
  const spawner = mod.GetVehicleSpawner(100);

  // Disable auto-spawn
  mod.SetVehicleSpawnerAutoSpawn(spawner, false);

  // Player manually spawns vehicle
  mod.ForceVehicleSpawnerSpawn(spawner);
}
```

---

### SetVehicleSpawnerRespawnTime

Set time before vehicle respawns after destruction.

```typescript
function SetVehicleSpawnerRespawnTime(
  vehicleSpawner: mod.VehicleSpawner,
  respawnTime: number
): void
```

**Parameters:**
- `respawnTime` - Seconds until respawn (default: varies by vehicle)

**Example:**

```typescript
// Quick respawn (30 seconds)
mod.SetVehicleSpawnerRespawnTime(spawner, 30);

// Long respawn (5 minutes)
mod.SetVehicleSpawnerRespawnTime(spawner, 300);

// Instant respawn
mod.SetVehicleSpawnerRespawnTime(spawner, 0);

// Configure by vehicle type
function configureSpawner(spawnerId: number, vehicleType: mod.VehicleList) {
  const spawner = mod.GetVehicleSpawner(spawnerId);
  mod.SetVehicleSpawnerType(spawner, vehicleType);

  // Faster respawn for light vehicles
  if (vehicleType === mod.VehicleList.LATV4_Recon ||
      vehicleType === mod.VehicleList.Polaris_RZR) {
    mod.SetVehicleSpawnerRespawnTime(spawner, 30);
  } else {
    mod.SetVehicleSpawnerRespawnTime(spawner, 90);
  }
}
```

---

### SetVehicleSpawnerTimeUntilAbandon

Set how long before an empty vehicle is considered abandoned.

```typescript
function SetVehicleSpawnerTimeUntilAbandon(
  vehicleSpawner: mod.VehicleSpawner,
  timeUntilAbandon: number
): void
```

**Parameters:**
- `timeUntilAbandon` - Seconds of inactivity before abandon (default: 60)

**Example:**

```typescript
// Quick abandon (15 seconds)
mod.SetVehicleSpawnerTimeUntilAbandon(spawner, 15);

// Never abandon
mod.SetVehicleSpawnerTimeUntilAbandon(spawner, 999999);

// Standard abandon time
mod.SetVehicleSpawnerTimeUntilAbandon(spawner, 60);
```

---

### SetVehicleSpawnerAbandonVehicleOutOfCombatArea

Automatically abandon vehicles that leave combat area.

```typescript
function SetVehicleSpawnerAbandonVehicleOutOfCombatArea(
  vehicleSpawner: mod.VehicleSpawner,
  enabled: boolean
): void
```

**Example:**

```typescript
// Auto-abandon out of bounds vehicles
mod.SetVehicleSpawnerAbandonVehicleOutOfCombatArea(spawner, true);

// Allow vehicles outside combat area
mod.SetVehicleSpawnerAbandonVehicleOutOfCombatArea(spawner, false);
```

---

### SetVehicleSpawnerApplyDamageToAbandonVehicle

Damage abandoned vehicles over time.

```typescript
function SetVehicleSpawnerApplyDamageToAbandonVehicle(
  vehicleSpawner: mod.VehicleSpawner,
  enabled: boolean
): void
```

**Example:**

```typescript
// Damage abandoned vehicles (default)
mod.SetVehicleSpawnerApplyDamageToAbandonVehicle(spawner, true);

// Abandoned vehicles stay at current health
mod.SetVehicleSpawnerApplyDamageToAbandonVehicle(spawner, false);
```

---

### SetVehicleSpawnerKeepAliveAbandonRadius

Set how far from spawner before vehicle is abandoned.

```typescript
function SetVehicleSpawnerKeepAliveAbandonRadius(
  vehicleSpawner: mod.VehicleSpawner,
  keepAliveAbandonedRadius: number
): void
```

**Parameters:**
- `keepAliveAbandonedRadius` - Radius in meters (default: 200)

**Example:**

```typescript
// Small radius (100 meters)
mod.SetVehicleSpawnerKeepAliveAbandonRadius(spawner, 100);

// Large radius (500 meters)
mod.SetVehicleSpawnerKeepAliveAbandonRadius(spawner, 500);

// Entire map
mod.SetVehicleSpawnerKeepAliveAbandonRadius(spawner, 9999);
```

---

### SetVehicleSpawnerSpawnerRadius

Set spawn protection radius around spawner.

```typescript
function SetVehicleSpawnerSpawnerRadius(
  vehicleSpawner: mod.VehicleSpawner,
  keepAliveSpawnerRadius: number
): void
```

**Parameters:**
- `keepAliveSpawnerRadius` - Radius in meters (default: 50)

**Example:**

```typescript
// Small spawn zone
mod.SetVehicleSpawnerSpawnerRadius(spawner, 25);

// Large spawn zone
mod.SetVehicleSpawnerSpawnerRadius(spawner, 100);
```

---

## Vehicle Control

### ForcePlayerEnterVehicle

Force a player into a vehicle.

```typescript
function ForcePlayerEnterVehicle(
  player: mod.Player,
  vehicle: mod.Vehicle
): void

function ForcePlayerEnterVehicle(
  player: mod.Player,
  vehicle: mod.Vehicle,
  seatIndex: number
): void
```

**Parameters:**
- `player` - Player to enter vehicle
- `vehicle` - Target vehicle
- `seatIndex` - (Optional) Specific seat (0 = driver, 1+ = passengers)

**Example:**

```typescript
// Put player in driver seat
mod.ForcePlayerEnterVehicle(player, vehicle);

// Put player in passenger seat
mod.ForcePlayerEnterVehicle(player, vehicle, 1);

// Put player in gunner seat
mod.ForcePlayerEnterVehicle(player, vehicle, 2);

// Auto-assign to vehicles on spawn
export async function OnPlayerDeployed(player: mod.Player) {
  const tankSpawner = mod.GetVehicleSpawner(100);
  mod.ForceVehicleSpawnerSpawn(tankSpawner);

  await mod.Wait(0.5);  // Wait for vehicle to spawn

  // Get spawned vehicle reference (would need tracking)
  // mod.ForcePlayerEnterVehicle(player, vehicle);
}
```

---

### ForcePlayerExitVehicle

Eject a player from their vehicle.

```typescript
function ForcePlayerExitVehicle(player: mod.Player): void

function ForcePlayerExitVehicle(
  player: mod.Player,
  exitPosition: mod.Vector
): void
```

**Parameters:**
- `player` - Player to eject
- `exitPosition` - (Optional) Where to place player after ejecting

**Example:**

```typescript
// Simple ejection (player exits near vehicle)
mod.ForcePlayerExitVehicle(player);

// Eject to specific position
const safePos = mod.CreateVector(100, 0, 100);
mod.ForcePlayerExitVehicle(player, safePos);

// Eject all players from stolen vehicle
export async function OnPlayerEnterVehicle(
  player: mod.Player,
  vehicle: mod.Vehicle
) {
  const vehicleTeam = getVehicleTeam(vehicle);
  const playerTeam = mod.GetTeam(player);

  if (vehicleTeam !== playerTeam) {
    mod.ForcePlayerExitVehicle(player);

    modlib.DisplayCustomNotificationMessage(
      mod.Message("Cannot enter enemy vehicle!"),
      mod.CustomNotificationSlots.MessageText1,
      3,
      player
    );
  }
}
```

---

### GetVehicleOccupantCount

Get number of players in a vehicle.

```typescript
function GetVehicleOccupantCount(vehicle: mod.Vehicle): number
```

**Returns:** Number of players currently in vehicle

**Example:**

```typescript
const occupants = mod.GetVehicleOccupantCount(vehicle);

if (occupants === 0) {
  console.log("Vehicle is empty");
} else {
  console.log(`Vehicle has ${occupants} occupants`);
}

// Check if vehicle is full
function isVehicleFull(vehicle: mod.Vehicle, maxSeats: number): boolean {
  return mod.GetVehicleOccupantCount(vehicle) >= maxSeats;
}
```

---

### IsVehicleOccupied

Check if vehicle has any occupants.

```typescript
function IsVehicleOccupied(vehicle: mod.Vehicle): boolean
```

**Returns:** `true` if vehicle has at least one occupant

**Example:**

```typescript
if (mod.IsVehicleOccupied(vehicle)) {
  console.log("Vehicle is occupied");
} else {
  console.log("Vehicle is empty");
}

// Destroy empty vehicles
export async function cleanupEmptyVehicles() {
  const vehicles = getAllVehicles();  // Custom tracking

  for (const vehicle of vehicles) {
    if (!mod.IsVehicleOccupied(vehicle)) {
      mod.DealDamage(vehicle, 999999);  // Destroy
    }
  }
}
```

---

## Vehicle Modification

### SetVehicleMaxHealth

Set maximum health for a vehicle.

```typescript
function SetVehicleMaxHealth(
  vehicle: mod.Vehicle,
  maxHealth: number
): void
```

**Parameters:**
- `maxHealth` - New max health (default varies by vehicle type)

**Example:**

```typescript
// Tank mode - 5000 HP
mod.SetVehicleMaxHealth(vehicle, 5000);

// Weak vehicle - 500 HP
mod.SetVehicleMaxHealth(vehicle, 500);

// Invincible vehicle
mod.SetVehicleMaxHealth(vehicle, 999999);

// Configure by vehicle type
export async function OnVehicleSpawned(vehicle: mod.Vehicle) {
  const vehicleType = getVehicleType(vehicle);  // Custom tracking

  if (vehicleType === mod.VehicleList.M1A5) {
    mod.SetVehicleMaxHealth(vehicle, 3000);  // Stronger tank
  } else if (vehicleType === mod.VehicleList.LATV4_Recon) {
    mod.SetVehicleMaxHealth(vehicle, 800);  // Normal jeep
  }
}
```

---

### SetVehicleMovementSpeedMultiplier

Modify vehicle movement speed.

```typescript
function SetVehicleMovementSpeedMultiplier(
  vehicle: mod.Vehicle,
  multiplier: number
): void
```

**Parameters:**
- `multiplier` - Speed multiplier (1.0 = normal, 2.0 = 2x speed)

**Example:**

```typescript
// Turbo mode
mod.SetVehicleMovementSpeedMultiplier(vehicle, 2.0);

// Slow mode
mod.SetVehicleMovementSpeedMultiplier(vehicle, 0.5);

// Reset to normal
mod.SetVehicleMovementSpeedMultiplier(vehicle, 1.0);

// Speed boost power-up
export async function giveVehicleSpeedBoost(vehicle: mod.Vehicle, duration: number) {
  mod.SetVehicleMovementSpeedMultiplier(vehicle, 1.5);

  await mod.Wait(duration);

  mod.SetVehicleMovementSpeedMultiplier(vehicle, 1.0);
}
```

---

### DealDamage (Vehicle)

Damage a vehicle.

```typescript
function DealDamage(
  vehicle: mod.Vehicle,
  damageAmount: number
): void
```

**Example:**

```typescript
// Deal 100 damage
mod.DealDamage(vehicle, 100);

// Destroy vehicle
mod.DealDamage(vehicle, 999999);

// Environmental damage over time
export async function applyFireDamage(vehicle: mod.Vehicle) {
  for (let i = 0; i < 10; i++) {
    mod.DealDamage(vehicle, 50);
    await mod.Wait(1);
  }
}
```

---

### Heal (Vehicle)

Repair a vehicle.

```typescript
function Heal(
  vehicle: mod.Vehicle,
  repairAmount: number
): void
```

**Example:**

```typescript
// Repair 200 HP
mod.Heal(vehicle, 200);

// Full repair
mod.Heal(vehicle, 999999);

// Repair zone
export async function OnPlayerEnterAreaTrigger(
  player: mod.Player,
  areaTrigger: mod.AreaTrigger
) {
  const triggerId = mod.GetObjId(areaTrigger);

  if (triggerId === 500) {  // Repair zone
    const vehicle = getPlayerVehicle(player);  // Custom function

    if (vehicle) {
      mod.Heal(vehicle, 999999);  // Full repair

      modlib.DisplayCustomNotificationMessage(
        mod.Message("Vehicle repaired!"),
        mod.CustomNotificationSlots.MessageText1,
        3,
        player
      );
    }
  }
}
```

---

### Kill (Vehicle)

Instantly destroy a vehicle.

```typescript
function Kill(vehicle: mod.Vehicle): void
```

**Example:**

```typescript
// Destroy vehicle
mod.Kill(vehicle);

// Destroy all vehicles on match end
export async function OnGameModeEnding() {
  const vehicles = getAllVehicles();  // Custom tracking

  for (const vehicle of vehicles) {
    mod.Kill(vehicle);
  }
}
```

---

## Available Vehicles

All **47 vehicle types** available through `mod.VehicleList`:

### Ground Vehicles - Light

```typescript
mod.VehicleList.LATV4_Recon        // Light recon vehicle
mod.VehicleList.Polaris_RZR        // Fast ATV
mod.VehicleList.Quad_Bike          // Motorcycle/quad
mod.VehicleList.Transport_Vehicle  // Generic transport
```

### Ground Vehicles - Armored

```typescript
mod.VehicleList.LAV25              // Infantry fighting vehicle
mod.VehicleList.M5C_Bolte          // Modern IFV
mod.VehicleList.EBLC_RAM           // Armored car
mod.VehicleList.T28                // Light tank
```

### Main Battle Tanks

```typescript
mod.VehicleList.M1A5               // US main battle tank
mod.VehicleList.T90                // Russian main battle tank
mod.VehicleList.Abrams             // M1 Abrams variant
```

### Anti-Air Vehicles

```typescript
mod.VehicleList.EBAA_Wildcat       // Anti-air vehicle
mod.VehicleList.KA520_Super_Hokum  // Anti-air helicopter
```

### Attack Helicopters

```typescript
mod.VehicleList.AH64_Apache        // Attack helicopter
mod.VehicleList.KA520_Super_Hokum  // Russian attack heli
mod.VehicleList.MD540_Nightbird    // Light attack heli
```

### Transport Helicopters

```typescript
mod.VehicleList.MV38_Condor        // Heavy transport
mod.VehicleList.Mi240_Super_Hind   // Russian transport
```

### Jets - Fighter

```typescript
mod.VehicleList.F35                // Modern fighter jet
mod.VehicleList.SU57_Felon         // Russian stealth fighter
mod.VehicleList.J20                // Chinese fighter
```

### Jets - Attack

```typescript
mod.VehicleList.A10_Warthog        // Ground attack jet
mod.VehicleList.SU25_Frogfoot      // Russian ground attack
```

### Naval Vehicles

```typescript
mod.VehicleList.RHIB               // Rigid hull boat
mod.VehicleList.Attack_Boat        // Armed boat
mod.VehicleList.Transport_Hovercraft  // Amphibious transport
```

### Special Vehicles

```typescript
mod.VehicleList.MAV                // Micro air vehicle (drone)
mod.VehicleList.LCAA_Hovercraft    // Amphibious hovercraft
mod.VehicleList.Ranger             // Utility vehicle
```

**Example Usage:**

```typescript
// Configure different vehicle types
export async function OnGameModeStarted() {
  // Light vehicles - quick respawn
  const lightVehicles = [
    { id: 100, type: mod.VehicleList.LATV4_Recon },
    { id: 101, type: mod.VehicleList.Polaris_RZR },
    { id: 102, type: mod.VehicleList.Quad_Bike }
  ];

  for (const v of lightVehicles) {
    const spawner = mod.GetVehicleSpawner(v.id);
    mod.SetVehicleSpawnerType(spawner, v.type);
    mod.SetVehicleSpawnerRespawnTime(spawner, 30);
    mod.SetVehicleSpawnerAutoSpawn(spawner, true);
  }

  // Heavy vehicles - slow respawn
  const heavyVehicles = [
    { id: 200, type: mod.VehicleList.M1A5 },
    { id: 201, type: mod.VehicleList.T90 },
    { id: 202, type: mod.VehicleList.LAV25 }
  ];

  for (const v of heavyVehicles) {
    const spawner = mod.GetVehicleSpawner(v.id);
    mod.SetVehicleSpawnerType(spawner, v.type);
    mod.SetVehicleSpawnerRespawnTime(spawner, 120);
    mod.SetVehicleSpawnerAutoSpawn(spawner, true);
  }

  // Air vehicles - long respawn
  const airVehicles = [
    { id: 300, type: mod.VehicleList.AH64_Apache },
    { id: 301, type: mod.VehicleList.F35 },
    { id: 302, type: mod.VehicleList.A10_Warthog }
  ];

  for (const v of airVehicles) {
    const spawner = mod.GetVehicleSpawner(v.id);
    mod.SetVehicleSpawnerType(spawner, v.type);
    mod.SetVehicleSpawnerRespawnTime(spawner, 180);
    mod.SetVehicleSpawnerAutoSpawn(spawner, true);
  }
}
```

---

## Stationary Emplacements

The API also supports stationary emplacements (turrets, mounted weapons) with similar functions:

```typescript
// Force spawn emplacement
ForceEmplacementSpawnerSpawn(emplacementSpawner: mod.EmplacementSpawner): void

// Configure emplacement spawner
SetEmplacementSpawnerType(
  emplacementSpawner: mod.EmplacementSpawner,
  emplacementType: mod.StationaryEmplacements
): void

SetEmplacementSpawnerAutoSpawn(spawner: mod.EmplacementSpawner, enabled: boolean): void
SetEmplacementSpawnerRespawnTime(spawner: mod.EmplacementSpawner, time: number): void
SetEmplacementSpawnerTimeUntilAbandon(spawner: mod.EmplacementSpawner, time: number): void
SetEmplacementSpawnerAbandonVehicleOutOfCombatArea(spawner: mod.EmplacementSpawner, enabled: boolean): void
SetEmplacementSpawnerApplyDamageToAbandonVehicle(spawner: mod.EmplacementSpawner, enabled: boolean): void
SetEmplacementSpawnerKeepAliveAbandonRadius(spawner: mod.EmplacementSpawner, radius: number): void
SetEmplacementSpawnerSpawnerRadius(spawner: mod.EmplacementSpawner, radius: number): void
```

**Example:**

```typescript
const turret = mod.GetEmplacementSpawner(400);
mod.SetEmplacementSpawnerType(turret, mod.StationaryEmplacements.MG_Turret);
mod.SetEmplacementSpawnerAutoSpawn(turret, true);
mod.SetEmplacementSpawnerRespawnTime(turret, 60);
```

---

## Complete Example: Vehicle Spawning System

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';

interface VehicleConfig {
  spawnerId: number;
  vehicleType: mod.VehicleList;
  respawnTime: number;
  maxHealth?: number;
  speedMultiplier?: number;
}

const vehicleConfigs: VehicleConfig[] = [
  // Light vehicles
  { spawnerId: 100, vehicleType: mod.VehicleList.LATV4_Recon, respawnTime: 30 },
  { spawnerId: 101, vehicleType: mod.VehicleList.Polaris_RZR, respawnTime: 25 },

  // Tanks
  { spawnerId: 200, vehicleType: mod.VehicleList.M1A5, respawnTime: 120, maxHealth: 4000 },
  { spawnerId: 201, vehicleType: mod.VehicleList.T90, respawnTime: 120, maxHealth: 4000 },

  // Helicopters
  { spawnerId: 300, vehicleType: mod.VehicleList.AH64_Apache, respawnTime: 180 },
  { spawnerId: 301, vehicleType: mod.VehicleList.MD540_Nightbird, respawnTime: 90 },

  // Jets
  { spawnerId: 400, vehicleType: mod.VehicleList.F35, respawnTime: 240 },
  { spawnerId: 401, vehicleType: mod.VehicleList.A10_Warthog, respawnTime: 240 }
];

export async function OnGameModeStarted() {
  // Configure all vehicle spawners
  for (const config of vehicleConfigs) {
    const spawner = mod.GetVehicleSpawner(config.spawnerId);

    // Set vehicle type
    mod.SetVehicleSpawnerType(spawner, config.vehicleType);

    // Configure spawner settings
    mod.SetVehicleSpawnerAutoSpawn(spawner, true);
    mod.SetVehicleSpawnerRespawnTime(spawner, config.respawnTime);
    mod.SetVehicleSpawnerTimeUntilAbandon(spawner, 60);
    mod.SetVehicleSpawnerAbandonVehicleOutOfCombatArea(spawner, true);
    mod.SetVehicleSpawnerApplyDamageToAbandonVehicle(spawner, true);
    mod.SetVehicleSpawnerKeepAliveAbandonRadius(spawner, 300);

    // Initial spawn
    mod.ForceVehicleSpawnerSpawn(spawner);
  }

  console.log(`Configured ${vehicleConfigs.length} vehicle spawners`);
}

// Vehicle health modifier on spawn (requires vehicle tracking)
export async function OnVehicleSpawned(vehicle: mod.Vehicle, config: VehicleConfig) {
  if (config.maxHealth) {
    mod.SetVehicleMaxHealth(vehicle, config.maxHealth);
  }

  if (config.speedMultiplier) {
    mod.SetVehicleMovementSpeedMultiplier(vehicle, config.speedMultiplier);
  }
}

// Repair zone implementation
export async function OnPlayerEnterAreaTrigger(
  player: mod.Player,
  areaTrigger: mod.AreaTrigger
) {
  const triggerId = mod.GetObjId(areaTrigger);

  if (triggerId === 500) {  // Repair zone
    // Note: Would need vehicle tracking to get player's vehicle
    // This is a simplified example

    modlib.DisplayCustomNotificationMessage(
      mod.Message("Entering repair zone..."),
      mod.CustomNotificationSlots.MessageText1,
      2,
      player
    );
  }
}
```

---

## Related APIs

- [Player Spawning](/api/player-spawning) - Deploy players into vehicles
- [Gameplay Objects](/api/gameplay-objects) - Place VehicleSpawner objects
- [Object Transform](/api/object-transform) - Move vehicles at runtime

## See Also

- [AcePursuit Example](/examples/acepursuit) - Racing mode with vehicle spawning
- [Godot Editor Guide](/guides/godot-editor) - Placing VehicleSpawner objects
