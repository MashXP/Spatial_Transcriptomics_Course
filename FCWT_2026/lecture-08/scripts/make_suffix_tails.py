"""Suffix array diagrams for lecture-08 indexing slides.

Two figures, one per slide:
  suffix_tails.png   - the reference and the tail that starts at every
                       position, listed in position order
  suffix_sorted.png  - the same tails sorted by letters, grouped by first
                       letter, so the start column comes out of order

Run: ~/.conda/envs/mdd/bin/python lecture-08/scripts/make_suffix_tails.py
"""

import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

INK = "#22272b"
PAPER = "#f5f2ea"
MUTED = "#8a938f"
ACCENT = "#b03a56"

LETTER = {"A": "#2b7a78", "C": "#3b6ea5", "G": "#b03a56", "T": "#8a6d3b"}

REF = "ACGTACGT"
n = len(REF)
tails = [REF[i:] for i in range(n)]
order = sorted(range(n), key=lambda i: tails[i])
rows = [(r + 1, i, tails[i]) for r, i in enumerate(order)]
tail_w = max(len(t) for t in tails)

MONO = "DejaVu Sans Mono"
ROW_H = 6.4


def new_ax(w, h):
    fig, ax = plt.subplots(figsize=(w, h))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis("off")
    fig.patch.set_facecolor(PAPER)
    ax.set_facecolor(PAPER)
    return fig, ax


def place(ax, x, y, s, size=11, colour=INK, family=MONO, weight="normal",
          ha="left", va="center"):
    ax.text(x, y, s, size=size, color=colour, family=family, weight=weight,
            ha=ha, va=va, zorder=10)


def box(ax, x, y, w, h, colour, lw=1.1, fill="none"):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.6",
                                linewidth=lw, edgecolor=colour,
                                facecolor=fill, zorder=5))


# ---------------------------------------------------------- figure 1: tails
fig, ax = new_ax(6.0, 5.2)

place(ax, 2, 94, "the reference: 8 letters, 8 positions", size=12.5,
      family="DejaVu Sans", weight="bold")

cell = 10.5
STRIP_TOP, STRIP_H = 79.0, 9.0
x0 = 2.0
for i, ch in enumerate(REF):
    x = x0 + i * cell
    box(ax, x, STRIP_TOP, cell, STRIP_H, MUTED)
    place(ax, x + cell / 2, STRIP_TOP + STRIP_H / 2, ch, size=13,
          colour=LETTER[ch], weight="bold", ha="center")
    place(ax, x + cell / 2, STRIP_TOP - 4.6, str(i), size=9.5,
          colour=MUTED, ha="center")

place(ax, 2, 64, "the tail from each position, in position order",
      size=11.5, family="DejaVu Sans")

label_x, tail_right = 2.0, 74.0
for i, t in enumerate(tails):
    y = 56.0 - i * ROW_H
    place(ax, label_x, y, f"start {i}", size=10.5, colour=MUTED,
          family="DejaVu Sans")
    for k, ch in enumerate(t):
        place(ax, tail_right - (len(t) - k) * 3.6, y, ch, size=11.5,
              colour=LETTER[ch])

place(ax, 2, 4.5, "8 letters  ->  8 positions  ->  8 rows", size=11.5,
      weight="bold", family="DejaVu Sans")



# ------------------------------------------------------- figure 2: sorted
fig2, ax2 = new_ax(5.4, 5.2)

place(ax2, 2, 94, "the same 8 tails, sorted by letters", size=12.5,
      family="DejaVu Sans", weight="bold")

ROW_X, START_X, TAIL_X = 8, 26, 40
HEAD, TOP = 84.0, 78.0
place(ax2, ROW_X, HEAD, "row", size=9.5, colour=MUTED, family="DejaVu Sans")
place(ax2, START_X, HEAD, "start", size=9.5, colour=MUTED, family="DejaVu Sans")
place(ax2, TAIL_X, HEAD, "tail", size=9.5, colour=MUTED, family="DejaVu Sans")

for r, start, t in rows:
    y = TOP - (r - 1) * ROW_H
    place(ax2, ROW_X, y, str(r), size=11)
    place(ax2, START_X, y, str(start), size=11, colour=ACCENT, weight="bold")
    for k, ch in enumerate(t):
        place(ax2, TAIL_X + k * 3.6, y, ch, size=11.5, colour=LETTER[ch])

for r1, r2, ch in [(1, 2, "A"), (3, 4, "C"), (5, 6, "G"), (7, 8, "T")]:
    y1 = TOP - (r1 - 1) * ROW_H
    y2 = TOP - (r2 - 1) * ROW_H
    box(ax2, TAIL_X - 4.2, min(y1, y2) - 2.6, 2.6, abs(y1 - y2) + 5.2,
        LETTER[ch], lw=1.4)

place(ax2, 2, 15.5, "the first letter picks the block,", size=10.5,
      family="DejaVu Sans")
place(ax2, 2, 9.5, "the next letter narrows it", size=10.5, family="DejaVu Sans")

_here = os.path.dirname(os.path.abspath(__file__))
_assets = os.path.abspath(os.path.join(_here, "..", "..", "_assets"))
for _fig, _name in ((fig, "suffix_tails.png"), (fig2, "suffix_sorted.png")):
    _out = os.path.join(_assets, _name)
    _fig.savefig(_out, facecolor=PAPER, dpi=200, bbox_inches="tight",
                pad_inches=0.22)
    print(f"wrote {_out}")
