# What is Portal SDK?

The **Battlefield 6 Portal SDK** is a comprehensive development toolkit that enables you to create custom game modes for Battlefield 2042 Portal using a combination of **Godot 4.4.1** for spatial editing and **TypeScript** for game logic scripting.

## Overview

Portal SDK provides:

- **Visual Level Editor** (Godot) - Place and configure objects on maps
- **TypeScript API** (545+ functions) - Script game logic and behaviors
- **9 Official Maps** - Create experiences on official Battlefield maps
- **14,000+ Spawnable Objects** - Extensive object library per map
- **Complete Game Systems** - Players, AI, vehicles, UI, VFX, and more

## What Can You Build?

### Game Mode Types

- **Team-Based Modes** - Capture the Flag, Team Deathmatch, Conquest
- **Objective Modes** - Bomb Defusal, Extraction, King of the Hill
- **Racing Modes** - Vehicle races, time trials, checkpoint systems
- **Custom Mechanics** - Climbing races, parkour challenges, obstacle courses
- **Co-op PvE** - AI enemies, wave defense, boss battles

### Key Features

::: tip COMPLETE API
Access to 545 functions across 14 categories:
- Player Control (120+ functions)
- UI System (104 functions)
- VFX & Audio (45+ functions)
- AI System (25+ functions)
- And many more...
:::

## How It Works

### Three-Step Workflow

1. **Edit in Godot** - Open a map, place objects, configure properties
2. **Export to JSON** - Convert Godot scene to `.spatial.json` format
3. **Script in TypeScript** - Write game logic using the complete API
4. **Upload to Portal** - Publish on portal.battlefield.com

### Architecture

```
┌─────────────────┐
│  Godot Editor   │  ← Visual spatial editing
│   (Map Layout)  │
└────────┬────────┘
         │ Export
         ▼
┌─────────────────┐
│  .spatial.json  │  ← Spatial data
└────────┬────────┘
         │
         │ Upload
         ▼
┌─────────────────────────────────┐
│   TypeScript Game Logic         │  ← 545 API functions
│   • OnGameModeStarted()         │
│   • OnPlayerJoinGame()          │
│   • OnPlayerDied()              │
│   • Custom game mechanics       │
└─────────────────────────────────┘
         │
         │ Upload
         ▼
┌─────────────────┐
│ Portal Website  │  ← portal.battlefield.com
│ (Publish)       │
└─────────────────┘
```

## SDK Components

### 1. Godot 4.4.1 Editor

- **Purpose**: Visual level editing and object placement
- **File**: `Godot_v4.4.1-stable_win64.exe` (156 MB)
- **Features**:
  - Full 3D spatial editor
  - Per-map object libraries
  - Custom BFPortal plugin
  - Export to JSON functionality

### 2. TypeScript API

- **Purpose**: Game logic scripting
- **File**: `code/mod/index.d.ts` (14,106 lines)
- **Features**:
  - Complete type definitions
  - 545 documented functions
  - 7 event hooks
  - 41 enumerations

### 3. Helper Library (modlib)

- **Purpose**: Common utility functions
- **File**: `code/modlib/index.ts` (720 lines)
- **Features**:
  - Array operations
  - UI builder (declarative)
  - Condition state tracking
  - Notification helpers

### 4. Python Converters

- **Purpose**: Bidirectional Godot ↔ JSON conversion
- **Location**: `code/gdconverter/`
- **Features**:
  - Export: `.tscn` → `.spatial.json`
  - Import: `.spatial.json` → `.tscn`

## Available Maps

The SDK includes 9 official Battlefield maps:

| Map Code | Name | Description |
|----------|------|-------------|
| `MP_Dumbo` | Manhattan Bridge | Brooklyn, New York |
| `MP_Abbasid` | Siege of Cairo | Cairo, Egypt |
| `MP_Tungsten` | Mirak Valley | Tajikistan |
| `MP_Outskirts` | New Sobek City | Egypt |
| `MP_Aftermath` | Empire State | New York |
| `MP_Battery` | Iberian Offensive | Gibraltar |
| `MP_Capstone` | Liberation Peak | Antarctica |
| `MP_Firestorm` | Operation Firestorm | Turkmenistan |
| `MP_Limestone` | Saint's Quarter | France |

## Core Capabilities

### Player System
- Movement control (teleport, speed, jump height)
- Health management (damage, healing, revive)
- Loadout customization (weapons, gadgets, equipment)
- Input restrictions (disable specific actions)
- Spawning and deployment

### AI System
- 7 behavior types (BattlefieldAI, Patrol, Defend, etc.)
- Combat control (shooting, targeting, damage)
- Movement (speed, stance, waypoints)
- Spawning and despawning

### UI System
- 5 widget types (Container, Text, Image, Button, ProgressBar)
- Per-player UI instances
- Full positioning and styling
- Notification system (5 slots)
- JSON declarative builder

### Teams & Scoring
- Up to 9 teams
- Custom team names and colors (14 color options)
- Score tracking (player and team)
- Victory conditions
- Time limits

### Vehicles
- 47 vehicle types
- Spawning and control
- Health and damage
- Passenger management
- Custom properties (speed, damage multiplier)

### VFX & Audio
- 100+ visual effects
- 3D positional audio
- Voice-over system
- Particle effects

## Who Is This For?

### Ideal Users

✅ **Game Mode Designers** - Create custom Battlefield experiences
✅ **TypeScript Developers** - Leverage programming skills for game logic
✅ **Level Designers** - Use Godot for spatial layout
✅ **Battlefield Players** - Build and share community experiences
✅ **Modders** - Extend Battlefield 2042 with custom content

### Prerequisites

- **Basic TypeScript knowledge** (or willingness to learn)
- **Godot familiarity** (helpful but not required)
- **Battlefield 2042** (to test and publish)
- **Windows PC** (Godot editor is Windows-only)

## Getting Started

Ready to build your first custom game mode?

→ **[Continue to Getting Started Guide](/guides/getting-started)**

## Example Projects

The SDK includes 4 complete working examples:

1. **Vertigo** (308 lines) - 4-team vertical climbing race
2. **AcePursuit** (800 lines) - 8-player vehicle racing
3. **BombSquad** (800 lines) - 5v5 tactical defuse mode
4. **Exfil** (1000 lines) - 4-team extraction with AI enemies

Each example demonstrates different aspects of the API and serves as a reference for your own projects.

## Community & Support

- **GitHub Issues**: Report bugs or request features
- **Email**: andrew@virusgaming.org
- **Documentation**: Full API reference and tutorials included

## Next Steps

1. **[Getting Started](/guides/getting-started)** - Set up your development environment
2. **[SDK Overview](/guides/sdk-overview)** - Understand the SDK structure
3. **[Installation](/guides/installation)** - Install and configure tools
4. **[Development Workflow](/guides/workflow)** - Learn the end-to-end process

---

::: info SDK VERSION
Current SDK Version: **1.0.1.0**
Godot Version: **4.4.1**
Last Updated: October 2024
:::
