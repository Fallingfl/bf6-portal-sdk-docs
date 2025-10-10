# Player State

Functions for querying and modifying player states, including health, position, and various gameplay states.

## Overview

Player state functions allow you to:
- Query player conditions (alive, sprinting, in vehicle, etc.)
- Get player statistics (health, ammo, position, velocity)
- Check player status in real-time
- Validate player references

## State Query Functions

### GetSoldierState

Query various player states using three overloaded versions:

#### Boolean States

```typescript
GetSoldierState(player: Player, state: SoldierStateBool): boolean
```

**Available Boolean States:**
```typescript
mod.SoldierStateBool.HasLowHealth    // Health below threshold
mod.SoldierStateBool.InVehicle       // Inside a vehicle
mod.SoldierStateBool.IsAI            // Is AI bot
mod.SoldierStateBool.IsAlive         // Currently alive
mod.SoldierStateBool.IsAirborne      // In the air
mod.SoldierStateBool.IsCrouching     // Crouching
mod.SoldierStateBool.IsDeploying     // Deploying into game
mod.SoldierStateBool.IsDeployed      // Fully deployed
mod.SoldierStateBool.IsFalling       // Falling
mod.SoldierStateBool.IsFiring        // Shooting weapon
mod.SoldierStateBool.IsGrounded      // On ground
mod.SoldierStateBool.IsManDown       // Downed state
mod.SoldierStateBool.IsMoving        // Moving
mod.SoldierStateBool.IsOnWater       // On water surface
mod.SoldierStateBool.IsParachuting   // Using parachute
mod.SoldierStateBool.IsProne         // Prone position
mod.SoldierStateBool.IsReloading     // Reloading weapon
mod.SoldierStateBool.IsScoped        // Aiming down sights
mod.SoldierStateBool.IsSprinting     // Sprinting
mod.SoldierStateBool.IsSwimming      // Swimming
mod.SoldierStateBool.IsUnderwater    // Underwater
mod.SoldierStateBool.IsUsingGadget   // Using gadget
```

**Example:**
```typescript
// Check if player is alive
if (mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive)) {
  console.log("Player is alive");
}

// Check multiple states
const isAlive = mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive);
const inVehicle = mod.GetSoldierState(player, mod.SoldierStateBool.InVehicle);
const isSprinting = mod.GetSoldierState(player, mod.SoldierStateBool.IsSprinting);

if (isAlive && !inVehicle && isSprinting) {
  console.log("Player is sprinting on foot");
}
```

#### Numeric States

```typescript
GetSoldierState(player: Player, state: SoldierStateNumber): number
```

**Available Numeric States:**
```typescript
mod.SoldierStateNumber.Ammo            // Current ammo in magazine
mod.SoldierStateNumber.AnimationSpeed  // Animation playback speed
mod.SoldierStateNumber.ClipSize        // Magazine size
mod.SoldierStateNumber.CurrentHealth   // Current HP
mod.SoldierStateNumber.ForwardSpeed    // Forward movement speed
mod.SoldierStateNumber.MaxHealth       // Maximum HP
mod.SoldierStateNumber.RightSpeed      // Strafe speed
mod.SoldierStateNumber.UpSpeed         // Vertical speed
```

**Example:**
```typescript
// Get health info
const currentHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.CurrentHealth);
const maxHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.MaxHealth);
const healthPercent = (currentHealth / maxHealth) * 100;

console.log(`Health: ${currentHealth}/${maxHealth} (${healthPercent}%)`);

// Check if low on ammo
const ammo = mod.GetSoldierState(player, mod.SoldierStateNumber.Ammo);
const clipSize = mod.GetSoldierState(player, mod.SoldierStateNumber.ClipSize);

if (ammo < clipSize * 0.25) {
  console.log("Low ammo warning!");
}
```

#### Vector States

```typescript
GetSoldierState(player: Player, state: SoldierStateVector): Vector
```

**Available Vector States:**
```typescript
mod.SoldierStateVector.GetPosition      // World position
mod.SoldierStateVector.GetVelocity      // Movement velocity
mod.SoldierStateVector.GetViewDirection // Looking direction
```

**Example:**
```typescript
// Get player position
const position = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
console.log(`Player at: x=${position.x}, y=${position.y}, z=${position.z}`);

// Get movement velocity
const velocity = mod.GetSoldierState(player, mod.SoldierStateVector.GetVelocity);
const speed = mod.Magnitude(velocity);
console.log(`Moving at ${speed} m/s`);

// Get look direction
const lookDir = mod.GetSoldierState(player, mod.SoldierStateVector.GetViewDirection);
```

## Player Validation

### IsPlayerValid

```typescript
IsPlayerValid(player: Player): boolean
```

Check if a player reference is still valid (player hasn't disconnected).

**Example:**
```typescript
function safePlayerOperation(player: mod.Player) {
  if (!mod.IsPlayerValid(player)) {
    console.log("Player no longer valid!");
    return;
  }

  // Safe to use player
  mod.Teleport(player, destination, 0);
}
```

## Player Information

### Basic Info

```typescript
GetPlayerName(player: Player): string
GetPlayerId(player: Player): string
GetTeam(player: Player): Team
GetSquad(player: Player): Squad
```

**Example:**
```typescript
const name = mod.GetPlayerName(player);
const id = mod.GetPlayerId(player);
const team = mod.GetTeam(player);
const squad = mod.GetSquad(player);

console.log(`${name} (ID: ${id}) - Team: ${team}, Squad: ${squad}`);
```

### Transform & Position

```typescript
GetPlayerTransform(player: Player): Transform
```

Get player's complete transform (position + rotation).

**Example:**
```typescript
const transform = mod.GetPlayerTransform(player);
const position = transform.position;
const rotation = transform.rotation;

console.log(`Player at: ${position.x}, ${position.y}, ${position.z}`);
```

## Finding Players

### Distance-Based

```typescript
ClosestPlayerTo(position: Vector): Player
FarthestPlayerFrom(position: Vector): Player
```

Find players based on distance from a position.

**Example:**
```typescript
// Find closest player to objective
const objectivePos = mod.CreateVector(500, 0, 100);
const closest = mod.ClosestPlayerTo(objectivePos);

if (closest) {
  console.log(`${mod.GetPlayerName(closest)} is closest to objective`);
}

// Find farthest player from spawn
const spawnPos = mod.CreateVector(0, 0, 0);
const farthest = mod.FarthestPlayerFrom(spawnPos);
```

### Get All Players

```typescript
AllPlayers(): Array
```

Get all players currently in the game.

**Example:**
```typescript
import * as modlib from './modlib';

// Get all players as JavaScript array
const players = modlib.ConvertArray(mod.AllPlayers());

// Count alive players
const alivePlayers = players.filter(p =>
  mod.GetSoldierState(p, mod.SoldierStateBool.IsAlive)
);

console.log(`${alivePlayers.length} players alive`);
```

### Get Players by Team

```typescript
GetPlayersInTeam(team: Team): Array
```

Get all players in a specific team.

**Example:**
```typescript
const team1Players = modlib.ConvertArray(
  mod.GetPlayersInTeam(mod.Team.Team1)
);

const team2Players = modlib.ConvertArray(
  mod.GetPlayersInTeam(mod.Team.Team2)
);

console.log(`Team 1: ${team1Players.length} players`);
console.log(`Team 2: ${team2Players.length} players`);
```

## Common State Patterns

### Health Check

```typescript
function checkPlayerHealth(player: mod.Player) {
  const currentHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.CurrentHealth);
  const maxHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.MaxHealth);
  const hasLowHealth = mod.GetSoldierState(player, mod.SoldierStateBool.HasLowHealth);

  if (hasLowHealth) {
    // Give health pack
    mod.Heal(player, 50);
    console.log("Player healed!");
  }

  return {
    current: currentHealth,
    max: maxHealth,
    percentage: (currentHealth / maxHealth) * 100,
    isLow: hasLowHealth
  };
}
```

### Movement State

```typescript
function getMovementState(player: mod.Player) {
  return {
    isMoving: mod.GetSoldierState(player, mod.SoldierStateBool.IsMoving),
    isSprinting: mod.GetSoldierState(player, mod.SoldierStateBool.IsSprinting),
    isCrouching: mod.GetSoldierState(player, mod.SoldierStateBool.IsCrouching),
    isProne: mod.GetSoldierState(player, mod.SoldierStateBool.IsProne),
    isAirborne: mod.GetSoldierState(player, mod.SoldierStateBool.IsAirborne),
    isFalling: mod.GetSoldierState(player, mod.SoldierStateBool.IsFalling),
    isParachuting: mod.GetSoldierState(player, mod.SoldierStateBool.IsParachuting),
    forwardSpeed: mod.GetSoldierState(player, mod.SoldierStateNumber.ForwardSpeed),
    rightSpeed: mod.GetSoldierState(player, mod.SoldierStateNumber.RightSpeed),
    upSpeed: mod.GetSoldierState(player, mod.SoldierStateNumber.UpSpeed)
  };
}
```

### Combat State

```typescript
function getCombatState(player: mod.Player) {
  return {
    isFiring: mod.GetSoldierState(player, mod.SoldierStateBool.IsFiring),
    isReloading: mod.GetSoldierState(player, mod.SoldierStateBool.IsReloading),
    isScoped: mod.GetSoldierState(player, mod.SoldierStateBool.IsScoped),
    isUsingGadget: mod.GetSoldierState(player, mod.SoldierStateBool.IsUsingGadget),
    ammo: mod.GetSoldierState(player, mod.SoldierStateNumber.Ammo),
    clipSize: mod.GetSoldierState(player, mod.SoldierStateNumber.ClipSize),
    lookDirection: mod.GetSoldierState(player, mod.SoldierStateVector.GetViewDirection)
  };
}
```

### Environment State

```typescript
function getEnvironmentState(player: mod.Player) {
  return {
    isGrounded: mod.GetSoldierState(player, mod.SoldierStateBool.IsGrounded),
    isOnWater: mod.GetSoldierState(player, mod.SoldierStateBool.IsOnWater),
    isSwimming: mod.GetSoldierState(player, mod.SoldierStateBool.IsSwimming),
    isUnderwater: mod.GetSoldierState(player, mod.SoldierStateBool.IsUnderwater),
    inVehicle: mod.GetSoldierState(player, mod.SoldierStateBool.InVehicle),
    position: mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition)
  };
}
```

## State Monitoring

### Continuous State Checking

```typescript
async function monitorPlayerStates() {
  while (gameRunning) {
    const players = modlib.ConvertArray(mod.AllPlayers());

    for (const player of players) {
      if (!mod.IsPlayerValid(player)) continue;

      // Check for specific conditions
      if (mod.GetSoldierState(player, mod.SoldierStateBool.IsUnderwater)) {
        // Start drowning timer
        startDrowningTimer(player);
      }

      if (mod.GetSoldierState(player, mod.SoldierStateBool.HasLowHealth)) {
        // Show low health warning
        showLowHealthWarning(player);
      }

      if (mod.GetSoldierState(player, mod.SoldierStateBool.IsFalling)) {
        // Check fall distance
        checkFallDamage(player);
      }
    }

    await mod.Wait(0.5);  // Check every 500ms
  }
}
```

### State Change Detection

```typescript
interface PlayerStateCache {
  player: mod.Player;
  wasAlive: boolean;
  wasInVehicle: boolean;
  wasSprinting: boolean;
}

let stateCache: PlayerStateCache[] = [];

function detectStateChanges(player: mod.Player) {
  let cache = stateCache.find(s => s.player === player);

  if (!cache) {
    cache = {
      player: player,
      wasAlive: true,
      wasInVehicle: false,
      wasSprinting: false
    };
    stateCache.push(cache);
  }

  // Check for state changes
  const isAlive = mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive);
  const inVehicle = mod.GetSoldierState(player, mod.SoldierStateBool.InVehicle);
  const isSprinting = mod.GetSoldierState(player, mod.SoldierStateBool.IsSprinting);

  // Detect death
  if (cache.wasAlive && !isAlive) {
    onPlayerStateChanged(player, "died");
  }

  // Detect vehicle enter
  if (!cache.wasInVehicle && inVehicle) {
    onPlayerStateChanged(player, "entered_vehicle");
  }

  // Detect vehicle exit
  if (cache.wasInVehicle && !inVehicle) {
    onPlayerStateChanged(player, "exited_vehicle");
  }

  // Detect sprint start
  if (!cache.wasSprinting && isSprinting) {
    onPlayerStateChanged(player, "started_sprinting");
  }

  // Update cache
  cache.wasAlive = isAlive;
  cache.wasInVehicle = inVehicle;
  cache.wasSprinting = isSprinting;
}
```

## Performance Optimization

### Cache State Queries

```typescript
// ❌ Bad - multiple queries
function badExample(player: mod.Player) {
  if (mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive)) {
    if (mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive)) {  // Duplicate!
      // Do something
    }
  }
}

// ✅ Good - cache result
function goodExample(player: mod.Player) {
  const isAlive = mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive);

  if (isAlive) {
    // Use cached value
    if (isAlive) {
      // Do something
    }
  }
}
```

### Batch State Queries

```typescript
// Get all states at once
function getPlayerFullState(player: mod.Player) {
  if (!mod.IsPlayerValid(player)) {
    return null;
  }

  return {
    // Boolean states
    alive: mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive),
    moving: mod.GetSoldierState(player, mod.SoldierStateBool.IsMoving),
    inCombat: mod.GetSoldierState(player, mod.SoldierStateBool.IsFiring),

    // Numeric states
    health: mod.GetSoldierState(player, mod.SoldierStateNumber.CurrentHealth),
    maxHealth: mod.GetSoldierState(player, mod.SoldierStateNumber.MaxHealth),
    ammo: mod.GetSoldierState(player, mod.SoldierStateNumber.Ammo),

    // Vector states
    position: mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition),
    velocity: mod.GetSoldierState(player, mod.SoldierStateVector.GetVelocity),

    // Computed values
    healthPercent: 0,  // Calculate after
    speed: 0           // Calculate after
  };
}
```

## Best Practices

### 1. Always Validate Players

```typescript
function safeStateQuery(player: mod.Player) {
  if (!mod.IsPlayerValid(player)) {
    return null;
  }

  return mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive);
}
```

### 2. Use Appropriate State Types

```typescript
// ✅ Correct state type
const isAlive = mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive);

// ❌ Wrong state type (would cause error)
// const isAlive = mod.GetSoldierState(player, mod.SoldierStateNumber.IsAlive);
```

### 3. Handle State Combinations

```typescript
function canPlayerShoot(player: mod.Player): boolean {
  const isAlive = mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive);
  const isDeployed = mod.GetSoldierState(player, mod.SoldierStateBool.IsDeployed);
  const isReloading = mod.GetSoldierState(player, mod.SoldierStateBool.IsReloading);
  const ammo = mod.GetSoldierState(player, mod.SoldierStateNumber.Ammo);

  return isAlive && isDeployed && !isReloading && ammo > 0;
}
```

### 4. Optimize Query Frequency

```typescript
// Don't query every frame for non-critical states
async function optimizedStateCheck() {
  while (gameRunning) {
    // Critical states - check frequently
    checkCombatStates();
    await mod.Wait(0.1);  // 10 times per second

    // Non-critical states - check less often
    if (frameCount % 10 === 0) {
      checkEnvironmentStates();
    }

    frameCount++;
  }
}
```

## Related Functions

### Health Management

```typescript
// Modify health based on state
const currentHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.CurrentHealth);
const maxHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.MaxHealth);

if (currentHealth < maxHealth * 0.25) {
  mod.Heal(player, 50);
}
```

### Position Tracking

```typescript
// Track player movement
const position = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
const velocity = mod.GetSoldierState(player, mod.SoldierStateVector.GetVelocity);

// Store for later comparison
playerPositions.set(player, position);
```

## Next Steps

- 📖 [Player Control](/api/player-control) - Modifying player properties
- 📖 [Player Spawning](/api/player-spawning) - Spawning and deployment
- 📖 [Player Equipment](/api/player-equipment) - Weapons and gadgets
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip Player State Summary
- **23 boolean states** - Check conditions like alive, moving, in vehicle
- **8 numeric states** - Get values like health, ammo, speed
- **3 vector states** - Get position, velocity, view direction
- **Always validate** - Check IsPlayerValid before queries
- **Cache results** - Don't query same state multiple times
:::