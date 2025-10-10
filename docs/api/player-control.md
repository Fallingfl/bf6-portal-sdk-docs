# Player Control API

Control player movement, health, visibility, and restrictions. This is the largest API category with **120+ functions**.

## Movement Control

### Teleport

Instantly move a player to a new position.

```typescript
function Teleport(
  player: mod.Player,
  destination: mod.Vector,
  orientation: number
): void
```

**Parameters:**
- `player` - The player to teleport
- `destination` - Target position as Vector (x, y, z)
- `orientation` - Rotation in degrees (0-360)

**Example:**

```typescript
// Teleport player to coordinates
const pos = new mod.Vector(100, 50, 200);
mod.Teleport(player, pos, 90);  // Face east (90°)

// Teleport to another player's position
const targetTransform = mod.GetPlayerTransform(targetPlayer);
mod.Teleport(player, targetTransform.position, 0);

// Teleport to checkpoint
export async function OnPlayerDeployed(player: mod.Player) {
  const spawner = mod.GetSpawner(1);
  const spawnerPos = mod.GetSpawnerPosition(spawner);
  mod.Teleport(player, spawnerPos, 0);
}
```

::: tip Orientation Guide
- `0°` = North
- `90°` = East
- `180°` = South
- `270°` = West
:::

---

### SetMovementSpeedScale

Modify player movement speed.

```typescript
function SetMovementSpeedScale(
  player: mod.Player,
  scale: number
): void
```

**Parameters:**
- `player` - The player to modify
- `scale` - Speed multiplier (1.0 = normal, 2.0 = 2x speed, 0.5 = half speed)

**Example:**

```typescript
// Double speed power-up
mod.SetMovementSpeedScale(player, 2.0);

// Slow player (50% speed)
mod.SetMovementSpeedScale(player, 0.5);

// Reset to normal
mod.SetMovementSpeedScale(player, 1.0);

// Timed speed boost
export async function giveSpeedBoost(player: mod.Player, duration: number) {
  mod.SetMovementSpeedScale(player, 1.5);

  modlib.DisplayCustomNotificationMessage(
    "Speed Boost Activated!",
    mod.NotificationSlot.MessageText1,
    3,
    player
  );

  await mod.Wait(duration);
  mod.SetMovementSpeedScale(player, 1.0);

  modlib.DisplayCustomNotificationMessage(
    "Speed Boost Expired",
    mod.NotificationSlot.MessageText1,
    2,
    player
  );
}
```

::: warning Performance Note
Values above 3.0 may cause physics issues or allow players to clip through walls!
:::

---

### SetSprintSpeedScale

Modify sprint speed separately from walk speed.

```typescript
function SetSprintSpeedScale(
  player: mod.Player,
  scale: number
): void
```

**Example:**

```typescript
// Allow super sprint but normal walk
mod.SetMovementSpeedScale(player, 1.0);   // Normal walk
mod.SetSprintSpeedScale(player, 3.0);     // 3x sprint

// Disable sprint (rubber-banding mechanic in racing)
mod.SetSprintSpeedScale(player, 0.0);
```

---

### SetJumpHeightScale

Modify jump height.

```typescript
function SetJumpHeightScale(
  player: mod.Player,
  scale: number
): void
```

**Example:**

```typescript
// Moon gravity jump
mod.SetJumpHeightScale(player, 3.0);

// Disable jumping
mod.SetJumpHeightScale(player, 0.0);

// Low gravity mode
export async function OnGameModeStarted() {
  const players = modlib.ConvertArray(mod.GetPlayers());
  for (const player of players) {
    mod.SetJumpHeightScale(player, 2.5);
    mod.SetMovementSpeedScale(player, 1.2);
  }
}
```

---

### GetPlayerTransform

Get player's current position and rotation.

```typescript
function GetPlayerTransform(player: mod.Player): mod.Transform
```

**Returns:** Transform object with `position` and `rotation`

**Example:**

```typescript
const transform = mod.GetPlayerTransform(player);
const pos = transform.position;  // mod.Vector
const rot = transform.rotation;  // mod.Vector (Euler angles)

console.log(`Player at: ${pos.x}, ${pos.y}, ${pos.z}`);

// Distance between two players
function getDistanceBetweenPlayers(p1: mod.Player, p2: mod.Player): number {
  const t1 = mod.GetPlayerTransform(p1);
  const t2 = mod.GetPlayerTransform(p2);

  return mod.Distance(t1.position, t2.position);
}

// Teleport all players to leader
export async function teleportToLeader(leader: mod.Player) {
  const leaderPos = mod.GetPlayerTransform(leader).position;
  const players = modlib.ConvertArray(mod.GetPlayers());

  for (const player of players) {
    if (player !== leader) {
      mod.Teleport(player, leaderPos, 0);
    }
  }
}
```

---

## Health & Damage

### SetPlayerMaxHealth

Set maximum health for a player.

```typescript
function SetPlayerMaxHealth(
  player: mod.Player,
  maxHealth: number
): void
```

**Parameters:**
- `maxHealth` - New max health (default is 100)

**Example:**

```typescript
// Tank mode - 500 HP
mod.SetPlayerMaxHealth(player, 500);

// Low health challenge
mod.SetPlayerMaxHealth(player, 25);

// Boss player
export async function makeBoss(player: mod.Player) {
  mod.SetPlayerMaxHealth(player, 1000);
  mod.SetMovementSpeedScale(player, 0.8);  // Slower but tankier
  mod.SetPlayerTeam(player, mod.Team.Team2);

  // Give special weapon
  mod.AddEquipment(player, mod.Weapons.RPG);
}
```

---

### DealDamage

Damage a specific player.

```typescript
function DealDamage(
  player: mod.Player,
  damage: number
): void
```

**Example:**

```typescript
// Environmental damage
mod.DealDamage(player, 25);

// Damage over time effect
export async function applyBurnDamage(player: mod.Player, duration: number) {
  const ticks = duration * 4;  // 4 ticks per second

  for (let i = 0; i < ticks; i++) {
    mod.DealDamage(player, 5);  // 5 damage per tick

    if (mod.IsPlayerDead(player)) break;

    await mod.Wait(0.25);  // 250ms between ticks
  }
}
```

---

### Kill

Instantly kill a player.

```typescript
function Kill(player: mod.Player): void
```

**Example:**

```typescript
// Out of bounds penalty
export async function checkBoundaries() {
  const players = modlib.ConvertArray(mod.GetPlayers());

  for (const player of players) {
    const pos = mod.GetPlayerTransform(player).position;

    // Kill if below Y = -100 (fell off map)
    if (pos.y < -100) {
      mod.Kill(player);

      modlib.DisplayCustomNotificationMessage(
        "Out of bounds!",
        mod.NotificationSlot.MessageText1,
        2,
        player
      );
    }
  }
}
```

---

### Revive

Revive a dead player.

```typescript
function Revive(player: mod.Player): void
```

**Example:**

```typescript
// Auto-revive after delay
export async function OnPlayerDied(player: mod.Player) {
  await mod.Wait(5);  // 5 second respawn timer

  if (mod.IsPlayerDead(player)) {
    mod.Revive(player);

    // Teleport to spawn
    const spawner = mod.GetSpawner(1);
    const spawnPos = mod.GetSpawnerPosition(spawner);
    mod.Teleport(player, spawnPos, 0);
  }
}

// Medic revive ability
export async function medicRevive(medic: mod.Player, deadPlayer: mod.Player) {
  const distance = getDistanceBetweenPlayers(medic, deadPlayer);

  if (distance < 5.0 && mod.IsPlayerDead(deadPlayer)) {
    mod.Revive(deadPlayer);

    // Award points to medic
    const score = mod.GetPlayerScore(medic);
    mod.SetPlayerScore(medic, score + 100);
  }
}
```

---

## Visibility & Appearance

### SetPlayerVisibility

Make player visible or invisible.

```typescript
function SetPlayerVisibility(
  player: mod.Player,
  visible: boolean
): void
```

**Example:**

```typescript
// Hide player (ghost mode)
mod.SetPlayerVisibility(player, false);

// Show player
mod.SetPlayerVisibility(player, true);

// Temporary invisibility power-up
export async function giveInvisibility(player: mod.Player, duration: number) {
  mod.SetPlayerVisibility(player, false);

  modlib.DisplayCustomNotificationMessage(
    "You are invisible!",
    mod.NotificationSlot.MessageText1,
    3,
    player
  );

  await mod.Wait(duration);
  mod.SetPlayerVisibility(player, true);
}
```

::: warning Gameplay Note
Invisible players can still be damaged and killed! They just can't be seen.
:::

---

### SetPlayerNameTagMode

Control when player name tags are visible.

```typescript
function SetPlayerNameTagMode(
  player: mod.Player,
  mode: mod.NameTagMode
): void
```

**Modes:**
- `mod.NameTagMode.Always` - Always show name
- `mod.NameTagMode.Never` - Never show name
- `mod.NameTagMode.TeamOnly` - Only show to teammates
- `mod.NameTagMode.AimingAt` - Only when aimed at

**Example:**

```typescript
// Stealth mode - no name tags
export async function OnGameModeStarted() {
  const players = modlib.ConvertArray(mod.GetPlayers());
  for (const player of players) {
    mod.SetPlayerNameTagMode(player, mod.NameTagMode.Never);
  }
}

// Hardcore mode - no teammate names
mod.SetPlayerNameTagMode(player, mod.NameTagMode.Never);

// Normal mode
mod.SetPlayerNameTagMode(player, mod.NameTagMode.Always);
```

---

## Input Restrictions

### RestrictPlayerInput

Disable specific player inputs.

```typescript
function RestrictPlayerInput(
  player: mod.Player,
  input: mod.RestrictedInputs,
  restricted: boolean
): void
```

**Available Inputs:**

```typescript
mod.RestrictedInputs.Sprint
mod.RestrictedInputs.Crouch
mod.RestrictedInputs.Jump
mod.RestrictedInputs.Prone
mod.RestrictedInputs.FireWeapon
mod.RestrictedInputs.ADS          // Aim Down Sights
mod.RestrictedInputs.Reload
mod.RestrictedInputs.SwitchWeapon
mod.RestrictedInputs.UseGadget
mod.RestrictedInputs.EnterVehicle
mod.RestrictedInputs.Melee
mod.RestrictedInputs.Interact
mod.RestrictedInputs.SpotEnemy
mod.RestrictedInputs.ToggleFireMode
mod.RestrictedInputs.Ping
mod.RestrictedInputs.VoiceChat
mod.RestrictedInputs.TextChat
mod.RestrictedInputs.Scoreboard
```

**Example:**

```typescript
// Disable sprint
mod.RestrictPlayerInput(player, mod.RestrictedInputs.Sprint, true);

// Enable sprint
mod.RestrictPlayerInput(player, mod.RestrictedInputs.Sprint, false);

// Melee-only mode
export async function makeMeleeOnly(player: mod.Player) {
  mod.RestrictPlayerInput(player, mod.RestrictedInputs.FireWeapon, true);
  mod.RestrictPlayerInput(player, mod.RestrictedInputs.UseGadget, true);
  mod.RestrictPlayerInput(player, mod.RestrictedInputs.SwitchWeapon, true);
  // Melee is still allowed!
}

// Buy phase (can't shoot)
export async function buyPhase(duration: number) {
  const players = modlib.ConvertArray(mod.GetPlayers());

  // Disable weapons
  for (const player of players) {
    mod.RestrictPlayerInput(player, mod.RestrictedInputs.FireWeapon, true);
  }

  await mod.Wait(duration);

  // Enable weapons
  for (const player of players) {
    mod.RestrictPlayerInput(player, mod.RestrictedInputs.FireWeapon, false);
  }
}
```

---

## Utility Functions

### IsPlayerDead

Check if player is currently dead.

```typescript
function IsPlayerDead(player: mod.Player): boolean
```

**Example:**

```typescript
if (mod.IsPlayerDead(player)) {
  console.log("Player is dead");
}

// Count alive players
function countAlivePlayers(): number {
  const players = modlib.ConvertArray(mod.GetPlayers());
  return players.filter(p => !mod.IsPlayerDead(p)).length;
}
```

---

### GetPlayerName

Get player's display name.

```typescript
function GetPlayerName(player: mod.Player): string
```

**Example:**

```typescript
const name = mod.GetPlayerName(player);
console.log(`Player name: ${name}`);

// Show kill message to everyone
export async function OnPlayerEarnedKill(killer: mod.Player, victim: mod.Player) {
  const killerName = mod.GetPlayerName(killer);
  const victimName = mod.GetPlayerName(victim);
  const message = `${killerName} eliminated ${victimName}`;

  const allPlayers = modlib.ConvertArray(mod.GetPlayers());
  for (const p of allPlayers) {
    modlib.DisplayCustomNotificationMessage(
      message,
      mod.NotificationSlot.MessageText3,
      3,
      p
    );
  }
}
```

---

### GetPlayerById

Get player object from string ID.

```typescript
function GetPlayerById(playerId: string): mod.Player | null
```

**Example:**

```typescript
export async function OnPlayerLeaveGame(playerId: string) {
  // Remove from tracking
  playersInGame = playersInGame.filter(p => {
    const id = mod.GetPlayerById(playerId);
    return p.player !== id;
  });
}
```

---

## Complete Example: Power-Up System

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';

enum PowerUpType {
  Speed,
  Health,
  Invisibility,
  Jump
}

interface ActivePowerUp {
  player: mod.Player;
  type: PowerUpType;
  expiresAt: number;
}

let activePowerUps: ActivePowerUp[] = [];

export async function grantPowerUp(player: mod.Player, type: PowerUpType) {
  const duration = 10;  // 10 seconds

  switch (type) {
    case PowerUpType.Speed:
      mod.SetMovementSpeedScale(player, 2.0);
      modlib.DisplayCustomNotificationMessage(
        "⚡ Speed Boost!",
        mod.NotificationSlot.MessageText1,
        3,
        player
      );
      break;

    case PowerUpType.Health:
      mod.SetPlayerMaxHealth(player, 200);
      modlib.DisplayCustomNotificationMessage(
        "❤️ Max Health Increased!",
        mod.NotificationSlot.MessageText1,
        3,
        player
      );
      break;

    case PowerUpType.Invisibility:
      mod.SetPlayerVisibility(player, false);
      modlib.DisplayCustomNotificationMessage(
        "👻 You are invisible!",
        mod.NotificationSlot.MessageText1,
        3,
        player
      );
      break;

    case PowerUpType.Jump:
      mod.SetJumpHeightScale(player, 3.0);
      modlib.DisplayCustomNotificationMessage(
        "🚀 Super Jump!",
        mod.NotificationSlot.MessageText1,
        3,
        player
      );
      break;
  }

  // Track active power-up
  activePowerUps.push({
    player,
    type,
    expiresAt: Date.now() + (duration * 1000)
  });
}

// Check for expired power-ups
export async function updatePowerUps() {
  const now = Date.now();

  for (let i = activePowerUps.length - 1; i >= 0; i--) {
    const powerUp = activePowerUps[i];

    if (now >= powerUp.expiresAt) {
      // Remove power-up effect
      switch (powerUp.type) {
        case PowerUpType.Speed:
          mod.SetMovementSpeedScale(powerUp.player, 1.0);
          break;
        case PowerUpType.Health:
          mod.SetPlayerMaxHealth(powerUp.player, 100);
          break;
        case PowerUpType.Invisibility:
          mod.SetPlayerVisibility(powerUp.player, true);
          break;
        case PowerUpType.Jump:
          mod.SetJumpHeightScale(powerUp.player, 1.0);
          break;
      }

      modlib.DisplayCustomNotificationMessage(
        "Power-up expired",
        mod.NotificationSlot.MessageText1,
        2,
        powerUp.player
      );

      // Remove from array
      activePowerUps.splice(i, 1);
    }
  }
}

// Main game loop
export async function OnGameModeStarted() {
  while (true) {
    updatePowerUps();
    await mod.Wait(0.5);  // Check twice per second
  }
}
```

---

## Related APIs

- [Player Spawning](/api/player-spawning) - Deploy and respawn players
- [Player Equipment](/api/player-equipment) - Weapons and gadgets
- [Player State](/api/player-state) - Get player information

## See Also

- [AcePursuit Example](/examples/acepursuit) - Uses speed scaling for catchup mechanics
- [Vertigo Example](/examples/vertigo) - Demonstrates teleportation and restrictions
