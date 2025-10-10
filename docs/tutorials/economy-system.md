# Economy & Buy Phase

Implement a tactical shooter economy system with weapon purchasing.

**Difficulty:** ★★★★★ | **Time:** 50 minutes

---

## What You'll Build

- Money management per player
- Buy phase timing and UI
- Equipment purchasing system
- Kill/round reward economy

---

## Player Economy State

```typescript
interface PlayerEconomy {
  money: number;
  equipment: mod.Weapons[];
}

const playerEconomy = new Map<mod.Player, PlayerEconomy>();

const STARTING_MONEY = 800;
const KILL_REWARD = 300;
const ROUND_WIN_BONUS = 1000;
const ROUND_LOSS_BONUS = 1400;
```

---

## Initialize Player Economy

```typescript
export async function OnPlayerJoinGame(player: mod.Player) {
  playerEconomy.set(player, {
    money: STARTING_MONEY,
    equipment: []
  });

  mod.DeployPlayer(player);
}
```

---

## Buy Phase

```typescript
const BUY_PHASE_TIME = 30; // seconds
let buyPhaseActive = false;

async function runBuyPhase() {
  console.log("Buy phase starting...");
  buyPhaseActive = true;

  // Show buy UI to all players
  showBuyMenus();

  // Countdown
  for (let time = BUY_PHASE_TIME; time > 0; time--) {
    updateBuyPhaseTimers(time);
    await mod.Wait(1);
  }

  buyPhaseActive = false;
  closeBuyMenus();
}

function showBuyMenus() {
  const players = modlib.ConvertArray(mod.AllPlayers());

  for (const player of players) {
    createBuyMenu(player);
  }
}
```

---

## Buy Menu UI

```typescript
const buyButtons = new Map<mod.Player, Map<string, mod.UIButton>>();

function createBuyMenu(player: mod.Player) {
  const economy = playerEconomy.get(player);
  if (!economy) return;

  // Container
  const menuContainer = mod.AddUIContainer(
    "buyMenu",
    mod.CreateVector(0, 0, 0),
    mod.CreateVector(400, 500, 0),
    mod.UIAnchor.Center,
    null,
    true,
    10,
    mod.CreateVector(0.1, 0.1, 0.1),
    0.9,
    mod.UIBgFill.Solid,
    player
  );

  // Money display
  mod.AddUIText(
    "moneyText",
    mod.Message(`Money: $${economy.money}`),
    mod.CreateVector(0, 10, 0),
    mod.CreateVector(380, 40, 0),
    mod.UIAnchor.TopCenter,
    menuContainer,
    true,
    20,
    mod.CreateVector(0, 1, 0),
    1.0,
    player
  );

  // Weapon buttons
  createWeaponButton(player, menuContainer, mod.Weapons.M5A3, 2700, 50);
  createWeaponButton(player, menuContainer, mod.Weapons.AK_24, 2500, 100);
  createWeaponButton(player, menuContainer, mod.Weapons.PKP_BP, 3100, 150);
}

function createWeaponButton(
  player: mod.Player,
  parent: mod.UIWidget,
  weapon: mod.Weapons,
  price: number,
  yPos: number
) {
  const buttonDef = mod.AddButtonDefinition(`buy_${weapon}`);

  mod.AddUIButton(
    `buyButton_${weapon}`,
    buttonDef,
    mod.Message(`${weapon} - $${price}`),
    mod.CreateVector(0, yPos, 0),
    mod.CreateVector(360, 40, 0),
    mod.UIAnchor.TopCenter,
    parent,
    true,
    true,
    18,
    mod.CreateVector(1, 1, 1),
    1.0,
    player
  );

  // Store button reference
  if (!buyButtons.has(player)) {
    buyButtons.set(player, new Map());
  }
  buyButtons.get(player)!.set(weapon.toString(), buttonDef);
}
```

---

## Handle Purchases

```typescript
export async function OnPlayerButtonPressed(player: mod.Player, button: mod.UIButton) {
  if (!buyPhaseActive) return;

  const economy = playerEconomy.get(player);
  if (!economy) return;

  // Check which weapon button was pressed
  const playerButtons = buyButtons.get(player);
  if (!playerButtons) return;

  for (const [weaponStr, buttonDef] of playerButtons.entries()) {
    if (button === buttonDef) {
      const weapon = weaponStr as mod.Weapons;
      const price = getWeaponPrice(weapon);

      if (economy.money >= price) {
        // Purchase successful
        economy.money -= price;
        economy.equipment.push(weapon);

        mod.DisplayCustomNotificationMessage(
          mod.Message(`Purchased ${weapon}`),
          mod.CustomNotificationSlots.MessageText1,
          2,
          player
        );

        // Update money display
        updateMoneyDisplay(player);
      } else {
        // Not enough money
        mod.DisplayCustomNotificationMessage(
          mod.Message("Not enough money!"),
          mod.CustomNotificationSlots.MessageText1,
          2,
          player
        );
      }
    }
  }
}

function getWeaponPrice(weapon: mod.Weapons): number {
  const prices: Record<string, number> = {
    [mod.Weapons.M5A3]: 2700,
    [mod.Weapons.AK_24]: 2500,
    [mod.Weapons.PKP_BP]: 3100
  };
  return prices[weapon] || 0;
}
```

---

## Give Purchased Equipment

```typescript
export async function OnPlayerDeployed(player: mod.Player) {
  const economy = playerEconomy.get(player);
  if (!economy) return;

  // Give purchased weapons
  for (const weapon of economy.equipment) {
    mod.AddEquipment(player, weapon, 1);
  }
}
```

---

## Award Money

```typescript
export async function OnPlayerEarnedKill(player: mod.Player, victim: mod.Player) {
  const economy = playerEconomy.get(player);
  if (economy) {
    economy.money += KILL_REWARD;
    updateMoneyDisplay(player);
  }
}

function awardRoundWin(team: mod.Team) {
  const players = modlib.ConvertArray(mod.GetPlayersInTeam(team));

  for (const player of players) {
    const economy = playerEconomy.get(player);
    if (economy) {
      economy.money += ROUND_WIN_BONUS;
    }
  }
}

function awardRoundLoss(team: mod.Team) {
  const players = modlib.ConvertArray(mod.GetPlayersInTeam(team));

  for (const player of players) {
    const economy = playerEconomy.get(player);
    if (economy) {
      economy.money += ROUND_LOSS_BONUS;
    }
  }
}
```

---

## Complete Example

See [BombSquad](/examples/bombsquad) for a full economy implementation with:
- Complete buy menu UI
- Weapon categories (rifles, SMGs, snipers)
- Armor purchasing
- Economy balancing

---

## Next Steps

- [BombSquad Example](/examples/bombsquad)
- [Complex UI Layouts](/tutorials/complex-ui)
- [Round-Based Systems](/tutorials/round-based)

---

★ Insight ─────────────────────────────────────
**Economy Balance**
1. **Loss Bonus** - Higher rewards for losing team (1400 vs 1000) creates comeback mechanics and prevents snowballing
2. **Per-Player State** - Economy tracked per-player (not team) allows individual skill expression through money management
3. **Buy Phase Lock** - Disable purchases outside buy phase prevents mid-round economic manipulation
─────────────────────────────────────────────────
