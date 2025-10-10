# Development Workflow

This guide covers the complete end-to-end workflow for creating custom game modes with the Battlefield 6 Portal SDK, from initial concept to published experience.

## Workflow Overview

The Portal SDK development cycle follows four main phases:

```
┌─────────────────┐
│ 1. DESIGN       │  Concept, planning, requirements
└────────┬────────┘
         │
┌────────▼────────┐
│ 2. BUILD        │  Godot editing, TypeScript scripting
└────────┬────────┘
         │
┌────────▼────────┐
│ 3. TEST         │  Local testing, iteration
└────────┬────────┘
         │
┌────────▼────────┐
│ 4. PUBLISH      │  Upload to Portal, community release
└─────────────────┘
```

## Phase 1: Design & Planning

### Concept Development

Before opening Godot, plan your game mode:

**Key Questions:**
- What type of game mode? (Team vs Team, FFA, Racing, PvE)
- How many players? (4v4, 8-player FFA, 16-player Conquest)
- What map suits this mode? (Open maps for vehicles, close quarters for infantry)
- What makes it unique? (Special mechanics, custom rules)

**Example Concepts:**
- **"Hot Pursuit"** - Police chase vehicles through Manhattan Bridge
- **"King of the Skyscraper"** - Vertical combat on Empire State Building
- **"Last Stand"** - 4-player co-op vs waves of AI enemies
- **"Parkour Challenge"** - Time trial through obstacle course

### Technical Requirements

Identify systems you'll need:

| System | Use Case | Complexity |
|--------|----------|------------|
| **Basic Spawning** | Team spawns, respawn | Low |
| **Scoring** | Points, kills, objectives | Low |
| **Timer** | Time limits, countdowns | Low |
| **UI** | HUD elements, notifications | Medium |
| **AI Enemies** | PvE combat | Medium |
| **Vehicles** | Racing, transport | Medium |
| **Custom Objectives** | Capture points, triggers | Medium-High |
| **Economy System** | Buy phases, currency | High |
| **Complex UI** | Menus, shops, dialogs | High |

### Study Examples

Review example mods matching your concept:

- **Simple Team Mode** → Study **Vertigo** (308 lines)
- **Vehicle Racing** → Study **AcePursuit** (800 lines)
- **Round-Based** → Study **BombSquad** (800 lines)
- **Objective PvE** → Study **Exfil** (1000 lines)

::: tip Start Simple
For your first mod, start with a simple concept. You can always add complexity in future iterations.
:::

## Phase 2: Build

### Step 2.1: Map Selection

Choose an appropriate map from the 9 available:

**Urban/Infantry Maps:**
- **MP_Dumbo** (Manhattan Bridge) - Multi-level urban warfare
- **MP_Abbasid** (Siege of Cairo) - Dense city streets
- **MP_Limestone** (Saint's Quarter) - Close quarters
- **MP_Aftermath** (Empire State) - Vertical skyscraper

**Open/Vehicle Maps:**
- **MP_Firestorm** (Operation Firestorm) - Desert, vehicles
- **MP_Tungsten** (Mirak Valley) - Mountain valleys
- **MP_Battery** (Gibraltar) - Coastal, mixed
- **MP_Capstone** (Liberation Peak) - Snow, mountains
- **MP_Outskirts** (New Sobek City) - Suburban sprawl

### Step 2.2: Open Map in Godot

1. Launch `Godot_v4.4.1-stable_win64.exe`
2. Open Portal project
3. **Scene** → **Open Scene** → `levels/MP_YourMap.tscn`
4. Look up to find level geometry

### Step 2.3: Spatial Editing

#### Set Up Required Objects

Every playable map needs:

**1. Combat Area** (Already placed on all maps)
- Defines playable boundaries
- Players die if they leave this area

**2. Player Spawners**
```
HQ_PlayerSpawner
├── Assigned to specific team
├── Links to SpawnPoints
└── Allows manual HQ spawning

OR

PlayerSpawner
├── Not assigned to team
├── Links to SpawnPoints
└── Used for script-controlled spawning
```

**3. Spawn Points**
- Determines actual spawn locations
- Must be linked to a spawner
- Multiple spawn points per spawner

#### Add Gameplay Objects

Use the Object Library to add:

**Common Objects:**
- **SpawnPoint** - Where players appear
- **AI_Spawner** - Spawn bot enemies
- **AreaTrigger** - Detect player entry/exit
- **VehicleSpawner** - Spawn vehicles
- **WorldIcon** - 3D markers
- **InteractPoint** - Interaction zones
- **CapturePoint** - Conquest-style objectives

**Adding Objects:**
1. Click **Object Library** tab at bottom
2. Select correct map tab or **Global**
3. Drag object into scene or outliner
4. Position using W (move), E (rotate), R (scale)

#### Configure Object Properties

For each gameplay object:

1. **Select object** in Scene Outliner
2. **Set Obj Id** in Inspector (unique number)
3. **Configure properties** (team, radius, etc.)
4. **Document the ID** in your script planning

**Example Configuration:**

```
PlayerSpawner (Obj Id: 1)
├── Name: "Team1_MainSpawn"
├── Obj Id: 1
└── Linked SpawnPoints: [10, 11, 12]

AreaTrigger (Obj Id: 50)
├── Name: "CheckpointA_Trigger"
├── Obj Id: 50
└── PolygonVolume: [configured]

AI_Spawner (Obj Id: 100)
├── Name: "Enemy_Spawn_North"
├── Obj Id: 100
└── Team: Neutral
```

#### Visual Placement Tips

**Good Spawn Placement:**
- Spawn points face into playable area
- Safe from enemy fire initially
- Multiple spawn points per team
- Spread out to avoid clustering

**Trigger Placement:**
- Clear visual indication (if possible)
- Appropriate size for gameplay
- Test player size vs trigger size

**Object Organization:**
- Use Scene Outliner folders
- Name objects descriptively
- Keep related objects grouped

### Step 2.4: Export Spatial Layout

When satisfied with object placement:

1. Click **BFPortal** tab (right side)
2. Click **"Export Current Level"** button
3. Choose save location (e.g., `mods/MyMod/`)
4. File saves as `MapName.spatial.json`

::: warning Save Godot Scene First
Always save your `.tscn` scene file before exporting. Unsaved changes won't be exported!
:::

### Step 2.5: Write TypeScript Logic

#### Create Script File

Create `MyMod.ts` in your mod folder:

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';

// ========================================
// GAME MODE: [Your Mode Name]
// ========================================

// Global state
let gameStarted = false;

export async function OnGameModeStarted() {
  // Initialize game mode
  console.log("[MyMod] Game mode starting...");

  // Configure game settings
  mod.SetGameTimeLimit(600); // 10 minutes
  mod.SetMaxPlayerCount(16);
  mod.SetFriendlyFire(false);

  // Start countdown
  await startCountdown();
}

async function startCountdown() {
  const allPlayers = modlib.ConvertArray(mod.GetPlayers());

  for (let i = 3; i > 0; i--) {
    for (const player of allPlayers) {
      modlib.DisplayCustomNotificationMessage(
        `Game starting in ${i}...`,
        mod.NotificationSlot.HeaderText,
        1,
        player
      );
    }
    await mod.Wait(1);
  }

  gameStarted = true;
  console.log("[MyMod] Game started!");
}

export async function OnPlayerJoinGame(player: mod.Player) {
  console.log("[MyMod] Player joined");

  // Assign to team (balance teams)
  const team1Count = modlib.ConvertArray(mod.GetPlayersInTeam(mod.Team.Team1)).length;
  const team2Count = modlib.ConvertArray(mod.GetPlayersInTeam(mod.Team.Team2)).length;

  if (team1Count <= team2Count) {
    mod.SetPlayerTeam(player, mod.Team.Team1);
  } else {
    mod.SetPlayerTeam(player, mod.Team.Team2);
  }
}

export async function OnPlayerDeployed(player: mod.Player) {
  console.log("[MyMod] Player deployed");

  // Spawn player at team spawner
  const team = mod.GetTeam(player);
  const spawnerId = team === mod.Team.Team1 ? 1 : 2;
  const spawner = mod.GetSpawner(spawnerId);

  mod.SpawnPlayerFromSpawnPoint(player, spawner);

  // Give default loadout
  mod.AddEquipment(player, mod.Weapons.Primary_AK24);
  mod.AddEquipment(player, mod.Weapons.Secondary_MP28);
  mod.AddEquipment(player, mod.Gadgets.Class_Supply_Bag);
}

export async function OnPlayerDied(player: mod.Player) {
  console.log("[MyMod] Player died");

  // Respawn after 5 seconds
  await mod.Wait(5);
  mod.Revive(player);
}

export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  // Award points
  const score = mod.GetPlayerScore(killer);
  mod.SetPlayerScore(killer, score + 100);

  // Check win condition
  if (score + 100 >= 1000) {
    mod.EndGameMode(killer);
  }
}
```

#### Implement Core Mechanics

Based on your design, implement:

**Scoring System:**
```typescript
function awardPoints(player: mod.Player, points: number) {
  const current = mod.GetPlayerScore(player);
  mod.SetPlayerScore(player, current + points);

  // Show notification
  modlib.DisplayCustomNotificationMessage(
    `+${points} points! Total: ${current + points}`,
    mod.NotificationSlot.MessageText2,
    3,
    player
  );
}
```

**Timer System:**
```typescript
async function startGameTimer() {
  let timeRemaining = 600; // 10 minutes

  while (timeRemaining > 0) {
    await mod.Wait(1);
    timeRemaining--;

    if (timeRemaining % 60 === 0) {
      const minutes = timeRemaining / 60;
      console.log(`${minutes} minutes remaining`);
    }
  }

  // Time's up
  endGame();
}
```

**Trigger Detection:**
```typescript
export async function OnPlayerEnterAreaTrigger(
  player: mod.Player,
  trigger: mod.AreaTrigger
) {
  const triggerId = mod.GetObjId(trigger);

  if (triggerId === 50) {
    // Player entered checkpoint A
    handleCheckpoint(player, "A");
  }
}
```

#### Add UI Elements

Create HUD and notifications:

```typescript
function createPlayerHUD(player: mod.Player) {
  // Score display
  const scoreWidget = modlib.ParseUI({
    type: "Container",
    position: [10, 10],
    size: [200, 50],
    bgColor: [0, 0, 0],
    bgAlpha: 0.7,
    children: [
      {
        type: "Text",
        textLabel: "Score: 0",
        textSize: 20,
        textColor: [1, 1, 1]
      }
    ]
  }, player);

  return scoreWidget;
}
```

## Phase 3: Testing

### Local Testing Strategy

#### Test Checklist

Before uploading, verify:

**Basic Functionality:**
- [ ] Game mode starts without errors
- [ ] Players can join and deploy
- [ ] Spawning works correctly
- [ ] Player controls work
- [ ] Death/respawn cycle functions

**Core Mechanics:**
- [ ] Scoring system works
- [ ] Objectives trigger correctly
- [ ] Timers count properly
- [ ] Win conditions activate
- [ ] Team assignment balances

**Edge Cases:**
- [ ] Player leaving/rejoining
- [ ] Multiple players spawning simultaneously
- [ ] Timer expiration
- [ ] All players on one team
- [ ] Maximum player count

#### Debug Techniques

**Console Logging:**
```typescript
console.log("[DEBUG] Player count:", modlib.ConvertArray(mod.GetPlayers()).length);
console.log("[DEBUG] Game time:", mod.GetMatchTimeElapsed());
console.log("[DEBUG] Player health:", mod.GetSoldierState(player, mod.SoldierStateNumber.CurrentHealth));
```

**Visual Debug:**
```typescript
// Spawn VFX at trigger locations
mod.SpawnObject(mod.RuntimeSpawn_Common.VFX_Explosion_Large, position, [0,0,0]);

// Add world icons to mark important points
mod.AddUIIcon(
  spawner,
  mod.WorldIconImages.Icon_Spawn,
  "Debug Spawner",
  [1, 0, 0] // Red
);
```

**State Tracking:**
```typescript
const playerStates = new Map<string, any>();

function trackPlayerState(player: mod.Player) {
  const playerId = mod.GetObjId(player);
  playerStates.set(playerId, {
    score: mod.GetPlayerScore(player),
    team: mod.GetTeam(player),
    isAlive: mod.GetSoldierState(player, mod.SoldierStateBool.IsAlive)
  });
}
```

### Iteration Cycle

**Quick Iteration:**
1. Make script changes in editor
2. Save file
3. Re-upload to Portal (script only)
4. Test immediately
5. No need to re-export spatial if unchanged

**Spatial Changes:**
1. Modify objects in Godot
2. Save .tscn scene
3. Re-export to .spatial.json
4. Upload both spatial + script
5. Test

::: tip Rapid Prototyping
For fast iteration, comment out slow initialization code and use simplified test scenarios.
:::

## Phase 4: Publish

### Step 4.1: Portal Upload

#### Access Portal Builder

1. Navigate to https://portal.battlefield.com
2. Log in with credentials
3. Click **"Create New Experience"**

#### Upload Files

**1. Upload Spatial Layout:**
- Click **"Upload Spatial File"**
- Select your `.spatial.json` file
- Wait for processing (30-60 seconds)

**2. Add TypeScript Script:**
- Click **"Script"** tab
- Select **"TypeScript"** mode
- Paste entire script or upload `.ts` file
- Script validates automatically

**3. Configure Settings:**
- **Name**: Descriptive, unique name
- **Description**: Explain gameplay and rules
- **Map**: Must match your spatial file
- **Players**: Min/Max player counts
- **Game Time**: Time limit (if relevant)
- **Tags**: Help players find your mode

### Step 4.2: Test on Portal

**Private Testing:**
1. Save experience as **"Private"**
2. Click **"Test Experience"**
3. Invite friends or add bots
4. Verify everything works in live environment

**Common Live Issues:**
- Latency affects timing
- Player behavior differs from bots
- Network synchronization issues

### Step 4.3: Publish to Community

When ready for public release:

1. **Final Review:**
   - Test with real players (5-10 games minimum)
   - Fix any reported bugs
   - Polish UI and notifications
   - Verify balance

2. **Publish Settings:**
   - Set to **"Public"** or **"Featured"**
   - Write clear description
   - Add appealing thumbnail (if available)
   - Include game rules in description

3. **Launch:**
   - Click **"Publish"**
   - Share link with community
   - Monitor feedback

### Step 4.4: Post-Launch

**Gather Feedback:**
- Monitor player reviews
- Track which features players like
- Note common complaints
- Watch gameplay videos (if shared)

**Update and Iterate:**
- Fix critical bugs immediately
- Balance issues (typically within 1-2 weeks)
- Add requested features
- Maintain version history

**Version Control:**
- Keep backup of each version
- Document changes in changelog
- Increment version numbers

## Best Practices

### Workflow Tips

**Before Building:**
- ✅ Sketch out game flow on paper
- ✅ List all required objects and IDs
- ✅ Review similar example mods
- ✅ Start with minimal viable version

**During Building:**
- ✅ Save Godot scene frequently (Ctrl+S)
- ✅ Test incrementally (don't build everything first)
- ✅ Use descriptive names for objects and variables
- ✅ Comment complex logic
- ✅ Keep functions small and focused

**Before Publishing:**
- ✅ Test with minimum players (1-2)
- ✅ Test with maximum players
- ✅ Test all win/loss conditions
- ✅ Verify all UI text is clear
- ✅ Check for console errors

### Common Mistakes

❌ **Building everything before testing**
- Test core mechanics first!

❌ **Using wrong object library**
- Only use matching map tab or Global

❌ **Forgetting to set Object IDs**
- Script can't reference objects without IDs

❌ **Not handling edge cases**
- Empty teams, all players leaving, etc.

❌ **Overcomplicating first version**
- Start simple, add features later

## Workflow Checklist

Use this checklist for each project:

### Planning Phase
- [ ] Game concept defined
- [ ] Map selected
- [ ] Systems identified
- [ ] Example mods reviewed

### Building Phase
- [ ] Godot scene created
- [ ] Required objects placed
- [ ] Object IDs set
- [ ] Spatial exported
- [ ] TypeScript file created
- [ ] Event hooks implemented
- [ ] Core mechanics coded
- [ ] UI created

### Testing Phase
- [ ] Basic functions tested
- [ ] All win conditions verified
- [ ] Edge cases handled
- [ ] No console errors
- [ ] Multiplayer tested

### Publishing Phase
- [ ] Spatial + script uploaded
- [ ] Settings configured
- [ ] Private testing complete
- [ ] Published to community

## Next Steps

Now you understand the complete workflow:

- **[Godot Editor Guide](/guides/godot-editor)** - Master spatial editing
- **[TypeScript Scripting](/guides/typescript-scripting)** - Write better code
- **[Event Hooks Guide](/guides/event-hooks)** - Understand the event system
- **[First Game Mode Tutorial](/tutorials/first-game-mode)** - Build step-by-step

---

::: tip Workflow Reference
Bookmark this page! You'll refer to it frequently during development.
:::
