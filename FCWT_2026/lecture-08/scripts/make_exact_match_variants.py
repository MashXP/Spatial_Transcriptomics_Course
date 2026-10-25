#!/usr/bin/env python3
"""Draw the exact-matching failure figure for Lecture 08.

A short mock reference has two identical 5 bp sites. A 5 bp read carries
one mismatch (red), so neither site is an exact match. The read is tilted
under the reference with a "???" thought bubble.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyBboxPatch, Polygon
from matplotlib.transforms import Affine2D

BG = "#f5f2ea"
INK = "#2f2a24"
MUTED = "#7a7266"
ACCENT = "#b03a2e"
HILITE = "#eee4d2"
EDGE = "#9c8f7a"

REF = "TGCAACGTAGCTTAGTTGCACGTAGATC"  # 28 bp; ACGTA at 5-9 and 20-24
READ = "ACGTT"  # one mismatch in the final base
FIT_STARTS = (4, 19)  # zero-based starts of the two ACGTA fits


def main() -> None:
    fig, ax = plt.subplots(figsize=(13.2, 5.6))
    fig.patch.set_facecolor(BG)
    ax.set_facecolor(BG)
    ax.set_xlim(0, 26.5)
    ax.set_ylim(0, 10)
    ax.axis("off")

    # Reference sequence -------------------------------------------------
    ax.text(
        0.4,
        9.0,
        "RefSeq (3 Gbp)",
        fontsize=19,
        fontweight="bold",
        color=INK,
        ha="left",
        va="center",
    )

    x0, dx, y_ref = 0.8, 0.9, 7.5

    # Highlight the two possible 5 bp fits.
    for start, label in ((FIT_STARTS[0], "fit 1"), (FIT_STARTS[1], "fit 2")):
        left = x0 + start * dx - 0.38
        width = 4 * dx + 0.76
        box = FancyBboxPatch(
            (left, y_ref - 0.68),
            width,
            1.36,
            boxstyle="round,pad=0.02,rounding_size=0.18",
            linewidth=1.8,
            edgecolor=EDGE,
            facecolor=HILITE,
            linestyle=(0, (4, 3)),
            zorder=1,
        )
        ax.add_patch(box)
        ax.text(
            left + width / 2,
            y_ref + 0.92,
            label,
            fontsize=12,
            color=MUTED,
            ha="center",
            va="center",
        )

    for i, base in enumerate(REF):
        ax.text(
            x0 + i * dx,
            y_ref,
            base,
            fontsize=25,
            family="DejaVu Sans Mono",
            color=INK,
            ha="center",
            va="center",
            zorder=2,
        )

    # Read ---------------------------------------------------------------
    cx, cy = 12.0, 3.4
    theta = 8.0  # slight tilt
    read_dx = 0.72
    box_w = 4 * read_dx + 0.72
    box_h = 1.18

    read_box = FancyBboxPatch(
        (cx - box_w / 2, cy - box_h / 2),
        box_w,
        box_h,
        boxstyle="round,pad=0.04,rounding_size=0.18",
        linewidth=2.0,
        edgecolor=INK,
        facecolor="#fbf8f1",
        zorder=2,
    )
    read_box.set_transform(Affine2D().rotate_deg_around(cx, cy, theta) + ax.transData)
    ax.add_patch(read_box)

    th = np.deg2rad(theta)
    for i, base in enumerate(READ):
        off = (i - 2) * read_dx
        x = cx + off * np.cos(th)
        y = cy + off * np.sin(th)
        is_error = i == len(READ) - 1
        ax.text(
            x,
            y,
            base,
            fontsize=24,
            family="DejaVu Sans Mono",
            color=ACCENT if is_error else INK,
            fontweight="bold" if is_error else "normal",
            ha="center",
            va="center",
            rotation=theta,
            rotation_mode="anchor",
            zorder=3,
        )

    ax.text(
        cx,
        cy - 1.35,
        "Read (150 bp, 1 error)",
        fontsize=16,
        color=MUTED,
        ha="center",
        va="center",
    )

    # "???" thought bubble ----------------------------------------------
    bx, by = 14.2, 5
    bw, bh = 2.7, 1.55

    tail = Polygon(
        [[bx, by - 0.2], [bx - 0.62, by - 0.42], [bx, by + 0.32]],
        closed=True,
        facecolor="#fbf8f1",
        edgecolor=INK,
        linewidth=2.0,
        linestyle="-",
        zorder=2,
    )
    ax.add_patch(tail)

    bubble = FancyBboxPatch(
        (bx, by - bh / 2),
        bw,
        bh,
        boxstyle="round,pad=0.08,rounding_size=0.35",
        linewidth=2.0,
        edgecolor=INK,
        facecolor="#fbf8f1",
        linestyle="-",
        zorder=3,
    )
    ax.add_patch(bubble)
    ax.text(
        bx + bw / 2,
        by,
        "???",
        fontsize=32,
        fontweight="bold",
        color=INK,
        ha="center",
        va="center",
        zorder=4,
    )

    out = Path(__file__).resolve().parents[2] / "_assets" / "exact_match_variants.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(
        out,
        dpi=220,
        facecolor=BG,
        bbox_inches="tight",
        pad_inches=0.12,
    )
    plt.close(fig)
    print(out)


if __name__ == "__main__":
    main()
