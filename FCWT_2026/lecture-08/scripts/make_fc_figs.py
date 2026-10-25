"""Section 6 figures: featureCounts assignment and strandedness.

Every number is measured from data/_ignore/featureCounts/*.summary, produced by
featureCounts v2.1.1 on data/_ignore/STAR/sample.Aligned.sortedByCoord.out.bam
against data/gtf/Homo_sapiens.GRCh38.sub.gtf.
"""

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

CREAM = "#f8f4ea"
INK = "#2d2b28"
MUTED = "#8f8a80"
BERRY = "#b03a56"
GOLD = "#d88a2b"

plt.rcParams.update({
    "font.family": "DejaVu Sans",
    "font.size": 13,
    "figure.facecolor": CREAM,
    "savefig.facecolor": CREAM,
})

# ---------------------------------------------------------------- assignment
ASSIGNED, MULTI, AMBIG, NOFEAT = 448, 183, 74, 31
TOTAL = 736

rows = [
    ("Assigned", ASSIGNED, BERRY, "overlaps exactly one gene_id"),
    ("Unassigned_MultiMapping", MULTI, GOLD, "more than one alignment in the BAM"),
    ("Unassigned_Ambiguity", AMBIG, GOLD, "overlaps more than one gene"),
    ("Unassigned_NoFeatures", NOFEAT, MUTED, "overlaps no exon"),
    ("Unassigned_MappingQuality", 0, MUTED, "below -q; STAR's lowest here is 1"),
    ("every other row", 0, MUTED, "read type, singleton, duplicate, secondary"),
]

NOTE_X = 520  # notes start past the longest bar (448)

fig, ax = plt.subplots(figsize=(12.2, 4.2))
ax.set_facecolor(CREAM)
y = np.arange(len(rows))[::-1]
for yi, (label, n, colour, note) in zip(y, rows):
    ax.barh(yi, n, height=0.62, color=colour, edgecolor="none")
    ax.text(-10, yi, label, ha="right", va="center", fontsize=12, color=INK)
    ax.text(n + 12, yi, f"{n}", ha="left", va="center", fontsize=12,
            color=INK, weight="bold")
    ax.text(NOTE_X, yi, note, ha="left", va="center", fontsize=10, color=MUTED)

ax.axvline(0, color=MUTED, lw=1.2)
ax.set_xlim(-180, 940)
ax.set_ylim(-0.6, len(rows) - 0.4)
ax.axis("off")

fig.text(0.5, 0.97,
         f"featureCounts v2.1.1, `-p --countReadPairs`: {TOTAL} fragments read, "
         f"{ASSIGNED} assigned ({ASSIGNED / TOTAL:.1%})",
         ha="center", va="top", fontsize=10, color=MUTED, style="italic")
fig.text(0.5, 0.03,
         f"{ASSIGNED} assigned + {MULTI} + {AMBIG} + {NOFEAT} = {TOTAL} — "
         "every fragment is named, none is silently dropped",
         ha="center", va="bottom", fontsize=10, color=MUTED, style="italic")
fig.savefig("../_assets/fc_summary.png", dpi=200, bbox_inches="tight")
plt.close(fig)

# ---------------------------------------------------------------- strandedness
STRAT = [("0 — unstranded", 448, BERRY), ("1 — forward", 270, GOLD),
         ("2 — reverse", 267, GOLD)]

fig, ax = plt.subplots(figsize=(11.2, 3.6))
ax.set_facecolor(CREAM)
x = np.arange(len(STRAT))
for xi, (label, n, colour) in zip(x, STRAT):
    ax.bar(xi, n, width=0.46, color=colour, edgecolor="none")
    ax.text(xi, n + 12, f"{n}", ha="center", va="bottom", fontsize=15,
            color=INK, weight="bold")
    ax.text(xi, -25, label, ha="center", va="top", fontsize=12, color=INK)

ax.plot([0.23, 0.77], [448, 270], color=MUTED, lw=1.0, ls="--")
ax.text(0.5, 366, "-178 (40%)", ha="center", va="bottom", fontsize=11,
        color=BERRY, weight="bold")
ax.text(1.5, 300, "-3", ha="center", va="bottom", fontsize=11, color=MUTED)

ax.set_xlim(-0.55, 2.55)
ax.set_ylim(-110, 560)
ax.set_yticks([])
ax.set_xticks([])
for spine in ax.spines.values():
    spine.set_visible(False)

fig.text(0.5, 0.97, "same BAM, same GTF, same flags; only `-s` changed",
         ha="center", va="top", fontsize=10, color=MUTED, style="italic")
fig.text(0.5, 0.03,
         "the simulated library is unstranded; forcing `-s 1` drops 178 pairs",
         ha="center", va="bottom", fontsize=10, color=MUTED, style="italic")
fig.savefig("../_assets/fc_stranded.png", dpi=200, bbox_inches="tight")
plt.close(fig)

print("done")
