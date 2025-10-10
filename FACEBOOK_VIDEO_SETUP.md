# 📹 Facebook Video Background Setup

Using Facebook video: https://www.facebook.com/watch/?v=1136294041346082

## Method 1: Automated Script (Recommended)

### Prerequisites
```bash
# Install yt-dlp (supports Facebook)
pip install yt-dlp

# Or on Ubuntu/Debian
sudo apt install yt-dlp

# Install ffmpeg
sudo apt install ffmpeg

# Update yt-dlp to latest version (important for Facebook support)
pip install -U yt-dlp
```

### Run the Script
```bash
cd "/home/virus/BF6 Portal SDK/docs-site"
./create-bg-clips-facebook.sh
```

The script will:
- Download the Facebook video automatically
- Extract 5 clips evenly distributed throughout the video
- Optimize to 720p MP4 format
- Place in `docs/public/bg/` directory

## Method 2: Manual Download + Conversion

If the automated script has issues with Facebook authentication:

### Step 1: Download the Video Manually

**Option A: Using Browser Extension**
1. Install a Facebook video downloader extension (e.g., "Video Downloader for Facebook")
2. Visit: https://www.facebook.com/watch/?v=1136294041346082
3. Download the video (choose highest quality)
4. Save as: `/home/virus/BF6 Portal SDK/docs-site/temp-bf6-gameplay.mp4`

**Option B: Using Online Service**
1. Visit: https://fdown.net/ or https://fbdownloader.net/
2. Paste URL: https://www.facebook.com/watch/?v=1136294041346082
3. Download HD version
4. Save as: `/home/virus/BF6 Portal SDK/docs-site/temp-bf6-gameplay.mp4`

### Step 2: Create Clips with FFmpeg

Once you have the video file:

```bash
cd "/home/virus/BF6 Portal SDK/docs-site"

# Get video duration
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 temp-bf6-gameplay.mp4 | cut -d. -f1)
echo "Video is ${DURATION} seconds long"

# Calculate timestamps (evenly distributed)
# For a 60-second video, this would be: 10s, 20s, 30s, 40s, 50s
INTERVAL=$((DURATION / 6))

# Create 5 clips
mkdir -p docs/public/bg

# Clip 1
ffmpeg -y -ss $((INTERVAL * 1)) -t 5 -i temp-bf6-gameplay.mp4 \
  -vf "scale=1280:-2,fps=20" \
  -c:v libx264 -crf 23 -preset fast \
  -an -movflags +faststart \
  docs/public/bg/bg-clip-1.mp4

# Clip 2
ffmpeg -y -ss $((INTERVAL * 2)) -t 5 -i temp-bf6-gameplay.mp4 \
  -vf "scale=1280:-2,fps=20" \
  -c:v libx264 -crf 23 -preset fast \
  -an -movflags +faststart \
  docs/public/bg/bg-clip-2.mp4

# Clip 3
ffmpeg -y -ss $((INTERVAL * 3)) -t 5 -i temp-bf6-gameplay.mp4 \
  -vf "scale=1280:-2,fps=20" \
  -c:v libx264 -crf 23 -preset fast \
  -an -movflags +faststart \
  docs/public/bg/bg-clip-3.mp4

# Clip 4
ffmpeg -y -ss $((INTERVAL * 4)) -t 5 -i temp-bf6-gameplay.mp4 \
  -vf "scale=1280:-2,fps=20" \
  -c:v libx264 -crf 23 -preset fast \
  -an -movflags +faststart \
  docs/public/bg/bg-clip-4.mp4

# Clip 5
ffmpeg -y -ss $((INTERVAL * 5)) -t 5 -i temp-bf6-gameplay.mp4 \
  -vf "scale=1280:-2,fps=20" \
  -c:v libx264 -crf 23 -preset fast \
  -an -movflags +faststart \
  docs/public/bg/bg-clip-5.mp4

echo "✅ All clips created!"
ls -lh docs/public/bg/
```

## Method 3: Custom Timestamps

If you want specific moments from the video:

```bash
cd "/home/virus/BF6 Portal SDK/docs-site"
mkdir -p docs/public/bg

# Replace XX:XX:XX with your desired timestamps
# Example: Extract 5 seconds starting at 10 seconds into the video

# Clip 1 - Action scene (adjust timestamp as needed)
ffmpeg -y -ss 00:00:05 -t 5 -i temp-bf6-gameplay.mp4 \
  -vf "scale=1280:-2,fps=20" -c:v libx264 -crf 23 -preset fast \
  -an -movflags +faststart docs/public/bg/bg-clip-1.mp4

# Clip 2 - Combat (adjust timestamp)
ffmpeg -y -ss 00:00:15 -t 5 -i temp-bf6-gameplay.mp4 \
  -vf "scale=1280:-2,fps=20" -c:v libx264 -crf 23 -preset fast \
  -an -movflags +faststart docs/public/bg/bg-clip-2.mp4

# Clip 3 - Vehicle scene (adjust timestamp)
ffmpeg -y -ss 00:00:25 -t 5 -i temp-bf6-gameplay.mp4 \
  -vf "scale=1280:-2,fps=20" -c:v libx264 -crf 23 -preset fast \
  -an -movflags +faststart docs/public/bg/bg-clip-3.mp4

# Clip 4 - Aerial view (adjust timestamp)
ffmpeg -y -ss 00:00:35 -t 5 -i temp-bf6-gameplay.mp4 \
  -vf "scale=1280:-2,fps=20" -c:v libx264 -crf 23 -preset fast \
  -an -movflags +faststart docs/public/bg/bg-clip-4.mp4

# Clip 5 - Dramatic moment (adjust timestamp)
ffmpeg -y -ss 00:00:45 -t 5 -i temp-bf6-gameplay.mp4 \
  -vf "scale=1280:-2,fps=20" -c:v libx264 -crf 23 -preset fast \
  -an -movflags +faststart docs/public/bg/bg-clip-5.mp4
```

## Troubleshooting Facebook Downloads

### "yt-dlp can't download from Facebook"

**Solution 1: Update yt-dlp**
```bash
pip install -U yt-dlp
```

**Solution 2: Add cookies (if video requires login)**
```bash
# Export cookies from your browser using extension "Get cookies.txt"
# Save as cookies.txt in the docs-site folder

yt-dlp --cookies cookies.txt \
  -f "best[ext=mp4]/best" \
  -o temp-bf6-gameplay.mp4 \
  "https://www.facebook.com/watch/?v=1136294041346082"
```

**Solution 3: Use alternative downloader**
Try gallery-dl instead:
```bash
pip install gallery-dl
gallery-dl "https://www.facebook.com/watch/?v=1136294041346082"
```

**Solution 4: Manual download (see Method 2 above)**
Use browser extension or online service.

### "Video is private or unavailable"

If the video requires Facebook login:
1. Make sure you're logged into Facebook in your browser
2. Use cookies method (Solution 2 above)
3. Or download manually via browser extension

### "Downloaded file is not MP4"

Convert to MP4:
```bash
ffmpeg -i input.webm -c:v libx264 -c:a aac temp-bf6-gameplay.mp4
```

## Verify Setup

After creating clips:

```bash
# Check if clips exist
ls -lh docs/public/bg/

# Should show:
# bg-clip-1.mp4
# bg-clip-2.mp4
# bg-clip-3.mp4
# bg-clip-4.mp4
# bg-clip-5.mp4

# Test a clip
ffplay docs/public/bg/bg-clip-1.mp4
```

## View Result

Visit: http://localhost:5174/

Background should now be rotating through 5 clips from the Facebook video!

---

**Video Source:** https://www.facebook.com/watch/?v=1136294041346082

**Next Steps:**
- If automated script works → You're done! ✅
- If script fails → Use Manual Download method
- Adjust timestamps if needed → See Method 3
