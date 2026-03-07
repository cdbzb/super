#!/usr/bin/env python3
"""
Detect when each of the 20 bar lights first appears in the column on the
left edge of the black panel.

Strategy: divide the bar column into 20 fixed vertical slots. For each slot,
detect when its mean brightness crosses a threshold within each cycle window.
Hysteresis prevents re-triggering on flicker.

Crop: x=565, y=360, w=35, h=232 (original 1280x720 frame)
Bars: rows 33–156 of the crop (~123 px for ~20 bars, ~6 px each)
"""

import os
import numpy as np
from PIL import Image

FRAMES_DIR = "/Users/michael/tank/Hyojin/Video Sync/bar_frames"
ACTUAL_FPS = 30000 / 1001

# Cycle windows (live-video seconds) from Yoeminrak.sections
SECTIONS = [3.3, 56.7, 110, 159, 211.25, 262.5, 314, 362, 408,
            451, 492, 534, 574, 615, 653, 692, 731]

# Bar column
BAR_COL_TOP = 33     # row where first bar starts
BAR_COL_BOT = 156    # row where last bar ends
NUM_BARS    = 20

# Detection thresholds (hysteresis)
THRESH_ON   = 55     # mean brightness to declare slot lit
THRESH_OFF  = 35     # mean brightness to declare slot dark again
DEBOUNCE    = 6      # frames slot must stay above THRESH_ON to commit

ACTUAL_FPS = 30000 / 1001

def fmt_tc(seconds):
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = seconds % 60
    return f"{h:02d}:{m:02d}:{s:05.2f}"

def get_cycle(t):
    for i in range(len(SECTIONS) - 1):
        if SECTIONS[i] <= t < SECTIONS[i + 1]:
            return i + 1
    return None

# Pre-compute slot row ranges
slot_h = (BAR_COL_BOT - BAR_COL_TOP) / NUM_BARS
slots = [(int(BAR_COL_TOP + i * slot_h), int(BAR_COL_TOP + (i + 1) * slot_h))
         for i in range(NUM_BARS)]

# ── Load frames ───────────────────────────────────────────────────────────────
frames = sorted(f for f in os.listdir(FRAMES_DIR) if f.endswith(".png"))
print(f"{len(frames)} frames — computing slot brightness...")

# slot_brightness[frame, slot] = mean brightness
slot_bright = np.zeros((len(frames), NUM_BARS), dtype=np.float32)
for fi, fname in enumerate(frames):
    img = np.array(Image.open(os.path.join(FRAMES_DIR, fname)).convert("L"))
    for si, (r0, r1) in enumerate(slots):
        slot_bright[fi, si] = img[r0:r1, :].mean()

print("Detecting bar events...")

# ── Per-slot hysteresis state machine ────────────────────────────────────────
# Within each cycle, once a slot turns on it stays on (we only record first on).
# At section boundary → reset all slot states.

events = []   # (time_s, cycle, bar_slot_1based)

slot_on        = [False] * NUM_BARS   # committed on/off within cycle
pending_count  = [0]     * NUM_BARS   # consecutive frames above THRESH_ON
prev_cycle     = None

for fi in range(len(frames)):
    t   = fi / ACTUAL_FPS
    cyc = get_cycle(t)

    if cyc != prev_cycle:
        slot_on       = [False] * NUM_BARS
        pending_count = [0]     * NUM_BARS
        prev_cycle    = cyc

    if cyc is None:
        continue

    for si in range(NUM_BARS):
        b = slot_bright[fi, si]
        if slot_on[si]:
            # Once on, stays on for the rest of the cycle (bars don't turn off individually)
            continue
        if b >= THRESH_ON:
            pending_count[si] += 1
            if pending_count[si] >= DEBOUNCE:
                slot_on[si] = True
                pending_count[si] = 0
                events.append((t, cyc, si + 1))
        else:
            pending_count[si] = 0

# ── Print ─────────────────────────────────────────────────────────────────────
print(f"\n{'Cycle':>6}  {'Slot':>5}  Timecode")
print("─" * 34)
prev_cyc = None
for t, cyc, slot in sorted(events, key=lambda e: (e[1], e[2])):
    if cyc != prev_cyc:
        if prev_cyc is not None:
            print()
        prev_cyc = cyc
    print(f"  {cyc:4d}    {slot:2d}   {fmt_tc(t)}")

print(f"\nTotal: {len(events)} events across {len(set(e[1] for e in events))} cycles")
