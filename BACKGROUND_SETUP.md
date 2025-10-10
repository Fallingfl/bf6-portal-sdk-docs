# Background Gameplay GIF Setup

## Step 1: Extract GIF Clips from YouTube Video

### Option A: Online Tool (Easiest)
1. Go to https://ezgif.com/video-to-gif
2. Enter YouTube URL: https://www.youtube.com/watch?v=pgNCgJG0vnY
3. Extract 3-5 short clips (5-10 seconds each):
   - Clip 1: Action scene (0:10-0:15)
   - Clip 2: Vehicle scene (0:30-0:35)
   - Clip 3: Combat scene (1:00-1:05)
   - Clip 4: Aerial view (1:30-1:35)
   - Clip 5: Explosion/dramatic (2:00-2:05)

4. For each clip:
   - Set size: 1280x720 (or smaller for performance)
   - Frame rate: 15-20 fps (lower = smaller file)
   - Export as GIF

### Option B: Using yt-dlp + FFmpeg (Command Line)
```bash
# 1. Download the video
yt-dlp -f "bestvideo[height<=720]" -o "bf6-gameplay.mp4" "https://www.youtube.com/watch?v=pgNCgJG0vnY"

# 2. Extract clips and convert to GIF
# Clip 1 (10-15 seconds)
ffmpeg -ss 00:00:10 -t 5 -i bf6-gameplay.mp4 \
  -vf "fps=15,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 bg-clip-1.gif

# Clip 2 (30-35 seconds)
ffmpeg -ss 00:00:30 -t 5 -i bf6-gameplay.mp4 \
  -vf "fps=15,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 bg-clip-2.gif

# Clip 3 (60-65 seconds)
ffmpeg -ss 00:01:00 -t 5 -i bf6-gameplay.mp4 \
  -vf "fps=15,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 bg-clip-3.gif

# Clip 4 (90-95 seconds)
ffmpeg -ss 00:01:30 -t 5 -i bf6-gameplay.mp4 \
  -vf "fps=15,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 bg-clip-4.gif

# Clip 5 (120-125 seconds)
ffmpeg -ss 00:02:00 -t 5 -i bf6-gameplay.mp4 \
  -vf "fps=15,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 bg-clip-5.gif
```

### Option C: Use MP4 videos instead (Better quality, smaller file size)
```bash
# Extract short MP4 clips (better than GIF)
ffmpeg -ss 00:00:10 -t 5 -i bf6-gameplay.mp4 -c:v libx264 -crf 28 -preset fast -an bg-clip-1.mp4
ffmpeg -ss 00:00:30 -t 5 -i bf6-gameplay.mp4 -c:v libx264 -crf 28 -preset fast -an bg-clip-2.mp4
ffmpeg -ss 00:01:00 -t 5 -i bf6-gameplay.mp4 -c:v libx264 -crf 28 -preset fast -an bg-clip-3.mp4
ffmpeg -ss 00:01:30 -t 5 -i bf6-gameplay.mp4 -c:v libx264 -crf 28 -preset fast -an bg-clip-4.mp4
ffmpeg -ss 00:02:00 -t 5 -i bf6-gameplay.mp4 -c:v libx264 -crf 28 -preset fast -an bg-clip-5.mp4
```

## Step 2: Place Files

Once you have the GIF or MP4 files, place them in:
```
docs-site/docs/public/bg/
  ├── bg-clip-1.gif (or .mp4)
  ├── bg-clip-2.gif
  ├── bg-clip-3.gif
  ├── bg-clip-4.gif
  └── bg-clip-5.gif
```

## Step 3: Update Configuration

Edit `docs/.vitepress/theme/index.js` and the CSS will automatically pick up the clips.

## Recommended Settings

- **Duration per clip**: 5-10 seconds
- **Resolution**: 1280x720 (or 1920x1080 for 1080p monitors)
- **Frame rate**: 15-20 fps (lower = smaller files)
- **File size target**: < 2MB per GIF, < 500KB per MP4
- **Number of clips**: 3-5 clips minimum

## Performance Tips

1. **Use MP4 instead of GIF** - Much smaller file size, better quality
2. **Lower resolution** - 720p is sufficient for background
3. **Reduce frame rate** - 15 fps is smooth enough for background
4. **Add blur** - Background should be slightly blurred so it doesn't distract from content

## Alternative: Use Video Element (Recommended)

Instead of GIFs, use HTML5 `<video>` elements:
- Smaller file size (80% smaller than GIF)
- Better quality
- Hardware accelerated
- Autoplay with loop

The CSS I'm about to create will support both GIF and MP4 formats.

---

**Next Steps:**
1. Extract clips using one of the methods above
2. Place files in `docs/public/bg/` directory
3. I'll create the CSS and JS to make them rotate automatically
