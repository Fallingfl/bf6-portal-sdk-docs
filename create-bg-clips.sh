#!/bin/bash

# BF6 Portal SDK - Background Clip Creator
# This script downloads the BF6 gameplay video and creates rotating background clips

set -e

YOUTUBE_URL="https://youtu.be/nMBBXqu0OLE"
OUTPUT_DIR="docs/public/bg"
TEMP_VIDEO="temp-bf6-gameplay.mp4"

echo "======================================"
echo "BF6 Background Clip Creator"
echo "======================================"
echo ""

# Check for required tools
echo "Checking for required tools..."

if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp not found. Installing..."
    echo "Run: pip install yt-dlp"
    echo "Or: sudo apt install yt-dlp"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg not found. Installing..."
    echo "Run: sudo apt install ffmpeg"
    exit 1
fi

echo "✅ All tools found!"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Download video if not already present
if [ ! -f "$TEMP_VIDEO" ]; then
    echo "📥 Downloading BF6 gameplay video..."
    yt-dlp -f "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
        --merge-output-format mp4 \
        -o "$TEMP_VIDEO" \
        "$YOUTUBE_URL"
    echo "✅ Download complete!"
else
    echo "✅ Video already downloaded (using cached version)"
fi

echo ""
echo "🎬 Creating background clips..."
echo ""

# Create 5 short clips from different timestamps
# Format: ffmpeg -ss START_TIME -t DURATION -i INPUT -vf FILTERS OUTPUT

# Clip 1: Early action (10-15 seconds)
echo "Creating clip 1/5 (10-15s)..."
ffmpeg -y -ss 00:00:10 -t 5 -i "$TEMP_VIDEO" \
    -vf "scale=1280:-2,fps=20" \
    -c:v libx264 -crf 23 -preset fast \
    -an -movflags +faststart \
    "$OUTPUT_DIR/bg-clip-1.mp4" \
    -loglevel error -stats

# Clip 2: Mid action (30-35 seconds)
echo "Creating clip 2/5 (30-35s)..."
ffmpeg -y -ss 00:00:30 -t 5 -i "$TEMP_VIDEO" \
    -vf "scale=1280:-2,fps=20" \
    -c:v libx264 -crf 23 -preset fast \
    -an -movflags +faststart \
    "$OUTPUT_DIR/bg-clip-2.mp4" \
    -loglevel error -stats

# Clip 3: Combat scene (60-65 seconds)
echo "Creating clip 3/5 (60-65s)..."
ffmpeg -y -ss 00:01:00 -t 5 -i "$TEMP_VIDEO" \
    -vf "scale=1280:-2,fps=20" \
    -c:v libx264 -crf 23 -preset fast \
    -an -movflags +faststart \
    "$OUTPUT_DIR/bg-clip-3.mp4" \
    -loglevel error -stats

# Clip 4: Aerial/vehicle (90-95 seconds)
echo "Creating clip 4/5 (90-95s)..."
ffmpeg -y -ss 00:01:30 -t 5 -i "$TEMP_VIDEO" \
    -vf "scale=1280:-2,fps=20" \
    -c:v libx264 -crf 23 -preset fast \
    -an -movflags +faststart \
    "$OUTPUT_DIR/bg-clip-4.mp4" \
    -loglevel error -stats

# Clip 5: Dramatic moment (120-125 seconds)
echo "Creating clip 5/5 (120-125s)..."
ffmpeg -y -ss 00:02:00 -t 5 -i "$TEMP_VIDEO" \
    -vf "scale=1280:-2,fps=20" \
    -c:v libx264 -crf 23 -preset fast \
    -an -movflags +faststart \
    "$OUTPUT_DIR/bg-clip-5.mp4" \
    -loglevel error -stats

echo ""
echo "======================================"
echo "✅ All background clips created!"
echo "======================================"
echo ""
echo "Files created:"
ls -lh "$OUTPUT_DIR"/bg-clip-*.mp4 | awk '{print "  " $9 " (" $5 ")"}'
echo ""
echo "Total size:"
du -sh "$OUTPUT_DIR"
echo ""
echo "🎮 Background rotation is now active on your docs site!"
echo "   Visit: http://localhost:5174/"
echo ""
echo "Optional cleanup:"
echo "  rm $TEMP_VIDEO  # Remove downloaded video (saves ~500MB)"
echo ""
