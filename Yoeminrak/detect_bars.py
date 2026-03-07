#!/usr/bin/env python3
"""
detect_bars.py
Calibrate bar slot positions from a reference frame, then auto-detect
the first appearance of each bar in each cycle.

Output flags:
  (clean)  — confident single-bar detection
  !        — burst: many bars triggered at once, likely arm interference
  ?        — not detected in this cycle
"""

import os, sys
import numpy as np
from PIL import Image
import matplotlib
matplotlib.use("MacOSX")
import matplotlib.pyplot as plt

FRAMES_DIR   = "/Users/michael/tank/Hyojin/Video Sync/bar_frames"
ACTUAL_FPS   = 30000 / 1001
SECTIONS     = [3.3, 56.7, 110, 159, 211.25, 262.5, 314, 362, 408,
                451, 492, 534, 574, 615, 653, 692, 731]
NUM_BARS     = 20
REF_TIME     = 154.0   # 2:34 — frame with all bars visible
REF_WINDOW   = 15      # average this many frames either side of REF_TIME
SEARCH_TOP   = 33      # row bounds within the crop
SEARCH_BOT   = 156
THRESH_ON    = 30      # mean brightness to declare bar lit
DEBOUNCE     = 6       # consecutive frames required to commit (~0.2 s)
BURST_NEARBY = 3       # bars within BURST_WINDOW that make an event "burst"
BURST_WINDOW = 0.5     # seconds
CROP_COL_START = 6     # skip leftmost columns of crop (noisy edge)

frames_list = sorted(f for f in os.listdir(FRAMES_DIR) if f.endswith(".png"))
NFRAMES = len(frames_list)

def fmt_tc(s):
    h, rem = divmod(s, 3600)
    m, sec = divmod(rem, 60)
    return f"{int(h):02d}:{int(m):02d}:{sec:05.2f}"

def load_gray(fi):
    return np.array(
        Image.open(os.path.join(FRAMES_DIR, frames_list[fi])).convert("L")
    )

# ── Calibrate from reference frame ────────────────────────────────────────────

fi_ref  = max(0, min(int(REF_TIME * ACTUAL_FPS), NFRAMES - 1))
fi_lo   = max(0, fi_ref - REF_WINDOW)
fi_hi   = min(NFRAMES - 1, fi_ref + REF_WINDOW)
ref_img = np.mean(
    [load_gray(fi)[SEARCH_TOP:SEARCH_BOT, CROP_COL_START:] for fi in range(fi_lo, fi_hi + 1)],
    axis=0
)
profile = ref_img.mean(axis=1)

def find_peaks(arr, min_dist=3):
    """Simple local-maxima finder."""
    candidates = []
    for i in range(1, len(arr) - 1):
        if arr[i] >= arr[i-1] and arr[i] >= arr[i+1]:
            candidates.append(i)
    # Merge peaks within min_dist
    merged = []
    for p in candidates:
        if merged and p - merged[-1] < min_dist:
            if arr[p] > arr[merged[-1]]:
                merged[-1] = p
        else:
            merged.append(p)
    return np.array(merged)

all_peaks = find_peaks(profile, min_dist=3)

# Keep top NUM_BARS by brightness
if len(all_peaks) >= NUM_BARS:
    top_idx   = np.argsort(profile[all_peaks])[-NUM_BARS:]
    bar_peaks = np.sort(all_peaks[top_idx])
else:
    bar_peaks = all_peaks
    print(f"WARNING: only {len(bar_peaks)} peaks found (expected {NUM_BARS}). "
          "Falling back to equal division.")
    sh = (SEARCH_BOT - SEARCH_TOP) / NUM_BARS
    bar_peaks = np.array([int(SEARCH_TOP + (i + 0.5) * sh) - SEARCH_TOP
                          for i in range(NUM_BARS)])

abs_peaks = bar_peaks + SEARCH_TOP  # absolute row indices

# Non-overlapping slots: boundaries at midpoints between consecutive peaks
mids  = [(abs_peaks[i] + abs_peaks[i + 1]) // 2 for i in range(len(abs_peaks) - 1)]
tops  = [SEARCH_TOP] + mids
bots  = mids + [SEARCH_BOT]
slots = list(zip(tops, bots))

# Pad to NUM_BARS with equal division if calibration failed
if len(slots) < NUM_BARS:
    sh    = (SEARCH_BOT - SEARCH_TOP) / NUM_BARS
    slots = [(int(SEARCH_TOP + i * sh), int(SEARCH_TOP + (i + 1) * sh))
             for i in range(NUM_BARS)]

slot_thresholds = [THRESH_ON] * NUM_BARS

# ── Show calibration plot ─────────────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(8, 6))
fig.patch.set_facecolor("#111")
fig.suptitle(f"Calibration  —  {fmt_tc(REF_TIME)} ±{REF_WINDOW} frames  ({len(bar_peaks)} peaks found)",
             color="white")

rows = np.arange(SEARCH_TOP, SEARCH_BOT)
ax1.plot(profile, rows, color="white", linewidth=0.9)
ax1.scatter(profile[bar_peaks], abs_peaks, color="yellow", s=25, zorder=5)
ax1.set_ylim(SEARCH_BOT, SEARCH_TOP)
ax1.set_xlabel("Mean brightness", color="white")
ax1.set_ylabel("Row (in crop)", color="white")
ax1.tick_params(colors="white")
ax1.set_facecolor("#222")
ax1.set_title("Vertical brightness profile", color="white")

bar_img = ref_img
ax2.imshow(bar_img, cmap="gray", aspect="auto", vmin=0, vmax=255,
           extent=[0, bar_img.shape[1], SEARCH_BOT, SEARCH_TOP])
for r0, _ in slots:
    ax2.axhline(r0, color="red", alpha=0.6, linewidth=0.8)
ax2.axhline(slots[-1][1], color="red", alpha=0.6, linewidth=0.8)
ax2.set_facecolor("#111")
ax2.set_title("Calibrated slots", color="white")
ax2.axis("off")

plt.tight_layout()
CALIB_PNG = "/tmp/bar_calibration.png"
plt.savefig(CALIB_PNG, dpi=150, facecolor=fig.get_facecolor())
plt.close("all")
print(f"Calibration plot saved → {CALIB_PNG}")
print(f"{len(slots)} slots detected. Proceeding with detection...")

# ── Load per-slot brightness for all frames ───────────────────────────────────

print(f"Computing brightness for {NFRAMES} frames × {NUM_BARS} slots...")
slot_bright = np.zeros((NFRAMES, NUM_BARS), dtype=np.float32)
for fi, fname in enumerate(frames_list):
    img = np.array(Image.open(os.path.join(FRAMES_DIR, fname)).convert("L"))
    for si, (r0, r1) in enumerate(slots):
        slot_bright[fi, si] = img[r0:r1, CROP_COL_START:].mean()
    if fi % 2000 == 0:
        print(f"  {fi}/{NFRAMES}", end="\r", flush=True)
print(f"  {NFRAMES}/{NFRAMES} done.")

# ── Detect first appearances ──────────────────────────────────────────────────

def get_cycle(t):
    for i in range(len(SECTIONS) - 1):
        if SECTIONS[i] <= t < SECTIONS[i + 1]:
            return i + 1
    return None

events = []   # (time_s, cycle, bar_1based)

slot_on       = [False] * NUM_BARS
pending_count = [0]     * NUM_BARS
prev_cycle    = None

for fi in range(NFRAMES):
    t   = fi / ACTUAL_FPS
    cyc = get_cycle(t)

    if cyc != prev_cycle:
        slot_on       = [False] * NUM_BARS
        pending_count = [0]     * NUM_BARS
        prev_cycle    = cyc

    if cyc is None:
        continue

    for si in range(NUM_BARS):
        if slot_on[si]:
            continue
        if slot_bright[fi, si] >= slot_thresholds[si]:
            pending_count[si] += 1
            if pending_count[si] >= DEBOUNCE:
                slot_on[si] = True
                pending_count[si] = 0
                events.append((t, cyc, si + 1))
        else:
            pending_count[si] = 0

# ── Burst flagging ────────────────────────────────────────────────────────────

def is_burst(t, cyc, bar):
    nearby = sum(
        1 for et, ec, eb in events
        if ec == cyc and eb != bar and abs(et - t) <= BURST_WINDOW
    )
    return nearby >= BURST_NEARBY

# ── Print results ─────────────────────────────────────────────────────────────

NUM_CYCLES   = len(SECTIONS) - 1
detected     = {(cyc, bar): t for t, cyc, bar in events}

SAVE_FILE = "/tmp/bar_timing_results.txt"

print(f"\n{'Cycle':>6}  {'Bar':>4}  Timecode      Note")
print("─" * 46)
prev_cyc = None
for cyc in range(1, NUM_CYCLES + 1):
    if cyc != prev_cyc:
        if prev_cyc is not None:
            print()
        prev_cyc = cyc
    for bar in range(1, NUM_BARS + 1):
        if (cyc, bar) in detected:
            t    = detected[(cyc, bar)]
            flag = "  ! burst" if is_burst(t, cyc, bar) else ""
            print(f"  {cyc:4d}    {bar:2d}   {fmt_tc(t)}{flag}")
        else:
            print(f"  {cyc:4d}    {bar:2d}   {'?':>8}       ? not detected")

print(f"\nTotal detected: {len(events)} / {NUM_CYCLES * NUM_BARS}")
print("!  = burst — multiple bars triggered simultaneously (arm likely)")
print("?  = not detected — bar may have been obscured all cycle")

with open(SAVE_FILE, "w") as f:
    f.write("cycle\tbar\ttimecode_s\ttimecode\tnote\n")
    for cyc in range(1, NUM_CYCLES + 1):
        for bar in range(1, NUM_BARS + 1):
            if (cyc, bar) in detected:
                t    = detected[(cyc, bar)]
                note = "burst" if is_burst(t, cyc, bar) else ""
                f.write(f"{cyc}\t{bar}\t{t:.4f}\t{fmt_tc(t)}\t{note}\n")
            else:
                f.write(f"{cyc}\t{bar}\t\t\tnot detected\n")
print(f"Saved → {SAVE_FILE}")
