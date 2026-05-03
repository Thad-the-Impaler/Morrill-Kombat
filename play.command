#!/bin/bash
# Morrill Kombat — local launcher.
#
# Double-click this file in Finder (it's executable). It will:
#   1. Rebuild index.html from src/template.html + src/all.js
#   2. Start a local HTTP server in the project directory
#   3. Open the game in your default browser at http://localhost:8765/
#   4. Stop the server cleanly when you press Ctrl+C in this Terminal window
#
# Why this script exists:
#
#   The game loads its sprite PNGs and audio MP3/WAVs via relative paths
#   (e.g., 'Assets/Fighters/Arnav/ArnStationary.PNG'). When you open
#   index.html via Finder (file://), modern browsers refuse to fetch other
#   files from disk for security reasons — so every sprite loads as a
#   broken image and the title-screen logo doesn't show up.
#
#   Serving the same file over HTTP (even just localhost) bypasses that
#   restriction. This script is the equivalent of what GitHub Pages does
#   when it serves the deployed site.
#
#   Don't open template.html directly — it's a build input, not a page.

set -e
cd "$(dirname "$0")"

PORT=8765
URL="http://localhost:${PORT}/"

echo "→ Rebuilding index.html..."
python3 src/build.py

echo "→ Starting HTTP server on port ${PORT}..."
echo "→ Opening ${URL} in your browser..."
echo "→ When you're done playing, return to this window and press Ctrl+C."
echo ""

# Open browser after a tiny delay so the server is ready
( sleep 1 && open "${URL}" ) &

# Foreground server — Ctrl+C kills it cleanly
exec python3 -m http.server "${PORT}"
