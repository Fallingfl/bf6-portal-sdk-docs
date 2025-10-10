# Tutorials

Step-by-step guides to help you build custom game modes for Battlefield 2042 Portal.

## Learning Path

Our tutorials are organized into three progressive difficulty levels. We recommend following them in order, especially if you're new to the Portal SDK.

---

## 🌱 Beginner Tutorials

Perfect for getting started with Portal SDK development. No prior game development experience required.

### [Your First Game Mode](/tutorials/first-game-mode)
**Time: 20 minutes** | **Difficulty: ★☆☆☆☆**

Create a simple Team Deathmatch mode from scratch. Learn the basics of:
- Setting up your development environment
- Writing your first TypeScript code
- Using event hooks
- Testing your game mode

**What you'll build:** A functional TDM mode with teams, spawning, and score tracking.

---

### [Understanding Event Hooks](/tutorials/event-hooks-tutorial)
**Time: 15 minutes** | **Difficulty: ★☆☆☆☆**

Master the 7 event hooks that drive all Portal game modes:
- OnGameModeStarted
- OnPlayerJoinGame
- OnPlayerDeployed
- OnPlayerDied
- OnPlayerEarnedKill
- OnPlayerLeaveGame
- OnPlayerSwitchTeam

**What you'll learn:** When each hook fires, how to use them, and common patterns.

---

### [Building a Simple UI](/tutorials/simple-ui)
**Time: 25 minutes** | **Difficulty: ★★☆☆☆**

Create your first heads-up display (HUD):
- Text labels for score and status
- Player-specific UI elements
- Positioning and anchoring
- UI visibility control

**What you'll build:** A scoreboard HUD showing kills, deaths, and team scores.

---

### [Working with Teams](/tutorials/teams-tutorial)
**Time: 20 minutes** | **Difficulty: ★★☆☆☆**

Learn team management and team-based gameplay:
- Assigning players to teams
- Auto-balancing teams
- Team scoring systems
- Team colors and customization

**What you'll build:** A 2-team game mode with automatic balancing and team victory conditions.

---

## 🌿 Intermediate Tutorials

Build on your foundational knowledge with more complex systems. Assumes completion of beginner tutorials.

### [Checkpoint System](/tutorials/checkpoint-system)
**Time: 30 minutes** | **Difficulty: ★★★☆☆**

Implement a checkpoint-based progression system:
- Area trigger detection
- Sequential checkpoint validation
- Progress tracking per player
- Visual feedback with UI

**What you'll build:** A racing checkpoint system that prevents skipping and tracks progress.

---

### [Custom Spawning Logic](/tutorials/custom-spawning)
**Time: 25 minutes** | **Difficulty: ★★★☆☆**

Control where and when players spawn:
- Dynamic spawn point selection
- Team-based spawning
- Wave-based spawning
- Spawn protection

**What you'll build:** A wave-based spawn system for a battle royale-style mode.

---

### [AI Enemies Setup](/tutorials/ai-enemies)
**Time: 35 minutes** | **Difficulty: ★★★☆☆**

Add AI-controlled enemies to your game mode:
- AI spawner configuration
- Behavior assignment (patrol, defend, attack)
- AI difficulty tuning
- AI event handling

**What you'll build:** A co-op PvE mode with patrolling AI enemies.

---

### [Vehicle Racing Mechanics](/tutorials/vehicle-racing)
**Time: 40 minutes** | **Difficulty: ★★★★☆**

Create a vehicle-based racing game:
- Vehicle spawning and assignment
- Lap tracking
- Leaderboard systems
- Rubber-banding catchup mechanics

**What you'll build:** A lap-based vehicle racing mode with real-time rankings.

---

## 🌳 Advanced Tutorials

Complex systems for experienced developers. Covers production-ready patterns and optimization.

### [Round-Based Systems](/tutorials/round-based)
**Time: 45 minutes** | **Difficulty: ★★★★☆**

Build a multi-round game mode architecture:
- Round state management
- Round transitions and cleanup
- Score persistence across rounds
- Best-of-N victory conditions

**What you'll build:** A 5-round game mode with halftime team switching.

---

### [Economy & Buy Phase](/tutorials/economy-system)
**Time: 50 minutes** | **Difficulty: ★★★★★**

Implement a tactical shooter economy system:
- Money management per player
- Buy phase timing and UI
- Equipment purchasing
- Economy balancing (kill rewards, round bonuses)

**What you'll build:** A Counter-Strike-style buy phase with weapon purchasing.

---

### [Complex UI Layouts](/tutorials/complex-ui)
**Time: 40 minutes** | **Difficulty: ★★★★☆**

Master advanced UI techniques:
- Container hierarchies
- Dynamic UI generation
- UI animations (fade in/out)
- Responsive layouts

**What you'll build:** A full scoreboard with player stats, team sections, and dynamic updates.

---

### [Performance Optimization](/tutorials/optimization)
**Time: 35 minutes** | **Difficulty: ★★★★☆**

Optimize your game mode for smooth performance:
- Async loop best practices
- Caching and avoiding redundant API calls
- UI update batching
- Memory management

**What you'll learn:** Profiling techniques and optimization patterns for 64-player servers.

---

## 💡 Additional Resources

### Code Snippets
Quick reference examples for common tasks:
- [Common Patterns](/examples/common-patterns) - Frequently used code patterns
- [UI Examples](/examples/ui-examples) - UI widget examples
- [AI Behaviors](/examples/ai-examples) - AI configuration examples

### Example Game Modes
Complete, production-ready game modes:
- [Vertigo](/examples/vertigo) - 4-team climbing race (308 lines)
- [AcePursuit](/examples/acepursuit) - Vehicle racing (~800 lines)
- [BombSquad](/examples/bombsquad) - Tactical defuse (~800 lines)
- [Exfil](/examples/exfil) - Extraction mode (~1000 lines)

### API Reference
Complete function documentation:
- [Player System](/api/player-control) - 120+ player functions
- [UI System](/api/ui-widgets) - 104+ UI functions
- [AI System](/api/ai-overview) - 25+ AI functions
- [All API Pages](/api/) - 545+ total functions

---

## 🎯 Recommended Learning Paths

### Path 1: Team-Based Shooter
1. Your First Game Mode
2. Understanding Event Hooks
3. Working with Teams
4. Building a Simple UI
5. Round-Based Systems
6. Economy & Buy Phase

**Result:** Build modes like Team Deathmatch, Domination, or BombSquad.

---

### Path 2: Racing Game
1. Your First Game Mode
2. Understanding Event Hooks
3. Checkpoint System
4. Vehicle Racing Mechanics
5. Building a Simple UI
6. Complex UI Layouts

**Result:** Build modes like AcePursuit or circuit racing.

---

### Path 3: Co-op PvE
1. Your First Game Mode
2. Understanding Event Hooks
3. AI Enemies Setup
4. Custom Spawning Logic
5. Building a Simple UI
6. Performance Optimization

**Result:** Build modes like Exfil or horde defense.

---

## ❓ Getting Help

- **Stuck on a tutorial?** Check the corresponding [API reference](/api/) page for detailed function documentation
- **Want to see a complete example?** Review the [example game modes](/examples/)
- **Need conceptual background?** Read the [guides section](/guides/)

Happy modding! 🎮
