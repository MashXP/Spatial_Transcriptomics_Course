#!/usr/bin/env Rscript
# quartiles.png — the same base as range.png and iqr.png: the seven spot dots on the
# same geometry.
#
# The quartiles as Tukey's hinges: the gold line is the median of all seven spots (6),
# and the median belongs to BOTH halves. The lower half is 1, 2, 4, 6, the upper half
# is 6, 8, 20, 40. The pink line is the median of the lower half (Q1 = 3), the cyan
# line is the median of the upper half (Q3 = 14). These are the values R's quantile()
# default, fivenum() and boxplot() all give for these counts.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/quartiles.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# panel geometry measured from the canvas, in pixels
panel_w <- 540
panel_h <- 460

# hand-set canvas width for this figure: narrower than the deck standard (5.6 in),
# so the right side is squeezed
fig_w <- 4.2

# the quartile lines use the deck's three colours: gold for the median, pink for the
# lower half's median, cyan for the upper half's median
cyan <- "#00FFFF"

# 7 spots (odd n, so the median is a real spot), one Visium sample.
counts7 <- c(1, 2, 4, 6, 8, 20, 40)
spots7  <- seq_along(counts7)   # spot number 1..7
sorted7 <- sort(counts7)
med     <- median(sorted7)      # 6, the cut, kept in both halves
q1      <- median(sorted7[1:4]) # lower half: 1, 2, 4, 6  -> 3
q3      <- median(sorted7[4:7]) # upper half: 6, 8, 20, 40 -> 14

gap     <- 1
blank   <- 1
y_hi    <- 52
y_lo    <- 0

x_pos  <- (seq_along(counts7) - 1) * gap
x_lo   <- -blank
x_hi   <- 7.2   # hand-set: the right blank is trimmed to the legend's right edge

p_quart <- ggplot(data.frame(spot = x_pos, value = counts7),
                  aes(x = spot, y = value)) +
  plot_base("quartiles: the median of each half",
            x_breaks = x_pos,  x_limits = c(x_lo, x_hi),
            y_breaks = c(0, 10, 20, 30, 40), y_limits = c(y_lo, y_hi)) +
  # the median: gold solid line, the cut between the two halves
  annotate("segment", x = x_lo, xend = x_hi, y = med, yend = med,
           colour = gold, linewidth = 0.6) +
  # the lower half's median (Q1) and the upper half's median (Q3)
  annotate("segment", x = x_lo, xend = x_hi, y = q1, yend = q1,
           linetype = "dashed", colour = accent, linewidth = 0.4) +
  annotate("segment", x = x_lo, xend = x_hi, y = q3, yend = q3,
           linetype = "dashed", colour = cyan, linewidth = 0.4) +
  # labels in the empty bands: the dots climb to the right, so text sits on the left
  annotate("text", x = x_lo + 0.5, y = q1 + 1.5, hjust = 0, size = 2.6,
           colour = accent, label = "Q1 = 3") +
  annotate("text", x = 1.6, y = med + 1.5, hjust = 0, size = 2.6,
           colour = gold, label = "median = 6") +
  annotate("text", x = x_lo + 0.5, y = q3 + 1.5, hjust = 0, size = 2.6,
           colour = cyan, label = "Q3 = 14") +
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

save_fig(p_quart, "quartiles.png")

cat("sorted:", sorted7, "\n")
cat("median:", med, "Q1:", q1, "Q3:", q3, "IQR (halves):", q3 - q1, "\n")
