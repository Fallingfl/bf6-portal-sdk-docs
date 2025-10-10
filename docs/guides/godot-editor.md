# Godot Editor Guide

The Godot 4.4.1 spatial editor is your primary tool for map layout and object placement. This guide covers everything you need to know to efficiently work with the editor.

## Interface Overview

### Main Panels

```
┌──────────────────────────────────────────────────────────────┐
│  Menu Bar: Scene, Project, Debug, Editor, Help              │
├──────────────┬────────────────────────────────┬──────────────┤
│              │                                 │              │
│   Scene      │      3D Viewport               │   Inspector  │
│   Outliner   │                                 │   Panel      │
│              │    [Your Level Here]           │              │
│   (Object    │                                 │  (Properties)│
│    Tree)     │                                 │              │
│              │                                 │   BFPortal   │
│              │                                 │   Tab        │
├──────────────┴────────────────────────────────┴──────────────┤
│              Object Library (Map Tabs)                        │
└──────────────────────────────────────────────────────────────┘
```

### Scene Outliner (Left)

Shows hierarchical structure of your level:

```
Scene
└── MP_Dumbo (Root)
    ├── Static (Read-only terrain)
    │   ├── MP_Dumbo_Terrain
    │   └── MP_Dumbo_Buildings
    ├── Portal_Dynamic (Your objects)
    │   ├── HQ_PlayerSpawner_Team1
    │   ├── SpawnPoint_01
    │   ├── AreaTrigger_CheckpointA
    │   └── AI_Spawner_Enemies
    └── Cameras
        └── DeployCam
```

**Uses:**
- Click to select objects
- Drag to reorganize hierarchy
- Right-click for context menu
- Eye icon to hide/show

### 3D Viewport (Center)

Main editing area:

- **Render** the 3D scene
- **Navigate** with camera
- **Select** objects by clicking
- **Manipulate** with gizmos

### Inspector Panel (Right)

Properties of selected object:

```
Node: SpawnPoint
├── Transform
│   ├── Position: (x, y, z)
│   ├── Rotation: (x, y, z)
│   └── Scale: (x, y, z)
├── Script Parameters
│   └── Obj Id: 1 ← Set unique ID here
└── Object-Specific Properties
    └── [varies by object type]
```

### Object Library (Bottom)

Drag-and-drop object palette:

**Tabs:**
- **Brooklyn** (MP_Dumbo objects only)
- **Cairo** (MP_Abbasid objects only)
- **Global** (usable on all maps) ⭐
- **Gibraltar**, **Tajikistan**, etc.

::: warning Map Restrictions
Only use objects from the matching map tab or Global tab!
:::

### BFPortal Tab (Right Side)

Custom SDK tools:

- **Portal Setup** button (one-time setup)
- **Export Current Level** button
- Validation tools
- Build status

## Camera Controls

Master these controls for efficient navigation:

### Free Camera Mode

**Activate:** Hold **RIGHT MOUSE BUTTON**

While holding RMB:

| Control | Action |
|---------|--------|
| **Move Mouse** | Tilt and pan camera |
| **W** | Move forward |
| **S** | Move backward |
| **A** | Strafe left |
| **D** | Strafe right |
| **Q** | Move down |
| **E** | Move up |
| **Scroll Wheel** | Change movement speed |

**Without RMB held:**

| Control | Action |
|---------|--------|
| **Scroll Wheel** | Zoom in/out |
| **Middle Mouse Button** | Pan camera |
| **F Key** | Frame selected object |

### Movement Speed

The scroll wheel adjusts how fast the camera moves:

- Scroll **up** = faster movement (for large maps)
- Scroll **down** = slower movement (for precise work)

**Tip:** Adjust speed frequently based on task:
- **Fast** for navigating across map
- **Slow** for precise object placement

### Finding Level Geometry

::: tip Common Issue
When you first open a map, the viewport may appear empty!
:::

**Why it happens:**
- Level geometry is often above the default camera spawn
- You're looking at empty sky or ground

**Solutions:**
1. **Look up** - Drag mouse upward while holding RMB
2. **Select terrain** in Scene Outliner, press **F**
3. **Scroll out** to see larger area

## Object Manipulation

### Selection Modes

Press these keys to change interaction mode:

| Key | Mode | Cursor | Function |
|-----|------|--------|----------|
| **Q** | Select | Arrow | Click to select objects |
| **W** | Move | Cross arrows | Translate position |
| **E** | Rotate | Circular arrows | Rotate orientation |
| **R** | Scale | Box arrows | Resize object |

### Move Mode (W Key)

**Gizmo Arrows:**
- **Red** = X axis (left/right)
- **Green** = Y axis (up/down)
- **Blue** = Z axis (forward/back)

**Usage:**
1. Press **W** to enter Move mode
2. Click and drag colored arrow
3. Object moves along that axis
4. Or drag center (white box) for free movement

**Precision:**
- Hold **Ctrl** for snap-to-grid
- Type values in Inspector for exact placement

### Rotate Mode (E Key)

**Gizmo Rings:**
- **Red ring** = Rotate around X axis
- **Green ring** = Rotate around Y axis
- **Blue ring** = Rotate around Z axis

**Usage:**
1. Press **E** to enter Rotate mode
2. Click and drag colored ring
3. Object rotates around that axis

**Common Rotations:**
- **Y axis** = Compass direction (most common)
- **X axis** = Pitch up/down
- **Z axis** = Roll/tilt

::: tip Spawn Point Rotation
Player spawners should face into the playable area. Use Y-axis rotation to point them the right direction.
:::

### Scale Mode (R Key)

::: danger Uniform Scaling Only
The SDK only supports uniform scaling (all axes equal). Non-uniform scaling causes errors!
:::

**Correct Scaling:**
```
Scale: (2.0, 2.0, 2.0) ✅ Double size
Scale: (0.5, 0.5, 0.5) ✅ Half size
```

**Incorrect Scaling:**
```
Scale: (2.0, 1.0, 1.0) ❌ Stretched horizontally
Scale: (1.0, 3.0, 1.0) ❌ Stretched vertically
```

**Usage:**
1. Press **R** to enter Scale mode
2. Drag any gizmo handle
3. All axes scale equally
4. Or set uniform scale in Inspector

### Frame Selection (F Key)

**Most useful shortcut!**

1. Select object in Scene Outliner
2. Press **F** key
3. Camera moves to frame the object perfectly
4. Use this to quickly navigate to objects

## Working with Objects

### Adding Objects to Scene

**Method 1: Drag to Viewport**
1. Find object in Object Library
2. Click and hold object
3. Drag into 3D viewport
4. Release to place
5. Position appears where you released

**Method 2: Drag to Outliner**
1. Find object in Object Library
2. Drag to Scene Outliner panel
3. Drop onto scene root or specific parent
4. Object appears at origin (0,0,0)
5. Use Move mode to position

::: tip Which Method?
- **Viewport** = Quick placement at visible location
- **Outliner** = Better for specific parent or organization
:::

### Configuring Object Properties

Every gameplay object needs configuration:

#### 1. Set Object ID

**Critical for scripting!**

1. Select object
2. Look at Inspector panel
3. Find **Obj Id** field
4. Enter unique number

```typescript
// In TypeScript, reference by this ID:
const spawner = mod.GetSpawner(1);  // ID = 1
const trigger = mod.GetAreaTrigger(50);  // ID = 50
```

**ID Organization:**
| Range | Purpose |
|-------|---------|
| 1-50 | Player spawners |
| 51-100 | Area triggers |
| 101-150 | AI spawners |
| 151-200 | Vehicle spawners |
| 201-250 | Capture points |
| 251+ | Misc objects |

#### 2. Set Transform

**Position:**
- X, Y, Z coordinates
- Origin (0,0,0) is typically center of map

**Rotation:**
- Degrees around X, Y, Z axes
- Y rotation = compass direction

**Scale:**
- Must be uniform (all equal)
- Default is (1,1,1)

#### 3. Object-Specific Settings

Different objects have different properties:

**HQ_PlayerSpawner:**
- Team assignment (Team1, Team2, etc.)
- Linked spawn points

**AreaTrigger:**
- PolygonVolume (defines trigger shape)
- Trigger radius

**AI_Spawner:**
- Spawn team
- AI class
- Behavior settings

**VehicleSpawner:**
- Vehicle type
- Respawn time
- Auto-spawn enabled

### Deleting Objects

1. Select object
2. Press **Delete** key
3. Or right-click → Delete

::: warning Can't Delete Static Objects
Objects in the "Static" layer (terrain, buildings) cannot be deleted. They're part of the map itself.
:::

### Duplicating Objects

1. Select object
2. Press **Ctrl+D** (duplicate)
3. New copy appears at same location
4. Move the duplicate to new position
5. **Change Obj Id** to unique value!

Useful for:
- Multiple spawn points
- Repeated AI spawners
- Pattern of triggers

### Organizing Objects

**Use Folders in Scene Outliner:**

```
Portal_Dynamic
├── Team1_Spawns
│   ├── HQ_PlayerSpawner_Team1
│   ├── SpawnPoint_T1_01
│   ├── SpawnPoint_T1_02
│   └── SpawnPoint_T1_03
├── Team2_Spawns
│   ├── HQ_PlayerSpawner_Team2
│   └── [spawn points...]
├── Objectives
│   ├── CapturePoint_A
│   ├── CapturePoint_B
│   └── CapturePoint_C
└── AI_Elements
    ├── AI_Spawner_North
    ├── AI_Spawner_South
    └── [waypoints...]
```

**Create Folder:**
1. Right-click in Scene Outliner
2. Add Child Node → Node3D
3. Rename to describe contents
4. Drag objects into folder

### Naming Objects

**Good Names:**
- `SpawnPoint_Team1_Main`
- `Trigger_CheckpointA`
- `AI_Spawner_EnemyWave1`

**Bad Names:**
- `Node3D` (default, not descriptive)
- `Spawner` (which spawner?)
- `Thing123` (meaningless)

**Rename Objects:**
1. Double-click name in Scene Outliner
2. Type new name
3. Press Enter

## Essential Gameplay Objects

### Player Spawning System

**Required objects for players to spawn:**

```
HQ_PlayerSpawner (Obj Id: 1)
├── Properties
│   └── Team: Team1
└── Must link to SpawnPoints

SpawnPoint (Obj Id: 10)
└── Position where player appears

SpawnPoint (Obj Id: 11)
└── Additional spawn location

[Repeat for each team]
```

**Setup:**
1. Place HQ_PlayerSpawner, set team
2. Place 3-5 SpawnPoints nearby
3. Link spawner to spawn points (check docs)
4. Set unique Obj Ids on all

**Alternative: PlayerSpawner**
- Use for script-controlled spawning
- Not assigned to specific team
- Link to SpawnPoints same way

### Area Triggers

Detect when players enter/exit zones:

**Setup:**
1. Add AreaTrigger from Global library
2. Set Obj Id
3. Configure PolygonVolume:
   - Click PolygonVolume property
   - Use **Ctrl+Click** to add points
   - **Ctrl+Right-Click** to remove points
   - Drag points to adjust shape

**In TypeScript:**
```typescript
export async function OnPlayerEnterAreaTrigger(
  player: mod.Player,
  trigger: mod.AreaTrigger
) {
  const id = mod.GetObjId(trigger);
  if (id === 50) {
    // Player entered checkpoint A
  }
}
```

### AI Spawners

Spawn bot enemies or allies:

**Setup:**
1. Add AI_Spawner from Global
2. Set Obj Id
3. Configure properties:
   - Team (or leave neutral)
   - Class (Assault, Engineer, etc.)

**In TypeScript:**
```typescript
const aiSpawner = mod.GetAISpawner(100);
mod.SpawnAIFromAISpawner(
  aiSpawner,
  mod.SoldierClass.Assault,
  mod.Team.Team3
);
```

### Vehicle Spawners

Spawn vehicles at specific locations:

**Setup:**
1. Add VehicleSpawner from map library
2. Set Obj Id
3. Position at desired spawn location
4. Rotate to face correct direction
5. Configure in script:

```typescript
const vehicleSpawner = mod.GetVehicleSpawner(200);
mod.SetVehicleSpawnerType(vehicleSpawner, mod.VehicleList.Tank_M1A1);
mod.ForceVehicleSpawnerSpawn(vehicleSpawner);
```

### World Icons

3D markers in the world:

**Setup:**
1. Place any object as anchor
2. Set Obj Id
3. Add icon in script:

```typescript
const anchor = mod.GetSpatialObject(300);
mod.AddUIIcon(
  anchor,
  mod.WorldIconImages.Icon_Objective,
  "Objective A",
  [1, 0, 0] // Red color
);
```

## Advanced Techniques

### Snapping to Grid

**Enable Snapping:**
1. Click **Snap** menu at top
2. Enable **Snap to Grid**
3. Adjust grid size as needed

**Benefits:**
- Aligned objects
- Consistent spacing
- Easier to organize

### Local vs Global Space

**Transform Mode:**
- **Local space** = Gizmo aligned to object rotation
- **Global space** = Gizmo always aligned to world axes

**Toggle:**
- Look for Local/Global toggle in toolbar
- Or press specific hotkey (varies)

### Multi-Select

Select multiple objects:
1. Hold **Ctrl** and click objects
2. Or click-drag box in viewport
3. All transform operations apply to all

**Useful for:**
- Moving groups together
- Uniform scaling multiple objects
- Mass deletion

### Camera Bookmarks

Save camera positions:
1. Position camera where you want
2. **Ctrl+1** (save to slot 1)
3. Press **1** to return to that view
4. Use slots 1-9 for different areas

## Performance Tips

### Viewport Performance

If editor is slow:

**Reduce Visual Complexity:**
1. Hide Static layer (eye icon)
2. Show only Portal_Dynamic
3. Reduce viewport quality (View menu)

**Simplify Scene:**
- Delete unused objects
- Avoid placing thousands of objects
- Use folders to organize

### Object Limits

**Recommended Limits:**
- **Player spawners**: 2-10 per team
- **AI spawners**: 10-30 total
- **Triggers**: 10-50 (simple shapes)
- **Runtime spawned objects**: 100-200

::: warning Performance Impact
More objects = slower export, larger file, potential game lag
:::

## Common Issues

### Can't See My Object

**Causes:**
- Object behind camera
- Object too small/large
- Object outside viewport
- Object hidden (eye icon)

**Solutions:**
1. Select in Scene Outliner, press **F**
2. Check eye icon isn't disabled
3. Check scale isn't 0 or extremely small

### Gizmo Not Appearing

**Cause:** Wrong mode selected

**Solution:** Press **W**, **E**, or **R** to activate transform mode

### Can't Select Object in Viewport

**Causes:**
- In wrong selection mode
- Object is locked
- Clicking empty space

**Solutions:**
1. Press **Q** for select mode
2. Check object isn't locked in outliner
3. Click directly on object geometry

### Objects Keep Snapping Weirdly

**Cause:** Snap to grid enabled

**Solution:** Disable snapping (Snap menu → Uncheck options)

## Exporting Your Scene

### Before Export

**Checklist:**
- [ ] All gameplay objects have Obj Ids set
- [ ] Objects are positioned correctly
- [ ] No duplicate Obj Ids
- [ ] Scene is saved (Ctrl+S)
- [ ] Object names are descriptive

### Export Process

1. Click **BFPortal** tab (right side)
2. Click **"Export Current Level"** button
3. Choose save location
4. Wait for completion
5. Verify `.spatial.json` file created

### What Gets Exported

**Included:**
- All objects in Portal_Dynamic layer
- Object positions, rotations, scales
- Object IDs and types
- Layer organization

**Not Included:**
- Static terrain (already in base map)
- Camera positions
- UI elements (created in script)
- Notes or comments

## Best Practices

### Object Placement

✅ **Do:**
- Test spawns facing correct direction
- Space spawn points apart
- Place triggers clearly visible (if possible)
- Use meaningful names
- Organize in folders

❌ **Don't:**
- Stack multiple objects at same position
- Use extremely large/small scales
- Leave default names
- Forget to set Obj Ids
- Place objects outside combat area

### Performance

✅ **Do:**
- Limit total object count
- Reuse objects when possible
- Delete unused objects
- Use simple trigger shapes

❌ **Don't:**
- Spawn hundreds of runtime objects
- Create overly complex polygon volumes
- Duplicate objects unnecessarily

### Workflow

✅ **Do:**
- Save frequently (Ctrl+S)
- Test exports regularly
- Document Obj Id assignments
- Keep backup copies

❌ **Don't:**
- Work for hours without saving
- Skip testing until fully complete
- Reuse Obj Ids
- Modify Static layers

## Next Steps

Master the Godot editor? Continue learning:

- **[TypeScript Scripting](/guides/typescript-scripting)** - Write game logic
- **[Event Hooks](/guides/event-hooks)** - Understand the event system
- **[Object System](/guides/object-system)** - Deep dive on objects
- **[First Game Mode Tutorial](/tutorials/first-game-mode)** - Build complete mode

---

::: tip Practice Makes Perfect
Spend 30 minutes exploring the editor before building your first mode. Familiarity with controls will make development much faster!
:::
