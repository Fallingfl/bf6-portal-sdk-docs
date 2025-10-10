#!/bin/bash

# BF6 Portal SDK - Background Clip Creator (Facebook Video)
# This script downloads the BF6 gameplay video from Facebook and creates rotating background clips

set -e

FACEBOOK_URL="https://www.facebook.com/watch/?v=1136294041346082"
OUTPUT_DIR="docs/public/bg"
TEMP_VIDEO="temp-bf6-gameplay.mp4"

echo "======================================"
echo "BF6 Background Clip Creator"
echo "Source: Facebook Video"
echo "======================================"
echo ""

# Check for required tools
echo "Checking for required tools..."

if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp not found."
    echo "Install with: pip install yt-dlp"
    echo "or: sudo apt install yt-dlp"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg not found."
    echo "Install with: sudo apt install ffmpeg"
    exit 1
fi

echo "✅ All tools found!"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Download video if not already present
if [ ! -f "$TEMP_VIDEO" ]; then
    echo "📥 Downloading BF6 gameplay video from Facebook..."
    echo "   URL: $FACEBOOK_URL"
    echo ""

    # yt-dlp supports Facebook videos
    yt-dlp -f "best[ext=mp4]/best" \
        --merge-output-format mp4 \
        -o "$TEMP_VIDEO" \
        "$FACEBOOK_URL"

    if [ $? -eq 0 ]; then
        echo "✅ Download complete!"
    else
        echo "❌ Download failed!"
        echo ""
        echo "Troubleshooting:"
        echo "1. Make sure yt-dlp is up to date: pip install -U yt-dlp"
        echo "2. Check if video is publicly accessible"
        echo "3. Try downloading manually and place as: $TEMP_VIDEO"
        exit 1
    fi
else
    echo "✅ Video already downloaded (using cached version)"
fi

echo ""
echo "📹 Analyzing video..."
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$TEMP_VIDEO" > /dev/null 2>&1
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$TEMP_VIDEO" 2>/dev/null | cut -d. -f1)
echo "   Duration: ${DURATION}s"

echo ""
echo "🎬 Creating background clips..."
echo ""

# Determine timestamps based on video duration
# We'll extract 5 clips evenly distributed throughout the video

if [ -z "$DURATION" ] || [ "$DURATION" -lt 30 ]; then
    echo "⚠️  Video is very short, using fixed timestamps"
    TIMESTAMPS=(5 10 15 20 25)
else
    # Calculate evenly spaced timestamps
    INTERVAL=$((DURATION / 6))
    TIMESTAMPS=(
        $((INTERVAL * 1))
        $((INTERVAL * 2))
        $((INTERVAL * 3))
        $((INTERVAL * 4))
        $((INTERVAL * 5))
    )
fi

# Create 5 short clips
for i in {0..4}; do
    CLIP_NUM=$((i + 1))
    TIMESTAMP=${TIMESTAMPS[$i]}

    echo "Creating clip $CLIP_NUM/5 (starting at ${TIMESTAMP}s)..."

    ffmpeg -y -ss "$TIMESTAMP" -t 5 -i "$TEMP_VIDEO" \
        -vf "scale=1280:-2,fps=20" \
        -c:v libx264 -crf 23 -preset fast \
        -an -movflags +faststart \
        "$OUTPUT_DIR/bg-clip-$CLIP_NUM.mp4" \
        -loglevel error -stats 2>&1

    if [ $? -ne 0 ]; then
        echo "⚠️  Warning: Clip $CLIP_NUM may have issues"
    fi
done

echo ""
echo "======================================"
echo "✅ All background clips created!"
echo "======================================"
echo ""
echo "Files created:"
ls -lh "$OUTPUT_DIR"/bg-clip-*.mp4 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
echo ""
echo "Total size:"
du -sh "$OUTPUT_DIR" 2>/dev/null
echo ""
echo "🎮 Background rotation is now active on your docs site!"
echo "   Visit: http://localhost:5174/"
echo ""
echo "Optional cleanup:"
echo "  rm $TEMP_VIDEO  # Remove downloaded video to save space"
echo ""
echo "Note: If clips look wrong, you can manually adjust timestamps"
echo "      by editing this script and changing the TIMESTAMPS array"
echo ""
