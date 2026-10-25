"""Lookup diagram for the "Lookup, Not Scan" slide.

Three panels, one figure: the sorted 8-tail list, narrowed once per read
letter group. Read GTACGT.

  step 1  G       -> rows 5-6 survive, everything else is dropped
  step 2  GT      -> rows 5 and 6 both begin with GT
  step 3  GTACGT  -> row 5 ends early, row 6 matches -> start 2

Run: ~/.conda/envs/mdd/bin/python lecture-08/scripts/make_suffix_lookup.py
"""

import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

INK = "#22272b"
PAPER = "#f5f2ea"
MUTED = "#8a938f"
FADE = "#cbd0d3"
ACCENT = "#b03a56"

LETTER = {"A": "#2b7a78", "C": "#3b6ea5", "G": "#b03a56", "T": "#8a6d3b"}

REF = "ACGTACGT"
tails = [REF[i:] for i in range(len(REF))]
order = sorted(range(len(REF)), key=lambda i: tails[i])
rows = [(r + 1, i, tails[i]) for r, i in enumerate(order)]
QUERY = "GTACGT"
STEPS = [QUERY[:1], QUERY[:2], QUERY]

MONO = "DejaVu Sans Mono"
ROW_H = 6.4
TOP = 78.0
ROW_X, START_X, TAIL_X = 0.0, 8.0, 16.0
TAIL_DX = 1.6
PANEL_X = [2.0, 37.0, 72.0]

fig, ax = plt.subplots(figsize=(12.4, 2.6))
ax.set_xlim(0, 112)
ax.set_ylim(31, 96)
ax.axis("off")
fig.patch.set_facecolor(PAPER)
ax.set_facecolor(PAPER)


def place(x, y, s, size=10, colour=INK, family=MONO, weight="normal",
          ha="left", va="center"):
    ax.text(x, y, s, size=size, color=colour, family=family, weight=weight,
            ha=ha, va=va, zorder=10)


def box(x, y, w, h, colour, lw=1.4, fill="none"):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.5",
                                linewidth=lw, edgecolor=colour,
                                facecolor=fill, zorder=6))


def prefix_len(tail, step):
    """How many leading letters of the step are shared by this tail."""
    k = 0
    while k < min(len(tail), len(step)) and tail[k] == step[k]:
        k += 1
    return k


for si, step in enumerate(STEPS):
    x = PANEL_X[si]

    # step header
    place(x, 92, f"step {si + 1}", size=10.5, colour=MUTED, family="DejaVu Sans")
    place(x + 12, 92, step, size=14, colour=ACCENT, weight="bold")

    # column labels on every panel: each panel is the same table
    place(x + ROW_X, TOP + 7, "row", size=9, colour=MUTED, family="DejaVu Sans")
    place(x + START_X, TOP + 7, "start", size=9, colour=MUTED, family="DejaVu Sans")
    place(x + TAIL_X, TOP + 7, "tail", size=9, colour=MUTED, family="DejaVu Sans")

    for r, start, tail in rows:
        y = TOP - (r - 1) * ROW_H
        live = prefix_len(tail, step) == len(step)
        k = prefix_len(tail, step)

        place(x + ROW_X, y, str(r), size=9.5, colour=INK if live else FADE)
        place(x + START_X, y, str(start), size=9.5,
              colour=ACCENT if live else FADE,
              weight="bold" if live else "normal")

        for i, ch in enumerate(tail):
            if live:
                c = LETTER[ch] if i < k else MUTED
            else:
                c = FADE
            place(x + TAIL_X + i * TAIL_DX, y, ch, size=10, colour=c,
                  weight="bold" if (live and i < k) else "normal")

        if si == 2 and r == 6:
            box(x + TAIL_X - 1.5, y - 2.6, 14.2, 5.2, ACCENT, lw=1.6)
            place(x + TAIL_X + 14.0, y, "start 2", size=11, colour=ACCENT,
                  weight="bold", ha="left")
        if si == 2 and r == 5:
            place(x + TAIL_X + 14.0, y, "ends early", size=10, colour=FADE,
                  family="DejaVu Sans")

_here = os.path.dirname(os.path.abspath(__file__))
_out = os.path.join(_here, "..", "..", "_assets", "suffix_lookup.png")
fig.savefig(_out, facecolor=PAPER, dpi=200, bbox_inches="tight", pad_inches=0.22)
print(f"wrote {_out}")
