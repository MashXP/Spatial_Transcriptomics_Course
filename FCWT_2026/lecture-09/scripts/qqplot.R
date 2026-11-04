#!/usr/bin/env Rscript
# qqplot.png — three Q-Q panels on one canvas, one per tumor. Each panel plots the
# sorted spot values (y) against the quantiles of a perfect bell (x), with the gold
# reference line through the middle. Points hugging the line mean the bell shape is
# a fair assumption; points curving away at the end mean a real tail.
#
# The reference line is the same line R's qqline() draws: it goes through the first
# and third quartiles of the data.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/qqplot.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# the three tumors from the problem slide
tumor1 <- c(1, 3, 4, 5, 6, 6, 6, 7, 8, 9, 11)
tumor2 <- c(1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9, 18)
tumor3 <- c(1, 2, 3, 5, 7, 8, 8, 8, 8, 8, 8)

# the deck's quartile convention (Tukey hinges = quantile type 7) is what
# qqline() uses, so the line matches the IQR slide
ref_line <- function(v, lab) {
  qs  <- quantile(v, c(0.25, 0.75), names = FALSE)
  th  <- qnorm(c(0.25, 0.75))
  slope     <- (qs[2] - qs[1]) / (th[2] - th[1])
  intercept <- qs[1] - slope * th[1]
  xg <- seq(-2.6, 2.6, length.out = 200)
  data.frame(theo = xg, samp = intercept + slope * xg, lab = lab)
}

build <- function(v, lab) {
  data.frame(theo = qnorm(ppoints(v)), samp = sort(v), lab = lab)
}

dat <- rbind(build(tumor1, "symmetric"),
            build(tumor2, "right-skewed"),
            build(tumor3, "left-skewed"))

lin <- rbind(ref_line(tumor1, "symmetric"),
            ref_line(tumor2, "right-skewed"),
            ref_line(tumor3, "left-skewed"))

dat$lab <- factor(dat$lab, levels = c("symmetric", "right-skewed", "left-skewed"))
lin$lab <- factor(lin$lab, levels = levels(dat$lab))

p_qq <- ggplot(dat, aes(x = theo, y = samp)) +
  plot_base("Q-Q plot: the points tell you the shape",
            x_breaks = c(-2, 0, 2), x_limits = c(-2.6, 2.6),
            y_breaks = c(0, 5, 10, 15), y_limits = c(-1, 19)) +
  # the Q-Q figure reads normal quantiles on x, so the axis labels are swapped
  labs(x = "normal quantile", y = "spot value (UMI)") +
  # the reference line: a perfect bell sits on it
  geom_line(data = lin, aes(x = theo, y = samp),
            colour = gold, linewidth = 0.4) +
  geom_point(size = 2, colour = accent, fill = accent) +
  facet_wrap(~ lab, nrow = 1) +
  # one strip per tumor, so the three panels read as a row
  theme(
    plot.title   = element_text(size = 10),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6),
    panel.grid.major.x = element_blank(),
    strip.text         = element_text(size = 8, face = "bold", colour = text),
    strip.background   = element_rect(fill = bg, colour = NA),
    strip.placement    = "outside"
  )

save_fig(p_qq, "qqplot.png")

cat("symmetric   : mean", mean(tumor1), "median", median(tumor1),
    "sd", sd(tumor1), "p", shapiro.test(tumor1)$p.value, "\n")
cat("right-skewed: mean", mean(tumor2), "median", median(tumor2),
    "sd", sd(tumor2), "p", shapiro.test(tumor2)$p.value, "\n")
cat("left-skewed : mean", mean(tumor3), "median", median(tumor3),
    "sd", sd(tumor3), "p", shapiro.test(tumor3)$p.value, "\n")
