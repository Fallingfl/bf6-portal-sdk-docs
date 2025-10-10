# Getting Started

Welcome to the Battlefield 6 Portal SDK! This guide will walk you through setting up your development environment and creating your first custom game mode.

## Prerequisites

Before you begin, make sure you have:

- ✅ **Portal SDK** downloaded and extracted
- ✅ **Node.js 18+** installed ([download](https://nodejs.org/))
- ✅ **Text Editor** (VS Code recommended)
- ✅ **Portal Account** with access to https://portal.battlefield.com

::: tip SDK Location
The SDK is typically extracted to a folder like:
- Windows: `C:\Users\YourName\Downloads\PortalSDK`
- WSL: `/mnt/c/Users/YourName/Downloads/PortalSDK`
:::

## Step 1: Initial Setup

### Launch Godot Editor

1. Navigate to your SDK folder
2. Run `Godot_v4.4.1-stable_win64.exe`
3. The **Project Selection** window will open

### Import the Project

You have two options:

**Option A: Drag and Drop**
- Drag the `GodotProject` folder into the Project Selection window
- Godot will auto-import the project

**Option B: Manual Import**
- Click **Import** button
- Navigate to `GodotProject` folder
- Click **Import & Edit**

### Run Portal Setup (CRITICAL!)

::: danger IMPORTANT
This step is **REQUIRED** and only needs to be done once!
:::

After opening the project:

1. Wait for Godot to finish loading (may take 1-2 minutes)
2. Look for the **BFPortal** tab on the **right side** of the Godot interface
3. Click the **"Portal Setup"** button
4. **Wait several minutes** for setup to complete
5. You'll see console output as it processes

::: warning Be Patient
Portal Setup can take 3-5 minutes. Don't close Godot during this process!
:::

## Step 2: Open Your First Map

### Navigate to Levels

1. Click **Scene** → **Open Scene** in the top menu
2. Navigate to the `levels/` directory
3. Choose a map to edit (we'll use `MP_Dumbo.tscn` - Manhattan Bridge)

### Understanding the View

When the map opens, you might see an empty gray viewport. This is normal!

::: tip Level Geometry Location
Map geometry is often **above** the default camera position. Press your **mouse scroll wheel** and drag upward to look up and find the level!
:::

### Camera Controls

Hold **RIGHT MOUSE BUTTON** to activate camera controls:

| Action | Control |
|--------|---------|
| Pan/Tilt | Move mouse |
| Move Forward/Back | W / S keys |
| Move Left/Right | A / D keys |
| Move Up/Down | Q / E keys (in some views) |
| Change Speed | Scroll wheel |

**General Controls:**
| Action | Key |
|--------|-----|
| Zoom | Scroll wheel |
| Frame Selection | F key |

## Step 3: Understanding the Interface

### Key Panels

#### Scene Outliner (Left Side)
- Shows all objects in the level
- Organized in hierarchy
- Click to select objects

#### Inspector Panel (Right Side)
- Shows properties of selected object
- Edit transforms, settings
- **Set Obj Id** for script reference

#### Object Library (Bottom Center)
- Drag objects into the scene
- **Tabs for each map** + Global
- Only use objects from matching tab!

#### BFPortal Tab (Right Side)
- **Portal Setup** button
- **Export Current Level** button
- Validation tools

### Object Manipulation

Press these keys to change modes:

| Key | Mode | Function |
|-----|------|----------|
| **Q** | Select | Click objects in 3D view |
| **W** | Move | Translate object position |
| **E** | Rotate | Rotate object |
| **R** | Scale | Scale object (uniform only!) |
| **F** | Frame | Focus camera on selection |

::: warning Scaling Restriction
Only **uniform scaling** is supported! Scale all axes (X, Y, Z) equally.
:::

## Step 4: Add Your First Object

Let's add a spawn point for players:

### 1. Find the Object

1. Click the **Object Library** tab at the bottom
2. Look for the **Global** tab (works on all maps)
3. Search or scroll for `SpawnPoint`

### 2. Place the Object

**Method A: Drag to Scene**
- Click and drag `SpawnPoint` from library
- Drop it into the 3D viewport

**Method B: Drag to Outliner**
- Drag `SpawnPoint` into the Scene Outliner panel
- It will appear in the hierarchy

### 3. Position the Object

1. Select the `SpawnPoint` object
2. Press **W** to enter Move mode
3. Drag the arrows (X=red, Y=green, Z=blue)
4. Or type coordinates in the Inspector panel

### 4. Set Object ID

This allows you to reference this object in code:

1. Select the `SpawnPoint`
2. Look at the **Inspector** panel on the right
3. Find the **Obj Id** field
4. Enter a unique number: `1`

::: tip Object ID System
Every gameplay object you want to reference in TypeScript needs a unique Obj Id!
- Spawners: 1-50
- Triggers: 51-100
- AI Spawners: 101-150
- etc.
:::

## Step 5: Export Your Level

### Export to .spatial.json

1. Click the **BFPortal** tab on the right side
2. Click **"Export Current Level"** button
3. Choose a save location
4. The file will be saved as `[MapName].spatial.json`

::: details Manual Export (Alternative)
You can also export using Python:

```bash
cd /path/to/PortalSDK
python code/gdconverter/src/gdconverter/export_tscn.py \
  "GodotProject/levels/MP_Dumbo.tscn" \
  "FbExportData/" \
  "output/"
```
:::

### What Gets Exported?

The `.spatial.json` file contains:
- All objects you placed
- Their positions, rotations, scales
- Object IDs and configurations
- Layer organization

## Step 6: Write TypeScript Game Logic

### Create Your Script File

Create a new file called `MyFirstMode.ts`:

```typescript
import * as mod from 'bf-portal-api';
import * as modlib from './modlib';

// ========================================
// YOUR FIRST GAME MODE
// ========================================

// Called once when the game mode starts
export async function OnGameModeStarted() {
  console.log("Game mode started!");

  // Configure game settings
  mod.SetGameTimeLimit(600); // 10 minutes
  mod.SetMaxPlayerCount(16);

  // Show message to all players
  const allPlayers = modlib.ConvertArray(mod.GetPlayers());
  for (const player of allPlayers) {
    modlib.DisplayCustomNotificationMessage(
      "Welcome to My First Mode!",
      mod.NotificationSlot.HeaderText,
      5,
      player
    );
  }
}

// Called when a player joins the game
export async function OnPlayerJoinGame(player: mod.Player) {
  console.log("Player joined!");

  // Assign to a team
  mod.SetPlayerTeam(player, mod.Team.Team1);

  // Show welcome message
  modlib.DisplayCustomNotificationMessage(
    "Press [SPACE] to deploy",
    mod.NotificationSlot.MessageText1,
    3,
    player
  );
}

// Called when a player clicks Deploy button
export async function OnPlayerDeployed(player: mod.Player) {
  console.log("Player deployed!");

  // Get the spawn point we created (Obj Id 1)
  const spawner = mod.GetSpawner(1);

  // Spawn the player
  mod.SpawnPlayerFromSpawnPoint(player, spawner);

  // Give them full health
  mod.SetPlayerMaxHealth(player, 100);
}

// Called when a player dies
export async function OnPlayerDied(player: mod.Player) {
  console.log("Player died!");

  // Wait 5 seconds
  await mod.Wait(5);

  // Revive and respawn
  mod.Revive(player);
}

// Called when a player gets a kill
export async function OnPlayerEarnedKill(
  killer: mod.Player,
  victim: mod.Player,
  deathType: mod.PlayerDeathTypes,
  weapon: mod.Weapons
) {
  // Award points
  const currentScore = mod.GetPlayerScore(killer);
  mod.SetPlayerScore(killer, currentScore + 100);

  // Show kill notification
  modlib.DisplayCustomNotificationMessage(
    `+100 points! Score: ${currentScore + 100}`,
    mod.NotificationSlot.MessageText2,
    3,
    killer
  );
}
```

### Understanding the Code

#### Event Hooks
The SDK calls these functions automatically:
- `OnGameModeStarted()` - Once at startup
- `OnPlayerJoinGame(player)` - When player joins lobby
- `OnPlayerDeployed(player)` - When player clicks Deploy
- `OnPlayerDied(player)` - When player dies
- `OnPlayerEarnedKill(...)` - When player gets a kill

#### Helper Library (modlib)
The `modlib` library provides useful utilities:
- `ConvertArray()` - Convert mod.Array to JavaScript array
- `DisplayCustomNotificationMessage()` - Simplified notifications
- `ParseUI()` - JSON-based UI creation

See [modlib documentation](/api/modlib) for all helpers.

## Step 7: Upload to Portal

### Access Portal Web Builder

1. Navigate to https://portal.battlefield.com
2. Log in with your credentials
3. Click **Create New Experience**

### Upload Your Files

#### 1. Upload Spatial Layout
- Click **"Upload Spatial File"**
- Select your `.spatial.json` file
- Wait for upload to complete

#### 2. Add Game Logic
You have two options:

**Option A: TypeScript (Recommended)**
- Click **"Script"** tab
- Select **"TypeScript"** mode
- Paste your `.ts` file contents
- Or upload the file directly

**Option B: Blockly (Visual)**
- Click **"Script"** tab
- Use drag-and-drop blocks
- Less powerful but beginner-friendly

#### 3. Configure Experience Settings
- Set experience name
- Choose description
- Select map
- Configure player counts

### Test Your Experience

1. Click **"Save"**
2. Click **"Test Experience"**
3. The game will launch in test mode
4. Invite friends or add bots to test

::: tip Testing Tips
- Use bots for initial testing
- Check console for `console.log()` output
- Iterate quickly by re-uploading script
:::

## Step 8: Common Setup Issues

### Portal Setup Button Not Visible
- Make sure you're looking at the **BFPortal** tab on the **right side**
- Try closing and reopening the project

### Can't See Level Geometry
- Level is likely above you - look up!
- Press **F** key after selecting an object in Scene Outliner
- Use scroll wheel to zoom out

### Object Library Is Empty
- Make sure you clicked the correct map tab
- Try restarting Godot after Portal Setup

### Export Button Doesn't Work
- Check that Portal Setup completed successfully
- Make sure you have write permissions in the output folder

### Player Won't Spawn
- Verify you created a `SpawnPoint` or `HQ_PlayerSpawner`
- Check that `Obj Id` is set correctly
- Make sure `GetSpawner(id)` uses the correct ID

## Next Steps

Now that you have a basic game mode running:

- 📖 Read [Event Hooks Guide](/guides/event-hooks) to understand all 7 hooks
- 🎨 Learn [UI System](/api/ui-overview) to create custom interfaces
- 🤖 Explore [AI System](/api/ai-overview) to add bot enemies
- 📚 Study [Example Mods](/examples/) for advanced patterns

### Recommended Learning Path

1. ✅ Complete this Getting Started guide
2. 📖 Read [Development Workflow](/guides/workflow)
3. 🎮 Study [Vertigo Example](/examples/vertigo) (simplest example)
4. 🏗️ Build your own simple mode (Team Deathmatch, King of the Hill, etc.)
5. 📚 Explore [API Reference](/api/) for specific functions
6. 🚀 Create something amazing!

---

::: tip Need Help?
If you get stuck:
1. Check the [API Reference](/api/)
2. Study the [Example Mods](/examples/)
3. Review the [Tutorials](/tutorials/)
4. Contact: andrew@virusgaming.org
:::
