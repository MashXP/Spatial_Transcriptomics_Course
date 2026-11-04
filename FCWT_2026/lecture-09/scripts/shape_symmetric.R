#!/usr/bin/env Rscript
# shape_symmetric.png — tumor1's eleven spot counts plotted by value (x) and spot
# index (y), with the smoothed density curve over the dots. The curve peaks in the
# middle and thins out evenly on both sides: the symmetric shape. The gold line is
# the mean (6), and the median (6) lands on the same value, so one line carries
# both labels.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/shape_symmetric.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# tumor1: eleven spots, counts spread evenly around 6.
tumor1 <- c(1, 3, 4, 5, 6, 6, 6, 7, 8, 9, 11)
spots  <- seq_along(tumor1)   # spot number 1..11
mn     <- mean(tumor1)        # 6
med    <- median(tumor1)      # 6

# hand-set canvas: x is the count value, y is the spot index
x_lo <- 0
x_hi <- 15
y_lo <- 0
y_hi <- 12.5

# the density curve is scaled by hand so its peak sits at the top of the spot rows
d   <- density(tumor1)
cur <- data.frame(x = d$x, y = d$y * 77)

p_sym <- ggplot(data.frame(value = tumor1, spot = spots),
                aes(x = value, y = spot)) +
  plot_base("symmetric: mean = median",
            x_breaks = c(2, 4, 6, 8, 10, 12, 14), x_limits = c(x_lo, x_hi),
            y_breaks = c(1, 3, 5, 7, 9, 11), y_limits = c(y_lo, y_hi)) +
  # the shape figure reads values on x, so the axis labels are swapped
  labs(x = "spot value (UMI)", y = "spot") +
  # the curve under the dots
  geom_line(data = cur, aes(x = x, y = y), colour = accent, linewidth = 0.4) +
  # the mean and the median land on the same value: one gold vertical line
  annotate("segment", x = mn, xend = mn, y = y_lo, yend = y_hi,
           colour = gold, linewidth = 0.6) +
  annotate("text", x = 6.4, y = 11.6, hjust = 0, size = 2.6,
           colour = gold, label = "mean = median = 6") +
  geom_point(size = 2, colour = text, fill = text) +
  # every element drawn small, so the space between the counts reads wide
  theme(
    plot.title   = element_text(size = 10),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6)
  )

save_fig(p_sym, "shape_symmetric.png")

cat("tumor1 mean:", mn, "median:", med, "sd:", sd(tumor1), "\n")
