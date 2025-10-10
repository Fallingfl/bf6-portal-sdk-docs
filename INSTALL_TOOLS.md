# Install Required Tools

Run these commands to install the tools needed to download and convert the Facebook video:

```bash
sudo apt update
sudo apt install -y yt-dlp ffmpeg
```

Then run:
```bash
cd "/home/virus/BF6 Portal SDK/docs-site"
./create-bg-clips-facebook.sh
```

This will download the Facebook video and create 5 rotating background clips automatically.
