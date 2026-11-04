#!/usr/bin/env Rscript
# range.png — the same base as variance.png and sd.png: the seven spot dots on the
# same x geometry, so they sit in exactly the same places on the page.
#
# The range is smallest to largest: the two gold lines at the smallest count and at
# the largest count, and the gap between them is the range. No mean bar — at this
# point in the deck the mean has not been defined yet, so nothing is measured from
# it.
#
# The x span is computed with the same formula as variance.R (the mean is used only
# to make the span, so the dots land at the same x positions in every figure).
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/range.R

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
legend_formula <- TeX(r"($r = x_{max} - x_{min}$)")

# 7 spots (odd n, so the median is a real spot), one Visium sample.
counts7 <- c(1, 2, 4, 6, 8, 20, 40)
spots7  <- seq_along(counts7)   # spot number 1..7
mn      <- min(counts7)         # 1
mx      <- max(counts7)         # 40
m       <- mean(counts7)        # 11.57143, used only for the x span

gap     <- 1
blank   <- 1
y_hi    <- 52
y_lo    <- 0

# the same span as variance.R, so the dots land at the same x positions
px_y   <- panel_h / y_hi                       # px per y unit
maxdev <- max(abs(counts7 - m))
n      <- length(counts7)
span   <- (2 * blank + (n - 1) * gap) / (1 - maxdev * px_y / panel_w)
x_pos  <- (seq_along(counts7) - 1) * gap
x_lo   <- -blank
x_hi   <- 7.2   # hand-set: the right blank is trimmed to the legend's right edge

p_range <- ggplot(data.frame(spot = x_pos, value = counts7),
                  aes(x = spot, y = value)) +
  plot_base("range: smallest to largest",
            x_breaks = x_pos,  x_limits = c(x_lo, x_hi),
            y_breaks = c(0, 10, 20, 30, 40), y_limits = c(y_lo, y_hi)) +
  # the two ends of the range: gold dashed lines at the smallest and the largest count
  annotate("segment", x = x_lo, xend = x_hi, y = mn, yend = mn,
           linetype = "dashed", colour = gold, linewidth = 0.4) +
  annotate("segment", x = x_lo, xend = x_hi, y = mx, yend = mx,
           linetype = "dashed", colour = gold, linewidth = 0.4) +
  annotate("text", x = x_lo + 0.5, y = mn + 1.5, hjust = 0, size = 2.6,
           colour = gold, label = "min = 1") +
  annotate("text", x = x_lo + 0.5, y = mx + 1.5, hjust = 0, size = 2.6,
           colour = gold, label = "max = 40") +
  # the range is the gap between the two lines
  annotate("text", x = x_lo + 0.5, y = 20.5, hjust = 0, size = 2.6,
           colour = gold, label = "range = 39") +
  # legend: the range formula, in a white-framed, transparent box in the right corner
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

save_fig(p_range, "range.png")

cat("x range:", x_lo, "to", x_hi, "\n")
cat("min:", mn, "max:", mx, "range:", mx - mn, "\n")
cat("range(counts):", range(counts7), "\n")
