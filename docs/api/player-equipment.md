# Player Equipment

Functions for managing player weapons, gadgets, and loadouts.

## Overview

The equipment system allows you to:
- Add/remove weapons and gadgets
- Manage inventory slots
- Create custom weapon configurations
- Control ammo and resupply
- Force weapon switching

## Adding Equipment

### AddEquipment

Add weapons or gadgets to a player's inventory.

```typescript
// Basic add
AddEquipment(player: Player, weapon: Weapons): void
AddEquipment(player: Player, gadget: Gadgets): void

// With weapon package
AddEquipment(player: Player, weapon: Weapons, weaponPackage: WeaponPackage): void

// To specific slot
AddEquipment(player: Player, weapon: Weapons, desiredInventorySlot: InventorySlots): void
AddEquipment(player: Player, gadget: Gadgets, desiredInventorySlot: InventorySlots): void
```

**Example: Basic Loadout**
```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Add primary weapon
  mod.AddEquipment(player, mod.Weapons.AK24);

  // Add secondary
  mod.AddEquipment(player, mod.Weapons.Pistol_G17);

  // Add gadgets
  mod.AddEquipment(player, mod.Gadgets.Class_Repair_Tool);
  mod.AddEquipment(player, mod.Gadgets.Throwable_Fragmentation_Grenade);
}
```

**Example: Specific Slots**
```typescript
// Place weapons in specific slots
mod.AddEquipment(player, mod.Weapons.AK24, mod.InventorySlots.PrimaryWeapon);
mod.AddEquipment(player, mod.Weapons.Pistol_G17, mod.InventorySlots.SecondaryWeapon);
mod.AddEquipment(player, mod.Gadgets.Class_Medkit, mod.InventorySlots.ClassGadget);
mod.AddEquipment(player, mod.Gadgets.Deployable_Cover, mod.InventorySlots.GadgetOne);
```

## Removing Equipment

### RemoveEquipment

Remove items from player's inventory.

```typescript
// Remove by slot
RemoveEquipment(player: Player, inventorySlot: InventorySlots): void

// Remove specific item
RemoveEquipment(player: Player, weapon: Weapons): void
RemoveEquipment(player: Player, gadget: Gadgets): void
```

**Example: Clear Loadout**
```typescript
function clearPlayerLoadout(player: mod.Player) {
  // Remove all equipment slots
  mod.RemoveEquipment(player, mod.InventorySlots.PrimaryWeapon);
  mod.RemoveEquipment(player, mod.InventorySlots.SecondaryWeapon);
  mod.RemoveEquipment(player, mod.InventorySlots.ClassGadget);
  mod.RemoveEquipment(player, mod.InventorySlots.GadgetOne);
  mod.RemoveEquipment(player, mod.InventorySlots.GadgetTwo);
  mod.RemoveEquipment(player, mod.InventorySlots.Throwable);
  mod.RemoveEquipment(player, mod.InventorySlots.MeleeWeapon);
}
```

**Example: Weapon Swap**
```typescript
function swapPrimaryWeapon(player: mod.Player, newWeapon: mod.Weapons) {
  // Remove current primary
  mod.RemoveEquipment(player, mod.InventorySlots.PrimaryWeapon);

  // Add new weapon
  mod.AddEquipment(player, newWeapon, mod.InventorySlots.PrimaryWeapon);

  // Force switch to new weapon
  mod.ForceSwitchInventory(player, mod.InventorySlots.PrimaryWeapon);
}
```

## Checking Equipment

### HasEquipment

Check if player has specific weapon or gadget.

```typescript
HasEquipment(player: Player, weapon: Weapons): boolean
HasEquipment(player: Player, gadget: Gadgets): boolean
```

**Example: Equipment Validation**
```typescript
function checkPlayerEquipment(player: mod.Player) {
  // Check for specific weapons
  const hasAK24 = mod.HasEquipment(player, mod.Weapons.AK24);
  const hasPistol = mod.HasEquipment(player, mod.Weapons.Pistol_G17);

  // Check for gadgets
  const hasMedkit = mod.HasEquipment(player, mod.Gadgets.Class_Medkit);
  const hasGrenade = mod.HasEquipment(player, mod.Gadgets.Throwable_Fragmentation_Grenade);

  console.log(`Equipment: AK24=${hasAK24}, Pistol=${hasPistol}, Medkit=${hasMedkit}`);

  return { hasAK24, hasPistol, hasMedkit, hasGrenade };
}
```

### GetPlayerEquipment

Get list of all equipment player has.

```typescript
GetPlayerEquipment(player: Player): Array
```

**Example: List All Equipment**
```typescript
function listPlayerEquipment(player: mod.Player) {
  const equipment = modlib.ConvertArray(mod.GetPlayerEquipment(player));

  console.log(`Player has ${equipment.length} items:`);
  for (const item of equipment) {
    console.log(`- ${item}`);
  }

  return equipment;
}
```

## Weapon Switching

### ForceSwitchInventory

Force player to switch to specific inventory slot.

```typescript
ForceSwitchInventory(player: Player, inventorySlot: InventorySlots): void
```

**Example: Weapon Cycling**
```typescript
let currentSlot = 0;

function cycleWeapons(player: mod.Player) {
  const slots = [
    mod.InventorySlots.PrimaryWeapon,
    mod.InventorySlots.SecondaryWeapon,
    mod.InventorySlots.MeleeWeapon
  ];

  currentSlot = (currentSlot + 1) % slots.length;
  mod.ForceSwitchInventory(player, slots[currentSlot]);
}
```

**Example: Melee Only Mode**
```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  // Give only melee weapon
  clearPlayerLoadout(player);
  mod.AddEquipment(player, mod.Gadgets.Melee_Combat_Knife, mod.InventorySlots.MeleeWeapon);

  // Force switch to melee
  mod.ForceSwitchInventory(player, mod.InventorySlots.MeleeWeapon);

  // Disable weapon switching
  mod.EnableInputRestriction(player, mod.RestrictedInputs.SelectPrimary, true);
  mod.EnableInputRestriction(player, mod.RestrictedInputs.SelectSecondary, true);
}
```

## Weapon Packages

### CreateWeaponPackage

Create custom weapon configuration with attachments.

```typescript
CreateWeaponPackage(): WeaponPackage
```

### AddAttachmentToWeaponPackage

Add attachments to weapon package.

```typescript
AddAttachmentToWeaponPackage(attachment: WeaponAttachments, weaponPackage: WeaponPackage): void
```

**Example: Custom Weapon Build**
```typescript
function createSniperLoadout(player: mod.Player) {
  // Create weapon package
  const sniperPackage = mod.CreateWeaponPackage();

  // Add attachments
  mod.AddAttachmentToWeaponPackage(mod.WeaponAttachments.LongBarrel, sniperPackage);
  mod.AddAttachmentToWeaponPackage(mod.WeaponAttachments.Scope8x, sniperPackage);
  mod.AddAttachmentToWeaponPackage(mod.WeaponAttachments.Bipod, sniperPackage);
  mod.AddAttachmentToWeaponPackage(mod.WeaponAttachments.ExtendedMag, sniperPackage);

  // Give weapon with package
  mod.AddEquipment(player, mod.Weapons.SniperRifle_SRR61, sniperPackage);
}
```

**Example: Multiple Configurations**
```typescript
// Assault configuration
const assaultPackage = mod.CreateWeaponPackage();
mod.AddAttachmentToWeaponPackage(mod.WeaponAttachments.RedDotSight, assaultPackage);
mod.AddAttachmentToWeaponPackage(mod.WeaponAttachments.Grip, assaultPackage);
mod.AddAttachmentToWeaponPackage(mod.WeaponAttachments.Suppressor, assaultPackage);

// CQB configuration
const cqbPackage = mod.CreateWeaponPackage();
mod.AddAttachmentToWeaponPackage(mod.WeaponAttachments.ShortBarrel, cqbPackage);
mod.AddAttachmentToWeaponPackage(mod.WeaponAttachments.LaserSight, cqbPackage);
mod.AddAttachmentToWeaponPackage(mod.WeaponAttachments.ExtendedMag, cqbPackage);
```

## Ammo Management

### SetPlayerAmmo

Set ammunition for specific weapon.

```typescript
SetPlayerAmmo(player: Player, weapon: Weapons, magazineAmmo: number, reserveAmmo: number): void
```

**Example: Ammo Control**
```typescript
// Full ammo
mod.SetPlayerAmmo(player, mod.Weapons.AK24, 30, 120);

// Limited ammo mode
mod.SetPlayerAmmo(player, mod.Weapons.AK24, 30, 30);  // Only 1 reload

// Low ammo start
mod.SetPlayerAmmo(player, mod.Weapons.Pistol_G17, 5, 10);
```

### ResupplyPlayer

Resupply player's ammunition.

```typescript
ResupplyPlayer(player: Player, resupplyType: ResupplyTypes): void
```

**Example: Ammo Station**
```typescript
async function checkAmmoStations() {
  const ammoStationTrigger = mod.GetAreaTrigger(50);

  while (gameRunning) {
    const players = modlib.ConvertArray(mod.AllPlayers());

    for (const player of players) {
      if (mod.IsPlayerInAreaTrigger(player, ammoStationTrigger)) {
        // Resupply ammo
        mod.ResupplyPlayer(player, mod.ResupplyTypes.Ammo);

        // Show notification
        mod.DisplayCustomNotificationMessage(
          mod.Message("Ammo Resupplied!"),
          mod.CustomNotificationSlots.MessageText2,
          2,
          player
        );
      }
    }

    await mod.Wait(1);
  }
}
```

## Loadout Presets

### Class-Based Loadouts

```typescript
function getClassLoadout(soldierClass: mod.SoldierClass) {
  switch (soldierClass) {
    case mod.SoldierClass.Assault:
      return {
        primary: mod.Weapons.M16A4,
        secondary: mod.Weapons.Pistol_M9,
        gadget1: mod.Gadgets.Class_Medkit,
        gadget2: mod.Gadgets.Launcher_High_Explosive,
        throwable: mod.Gadgets.Throwable_Fragmentation_Grenade
      };

    case mod.SoldierClass.Engineer:
      return {
        primary: mod.Weapons.AK24,
        secondary: mod.Weapons.Pistol_G17,
        gadget1: mod.Gadgets.Class_Repair_Tool,
        gadget2: mod.Gadgets.Launcher_Anti_Vehicle,
        throwable: mod.Gadgets.Throwable_Anti_Vehicle_Grenade
      };

    case mod.SoldierClass.Recon:
      return {
        primary: mod.Weapons.SniperRifle_GOL,
        secondary: mod.Weapons.Pistol_MP443,
        gadget1: mod.Gadgets.Class_Motion_Sensor,
        gadget2: mod.Gadgets.Deployable_Recon_Drone,
        throwable: mod.Gadgets.Throwable_Proximity_Detector
      };

    case mod.SoldierClass.Support:
      return {
        primary: mod.Weapons.LMG_M249,
        secondary: mod.Weapons.Pistol_G17,
        gadget1: mod.Gadgets.Class_Supply_Bag,
        gadget2: mod.Gadgets.Deployable_Portable_Mortar,
        throwable: mod.Gadgets.Throwable_Smoke_Grenade
      };
  }
}

function applyClassLoadout(player: mod.Player, soldierClass: mod.SoldierClass) {
  const loadout = getClassLoadout(soldierClass);

  // Clear current equipment
  clearPlayerLoadout(player);

  // Apply new loadout
  mod.AddEquipment(player, loadout.primary, mod.InventorySlots.PrimaryWeapon);
  mod.AddEquipment(player, loadout.secondary, mod.InventorySlots.SecondaryWeapon);
  mod.AddEquipment(player, loadout.gadget1, mod.InventorySlots.GadgetOne);
  mod.AddEquipment(player, loadout.gadget2, mod.InventorySlots.GadgetTwo);
  mod.AddEquipment(player, loadout.throwable, mod.InventorySlots.Throwable);
  mod.AddEquipment(player, mod.Gadgets.Melee_Combat_Knife, mod.InventorySlots.MeleeWeapon);
}
```

### Random Loadouts

```typescript
function getRandomLoadout() {
  const primaries = [
    mod.Weapons.AK24,
    mod.Weapons.M16A4,
    mod.Weapons.SCAR_H,
    mod.Weapons.G36C
  ];

  const secondaries = [
    mod.Weapons.Pistol_G17,
    mod.Weapons.Pistol_M9,
    mod.Weapons.Pistol_MP443
  ];

  const gadgets = [
    mod.Gadgets.Class_Medkit,
    mod.Gadgets.Class_Supply_Bag,
    mod.Gadgets.Class_Motion_Sensor,
    mod.Gadgets.Deployable_Cover
  ];

  return {
    primary: primaries[Math.floor(Math.random() * primaries.length)],
    secondary: secondaries[Math.floor(Math.random() * secondaries.length)],
    gadget: gadgets[Math.floor(Math.random() * gadgets.length)]
  };
}

export async function OnPlayerDeployed(player: mod.Player) {
  const randomLoadout = getRandomLoadout();

  mod.AddEquipment(player, randomLoadout.primary);
  mod.AddEquipment(player, randomLoadout.secondary);
  mod.AddEquipment(player, randomLoadout.gadget);

  console.log(`Random loadout: ${randomLoadout.primary}`);
}
```

## Weapon Restrictions

### Disable Weapon Usage

```typescript
// Disable shooting
mod.EnableInputRestriction(player, mod.RestrictedInputs.FireWeapon, true);

// Disable aiming
mod.EnableInputRestriction(player, mod.RestrictedInputs.Zoom, true);

// Disable reload
mod.EnableInputRestriction(player, mod.RestrictedInputs.Reload, true);

// Disable weapon switching
mod.EnableInputRestriction(player, mod.RestrictedInputs.SelectPrimary, true);
mod.EnableInputRestriction(player, mod.RestrictedInputs.SelectSecondary, true);
```

### Weapon-Free Zones

```typescript
async function checkWeaponFreeZones() {
  const safeZone = mod.GetAreaTrigger(100);

  while (gameRunning) {
    const players = modlib.ConvertArray(mod.AllPlayers());

    for (const player of players) {
      const inSafeZone = mod.IsPlayerInAreaTrigger(player, safeZone);

      // Disable weapons in safe zone
      mod.EnableInputRestriction(player, mod.RestrictedInputs.FireWeapon, inSafeZone);

      if (inSafeZone) {
        mod.DisplayCustomNotificationMessage(
          mod.Message("Safe Zone - Weapons Disabled"),
          mod.CustomNotificationSlots.MessageText3,
          1,
          player
        );
      }
    }

    await mod.Wait(0.5);
  }
}
```

## Progressive Unlock System

```typescript
interface PlayerProgress {
  player: mod.Player;
  level: number;
  unlockedWeapons: mod.Weapons[];
  unlockedGadgets: mod.Gadgets[];
}

let playerProgress: PlayerProgress[] = [];

function getUnlocksForLevel(level: number) {
  const unlocks = {
    1: { weapon: mod.Weapons.Pistol_G17, gadget: null },
    5: { weapon: mod.Weapons.AK24, gadget: mod.Gadgets.Throwable_Fragmentation_Grenade },
    10: { weapon: mod.Weapons.M16A4, gadget: mod.Gadgets.Class_Medkit },
    15: { weapon: mod.Weapons.SniperRifle_GOL, gadget: mod.Gadgets.Deployable_Recon_Drone },
    20: { weapon: mod.Weapons.LMG_M249, gadget: mod.Gadgets.Class_Supply_Bag }
  };

  return unlocks[level] || null;
}

function levelUp(player: mod.Player) {
  let progress = playerProgress.find(p => p.player === player);

  if (!progress) {
    progress = {
      player,
      level: 1,
      unlockedWeapons: [],
      unlockedGadgets: []
    };
    playerProgress.push(progress);
  }

  progress.level++;

  const unlock = getUnlocksForLevel(progress.level);
  if (unlock) {
    if (unlock.weapon) {
      progress.unlockedWeapons.push(unlock.weapon);
      mod.AddEquipment(player, unlock.weapon);

      mod.DisplayCustomNotificationMessage(
        mod.Message(`Weapon Unlocked: ${unlock.weapon}`),
        mod.CustomNotificationSlots.HeaderText,
        5,
        player
      );
    }

    if (unlock.gadget) {
      progress.unlockedGadgets.push(unlock.gadget);
      mod.AddEquipment(player, unlock.gadget);

      mod.DisplayCustomNotificationMessage(
        mod.Message(`Gadget Unlocked: ${unlock.gadget}`),
        mod.CustomNotificationSlots.MessageText1,
        5,
        player
      );
    }
  }
}
```

## Buy Menu System

```typescript
interface ShopItem {
  type: 'weapon' | 'gadget';
  item: mod.Weapons | mod.Gadgets;
  cost: number;
  slot: mod.InventorySlots;
}

const shopItems: ShopItem[] = [
  { type: 'weapon', item: mod.Weapons.AK24, cost: 1000, slot: mod.InventorySlots.PrimaryWeapon },
  { type: 'weapon', item: mod.Weapons.M16A4, cost: 1200, slot: mod.InventorySlots.PrimaryWeapon },
  { type: 'weapon', item: mod.Weapons.SniperRifle_GOL, cost: 2500, slot: mod.InventorySlots.PrimaryWeapon },
  { type: 'gadget', item: mod.Gadgets.Class_Medkit, cost: 500, slot: mod.InventorySlots.ClassGadget },
  { type: 'gadget', item: mod.Gadgets.Deployable_Cover, cost: 750, slot: mod.InventorySlots.GadgetOne }
];

function buyItem(player: mod.Player, itemIndex: number) {
  const item = shopItems[itemIndex];
  const playerMoney = getPlayerMoney(player);

  if (playerMoney < item.cost) {
    mod.DisplayCustomNotificationMessage(
      mod.Message("Not enough money!"),
      mod.CustomNotificationSlots.MessageText2,
      2,
      player
    );
    return false;
  }

  // Deduct money
  setPlayerMoney(player, playerMoney - item.cost);

  // Remove current item in slot
  mod.RemoveEquipment(player, item.slot);

  // Add new item
  if (item.type === 'weapon') {
    mod.AddEquipment(player, item.item as mod.Weapons, item.slot);
  } else {
    mod.AddEquipment(player, item.item as mod.Gadgets, item.slot);
  }

  return true;
}
```

## Best Practices

### 1. Clear Before Adding

```typescript
// Clear slot before adding new equipment
mod.RemoveEquipment(player, mod.InventorySlots.PrimaryWeapon);
mod.AddEquipment(player, mod.Weapons.AK24, mod.InventorySlots.PrimaryWeapon);
```

### 2. Validate Equipment

```typescript
function safeAddEquipment(player: mod.Player, weapon: mod.Weapons) {
  if (!mod.IsPlayerValid(player)) {
    console.log("Invalid player!");
    return false;
  }

  // Check if already has weapon
  if (mod.HasEquipment(player, weapon)) {
    console.log("Player already has this weapon");
    return false;
  }

  mod.AddEquipment(player, weapon);
  return true;
}
```

### 3. Cache Loadouts

```typescript
const loadoutCache = new Map<string, any>();

function getCachedLoadout(loadoutName: string) {
  if (!loadoutCache.has(loadoutName)) {
    loadoutCache.set(loadoutName, buildLoadout(loadoutName));
  }
  return loadoutCache.get(loadoutName);
}
```

## Next Steps

- 📖 [Player Control](/api/player-control) - Player management
- 📖 [Player State](/api/player-state) - Equipment state checks
- 📖 [Enums](/api/enums) - Weapon and gadget enumerations
- 📚 [API Overview](/api/) - Complete API reference

---

::: tip Equipment Summary
- **Add/Remove** - Manage weapons and gadgets
- **8 inventory slots** - Primary, Secondary, Gadgets, etc.
- **Weapon packages** - Custom configurations with attachments
- **Ammo control** - Set and resupply ammunition
- **Input restrictions** - Control weapon usage
:::