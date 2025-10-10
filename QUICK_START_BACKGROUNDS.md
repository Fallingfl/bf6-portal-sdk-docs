# 🚀 Quick Start: Rotating Background Setup

## TL;DR - 3 Steps to Activate

```bash
# 1. Install tools (if not already installed)
sudo apt install yt-dlp ffmpeg

# 2. Navigate to docs-site folder
cd "/home/virus/BF6 Portal SDK/docs-site"

# 3. Run the script (Facebook video)
./create-bg-clips-facebook.sh

# OR use YouTube video instead:
# ./create-bg-clips.sh
```

**That's it!** Your documentation site will now have rotating BF6 gameplay backgrounds.

## What Happens

The script will:
1. ✅ Download BF6 gameplay from Facebook (https://www.facebook.com/watch/?v=1136294041346082)
2. ✅ Extract 5 short clips (5 seconds each, evenly distributed)
3. ✅ Optimize them to 720p MP4 (~500KB each)
4. ✅ Place them in `docs/public/bg/` folder
5. ✅ Background rotation activates automatically

## Result

- **5 rotating clips** of BF6 gameplay
- **10 seconds** per clip (with 2-second fade transition)
- **Blurred and darkened** to ensure text readability
- **Auto-disabled on mobile** for performance
- **Total size:** ~2-4MB for all clips

## If You Don't Have the Tools

### Install yt-dlp
```bash
# Ubuntu/Debian
sudo apt install yt-dlp

# Or via pip
pip install yt-dlp

# macOS
brew install yt-dlp
```

### Install ffmpeg
```bash
# Ubuntu/Debian
sudo apt install ffmpeg

# macOS
brew install ffmpeg
```

## Alternative: Manual Extraction

If you already have BF6 gameplay footage:

1. **Place 5 video files** in `docs/public/bg/`:
   - `bg-clip-1.mp4`
   - `bg-clip-2.mp4`
   - `bg-clip-3.mp4`
   - `bg-clip-4.mp4`
   - `bg-clip-5.mp4`

2. **Recommended specs:**
   - Resolution: 1280x720 (or 1920x1080)
   - Duration: 5-10 seconds each
   - Format: MP4 (H.264)
   - No audio needed (will be muted anyway)

That's it! The rotation will work automatically.

## Files Created

The following files have been set up for you:

✅ `docs/.vitepress/theme/Layout.vue` - Background rotation component
✅ `docs/.vitepress/theme/index.js` - Updated to use custom layout
✅ `docs/public/bg/` - Directory for background clips
✅ `create-bg-clips.sh` - Automated clip generation script
✅ `BACKGROUND_CLIPS.md` - Full documentation
✅ `BACKGROUND_SETUP.md` - Alternative methods

## View Live

Visit: **http://localhost:5174/**

The background clips will rotate every 10 seconds on the homepage and all pages!

## Troubleshooting

**Background not showing?**
- Check if files exist: `ls docs/public/bg/`
- Look for errors in browser console (F12)
- Try hard refresh: Ctrl+Shift+R

**Script fails?**
- Make sure yt-dlp and ffmpeg are installed
- Check internet connection (for video download)
- Read error message - it will tell you what's missing

## Need Help?

See full documentation:
- `BACKGROUND_CLIPS.md` - Complete guide with customization
- `BACKGROUND_SETUP.md` - Alternative extraction methods

---

**Ready?** Run: `./create-bg-clips.sh` 🎮
