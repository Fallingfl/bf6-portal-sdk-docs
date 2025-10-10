# SDK Overview

The Battlefield 6 Portal SDK is a complete development environment for creating custom game modes in Battlefield 2042 Portal. This guide explains the SDK's structure, components, and how they work together.

## SDK Architecture

The SDK follows a clear separation of concerns:

```
Portal SDK
├── Visual Editing (Godot 4.4.1)
├── Game Logic (TypeScript API)
├── Conversion Tools (Python)
└── Publishing (Portal Website)
```

### The Development Pipeline

```
1. EDIT MAP LAYOUT
   ↓
   [Godot Spatial Editor]
   • Place objects
   • Configure properties
   • Set object IDs
   ↓

2. EXPORT TO JSON
   ↓
   [.spatial.json file]
   • Object positions
   • Rotations & scales
   • Layer organization
   ↓

3. WRITE GAME LOGIC
   ↓
   [TypeScript .ts file]
   • Event hooks
   • Game mechanics
   • UI systems
   ↓

4. PUBLISH
   ↓
   [Portal Website]
   • Upload spatial + script
   • Configure settings
   • Publish to community
```

## Core Components

### 1. Godot 4.4.1 Editor

**Purpose**: Visual level editing

The Godot editor is your primary tool for map layout:

- **Spatial editing** - Place, move, rotate, scale objects
- **Object library** - 14,000+ objects organized by map
- **Inspector panel** - Configure object properties
- **Export functionality** - Convert to `.spatial.json`

**Key Features:**
- Full 3D viewport with camera controls
- Scene hierarchy for object organization
- Custom BFPortal plugin for validation
- Per-map object libraries with Global tab

::: tip Godot is Pre-configured
You don't need Godot experience to use this SDK. The included version is pre-configured with the BFPortal plugin and all necessary assets.
:::

### 2. TypeScript API

**Purpose**: Game logic scripting

The TypeScript API provides programmatic control over all game systems:

- **545 functions** across 14 categories
- **7 event hooks** for game lifecycle
- **Complete type definitions** (14,106 lines)
- **Full IntelliSense support** in VS Code

**Categories:**
| Category | Functions | Purpose |
|----------|-----------|---------|
| Player Control | 120+ | Movement, health, loadouts, spawning |
| UI System | 104 | Widgets, notifications, scoreboards |
| AI System | 25+ | Bot behaviors, combat, spawning |
| VFX & Audio | 45+ | Visual effects, sounds, voice-over |
| Vehicle System | 40 | Vehicle spawning, control, damage |
| Game Mode | 30+ | Scoring, time limits, win conditions |
| Teams | 20+ | Team management, colors, assignments |
| World Objects | 20+ | Spawning, movement, triggers |
| Combat | 15+ | Damage, healing, revive, resupply |
| Core Utilities | 30+ | Vectors, arrays, messages, timing |

### 3. Helper Library (modlib)

**Purpose**: Common utility functions

The modlib library simplifies common operations:

```typescript
import * as modlib from './modlib';

// Convert Portal arrays to JavaScript arrays
const players = modlib.ConvertArray(mod.GetPlayers());

// Simplified notifications
modlib.DisplayCustomNotificationMessage(
  "Game starting in 5 seconds",
  mod.NotificationSlot.HeaderText,
  5,
  player
);

// Declarative UI building
const widget = modlib.ParseUI({
  type: "Container",
  position: [10, 10],
  size: [200, 100],
  children: [
    { type: "Text", textLabel: "Score: 0" }
  ]
});
```

**Helper Categories:**
- Array operations (filter, sort, convert)
- UI builder (JSON-based)
- Condition state tracking (per-player/team)
- Notification wrappers

### 4. Python Converters

**Purpose**: Godot ↔ JSON conversion

Python scripts handle bidirectional conversion:

**Export (Godot → JSON):**
```bash
python export_tscn.py "GodotProject/levels/MP_Dumbo.tscn" "FbExportData/" "output/"
```

**Import (JSON → Godot):**
```bash
python import_spatial.py "FbExportData/" "GodotProject/" "custom.spatial.json"
```

::: info Built-in Export
The Godot plugin includes an "Export Current Level" button that runs the Python exporter automatically.
:::

## File Structure

### SDK Directory Layout

```
PortalSDK/
├── Godot_v4.4.1-stable_win64.exe    # Godot editor (156 MB)
├── GodotProject/                     # Main project
│   ├── addons/bf_portal/            # Custom plugin
│   ├── levels/                       # 9 editable maps
│   │   ├── MP_Dumbo.tscn
│   │   ├── MP_Abbasid.tscn
│   │   └── ...
│   └── objects/                      # Per-map object libraries
├── FbExportData/                     # Frostbite data
│   ├── levels/*.spatial.json        # Official map data
│   └── asset_types.json             # Object definitions
├── code/
│   ├── mod/
│   │   └── index.d.ts               # TypeScript API (14,106 lines)
│   ├── modlib/
│   │   └── index.ts                 # Helper library (720 lines)
│   └── gdconverter/                 # Python converters
│       ├── export_tscn.py
│       └── import_spatial.py
├── mods/                             # Example game modes
│   ├── Vertigo/
│   ├── AcePursuit/
│   ├── BombSquad/
│   └── Exfil/
└── python/                           # Bundled Python runtime
```

### Per-Mod File Structure

Each complete game mode has 3 files:

```
ModName/
├── ModName.ts              # TypeScript game logic
├── ModName.tscn           # Godot scene (export to .spatial.json)
└── ModName.strings.json   # Localization strings
```

## Event-Driven Architecture

The SDK uses an event-driven model with 7 lifecycle hooks:

### Event Hook Overview

```typescript
// 1. GAME STARTUP
export async function OnGameModeStarted() {
  // Called once when server starts
  // Initialize game mode, set rules
}

// 2. PLAYER JOINS LOBBY
export async function OnPlayerJoinGame(player: mod.Player) {
  // Called when player enters lobby
  // Assign team, show welcome
}

// 3. PLAYER LEAVES
export async function OnPlayerLeaveGame(playerId: string) {
  // Called when player disconnects
  // Cleanup, reassign teams
}

// 4. PLAYER DEPLOYS
export async function OnPlayerDeployed(player: mod.Player) {
  // Called when player spawns into world
  // Give loadout, teleport
}

// 5. PLAYER DIES
export async function OnPlayerDied(player: mod.Player) {
  // Called when player health reaches 0
  // Handle respawn, update stats
}

// 6. PLAYER GETS KILL
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  // Called when player kills another
  // Award points, show killstreaks
}

// 7. PLAYER SWITCHES TEAM
export async function OnPlayerSwitchTeam(
  player: mod.Player,
  team: mod.Team
) {
  // Called when team assignment changes
  // Update UI, reset state
}
```

::: tip Async/Await Support
All event hooks are `async` functions, allowing you to use `await mod.Wait()` for timing and delays.
:::

## Object ID System

The SDK uses numeric IDs to reference objects between Godot and TypeScript:

### Setting Object IDs in Godot

1. Select object in Scene Outliner
2. Find **Obj Id** field in Inspector
3. Enter unique number (e.g., `1`, `2`, `3`)

### Referencing in TypeScript

```typescript
// Get spawner with ID 1
const spawner = mod.GetSpawner(1);

// Get trigger with ID 50
const trigger = mod.GetAreaTrigger(50);

// Get AI spawner with ID 100
const aiSpawner = mod.GetAISpawner(100);

// Get vehicle spawner with ID 200
const vehicleSpawner = mod.GetVehicleSpawner(200);
```

::: warning Unique IDs Required
Each object in your scene must have a unique Obj Id. Duplicate IDs will cause unpredictable behavior.
:::

### Recommended ID Ranges

Organize your IDs by type:

| Range | Object Type |
|-------|-------------|
| 1-50 | Player spawners |
| 51-100 | Area triggers |
| 101-150 | AI spawners |
| 151-200 | Vehicle spawners |
| 201-250 | Capture points |
| 251-300 | World icons |
| 301+ | Miscellaneous objects |

## Map-Specific Object Libraries

Each map has its own object library with thousands of unique objects:

### Object Availability

| Map | Object Count | Notes |
|-----|--------------|-------|
| Global | 629 | Usable on **ALL** maps |
| MP_Dumbo | 1,668 | Manhattan Bridge only |
| MP_Abbasid | 1,474 | Siege of Cairo only |
| MP_Tungsten | 1,417 | Mirak Valley only |
| MP_Aftermath | 1,454 | Empire State only |
| MP_Battery | 1,234 | Gibraltar only |
| MP_Outskirts | 854 | New Sobek City only |
| MP_Firestorm | 749 | Operation Firestorm only |
| MP_Limestone | 925 | Saint's Quarter only |
| MP_Capstone | 620 | Liberation Peak only |

::: danger Map Restrictions
Objects from one map **cannot** be used on another map (except Global objects). Using wrong objects will cause errors.
:::

### Object Categories

Objects include:
- **Terrain pieces** - Buildings, rocks, vegetation
- **Gameplay objects** - Spawners, triggers, capture points
- **Props** - Furniture, vehicles, decorations
- **VFX** - Particle effects, explosions, smoke
- **Audio** - 3D sound emitters

## Multi-Tenancy Design

While this SDK is for Battlefield Portal, the documentation site is designed with multi-tenant architecture principles:

- Each game mode is isolated
- No cross-contamination between experiences
- Scalable for community hosting
- Compliant with security standards (HIPAA, SOC 2 Type 2 ready)

## Performance Considerations

### Best Practices

**Object Spawning:**
- Limit runtime spawning to 100-200 objects
- Despawn objects when not needed
- Reuse object instances instead of spawning new ones

**UI Updates:**
- Batch UI updates when possible
- Cache widget references instead of `FindUIWidgetWithName()`
- Use per-player UI sparingly (duplicates per player)

**AI Bots:**
- Limit to 30-40 AI bots per map
- Use simple behaviors (Idle, Patrol) when possible
- Despawn AI when far from players

**Arrays & Loops:**
- Use `modlib.ConvertArray()` once, then cache
- Avoid nested loops over player arrays
- Filter arrays before processing

## Version Information

| Component | Version |
|-----------|---------|
| SDK | 1.0.1.0 |
| Godot | 4.4.1 |
| TypeScript API | 1.0 |
| Python | 3.x (bundled) |

## Next Steps

Now that you understand the SDK architecture:

- **[Installation Guide](/guides/installation)** - Set up your development environment
- **[Development Workflow](/guides/workflow)** - Learn the complete process
- **[Event Hooks Guide](/guides/event-hooks)** - Master the event system
- **[API Reference](/api/)** - Explore all 545 functions

---

::: tip Quick Start
Already familiar with the structure? Jump to [Getting Started](/guides/getting-started) to build your first game mode!
:::
