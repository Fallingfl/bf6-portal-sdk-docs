# Custom Spawning Logic

Control where and when players spawn with custom spawn point selection.

**Difficulty:** ★★★☆☆ | **Time:** 25 minutes

---

## What You'll Learn

- Dynamic spawn point selection
- Team-based spawning
- Wave-based spawning systems
- Spawn protection

---

## Basic Custom Spawning

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Get all spawner objects (set IDs in Godot)
  const spawners = [
    mod.GetSpawner(1),
    mod.GetSpawner(2),
    mod.GetSpawner(3)
  ];

  // Select random spawner
  const randomSpawner = spawners[Math.floor(Math.random() * spawners.length)];

  // Get spawn location
  const transform = mod.GetSpawnerTransform(randomSpawner);

  // Teleport player
  mod.TeleportPlayer(player, transform.position, transform.rotation);

  // Give equipment
  mod.AddEquipment(player, mod.Weapons.M5A3, 1);
}
```

---

## Team-Based Spawning

```typescript
const team1Spawners = [mod.GetSpawner(1), mod.GetSpawner(2)];
const team2Spawners = [mod.GetSpawner(3), mod.GetSpawner(4)];

export async function OnPlayerDeployed(player: mod.Player) {
  const team = mod.GetTeam(player);
  const spawners = team === mod.Team.Team1 ? team1Spawners : team2Spawners;

  const spawner = spawners[Math.floor(Math.random() * spawners.length)];
  const transform = mod.GetSpawnerTransform(spawner);

  mod.TeleportPlayer(player, transform.position, transform.rotation);
}
```

---

## Wave-Based Spawning

```typescript
let waveActive = false;
const waitingPlayers: mod.Player[] = [];

export async function OnPlayerDied(player: mod.Player) {
  waitingPlayers.push(player);

  if (!waveActive) {
    startWaveTimer();
  }
}

async function startWaveTimer() {
  waveActive = true;
  await mod.Wait(10); // 10 second wave timer

  // Respawn all waiting players
  for (const player of waitingPlayers) {
    mod.Revive(player);
    mod.DeployPlayer(player);
  }

  waitingPlayers.length = 0;
  waveActive = false;
}
```

---

## Spawn Protection

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Make invulnerable
  mod.SetDamageReductionModifier(player, 0);

  // Show indicator
  mod.DisplayCustomNotificationMessage(
    mod.Message("Spawn Protection: 3s"),
    mod.CustomNotificationSlots.MessageText1,
    3,
    player
  );

  await mod.Wait(3);

  // Remove protection
  mod.SetDamageReductionModifier(player, 1);
}
```

---

## Next Steps

- [AI Enemies Setup](/tutorials/ai-enemies)
- [Round-Based Systems](/tutorials/round-based)
- [Player Spawning API](/api/player-spawning)

---

★ Insight ─────────────────────────────────────
**Spawn Control Patterns**
1. **Decouple Spawn from Deploy** - `OnPlayerDeployed` fires before player appears; use `TeleportPlayer` immediately to override default spawn
2. **Wave Spawning** - Batch respawns prevent staggered player trickle and create coordinated team pushes
3. **Damage Modifiers** - Setting reduction to 0 = invulnerable, 1 = normal, >1 = increased damage taken
─────────────────────────────────────────────────
