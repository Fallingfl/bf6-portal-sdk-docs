# AI Combat

Functions for configuring AI combat behavior, targeting, and weapon usage.

## Overview

The AI combat system controls:
- Shooting and aiming
- Target selection
- Damage modifiers
- Grenade and melee usage
- Fire control

## Combat Control

### SetAIShootingEnabled

```typescript
SetAIShootingEnabled(soldier: Player, shootingEnabled: boolean): void
```

Enable or disable AI shooting ability.

**Example:**
```typescript
// Disable shooting for tutorial
export async function OnGameModeStarted() {
  const spawner = mod.GetAISpawner(1);
  const ai = mod.SpawnAIFromAISpawner(spawner);

  // Disable shooting
  mod.SetAIShootingEnabled(ai, false);

  // Re-enable after tutorial
  await mod.Wait(30);
  mod.SetAIShootingEnabled(ai, true);
}
```

### SetAIGrenadeEnabled

```typescript
SetAIGrenadeEnabled(soldier: Player, grenadeEnabled: boolean): void
```

Control AI grenade usage.

**Example:**
```typescript
// Configure grenade usage by difficulty
function setAIDifficulty(ai: mod.Player, difficulty: string) {
  switch(difficulty) {
    case "easy":
      mod.SetAIGrenadeEnabled(ai, false);  // No grenades
      break;
    case "normal":
      mod.SetAIGrenadeEnabled(ai, true);
      break;
    case "hard":
      mod.SetAIGrenadeEnabled(ai, true);
      // More aggressive grenade use via other settings
      break;
  }
}
```

### SetAIMeleeEnabled

```typescript
SetAIMeleeEnabled(soldier: Player, meleeEnabled: boolean): void
```

Enable or disable AI melee attacks.

**Example:**
```typescript
// Create melee-only zombies
function createZombie(spawnerId: number): mod.Player {
  const spawner = mod.GetAISpawner(spawnerId);
  const zombie = mod.SpawnAIFromAISpawner(spawner);

  // Melee only
  mod.SetAIShootingEnabled(zombie, false);
  mod.SetAIGrenadeEnabled(zombie, false);
  mod.SetAIMeleeEnabled(zombie, true);

  // Increase movement speed
  mod.SetAIMovementSpeed(zombie, mod.MovementSpeed.Sprint);

  return zombie;
}
```

## Target Management

### SetAITarget

```typescript
SetAITarget(soldier: Player, target: Player): void
```

Force AI to target a specific player.

**Example:**
```typescript
// Assign targets to AI squad
function assignTargets(aiSquad: mod.Player[], enemyTeam: mod.Team) {
  const enemies = modlib.ConvertArray(mod.GetPlayersInTeam(enemyTeam));

  aiSquad.forEach((ai, index) => {
    if (enemies[index]) {
      // Assign specific target
      mod.SetAITarget(ai, enemies[index]);
    }
  });
}

// VIP assassination mode
export async function OnPlayerJoinGame(player: mod.Player) {
  if (isVIP(player)) {
    // All enemy AI target the VIP
    const enemyAI = getEnemyAI();
    for (const ai of enemyAI) {
      mod.SetAITarget(ai, player);
    }
  }
}
```

### ClearAITarget

```typescript
ClearAITarget(soldier: Player): void
```

Remove forced target, return to normal targeting.

**Example:**
```typescript
// Clear targets after objective complete
function onObjectiveComplete() {
  const allAI = getAllAI();

  for (const ai of allAI) {
    // Clear forced targets
    mod.ClearAITarget(ai);

    // Return to normal combat
    mod.SetAIBehavior(ai, mod.AIBehavior.BattlefieldAI);
  }
}
```

### SetAIFocusPoint

```typescript
SetAIFocusPoint(soldier: Player, position: Vector): void
```

Make AI look at a specific position.

**Example:**
```typescript
// AI guards watch doorways
function setupGuards() {
  const doorwayPositions = [
    mod.CreateVector(100, 0, 50),
    mod.CreateVector(200, 0, 50)
  ];

  doorwayPositions.forEach((doorway, i) => {
    const spawner = mod.GetAISpawner(i + 1);
    const guard = mod.SpawnAIFromAISpawner(spawner);

    // Position guard
    const guardPos = mod.Subtract(doorway, mod.CreateVector(10, 0, 0));
    mod.Teleport(guard, guardPos, 0);

    // Watch doorway
    mod.SetAIFocusPoint(guard, doorway);
    mod.SetAIStance(guard, mod.Stance.Crouch);
  });
}
```

## Damage Configuration

### SetAIDamageModifier

```typescript
SetAIDamageModifier(soldier: Player, damageMultiplier: number): void
```

Adjust AI damage output (0.0 - 10.0).

**Example:**
```typescript
// Progressive difficulty scaling
let waveNumber = 0;

function spawnWave() {
  waveNumber++;

  for (let i = 0; i < 10; i++) {
    const spawner = mod.GetAISpawner(i % 5);
    const ai = mod.SpawnAIFromAISpawner(spawner);

    // Scale damage with wave number
    const damageMultiplier = Math.min(0.5 + (waveNumber * 0.1), 2.0);
    mod.SetAIDamageModifier(ai, damageMultiplier);

    console.log(`Wave ${waveNumber} AI damage: ${damageMultiplier * 100}%`);
  }
}
```

### SetPlayerIncomingDamageMultiplier

```typescript
SetPlayerIncomingDamageMultiplier(player: Player, multiplier: number): void
```

Adjust damage AI takes (works for AI soldiers too).

**Example:**
```typescript
// Boss enemy with high health
function spawnBoss() {
  const spawner = mod.GetAISpawner(99);  // Boss spawner
  const boss = mod.SpawnAIFromAISpawner(spawner);

  // Reduce incoming damage (5x health effectively)
  mod.SetPlayerIncomingDamageMultiplier(boss, 0.2);

  // Increase outgoing damage
  mod.SetAIDamageModifier(boss, 2.0);

  // Visual indicator
  mod.SetPlayerNametagMode(boss, mod.NameTagMode.ShowAll);

  return boss;
}
```

## Fire Control

### ForceAIFire

```typescript
ForceAIFire(soldier: Player, fire: boolean): void
```

Force AI to fire weapon continuously.

**Example:**
```typescript
// Suppressing fire
async function suppressArea(ai: mod.Player, targetPos: mod.Vector) {
  // Aim at position
  mod.SetAIFocusPoint(ai, targetPos);

  // Force continuous fire
  mod.ForceAIFire(ai, true);

  // Suppress for 5 seconds
  await mod.Wait(5);

  // Stop forced fire
  mod.ForceAIFire(ai, false);
}

// Turret simulation
function createTurret(spawnerId: number, fireArc: mod.Vector) {
  const spawner = mod.GetAISpawner(spawnerId);
  const turret = mod.SpawnAIFromAISpawner(spawner);

  // Lock in place
  mod.SetAIBehavior(turret, mod.AIBehavior.Idle);
  mod.SetAIStance(turret, mod.Stance.Prone);

  // Continuous fire at arc
  mod.SetAIFocusPoint(turret, fireArc);
  mod.ForceAIFire(turret, true);

  return turret;
}
```

## Combat Patterns

### Difficulty System

```typescript
interface DifficultySettings {
  damage: number;
  health: number;
  accuracy: number;
  reactions: number;
  grenades: boolean;
}

const difficultyPresets: Record<string, DifficultySettings> = {
  recruit: {
    damage: 0.5,
    health: 75,
    accuracy: 0.6,
    reactions: 0.5,
    grenades: false
  },
  regular: {
    damage: 1.0,
    health: 100,
    accuracy: 0.8,
    reactions: 1.0,
    grenades: true
  },
  veteran: {
    damage: 1.25,
    health: 125,
    accuracy: 0.9,
    reactions: 1.2,
    grenades: true
  },
  elite: {
    damage: 1.5,
    health: 150,
    accuracy: 1.0,
    reactions: 1.5,
    grenades: true
  }
};

function applyDifficulty(ai: mod.Player, difficulty: string) {
  const settings = difficultyPresets[difficulty];
  if (!settings) return;

  // Apply settings
  mod.SetAIDamageModifier(ai, settings.damage);
  mod.SetPlayerMaxHealth(ai, settings.health);
  mod.SetAIGrenadeEnabled(ai, settings.grenades);

  // Store for reference
  storeAIDifficulty(ai, difficulty);
}
```

### Aggression Levels

```typescript
// Dynamic aggression based on game state
async function updateAIAggression() {
  while (gameActive) {
    const scoreRatio = getScoreRatio();  // Winning/losing ratio
    const timeRemaining = getRemainingTime();

    const allAI = getAllAI();
    for (const ai of allAI) {
      let aggression = "normal";

      // Losing team gets more aggressive
      if (scoreRatio < 0.5) {
        aggression = "aggressive";
      }
      // End game push
      else if (timeRemaining < 60) {
        aggression = "very_aggressive";
      }

      applyAggressionLevel(ai, aggression);
    }

    await mod.Wait(10);
  }
}

function applyAggressionLevel(ai: mod.Player, level: string) {
  switch(level) {
    case "passive":
      mod.SetAIMovementSpeed(ai, mod.MovementSpeed.Walk);
      mod.SetAIDamageModifier(ai, 0.75);
      mod.SetAIGrenadeEnabled(ai, false);
      break;

    case "normal":
      mod.SetAIMovementSpeed(ai, mod.MovementSpeed.Run);
      mod.SetAIDamageModifier(ai, 1.0);
      mod.SetAIGrenadeEnabled(ai, true);
      break;

    case "aggressive":
      mod.SetAIMovementSpeed(ai, mod.MovementSpeed.Sprint);
      mod.SetAIDamageModifier(ai, 1.25);
      mod.SetAIGrenadeEnabled(ai, true);
      break;

    case "very_aggressive":
      mod.SetAIMovementSpeed(ai, mod.MovementSpeed.Sprint);
      mod.SetAIDamageModifier(ai, 1.5);
      mod.SetAIGrenadeEnabled(ai, true);
      // Force engagement
      const nearestEnemy = findNearestEnemy(ai);
      if (nearestEnemy) {
        mod.SetAITarget(ai, nearestEnemy);
      }
      break;
  }
}
```

### Squad Tactics

```typescript
// Coordinated squad combat
class CombatSquad {
  leader: mod.Player;
  members: mod.Player[];

  constructor(size: number) {
    this.members = [];
    // Spawn squad...
  }

  engageTarget(target: mod.Player) {
    // Leader focuses fire
    mod.SetAITarget(this.leader, target);

    // Squad provides covering fire
    const targetPos = mod.GetSoldierState(
      target,
      mod.SoldierStateVector.GetPosition
    );

    this.members.forEach((member, i) => {
      if (i % 2 === 0) {
        // Half target the player
        mod.SetAITarget(member, target);
      } else {
        // Half suppress area
        const suppressPos = mod.Add(
          targetPos,
          mod.CreateVector(Math.random() * 10 - 5, 0, Math.random() * 10 - 5)
        );
        mod.SetAIFocusPoint(member, suppressPos);
        mod.ForceAIFire(member, true);
      }
    });
  }

  throwGrenades(position: mod.Vector) {
    // Coordinated grenade attack
    this.members.forEach((member, i) => {
      setTimeout(() => {
        mod.SetAIFocusPoint(member, position);
        // AI will throw grenade if enabled
      }, i * 500);  // Stagger throws
    });
  }

  ceasefire() {
    // Stop all combat
    [...this.members, this.leader].forEach(ai => {
      mod.ClearAITarget(ai);
      mod.ForceAIFire(ai, false);
    });
  }
}
```

### Weapon Restrictions

```typescript
// Force specific weapon usage
async function configureAILoadout(ai: mod.Player, role: string) {
  switch(role) {
    case "sniper":
      // Long range only
      mod.SetAIWeapon(ai, mod.Weapons.SniperRifle_SWS10);
      mod.SetAIMeleeEnabled(ai, false);
      mod.SetAIGrenadeEnabled(ai, false);
      break;

    case "assault":
      mod.SetAIWeapon(ai, mod.Weapons.AssaultRifle_M5A3);
      mod.SetAIGrenadeEnabled(ai, true);
      mod.SetAIMeleeEnabled(ai, true);
      break;

    case "support":
      mod.SetAIWeapon(ai, mod.Weapons.LMG_PKP_BP);
      mod.SetAIGrenadeEnabled(ai, true);
      mod.SetAIMeleeEnabled(ai, false);
      break;
  }
}
```

## Combat Events

### Tracking AI Performance

```typescript
const aiStats = new Map<mod.Player, {
  kills: number;
  deaths: number;
  damage: number;
}>();

export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  if (isAI(killer)) {
    const stats = aiStats.get(killer) || { kills: 0, deaths: 0, damage: 0 };
    stats.kills++;
    aiStats.set(killer, stats);

    // Reward performing AI
    if (stats.kills >= 5) {
      // Upgrade AI
      mod.SetAIDamageModifier(killer, 1.5);
      console.log("AI promoted to elite!");
    }
  }
}

export async function OnPlayerDied(player: mod.Player) {
  if (isAI(player)) {
    const stats = aiStats.get(player) || { kills: 0, deaths: 0, damage: 0 };
    stats.deaths++;
    aiStats.set(player, stats);
  }
}
```

### Adaptive Difficulty

```typescript
// Adjust AI based on player performance
let playerDeathCount = 0;
let aiDifficultyModifier = 1.0;

export async function OnPlayerDied(player: mod.Player) {
  if (!isAI(player)) {
    playerDeathCount++;

    // Make AI easier if players struggling
    if (playerDeathCount > 10) {
      aiDifficultyModifier = Math.max(0.5, aiDifficultyModifier - 0.1);
      updateAllAIDifficulty();
    }
  }
}

function updateAllAIDifficulty() {
  const allAI = getAllAI();
  for (const ai of allAI) {
    mod.SetAIDamageModifier(ai, aiDifficultyModifier);
  }
  console.log(`AI difficulty adjusted to ${aiDifficultyModifier * 100}%`);
}
```

## Best Practices

### 1. Balance AI Difficulty

```typescript
// Provide clear difficulty options
const DIFFICULTY_OPTIONS = {
  easy: "For casual players",
  normal: "Balanced challenge",
  hard: "For experienced players",
  extreme: "Nearly impossible"
};
```

### 2. Clear Combat States

```typescript
function setAICombatState(ai: mod.Player, state: "passive" | "alert" | "combat") {
  switch(state) {
    case "passive":
      mod.SetAIShootingEnabled(ai, false);
      mod.ClearAITarget(ai);
      break;

    case "alert":
      mod.SetAIShootingEnabled(ai, false);
      // Look around but don't shoot
      break;

    case "combat":
      mod.SetAIShootingEnabled(ai, true);
      mod.SetAIGrenadeEnabled(ai, true);
      break;
  }
}
```

### 3. Performance Management

```typescript
// Limit active combat AI
const MAX_COMBAT_AI = 32;
let activeCombatAI = 0;

function enableAICombat(ai: mod.Player): boolean {
  if (activeCombatAI >= MAX_COMBAT_AI) {
    return false;
  }

  mod.SetAIShootingEnabled(ai, true);
  activeCombatAI++;
  return true;
}
```

### 4. Visual Feedback

```typescript
// Indicate AI threat level
function visualizeAIDifficulty(ai: mod.Player, difficulty: string) {
  const colors = {
    easy: mod.TeamColor.Green,
    normal: mod.TeamColor.Blue,
    hard: mod.TeamColor.Orange,
    elite: mod.TeamColor.Red
  };

  // Use team color as indicator
  const aiTeam = mod.GetTeam(ai);
  mod.SetTeamColor(aiTeam, colors[difficulty]);
}
```

## Next Steps

- 📖 [AI Behaviors](/api/ai-behaviors) - Behavior patterns
- 📖 [AI Overview](/api/ai-overview) - General AI system
- 📖 [Player Equipment](/api/player-equipment) - Weapon management
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip Combat Configuration Summary
- **Fine control** - Shooting, grenades, melee separately
- **Damage scaling** - Both dealt and received
- **Target management** - Force targets or auto-select
- **Fire control** - Forced fire for suppression
- **Difficulty presets** - Easy to implement scaling
:::