#!/usr/bin/env python3
"""Draw the strandedness figure for Lecture 08.

A read matches an ACGTA on the forward strand. The reference also carries
an ACGTA on the reverse strand, boxed as well. The read gets a "!!" bubble.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Polygon

BG = "#f5f2ea"
INK = "#2f2a24"
MUTED = "#7a7266"
HILITE = "#eee4d2"
REV_FILL = "#dde7e8"
EDGE = "#9c8f7a"
ARROW = "#4f6d7a"

FORWARD = "GCTTACGTATAGCTGCAT"  # 18 bp; ACGTA at 5-9
REVERSE = "CGAATGCATATCGACGTA"  # complement, 3'->5'; ACGTA at 14-18
READ = "ACGTA"


def main() -> None:
    fig, ax = plt.subplots(figsize=(13.2, 6.2))
    fig.patch.set_facecolor(BG)
    ax.set_facecolor(BG)
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 11.2)
    ax.axis("off")

    ax.text(
        0.4,
        10.7,
        "RefSeq (3 Gbp)",
        fontsize=19,
        fontweight="bold",
        color=INK,
        ha="left",
        va="center",
    )
    ax.text(
        0.4,
        8.65,
        "Forward 5′ → 3′",
        fontsize=13,
        color=MUTED,
        ha="left",
        va="center",
    )
    ax.text(
        0.4,
        5.3,
        "Reverse 3′ → 5′",
        fontsize=13,
        color=MUTED,
        ha="left",
        va="center",
    )

    x0, dx = 3.0, 0.8
    y_fwd, y_rev = 7.7, 6.4

    # Box the ACGTA on the forward strand and the ACGTA on the reverse strand.
    boxes = (
        (x0 + 4 * dx - 0.34, y_fwd, HILITE, EDGE),
        (x0 + 13 * dx - 0.34, y_rev, REV_FILL, ARROW),
    )
    box_width = 4 * dx + 0.68
    for left, y, fill, edge in boxes:
        box = FancyBboxPatch(
            (left, y - 0.62),
            box_width,
            1.24,
            boxstyle="round,pad=0.02,rounding_size=0.16",
            linewidth=1.8,
            edgecolor=edge,
            facecolor=fill,
            linestyle=(0, (4, 3)),
            zorder=1,
        )
        ax.add_patch(box)

    for i, base in enumerate(FORWARD):
        ax.text(
            x0 + i * dx,
            y_fwd,
            base,
            fontsize=21,
            family="DejaVu Sans Mono",
            color=INK,
            ha="center",
            va="center",
            zorder=2,
        )
    for i, base in enumerate(REVERSE):
        ax.text(
            x0 + i * dx,
            y_rev,
            base,
            fontsize=21,
            family="DejaVu Sans Mono",
            color=INK,
            ha="center",
            va="center",
            zorder=2,
        )

    # Read above the forward strand --------------------------------------
    cx, cy = x0 + 4 * dx + 2 * dx, 9.55
    bw, bh = 3.8, 1.0
    read_box = FancyBboxPatch(
        (cx - bw / 2, cy - bh / 2),
        bw,
        bh,
        boxstyle="round,pad=0.04,rounding_size=0.16",
        linewidth=2.0,
        edgecolor=INK,
        facecolor="#fbf8f1",
        zorder=3,
    )
    ax.add_patch(read_box)

    ax.text(
        cx - bw / 2 - 0.22,
        cy,
        "5′",
        fontsize=13,
        color=MUTED,
        ha="right",
        va="center",
    )
    ax.text(
        cx + bw / 2 + 0.22,
        cy,
        "3′",
        fontsize=13,
        color=MUTED,
        ha="left",
        va="center",
    )
    ax.text(
        cx - bw / 2 - 0.9,
        cy,
        "read",
        fontsize=14,
        color=MUTED,
        ha="right",
        va="center",
    )

    for i, base in enumerate(READ):
        ax.text(
            cx + (i - 2) * 0.55,
            cy,
            base,
            fontsize=20,
            family="DejaVu Sans Mono",
            color=INK,
            ha="center",
            va="center",
            zorder=4,
        )

    # Arrow: read -> forward ACGTA
    ax.annotate(
        "",
        xy=(cx, y_fwd + 0.66),
        xytext=(cx, cy - 0.52),
        arrowprops=dict(
            arrowstyle="-|>",
            color=ARROW,
            lw=2.0,
            shrinkA=0,
            shrinkB=0,
        ),
        zorder=2,
    )

    # "!!" bubble next to the read --------------------------------------
    bx, by = 11.0, 9.9
    bw2, bh2 = 1.85, 1.25
    tail = Polygon(
        [[bx, by - 0.18], [bx - 0.52, by - 0.36], [bx, by + 0.3]],
        closed=True,
        facecolor="#fbf8f1",
        edgecolor=ARROW,
        linewidth=2.0,
        linestyle="-",
        zorder=2,
    )
    ax.add_patch(tail)

    bubble = FancyBboxPatch(
        (bx, by - bh2 / 2),
        bw2,
        bh2,
        boxstyle="round,pad=0.06,rounding_size=0.3",
        linewidth=2.0,
        edgecolor=ARROW,
        facecolor="#fbf8f1",
        linestyle="-",
        zorder=3,
    )
    ax.add_patch(bubble)
    ax.text(
        bx + bw2 / 2,
        by,
        "!!",
        fontsize=30,
        fontweight="bold",
        color=ARROW,
        ha="center",
        va="center",
        zorder=4,
    )

    # Badge --------------------------------------------------------------
    bx2, by2, bw3, bh3 = 6.1, 3.4, 6.6, 1.0
    badge = FancyBboxPatch(
        (bx2, by2),
        bw3,
        bh3,
        boxstyle="round,pad=0.06,rounding_size=0.25",
        linewidth=1.8,
        edgecolor=ARROW,
        facecolor="#fbf8f1",
        zorder=3,
    )
    ax.add_patch(badge)
    ax.text(
        bx2 + bw3 / 2,
        by2 + bh3 / 2,
        "both are perfect matches",
        fontsize=14,
        fontweight="bold",
        color=ARROW,
        ha="center",
        va="center",
        zorder=4,
    )

    out = Path(__file__).resolve().parents[2] / "_assets" / "strandedness.png"
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
