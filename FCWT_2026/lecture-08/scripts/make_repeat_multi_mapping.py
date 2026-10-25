#!/usr/bin/env python3
"""Draw the repeat / multi-mapping figure for Lecture 08.

A single 5 bp read matches three identical copies of the same 5 bp repeat
in the mock reference. Dashed arrows show that exact matching returns three
equally good homes.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

BG = "#f5f2ea"
INK = "#2f2a24"
MUTED = "#7a7266"
HILITE = "#eee4d2"
EDGE = "#9c8f7a"
ARROW = "#4f6d7a"

REF = "TGCAACGTAGCTTACGTATAGCACGTAGATC"  # 31 bp; ACGTA at 5-9, 14-18, 23-27
READ = "ACGTA"
COPY_STARTS = (4, 13, 22)  # zero-based starts


def main() -> None:
    fig, ax = plt.subplots(figsize=(13.2, 5.8))
    fig.patch.set_facecolor(BG)
    ax.set_facecolor(BG)
    ax.set_xlim(0, 25.8)
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

    x0, dx, y_ref = 0.8, 0.8, 7.5

    copy_centers = []
    for n, start in enumerate(COPY_STARTS, start=1):
        left = x0 + start * dx - 0.34
        width = 4 * dx + 0.68
        center = left + width / 2
        copy_centers.append(center)

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
            center,
            y_ref + 0.92,
            f"copy {n}",
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
            fontsize=23,
            family="DejaVu Sans Mono",
            color=INK,
            ha="center",
            va="center",
            zorder=2,
        )

    # Read ---------------------------------------------------------------
    cx, cy = 12.8, 3.2
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
        zorder=3,
    )
    ax.add_patch(read_box)

    for i, base in enumerate(READ):
        ax.text(
            cx + (i - 2) * read_dx,
            cy,
            base,
            fontsize=23,
            family="DejaVu Sans Mono",
            color=INK,
            ha="center",
            va="center",
            zorder=4,
        )

    ax.text(
        cx,
        cy - 1.35,
        "Read (150 bp)",
        fontsize=16,
        color=MUTED,
        ha="center",
        va="center",
    )

    # Dashed arrows: one read, three equally good homes -----------------
    rads = (-0.16, 0.0, 0.16)
    for center, rad in zip(copy_centers, rads):
        ax.annotate(
            "",
            xy=(center, y_ref - 0.72),
            xytext=(cx, cy + 0.62),
            arrowprops=dict(
                arrowstyle="-|>",
                color=ARROW,
                lw=1.7,
                linestyle=(0, (4, 3)),
                shrinkA=0,
                shrinkB=0,
                connectionstyle=f"arc3,rad={rad}",
            ),
            zorder=1,
        )

    # "3 hits" badge -----------------------------------------------------
    bx, by, bw, bh = 16.4, 2.45, 5.4, 1.25
    badge = FancyBboxPatch(
        (bx, by),
        bw,
        bh,
        boxstyle="round,pad=0.06,rounding_size=0.28",
        linewidth=1.8,
        edgecolor=ARROW,
        facecolor="#fbf8f1",
        zorder=3,
    )
    ax.add_patch(badge)
    ax.text(
        bx + bw / 2,
        by + bh / 2,
        "3 equally good hits",
        fontsize=14,
        fontweight="bold",
        color=ARROW,
        ha="center",
        va="center",
        zorder=4,
    )

    out = Path(__file__).resolve().parents[2] / "_assets" / "repeat_multi_mapping.png"
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
