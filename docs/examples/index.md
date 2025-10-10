# Example Game Modes

Complete, production-ready game modes demonstrating advanced Portal SDK features.

## Overview

These examples are fully functional game modes extracted from real Portal experiences. Each one demonstrates different SDK capabilities and design patterns you can learn from and adapt for your own modes.

---

## 🎮 Complete Game Modes

### [Vertigo: Climbing Race](/examples/vertigo)

**Players:** 1-16 (4 teams) | **Lines:** 308 | **Difficulty:** Beginner-Intermediate

A vertical climbing race where teams compete to reach checkpoints at increasing heights.

**Key Features:**
- 4-team competitive gameplay
- Checkpoint-based progression
- Teleportation mechanics
- Custom lobby and countdown system
- Victory condition based on first team to complete all checkpoints

**SDK Systems Demonstrated:**
- ✅ Team management and scoring
- ✅ Area trigger detection (checkpoints)
- ✅ Player teleportation
- ✅ UI notifications
- ✅ Game mode lifecycle management

**Best For:** Learning team-based game modes and checkpoint systems.

---

### [AcePursuit: Vehicle Racing](/examples/acepursuit)

**Players:** 1-8 | **Lines:** ~800 | **Difficulty:** Advanced

8-player vehicle racing with lap tracking, checkpoint validation, and rubber-banding mechanics.

**Key Features:**
- Lap-based racing (configurable laps per track)
- Sequential checkpoint system (prevents skipping)
- Vehicle spawning and assignment
- Real-time scoreboard with race positions
- Rubber-banding catchup mechanics for trailing players
- AI competitor support (14 spawn points)
- Ready-up system with countdown

**SDK Systems Demonstrated:**
- ✅ Vehicle spawning and control
- ✅ Complex checkpoint tracking with state machines
- ✅ Dynamic UI (scoreboard, lap counter, position display)
- ✅ Player state tracking with classes
- ✅ AI integration
- ✅ Performance optimization (different update frequencies)

**Best For:** Learning vehicle systems, complex state management, and competitive racing mechanics.

---

### [BombSquad: Tactical Defuse](/examples/bombsquad)

**Players:** 2-10 (5v5) | **Lines:** ~800 | **Difficulty:** Advanced

Tactical 5v5 bomb defusal mode with economy system, buy phases, and round-based gameplay.

**Key Features:**
- Round-based gameplay (14 rounds, team switch at halftime)
- Economy system (earn money from kills/rounds)
- Buy phase (30 seconds to purchase weapons)
- Bomb plant/defuse mechanics with progress bars
- Multiple bomb sites (A/B)
- Overtime system for tied matches
- Player roles (attackers vs defenders)

**SDK Systems Demonstrated:**
- ✅ Round state management
- ✅ Economy system with persistent player data
- ✅ Interactive objects (bomb sites)
- ✅ Progress bar UI for timed actions
- ✅ Buy menu UI system
- ✅ Complex game flow (buy → action → round end → repeat)
- ✅ Team switching and role swapping

**Best For:** Learning round-based systems, economy mechanics, and complex UI interactions.

---

### [Exfil: Extraction Mode](/examples/exfil)

**Players:** 4-16 (4 teams) | **Lines:** ~1000 | **Difficulty:** Expert

4-team extraction mode where teams compete to retrieve items and extract them to their base.

**Key Features:**
- 4-team objective-based gameplay
- Item pickup/drop system with physics
- Carrier debuffs (slower movement, reduced health)
- Dynamic extraction zones per team
- AI enemy spawning (13 spawn points)
- Item respawn system
- Time limit with sudden death

**SDK Systems Demonstrated:**
- ✅ Object spawning and manipulation
- ✅ Item carrier mechanics with state tracking
- ✅ Status effects (speed/health modifiers)
- ✅ AI enemy integration
- ✅ Multi-objective gameplay
- ✅ Complex spatial object management
- ✅ Team-specific zones and objectives

**Best For:** Learning object interaction, AI enemies, and multi-team objective modes.

---

## 📚 Code Snippet Collections

Quick reference examples for common tasks. Perfect when you need to quickly find how to do something specific.

### [Common Patterns](/examples/common-patterns)

Frequently used code patterns and utilities:
- Player proximity detection
- Circular zone checks
- Grid positioning
- Distance calculations
- Timer systems
- State machines
- Array operations

---

### [UI Examples](/examples/ui-examples)

Pre-built UI components you can copy and adapt:
- Scoreboards (simple and complex)
- HUD elements (health, ammo, timers)
- Menus (ready-up, buy phase, settings)
- Progress bars (loading, actions)
- Notifications and alerts
- Team indicators

---

### [AI Behaviors](/examples/ai-examples)

AI configuration examples:
- Patrol routes with waypoints
- Defend location setup
- Attack specific targets
- AI difficulty tuning
- Mixed AI behaviors
- AI spawn management

---

## 🎯 Learning from Examples

### How to Use These Examples

1. **Read the Overview** - Understand what the mode does and what it demonstrates
2. **Study Key Systems** - Focus on the systems relevant to your own mode
3. **Review Code Snippets** - See practical implementations of SDK functions
4. **Copy Patterns** - Adapt the patterns to your own game mode
5. **Reference API Docs** - Look up unfamiliar functions in the [API reference](/api/)

### Progressive Learning Path

**Beginner** → Start with **Vertigo**
- Simplest example (308 lines)
- Clear structure and flow
- Demonstrates core concepts (teams, checkpoints, UI)

**Intermediate** → Study **AcePursuit**
- Moderate complexity (~800 lines)
- Introduces state management with classes
- Shows vehicle systems and dynamic UI

**Advanced** → Analyze **BombSquad**
- Complex round-based system
- Economy and buy phase mechanics
- Multi-state gameplay flow

**Expert** → Master **Exfil**
- Largest example (~1000 lines)
- Most complex state management
- Multi-team objectives with AI

---

## 🔍 Finding Specific Features

Looking for how to implement a specific feature? Use this quick reference:

| Feature | Example |
|---------|---------|
| **Teams & Scoring** | Vertigo, BombSquad |
| **Checkpoints** | Vertigo, AcePursuit |
| **Vehicles** | AcePursuit |
| **UI Systems** | All examples |
| **AI Enemies** | Exfil |
| **Round-Based** | BombSquad |
| **Economy System** | BombSquad |
| **Item Pickup/Drop** | Exfil |
| **Progress Bars** | BombSquad, AcePursuit |
| **State Machines** | AcePursuit, BombSquad, Exfil |
| **Timers** | All examples |
| **Rubber-banding** | AcePursuit |
| **Extraction Zones** | Exfil |

---

## 💾 Accessing Source Code

All example source code is available in the SDK:

```
/PortalSDK/mods/
├── Vertigo/
│   ├── index.ts           # Game logic (308 lines)
│   ├── level.tscn         # Godot scene
│   └── strings.json       # Localization
├── AcePursuit/
│   ├── index.ts           # Game logic (~800 lines)
│   ├── level.tscn
│   └── strings.json
├── BombSquad/
│   ├── index.ts           # Game logic (~800 lines)
│   ├── level.tscn
│   └── strings.json
└── Exfil/
    ├── index.ts           # Game logic (~1000 lines)
    ├── level.tscn
    └── strings.json
```

**Note:** The walkthrough pages on this site provide annotated explanations of key systems. Refer to the actual source files for complete, runnable code.

---

## 🚀 Next Steps

After studying these examples:

1. **Follow Tutorials** - Work through [step-by-step tutorials](/tutorials/) to build similar systems yourself
2. **Check API Docs** - Reference the [complete API documentation](/api/) for all available functions
3. **Build Your Own** - Start with the template and adapt patterns from these examples
4. **Test & Iterate** - Upload to Portal and test with real players

Happy modding! 🎮
