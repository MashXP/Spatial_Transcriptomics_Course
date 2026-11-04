#!/usr/bin/env Rscript
# mean_sd_bar.png — the band from mean - sd to mean + sd, drawn around the mean
# bar, with one sd measured as a vertical arrow from the mean bar to the top of
# the band. x = spot number, y = spot value (UMI). Used on the "sd" slide.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/mean_sd_bar.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# the running example the slides use for this figure
counts <- c(2, 6, 8, 10, 20)
spots  <- seq_along(counts)   # spot number 1..5
m      <- mean(counts)        # 9.2
s      <- sd(counts)          # 6.723095

x_lo <- 0.35
x_hi <- 5.75

p_sd <- ggplot(data.frame(spot = spots, value = counts),
               aes(x = spot, y = value)) +
  plot_base("sd: the band from mean - sd to mean + sd",
            x_breaks = 1:5,  x_limits = c(0.3, 5.75),
            y_breaks = c(2, 6, 8, 10, 20), y_limits = c(0, 25)) +
  # the sd band: everything within one sd of the mean
  annotate("rect", xmin = x_lo, xmax = x_hi, ymin = m - s, ymax = m + s,
           fill = accent, alpha = 0.14) +
  annotate("segment", x = x_lo, xend = x_hi, y = m + s, yend = m + s,
           colour = accent, linewidth = 1.4) +
  annotate("segment", x = x_lo, xend = x_hi, y = m - s, yend = m - s,
           colour = accent, linewidth = 1.4) +
  annotate("segment", x = x_lo, xend = x_hi, y = m, yend = m,
           linetype = "dashed", colour = text, linewidth = 1.3) +
  # sd drawn as a vertical: the distance from the mean bar up to the band's top
  annotate("segment", x = 4.55, xend = 4.55, y = m, yend = m + s,
           colour = accent, linewidth = 1.2,
           arrow = arrow(angle = 25, length = unit(2.2, "mm"), type = "closed")) +
  geom_point(size = dot_size, colour = text, fill = text) +
  # labels inside the band, each one clear of the line it names
  annotate("text", x = x_lo + 0.06, y = m + 1.9, hjust = 0, size = 7.4,
           fontface = "bold", colour = text,   label = "mean = 9.2") +
  annotate("text", x = 4.40, y = m + s / 2, hjust = 1, size = 7.0,
           fontface = "bold", colour = accent, label = "sd = 6.72") +
  annotate("text", x = x_lo + 0.06, y = m + s - 1.9, hjust = 0, size = 6.6,
           colour = fade, label = "mean + sd = 15.92") +
  annotate("text", x = x_hi - 0.06, y = m - s + 1.9, hjust = 1, size = 6.6,
           colour = fade, label = "mean - sd = 2.48")

save_fig(p_sd, "mean_sd_bar.png")

cat("mean:", round(m, 2), "sd:", round(s, 6),
    "mean-sd:", round(m - s, 2), "mean+sd:", round(m + s, 2), "\n")
