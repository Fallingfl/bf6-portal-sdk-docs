# Installation

This guide walks you through installing and configuring the Battlefield 6 Portal SDK and all required tools for development.

## System Requirements

### Minimum Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Windows 10/11 (64-bit) |
| **RAM** | 8GB minimum, 16GB recommended |
| **Storage** | 5GB free space |
| **GPU** | DirectX 11 compatible |
| **Internet** | Required for Portal uploads |

### Software Prerequisites

- **Windows PC** - Godot editor requires Windows
- **Web Browser** - Chrome, Firefox, or Edge (latest version)
- **Portal Account** - Access to portal.battlefield.com

::: tip WSL Users
You can access the SDK through WSL (Windows Subsystem for Linux), but must run the Godot editor natively in Windows.
:::

## Step 1: Download the SDK

### Obtain SDK Package

1. Download the Portal SDK package (if you have access)
2. Extract to a location with **no spaces in path**:
   - ✅ Good: `C:\PortalSDK\`
   - ✅ Good: `C:\Dev\BF6Portal\`
   - ❌ Bad: `C:\My Documents\Portal SDK\` (has spaces)

### Verify Contents

After extraction, verify these folders exist:

```
PortalSDK/
├── Godot_v4.4.1-stable_win64.exe    ✅ Godot editor
├── GodotProject/                     ✅ Project files
├── code/                             ✅ TypeScript API
├── mods/                             ✅ Example mods
├── FbExportData/                     ✅ Map data
└── python/                           ✅ Python runtime
```

## Step 2: Install Node.js (Optional)

Node.js provides TypeScript support and IntelliSense in code editors.

### Download Node.js

1. Visit https://nodejs.org/
2. Download the **LTS version** (18.x or higher)
3. Run the installer
4. Accept default options
5. Verify installation:

```bash
node --version
# Should show: v18.x.x or higher

npm --version
# Should show: 9.x.x or higher
```

::: tip Node.js Benefits
While optional, Node.js enables:
- TypeScript syntax checking
- IntelliSense autocompletion
- Package management
- Better debugging
:::

## Step 3: Install a Code Editor

### Option A: Visual Studio Code (Recommended)

**Why VS Code:**
- Free and lightweight
- Excellent TypeScript support
- Built-in terminal
- Git integration

**Installation:**
1. Visit https://code.visualstudio.com/
2. Download for Windows
3. Run installer
4. Launch VS Code

**Recommended Extensions:**
1. **TypeScript Extension Pack** - TypeScript support
2. **Prettier** - Code formatting
3. **ESLint** - Code quality
4. **Error Lens** - Inline errors

**Install Extensions:**
```
1. Press Ctrl+Shift+X (Extensions panel)
2. Search "TypeScript"
3. Install "JavaScript and TypeScript Nightly"
4. Repeat for other extensions
```

### Option B: Other Editors

Any text editor works, but these have good TypeScript support:
- **WebStorm** - Full IDE, paid
- **Sublime Text** - Lightweight, requires plugins
- **Atom** - Free, GitHub integration
- **Notepad++** - Minimal, no IntelliSense

## Step 4: Configure TypeScript Project

### Create TypeScript Config

In your mod folder (e.g., `mods/MyMod/`), create `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020"],
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "types": [],
    "baseUrl": ".",
    "paths": {
      "bf-portal-api": ["../../code/mod/index.d.ts"],
      "./modlib": ["../../code/modlib/index.ts"]
    }
  },
  "include": [
    "*.ts",
    "../../code/mod/index.d.ts",
    "../../code/modlib/index.ts"
  ],
  "exclude": ["node_modules"]
}
```

### Create Package.json (Optional)

For better IDE integration:

```json
{
  "name": "my-portal-mod",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "check": "tsc --noEmit"
  },
  "devDependencies": {
    "typescript": "^5.0.0"
  }
}
```

Install TypeScript:
```bash
npm install
```

## Step 5: Launch Godot Editor

### First Launch

1. Navigate to SDK folder
2. Double-click `Godot_v4.4.1-stable_win64.exe`
3. Wait for the **Project Selection** window

### Import Portal Project

**Method 1: Drag and Drop**
1. Drag `GodotProject` folder into Project Selection window
2. Godot auto-imports the project
3. Click **"Open"**

**Method 2: Manual Import**
1. Click **"Import"** button
2. Navigate to `GodotProject` folder
3. Select `project.godot` file
4. Click **"Import & Edit"**

### Wait for Initial Load

- First launch takes 1-2 minutes
- Godot compiles shaders and indexes assets
- Console will show progress

::: warning Don't Close Godot
Let the initial load complete fully before closing Godot or starting Portal Setup.
:::

## Step 6: Run Portal Setup

This is a **critical one-time setup** step.

### Portal Setup Process

1. Look for **BFPortal** tab on the **right side** of Godot
2. Click **"Portal Setup"** button
3. **Wait 3-5 minutes** for completion

**What Portal Setup Does:**
- Processes all map object libraries
- Builds object databases
- Validates asset references
- Sets up export configurations

**Progress Indicators:**
- Console shows processing messages
- Status bar updates
- "Setup Complete" message appears

::: danger Must Complete
Portal Setup MUST complete successfully before you can export levels. Do not skip this step!
:::

### Verify Setup Success

After Portal Setup completes:

1. Open a level: **Scene** → **Open Scene** → `levels/MP_Dumbo.tscn`
2. Check **Object Library** tab at bottom
3. Verify tabs appear: Brooklyn, Global, Gibraltar, etc.
4. If tabs are empty, re-run Portal Setup

## Step 7: Configure Export Location

### Set Export Path (Optional)

By default, exports save to `output/` folder. To change:

1. Click **Project** → **Project Settings**
2. Search for "Export"
3. Set custom export path
4. Click **Close**

## Step 8: Test Your Installation

### Test Godot Editor

1. **Open a map**: Scene → Open Scene → `levels/MP_Dumbo.tscn`
2. **Find geometry**: Look up, geometry is above default view
3. **Test controls**: Hold Right Mouse Button, move with WASD
4. **Select object**: Press Q, click an object
5. **Export test**: BFPortal tab → "Export Current Level"

### Test TypeScript Setup

Create a test file `test.ts`:

```typescript
import * as mod from 'bf-portal-api';

export async function OnGameModeStarted() {
  console.log("Test successful!");

  const players = mod.GetPlayers();
  mod.SetGameTimeLimit(600);
}
```

**If using VS Code with TypeScript:**
- Open test.ts
- Verify no red squiggles under `mod`
- Hover over `GetPlayers()` - should show type info
- If errors appear, check tsconfig.json paths

## Common Installation Issues

### Godot Won't Launch

**Problem**: Double-clicking Godot does nothing

**Solutions:**
- Check Windows compatibility (64-bit required)
- Run as Administrator
- Disable antivirus temporarily
- Check GPU drivers are up to date

### Portal Setup Fails

**Problem**: Portal Setup errors or never completes

**Solutions:**
1. Close Godot completely
2. Delete `.godot/` folder in GodotProject
3. Restart Godot
4. Re-run Portal Setup
5. Check console for specific errors

### Object Library Empty

**Problem**: No objects appear in Object Library tabs

**Solutions:**
- Portal Setup didn't complete - re-run it
- Close and reopen the scene
- Restart Godot entirely
- Check FbExportData/ folder exists

### TypeScript Errors in VS Code

**Problem**: Red squiggles, "Cannot find module"

**Solutions:**
1. Verify tsconfig.json is in mod folder
2. Check paths in tsconfig.json point to correct locations
3. Reload VS Code window (Ctrl+Shift+P → "Reload Window")
4. Ensure Node.js and TypeScript are installed

### Export Button Doesn't Work

**Problem**: Clicking "Export Current Level" does nothing

**Solutions:**
- Portal Setup must complete first
- Check Python is installed (bundled in SDK)
- Verify write permissions on output folder
- Check console for Python errors

### Can't Find Level Geometry

**Problem**: Map appears empty in Godot

**Solutions:**
- **Look up!** Geometry is above default camera
- Select object in Scene Outliner, press F to frame
- Use scroll wheel to zoom out
- Check the correct .tscn file is open

## Verification Checklist

Before proceeding, verify:

- ✅ Godot launches successfully
- ✅ Portal Setup completed without errors
- ✅ Object Library shows map tabs
- ✅ Can open and view a map
- ✅ Can export a level to .spatial.json
- ✅ TypeScript editor shows no import errors
- ✅ Can access portal.battlefield.com

## Next Steps

With installation complete:

- **[SDK Overview](/guides/sdk-overview)** - Understand SDK architecture
- **[Development Workflow](/guides/workflow)** - Learn the full process
- **[Godot Editor Guide](/guides/godot-editor)** - Master spatial editing
- **[Getting Started](/guides/getting-started)** - Create your first mod

---

::: tip Need Help?
If you encounter issues not covered here:
1. Check the [Common Issues](#common-installation-issues) section
2. Verify all [Prerequisites](#system-requirements)
3. Contact: andrew@virusgaming.org
:::
