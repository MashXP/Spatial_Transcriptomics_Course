#!/usr/bin/env Rscript
# shape_right.png — tumor2's thirteen spot counts plotted by value (x) and spot
# index (y), with the smoothed density curve over the dots. The curve piles up at
# the low end and keeps a long tail running to the right: the right-skewed shape.
# The gold line is the mean (6), the cyan dashed line is the median (5) — the mean
# sits to the right of the median because the tail drags it.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/shape_right.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# the median line is cyan, the same colour the quartile figures use for Q3
cyan <- "#00FFFF"

# tumor2: twelve low spots, one high spot.
tumor2 <- c(1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9, 18)
spots  <- seq_along(tumor2)   # spot number 1..13
mn     <- mean(tumor2)        # 6
med    <- median(tumor2)      # 5

# hand-set canvas: x is the count value, y is the spot index
x_lo <- 0
x_hi <- 22
y_lo <- 0
y_hi <- 14.5

# the density curve is scaled by hand so its peak sits at the top of the spot rows
d   <- density(tumor2)
cur <- data.frame(x = d$x, y = d$y * 97)

p_right <- ggplot(data.frame(value = tumor2, spot = spots),
                  aes(x = value, y = spot)) +
  plot_base("right-skewed: mean > median",
            x_breaks = c(1, 5, 10, 15, 17, 20), x_limits = c(x_lo, x_hi),
            y_breaks = c(1, 3, 5, 7, 9, 11, 13), y_limits = c(y_lo, y_hi)) +
  # the shape figure reads values on x, so the axis labels are swapped
  labs(x = "spot value (UMI)", y = "spot") +
  # the curve under the dots
  geom_line(data = cur, aes(x = x, y = y), colour = accent, linewidth = 0.4) +
  # the median: cyan dashed vertical line, sitting in the low pile
  annotate("segment", x = med, xend = med, y = y_lo, yend = y_hi,
           linetype = "dashed", colour = cyan, linewidth = 0.4) +
  # the mean: gold solid vertical line, dragged right by the one high spot
  annotate("segment", x = mn, xend = mn, y = y_lo, yend = y_hi,
           colour = gold, linewidth = 0.6) +
  annotate("text", x = 5.4, y = 14.0, hjust = 0, size = 2.6,
           colour = cyan, label = "median = 5") +
  annotate("text", x = 6.6, y = 13.0, hjust = 0, size = 2.6,
           colour = gold, label = "mean = 6") +
  geom_point(size = 2, colour = text, fill = text) +
  # every element drawn small, so the space between the counts reads wide
  theme(
    plot.title   = element_text(size = 10),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6)
  )

save_fig(p_right, "shape_right.png")

cat("tumor2 mean:", mn, "median:", med, "sd:", sd(tumor2), "\n")
