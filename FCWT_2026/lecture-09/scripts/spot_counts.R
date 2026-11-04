#!/usr/bin/env Rscript
# spot_counts.png — the data on its own, nothing computed. One dot per spot,
# x = spot number, y = spot value (UMI). Used on the "The problem" slide,
# left column.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/spot_counts.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# 7 spots (odd n, so the median is a real spot), one Visium sample.
counts7 <- c(1, 2, 4, 6, 8, 20, 40)
spots7  <- seq_along(counts7)   # spot number 1..7

p_counts <- ggplot(data.frame(spot = spots7, value = counts7),
                   aes(x = spot, y = value)) +
  plot_base("7 spot counts, one Visium sample",
            x_breaks = 1:7,  x_limits = c(0.3, 7.7),
            y_breaks = c(0, 10, 20, 30, 40), y_limits = c(0, 46)) +
  geom_point(size = dot_size, colour = text, fill = text)

save_fig(p_counts, "spot_counts.png")
