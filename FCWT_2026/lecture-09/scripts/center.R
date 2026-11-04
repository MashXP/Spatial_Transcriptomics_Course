#!/usr/bin/env Rscript
# center.png — the mean and the median as full-width horizontal bars across the
# spots, so the vertical distance of each spot from a bar is readable.
# Same axes, grid, canvas and dots as spot_counts.R; only the two bars and their
# labels are added. x = spot number, y = spot value (UMI). Used on the "Center" slide.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/center.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# 7 spots (odd n, so the median is a real spot), one Visium sample.
counts7 <- c(1, 2, 4, 6, 8, 20, 40)
spots7  <- seq_along(counts7)   # spot number 1..7
m       <- mean(counts7)        # 11.57143
med     <- median(counts7)      # 6

x_lo <- 0.3
x_hi <- 7.7

p_center <- ggplot(data.frame(spot = spots7, value = counts7),
                   aes(x = spot, y = value)) +
  plot_base("Center: mean and median as horizontal bars",
            x_breaks = 1:7,  x_limits = c(x_lo, x_hi),
            y_breaks = c(0, 10, 20, 30, 40), y_limits = c(0, 46)) +
  # the median bar: solid gold, the mean bar: dashed pink
  annotate("segment", x = x_lo, xend = x_hi, y = med, yend = med,
           colour = gold, linewidth = 0.6) +
  annotate("segment", x = x_lo, xend = x_hi, y = m, yend = m,
           linetype = "dashed", colour = accent, linewidth = 0.6) +
  geom_point(size = dot_size, colour = text, fill = text) +
  # labels anchored at the left edge, in the empty band above each bar: the dots
  # climb to the right, so the left side of the panel is where text can sit clear
  annotate("text", x = x_lo + 0.06, y = med + 2.4, hjust = 0, size = 3.2,
           fontface = "plain", colour = gold,   label = "median = 6") +
  annotate("text", x = x_lo + 0.06, y = m + 2.4, hjust = 0, size = 3.2,
           fontface = "plain", colour = accent, label = "mean = 11.57")

save_fig(p_center, "center.png")

cat("mean:", round(m, 5), "median:", med, "mean - median:", round(m - med, 5), "\n")
