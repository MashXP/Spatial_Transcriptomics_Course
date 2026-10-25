"""BAM figures for lecture-08 section 4, drawn from the real BAM in
data/_ignore/STAR/sample.Aligned.sortedByCoord.out.bam.

Every number in these figures is measured from the run, not invented:

  record   SRR8836894.3781  99  17  79100  255  110M7018N40M  =  79158  7225
  mate     SRR8836894.3781 147  17  79158  255  52M7018N97M1S =  79100 -7225
  flags    83:315  99:300  147:300  163:315   (1230 primary records, 615 pairs)
  mapq     255:1106  3:48  1:76

Run: ~/.conda/envs/mdd/bin/python lecture-08/scripts/make_bam_figs.py
"""

import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle

INK = "#22272b"
PAPER = "#f5f2ea"
MUTED = "#8a938f"
FADE = "#cbd0d3"
ACCENT = "#b03a56"
TEAL = "#2b7a78"
BLUE = "#3b6ea5"
GOLD = "#8a6d3b"

MONO = "DejaVu Sans Mono"
SANS = "DejaVu Sans"

REC = dict(qname="SRR8836894.3781", flag="99", rname="17", pos="79100",
           mapq="255", cigar="110M7018N40M", rnext="=", pnext="79158",
           tlen="7225", seq="GGCACAATGG…", qual="AAFFFJJFAA…")

KEY = {"flag", "pos", "mapq", "cigar", "pnext", "tlen"}


def new_fig(w, h, xlim=100, ylim=100):
    fig, ax = plt.subplots(figsize=(w, h))
    ax.set_xlim(0, xlim)
    ax.set_ylim(0, ylim)
    ax.axis("off")
    fig.patch.set_facecolor(PAPER)
    ax.set_facecolor(PAPER)
    return fig, ax


def place(ax, x, y, s, size=10, colour=INK, family=MONO, weight="normal",
          ha="left", va="center"):
    ax.text(x, y, s, size=size, color=colour, family=family, weight=weight,
            ha=ha, va=va, zorder=10)


def box(ax, x, y, w, h, colour, lw=1.3, fill="none", radius=0.6):
    ax.add_patch(FancyBboxPatch((x, y), w, h,
                               boxstyle=f"round,pad={radius}",
                               linewidth=lw, edgecolor=colour,
                               facecolor=fill, zorder=6))


def bar(ax, x, y, w, h, colour):
    ax.add_patch(Rectangle((x, y), w, h, facecolor=colour, edgecolor="none",
                           zorder=5))


# ---------------------------------------------------------------- figure 1
def fig_fields():
    """The 11 SAM columns of one real record, with the 5 that matter marked."""
    cols = [("QNAME", "which read", "qname", 13, False),
            ("FLAG", "pair / mate", "flag", 10, True),
            ("RNAME", "chromosome", "rname", 9, True),
            ("POS", "start", "pos", 9, True),
            ("MAPQ", "certainty", "mapq", 10, True),
            ("CIGAR", "shape", "cigar", 14, True),
            ("RNEXT", "mate chr", "rnext", 9, True),
            ("PNEXT", "mate start", "pnext", 9, True),
            ("TLEN", "fragment", "tlen", 10, True),
            ("SEQ", "bases", "seq", 12, False),
            ("QUAL", "quality", "qual", 11, False)]

    fig, ax = new_fig(13.2, 2.4, xlim=112)
    ax.set_ylim(36, 100)
    x = 1.0
    TOP = 74
    for name, ask, key, w, is_key in cols:
        place(ax, x + w / 2, TOP + 16, ask, size=8.4, colour=ACCENT if is_key
              else FADE, family=SANS, ha="center", weight="bold")
        place(ax, x + w / 2, TOP + 8, name, size=8.6,
              colour=INK if is_key else MUTED, family=SANS, ha="center")
        val = REC[key]
        place(ax, x + w / 2, TOP - 4, val, size=9.0,
              colour=INK if is_key else MUTED, weight="bold" if is_key
              else "normal", ha="center")
        box(ax, x, TOP - 11, w, 20, ACCENT if is_key else FADE,
            lw=1.5 if is_key else 1.0, radius=0.5)
        x += w + 1.0

    place(ax, 1, 50, "11 columns, in this order, every alignment line",
          size=11, family=SANS, weight="bold")
    place(ax, 1, 40, "the highlighted ones answer: where, what shape, how sure, "
          "and where the mate is", size=10, family=SANS, colour=MUTED)
    return fig, ax


# ---------------------------------------------------------------- figure 2
def fig_cigar():
    """110M + 7018N + 40M: the read is two exons, the genome skips the middle."""
    fig, ax = new_fig(12.6, 3.4)

    # genome bar: exon1, intron, exon2
    g_y, g_h = 24, 14
    e1_x, e1_w = 4, 15
    intr_x, intr_w = e1_x + e1_w, 62
    e2_x, e2_w = intr_x + intr_w, 8

    bar(ax, e1_x, g_y, e1_w, g_h, TEAL)
    bar(ax, e2_x, g_y, e2_w, g_h, TEAL)
    box(ax, intr_x, g_y, intr_w, g_h, FADE, lw=1.1, radius=0.3)

    place(ax, e1_x + e1_w / 2, g_y + g_h / 2, "exon 1", size=9.5,
          colour="white", family=SANS, weight="bold", ha="center")
    place(ax, e2_x + e2_w / 2, g_y + g_h / 2, "exon 2", size=9.5,
          colour="white", family=SANS, weight="bold", ha="center")
    place(ax, intr_x + intr_w / 2, g_y + g_h / 2, "intron — not in the read",
          size=9.5, colour=MUTED, family=SANS, ha="center")

    # read: two segments above the genome, joined by a dashed arc
    r_y, r_h = 52, 12
    bar(ax, e1_x, r_y, e1_w, r_h, GOLD)
    bar(ax, e2_x, r_y, e2_w, r_h, GOLD)
    ax.plot([e1_x + e1_w, e2_x], [r_y + r_h + 2, r_y + r_h + 2],
            color=ACCENT, lw=1.6, ls=(0, (4, 3)), zorder=8)
    for xx in (e1_x + e1_w, e2_x):
        ax.plot([xx, xx], [r_y, r_y + r_h + 2], color=ACCENT, lw=1.1,
                ls=(0, (3, 2)), zorder=8)

    place(ax, e1_x + e1_w / 2, r_y + r_h + 8, "110M", size=11, colour=INK,
          family=MONO, weight="bold", ha="center")
    place(ax, intr_x + intr_w / 2, r_y + r_h + 8, "7018N", size=11,
          colour=ACCENT, family=MONO, weight="bold", ha="center")
    place(ax, e2_x + e2_w / 2, r_y + r_h + 8, "40M", size=11, colour=INK,
          family=MONO, weight="bold", ha="center")

    place(ax, e1_x, 10, "the read is 150 bp: 110 + 40 aligned, 0 bases lost",
          size=10.5, family=SANS, weight="bold")
    place(ax, e1_x, 2, "7,018 bp of genome are skipped between the two blocks — "
          "that is the intron", size=10, family=SANS, colour=MUTED)
    place(ax, e1_x, 17, "17:79100", size=9.5, colour=MUTED, family=MONO)
    place(ax, e2_x + e2_w, 17, "17:86158", size=9.5, colour=MUTED,
          family=MONO, ha="right")
    return fig, ax


# ---------------------------------------------------------------- figure 3
def fig_flag():
    """FLAG as bits: 99 and 147, the two flags our BAM is made of."""
    fig, ax = new_fig(12.4, 3.6)
    ax.set_ylim(0, 104)
    bits = [1, 2, 4, 8, 16, 32, 64, 128]
    flags = [(83, 315, "first in pair, reverse, mate forward"),
             (99, 300, "first in pair, forward, mate reverse"),
             (147, 300, "second in pair, reverse, mate forward"),
             (163, 315, "second in pair, forward, mate reverse")]

    for flag, count, meaning in flags:
        y = 85 - flags.index((flag, count, meaning)) * 24
        place(ax, 1, y + 17, f"FLAG {flag}", size=11.5, colour=ACCENT,
              family=MONO, weight="bold")
        place(ax, 24, y + 17, f"{count} records", size=9.5, colour=MUTED,
              family=SANS)
        x = 1.0
        for b in bits:
            lit = flag & b
            box(ax, x, y, 10.5, 13, ACCENT if lit else FADE,
                lw=1.6 if lit else 1.0, radius=0.5,
                fill="#b03a56" if lit else "none")
            place(ax, x + 5.25, y + 9.5, str(lit), size=9,
                  colour="white" if lit else MUTED, family=MONO, ha="center",
                  weight="bold" if lit else "normal")
            place(ax, x + 5.25, y + 4, str(b), size=8.4,
                  colour="white" if lit else MUTED, family=MONO, ha="center")
            x += 11.5
        place(ax, x + 1, y + 6.5, f"= {meaning}", size=9.5, colour=INK,
              family=SANS)

    place(ax, 1, 3, "the whole BAM: four primary flags, 615 pairs",
          size=11, family=SANS, weight="bold")
    return fig, ax


# ---------------------------------------------------------------- figure 4
def fig_mapq():
    """MAPQ from the real BAM: 1106 unique, 124 multi-mapping."""
    fig, ax = new_fig(9.4, 2.6)
    rows = [("255", 1106, "unique: one place in the genome", ACCENT),
            ("3", 48, "fits in several places", GOLD),
            ("1", 76, "fits in several places", GOLD)]
    top = 76
    h = 14
    pitch = 26
    maxw = 62
    for i, (mapq, n, label, colour) in enumerate(rows):
        y = top - i * pitch
        w = maxw * n / 1106
        place(ax, 1, y + h / 2, mapq, size=12, colour=colour, family=MONO,
              weight="bold")
        bar(ax, 12, y, w, h, colour)
        place(ax, 12 + w + 2, y + h / 2, f"{n} records", size=9.5,
              colour=INK, family=SANS, weight="bold")
        place(ax, 12, y + h + 2.5, label, size=9, colour=MUTED, family=SANS)

    place(ax, 12, 5, "1230 primary records: 90% unique, 10% multi-mapping",
          size=10.5, family=SANS, weight="bold")
    return fig, ax


_here = os.path.dirname(os.path.abspath(__file__))
_assets = os.path.abspath(os.path.join(_here, "..", "..", "_assets"))
for f, name in ((fig_fields(), "bam_fields.png"),
               (fig_cigar(), "bam_cigar.png"),
               (fig_flag(), "bam_flag.png"),
               (fig_mapq(), "bam_mapq.png")):
    fig, _ = f
    out = os.path.join(_assets, name)
    fig.savefig(out, facecolor=PAPER, dpi=200, bbox_inches="tight",
                pad_inches=0.2)
    print(f"wrote {out}")
