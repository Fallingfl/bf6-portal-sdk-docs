# Enumerations

Complete reference for all 41 enumerations available in the BF6 Portal SDK.

## Overview

Enumerations provide predefined values for various game elements. They ensure type safety and prevent invalid values.

## Maps (9 maps)

```typescript
mod.Maps.MP_Abbasid      // Siege of Cairo
mod.Maps.MP_Aftermath    // Empire State
mod.Maps.MP_Battery      // Iberian Offensive (Gibraltar)
mod.Maps.MP_Capstone     // Liberation Peak
mod.Maps.MP_Dumbo        // Manhattan Bridge (Brooklyn)
mod.Maps.MP_Firestorm    // Operation Firestorm (Turkmenistan)
mod.Maps.MP_Limestone    // Saint's Quarter
mod.Maps.MP_Outskirts    // New Sobek City
mod.Maps.MP_Tungsten     // Mirak Valley (Tajikistan)
```

**Usage:**
```typescript
const currentMap = mod.GetCurrentMap();
if (currentMap === mod.Maps.MP_Dumbo) {
  console.log("Playing on Manhattan Bridge");
}
```

## Teams (9 teams)

```typescript
mod.Team.Team1
mod.Team.Team2
mod.Team.Team3
mod.Team.Team4
mod.Team.Team5
mod.Team.Team6
mod.Team.Team7
mod.Team.Team8
mod.Team.Team9
```

**Usage:**
```typescript
mod.SetPlayerTeam(player, mod.Team.Team1);
mod.SetTeamName(mod.Team.Team1, "Attackers");
mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);
```

## Team Colors (14 colors)

```typescript
mod.TeamColor.Red
mod.TeamColor.Blue
mod.TeamColor.Green
mod.TeamColor.Yellow
mod.TeamColor.Orange
mod.TeamColor.Purple
mod.TeamColor.Pink
mod.TeamColor.Cyan
mod.TeamColor.White
mod.TeamColor.Black
mod.TeamColor.Brown
mod.TeamColor.Gray
mod.TeamColor.LightBlue
mod.TeamColor.DarkGreen
```

**Usage:**
```typescript
mod.SetTeamColor(mod.Team.Team1, mod.TeamColor.Red);
mod.SetTeamColor(mod.Team.Team2, mod.TeamColor.Blue);
```

## Weapons (163 weapons)

### Assault Rifles
```typescript
mod.Weapons.AK24
mod.Weapons.M16A4
mod.Weapons.SCAR_H
mod.Weapons.ACR
mod.Weapons.G36C
// ... 158 more weapons
```

### Sniper Rifles
```typescript
mod.Weapons.SniperRifle_SRR61
mod.Weapons.SniperRifle_M95
mod.Weapons.SniperRifle_GOL
```

### Pistols
```typescript
mod.Weapons.Pistol_G17
mod.Weapons.Pistol_M9
mod.Weapons.Pistol_MP443
```

**Usage:**
```typescript
mod.AddEquipment(player, mod.Weapons.AK24);
mod.RemoveEquipment(player, mod.Weapons.AK24);
mod.SetPlayerAmmo(player, mod.Weapons.AK24, 30, 120);
```

## Gadgets (47 gadgets)

### Class Gadgets
```typescript
mod.Gadgets.Class_Adrenaline_Injector
mod.Gadgets.Class_Motion_Sensor
mod.Gadgets.Class_Repair_Tool
mod.Gadgets.Class_Supply_Bag
```

### Deployables
```typescript
mod.Gadgets.Deployable_Cover
mod.Gadgets.Deployable_Deploy_Beacon
mod.Gadgets.Deployable_EOD_Bot
mod.Gadgets.Deployable_Grenade_Intercept_System
mod.Gadgets.Deployable_Missile_Intercept_System
mod.Gadgets.Deployable_Portable_Mortar
mod.Gadgets.Deployable_Recon_Drone
mod.Gadgets.Deployable_Vehicle_Supply_Crate
```

### Launchers
```typescript
mod.Gadgets.Launcher_Aim_Guided
mod.Gadgets.Launcher_Air_Defense
mod.Gadgets.Launcher_Auto_Guided
mod.Gadgets.Launcher_Breaching_Projectile
mod.Gadgets.Launcher_High_Explosive
mod.Gadgets.Launcher_Incendiary_Airburst
mod.Gadgets.Launcher_Long_Range
mod.Gadgets.Launcher_Smoke_Grenade
mod.Gadgets.Launcher_Thermobaric_Grenade
mod.Gadgets.Launcher_Unguided_Rocket
```

### Melee
```typescript
mod.Gadgets.Melee_Combat_Knife
mod.Gadgets.Melee_Hunting_Knife
mod.Gadgets.Melee_Sledgehammer
```

### Miscellaneous
```typescript
mod.Gadgets.Misc_Acoustic_Sensor_AV_Mine
mod.Gadgets.Misc_Anti_Personnel_Mine
mod.Gadgets.Misc_Anti_Vehicle_Mine
mod.Gadgets.Misc_Assault_Ladder
mod.Gadgets.Misc_Defibrillator
mod.Gadgets.Misc_Demolition_Charge
mod.Gadgets.Misc_Incendiary_Round_Shotgun
mod.Gadgets.Misc_Laser_Designator
mod.Gadgets.Misc_Sniper_Decoy
mod.Gadgets.Misc_Supply_Pouch
mod.Gadgets.Misc_Tracer_Dart
mod.Gadgets.Misc_Tripwire_Sensor_AV_Mine
```

### Throwables
```typescript
mod.Gadgets.Throwable_Anti_Vehicle_Grenade
mod.Gadgets.Throwable_Flash_Grenade
mod.Gadgets.Throwable_Fragmentation_Grenade
mod.Gadgets.Throwable_Incendiary_Grenade
mod.Gadgets.Throwable_Mini_Frag_Grenade
mod.Gadgets.Throwable_Proximity_Detector
mod.Gadgets.Throwable_Smoke_Grenade
mod.Gadgets.Throwable_Stun_Grenade
mod.Gadgets.Throwable_Throwing_Knife
```

**Usage:**
```typescript
mod.AddEquipment(player, mod.Gadgets.Class_Repair_Tool);
mod.AddEquipment(player, mod.Gadgets.Throwable_Fragmentation_Grenade);
```

## Vehicles (47 types)

### Tanks
```typescript
mod.Vehicles.M1A5          // Abrams tank
mod.Vehicles.T28            // Russian tank
mod.Vehicles.EMKV90_TOR     // Tor tank
```

### Helicopters
```typescript
mod.Vehicles.AH64          // Apache
mod.Vehicles.KA52          // Hokum
mod.Vehicles.ANNIH         // Annihilator
```

### Jets
```typescript
mod.Vehicles.F35           // F-35
mod.Vehicles.SU57          // Su-57
```

### Transport
```typescript
mod.Vehicles.LATV          // Light vehicle
mod.Vehicles.HUMVEE        // Humvee
mod.Vehicles.QUADBIKE      // Quad bike
```

**Usage:**
```typescript
const vehicleSpawner = mod.GetVehicleSpawner(50);
mod.SetVehicleSpawnerType(vehicleSpawner, mod.Vehicles.M1A5);
mod.ForceVehicleSpawnerSpawn(vehicleSpawner);
```

## Inventory Slots (8 slots)

```typescript
mod.InventorySlots.PrimaryWeapon       // Primary weapon slot
mod.InventorySlots.SecondaryWeapon     // Secondary weapon slot
mod.InventorySlots.ClassGadget         // Class-specific gadget
mod.InventorySlots.GadgetOne           // Gadget slot 1
mod.InventorySlots.GadgetTwo           // Gadget slot 2
mod.InventorySlots.MeleeWeapon         // Melee weapon
mod.InventorySlots.MiscGadget          // Misc gadget
mod.InventorySlots.Throwable           // Throwable item
```

**Usage:**
```typescript
// Add weapon to specific slot
mod.AddEquipment(player, mod.Weapons.AK24, mod.InventorySlots.PrimaryWeapon);

// Remove from specific slot
mod.RemoveEquipment(player, mod.InventorySlots.SecondaryWeapon);

// Force switch to slot
mod.ForceSwitchInventory(player, mod.InventorySlots.ClassGadget);
```

## Restricted Inputs (18 inputs)

```typescript
mod.RestrictedInputs.CameraPitch          // Look up/down
mod.RestrictedInputs.CameraYaw            // Look left/right
mod.RestrictedInputs.Crouch               // Crouch action
mod.RestrictedInputs.CycleFire            // Change fire mode
mod.RestrictedInputs.CyclePrimary         // Cycle primary weapons
mod.RestrictedInputs.FireWeapon           // Shoot
mod.RestrictedInputs.Interact             // Interact with objects
mod.RestrictedInputs.Jump                 // Jump action
mod.RestrictedInputs.MoveForwardBack      // Forward/backward movement
mod.RestrictedInputs.MoveLeftRight        // Strafe movement
mod.RestrictedInputs.Prone                // Go prone
mod.RestrictedInputs.Reload               // Reload weapon
mod.RestrictedInputs.SelectCharacterGadget // Select class gadget
mod.RestrictedInputs.SelectMelee          // Select melee
mod.RestrictedInputs.SelectOpenGadget     // Select open gadget
mod.RestrictedInputs.SelectPrimary        // Select primary weapon
mod.RestrictedInputs.SelectSecondary      // Select secondary weapon
mod.RestrictedInputs.SelectThrowable      // Select throwable
mod.RestrictedInputs.Sprint               // Sprint action
mod.RestrictedInputs.Zoom                 // Aim down sights
```

**Usage:**
```typescript
// Disable sprinting
mod.EnableInputRestriction(player, mod.RestrictedInputs.Sprint, true);

// Disable shooting
mod.EnableInputRestriction(player, mod.RestrictedInputs.FireWeapon, true);

// Disable all movement
mod.EnableInputRestriction(player, mod.RestrictedInputs.MoveForwardBack, true);
mod.EnableInputRestriction(player, mod.RestrictedInputs.MoveLeftRight, true);

// Re-enable jumping
mod.EnableInputRestriction(player, mod.RestrictedInputs.Jump, false);
```

## AI Behaviors (7 behaviors)

```typescript
mod.AIBehavior.BattlefieldAI      // Standard combat AI
mod.AIBehavior.MoveToLocation     // Move to position
mod.AIBehavior.DefendLocation     // Guard position
mod.AIBehavior.DefendPlayer       // Protect player
mod.AIBehavior.Idle               // Stand still
mod.AIBehavior.WaypointPatrol     // Patrol waypoints
mod.AIBehavior.Parachute          // Parachute down
```

**Usage:**
```typescript
// Set AI behavior
mod.AIBattlefieldBehavior(aiPlayer);

// Defend position
const defendPos = mod.CreateVector(100, 0, 50);
mod.AIDefendPositionBehavior(aiPlayer, defendPos, 5, 20);

// Patrol waypoints
const waypoints = [
  mod.CreateVector(100, 0, 50),
  mod.CreateVector(200, 0, 50),
  mod.CreateVector(200, 0, 150)
];
const path = mod.CreateWaypointPatrolPath(waypoints);
mod.AIWaypointIdleBehavior(aiPlayer, path);
```

## AI Move Speeds (7 speeds)

```typescript
mod.MoveSpeed.InvestigateRun
mod.MoveSpeed.InvestigateSlowWalk
mod.MoveSpeed.InvestigateWalk
mod.MoveSpeed.Patrol
mod.MoveSpeed.Run
mod.MoveSpeed.Sprint
mod.MoveSpeed.Walk
```

**Usage:**
```typescript
mod.AISetMoveSpeed(aiPlayer, mod.MoveSpeed.Sprint);
mod.AISetMoveSpeed(aiPlayer, mod.MoveSpeed.Patrol);
```

## Soldier Classes (4 classes)

```typescript
mod.SoldierClass.Assault
mod.SoldierClass.Engineer
mod.SoldierClass.Recon
mod.SoldierClass.Support
```

**Usage:**
```typescript
// Spawn AI with specific class
mod.SpawnAIFromAISpawner(
  spawner,
  mod.SoldierClass.Assault,
  mod.Message("Assault Bot"),
  mod.Team.Team2
);
```

## Player Death Types (11 types)

```typescript
mod.PlayerDeathTypes.Deserting     // Left combat area
mod.PlayerDeathTypes.Drowning      // Drowned
mod.PlayerDeathTypes.Explosion     // Killed by explosion
mod.PlayerDeathTypes.Fall          // Fall damage
mod.PlayerDeathTypes.Fire          // Burned to death
mod.PlayerDeathTypes.Headshot      // Headshot kill
mod.PlayerDeathTypes.Melee         // Melee kill
mod.PlayerDeathTypes.Penetration   // Bullet penetration
mod.PlayerDeathTypes.Redeploy      // Player redeployed
mod.PlayerDeathTypes.Roadkill      // Vehicle roadkill
mod.PlayerDeathTypes.Weapon        // Weapon kill
```

**Usage:**
```typescript
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  switch (deathType) {
    case mod.PlayerDeathTypes.Headshot:
      console.log("Headshot kill!");
      mod.SetPlayerScore(killer, mod.GetPlayerScore(killer) + 150);
      break;
    case mod.PlayerDeathTypes.Melee:
      console.log("Melee kill!");
      mod.SetPlayerScore(killer, mod.GetPlayerScore(killer) + 200);
      break;
    default:
      mod.SetPlayerScore(killer, mod.GetPlayerScore(killer) + 100);
  }
}
```

## Player Damage Types (6 types)

```typescript
mod.PlayerDamageTypes.Default
mod.PlayerDamageTypes.Explosion
mod.PlayerDamageTypes.Fall
mod.PlayerDamageTypes.Fire
mod.PlayerDamageTypes.Headshot
mod.PlayerDamageTypes.Melee
```

## UI Anchors (9 positions)

```typescript
mod.UIAnchor.TopLeft
mod.UIAnchor.TopCenter
mod.UIAnchor.TopRight
mod.UIAnchor.CenterLeft
mod.UIAnchor.Center
mod.UIAnchor.CenterRight
mod.UIAnchor.BottomLeft
mod.UIAnchor.BottomCenter
mod.UIAnchor.BottomRight
```

**Usage:**
```typescript
// Create UI at top-left
mod.AddUIContainer(
  "scoreDisplay",
  mod.CreateVector(10, 10, 0),
  mod.CreateVector(200, 100, 0),
  mod.UIAnchor.TopLeft
);

// Center a dialog
mod.AddUIContainer(
  "dialog",
  mod.CreateVector(-200, -150, 0),  // Offset from center
  mod.CreateVector(400, 300, 0),
  mod.UIAnchor.Center
);
```

## Notification Slots (5 slots)

```typescript
mod.CustomNotificationSlots.HeaderText      // Large header
mod.CustomNotificationSlots.MessageText1    // Sub-message 1
mod.CustomNotificationSlots.MessageText2    // Sub-message 2
mod.CustomNotificationSlots.MessageText3    // Sub-message 3
mod.CustomNotificationSlots.MessageText4    // Sub-message 4
```

**Usage:**
```typescript
// Display messages in different slots
mod.DisplayCustomNotificationMessage(
  mod.Message("ROUND STARTING"),
  mod.CustomNotificationSlots.HeaderText,
  5  // Duration in seconds
);

mod.DisplayCustomNotificationMessage(
  mod.Message("Capture the objectives!"),
  mod.CustomNotificationSlots.MessageText1,
  3
);
```

## Spawn Modes (2 modes)

```typescript
mod.SpawnModes.AutoSpawn    // Automatic spawning
mod.SpawnModes.Manual       // Manual deploy only
```

**Usage:**
```typescript
// Set spawn mode
mod.SetSpawnMode(mod.SpawnModes.Manual);

// Players must click Deploy button
export async function OnPlayerDeployed(player: mod.Player) {
  const spawner = mod.GetSpawnPoint(1);
  mod.SpawnPlayerFromSpawnPoint(player, spawner);
}
```

## Scoreboard Types (4 types)

```typescript
mod.ScoreboardType.None
mod.ScoreboardType.FreeForAll
mod.ScoreboardType.Teams
mod.ScoreboardType.Squads
```

**Usage:**
```typescript
mod.SetScoreboardType(mod.ScoreboardType.Teams);
mod.SetScoreboardHeader(mod.Message("TEAM DEATHMATCH"));
```

## Camera Types (3 types)

```typescript
mod.Cameras.FirstPerson
mod.Cameras.ThirdPerson
mod.Cameras.Free
```

**Usage:**
```typescript
// Force third-person for all
mod.SetCameraTypeForAll(mod.Cameras.ThirdPerson);

// Set specific player camera
mod.SetCameraTypeForPlayer(player, mod.Cameras.FirstPerson);
```

## Soldier State Booleans (23 states)

```typescript
mod.SoldierStateBool.HasLowHealth
mod.SoldierStateBool.InVehicle
mod.SoldierStateBool.IsAI
mod.SoldierStateBool.IsAlive
mod.SoldierStateBool.IsAirborne
mod.SoldierStateBool.IsCrouching
mod.SoldierStateBool.IsDeploying
mod.SoldierStateBool.IsDeployed
mod.SoldierStateBool.IsFalling
mod.SoldierStateBool.IsFiring
mod.SoldierStateBool.IsGrounded
mod.SoldierStateBool.IsManDown
mod.SoldierStateBool.IsMoving
mod.SoldierStateBool.IsOnWater
mod.SoldierStateBool.IsParachuting
mod.SoldierStateBool.IsProne
mod.SoldierStateBool.IsReloading
mod.SoldierStateBool.IsScoped
mod.SoldierStateBool.IsSprinting
mod.SoldierStateBool.IsSwimming
mod.SoldierStateBool.IsUnderwater
mod.SoldierStateBool.IsUsingGadget
```

**Usage:**
```typescript
// Check player states
const isAlive = mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive);
const isSprinting = mod.GetSoldierState(player, mod.SoldierStateBool.IsSprinting);
const inVehicle = mod.GetSoldierState(player, mod.SoldierStateBool.InVehicle);

if (isAlive && !inVehicle) {
  // Player is alive and on foot
}
```

## Soldier State Numbers (8 states)

```typescript
mod.SoldierStateNumber.Ammo
mod.SoldierStateNumber.AnimationSpeed
mod.SoldierStateNumber.ClipSize
mod.SoldierStateNumber.CurrentHealth
mod.SoldierStateNumber.ForwardSpeed
mod.SoldierStateNumber.MaxHealth
mod.SoldierStateNumber.RightSpeed
mod.SoldierStateNumber.UpSpeed
```

**Usage:**
```typescript
const health = mod.GetSoldierState(player, mod.SoldierStateNumber.CurrentHealth);
const maxHealth = mod.GetSoldierState(player, mod.SoldierStateNumber.MaxHealth);
const ammo = mod.GetSoldierState(player, mod.SoldierStateNumber.Ammo);

console.log(`Health: ${health}/${maxHealth}, Ammo: ${ammo}`);
```

## Soldier State Vectors (3 states)

```typescript
mod.SoldierStateVector.GetPosition
mod.SoldierStateVector.GetVelocity
mod.SoldierStateVector.GetViewDirection
```

**Usage:**
```typescript
const position = mod.GetSoldierState(player, mod.SoldierStateVector.GetPosition);
const velocity = mod.GetSoldierState(player, mod.SoldierStateVector.GetVelocity);
const lookDir = mod.GetSoldierState(player, mod.SoldierStateVector.GetViewDirection);

console.log(`Player at: ${position}, moving: ${velocity}, looking: ${lookDir}`);
```

## Ammo Types (6 types)

```typescript
mod.AmmoTypes.AR_Carbine_Ammo
mod.AmmoTypes.Backpack_Ammo
mod.AmmoTypes.Launcher_Ammo
mod.AmmoTypes.LMG_Ammo
mod.AmmoTypes.Pistol_SMG_Ammo
mod.AmmoTypes.Sniper_DMR_Ammo
```

## Best Practices

### 1. Always Use Enums, Not Strings

```typescript
// ❌ Bad - using strings
mod.SetPlayerTeam(player, "Team1");  // ERROR!

// ✅ Good - using enum
mod.SetPlayerTeam(player, mod.Team.Team1);
```

### 2. Validate Enum Values

```typescript
function assignTeam(player: mod.Player, teamIndex: number) {
  const teams = [
    mod.Team.Team1,
    mod.Team.Team2,
    mod.Team.Team3,
    mod.Team.Team4
  ];

  if (teamIndex >= 0 && teamIndex < teams.length) {
    mod.SetPlayerTeam(player, teams[teamIndex]);
  } else {
    console.log("Invalid team index!");
  }
}
```

### 3. Use Switch Statements

```typescript
switch (deathType) {
  case mod.PlayerDeathTypes.Headshot:
    awardBonus(killer, 50);
    break;
  case mod.PlayerDeathTypes.Melee:
    awardBonus(killer, 100);
    break;
  case mod.PlayerDeathTypes.Roadkill:
    awardBonus(killer, 25);
    break;
  default:
    // Standard kill
}
```

## Next Steps

- 📖 [Types](/api/types) - Understanding type system
- 📖 [Player Control](/api/player-control) - Player functions
- 📖 [UI System](/api/ui-overview) - UI enumerations
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip Enum Summary
- **41 total enumerations** covering all game aspects
- **Always use enums** instead of magic strings/numbers
- **Type-safe** - IDE autocomplete and compile-time checking
- **Comprehensive** - Maps, weapons, gadgets, vehicles, and more
:::