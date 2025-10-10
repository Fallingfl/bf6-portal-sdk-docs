# AI Behavior Examples

AI configuration examples for different enemy types and behaviors.

---

## Basic Patrol AI

```typescript
export async function OnGameModeStarted() {
  // Create patrol waypoints
  const waypoints = [
    mod.CreateVector(100, 0, 100),
    mod.CreateVector(200, 0, 100),
    mod.CreateVector(200, 0, 200),
    mod.CreateVector(100, 0, 200)
  ];

  const patrolPath = mod.CreateWaypointPatrolPath(waypoints);

  // Spawn AI
  const ai = mod.SpawnAIFromAISpawner(mod.GetAISpawner(1));

  // Configure patrol behavior
  mod.AISetBehavior(ai, mod.AIBehaviors.WaypointPatrol);
  mod.AISetWaypointPatrolPath(ai, patrolPath);
  mod.AISetMoveSpeed(ai, mod.MoveSpeed.Walk);
  mod.AISetShootingEnabled(ai, true);
}
```

---

## Stationary Defender

```typescript
function spawnDefender(spawnerId: number, defendPos: mod.Vector) {
  const ai = mod.SpawnAIFromAISpawner(mod.GetAISpawner(spawnerId));

  // Set to defend location
  mod.AISetBehavior(ai, mod.AIBehaviors.DefendLocation);
  mod.AISetDefendLocation(ai, defendPos);

  // Aggressive stance
  mod.AISetStance(ai, mod.AIStance.Standing);
  mod.AISetShootingEnabled(ai, true);
  mod.AISetAccuracy(ai, 0.7);

  return ai;
}
```

---

## Aggressive Rusher

```typescript
function spawnRusher(spawnerId: number, targetPlayer: mod.Player) {
  const ai = mod.SpawnAIFromAISpawner(mod.GetAISpawner(spawnerId));

  // Chase player aggressively
  mod.AISetBehavior(ai, mod.AIBehaviors.BattlefieldAI);
  mod.AISetTarget(ai, targetPlayer);
  mod.AISetMoveSpeed(ai, mod.MoveSpeed.Sprint);
  mod.AISetShootingEnabled(ai, true);

  // High aggression
  mod.AISetAccuracy(ai, 0.8);
  mod.AISetDamageMultiplier(ai, 1.5); // Takes less damage

  return ai;
}
```

---

## Sniper AI

```typescript
function spawnSniper(spawnerId: number, overwatch Pos: mod.Vector) {
  const ai = mod.SpawnAIFromAISpawner(mod.GetAISpawner(spawnerId));

  // Position at vantage point
  mod.AISetBehavior(ai, mod.AIBehaviors.DefendLocation);
  mod.AISetDefendLocation(ai, overwatchPos);

  // Sniper configuration
  mod.AISetStance(ai, mod.AIStance.Prone);
  mod.AISetMoveSpeed(ai, mod.MoveSpeed.Prone);
  mod.AISetShootingEnabled(ai, true);
  mod.AISetAccuracy(ai, 0.95); // Very accurate
  mod.AISetFireRate(ai, 0.3);  // Slow fire rate

  // Give sniper rifle
  mod.AISetWeapon(ai, mod.Weapons.SWS_10);

  return ai;
}
```

---

## Mixed AI Squad

```typescript
function spawnSquad(leaderSpawnerId: number, followerIds: number[]) {
  // Spawn leader
  const leader = mod.SpawnAIFromAISpawner(mod.GetAISpawner(leaderSpawnerId));
  mod.AISetBehavior(leader, mod.AIBehaviors.BattlefieldAI);
  mod.AISetMoveSpeed(leader, mod.MoveSpeed.Normal);

  // Spawn followers
  const followers: mod.AI[] = [];

  for (const id of followerIds) {
    const follower = mod.SpawnAIFromAISpawner(mod.GetAISpawner(id));

    // Follow the leader
    mod.AISetBehavior(follower, mod.AIBehaviors.DefendPlayer);
    mod.AISetDefendPlayer(follower, leader);
    mod.AISetMoveSpeed(follower, mod.MoveSpeed.Normal);

    followers.push(follower);
  }

  return { leader, followers };
}
```

---

## Easy/Normal/Hard Difficulty

```typescript
function setAIDifficulty(ai: mod.AI, difficulty: 'easy' | 'normal' | 'hard') {
  switch (difficulty) {
    case 'easy':
      mod.AISetDamageMultiplier(ai, 0.5);  // Takes 2x damage
      mod.AISetAccuracy(ai, 0.3);           // 30% accuracy
      mod.AISetFireRate(ai, 0.5);           // Slow fire
      mod.AISetMoveSpeed(ai, mod.MoveSpeed.Walk);
      break;

    case 'normal':
      mod.AISetDamageMultiplier(ai, 1.0);
      mod.AISetAccuracy(ai, 0.6);
      mod.AISetFireRate(ai, 1.0);
      mod.AISetMoveSpeed(ai, mod.MoveSpeed.Normal);
      break;

    case 'hard':
      mod.AISetDamageMultiplier(ai, 2.0);  // Takes half damage
      mod.AISetAccuracy(ai, 0.9);           // 90% accuracy
      mod.AISetFireRate(ai, 1.5);           // Fast fire
      mod.AISetMoveSpeed(ai, mod.MoveSpeed.Sprint);
      break;
  }
}
```

---

## AI Respawn Manager

```typescript
interface AISpawnPoint {
  spawner: mod.AISpawner;
  behavior: mod.AIBehaviors;
  respawnTime: number;
  currentAI?: mod.AI;
}

const aiSpawnPoints: AISpawnPoint[] = [];

function registerAISpawnPoint(
  spawnerId: number,
  behavior: mod.AIBehaviors,
  respawnTime: number
) {
  aiSpawnPoints.push({
    spawner: mod.GetAISpawner(spawnerId),
    behavior,
    respawnTime,
    currentAI: undefined
  });
}

async function aiRespawnLoop() {
  while (true) {
    for (const spawnPoint of aiSpawnPoints) {
      if (!spawnPoint.currentAI || !mod.AIIsAlive(spawnPoint.currentAI)) {
        // AI dead or never spawned, wait and respawn
        if (spawnPoint.currentAI) {
          await mod.Wait(spawnPoint.respawnTime);
        }

        const ai = mod.SpawnAIFromAISpawner(spawnPoint.spawner);
        mod.AISetBehavior(ai, spawnPoint.behavior);
        mod.AISetShootingEnabled(ai, true);

        spawnPoint.currentAI = ai;
      }
    }

    await mod.Wait(1);
  }
}

// Usage
export async function OnGameModeStarted() {
  registerAISpawnPoint(1, mod.AIBehaviors.BattlefieldAI, 10);
  registerAISpawnPoint(2, mod.AIBehaviors.DefendLocation, 15);
  registerAISpawnPoint(3, mod.AIBehaviors.WaypointPatrol, 20);

  aiRespawnLoop();
}
```

---

## Dynamic AI Spawning

```typescript
const MAX_AI = 20;
let currentAICount = 0;

async function dynamicAISpawner() {
  while (true) {
    const players = modlib.ConvertArray(mod.AllPlayers());
    const targetAI = Math.min(players.length * 3, MAX_AI); // 3 AI per player

    if (currentAICount < targetAI) {
      // Spawn more AI
      const toSpawn = targetAI - currentAICount;

      for (let i = 0; i < toSpawn; i++) {
        spawnRandomAI();
        currentAICount++;
      }
    }

    await mod.Wait(5);
  }
}

function spawnRandomAI() {
  const spawnerId = Math.floor(Math.random() * 10) + 1;
  const ai = mod.SpawnAIFromAISpawner(mod.GetAISpawner(spawnerId));

  mod.AISetBehavior(ai, mod.AIBehaviors.BattlefieldAI);
  mod.AISetMoveSpeed(ai, mod.MoveSpeed.Normal);
  mod.AISetShootingEnabled(ai, true);

  // Track AI death
  trackAIDeath(ai);
}

async function trackAIDeath(ai: mod.AI) {
  while (mod.AIIsAlive(ai)) {
    await mod.Wait(1);
  }

  currentAICount--;
}
```

---

★ Insight ─────────────────────────────────────
**AI Behavior Design**
1. **Behavior Specialization** - Different AI behaviors (patrol, defend, rush) create varied encounters and tactical challenges
2. **Difficulty Scaling** - Adjust multiple parameters (accuracy, damage, speed) together for balanced difficulty tiers
3. **Respawn Management** - Track AI by spawner location to maintain spatial distribution and prevent clustering
─────────────────────────────────────────────────
