#!/usr/bin/env Rscript
# dots_lines.png — the same 5 numbers drawn two ways: dots, then dots joined
# by a line. Used on the "Dots and lines" slide, left column.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/dots_lines.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# ggplot2 4.0 does not join two plots on `+`; patchwork does
library(patchwork)

# the same five spots in both panels
d <- data.frame(spot = 1:5, umi = c(2, 4, 6, 8, 10))

breaks_x <- 1:5
limits_x <- c(0.4, 5.6)
breaks_y <- c(2, 4, 6, 8, 10)
limits_y <- c(0.5, 11.5)

p_dots <- ggplot(d, aes(x = spot, y = umi)) +
  plot_base("dots", breaks_x, limits_x, breaks_y, limits_y) +
  geom_point(size = dot_size, colour = accent, fill = accent)

p_line <- ggplot(d, aes(x = spot, y = umi)) +
  plot_base("dots + line", breaks_x, limits_x, breaks_y, limits_y) +
  geom_line(colour = gold, linewidth = 1) +
  geom_point(size = dot_size, colour = accent, fill = accent)

ggsave(file.path(assets_dir(), "dots_lines.png"), p_dots + p_line,
       width = fig_w, height = fig_h, dpi = fig_dpi, bg = bg)
cat("wrote", file.path(assets_dir(), "dots_lines.png"), "\n")
