#!/usr/bin/env python3
"""
Compare detected bar timings against the beat grid computed by Yoeminrak.sc.

Yoeminrak.sc sections formula (SC has no operator precedence — left to right):
  sections = raw_values.collect{|i x| x * 52 + 6 + i}
  => section[index] = ((index * 52) + 6) + raw_value

secDur = sections.differentiate.drop(1)
  => secDur[j] = sections[j+1] - sections[j]

Each cycle has 20 beats, evenly spaced within its secDur.
Expected time of beat b (1-based) in cycle c (1-based):
  t_expected = sections[c-1] + (b - 1) * secDur[c-1] / 20
"""

import csv

RESULTS_FILE = "/tmp/bar_timing_results.txt"

# Raw values from Yoeminrak.sc
raw = [-2.7, -1.3, 0, -3, -2.75, -3.5, -4, -8, -14, -23, -34, -44, -56, -67, -81, -94, -107]

# SC formula: left-to-right, i=element, x=index
sections = [((x * 52) + 6) + i for x, i in enumerate(raw)]

# secDur = differentiate.drop(1) = differences between consecutive sections
sec_dur = [sections[j+1] - sections[j] for j in range(len(sections) - 1)]

NUM_CYCLES = len(sec_dur)   # 16
NUM_BARS   = 20

def fmt_tc(s):
    h, rem = divmod(abs(s), 3600)
    m, sec = divmod(rem, 60)
    sign = "-" if s < 0 else ""
    return f"{sign}{int(h):02d}:{int(m):02d}:{sec:05.2f}"

# Load detected results
detected = {}   # (cycle, bar) -> (timecode_s, note)
with open(RESULTS_FILE) as f:
    reader = csv.DictReader(f, delimiter="\t")
    for row in reader:
        c, b = int(row["cycle"]), int(row["bar"])
        t_s  = float(row["timecode_s"]) if row["timecode_s"] else None
        detected[(c, b)] = (t_s, row.get("note", ""))

# Print comparison — clean detections only
# Clean = detected, not burst, and detected time falls within the cycle window
print(f"Sections (seconds): {[round(s,2) for s in sections]}")
print(f"SecDur   (seconds): {[round(d,2) for d in sec_dur]}")
print()

hdr = f"{'Cyc':>4} {'Bar':>4}  {'Expected':>10}  {'Detected':>10}  {'Diff':>8}"
print(hdr)
print("─" * len(hdr))

for c in range(1, NUM_CYCLES + 1):
    s0       = sections[c - 1]
    s1       = sections[c]
    dur      = sec_dur[c - 1]
    beat_dur = dur / NUM_BARS
    rows     = []

    for b in range(1, NUM_BARS + 1):
        t_exp       = s0 + (b - 1) * beat_dur
        t_det, note = detected.get((c, b), (None, ""))

        if t_det is None:
            continue
        if note == "burst":
            continue
        if not (s0 <= t_det < s1):   # outside cycle window → false trigger
            continue
        if abs(t_det - t_exp) > 10:  # more than 10s off expected → likely noise
            continue

        diff = t_det - t_exp
        rows.append((b, t_exp, t_det, diff))

    if rows:
        for b, t_exp, t_det, diff in rows:
            print(f"  {c:2d}   {b:2d}  {fmt_tc(t_exp):>10}  {fmt_tc(t_det):>10}  {diff:+.2f}s")
        print()
