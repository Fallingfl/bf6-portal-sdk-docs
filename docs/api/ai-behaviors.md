# AI Behaviors

Detailed documentation for the 7 AI behavior types and their configuration options.

## Overview

AI behaviors control how bots act in your game mode. Each behavior has specific parameters and use cases.

## Behavior Types

### BattlefieldAI

```typescript
SetAIBehavior(soldier: Player, behavior: AIBehavior.BattlefieldAI): void
```

Standard combat AI that mimics player behavior.

**Features:**
- Automatic target acquisition
- Cover usage and flanking
- Team coordination
- Objective awareness

**Example:**
```typescript
export async function OnGameModeStarted() {
  // Spawn combat AI
  const spawner = mod.GetAISpawner(1);
  const aiSoldier = mod.SpawnAIFromAISpawner(spawner);

  // Set combat behavior
  mod.SetAIBehavior(aiSoldier, mod.AIBehavior.BattlefieldAI);

  // Configure combat settings
  mod.SetAIShootingEnabled(aiSoldier, true);
  mod.SetAIGrenadeEnabled(aiSoldier, true);
  mod.SetAIDamageModifier(aiSoldier, 0.75);  // 75% damage
}
```

### MoveToLocation

```typescript
SetAIBehavior(soldier: Player, behavior: AIBehavior.MoveToLocation): void
SetAIMoveToLocationDestination(soldier: Player, position: Vector): void
```

Direct movement to a specific position.

**Parameters:**
- `position`: Target destination (Vector3)

**Example:**
```typescript
function sendAIToObjective(ai: mod.Player, objectivePos: mod.Vector) {
  // Set movement behavior
  mod.SetAIBehavior(ai, mod.AIBehavior.MoveToLocation);

  // Set destination
  mod.SetAIMoveToLocationDestination(ai, objectivePos);

  // Configure movement speed
  mod.SetAIMovementSpeed(ai, mod.MovementSpeed.Sprint);

  // Check arrival
  checkArrival(ai, objectivePos);
}

async function checkArrival(ai: mod.Player, target: mod.Vector) {
  while (true) {
    const aiPos = mod.GetSoldierState(ai, mod.SoldierStateVector.GetPosition);
    const distance = mod.DistanceBetween(aiPos, target);

    if (distance < 5) {
      console.log("AI reached destination");
      // Switch to defend behavior
      mod.SetAIBehavior(ai, mod.AIBehavior.DefendLocation);
      break;
    }

    await mod.Wait(1);
  }
}
```

### DefendLocation

```typescript
SetAIBehavior(soldier: Player, behavior: AIBehavior.DefendLocation): void
SetAIDefendLocationDestination(soldier: Player, position: Vector, radius: number): void
```

Defend an area within a radius.

**Parameters:**
- `position`: Center of defense area
- `radius`: Defense perimeter (meters)

**Example:**
```typescript
// Create defensive AI squad
function createDefenseSquad(spawnerId: number, defendPos: mod.Vector) {
  const defenders: mod.Player[] = [];

  for (let i = 0; i < 4; i++) {
    const spawner = mod.GetAISpawner(spawnerId);
    const ai = mod.SpawnAIFromAISpawner(spawner);

    // Set defend behavior
    mod.SetAIBehavior(ai, mod.AIBehavior.DefendLocation);

    // Configure defense area (20m radius)
    mod.SetAIDefendLocationDestination(ai, defendPos, 20);

    // Set stance for defense
    mod.SetAIStance(ai, mod.Stance.Crouch);

    defenders.push(ai);
  }

  return defenders;
}
```

### Idle

```typescript
SetAIBehavior(soldier: Player, behavior: AIBehavior.Idle): void
```

AI stands still and doesn't act.

**Use Cases:**
- NPCs in safe zones
- Training dummies
- Cutscene actors
- Waiting for triggers

**Example:**
```typescript
// Create training dummy
function createTrainingDummy(spawnerId: number) {
  const spawner = mod.GetAISpawner(spawnerId);
  const dummy = mod.SpawnAIFromAISpawner(spawner);

  // Set idle behavior
  mod.SetAIBehavior(dummy, mod.AIBehavior.Idle);

  // Disable all combat
  mod.SetAIShootingEnabled(dummy, false);
  mod.SetAIGrenadeEnabled(dummy, false);
  mod.SetAIMeleeEnabled(dummy, false);

  // Make invincible
  mod.SetPlayerIncomingDamageMultiplier(dummy, 0);

  return dummy;
}
```

### WaypointPatrol

```typescript
SetAIBehavior(soldier: Player, behavior: AIBehavior.WaypointPatrol): void
CreateWaypointPatrolPath(positions: Vector[], loop: boolean): WaypointPath
SetAIWaypointPath(soldier: Player, path: WaypointPath): void
```

Follow a patrol route through waypoints.

**Parameters:**
- `positions`: Array of waypoint positions
- `loop`: Whether to repeat the path

**Example:**
```typescript
// Create patrol route
function setupPatrol() {
  // Define waypoints
  const waypoints = [
    mod.CreateVector(100, 0, 100),
    mod.CreateVector(200, 0, 100),
    mod.CreateVector(200, 0, 200),
    mod.CreateVector(100, 0, 200)
  ];

  // Create looping path
  const patrolPath = mod.CreateWaypointPatrolPath(waypoints, true);

  // Spawn patrol AI
  const spawner = mod.GetAISpawner(1);
  const patroller = mod.SpawnAIFromAISpawner(spawner);

  // Set patrol behavior
  mod.SetAIBehavior(patroller, mod.AIBehavior.WaypointPatrol);
  mod.SetAIWaypointPath(patroller, patrolPath);

  // Configure patrol settings
  mod.SetAIMovementSpeed(patroller, mod.MovementSpeed.Walk);
  mod.SetAIShootingEnabled(patroller, true);  // Shoot while patrolling
}
```

### Parachute

```typescript
SetAIBehavior(soldier: Player, behavior: AIBehavior.Parachute): void
SetAIParachuteDestination(soldier: Player, position: Vector): void
```

Deploy parachute and land at target position.

**Parameters:**
- `position`: Landing zone

**Example:**
```typescript
// Paradrop reinforcements
async function paraDropSquad(dropZone: mod.Vector) {
  const dropHeight = 200;
  const squad: mod.Player[] = [];

  for (let i = 0; i < 6; i++) {
    // Spawn AI high in air
    const spawner = mod.GetAISpawner(10);  // Air spawner
    const ai = mod.SpawnAIFromAISpawner(spawner);

    // Position in air
    const dropPos = mod.Add(dropZone, mod.CreateVector(i * 10, dropHeight, 0));
    mod.Teleport(ai, dropPos, 0);

    // Set parachute behavior
    mod.SetAIBehavior(ai, mod.AIBehavior.Parachute);
    mod.SetAIParachuteDestination(ai, dropZone);

    squad.push(ai);
  }

  // Wait for landing
  await mod.Wait(15);

  // Switch to combat after landing
  for (const ai of squad) {
    mod.SetAIBehavior(ai, mod.AIBehavior.BattlefieldAI);
  }
}
```

### DefendPlayer

```typescript
SetAIBehavior(soldier: Player, behavior: AIBehavior.DefendPlayer): void
SetAIDefendPlayerTarget(soldier: Player, targetPlayer: Player): void
```

Follow and protect a specific player.

**Parameters:**
- `targetPlayer`: Player to defend

**Example:**
```typescript
// Assign bodyguard AI
function assignBodyguard(vip: mod.Player) {
  const spawner = mod.GetAISpawner(1);
  const bodyguard = mod.SpawnAIFromAISpawner(spawner);

  // Set defend player behavior
  mod.SetAIBehavior(bodyguard, mod.AIBehavior.DefendPlayer);
  mod.SetAIDefendPlayerTarget(bodyguard, vip);

  // Configure bodyguard
  mod.SetAIShootingEnabled(bodyguard, true);
  mod.SetAIDamageModifier(bodyguard, 1.5);  // 150% damage
  mod.SetPlayerMaxHealth(bodyguard, 150);    // Extra health

  // Notify VIP
  mod.DisplayCustomNotificationMessage(
    mod.Message("Bodyguard assigned"),
    mod.CustomNotificationSlots.MessageText1,
    3,
    vip
  );

  return bodyguard;
}
```

## Behavior Transitions

### Switching Behaviors

```typescript
// Dynamic behavior switching
async function aiStateMachine(ai: mod.Player) {
  let state = "patrol";

  while (mod.IsPlayerValid(ai)) {
    switch(state) {
      case "patrol":
        mod.SetAIBehavior(ai, mod.AIBehavior.WaypointPatrol);

        // Check for enemies
        if (enemiesNearby(ai)) {
          state = "combat";
        }
        break;

      case "combat":
        mod.SetAIBehavior(ai, mod.AIBehavior.BattlefieldAI);

        // Return to patrol when clear
        if (!enemiesNearby(ai)) {
          state = "patrol";
        }
        break;

      case "retreat":
        mod.SetAIBehavior(ai, mod.AIBehavior.MoveToLocation);
        const safeZone = getSafeZone();
        mod.SetAIMoveToLocationDestination(ai, safeZone);

        // Heal at safe zone
        if (atLocation(ai, safeZone)) {
          mod.SetPlayerHealth(ai, 100);
          state = "patrol";
        }
        break;
    }

    // Check health for retreat
    const health = mod.GetPlayerHealth(ai);
    if (health < 30 && state !== "retreat") {
      state = "retreat";
    }

    await mod.Wait(1);
  }
}
```

### Behavior Queueing

```typescript
// Queue multiple behaviors
async function executeBehaviorSequence(ai: mod.Player) {
  const behaviors = [
    { type: "move", target: mod.CreateVector(100, 0, 0) },
    { type: "defend", target: mod.CreateVector(100, 0, 0), duration: 30 },
    { type: "patrol", waypoints: getPatrolPath() }
  ];

  for (const behavior of behaviors) {
    switch(behavior.type) {
      case "move":
        mod.SetAIBehavior(ai, mod.AIBehavior.MoveToLocation);
        mod.SetAIMoveToLocationDestination(ai, behavior.target);
        await waitForArrival(ai, behavior.target);
        break;

      case "defend":
        mod.SetAIBehavior(ai, mod.AIBehavior.DefendLocation);
        mod.SetAIDefendLocationDestination(ai, behavior.target, 15);
        await mod.Wait(behavior.duration);
        break;

      case "patrol":
        mod.SetAIBehavior(ai, mod.AIBehavior.WaypointPatrol);
        mod.SetAIWaypointPath(ai, behavior.waypoints);
        break;
    }
  }
}
```

## Advanced Patterns

### Wave Defense System

```typescript
interface WaveConfig {
  count: number;
  behavior: mod.AIBehavior;
  difficulty: number;
}

const waves: WaveConfig[] = [
  { count: 5, behavior: mod.AIBehavior.MoveToLocation, difficulty: 0.5 },
  { count: 8, behavior: mod.AIBehavior.BattlefieldAI, difficulty: 0.75 },
  { count: 12, behavior: mod.AIBehavior.BattlefieldAI, difficulty: 1.0 }
];

async function runWaveDefense() {
  for (let i = 0; i < waves.length; i++) {
    const wave = waves[i];
    console.log(`Starting wave ${i + 1}`);

    const enemies: mod.Player[] = [];

    // Spawn wave
    for (let j = 0; j < wave.count; j++) {
      const spawner = mod.GetAISpawner(j % 5);  // Use 5 spawners
      const ai = mod.SpawnAIFromAISpawner(spawner);

      // Set behavior
      mod.SetAIBehavior(ai, wave.behavior);

      // Configure difficulty
      mod.SetAIDamageModifier(ai, wave.difficulty);
      mod.SetPlayerMaxHealth(ai, 100 * wave.difficulty);

      // Set target
      if (wave.behavior === mod.AIBehavior.MoveToLocation) {
        const objective = getObjectivePosition();
        mod.SetAIMoveToLocationDestination(ai, objective);
      }

      enemies.push(ai);
    }

    // Wait for wave completion
    while (enemies.some(ai => mod.IsPlayerValid(ai) && mod.IsPlayerAlive(ai))) {
      await mod.Wait(1);
    }

    console.log(`Wave ${i + 1} complete!`);
    await mod.Wait(10);  // Break between waves
  }
}
```

### Squad Coordination

```typescript
class AISquad {
  leader: mod.Player;
  members: mod.Player[];

  constructor(size: number, spawnerId: number) {
    this.members = [];

    // Spawn squad
    for (let i = 0; i < size; i++) {
      const spawner = mod.GetAISpawner(spawnerId);
      const ai = mod.SpawnAIFromAISpawner(spawner);

      if (i === 0) {
        this.leader = ai;
        mod.SetAIBehavior(ai, mod.AIBehavior.BattlefieldAI);
      } else {
        // Follow leader
        mod.SetAIBehavior(ai, mod.AIBehavior.DefendPlayer);
        mod.SetAIDefendPlayerTarget(ai, this.leader);
      }

      this.members.push(ai);
    }
  }

  moveToPosition(position: mod.Vector) {
    // Leader moves to position
    mod.SetAIBehavior(this.leader, mod.AIBehavior.MoveToLocation);
    mod.SetAIMoveToLocationDestination(this.leader, position);

    // Members continue following
  }

  defendArea(position: mod.Vector, radius: number) {
    // All defend the area
    for (const ai of this.members) {
      mod.SetAIBehavior(ai, mod.AIBehavior.DefendLocation);
      mod.SetAIDefendLocationDestination(ai, position, radius);
    }
  }

  attack() {
    // All switch to combat
    for (const ai of this.members) {
      mod.SetAIBehavior(ai, mod.AIBehavior.BattlefieldAI);
    }
  }
}
```

### Context-Aware Behavior

```typescript
function selectBehaviorByContext(ai: mod.Player): mod.AIBehavior {
  const health = mod.GetPlayerHealth(ai);
  const ammo = mod.GetPlayerAmmo(ai, mod.Slots.PrimaryWeapon);
  const enemies = countNearbyEnemies(ai, 50);
  const allies = countNearbyAllies(ai, 30);

  // Low health - retreat
  if (health < 25) {
    return mod.AIBehavior.MoveToLocation;  // To safe zone
  }

  // No ammo - idle or retreat
  if (ammo === 0) {
    return mod.AIBehavior.Idle;
  }

  // Outnumbered - defend
  if (enemies > allies * 2) {
    return mod.AIBehavior.DefendLocation;
  }

  // Advantage - attack
  if (allies > enemies) {
    return mod.AIBehavior.BattlefieldAI;
  }

  // Default - patrol
  return mod.AIBehavior.WaypointPatrol;
}

// Apply context-based behavior
async function updateAIBehaviors() {
  while (gameActive) {
    const aiSoldiers = getAISoldiers();

    for (const ai of aiSoldiers) {
      if (!mod.IsPlayerValid(ai)) continue;

      const behavior = selectBehaviorByContext(ai);
      const current = getCurrentBehavior(ai);

      if (behavior !== current) {
        console.log(`AI behavior change: ${current} -> ${behavior}`);
        mod.SetAIBehavior(ai, behavior);

        // Configure based on new behavior
        configureBehavior(ai, behavior);
      }
    }

    await mod.Wait(2);  // Update every 2 seconds
  }
}
```

## Performance Considerations

### AI Limits

```typescript
const MAX_AI_COUNT = 64;  // Platform dependent
let currentAICount = 0;

function canSpawnAI(): boolean {
  return currentAICount < MAX_AI_COUNT;
}

function spawnAI(spawnerId: number): mod.Player | null {
  if (!canSpawnAI()) {
    console.log("AI limit reached");
    return null;
  }

  const spawner = mod.GetAISpawner(spawnerId);
  const ai = mod.SpawnAIFromAISpawner(spawner);
  currentAICount++;

  return ai;
}

export async function OnPlayerDied(player: mod.Player) {
  if (isAI(player)) {
    currentAICount--;
  }
}
```

### Behavior Optimization

```typescript
// Cache expensive calculations
const behaviorCache = new Map<mod.Player, {
  behavior: mod.AIBehavior;
  timestamp: number;
}>();

function getCachedBehavior(ai: mod.Player): mod.AIBehavior | null {
  const cached = behaviorCache.get(ai);
  const now = Date.now();

  // Cache for 5 seconds
  if (cached && (now - cached.timestamp) < 5000) {
    return cached.behavior;
  }

  return null;
}

function setBehaviorWithCache(ai: mod.Player, behavior: mod.AIBehavior) {
  mod.SetAIBehavior(ai, behavior);
  behaviorCache.set(ai, {
    behavior,
    timestamp: Date.now()
  });
}
```

## Best Practices

### 1. Always Validate AI

```typescript
if (!mod.IsPlayerValid(ai)) {
  console.log("Invalid AI reference");
  return;
}
```

### 2. Clean Up AI on Death

```typescript
export async function OnPlayerDied(player: mod.Player) {
  if (isAI(player)) {
    // Clean up references
    removeFromSquad(player);
    clearBehaviorCache(player);

    // Despawn after delay
    await mod.Wait(5);
    mod.DespawnAI(player);
  }
}
```

### 3. Provide Clear Behavior Transitions

```typescript
async function transitionBehavior(ai: mod.Player, newBehavior: mod.AIBehavior) {
  // Stop current behavior cleanly
  mod.SetAIShootingEnabled(ai, false);

  // Brief pause
  await mod.Wait(0.5);

  // Set new behavior
  mod.SetAIBehavior(ai, newBehavior);

  // Re-enable appropriate actions
  if (newBehavior === mod.AIBehavior.BattlefieldAI) {
    mod.SetAIShootingEnabled(ai, true);
  }
}
```

### 4. Balance AI Difficulty

```typescript
function configureAIDifficulty(ai: mod.Player, difficulty: "easy" | "normal" | "hard") {
  const settings = {
    easy: { damage: 0.5, health: 75, accuracy: 0.6 },
    normal: { damage: 1.0, health: 100, accuracy: 0.8 },
    hard: { damage: 1.5, health: 125, accuracy: 1.0 }
  };

  const config = settings[difficulty];
  mod.SetAIDamageModifier(ai, config.damage);
  mod.SetPlayerMaxHealth(ai, config.health);
  // Accuracy controlled by other means
}
```

## Next Steps

- 📖 [AI Combat](/api/ai-combat) - Combat configuration
- 📖 [AI Overview](/api/ai-overview) - General AI system
- 📖 [Player State](/api/player-state) - AI state queries
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip AI Behavior Summary
- **7 behavior types** - From combat to patrol
- **Dynamic transitions** - Switch behaviors based on context
- **Squad coordination** - AI can work in groups
- **Performance limits** - Platform-specific AI caps
- **Always validate** - Check AI references before use
:::