# AI System Overview

The BF6 Portal SDK provides a comprehensive AI system with 25+ functions for creating bot enemies, allies, and NPCs.

## Overview

The AI system enables:
- **7 behavior types** - From combat to patrol
- **Combat control** - Targeting, shooting, accuracy
- **Movement control** - Speed, stance, pathfinding
- **Spawning system** - Dynamic AI creation
- **Team assignment** - Friendly or enemy AI

## AI Fundamentals

### AI as Players

AI bots use the same `mod.Player` type as human players:

```typescript
// AI is just a Player with AI behavior
const aiPlayer: mod.Player = spawnedAI;

// Can use all player functions on AI
mod.SetTeam(aiPlayer, mod.Team.Team2);
mod.SetPlayerMaxHealth(aiPlayer, 150);
mod.AddEquipment(aiPlayer, mod.Weapons.AK24);
mod.Teleport(aiPlayer, position, 0);
```

### AI vs Human Detection

```typescript
// Check if player is AI
const isAI = mod.GetSoldierState(player, mod.SoldierStateBool.IsAI);

if (isAI) {
  console.log("This is an AI bot");
} else {
  console.log("This is a human player");
}
```

## AI Spawning

### SpawnAIFromAISpawner

Spawn AI from pre-placed spawner (8 overloads):

```typescript
// Basic spawn
SpawnAIFromAISpawner(spawner: Spawner): void

// With class
SpawnAIFromAISpawner(spawner: Spawner, classToSpawn: SoldierClass): void

// With name
SpawnAIFromAISpawner(spawner: Spawner, name: Message): void

// With team
SpawnAIFromAISpawner(spawner: Spawner, team: Team): void

// Full configuration
SpawnAIFromAISpawner(
  spawner: Spawner,
  classToSpawn: SoldierClass,
  name: Message,
  team: Team
): void
```

**Example: Basic AI Spawn**
```typescript
export async function OnGameModeStarted() {
  // Get AI spawner from Godot (Obj Id 100)
  const aiSpawner = mod.GetSpawner(100);

  if (!aiSpawner) {
    console.log("ERROR: AI spawner not found!");
    return;
  }

  // Spawn basic AI
  mod.SpawnAIFromAISpawner(aiSpawner);
}
```

**Example: Configured AI Spawn**
```typescript
function spawnEnemySquad() {
  const spawners = [100, 101, 102, 103];

  for (const spawnerId of spawners) {
    const spawner = mod.GetSpawner(spawnerId);
    if (!spawner) continue;

    mod.SpawnAIFromAISpawner(
      spawner,
      mod.SoldierClass.Assault,
      mod.Message("Enemy Soldier"),
      mod.Team.Team2
    );
  }

  console.log("Enemy squad spawned!");
}
```

### UnspawnAllAIsFromAISpawner

Remove all AI from specific spawner:

```typescript
UnspawnAllAIsFromAISpawner(spawner: Spawner): void
```

**Example: Wave System**
```typescript
async function waveSystem() {
  const spawner = mod.GetSpawner(100);
  let waveNumber = 0;

  while (gameRunning) {
    waveNumber++;

    // Spawn wave
    console.log(`Starting wave ${waveNumber}`);
    for (let i = 0; i < 5 * waveNumber; i++) {
      mod.SpawnAIFromAISpawner(spawner, mod.Team.Team2);
      await mod.Wait(0.5);
    }

    // Wait for wave to be defeated
    await mod.Wait(60);

    // Clear remaining AI
    mod.UnspawnAllAIsFromAISpawner(spawner);

    // Wave break
    await mod.Wait(10);
  }
}
```

## AI Behaviors

### Combat AI

```typescript
AIBattlefieldBehavior(player: Player): void
```

Standard combat AI that acts independently:

```typescript
function spawnCombatAI() {
  const spawner = mod.GetSpawner(100);
  mod.SpawnAIFromAISpawner(spawner);

  // Set to combat behavior (fights independently)
  mod.AIBattlefieldBehavior(aiPlayer);

  // Enable shooting
  mod.AIEnableShooting(aiPlayer, true);
  mod.AIEnableTargeting(aiPlayer, true);
}
```

### Movement Behaviors

```typescript
// Move to specific location
AIMoveToBehavior(player: Player, position: Vector): void

// Move with line of sight check
AILOSMoveToBehavior(player: Player, position: Vector): void

// Move to valid navmesh position
AIValidatedMoveToBehavior(player: Player, position: Vector): void
```

**Example: Ordered Movement**
```typescript
async function moveAISquad(targetPos: mod.Vector) {
  const aiSquad = getAISquad();

  for (const ai of aiSquad) {
    // Move with pathfinding
    mod.AIMoveToBehavior(ai, targetPos);

    // Stagger movement
    await mod.Wait(0.5);
  }
}
```

### Defensive Behaviors

```typescript
// Defend a position
AIDefendPositionBehavior(
  player: Player,
  defendPosition: Vector,
  minDistance: number,
  maxDistance: number
): void

// Defend a player
// Note: DefendPlayer behavior exists in enum but no direct function
```

**Example: Guard Posts**
```typescript
function setupGuardPosts() {
  const guardPosts = [
    { spawner: 100, position: mod.CreateVector(100, 0, 50) },
    { spawner: 101, position: mod.CreateVector(200, 0, 50) },
    { spawner: 102, position: mod.CreateVector(300, 0, 50) }
  ];

  for (const post of guardPosts) {
    const spawner = mod.GetSpawner(post.spawner);
    mod.SpawnAIFromAISpawner(spawner, mod.Team.Team2);

    // Defend within 5-20 meter radius
    mod.AIDefendPositionBehavior(aiPlayer, post.position, 5, 20);
  }
}
```

### Idle Behavior

```typescript
AIIdleBehavior(player: Player): void
```

AI stays at current position:

```typescript
// Make AI stop and stay
mod.AIIdleBehavior(aiPlayer);
```

### Patrol Behavior

```typescript
AIWaypointIdleBehavior(player: Player, waypointPath: WaypointPath): void
```

AI patrols waypoint path:

```typescript
function createPatrol() {
  // Define waypoints
  const waypoints = [
    mod.CreateVector(100, 0, 50),
    mod.CreateVector(200, 0, 50),
    mod.CreateVector(200, 0, 150),
    mod.CreateVector(100, 0, 150)
  ];

  // Create path
  const patrolPath = mod.CreateWaypointPatrolPath(waypoints);

  // Spawn AI
  const spawner = mod.GetSpawner(100);
  mod.SpawnAIFromAISpawner(spawner);

  // Set patrol behavior
  mod.AIWaypointIdleBehavior(aiPlayer, patrolPath);
}
```

### Special Behaviors

```typescript
// Parachute behavior
AIParachuteBehavior(player: Player): void
```

**Example: Airborne AI**
```typescript
function spawnParatroopers() {
  const dropPosition = mod.CreateVector(500, 500, 300);  // High altitude

  // Spawn AI at height
  const aiPlayer = spawnAIAtPosition(dropPosition);

  // Enable parachute
  mod.AIParachuteBehavior(aiPlayer);

  // After landing, switch to combat
  setTimeout(() => {
    mod.AIBattlefieldBehavior(aiPlayer);
  }, 10000);  // 10 seconds
}
```

## Combat Control

### Shooting Control

```typescript
// Enable/disable shooting
AIEnableShooting(player: Player): void
AIEnableShooting(player: Player, enable: boolean): void

// Force AI to fire
AIForceFire(player: Player, fireDuration: number): void
```

**Example: Suppression Fire**
```typescript
function suppressionFire(aiPlayer: mod.Player) {
  // Force continuous fire for 3 seconds
  mod.AIForceFire(aiPlayer, 3.0);

  // After suppression, return to normal
  setTimeout(() => {
    mod.AIEnableShooting(aiPlayer, true);
  }, 3000);
}
```

### Targeting

```typescript
// Enable/disable targeting
AIEnableTargeting(player: Player): void
AIEnableTargeting(player: Player, enable: boolean): void

// Set specific target
AISetTarget(aiPlayer: Player, targetPlayer: Player): void
AISetTarget(player: Player): void  // Clear target

// Set focus point
AISetFocusPoint(player: Player, point: Vector, isTarget: boolean): void
```

**Example: Priority Targeting**
```typescript
function setPriorityTarget(aiSquad: mod.Player[], vipTarget: mod.Player) {
  for (const ai of aiSquad) {
    // All AI target the VIP
    mod.AISetTarget(ai, vipTarget);
    mod.AIEnableShooting(ai, true);
  }
}
```

## Movement Control

### Move Speed

```typescript
AISetMoveSpeed(player: Player, moveSpeed: MoveSpeed): void
```

**Speed Options:**
```typescript
mod.MoveSpeed.InvestigateRun
mod.MoveSpeed.InvestigateSlowWalk
mod.MoveSpeed.InvestigateWalk
mod.MoveSpeed.Patrol
mod.MoveSpeed.Run
mod.MoveSpeed.Sprint
mod.MoveSpeed.Walk
```

**Example: Dynamic Speed**
```typescript
function updateAISpeed(ai: mod.Player, distance: number) {
  if (distance < 10) {
    // Close - walk carefully
    mod.AISetMoveSpeed(ai, mod.MoveSpeed.Walk);
  } else if (distance < 50) {
    // Medium - run
    mod.AISetMoveSpeed(ai, mod.MoveSpeed.Run);
  } else {
    // Far - sprint
    mod.AISetMoveSpeed(ai, mod.MoveSpeed.Sprint);
  }
}
```

### Stance Control

```typescript
AISetStance(player: Player, stance: Stance): void
```

**Example: Tactical Movement**
```typescript
function setTacticalStance(ai: mod.Player, inCombat: boolean) {
  if (inCombat) {
    mod.AISetStance(ai, mod.Stance.Crouch);
  } else {
    mod.AISetStance(ai, mod.Stance.Stand);
  }
}
```

## AI Configuration

### Damage Modifiers

```typescript
// Global AI damage to humans
SetAIToHumanDamageModifier(damageMultiplier: number): void
```

**Example: Difficulty Levels**
```typescript
function setDifficulty(level: string) {
  switch (level) {
    case 'easy':
      mod.SetAIToHumanDamageModifier(0.5);   // AI does 50% damage
      break;
    case 'normal':
      mod.SetAIToHumanDamageModifier(1.0);   // Normal damage
      break;
    case 'hard':
      mod.SetAIToHumanDamageModifier(1.5);   // AI does 150% damage
      break;
    case 'nightmare':
      mod.SetAIToHumanDamageModifier(2.0);   // AI does 200% damage
      break;
  }
}
```

### Spawner Configuration

```typescript
// Auto-unspawn dead AI
AISetUnspawnOnDead(spawner: Spawner, enableUnspawnOnDead: boolean): void

// Set unspawn delay
SetUnspawnDelayInSeconds(spawner: Spawner, delay: number): void
```

**Example: Cleanup System**
```typescript
function configureAISpawner(spawnerId: number) {
  const spawner = mod.GetSpawner(spawnerId);

  // Auto-remove dead AI after 10 seconds
  mod.AISetUnspawnOnDead(spawner, true);
  mod.SetUnspawnDelayInSeconds(spawner, 10);
}
```

## Gadget Usage

### AI Gadgets

```typescript
// Start using gadget
AIStartUsingGadget(player: Player, gadget: OpenGadgets, targetPos: Vector): void
AIStartUsingGadget(player: Player, gadget: OpenGadgets, targetPlayer: Player): void

// Stop using gadget
AIStopUsingGadget(player: Player): void

// Configure gadget behavior
AIGadgetSettings(
  player: Player,
  applyUsageCriteria: boolean,
  applyCoolDownAfterUse: boolean,
  applyInaccuracy: boolean
): void
```

**Example: AI Medic**
```typescript
function createAIMedic() {
  const spawner = mod.GetSpawner(100);
  mod.SpawnAIFromAISpawner(
    spawner,
    mod.SoldierClass.Support,
    mod.Message("AI Medic"),
    mod.Team.Team1
  );

  // Give medkit
  mod.AddEquipment(aiMedic, mod.Gadgets.Class_Medkit);

  // Configure gadget use
  mod.AIGadgetSettings(
    aiMedic,
    true,   // Use when appropriate
    true,   // Cooldown after use
    false   // No inaccuracy
  );

  // Heal nearby players
  async function medicBehavior() {
    while (mod.IsPlayerValid(aiMedic)) {
      const nearbyPlayers = findNearbyWoundedPlayers(aiMedic);

      if (nearbyPlayers.length > 0) {
        const target = nearbyPlayers[0];
        mod.AIStartUsingGadget(aiMedic, mod.OpenGadgets.Medkit, target);
      }

      await mod.Wait(2);
    }
  }

  medicBehavior();
}
```

## AI Squad System

```typescript
interface AISquad {
  leader: mod.Player;
  members: mod.Player[];
  objective: mod.Vector;
}

let aiSquads: AISquad[] = [];

function createAISquad(size: number, team: mod.Team): AISquad {
  const members: mod.Player[] = [];

  // Spawn squad members
  for (let i = 0; i < size; i++) {
    const spawner = mod.GetSpawner(100 + i);
    mod.SpawnAIFromAISpawner(
      spawner,
      mod.SoldierClass.Assault,
      mod.Message(`Squad Member ${i + 1}`),
      team
    );

    members.push(spawnedAI);
  }

  const squad: AISquad = {
    leader: members[0],
    members: members,
    objective: mod.CreateVector(0, 0, 0)
  };

  aiSquads.push(squad);
  return squad;
}

function commandSquad(squad: AISquad, objective: mod.Vector) {
  squad.objective = objective;

  // Leader moves first
  mod.AIMoveToBehavior(squad.leader, objective);

  // Members follow with offset
  for (let i = 1; i < squad.members.length; i++) {
    const offset = mod.CreateVector(i * 5, 0, 0);
    const position = mod.Add(objective, offset);
    mod.AIMoveToBehavior(squad.members[i], position);
  }
}
```

## AI Difficulty Scaling

```typescript
interface DifficultySettings {
  damageModifier: number;
  healthModifier: number;
  accuracyModifier: number;
  reactionTime: number;
  moveSpeed: mod.MoveSpeed;
}

const difficultyPresets: { [key: string]: DifficultySettings } = {
  easy: {
    damageModifier: 0.5,
    healthModifier: 0.75,
    accuracyModifier: 0.5,
    reactionTime: 2.0,
    moveSpeed: mod.MoveSpeed.Walk
  },
  normal: {
    damageModifier: 1.0,
    healthModifier: 1.0,
    accuracyModifier: 0.75,
    reactionTime: 1.0,
    moveSpeed: mod.MoveSpeed.Run
  },
  hard: {
    damageModifier: 1.5,
    healthModifier: 1.25,
    accuracyModifier: 0.9,
    reactionTime: 0.5,
    moveSpeed: mod.MoveSpeed.Sprint
  }
};

function applyDifficulty(ai: mod.Player, difficulty: string) {
  const settings = difficultyPresets[difficulty];

  // Apply health modifier
  const baseHealth = 100;
  mod.SetPlayerMaxHealth(ai, baseHealth * settings.healthModifier);

  // Apply damage modifiers
  mod.SetPlayerIncomingDamageMultiplier(ai, 1 / settings.healthModifier);
  mod.SetPlayerOutgoingDamageMultiplier(ai, settings.damageModifier);

  // Apply move speed
  mod.AISetMoveSpeed(ai, settings.moveSpeed);

  // Apply reaction time (delay before targeting)
  setTimeout(() => {
    mod.AIEnableTargeting(ai, true);
  }, settings.reactionTime * 1000);
}
```

## Common AI Patterns

### Wave Defense

```typescript
async function waveDefense() {
  let wave = 0;

  while (gameRunning) {
    wave++;
    const enemyCount = 5 + (wave * 2);

    console.log(`Wave ${wave}: ${enemyCount} enemies`);

    // Spawn enemies
    for (let i = 0; i < enemyCount; i++) {
      const spawnerId = 100 + (i % 5);  // Use 5 spawners
      const spawner = mod.GetSpawner(spawnerId);

      mod.SpawnAIFromAISpawner(
        spawner,
        mod.SoldierClass.Assault,
        mod.Message(`Enemy ${i + 1}`),
        mod.Team.Team2
      );

      await mod.Wait(0.5);  // Stagger spawns
    }

    // Wait for wave completion
    await waitForWaveDefeat();

    // Wave complete bonus
    awardWaveBonus(wave);

    // Inter-wave break
    await mod.Wait(15);
  }
}
```

### AI Reinforcements

```typescript
async function callReinforcements(position: mod.Vector) {
  console.log("Reinforcements incoming!");

  // Spawn reinforcements at edges
  const spawnPoints = [
    mod.CreateVector(position.x + 100, position.y, position.z),
    mod.CreateVector(position.x - 100, position.y, position.z),
    mod.CreateVector(position.x, position.y + 100, position.z),
    mod.CreateVector(position.x, position.y - 100, position.z)
  ];

  for (const spawnPos of spawnPoints) {
    const ai = spawnAIAtPosition(spawnPos);

    // Move to conflict zone
    mod.AIMoveToBehavior(ai, position);
    mod.AISetMoveSpeed(ai, mod.MoveSpeed.Sprint);

    await mod.Wait(1);
  }
}
```

## Best Practices

### 1. Validate Spawners

```typescript
const spawner = mod.GetSpawner(100);
if (!spawner) {
  console.log("ERROR: AI spawner not found!");
  return;
}
```

### 2. Clean Up AI

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  // If last human player leaves, clear AI
  const humanPlayers = getHumanPlayers();

  if (humanPlayers.length === 0) {
    for (const spawner of aiSpawners) {
      mod.UnspawnAllAIsFromAISpawner(spawner);
    }
  }
}
```

### 3. Balance AI Count

```typescript
function maintainAIBalance() {
  const maxAI = 20;
  const currentAI = getAICount();

  if (currentAI >= maxAI) {
    console.log("AI limit reached");
    return false;
  }

  return true;
}
```

## Next Steps

- 📖 [AI Behaviors](/api/ai-behaviors) - Detailed behavior documentation
- 📖 [AI Combat](/api/ai-combat) - Combat system details
- 📖 [Player Control](/api/player-control) - AI uses player functions
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip AI System Summary
- **25+ AI functions** for complete bot control
- **7 behavior types** - Combat, patrol, defend, etc.
- **AI are Players** - Use all player functions on AI
- **Combat control** - Targeting, shooting, accuracy
- **Patrol system** - Waypoint-based movement
:::