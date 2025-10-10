# Performance Optimization

Optimize your game mode for smooth performance with 64-player servers.

**Difficulty:** ★★★★☆ | **Time:** 35 minutes

---

## What You'll Learn

- Async loop best practices
- Caching and avoiding redundant API calls
- UI update batching
- Memory management

---

## Async Loop Optimization

**❌ Bad: Blocking Loop**

```typescript
// DON'T DO THIS - Blocks game loop
while (true) {
  checkSomething();
  // No await = infinite loop crashes server
}
```

**✅ Good: Non-Blocking Loop**

```typescript
// DO THIS - Yields control
while (true) {
  checkSomething();
  await mod.Wait(0.1); // Check 10 times per second
}
```

---

## Update Frequency Tuning

Different systems need different update rates:

```typescript
// Critical: 10 Hz (0.1s)
async function checkpointLoop() {
  while (true) {
    checkCheckpoints();
    await mod.Wait(0.1);
  }
}

// UI Updates: 2 Hz (0.5s)
async function updateScoreboard() {
  while (true) {
    refreshScoreboard();
    await mod.Wait(0.5);
  }
}

// Background Tasks: 0.5 Hz (2s)
async function cleanupLoop() {
  while (true) {
    cleanupDeadObjects();
    await mod.Wait(2);
  }
}
```

---

## Cache Expensive Calls

**❌ Bad: Repeated Calls**

```typescript
for (const player of players) {
  const pos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
  const health = mod.GetPlayerHealth(player);
  const name = mod.GetPlayerName(player);

  // Same calls repeated in loop
  if (distance(pos, targetPos) < 10) {
    // Do something
  }
}
```

**✅ Good: Cache Results**

```typescript
// Cache player data once
const playerData = players.map(player => ({
  player,
  position: mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition),
  health: mod.GetPlayerHealth(player),
  name: mod.GetPlayerName(player)
}));

// Use cached data
for (const data of playerData) {
  if (distance(data.position, targetPos) < 10) {
    // Do something
  }
}
```

---

## Batch UI Updates

**❌ Bad: Update Every Frame**

```typescript
async function healthRegenLoop(player: mod.Player) {
  while (mod.IsAlive(player)) {
    const health = mod.GetPlayerHealth(player);
    mod.SetPlayerHealth(player, health + 1);

    // Updates UI widget every 0.1s
    updateHealthUI(player, health + 1);

    await mod.Wait(0.1);
  }
}
```

**✅ Good: Update UI Less Frequently**

```typescript
async function healthRegenLoop(player: mod.Player) {
  let frameCount = 0;

  while (mod.IsAlive(player)) {
    const health = mod.GetPlayerHealth(player);
    mod.SetPlayerHealth(player, health + 1);

    frameCount++;

    // Update UI every 5th frame (0.5s)
    if (frameCount % 5 === 0) {
      updateHealthUI(player, health + 1);
    }

    await mod.Wait(0.1);
  }
}
```

---

## Avoid Redundant Calculations

**❌ Bad: Recalculate Every Time**

```typescript
function isInRange(player: mod.Player, target: mod.Vector): boolean {
  const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
  const dx = target.x - playerPos.x;
  const dy = target.y - playerPos.y;
  const dz = target.z - playerPos.z;
  const distance = Math.sqrt(dx * dx + dy * dy + dz * dz);
  return distance < 10;
}

// Called multiple times per frame
if (isInRange(player, pos1)) { }
if (isInRange(player, pos2)) { }
if (isInRange(player, pos3)) { }
```

**✅ Good: Cache Position**

```typescript
const playerPositions = new Map<mod.Player, mod.Vector>();

// Update once per frame
async function updatePositionCache() {
  while (true) {
    for (const player of players) {
      const pos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
      playerPositions.set(player, pos);
    }
    await mod.Wait(0.1);
  }
}

function isInRange(player: mod.Player, target: mod.Vector): boolean {
  const playerPos = playerPositions.get(player);
  if (!playerPos) return false;

  const dx = target.x - playerPos.x;
  const dy = target.y - playerPos.y;
  const dz = target.z - playerPos.z;
  const distance = Math.sqrt(dx * dx + dy * dy + dz * dz);
  return distance < 10;
}
```

---

## Memory Management

**Clean up on disconnect:**

```typescript
const playerData = new Map<mod.Player, any>();

export async function OnPlayerLeaveGame(playerId: string) {
  // Clean up Maps
  for (const [player, data] of playerData.entries()) {
    if (mod.GetPlayerId(player) === playerId) {
      playerData.delete(player);
      break;
    }
  }
}
```

---

## Profiling

Add timing logs to identify bottlenecks:

```typescript
async function expensiveOperation() {
  const startTime = Date.now();

  // ... operation ...

  const endTime = Date.now();
  console.log(`Operation took ${endTime - startTime}ms`);
}
```

---

## Best Practices Summary

✅ **Always use `await mod.Wait()` in loops**
✅ **Cache API results when called multiple times**
✅ **Batch UI updates (0.5-1s intervals)**
✅ **Tune update frequency per system**
✅ **Clean up Maps/arrays on player disconnect**
✅ **Profile slow operations**

❌ **Don't poll faster than needed**
❌ **Don't update UI every frame**
❌ **Don't recalculate same values repeatedly**

---

★ Insight ─────────────────────────────────────
**Performance Patterns**
1. **Update Rate Hierarchy** - Critical gameplay (checkpoints) runs at 10 Hz, UI at 2 Hz, background tasks at 0.5 Hz
2. **Batch Read Operations** - Cache player states once per frame, avoid per-player API calls in tight loops
3. **Memory Leaks** - Player objects persist after disconnect in Maps; must clean up by playerId string comparison
─────────────────────────────────────────────────
