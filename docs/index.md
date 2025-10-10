---
layout: home

hero:
  name: "BF6 Portal SDK"
  text: "Create Custom Game Modes"
  tagline: Build incredible Battlefield experiences with TypeScript and Godot
  image:
    src: https://drop-assets.ea.com/images/1bpD5zqqp6ndkbOtPnZeqO/f95a145e1e8fb8b6c97170a420958641/battlefield-6-phantom-edition-16x9.jpg?im=Resize=(1280)&q=85
    alt: Battlefield 6 Phantom Edition
  actions:
    - theme: brand
      text: Get Started
      link: /guides/getting-started
    - theme: alt
      text: API Reference
      link: /api/
    - theme: alt
      text: View Examples
      link: /examples/

features:
  - icon: 🎮
    title: 545 API Functions
    details: Complete TypeScript API with comprehensive control over players, AI, vehicles, UI, and game logic
  - icon: 🗺️
    title: 9 Maps Available
    details: Create experiences on Cairo, Manhattan, Tajikistan, and 6 other iconic Battlefield maps
  - icon: 🤖
    title: Advanced AI System
    details: 7 AI behaviors including combat, patrol, defend, and custom waypoint systems
  - icon: 🎨
    title: Custom UI Builder
    details: 104 UI functions to create containers, buttons, progress bars, notifications, and scoreboards
  - icon: 🚗
    title: 47 Vehicle Types
    details: Spawn and control tanks, helicopters, jets, and more with full vehicle API
  - icon: 🔧
    title: Godot 4.4.1 Editor
    details: Visual spatial editor for placing 14,000+ objects with real-time preview
  - icon: 💥
    title: VFX & Audio
    details: 100+ visual effects and 3D positional audio system for immersive experiences
  - icon: 📦
    title: 14,000+ Objects
    details: Spawn props, barriers, debris, and gameplay objects at runtime
  - icon: 📚
    title: 4 Complete Examples
    details: Study working game modes including racing, tactical, extraction, and climbing modes
---

## Quick Example

Create a simple Free-For-All deathmatch in just a few lines:

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';

export async function OnGameModeStarted() {
  // Set up game mode
  mod.SetGameTimeLimit(600); // 10 minutes
  mod.SetMaxPlayerCount(16);
}

export async function OnPlayerJoinGame(player: mod.Player) {
  // Assign to FFA team
  mod.SetPlayerTeam(player, mod.Team.Team1);

  // Spawn player
  const spawner = mod.GetSpawner(1);
  mod.SpawnPlayerFromSpawnPoint(player, spawner);

  // Show welcome message
  modlib.DisplayCustomNotificationMessage(
    "Welcome to the arena!",
    mod.NotificationSlot.MessageText1,
    5,
    player
  );
}

export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player
) {
  // Award points
  const currentScore = mod.GetPlayerScore(killer);
  mod.SetPlayerScore(killer, currentScore + 100);

  // Check for winner
  if (currentScore + 100 >= 3000) {
    mod.SetWinningPlayer(killer);
    mod.EndGame();
  }
}
```

## Why BF6 Portal SDK?

The Battlefield 6 Portal SDK gives you unprecedented control over custom game mode creation. Unlike the web-based Blockly editor, this SDK provides:

- **Full TypeScript Support** - Write complex logic with proper types and IDE support
- **Godot Visual Editor** - Place and configure objects visually before exporting
- **Complete API Access** - All 545 functions at your fingertips
- **No Limitations** - Build anything from racing to tactical to extraction modes

## System Requirements

- **Godot 4.4.1** (included in SDK)
- **Python 3.x** (bundled with SDK)
- **Node.js 18+** (for TypeScript development)
- **Portal Account** (for uploading to https://portal.battlefield.com)

## Community & Support

- **SDK Version**: 1.0.1.0
- **Maintained by**: synthetic-virus
- **Email**: andrew@virusgaming.org

---

<div style="text-align: center; margin-top: 2rem;">
  <a href="/guides/getting-started" style="display: inline-block; padding: 12px 24px; background: rgba(255, 255, 255, 0.15); color: white; border: 1px solid rgba(255, 255, 255, 0.3); text-decoration: none; font-weight: 600; text-transform: uppercase; letter-spacing: 1px;">Start Building →</a>
</div>
