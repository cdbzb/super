#!/bin/bash
# Create video copies with timecode burn-in.
# Particle: timecode starts at -00:00:20
# Live:     timecode starts at 00:00:00

set -euo pipefail

PARTICLE_IN="/Users/michael/tank/Hyojin/Video Sync/Media/여민락_2025__yeomillak-2025 (720p).mp4"
LIVE_IN="/Users/michael/tank/Hyojin/Video Sync/Media/1015_여민락_실연_full (720p).mp4"

PARTICLE_OUT="${PARTICLE_IN%.mp4}_tc.mp4"
LIVE_OUT="${LIVE_IN%.mp4}_tc.mp4"

STYLE="fontsize=36:fontcolor=white:box=1:boxcolor=black@0.7:x=10:y=10"

echo "Encoding particle video with timecode from -00:00:20..."
# Two drawtext layers switch at t=20:
#   t < 20:  shows -00:00:XX countdown (ceil so it reads 20,19,...,1)
#   t >= 20: shows elapsed time since t=20
ffmpeg -y -i "$PARTICLE_IN" \
  -vf "drawtext=text='-00\:00\:%{eif\:ceil(20-t)\:d\:2}.%{eif\:mod(floor(t*1000)\,1000)\:d\:3}':${STYLE}:enable='lt(t,20)',\
drawtext=text='%{eif\:floor((t-20)/3600)\:d\:2}\:%{eif\:mod(floor((t-20)/60)\,60)\:d\:2}\:%{eif\:mod(floor(t-20)\,60)\:d\:2}.%{eif\:mod(floor((t-20)*1000)\,1000)\:d\:3}':${STYLE}:enable='gte(t,20)'" \
  -c:v libx264 -crf 23 -preset fast -c:a copy \
  "$PARTICLE_OUT"

echo "Encoding live video with timecode from 00:00:00..."
ffmpeg -y -i "$LIVE_IN" \
  -vf "drawtext=text='%{eif\:floor(t/3600)\:d\:2}\:%{eif\:mod(floor(t/60)\,60)\:d\:2}\:%{eif\:mod(floor(t)\,60)\:d\:2}.%{eif\:mod(floor(t*1000)\,1000)\:d\:3}':${STYLE}" \
  -c:v libx264 -crf 23 -preset fast -c:a copy \
  "$LIVE_OUT"

echo ""
echo "Done!"
echo "  Particle: $PARTICLE_OUT"
echo "  Live:     $LIVE_OUT"