#!/usr/bin/env Rscript
# iqr.png — the same base as range.png: the seven spot dots on the same geometry.
#
# The IQR is the middle 50%: the two gold lines at Q1 and at Q3, and the gap between
# them is the interquartile range. No mean bar — the mean is not defined yet at this
# point in the deck.
#
# Q1 = 3, Q3 = 14 (R's default quantile type 7), so IQR = 14 - 3 = 11.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/iqr.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# panel geometry measured from the canvas, in pixels
panel_w <- 540
panel_h <- 460

# hand-set canvas width for this figure: narrower than the deck standard (5.6 in),
# so the right side is squeezed
fig_w <- 4.2

# the legend formula, rendered in R by latex2exp: TeX() turns a LaTeX string into
# a plotmath expression, which annotation_custom() draws directly.
library(latex2exp)
legend_formula <- TeX(r"($iq = Q_{3} - Q_{1}$)")

# the middle 50% band and its number are drawn in cyan, so Q1 (pink), Q3 (gold) and
# the IQR itself read as three different things
cyan <- "#00FFFF"

# 7 spots (odd n, so the median is a real spot), one Visium sample.
counts7 <- c(1, 2, 4, 6, 8, 20, 40)
spots7  <- seq_along(counts7)   # spot number 1..7
q1      <- as.numeric(quantile(counts7, 0.25))   # 3
q3      <- as.numeric(quantile(counts7, 0.75))   # 14
iq      <- q3 - q1                              # 11

gap     <- 1
blank   <- 1
y_hi    <- 52
y_lo    <- 0

x_pos  <- (seq_along(counts7) - 1) * gap
x_lo   <- -blank
x_hi   <- 7.2   # hand-set: the right blank is trimmed to the legend's right edge

p_iqr <- ggplot(data.frame(spot = x_pos, value = counts7),
                aes(x = spot, y = value)) +
  plot_base("iqr: the middle half, extremes ignored",
            x_breaks = x_pos,  x_limits = c(x_lo, x_hi),
            y_breaks = c(0, 10, 20, 30, 40), y_limits = c(y_lo, y_hi)) +
  # the middle 50% is the region between Q1 and Q3: shaded in cyan
  annotate("rect", xmin = x_lo, xmax = x_hi, ymin = q1, ymax = q3,
           fill = alpha(cyan, 0.16), colour = NA) +
  # the two ends of the middle 50%: pink dashed line at Q1, gold dashed line at Q3
  annotate("segment", x = x_lo, xend = x_hi, y = q1, yend = q1,
           linetype = "dashed", colour = accent, linewidth = 0.4) +
  annotate("segment", x = x_lo, xend = x_hi, y = q3, yend = q3,
           linetype = "dashed", colour = gold, linewidth = 0.4) +
  annotate("text", x = x_lo + 0.5, y = q1 + 1.5, hjust = 0, size = 2.6,
           colour = accent, label = "Q1 = 3") +
  annotate("text", x = x_lo + 0.5, y = q3 + 1.5, hjust = 0, size = 2.6,
           colour = gold, label = "Q3 = 14") +
  # the IQR is the gap between the two lines: cyan, inside the shaded band
  annotate("text", x = 3.4, y = (q1 + q3) / 2, hjust = 0.5, size = 2.6,
           colour = cyan, label = "IQR = 11") +
  # legend: the IQR formula, in a white-framed, transparent box in the right corner
  annotation_custom(
    grob = grid::gTree(children = grid::gList(
      grid::rectGrob(x = 0.5, y = 0.5, width = grid::unit(1, "npc"), height = grid::unit(1, "npc"),
                     gp = grid::gpar(col = "white", fill = "transparent", linewidth = 0.5)),
      grid::textGrob(legend_formula, x = 0.5, y = 0.5,
                     gp = grid::gpar(col = "white", fontsize = 8, fontfamily = "Latin Modern Math"))
    )),
    xmin = 4.9, xmax = 7.2, ymin = 43, ymax = 50
  ) +
  geom_point(size = 2, colour = text, fill = text) +
  # the spot numbers label the grid: 1..7 under the positions
  scale_x_continuous(breaks = x_pos, labels = spots7, limits = c(x_lo, x_hi),
                     expand = expansion(mult = c(0.02, 0.02))) +
  # every element drawn small, so the space between the spot numbers reads wide
  theme(
    plot.title   = element_text(size = 10),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6)
  )

save_fig(p_iqr, "iqr.png")

cat("Q1:", q1, "Q3:", q3, "IQR:", iq, "\n")
cat("quantile(counts, 0.25):", quantile(counts7, 0.25), "\n")
cat("quantile(counts, 0.75):", quantile(counts7, 0.75), "\n")
cat("IQR(counts):", IQR(counts7), "\n")
