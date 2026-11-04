#!/usr/bin/env Rscript
# shape_left.png — tumor3's eleven spot counts plotted by value (x) and spot
# index (y), with the smoothed density curve over the dots. The curve piles up at
# the high end and keeps a long tail running to the left: the left-skewed shape.
# The gold line is the mean (6), the cyan dashed line is the median (8) — the mean
# sits to the left of the median because the tail drags it.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/shape_left.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# the median line is cyan, the same colour the quartile figures use for Q3
cyan <- "#00FFFF"

# tumor3: one high spot, ten spots below it
tumor3 <- c(1, 2, 3, 5, 7, 8, 8, 8, 8, 8, 8)
spots  <- seq_along(tumor3)   # spot number 1..11
mn     <- mean(tumor3)        # 6
med    <- median(tumor3)      # 8

# hand-set canvas: x is the count value, y is the spot index
x_lo <- 0
x_hi <- 13
y_lo <- 0
y_hi <- 12.5

# the density curve is scaled by hand so its peak sits at the top of the spot rows
d   <- density(tumor3)
cur <- data.frame(x = d$x, y = d$y * 69)

p_left <- ggplot(data.frame(value = tumor3, spot = spots),
                 aes(x = value, y = spot)) +
  plot_base("left-skewed: mean < median",
            x_breaks = c(1, 3, 5, 7, 9, 11), x_limits = c(x_lo, x_hi),
            y_breaks = c(1, 3, 5, 7, 9, 11), y_limits = c(y_lo, y_hi)) +
  # the shape figure reads values on x, so the axis labels are swapped
  labs(x = "spot value (UMI)", y = "spot") +
  # the curve under the dots
  geom_line(data = cur, aes(x = x, y = y), colour = accent, linewidth = 0.4) +
  # the median: cyan dashed vertical line, sitting in the high pile
  annotate("segment", x = med, xend = med, y = y_lo, yend = y_hi,
           linetype = "dashed", colour = cyan, linewidth = 0.4) +
  # the mean: gold solid vertical line, dragged left by the low tail
  annotate("segment", x = mn, xend = mn, y = y_lo, yend = y_hi,
           colour = gold, linewidth = 0.6) +
  # the mean label sits in the empty band under the tail, clear of the low dots
  annotate("text", x = 1.1, y = 0.45, hjust = 0, size = 2.6,
           colour = gold, label = "mean = 6") +
  annotate("text", x = 8.4, y = 11.9, hjust = 0, size = 2.6,
           colour = cyan, label = "median = 8") +
  geom_point(size = 2, colour = text, fill = text) +
  # every element drawn small, so the space between the counts reads wide
  theme(
    plot.title   = element_text(size = 10),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6)
  )

save_fig(p_left, "shape_left.png")

cat("tumor3 mean:", mn, "median:", med, "sd:", sd(tumor3), "\n")
