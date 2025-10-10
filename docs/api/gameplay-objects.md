# Gameplay Objects

Functions for interacting with gameplay objects like spawners, triggers, capture points, and interactive elements.

## Overview

Gameplay objects are pre-placed interactive elements that control game mechanics:
- **Spawners** - Player and AI spawn points
- **Vehicle Spawners** - Vehicle spawn locations
- **Capture Points** - Territory objectives
- **Area Triggers** - Event zones
- **Interact Points** - Interactive zones
- **World Icons** - 3D markers
- **HQ** - Team headquarters
- **MCOM** - Rush objectives
- **Sectors** - Map zones

## Spawner Objects

### Player Spawners

#### GetSpawnPoint

```typescript
GetSpawnPoint(spawnPointId: number): SpawnPoint
```

Get reference to a spawn point by its Obj Id (set in Godot).

**Example:**
```typescript
// Define spawn points
const TEAM1_SPAWN = 100;
const TEAM2_SPAWN = 101;

export async function OnPlayerJoinGame(player: mod.Player) {
  const team = mod.GetTeam(player);

  if (team === mod.Team.Team1) {
    const spawnPoint = mod.GetSpawnPoint(TEAM1_SPAWN);
    mod.SpawnPlayerFromSpawnPoint(player, spawnPoint);
  } else {
    const spawnPoint = mod.GetSpawnPoint(TEAM2_SPAWN);
    mod.SpawnPlayerFromSpawnPoint(player, spawnPoint);
  }
}

// Multiple spawn points per team
const TEAM1_SPAWNS = [100, 101, 102, 103];

function getRandomSpawnPoint(spawnIds: number[]): mod.SpawnPoint {
  const randomId = spawnIds[Math.floor(Math.random() * spawnIds.length)];
  return mod.GetSpawnPoint(randomId);
}
```

### AI Spawners

#### GetSpawner

```typescript
GetSpawner(spawnerId: number): Spawner
```

Get reference to an AI spawner.

**Example:**
```typescript
// AI spawn points
const GUARD_SPAWNS = [200, 201, 202, 203];
const PATROL_SPAWNS = [210, 211, 212];

export async function OnGameModeStarted() {
  // Spawn guards
  for (const spawnId of GUARD_SPAWNS) {
    const spawner = mod.GetSpawner(spawnId);
    mod.SpawnAIFromAISpawner(
      spawner,
      mod.SoldierClass.Assault,
      mod.Message("Guard"),
      mod.Team.Team2
    );
  }

  // Spawn patrols
  for (const spawnId of PATROL_SPAWNS) {
    const spawner = mod.GetSpawner(spawnId);
    mod.SpawnAIFromAISpawner(
      spawner,
      mod.SoldierClass.Recon,
      mod.Message("Patrol"),
      mod.Team.Team2
    );
  }
}
```

#### AI Spawner Configuration

```typescript
AISetUnspawnOnDead(spawner: Spawner, enableUnspawnOnDead: boolean): void
SetUnspawnDelayInSeconds(spawner: Spawner, delay: number): void
```

Configure AI spawner behavior.

**Example:**
```typescript
// Configure respawning AI
const ENEMY_SPAWNER = 200;

export async function OnGameModeStarted() {
  const spawner = mod.GetSpawner(ENEMY_SPAWNER);

  // Auto-remove dead AI after 5 seconds
  mod.AISetUnspawnOnDead(spawner, true);
  mod.SetUnspawnDelayInSeconds(spawner, 5);

  // Spawn first wave
  mod.SpawnAIFromAISpawner(spawner, mod.SoldierClass.Assault);
}

// Respawn wave when all dead
let activeAI = 0;

export async function OnPlayerDied(player: mod.Player) {
  const isAI = mod.GetSoldierState(player, mod.SoldierStateBool.IsAI);

  if (isAI) {
    activeAI--;

    if (activeAI <= 0) {
      // Spawn new wave after delay
      await mod.Wait(10);
      spawnAIWave();
    }
  }
}

function spawnAIWave() {
  const spawner = mod.GetSpawner(ENEMY_SPAWNER);

  for (let i = 0; i < 5; i++) {
    mod.SpawnAIFromAISpawner(spawner, mod.SoldierClass.Assault);
    activeAI++;
  }
}
```

### Vehicle Spawners

#### GetVehicleSpawner

```typescript
GetVehicleSpawner(spawnerId: number): VehicleSpawner
```

Get reference to a vehicle spawner.

**Example:**
```typescript
// Vehicle spawner IDs
const TANK_SPAWN = 300;
const HELI_SPAWN = 301;
const TRANSPORT_SPAWN = 302;

export async function OnGameModeStarted() {
  const tankSpawner = mod.GetVehicleSpawner(TANK_SPAWN);
  const heliSpawner = mod.GetVehicleSpawner(HELI_SPAWN);

  // Configure spawners
  mod.SetVehicleSpawnerType(tankSpawner, mod.VehicleList.M1A5);
  mod.SetVehicleSpawnerAutoSpawn(tankSpawner, true);
  mod.SetVehicleSpawnerRespawnTime(tankSpawner, 60);  // 60 second respawn

  mod.SetVehicleSpawnerType(heliSpawner, mod.VehicleList.AH64_Apache);
  mod.SetVehicleSpawnerAutoSpawn(heliSpawner, true);
  mod.SetVehicleSpawnerRespawnTime(heliSpawner, 90);

  // Force initial spawn
  mod.ForceVehicleSpawnerSpawn(tankSpawner);
  mod.ForceVehicleSpawnerSpawn(heliSpawner);
}
```

#### Vehicle Spawner Configuration

```typescript
SetVehicleSpawnerType(spawner: VehicleSpawner, vehicleType: VehicleList): void
SetVehicleSpawnerAutoSpawn(spawner: VehicleSpawner, enabled: boolean): void
SetVehicleSpawnerRespawnTime(spawner: VehicleSpawner, respawnTime: number): void
SetVehicleSpawnerTimeUntilAbandon(spawner: VehicleSpawner, timeUntilAbandon: number): void
SetVehicleSpawnerKeepAliveAbandonRadius(spawner: VehicleSpawner, radius: number): void
SetVehicleSpawnerSpawnerRadius(spawner: VehicleSpawner, radius: number): void
SetVehicleSpawnerAbandonVehicleOutOfCombatArea(spawner: VehicleSpawner, enabled: boolean): void
SetVehicleSpawnerApplyDamageToAbandonVehicle(spawner: VehicleSpawner, enabled: boolean): void
ForceVehicleSpawnerSpawn(spawner: VehicleSpawner): void
```

**Example:**
```typescript
// Advanced vehicle spawner setup
function configureVehicleSpawner(
  spawnerId: number,
  vehicleType: mod.VehicleList,
  respawnTime: number
) {
  const spawner = mod.GetVehicleSpawner(spawnerId);

  mod.SetVehicleSpawnerType(spawner, vehicleType);
  mod.SetVehicleSpawnerAutoSpawn(spawner, true);
  mod.SetVehicleSpawnerRespawnTime(spawner, respawnTime);

  // Abandon settings
  mod.SetVehicleSpawnerTimeUntilAbandon(spawner, 30);  // 30 sec empty
  mod.SetVehicleSpawnerAbandonVehicleOutOfCombatArea(spawner, true);
  mod.SetVehicleSpawnerApplyDamageToAbandonVehicle(spawner, true);

  // Keep-alive zones
  mod.SetVehicleSpawnerKeepAliveAbandonRadius(spawner, 100);
  mod.SetVehicleSpawnerSpawnerRadius(spawner, 50);

  // Spawn immediately
  mod.ForceVehicleSpawnerSpawn(spawner);
}

// Setup multiple vehicles
export async function OnGameModeStarted() {
  configureVehicleSpawner(300, mod.VehicleList.M1A5, 60);
  configureVehicleSpawner(301, mod.VehicleList.AH64_Apache, 90);
  configureVehicleSpawner(302, mod.VehicleList.LATV4_Recon, 30);
  configureVehicleSpawner(303, mod.VehicleList.MAV, 45);
}
```

## Objective Objects

### Capture Points

#### GetCapturePoint

```typescript
GetCapturePoint(capturePointId: number): CapturePoint
```

Get reference to a capture point.

**Example:**
```typescript
// Capture point IDs
const CAPTURE_POINT_A = 400;
const CAPTURE_POINT_B = 401;
const CAPTURE_POINT_C = 402;

export async function OnGameModeStarted() {
  const pointA = mod.GetCapturePoint(CAPTURE_POINT_A);
  const pointB = mod.GetCapturePoint(CAPTURE_POINT_B);
  const pointC = mod.GetCapturePoint(CAPTURE_POINT_C);

  // Configure capture times
  mod.SetCapturePointCapturingTime(pointA, 10);  // 10 seconds to capture
  mod.SetCapturePointCapturingTime(pointB, 15);
  mod.SetCapturePointCapturingTime(pointC, 20);

  // Set neutralization times
  mod.SetCapturePointNeutralizationTime(pointA, 5);
  mod.SetCapturePointNeutralizationTime(pointB, 7);
  mod.SetCapturePointNeutralizationTime(pointC, 10);

  // Set capture multipliers
  mod.SetMaxCaptureMultiplier(pointA, 3);  // Max 3x speed
  mod.SetMaxCaptureMultiplier(pointB, 3);
  mod.SetMaxCaptureMultiplier(pointC, 3);

  // Enable spawning on captured points
  mod.EnableCapturePointDeploying(pointA, true);
  mod.EnableCapturePointDeploying(pointB, true);
  mod.EnableCapturePointDeploying(pointC, true);

  // Set initial owners
  mod.SetCapturePointOwner(pointA, mod.Team.Team1);
  mod.SetCapturePointOwner(pointB, mod.Team.Neutral);
  mod.SetCapturePointOwner(pointC, mod.Team.Team2);
}
```

#### Capture Point Functions

```typescript
SetCapturePointCapturingTime(capturePoint: CapturePoint, capturingTime: number): void
SetCapturePointNeutralizationTime(capturePoint: CapturePoint, neutralizationTime: number): void
SetCapturePointOwner(capturePoint: CapturePoint, team: Team): void
SetMaxCaptureMultiplier(capturePoint: CapturePoint, multiplier: number): void
EnableCapturePointDeploying(capturePoint: CapturePoint, enableDeploying: boolean): void
EnableGameModeObjective(objective: CapturePoint, enable: boolean): void
```

**Example:**
```typescript
// Dynamic capture point control
const capturePoints = [400, 401, 402];

async function unlockCapturePointsSequentially() {
  for (const pointId of capturePoints) {
    const point = mod.GetCapturePoint(pointId);

    // Start disabled
    mod.EnableGameModeObjective(point, false);
  }

  // Unlock points one by one
  for (const pointId of capturePoints) {
    const point = mod.GetCapturePoint(pointId);

    mod.EnableGameModeObjective(point, true);
    mod.DisplayGameModeMessage(mod.Message("New capture point available!"));

    // Wait for capture
    while (true) {
      // Check if captured (would need custom tracking)
      await mod.Wait(1);
      // Break when captured
    }
  }
}
```

### Headquarters (HQ)

```typescript
GetHQ(hqId: number): HQ
SetHQTeam(hq: HQ, team: Team): void
EnableHQ(hq: HQ, enable: boolean): void
EnableGameModeObjective(objective: HQ, enable: boolean): void
```

**Example:**
```typescript
// Team headquarters
const TEAM1_HQ = 500;
const TEAM2_HQ = 501;

export async function OnGameModeStarted() {
  const hq1 = mod.GetHQ(TEAM1_HQ);
  const hq2 = mod.GetHQ(TEAM2_HQ);

  mod.SetHQTeam(hq1, mod.Team.Team1);
  mod.SetHQTeam(hq2, mod.Team.Team2);

  mod.EnableHQ(hq1, true);
  mod.EnableHQ(hq2, true);
}

// Disable HQ when team loses
function disableTeamHQ(team: mod.Team) {
  const hqId = team === mod.Team.Team1 ? TEAM1_HQ : TEAM2_HQ;
  const hq = mod.GetHQ(hqId);

  mod.EnableHQ(hq, false);
  mod.DisplayGameModeMessage(mod.Message("HQ Destroyed!"));
}
```

### MCOM (Rush)

```typescript
GetMCOM(mcomId: number): MCOM
SetMCOMFuseTime(mcom: MCOM, fuseTime: number): void
EnableGameModeObjective(objective: MCOM, enable: boolean): void
```

**Example:**
```typescript
// MCOM objectives
const MCOM_A = 600;
const MCOM_B = 601;

export async function OnGameModeStarted() {
  const mcomA = mod.GetMCOM(MCOM_A);
  const mcomB = mod.GetMCOM(MCOM_B);

  // Set fuse time (time to arm)
  mod.SetMCOMFuseTime(mcomA, 5);  // 5 seconds
  mod.SetMCOMFuseTime(mcomB, 5);

  // Enable objectives
  mod.EnableGameModeObjective(mcomA, true);
  mod.EnableGameModeObjective(mcomB, true);
}
```

### Sectors

```typescript
GetSector(sectorId: number): Sector
EnableGameModeObjective(objective: Sector, enable: boolean): void
```

**Example:**
```typescript
// Map sectors for Rush-style progression
const SECTORS = [700, 701, 702];

let currentSector = 0;

export async function OnGameModeStarted() {
  // Disable all sectors
  for (const sectorId of SECTORS) {
    const sector = mod.GetSector(sectorId);
    mod.EnableGameModeObjective(sector, false);
  }

  // Enable first sector
  enableSector(0);
}

function enableSector(index: number) {
  if (index >= SECTORS.length) return;

  const sector = mod.GetSector(SECTORS[index]);
  mod.EnableGameModeObjective(sector, true);
  currentSector = index;
}
```

## Interactive Objects

### Area Triggers

#### GetAreaTrigger

```typescript
GetAreaTrigger(triggerId: number): AreaTrigger
EnableAreaTrigger(trigger: AreaTrigger, enable: boolean): void
```

Get reference to an area trigger zone.

**Example:**
```typescript
// Area trigger zones
const CAPTURE_ZONE = 800;
const DEATH_ZONE = 801;
const SPEED_BOOST_ZONE = 802;

export async function OnGameModeStarted() {
  const captureZone = mod.GetAreaTrigger(CAPTURE_ZONE);
  const deathZone = mod.GetAreaTrigger(DEATH_ZONE);
  const boostZone = mod.GetAreaTrigger(SPEED_BOOST_ZONE);

  mod.EnableAreaTrigger(captureZone, true);
  mod.EnableAreaTrigger(deathZone, true);
  mod.EnableAreaTrigger(boostZone, true);
}

// Track players in zones
const playersInZone = new Map<number, Set<mod.Player>>();

async function monitorAreaTrigger(triggerId: number) {
  const trigger = mod.GetAreaTrigger(triggerId);
  const transform = mod.GetObjectTransform(trigger);
  const zonePos = transform.position;
  const zoneRadius = 20;  // Set based on trigger size

  playersInZone.set(triggerId, new Set());

  while (true) {
    const players = modlib.ConvertArray(mod.AllPlayers());
    const currentlyInZone = new Set<mod.Player>();

    for (const player of players) {
      const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
      const distance = mod.DistanceBetween(playerPos, zonePos);

      if (distance <= zoneRadius) {
        currentlyInZone.add(player);

        // Player entered zone
        if (!playersInZone.get(triggerId)!.has(player)) {
          onPlayerEnterZone(player, triggerId);
        }
      } else {
        // Player left zone
        if (playersInZone.get(triggerId)!.has(player)) {
          onPlayerLeaveZone(player, triggerId);
        }
      }
    }

    playersInZone.set(triggerId, currentlyInZone);
    await mod.Wait(0.5);
  }
}

function onPlayerEnterZone(player: mod.Player, triggerId: number) {
  if (triggerId === DEATH_ZONE) {
    mod.Kill(player);
  } else if (triggerId === SPEED_BOOST_ZONE) {
    mod.SetPlayerMovementSpeedMultiplier(player, 1.5);
  }
}

function onPlayerLeaveZone(player: mod.Player, triggerId: number) {
  if (triggerId === SPEED_BOOST_ZONE) {
    mod.SetPlayerMovementSpeedMultiplier(player, 1.0);
  }
}
```

### Interact Points

```typescript
GetInteractPoint(interactPointId: number): InteractPoint
EnableInteractPoint(interactPoint: InteractPoint, enable: boolean): void
```

Get reference to an interactive point.

**Example:**
```typescript
// Interact point IDs
const DOOR_BUTTON = 900;
const SUPPLY_CRATE = 901;
const OBJECTIVE_TERMINAL = 902;

export async function OnGameModeStarted() {
  const doorButton = mod.GetInteractPoint(DOOR_BUTTON);
  const supplyCrate = mod.GetInteractPoint(SUPPLY_CRATE);
  const terminal = mod.GetInteractPoint(OBJECTIVE_TERMINAL);

  mod.EnableInteractPoint(doorButton, true);
  mod.EnableInteractPoint(supplyCrate, true);
  mod.EnableInteractPoint(terminal, true);
}

// Track interaction (requires custom proximity detection)
async function monitorInteractPoint(pointId: number, callback: (player: mod.Player) => void) {
  const point = mod.GetInteractPoint(pointId);
  const transform = mod.GetObjectTransform(point);
  const pointPos = transform.position;
  const interactRadius = 2;  // Meters

  while (true) {
    const players = modlib.ConvertArray(mod.AllPlayers());

    for (const player of players) {
      if (!mod.IsPlayerValid(player)) continue;

      const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
      const distance = mod.DistanceBetween(playerPos, pointPos);

      if (distance <= interactRadius) {
        // Player in range - would need to detect actual interaction
        // This is simplified; real detection would need input tracking
        callback(player);
      }
    }

    await mod.Wait(0.5);
  }
}

// Usage
monitorInteractPoint(SUPPLY_CRATE, (player) => {
  mod.ResupplyPlayer(player, mod.ResupplyTypes.All);
  mod.DisplayNotificationMessage(mod.Message("Resupplied!"), player);
});
```

## World Icons

### GetWorldIcon

```typescript
GetWorldIcon(worldIconId: number): WorldIcon
SetWorldIconVisibility(icon: WorldIcon, visible: boolean): void
SetWorldIconColor(icon: WorldIcon, color: Vector): void
SetWorldIconImage(icon: WorldIcon, image: WorldIconImages): void
SetWorldIconText(icon: WorldIcon, text: Message): void
SetWorldIconPosition(icon: WorldIcon, position: Vector): void
SetWorldIconOwner(icon: WorldIcon, owner: Team | Player): void
EnableWorldIconImage(icon: WorldIcon, enable: boolean): void
EnableWorldIconText(icon: WorldIcon, enable: boolean): void
```

**Example:**
```typescript
// World icon markers
const OBJECTIVE_ICON = 1000;
const EXTRACTION_ICON = 1001;

export async function OnGameModeStarted() {
  const objectiveIcon = mod.GetWorldIcon(OBJECTIVE_ICON);
  const extractIcon = mod.GetWorldIcon(EXTRACTION_ICON);

  // Configure objective marker
  mod.SetWorldIconImage(objectiveIcon, mod.WorldIconImages.Objective);
  mod.SetWorldIconText(objectiveIcon, mod.Message("Capture Point A"));
  mod.SetWorldIconColor(objectiveIcon, mod.CreateVector(1, 0, 0));  // Red
  mod.EnableWorldIconImage(objectiveIcon, true);
  mod.EnableWorldIconText(objectiveIcon, true);

  // Configure extraction marker
  mod.SetWorldIconImage(extractIcon, mod.WorldIconImages.Extraction);
  mod.SetWorldIconText(extractIcon, mod.Message("Extract Here"));
  mod.SetWorldIconColor(extractIcon, mod.CreateVector(0, 1, 0));  // Green
}

// Update icon position dynamically
async function trackMovingObjective(iconId: number, targetPlayer: mod.Player) {
  const icon = mod.GetWorldIcon(iconId);

  while (mod.IsPlayerValid(targetPlayer)) {
    const playerPos = mod.GetSoldierState(targetPlayer, mod.SoldierStateVector.GetPosition);
    mod.SetWorldIconPosition(icon, playerPos);
    await mod.Wait(0.1);
  }
}
```

## Spatial Objects

### GetSpatialObject

```typescript
GetSpatialObject(objectId: number): SpatialObject
EnableObject(object: SpatialObject, enabled: boolean): void
```

Get reference to any spatial object (doors, platforms, etc).

**Example:**
```typescript
// Spatial objects
const DOOR_1 = 1100;
const BRIDGE_1 = 1101;
const ELEVATOR_1 = 1102;

export async function OnGameModeStarted() {
  const door = mod.GetSpatialObject(DOOR_1);
  const bridge = mod.GetSpatialObject(BRIDGE_1);

  // Hide initially
  mod.EnableObject(door, false);
  mod.EnableObject(bridge, false);
}

function openDoor(doorId: number) {
  const door = mod.GetSpatialObject(doorId);
  mod.EnableObject(door, true);

  mod.DisplayGameModeMessage(mod.Message("Door Opened!"));
}

function closeDoor(doorId: number) {
  const door = mod.GetSpatialObject(doorId);
  mod.EnableObject(door, false);

  mod.DisplayGameModeMessage(mod.Message("Door Closed!"));
}
```

## Common Patterns

### Progressive Unlocking

```typescript
// Unlock objectives sequentially
const OBJECTIVES = [400, 401, 402, 403];
let currentObjective = 0;

export async function OnGameModeStarted() {
  // Disable all
  for (const objId of OBJECTIVES) {
    const obj = mod.GetCapturePoint(objId);
    mod.EnableGameModeObjective(obj, false);
  }

  // Enable first
  unlockNextObjective();
}

function unlockNextObjective() {
  if (currentObjective >= OBJECTIVES.length) return;

  const obj = mod.GetCapturePoint(OBJECTIVES[currentObjective]);
  mod.EnableGameModeObjective(obj, true);
  mod.DisplayGameModeMessage(mod.Message(`Objective ${currentObjective + 1} Active!`));

  currentObjective++;
}
```

### Dynamic Spawner Management

```typescript
// Switch active vehicle spawners
const VEHICLE_SPAWNERS = [300, 301, 302];
let activeSpawner = 0;

async function rotateVehicleSpawners(intervalSeconds: number) {
  while (true) {
    // Disable all
    for (const spawnId of VEHICLE_SPAWNERS) {
      const spawner = mod.GetVehicleSpawner(spawnId);
      mod.SetVehicleSpawnerAutoSpawn(spawner, false);
    }

    // Enable one
    const spawner = mod.GetVehicleSpawner(VEHICLE_SPAWNERS[activeSpawner]);
    mod.SetVehicleSpawnerAutoSpawn(spawner, true);
    mod.ForceVehicleSpawnerSpawn(spawner);

    activeSpawner = (activeSpawner + 1) % VEHICLE_SPAWNERS.length;

    await mod.Wait(intervalSeconds);
  }
}
```

### Zone-Based Gameplay

```typescript
// Control zones with buffs/debuffs
const SAFE_ZONE = 800;
const COMBAT_ZONE = 801;
const HAZARD_ZONE = 802;

interface ZoneConfig {
  triggerId: number;
  onEnter: (player: mod.Player) => void;
  onExit: (player: mod.Player) => void;
}

const zones: ZoneConfig[] = [
  {
    triggerId: SAFE_ZONE,
    onEnter: (player) => {
      mod.SetPlayerIncomingDamageMultiplier(player, 0);
      mod.DisplayNotificationMessage(mod.Message("Safe Zone - No Damage"), player);
    },
    onExit: (player) => {
      mod.SetPlayerIncomingDamageMultiplier(player, 1);
    }
  },
  {
    triggerId: COMBAT_ZONE,
    onEnter: (player) => {
      mod.SetPlayerOutgoingDamageMultiplier(player, 1.5);
      mod.DisplayNotificationMessage(mod.Message("Combat Zone - 1.5x Damage"), player);
    },
    onExit: (player) => {
      mod.SetPlayerOutgoingDamageMultiplier(player, 1);
    }
  },
  {
    triggerId: HAZARD_ZONE,
    onEnter: (player) => {
      mod.DealDamage(player, 10);  // Damage over time would need async loop
      mod.DisplayNotificationMessage(mod.Message("Hazard Zone!"), player);
    },
    onExit: (player) => {
      // Stop damage
    }
  }
];
```

## Best Practices

### 1. Document Object IDs

```typescript
// Create constants file for all object IDs
const OBJECT_IDS = {
  // Spawners
  TEAM1_SPAWN: 100,
  TEAM2_SPAWN: 101,

  // Vehicles
  TANK_SPAWN: 300,
  HELI_SPAWN: 301,

  // Objectives
  CAPTURE_A: 400,
  CAPTURE_B: 401,

  // Triggers
  SAFE_ZONE: 800,
  COMBAT_ZONE: 801
};
```

### 2. Validate References

```typescript
function safeGetCapturePoint(pointId: number): mod.CapturePoint | null {
  try {
    const point = mod.GetCapturePoint(pointId);
    if (!point) {
      console.log(`Capture point ${pointId} not found`);
      return null;
    }
    return point;
  } catch (error) {
    console.log(`Error getting capture point ${pointId}: ${error}`);
    return null;
  }
}
```

### 3. Initialize in OnGameModeStarted

```typescript
export async function OnGameModeStarted() {
  initializeSpawners();
  initializeObjectives();
  initializeVehicles();
  initializeTriggers();
}

function initializeSpawners() {
  // Setup all spawners
}

function initializeObjectives() {
  // Setup all objectives
}
```

### 4. Clean State Management

```typescript
// Track objective states
interface ObjectiveState {
  id: number;
  enabled: boolean;
  owner: mod.Team;
  captureProgress: number;
}

const objectiveStates: ObjectiveState[] = [];

function updateObjectiveState(id: number, state: Partial<ObjectiveState>) {
  const existing = objectiveStates.find(o => o.id === id);
  if (existing) {
    Object.assign(existing, state);
  } else {
    objectiveStates.push({ id, enabled: false, owner: mod.Team.Neutral, captureProgress: 0, ...state });
  }
}
```

## Next Steps

- 📖 [Object Spawning](/api/object-spawning) - Runtime object creation
- 📖 [Object Transform](/api/object-transform) - Moving objects
- 📖 [Teams & Scoring](/api/teams-scoring) - Team management
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip Gameplay Objects Summary
- **Spawners** - Player, AI, and vehicle spawn points
- **Objectives** - Capture points, HQ, MCOM, sectors
- **Triggers** - Area zones for events
- **Interactables** - Interactive points
- **World Icons** - 3D markers and indicators
- **Always validate** - Check object references before use
:::
