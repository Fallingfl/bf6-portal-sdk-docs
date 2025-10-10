# 🎬 Rotating Background Clips Setup

The BF6 Portal SDK documentation site now supports **rotating gameplay background videos** that automatically cycle every 10 seconds, creating a dynamic and immersive experience.

## 📋 What's Been Set Up

✅ **Custom Vue Layout** (`docs/.vitepress/theme/Layout.vue`)
- Displays rotating background videos/GIFs
- Smooth fade transitions between clips
- Dark overlay for text readability
- Blur effect to prevent distraction
- Mobile-optimized (disabled on small screens for performance)

✅ **Background Rotation Logic**
- Automatically rotates through 5 clips every 10 seconds
- Supports both MP4 and GIF formats
- Hardware-accelerated video playback
- Autoplay, muted, and looping

✅ **Helper Script** (`create-bg-clips.sh`)
- Downloads BF6 gameplay video from YouTube
- Extracts 5 short clips (5 seconds each)
- Converts to optimized MP4 format
- Places files in correct location

## 🚀 Quick Start

### Step 1: Install Required Tools

```bash
# Ubuntu/Debian
sudo apt install yt-dlp ffmpeg

# macOS (using Homebrew)
brew install yt-dlp ffmpeg

# Or install yt-dlp via pip
pip install yt-dlp
```

### Step 2: Run the Script

```bash
cd "/home/virus/BF6 Portal SDK/docs-site"
./create-bg-clips.sh
```

This will:
1. Download the BF6 gameplay video: https://www.youtube.com/watch?v=pgNCgJG0vnY
2. Extract 5 clips from different timestamps:
   - Clip 1: 10-15 seconds (early action)
   - Clip 2: 30-35 seconds (mid action)
   - Clip 3: 60-65 seconds (combat scene)
   - Clip 4: 90-95 seconds (aerial/vehicle)
   - Clip 5: 120-125 seconds (dramatic moment)
3. Convert to optimized MP4 format (720p, 20fps, ~500KB each)
4. Place in `docs/public/bg/` directory

### Step 3: View the Result

The background rotation will automatically activate. Visit:
```
http://localhost:5174/
```

The homepage will now have rotating BF6 gameplay footage in the background!

## 🎨 Customization

### Change Clip Duration

Edit `docs/.vitepress/theme/Layout.vue`:

```javascript
// Change from 10 seconds to 15 seconds
rotationInterval = setInterval(() => {
  currentClip.value = (currentClip.value + 1) % backgroundClips.value.length
}, 15000) // 15 seconds instead of 10
```

### Change Timestamps

Edit `create-bg-clips.sh` to extract clips from different timestamps:

```bash
# Example: Extract clip from 2:30 to 2:35
ffmpeg -y -ss 00:02:30 -t 5 -i "$TEMP_VIDEO" \
    -vf "scale=1280:-2,fps=20" \
    -c:v libx264 -crf 23 -preset fast \
    -an -movflags +faststart \
    "$OUTPUT_DIR/bg-clip-3.mp4"
```

### Adjust Blur/Brightness

Edit `docs/.vitepress/theme/Layout.vue`:

```css
.bf6-bg-video,
.bf6-bg-image {
  /* Increase blur: blur(5px) */
  /* Decrease darkness: brightness(0.5) */
  filter: blur(3px) brightness(0.4);
}
```

### Add More Clips

1. Add more clips to `docs/public/bg/`:
   ```
   bg-clip-6.mp4
   bg-clip-7.mp4
   ```

2. Update `docs/.vitepress/theme/Layout.vue`:
   ```javascript
   const backgroundClips = ref([
     '/bg/bg-clip-1.mp4',
     '/bg/bg-clip-2.mp4',
     '/bg/bg-clip-3.mp4',
     '/bg/bg-clip-4.mp4',
     '/bg/bg-clip-5.mp4',
     '/bg/bg-clip-6.mp4', // New!
     '/bg/bg-clip-7.mp4'  // New!
   ])
   ```

### Use GIFs Instead of MP4

If you prefer GIFs (larger file size but simpler):

1. Convert clips to GIF:
   ```bash
   ffmpeg -i docs/public/bg/bg-clip-1.mp4 \
     -vf "fps=15,scale=1280:-1:flags=lanczos" \
     docs/public/bg/bg-clip-1.gif
   ```

2. Update `Layout.vue` to reference `.gif` files instead of `.mp4`

## 📊 File Sizes

Expected file sizes after running the script:
- Each MP4 clip: ~400-800KB (720p, 5 seconds, 20fps)
- Total for 5 clips: ~2-4MB
- Original downloaded video: ~500MB (can be deleted after conversion)

## 🎯 Performance Tips

1. **Use MP4 instead of GIF** - Much smaller file size (80% smaller)
2. **Lower resolution** - 720p is sufficient for background (already set)
3. **Reduce FPS** - 15-20 fps is smooth enough (script uses 20fps)
4. **Shorter clips** - 5 seconds per clip is ideal (already set)
5. **Mobile disabled** - Background is automatically disabled on mobile for performance

## 🔧 Troubleshooting

### "yt-dlp: command not found"
```bash
# Install yt-dlp
pip install yt-dlp
# or
sudo apt install yt-dlp
```

### "ffmpeg: command not found"
```bash
sudo apt install ffmpeg
```

### Background not showing
1. Check if files exist: `ls docs/public/bg/`
2. Check browser console for errors (F12)
3. Try hard refresh: Ctrl+Shift+R
4. Make sure dev server is running

### Videos won't play
- Make sure files are MP4 format (not MOV or other formats)
- Check that videos are muted (required for autoplay)
- Try a different browser (Chrome/Firefox recommended)

### Files too large
Increase compression:
```bash
# Higher CRF = more compression (18-28 is good range)
ffmpeg -i input.mp4 -c:v libx264 -crf 28 -preset slow output.mp4
```

## 🎮 Alternative: Use Different Source Video

To use a different BF6 gameplay video:

1. Edit `create-bg-clips.sh`
2. Change the `YOUTUBE_URL` variable:
   ```bash
   YOUTUBE_URL="https://www.youtube.com/watch?v=YOUR_VIDEO_ID"
   ```
3. Adjust timestamps to capture the best moments from that video
4. Re-run the script

## 📝 Manual Method (Without Script)

If you prefer to create clips manually:

1. Download video:
   ```bash
   yt-dlp -o "bf6.mp4" "https://www.youtube.com/watch?v=pgNCgJG0vnY"
   ```

2. Extract clips manually (example for clip 1):
   ```bash
   ffmpeg -ss 00:00:10 -t 5 -i bf6.mp4 \
     -vf "scale=1280:-2,fps=20" \
     -c:v libx264 -crf 23 \
     -an -movflags +faststart \
     docs/public/bg/bg-clip-1.mp4
   ```

3. Repeat for clips 2-5 with different timestamps

## 🎨 Current Configuration

**Clip Settings:**
- Resolution: 1280x720 (720p)
- Frame rate: 20 fps
- Duration: 5 seconds each
- Format: MP4 (H.264)
- Audio: Removed (muted)
- Compression: CRF 23 (balanced quality/size)

**Rotation Settings:**
- Transition: 2 second fade
- Display time: 10 seconds per clip
- Loop: Continuous

**Visual Effects:**
- Blur: 3px (soft background)
- Brightness: 0.4 (40% to ensure text readability)
- Overlay: Dark gradient (top to bottom)

---

**Status:** ✅ Infrastructure Complete

**Next Step:** Run `./create-bg-clips.sh` to generate the background clips!

**Support:** andrew@virusgaming.org
