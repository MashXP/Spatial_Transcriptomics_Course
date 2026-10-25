#!/usr/bin/env python3
"""Draw the before/after split-read figure for Lecture 08.

Before: one contiguous 100 bp read cannot match a genome with an intron.
After: the aligner splits the read into 40 bp + 60 bp around the intron.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

BG = "#f5f2ea"
INK = "#2f2a24"
MUTED = "#7a7266"
EXON_FILL = "#dde7e8"
EXON_EDGE = "#4f6d7a"
READ = "#4f6d7a"
ACCENT = "#b03a2e"
LINE = "#9c8f7a"


def exon(ax, x, y, w, h, label):
    box = FancyBboxPatch(
        (x, y),
        w,
        h,
        boxstyle="round,pad=0.02,rounding_size=0.08",
        linewidth=1.8,
        edgecolor=EXON_EDGE,
        facecolor=EXON_FILL,
        zorder=2,
    )
    ax.add_patch(box)
    ax.text(
        x + w / 2,
        y + h / 2,
        label,
        fontsize=13,
        color=INK,
        ha="center",
        va="center",
        zorder=3,
    )


def read_bar(ax, x, y, w, h, label, fill=READ):
    box = FancyBboxPatch(
        (x, y),
        w,
        h,
        boxstyle="round,pad=0.02,rounding_size=0.08",
        linewidth=1.6,
        edgecolor=fill,
        facecolor=fill,
        zorder=2,
    )
    ax.add_patch(box)
    ax.text(
        x + w / 2,
        y + h / 2,
        label,
        fontsize=13,
        color="white" if fill == READ else INK,
        ha="center",
        va="center",
        zorder=3,
    )


def badge(ax, x, y, w, h, text, color):
    box = FancyBboxPatch(
        (x, y),
        w,
        h,
        boxstyle="round,pad=0.06,rounding_size=0.25",
        linewidth=1.8,
        edgecolor=color,
        facecolor="#fbf8f1",
        zorder=2,
    )
    ax.add_patch(box)
    ax.text(
        x + w / 2,
        y + h / 2,
        text,
        fontsize=13,
        fontweight="bold",
        color=color,
        ha="center",
        va="center",
        zorder=3,
    )


def main() -> None:
    fig, ax = plt.subplots(figsize=(13.2, 5.8))
    fig.patch.set_facecolor(BG)
    ax.set_facecolor(BG)
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 10)
    ax.axis("off")

    # Panel titles -------------------------------------------------------
    ax.text(1.0, 9.3, "Before", fontsize=21, fontweight="bold", color=INK, ha="left")
    ax.text(
        1.0,
        8.75,
        "One contiguous 100 bp read",
        fontsize=13,
        color=MUTED,
        ha="left",
    )
    ax.text(11.0, 9.3, "After", fontsize=21, fontweight="bold", color=INK, ha="left")
    ax.text(
        11.0,
        8.75,
        "The aligner splits the read",
        fontsize=13,
        color=MUTED,
        ha="left",
    )

    # Genome tracks ------------------------------------------------------
    for ox in (0.0, 10.0):
        exon(ax, ox + 1.2, 6.6, 3.0, 0.8, "Exon 1")
        exon(ax, ox + 6.2, 6.6, 3.0, 0.8, "Exon 2")
        ax.plot(
            [ox + 4.2, ox + 6.2],
            [7.0, 7.0],
            color=LINE,
            linewidth=2.2,
            linestyle=(0, (4, 3)),
            zorder=1,
        )
        ax.text(
            ox + 5.2,
            7.45,
            "intron",
            fontsize=11,
            color=MUTED,
            ha="center",
            va="bottom",
        )

    # BEFORE: one continuous read bar ------------------------------------
    read_bar(ax, 1.5, 4.5, 7.4, 0.75, "100 bp")
    ax.plot(
        [1.5, 8.9],
        [4.25, 4.25],
        color=ACCENT,
        linewidth=1.5,
        linestyle=(0, (4, 3)),
        zorder=1,
    )
    badge(ax, 2.45, 2.8, 5.5, 0.8, "× no contiguous match", ACCENT)

    # AFTER: split read --------------------------------------------------
    read_bar(ax, 11.5, 4.5, 2.7, 0.75, "40 bp")
    read_bar(ax, 16.2, 4.5, 2.7, 0.75, "60 bp")
    ax.plot(
        [14.2, 16.2],
        [4.25, 4.25],
        color=LINE,
        linewidth=1.8,
        linestyle=(0, (4, 3)),
        zorder=1,
    )
    ax.text(
        15.2,
        4.12,
        "invented intron",
        fontsize=11,
        color=MUTED,
        ha="center",
        va="top",
    )
    badge(ax, 13.0, 2.8, 4.2, 0.8, "✓ split alignment", EXON_EDGE)

    ax.text(
        10.0,
        1.1,
        "The read is contiguous. The genome is not.",
        fontsize=14,
        color=MUTED,
        ha="center",
        va="center",
    )

    out = Path(__file__).resolve().parents[2] / "_assets" / "splicing_before_after.png"
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
