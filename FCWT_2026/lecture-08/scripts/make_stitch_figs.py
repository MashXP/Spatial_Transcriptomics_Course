"""Stitch diagrams for lecture-08.

The splice figure is drawn from a real record in our own STAR output:
SRR8836894.3781 -> 110M7018N40M on chr17, 79100..86158.
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

INK = "#242424"
ACCENT = "#b03a56"
GOLD = "#8a6d33"
TEAL = "#2e7d74"
MUTED = "#7a7a72"
FADE = "#c9c9c2"
SANS = "Verdana"
MONO = "DejaVu Sans Mono"
PAPER = "#f2efe6"


def new_fig(w, h, xlim=100):
    fig, ax = plt.subplots(figsize=(w, h), facecolor=PAPER)
    ax.set_xlim(0, xlim)
    ax.set_ylim(0, 100)
    ax.axis("off")
    fig.patch.set_alpha(0)
    return fig, ax


def box(ax, x, y, w, h, colour, lw=1.4, radius=0.8, fill="none"):
    ax.add_patch(FancyBboxPatch((x, y), w, h,
                                boxstyle=f"round,pad=0,rounding_size={radius}",
                                linewidth=lw, edgecolor=colour, facecolor=fill))


def bar(ax, x, y, w, h, colour):
    ax.add_patch(FancyBboxPatch((x, y), w, h,
                                boxstyle="square,pad=0", linewidth=0,
                                facecolor=colour))


def place(ax, x, y, s, size=10, colour=INK, family=SANS, ha="left",
          weight="normal"):
    ax.text(x, y, s, fontsize=size, color=colour, family=family,
            ha=ha, va="center", fontweight=weight)


# --------------------------------------------------------------------------
# figure 1: the read, the genome, and the intron the genome skips
# real record: 110M 7018N 40M, chr17: exon1 79100-79209, exon2 86228-86267
fig1, ax = new_fig(11.6, 2.9)
ax.set_ylim(0, 100)

R_Y, R_H = 66, 14
G_Y, G_H = 36, 14

# read: 110 aligned + 40 aligned, drawn as one 150 bp bar
bar(ax, 8, R_Y, 22, R_H, TEAL)
bar(ax, 70, R_Y, 8, R_H, TEAL)
place(ax, 19, R_Y + R_H + 5, "110M", size=11, colour=INK, family=MONO,
      ha="center", weight="bold")
place(ax, 74, R_Y + R_H + 5, "40M", size=11, colour=INK, family=MONO,
      ha="center", weight="bold")

# genome: exon 1, intron, exon 2  (not to scale; the intron is far longer)
bar(ax, 8, G_Y, 22, G_H, GOLD)
bar(ax, 70, G_Y, 8, G_H, GOLD)
place(ax, 19, G_Y + G_H / 2, "exon 1", size=10, colour="white", ha="center",
      weight="bold")
place(ax, 74, G_Y + G_H / 2, "exon 2", size=10, colour="white", ha="center",
      weight="bold")
place(ax, 8, G_Y - 6, "17:79100", size=9, colour=MUTED, family=MONO)
place(ax, 70, G_Y - 6, "17:86228", size=9, colour=MUTED, family=MONO,
      ha="center")

# the intron gap, drawn as a dashed bracket between the exons
ax.plot([30, 70], [G_Y + G_H, G_Y + G_H], color=ACCENT, lw=1.6, ls="--")
place(ax, 50, G_Y + G_H + 6, "7018N", size=11, colour=ACCENT, family=MONO,
      ha="center", weight="bold")

# the read is continuous: base 110 joins base 111 across the intron
ax.add_patch(FancyArrowPatch((30, R_Y + R_H / 2), (70, R_Y + R_H / 2),
                             connectionstyle="arc3,rad=-0.22",
                             arrowstyle="-", lw=1.4, color=ACCENT, ls="--"))
place(ax, 50, 96, "the read is one piece: base 110 joins base 111",
      size=10, colour=ACCENT, ha="center", weight="bold")
place(ax, 50, 16, "the read: 150 bp. The genome skips 7,018 bp; "
      "the read loses nothing", size=10.5, colour=INK, weight="bold",
      ha="center")
place(ax, 50, 8, "not to scale: the intron is 47x longer than the whole read",
      size=9.5, colour=MUTED, ha="center")
fig1.savefig("_assets/stitch_cigar.png", dpi=200, facecolor=PAPER,
            bbox_inches="tight", transparent=True)

# --------------------------------------------------------------------------
# figure 2: annotated junction vs novel junction
fig2, ax = new_fig(11.6, 3.0)
ax.set_ylim(0, 100)

E_Y, E_H = 42, 15
exons = [(4, 20, "exon 1"), (34, 20, "exon 2"), (66, 20, "exon 3")]
for x, w, name in exons:
    bar(ax, x, E_Y, w, E_H, GOLD)
    place(ax, x + w / 2, E_Y + E_H / 2, name, size=10, colour="white",
          ha="center", weight="bold")

# annotated junction: exon1 -> exon2
ax.plot([24, 34], [E_Y + E_H, E_Y + E_H], color=ACCENT, lw=1.6, ls="--")
bar(ax, 18, E_Y + E_H + 3, 6, 4, TEAL)
bar(ax, 34, E_Y + E_H + 3, 6, 4, TEAL)
place(ax, 29, E_Y + E_H + 13, "annotated", size=11, colour=TEAL, ha="center",
      weight="bold")
place(ax, 29, E_Y + E_H + 24, "in the GTF, baked into the index", size=9.5,
      colour=MUTED, ha="center")
place(ax, 21, E_Y + E_H + 9, "149 bp", size=8.5, colour=TEAL, ha="center")
place(ax, 37, E_Y + E_H + 9, "149 bp", size=8.5, colour=TEAL, ha="center")

# novel junction: exon2 -> exon3
ax.plot([54, 66], [E_Y + E_H, E_Y + E_H], color=ACCENT, lw=1.6, ls="--")
bar(ax, 49, E_Y + E_H + 3, 4, 4, GOLD)
bar(ax, 63, E_Y + E_H + 3, 4, 4, GOLD)
place(ax, 59, E_Y + E_H + 13, "novel", size=11, colour=GOLD, ha="center",
      weight="bold")
place(ax, 59, E_Y + E_H + 24, "found by the reads, must earn its place",
      size=9.5, colour=MUTED, ha="center")
place(ax, 51, E_Y + E_H + 9, "8 bp", size=8.5, colour=GOLD, ha="center")
place(ax, 65, E_Y + E_H + 9, "8 bp", size=8.5, colour=GOLD, ha="center")

place(ax, 24, 24, "--sjdbOverhang 149", size=10.5, colour=TEAL, weight="bold",
      ha="center", family=MONO)
place(ax, 24, 15, "read length - 1, flanking every known junction", size=9,
      colour=MUTED, ha="center")
place(ax, 64, 24, "--alignSJoverhangMin 8", size=10.5, colour=GOLD,
      weight="bold", ha="center", family=MONO)
place(ax, 64, 15, "8 bp on each side to count a new junction", size=9,
      colour=MUTED, ha="center")
fig2.savefig("_assets/stitch_junctions.png", dpi=200, facecolor=PAPER,
            bbox_inches="tight", pad=0.12, transparent=True)

# --------------------------------------------------------------------------
# figure 3: which flag tunes which step
fig3, ax = new_fig(11.8, 2.5, xlim=112)
ax.set_ylim(0, 100)

steps = [("Index", TEAL, [("SAindexNbases 12", 1), ("SAsparseD 1", 1),
                          ("sjdbGTFfile", 1), ("sjdbOverhang 149", 1)]),
         ("Seed", GOLD, [("seedMultimapNmax 10000", 0),
                         ("seedPerReadNmax 1000", 0),
                         ("seedPerWindowNmax 50", 0)]),
         ("Extend", GOLD, [("alignIntronMin 21", 0),
                           ("SJoverhangMin 8 (was 5)", 1),
                           ("SJDBoverhangMin 1 (was 3)", 1)]),
         ("Stitch", ACCENT, [("MultimapNmax 20", 1),
                             ("outFilterType BySJout", 1),
                             ("outSAMtype BAM sorted", 1)])]

x = 1.0
for name, colour, flags in steps:
    w = 25.0
    box(ax, x, 80, w, 16, colour, lw=1.6)
    place(ax, x + w / 2, 88, name, size=11.5, colour=colour,
          ha="center", weight="bold")
    for i, (f, ours) in enumerate(flags):
        fy = 68 - i * 13
        box(ax, x, fy, w, 11, ACCENT if ours else FADE, lw=1.4 if ours else 1.0,
            radius=0.4)
        place(ax, x + 1, fy + 5.5, f, size=7.5, colour=INK, family=MONO)
    x += w + 1.0

place(ax, 1, 14, "each step has knobs. Red boxes are the values we set;",
      size=10.5, colour=INK, weight="bold")
place(ax, 1, 6, "grey boxes are STAR's own defaults, left alone.", size=9.5,
      colour=MUTED)
fig3.savefig("_assets/flags_map.png", dpi=200, facecolor=PAPER,
             bbox_inches="tight", pad=0.12, transparent=True)
