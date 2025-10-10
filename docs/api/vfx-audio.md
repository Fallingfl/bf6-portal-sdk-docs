# VFX & Audio API Reference

Complete reference for visual effects and audio systems in the BF6 Portal SDK.

## Overview

The VFX & Audio system provides:
- **Visual effects** - Particle systems, explosions, environmental effects
- **Sound effects** - 2D and 3D positioned audio
- **Voice overs** - Character dialogue and announcements
- **Dynamic control** - Enable, move, scale, and colorize effects

---

## Visual Effects (VFX)

### GetVFX

Retrieve a VFX object by ID:

```typescript
const vfx: VFX = mod.GetVFX(vfxNumber: number);

// Get VFX placed in Godot editor (by Obj Id)
const explosion = mod.GetVFX(100);
```

### EnableVFX

Enable or disable a VFX:

```typescript
mod.EnableVFX(vfx: VFX, enable: boolean): void

// Enable effect
mod.EnableVFX(explosionVFX, true);

// Disable effect
mod.EnableVFX(explosionVFX, false);
```

**Example - Timed Explosion:**
```typescript
async function triggerExplosion(position: mod.Vector) {
  const vfx = mod.GetVFX(explosionVFXId);

  mod.MoveVFX(vfx, position, mod.CreateVector(0, 0, 0));
  mod.EnableVFX(vfx, true);

  await mod.Wait(2);  // 2 second duration

  mod.EnableVFX(vfx, false);
}
```

### MoveVFX

Reposition and rotate a VFX:

```typescript
mod.MoveVFX(vfxID: VFX, position: Vector, rotation: Vector): void

// Move to player location
const playerPos = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
mod.MoveVFX(smokeVFX, playerPos, mod.CreateVector(0, 0, 0));
```

### SetVFXColor

Tint a VFX with color:

```typescript
mod.SetVFXColor(vfxID: VFX, color: Vector): void

// Red smoke
mod.SetVFXColor(smokeVFX, mod.CreateVector(1, 0, 0));

// Blue fire
mod.SetVFXColor(fireVFX, mod.CreateVector(0, 0.5, 1));
```

### SetVFXScale

Scale a VFX:

```typescript
mod.SetVFXScale(vfxID: VFX, scale: number): void

// Double size
mod.SetVFXScale(explosionVFX, 2.0);

// Half size
mod.SetVFXScale(smokeVFX, 0.5);
```

### SetVFXSpeed

Adjust animation speed:

```typescript
mod.SetVFXSpeed(vfxID: VFX, speed: number): void

// Slow motion (half speed)
mod.SetVFXSpeed(fireVFX, 0.5);

// Fast animation (double speed)
mod.SetVFXSpeed(explosionVFX, 2.0);
```

**Example - Dynamic Smoke Trail:**
```typescript
async function createSmokeTrail(startPos: mod.Vector, endPos: mod.Vector) {
  const smokeVFX = mod.GetVFX(smokeTrailId);

  // Start position
  mod.MoveVFX(smokeVFX, startPos, mod.CreateVector(0, 0, 0));
  mod.SetVFXScale(smokeVFX, 0.5);
  mod.EnableVFX(smokeVFX, true);

  // Animate to end position (simplified)
  for (let t = 0; t <= 1; t += 0.1) {
    const currentPos = lerpVector(startPos, endPos, t);
    mod.MoveVFX(smokeVFX, currentPos, mod.CreateVector(0, 0, 0));
    await mod.Wait(0.1);
  }

  await mod.Wait(3);
  mod.EnableVFX(smokeVFX, false);
}
```

---

## Audio System

### PlaySound

Play a sound effect:

```typescript
// 2D sound (all players)
mod.PlaySound(sound: SFX, amplitude: number): void

// 2D sound (specific target)
mod.PlaySound(sound: SFX, amplitude: number, target: Player | Team | Squad): void

// 3D positioned sound
mod.PlaySound(
  sound: SFX,
  amplitude: number,
  location: Vector,
  attenuationRange: number
): void

// Using spatial object ID
mod.PlaySound(objectId: number, amplitude: number, target?: Player | Team | Squad): void
```

**Parameters:**
- `sound` / `objectId` - Sound effect or spatial object with sound
- `amplitude` - Volume (0.0 to 1.0, higher = louder)
- `location` - 3D position for spatial audio
- `attenuationRange` - Distance over which sound fades
- `target` - Who hears the sound (optional, defaults to all)

**Example - Countdown Beeps:**
```typescript
async function playCountdownBeeps() {
  for (let i = 3; i > 0; i--) {
    mod.PlaySound(mod.SFX.UI_CountdownBeep, 0.8);
    await mod.Wait(1);
  }

  mod.PlaySound(mod.SFX.UI_CountdownStart, 1.0);
}
```

**Example - 3D Explosion Sound:**
```typescript
function playExplosionAt(position: mod.Vector) {
  mod.PlaySound(
    mod.SFX.Explosion_Large,
    1.0,              // Full volume at center
    position,         // 3D position
    50                // Audible within 50 meters
  );
}
```

**Example - Player-Specific Sound:**
```typescript
export async function OnPlayerEarnedKill(killer: mod.Player, victim: mod.Player) {
  // Only killer hears victory sound
  mod.PlaySound(mod.SFX.UI_KillConfirm, 0.7, killer);

  // Only victim hears death sound
  mod.PlaySound(mod.SFX.UI_Death, 0.6, victim);
}
```

### StopSound

Stop a playing sound:

```typescript
// Stop for all
mod.StopSound(sound: SFX): void
mod.StopSound(objectId: number): void

// Stop for specific target
mod.StopSound(sound: SFX, target: Player | Team | Squad): void
mod.StopSound(objectId: number, target: Player | Team | Squad): void
```

**Example - Stop Alarm:**
```typescript
let alarmPlaying = false;
let alarmSoundId = 0;

async function startAlarm() {
  alarmSoundId = mod.SFX.Alarm_Loop;
  mod.PlaySound(alarmSoundId, 0.8);
  alarmPlaying = true;
}

function stopAlarm() {
  if (alarmPlaying) {
    mod.StopSound(alarmSoundId);
    alarmPlaying = false;
  }
}
```

---

## Voice Overs

### PlayVO

Play character voice-over dialogue:

```typescript
// All players
mod.PlayVO(
  voiceOver: VO,
  event: VoiceOverEvents2D,
  flag: VoiceOverFlags
): void

// Specific target
mod.PlayVO(
  voiceOver: VO,
  event: VoiceOverEvents2D,
  flag: VoiceOverFlags,
  target: Player | Team | Squad
): void
```

**Parameters:**
- `voiceOver` - Character/faction voice
- `event` - Dialogue event type
- `flag` - Voice-over behavior flags
- `target` - Who hears it (optional)

**Example - Objective Announcements:**
```typescript
function announceObjectiveComplete(team: mod.Team) {
  mod.PlayVO(
    mod.VO.FactionCommander,
    mod.VoiceOverEvents2D.ObjectiveComplete,
    mod.VoiceOverFlags.Default,
    team
  );
}

function announceEnemySpotted(player: mod.Player) {
  mod.PlayVO(
    mod.VO.PlayerCharacter,
    mod.VoiceOverEvents2D.EnemySpotted,
    mod.VoiceOverFlags.Priority,  // Interrupts other VO
    player
  );
}
```

---

## Common Patterns

### Zone-Based Audio

```typescript
async function trackZoneAmbience() {
  const dangerZone = mod.GetAreaTrigger(10);

  while (gameRunning) {
    const players = modlib.ConvertArray(mod.AllPlayers());

    for (const player of players) {
      const inZone = mod.IsPlayerInAreaTrigger(player, dangerZone);
      const condition = modlib.getPlayerCondition(player, ZONE_CONDITION);

      if (condition.update(inZone)) {
        // Entered danger zone
        mod.PlaySound(mod.SFX.Ambient_DangerZone, 0.5, player);
      } else if (condition.updateExit(!inZone)) {
        // Left danger zone
        mod.StopSound(mod.SFX.Ambient_DangerZone, player);
      }
    }

    await mod.Wait(0.5);
  }
}
```

### Capture Point Effects

```typescript
async function capturePointEffects(capturePointId: number) {
  const capturePoint = mod.GetCapturePoint(capturePointId);
  const vfx = mod.GetVFX(capturePointVFXId);
  const position = mod.GetCapturePointTransform(capturePoint).position;

  while (gameRunning) {
    const controllingTeam = mod.GetCapturePointTeam(capturePoint);

    if (controllingTeam === mod.Team.Team1) {
      // Blue team controls - blue smoke
      mod.SetVFXColor(vfx, mod.CreateVector(0, 0.5, 1));
      mod.EnableVFX(vfx, true);
    } else if (controllingTeam === mod.Team.Team2) {
      // Red team controls - red smoke
      mod.SetVFXColor(vfx, mod.CreateVector(1, 0, 0));
      mod.EnableVFX(vfx, true);
    } else {
      // Neutral - disable VFX
      mod.EnableVFX(vfx, false);
    }

    await mod.Wait(1);
  }
}
```

### Low Health Warning

```typescript
async function lowHealthWarning(player: mod.Player) {
  while (mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive)) {
    const health = mod.GetSoldierState(player, mod.SoldierStateNumber.CurrentHealth);
    const maxHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.MaxHealth);
    const healthPercent = health / maxHealth;

    if (healthPercent < 0.25) {
      // Play heartbeat sound
      mod.PlaySound(mod.SFX.UI_LowHealth, 0.3, player);
    }

    await mod.Wait(1);
  }
}
```

---

## Best Practices

### 1. Use Appropriate Amplitude

```typescript
// ✅ Good - Moderate volumes
mod.PlaySound(mod.SFX.UI_Click, 0.5);           // UI sounds: 0.3-0.7
mod.PlaySound(mod.SFX.Explosion_Large, 0.9);    // Explosions: 0.8-1.0
mod.PlaySound(mod.SFX.Ambient_Wind, 0.2);       // Ambient: 0.1-0.3

// ❌ Bad - Too loud
mod.PlaySound(mod.SFX.UI_Click, 2.0);  // Ear-piercing
```

### 2. Clean Up VFX

```typescript
// ✅ Good - Disable when done
async function temporaryEffect() {
  mod.EnableVFX(vfx, true);
  await mod.Wait(duration);
  mod.EnableVFX(vfx, false);  // Clean up
}

// ❌ Bad - Leave effects running
async function temporaryEffect() {
  mod.EnableVFX(vfx, true);
  await mod.Wait(duration);
  // VFX still enabled!
}
```

### 3. Use 3D Audio for Spatial Events

```typescript
// ✅ Good - 3D positioned explosion
function explodeAt(position: mod.Vector) {
  mod.PlaySound(mod.SFX.Explosion, 1.0, position, 50);
}

// ❌ Bad - 2D sound for spatial event
function explodeAt(position: mod.Vector) {
  mod.PlaySound(mod.SFX.Explosion, 1.0);  // Everyone hears equally
}
```

### 4. Stop Looping Sounds

```typescript
// ✅ Good - Stop loops explicitly
function endAlarm() {
  mod.StopSound(mod.SFX.Alarm_Loop);
}

// ❌ Bad - Loop plays forever
function endAlarm() {
  // Alarm never stops
}
```

---

## API Functions Summary

| Category | Functions |
|----------|-----------|
| **VFX Control** | GetVFX, EnableVFX, MoveVFX, SetVFXColor, SetVFXScale, SetVFXSpeed |
| **Audio Playback** | PlaySound (2D/3D, multiple overloads) |
| **Audio Control** | StopSound (multiple overloads) |
| **Voice Overs** | PlayVO (multiple overloads) |

**Total: ~45+ VFX & audio functions** (including overloads)

---

## See Also

- 📖 [Gameplay Objects](/api/gameplay-objects) - Spatial objects with VFX/audio
- 📖 [Object Transform](/api/object-transform) - Positioning for 3D audio
- 📖 [Math & Vector](/api/math-vector) - Vector math for positioning
- 📚 [API Overview](/api/) - Complete API reference

---

★ Insight ─────────────────────────────────────
**VFX & Audio Architecture**
1. **VFX Object Model** - Effects are persistent objects that can be enabled/disabled rather than spawned/destroyed
2. **Flexible Audio Targeting** - Same PlaySound function handles 2D (all players), targeted (specific player/team), and 3D spatial audio
3. **Amplitude vs Attenuation** - 2D sounds use amplitude for volume, 3D sounds combine amplitude with attenuation range for distance-based falloff
─────────────────────────────────────────────────
