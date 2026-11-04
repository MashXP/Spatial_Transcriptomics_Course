#!/usr/bin/env Rscript
# sd.png — the same base as variance.png: spot dots, the mean bar, one vertical
# per spot from the point down (or up) to the mean.
#
# variance drew a SQUARE on every vertical, so its number was an AREA. sd is a
# LENGTH, so it is drawn as one length: the gold arrow from the mean bar up by
# sd, and the gold band mean - sd to mean + sd. The distances are printed on the
# verticals; the arrow's number is the square root of their squared mean.
#
# x geometry is identical to variance.R (same gap, blank, y_hi, same span
# formula), so the dots sit in the same places on the page.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/sd.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# panel geometry measured from the canvas, in pixels
panel_w <- 960
panel_h <- 460

# the legend formula, rendered in R by latex2exp: TeX() turns a LaTeX string into
# a plotmath expression, which annotation_custom() draws directly.
library(latex2exp)
legend_formula <- TeX(r"($s = \sqrt{\frac{1}{n-1}\sum_{i=1}^{n}(x_i - \bar{x})^2}$)")

# 7 spots (odd n, so the median is a real spot), one Visium sample.
counts7 <- c(1, 2, 4, 6, 8, 20, 40)
spots7  <- seq_along(counts7)   # spot number 1..7
m       <- mean(counts7)        # 11.57143
s       <- sd(counts7)          # 14.04584

gap     <- 1
blank   <- 1
y_hi    <- 52
y_lo    <- -3   # mean - sd = -2.4744, so the lower sd line needs room below zero

# the same span as variance.R: the x range that makes the widest square square
px_y   <- panel_h / y_hi                       # px per y unit
maxdev <- max(abs(counts7 - m))
n      <- length(counts7)
span   <- (2 * blank + (n - 1) * gap) / (1 - maxdev * px_y / panel_w)
x_pos  <- (seq_along(counts7) - 1) * gap
x_lo   <- -blank
x_hi   <- -blank + span

p_sd <- ggplot(data.frame(spot = x_pos, value = counts7),
               aes(x = spot, y = value)) +
  plot_base("sd: the average distance, back in UMI",
            x_breaks = x_pos,  x_limits = c(x_lo, x_hi),
            y_breaks = c(0, 10, 20, 30, 40), y_limits = c(y_lo, y_hi)) +
  # the sd band: the two sd lines, mean - sd to mean + sd
  annotate("rect", xmin = x_lo, xmax = x_hi, ymin = m - s, ymax = m + s,
           fill = alpha(gold, 0.10), colour = NA) +
  annotate("segment", x = x_lo, xend = x_hi, y = m + s, yend = m + s,
           linetype = "dashed", colour = gold, linewidth = 0.4) +
  annotate("segment", x = x_lo, xend = x_hi, y = m - s, yend = m - s,
           linetype = "dashed", colour = gold, linewidth = 0.4) +
  annotate("text", x = x_hi - 0.1, y = m + s + 1.4, hjust = 1, size = 2.0,
           colour = gold, label = "mean + sd = 25.617") +
  annotate("text", x = x_hi - 0.1, y = m - s + 1.4, hjust = 1, size = 2.0,
           colour = gold, label = "mean - sd = -2.474") +
  # the mean bar: thin dashed pink, with small text
  annotate("segment", x = x_lo, xend = x_hi, y = m, yend = m,
           linetype = "dashed", colour = accent, linewidth = 0.4) +
  annotate("text", x = x_lo + 0.5, y = m + 3.0, hjust = 0, size = 2.6,
           colour = accent, label = "mean = 11.57143") +
  # legend: the sd formula, in a white-framed, transparent box in the right corner
  annotation_custom(
    grob = grid::gTree(children = grid::gList(
      grid::rectGrob(x = 0.5, y = 0.5, width = grid::unit(1, "npc"), height = grid::unit(1, "npc"),
                     gp = grid::gpar(col = "white", fill = "transparent", linewidth = 0.5)),
      grid::textGrob(legend_formula, x = 0.5, y = 0.5,
                     gp = grid::gpar(col = "white", fontsize = 8, fontfamily = "Latin Modern Math"))
    )),
    xmin = 7, xmax = x_hi, ymin = 43, ymax = 52
  ) +
  # lines connecting each point to the mean line, under the dots
  geom_segment(aes(x = x_pos, xend = x_pos, y = counts7, yend = m),
               inherit.aes = FALSE, colour = accent, linewidth = 0.4) +
  # the length of each vertical: how far that spot sits from the mean bar
  annotate("text", x = x_pos + 0.22, y = (counts7 + m) / 2, hjust = 0, size = 2.0,
           colour = accent, label = sprintf("%.1f", abs(counts7 - m))) +
  # sd as ONE length: the gold label between the two sd lines, in the left blank
  annotate("text", x = -0.85, y = m + s + 1.8, hjust = 0, size = 2.6,
           colour = gold, label = "sd = 14.04584") +
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

save_fig(p_sd, "sd.png")

cat("x range:", x_lo, "to", x_hi, "\n")
cat("mean:", m, "sd:", s, "band:", m - s, "to", m + s, "\n")
cat("distances:", round(abs(counts7 - m), 3), "\n")
cat("sum of squares:", sum((counts7 - m)^2), "variance:", var(counts7), "\n")
