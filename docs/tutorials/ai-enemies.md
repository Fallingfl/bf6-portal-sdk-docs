# AI Enemies Setup

Add AI-controlled enemies to create co-op PvE experiences.

**Difficulty:** ★★★☆☆ | **Time:** 35 minutes

---

## What You'll Build

A co-op mode with:
- Spawning AI enemies
- AI patrol behaviors
- AI difficulty settings
- AI event handling

---

## Step 1: Spawn AI from Spawner

```typescript
export async function OnGameModeStarted() {
  // Get AI spawner (set ID in Godot)
  const aiSpawner = mod.GetAISpawner(1);

  // Spawn an AI soldier
  const ai = mod.SpawnAIFromAISpawner(aiSpawner);

  console.log(`AI spawned: ${ai}`);
}
```

---

## Step 2: Set AI Behavior

```typescript
export async function OnGameModeStarted() {
  const aiSpawner = mod.GetAISpawner(1);
  const ai = mod.SpawnAIFromAISpawner(aiSpawner);

  // Set behavior
  mod.AISetBehavior(ai, mod.AIBehaviors.BattlefieldAI);

  // Set movement speed
  mod.AISetMoveSpeed(ai, mod.MoveSpeed.Normal);

  // Enable shooting
  mod.AISetShootingEnabled(ai, true);
}
```

---

## Available AI Behaviors

```typescript
mod.AIBehaviors.BattlefieldAI    // Default combat AI
mod.AIBehaviors.MoveToLocation   // Move to specific point
mod.AIBehaviors.DefendLocation   // Guard an area
mod.AIBehaviors.Idle             // Stand still
mod.AIBehaviors.WaypointPatrol   // Patrol waypoints
mod.AIBehaviors.DefendPlayer     // Protect a player
mod.AIBehaviors.Parachute        // Parachute down
```

---

## Step 3: Create Patrol Route

```typescript
export async function OnGameModeStarted() {
  // Create waypoint path
  const waypoints = [
    mod.CreateVector(100, 0, 100),
    mod.CreateVector(200, 0, 100),
    mod.CreateVector(200, 0, 200),
    mod.CreateVector(100, 0, 200)
  ];

  const patrolPath = mod.CreateWaypointPatrolPath(waypoints);

  // Spawn AI and assign patrol
  const ai = mod.SpawnAIFromAISpawner(mod.GetAISpawner(1));
  mod.AISetBehavior(ai, mod.AIBehaviors.WaypointPatrol);
  mod.AISetWaypointPatrolPath(ai, patrolPath);
  mod.AISetMoveSpeed(ai, mod.MoveSpeed.Walk);
}
```

---

## Step 4: Spawn Multiple AI

```typescript
const spawnedAI: mod.AI[] = [];

export async function OnGameModeStarted() {
  // Spawn 10 AI enemies
  for (let i = 1; i <= 10; i++) {
    const spawner = mod.GetAISpawner(i);
    const ai = mod.SpawnAIFromAISpawner(spawner);

    mod.AISetBehavior(ai, mod.AIBehaviors.BattlefieldAI);
    mod.AISetMoveSpeed(ai, mod.MoveSpeed.Normal);
    mod.AISetShootingEnabled(ai, true);

    spawnedAI.push(ai);
  }

  console.log(`Spawned ${spawnedAI.length} AI enemies`);
}
```

---

## Step 5: Adjust AI Difficulty

```typescript
function setAIDifficulty(ai: mod.AI, difficulty: 'easy' | 'normal' | 'hard') {
  switch (difficulty) {
    case 'easy':
      mod.AISetDamageMultiplier(ai, 0.5);   // AI takes 2x damage
      mod.AISetAccuracy(ai, 0.3);            // 30% accuracy
      break;

    case 'normal':
      mod.AISetDamageMultiplier(ai, 1.0);
      mod.AISetAccuracy(ai, 0.6);
      break;

    case 'hard':
      mod.AISetDamageMultiplier(ai, 2.0);   // AI takes half damage
      mod.AISetAccuracy(ai, 0.9);            // 90% accuracy
      break;
  }
}
```

---

## Step 6: Respawn AI on Death

```typescript
const aiSpawners = new Map<mod.AI, mod.AISpawner>();

export async function OnGameModeStarted() {
  for (let i = 1; i <= 5; i++) {
    const spawner = mod.GetAISpawner(i);
    const ai = mod.SpawnAIFromAISpawner(spawner);

    aiSpawners.set(ai, spawner);

    mod.AISetBehavior(ai, mod.AIBehaviors.BattlefieldAI);
  }

  // Start respawn monitoring
  aiRespawnLoop();
}

async function aiRespawnLoop() {
  while (true) {
    for (const [ai, spawner] of aiSpawners.entries()) {
      if (!mod.AIIsAlive(ai)) {
        // AI died, respawn after delay
        await mod.Wait(10);

        const newAI = mod.SpawnAIFromAISpawner(spawner);
        mod.AISetBehavior(newAI, mod.AIBehaviors.BattlefieldAI);

        // Update map
        aiSpawners.delete(ai);
        aiSpawners.set(newAI, spawner);
      }
    }

    await mod.Wait(1);
  }
}
```

---

## Complete Co-op Example

```typescript
import * as mod from 'bf-portal-api';

const MAX_AI = 15;
const spawnedAI: mod.AI[] = [];

export async function OnGameModeStarted() {
  console.log("Co-op Mode Starting");

  // Spawn initial AI wave
  spawnAIWave();

  // Monitor and respawn
  aiManagementLoop();
}

function spawnAIWave() {
  for (let i = 1; i <= MAX_AI; i++) {
    const spawner = mod.GetAISpawner(i);
    const ai = mod.SpawnAIFromAISpawner(spawner);

    // Configure AI
    mod.AISetBehavior(ai, mod.AIBehaviors.BattlefieldAI);
    mod.AISetMoveSpeed(ai, mod.MoveSpeed.Normal);
    mod.AISetShootingEnabled(ai, true);
    mod.AISetDamageMultiplier(ai, 1.0);

    spawnedAI.push(ai);
  }
}

async function aiManagementLoop() {
  while (true) {
    // Count alive AI
    const aliveCount = spawnedAI.filter(ai => mod.AIIsAlive(ai)).length;

    // Respawn if below threshold
    if (aliveCount < MAX_AI / 2) {
      console.log(`Only ${aliveCount} AI alive, spawning more...`);
      spawnAIWave();
    }

    await mod.Wait(5);
  }
}
```

---

## Next Steps

- [Exfil Example](/examples/exfil) - Full PvE extraction mode
- [AI API Reference](/api/ai-overview)

---

★ Insight ─────────────────────────────────────
**AI Management**
1. **Stateless AI** - AI objects don't persist after death; must track spawners and respawn new instances
2. **Behavior-First** - Always set behavior immediately after spawning; default behavior is unpredictable
3. **Performance Scaling** - 15-20 AI is reasonable; 50+ can impact performance depending on behaviors
─────────────────────────────────────────────────
