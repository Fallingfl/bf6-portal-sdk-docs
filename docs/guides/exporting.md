# Exporting & Upload

Learn how to export your Godot scenes to `.spatial.json` format and upload your custom game modes to the Battlefield Portal platform.

## Overview

The export process converts your Godot scene into a format that the Battlefield Portal platform understands. This involves:

1. **Export from Godot** - Convert `.tscn` scene to `.spatial.json`
2. **Prepare TypeScript** - Finalize your game logic code
3. **Upload to Portal** - Publish on portal.battlefield.com
4. **Test & Iterate** - Refine your experience

## Export from Godot

### Method 1: Godot Export Button (Recommended)

The easiest way to export your level:

1. **Open Your Level**
   - Scene → Open Scene
   - Navigate to `levels/YourLevel.tscn`

2. **Click Export Button**
   - Look for **BFPortal** tab on right side
   - Click **"Export Current Level"** button
   - Choose save location
   - File will be saved as `[MapName].spatial.json`

::: tip Export Location
Save exports to a dedicated folder like:
- `PortalSDK/exports/`
- Makes it easy to find files for upload
:::

3. **Verify Export**
   - Open the `.spatial.json` file in a text editor
   - Should see JSON with `"Portal_Dynamic"` and `"Static"` sections
   - Check file size (typically 10KB-500KB depending on objects)

### Method 2: Python Export Script

For advanced users or automation:

```bash
cd /path/to/PortalSDK

python code/gdconverter/src/gdconverter/export_tscn.py \
  "GodotProject/levels/YourLevel.tscn" \
  "FbExportData/" \
  "exports/"
```

**Parameters:**
- **Arg 1**: Path to your `.tscn` file
- **Arg 2**: Path to `FbExportData/` folder (SDK resources)
- **Arg 3**: Output directory for `.spatial.json`

**Output:**
```
Exporting YourLevel.tscn...
Processing 45 objects...
Export complete: exports/YourLevel.spatial.json
```

### What Gets Exported?

The spatial export includes:

#### Static Objects
Pre-placed objects from your Godot scene:
- Terrain
- Buildings
- Props
- Barriers
- Combat areas

#### Portal_Dynamic Objects
Gameplay objects you can reference in code:
- **Spawners** (PlayerSpawner, HQ_PlayerSpawner)
- **Vehicle Spawners** (VehicleSpawner)
- **AI Spawners** (AISpawner)
- **Triggers** (AreaTrigger)
- **Interact Points** (InteractPoint)
- **Capture Points** (CapturePoint)
- **World Icons** (WorldIcon)

#### Object Data Stored
For each object:
```json
{
  "name": "PlayerSpawner_1",
  "type": "PlayerSpawner",
  "objId": 1,
  "position": {"x": 100.0, "y": 0.0, "z": 50.0},
  "right": {"x": 1.0, "y": 0.0, "z": 0.0},
  "up": {"x": 0.0, "y": 1.0, "z": 0.0},
  "front": {"x": 0.0, "y": 0.0, "z": 1.0}
}
```

### What Does NOT Get Exported?

These are NOT included in spatial export:
- ❌ Game logic (write in TypeScript)
- ❌ UI elements (create in TypeScript)
- ❌ Victory conditions (define in TypeScript)
- ❌ Player loadouts (set in TypeScript)
- ❌ Team configurations (configure in TypeScript)

The spatial file is **ONLY** for object placement!

## Spatial JSON Format

Understanding the format helps debug issues:

### Basic Structure

```json
{
  "Portal_Dynamic": [
    {
      "name": "PlayerSpawner_1",
      "type": "PlayerSpawner",
      "objId": 1,
      "position": {"x": 0, "y": 0, "z": 0},
      "right": {"x": 1, "y": 0, "z": 0},
      "up": {"x": 0, "y": 1, "z": 0},
      "front": {"x": 0, "y": 0, "z": 1}
    }
  ],
  "Static": [
    {
      "name": "MP_Dumbo_Terrain",
      "type": "MP_Dumbo_Terrain",
      "position": {"x": 0, "y": 0, "z": 0},
      "right": {"x": 1, "y": 0, "z": 0},
      "up": {"x": 0, "y": 1, "z": 0},
      "front": {"x": 0, "y": 0, "z": 1}
    }
  ]
}
```

### Transform Vectors

Each object has 4 vectors defining its transform:

**Position** - World coordinates (x, y, z)
- In meters
- Battlefield uses Z-up coordinate system

**Right** - Local X-axis direction
- Points to the object's right
- Unit vector (length = 1.0)

**Up** - Local Y-axis direction
- Points upward from object
- Unit vector (length = 1.0)

**Front** - Local Z-axis direction
- Points forward from object
- Unit vector (length = 1.0)

::: tip Coordinate System
Battlefield Portal uses **Z-up** coordinates:
- **X** = Left/Right
- **Y** = Forward/Back
- **Z** = Up/Down
:::

### Object Types

Common object types in exports:

**Spawners:**
- `PlayerSpawner` - Basic player spawn
- `HQ_PlayerSpawner` - HQ spawn (team-specific)
- `VehicleSpawner` - Vehicle spawn point
- `AISpawner` - AI bot spawn

**Gameplay:**
- `AreaTrigger` - Zone detection
- `InteractPoint` - Player interaction
- `CapturePoint` - Conquest-style capture
- `WorldIcon` - 3D marker icon

**Map Elements:**
- `[MapName]_Terrain` - Ground terrain
- `[MapName]_Buildings` - Structures
- Various props and decorations

## Prepare TypeScript Code

Before uploading, finalize your TypeScript:

### 1. Test Locally

```typescript
// Add console logging for debugging
export async function OnGameModeStarted() {
  console.log("=== GAME MODE STARTED ===");
  console.log("SDK Version: 1.0.1.0");

  // Test all your systems
  testSpawners();
  testTriggers();
  testUI();
}

function testSpawners() {
  const spawner = mod.GetSpawner(1);
  if (spawner) {
    console.log("✅ Spawner 1 found");
  } else {
    console.log("❌ Spawner 1 NOT FOUND");
  }
}
```

### 2. Remove Debug Code

```typescript
// ❌ Remove before upload:
// console.log("Debug: X =", x);
// debugShowAllObjects();
// testMode = true;

// ✅ Keep essential logging:
console.log("Game mode started");
console.log("Player joined:", mod.GetPlayerName(player));
```

### 3. Verify Obj IDs Match

Ensure your TypeScript references match Godot Obj IDs:

```typescript
// Godot: Set Obj Id = 1 on PlayerSpawner
// TypeScript: Reference with matching ID
const spawner = mod.GetSpawner(1);  // Must match!

// Godot: Set Obj Id = 10 on AreaTrigger
const trigger = mod.GetAreaTrigger(10);  // Must match!
```

### 4. Add Comments

```typescript
// ========================================
// KING OF THE HILL - Custom Game Mode
// Author: synthetic-virus
// Version: 1.0
// ========================================

export async function OnGameModeStarted() {
  // Initialize 10-minute match
  mod.SetGameTimeLimit(600);

  // Set up 2 teams
  setupTeams();

  // Start capture point system
  startCaptureSystem();
}
```

## Upload to Portal

### Access Portal Website

1. Navigate to **https://portal.battlefield.com**
2. Log in with your account
3. Click **"Create New Experience"** or **"My Experiences"**

### Upload Process

#### Step 1: Basic Information

Fill in experience details:
- **Experience Name** - "Ace Pursuit Racing"
- **Description** - What your mode does
- **Tags** - Racing, Vehicles, etc.
- **Thumbnail** - Optional screenshot

#### Step 2: Map Selection

Choose which map your spatial file is for:
- MP_Dumbo (Manhattan Bridge)
- MP_Abbasid (Siege of Cairo)
- MP_Tungsten (Mirak Valley)
- etc.

::: warning Map Must Match
Your `.spatial.json` must be from the map you select! Mismatches will cause errors.
:::

#### Step 3: Upload Spatial File

1. Click **"Upload Spatial Layout"**
2. Select your `.spatial.json` file
3. Wait for upload (usually 5-30 seconds)
4. Check for validation errors

**Common Errors:**
- "Invalid object type" - Used object not available on this map
- "Missing terrain" - Must include base map terrain
- "Invalid transform" - Object rotation/scale issue

#### Step 4: Add Game Logic

Choose scripting method:

**Option A: TypeScript (Recommended)**

1. Click **"Script"** tab
2. Select **"TypeScript"** mode
3. **Paste** your `.ts` file contents OR
4. **Upload** `.ts` file directly
5. Check for syntax errors

**Option B: Blockly (Visual)**

1. Click **"Script"** tab
2. Use **drag-and-drop blocks**
3. Limited functionality compared to TypeScript

::: tip TypeScript vs Blockly
- **TypeScript**: Full 545 API functions, complex logic
- **Blockly**: Beginner-friendly, ~100 functions, visual
- **Recommendation**: Use TypeScript for anything beyond simple modes
:::

#### Step 5: Configure Settings

Set game parameters:
- **Max Players** - 2 to 128
- **Team Count** - 1 to 9 teams
- **Time Limit** - No limit or set minutes
- **Fill With Bots** - Yes/No
- **Bot Difficulty** - Easy/Medium/Hard

::: warning These Can Override Your Code
Portal settings may override TypeScript values!
- If you set `mod.SetMaxPlayerCount(32)` but Portal setting is 64, Portal wins
- Test with various settings to ensure compatibility
:::

#### Step 6: Save & Publish

1. Click **"Save Draft"** to save work
2. Click **"Publish"** when ready
3. Choose visibility:
   - **Private** - Only you can see
   - **Unlisted** - Anyone with link
   - **Public** - Listed in Portal browser

### Post-Upload

After publishing:
- **Share Code** - Portal generates a code (e.g., AAAA-BBBB-CCCC)
- **Share Link** - Direct link to experience
- **Track Stats** - Views, plays, likes

## Testing Your Experience

### Test Mode

1. Click **"Test Experience"** in Portal
2. Game launches with your mode loaded
3. You're the only player unless you invite

**Testing Checklist:**
- ✅ Players spawn correctly?
- ✅ Triggers detect players?
- ✅ UI displays properly?
- ✅ Victory conditions work?
- ✅ No errors in console?

### Invite Friends

Test with multiple players:
1. Start test experience
2. Invite friends from in-game
3. Test team mechanics
4. Verify networking works

### Add Bots

Fill server with AI for testing:
1. Enable "Fill With Bots" in settings
2. Set bot difficulty
3. Test against AI enemies

## Common Export Issues

### Issue: Export Button Doesn't Work

**Causes:**
- Portal Setup not run
- Godot crashed during setup
- File permissions

**Solutions:**
```bash
# Re-run Portal Setup
1. Close Godot
2. Reopen project
3. BFPortal tab → "Portal Setup"
4. Wait for completion
5. Try export again
```

### Issue: Objects Missing After Export

**Causes:**
- Objects not in correct layer
- Objects disabled in Godot
- Wrong object tab used (map-specific vs Global)

**Solutions:**
1. Check object visibility in Scene Outliner
2. Verify object is from correct tab (map-specific or Global)
3. Check Inspector: "Visible" should be checked
4. Re-export after fixing

### Issue: "Invalid Object Type" on Upload

**Causes:**
- Used object from wrong map
- Object not supported by Portal

**Solutions:**
1. Check which map tab object came from
2. Only use Global objects OR objects from current map
3. Remove unsupported objects
4. Re-export

### Issue: Obj IDs Not Working in Code

**Causes:**
- Typo in Obj Id
- Forgot to set Obj Id in Godot
- Wrong getter function

**Solutions:**
```typescript
// ❌ Wrong getter for object type
const spawner = mod.GetAreaTrigger(1);  // Wrong function!

// ✅ Correct getter
const spawner = mod.GetSpawner(1);

// ✅ Check if object exists
if (!spawner) {
  console.log("ERROR: Spawner 1 not found! Check Obj Id in Godot.");
  return;
}
```

### Issue: Spatial File Too Large

**Causes:**
- Too many objects (thousands)
- Excessive detail

**Solutions:**
1. Remove unnecessary decorative objects
2. Simplify scene complexity
3. Use fewer unique objects
4. Battlefield has limits (~2000 objects per map)

## Version Control

### Save Multiple Versions

Keep backups of working versions:

```
exports/
├── MyMode_v1.0.spatial.json
├── MyMode_v1.1.spatial.json
├── MyMode_v2.0.spatial.json
└── MyMode_latest.spatial.json
```

### Track Changes

Document what changed:

```typescript
// ========================================
// VERSION HISTORY
// ========================================
// v1.0 - Initial release
// v1.1 - Added 5 more spawn points
// v1.2 - Fixed trigger zone sizes
// v2.0 - Complete redesign with new layout
```

### Godot Scene Versions

Save scene backups:
```
GodotProject/levels/
├── MyLevel.tscn          (current)
├── MyLevel_backup.tscn   (last working)
├── MyLevel_v1.tscn       (v1 release)
└── MyLevel_v2.tscn       (v2 release)
```

## Best Practices

### 1. Test Before Upload

Always test locally first:
- Export spatial file
- Check file size
- Open in text editor
- Verify object count
- Check Obj IDs are set

### 2. Use Descriptive Names

```typescript
// ❌ Bad naming
const s1 = mod.GetSpawner(1);
const t5 = mod.GetAreaTrigger(5);

// ✅ Good naming
const blueFlagSpawner = mod.GetSpawner(1);
const captureZoneTrigger = mod.GetAreaTrigger(5);
```

### 3. Document Obj IDs

Keep a reference of what each ID is:

```typescript
// ========================================
// OBJECT ID REFERENCE
// ========================================
// Spawners (1-20):
//   1 - Blue team HQ spawn
//   2 - Red team HQ spawn
//   3-10 - Neutral spawn points
//
// Triggers (21-40):
//   21 - Capture Point A
//   22 - Capture Point B
//   23 - Out of bounds zone
//
// AI Spawners (41-60):
//   41-45 - Enemy patrol spawns
//   46-50 - Guard spawns
```

### 4. Incremental Testing

Don't upload huge changes:
1. Export basic level → Test
2. Add triggers → Export → Test
3. Add spawners → Export → Test
4. Add AI → Export → Test

### 5. Keep Spatial Files Small

Optimize for upload speed:
- Remove unnecessary objects
- Simplify geometry where possible
- Use fewer unique object types
- Target: < 200KB if possible

## Next Steps

- 📖 [TypeScript Scripting](/guides/typescript-scripting) - Write game logic
- 📖 [Event Hooks](/guides/event-hooks) - Understand event system
- 🎓 [Tutorials](/tutorials/) - Hands-on learning
- 📚 [Examples](/examples/) - Study complete mods

---

::: tip Quick Upload Checklist
1. ✅ Export `.spatial.json` from Godot
2. ✅ Verify Obj IDs are set in Inspector
3. ✅ Test TypeScript locally with console logging
4. ✅ Remove debug code
5. ✅ Upload spatial file to Portal
6. ✅ Paste/upload TypeScript code
7. ✅ Configure experience settings
8. ✅ Test with "Test Experience" button
9. ✅ Publish when ready!
:::
