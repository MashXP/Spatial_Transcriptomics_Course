#!/usr/bin/env Rscript
# variance.png — spot dots, mean line, one square per spot built on the line
# from the point to the mean, and the square's area as its number.
#
# A square's height is the distance from the point to the mean line, so its
# AREA is the squared deviation. To draw it as a real square on the page, the
# x width has to be converted between the panel's x and y pixel scales. The
# panel measures 960.5 x 468 px of plotting area on the 1120 x 640 canvas.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/variance.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

# panel geometry measured from the canvas, in pixels
panel_w <- 960
panel_h <- 460

# the legend formula, rendered in R by latex2exp: TeX() turns a LaTeX string into
# a plotmath expression, which annotate("text") draws directly. No LaTeX install,
# no external process.
library(latex2exp)
legend_formula <- TeX(r"($v = \frac{1}{n-1}\sum_{i=1}^{n}(x_i - \bar{x})^2$)")

# one square per spot: height = |value - mean|, left edge = the spot's x,
# width converted to x units so the drawn shape is square on the page
square_layout <- function(counts, m, gap, blank, panel_w, panel_h, y_hi) {
  px_y   <- panel_h / y_hi                       # px per y unit
  maxdev <- max(abs(counts - m))
  n      <- length(counts)
  # x range that makes the widest square square: span = (blank left + row width
  # + blank right) / (1 - maxdev * px_y / panel_w)
  span <- (2 * blank + (n - 1) * gap) / (1 - maxdev * px_y / panel_w)
  x_pos <- (seq_along(counts) - 1) * gap
  w     <- abs(counts - m) * px_y * span / panel_w
  data.frame(
    x_lo    = -blank,
    x_hi    = -blank + span,
    x_pos   = x_pos,
    xmin    = x_pos,
    xmax    = x_pos + w,
    ymin    = pmin(counts, m),
    ymax    = pmax(counts, m),
    label_x = x_pos + w / 2,
    label_y = (pmin(counts, m) + pmax(counts, m)) / 2,
    area    = (counts - m)^2
  )
}

# 7 spots (odd n, so the median is a real spot), one Visium sample.
counts7 <- c(1, 2, 4, 6, 8, 20, 40)
spots7  <- seq_along(counts7)   # spot number 1..7
m       <- mean(counts7)        # 11.57143

gap     <- 1
blank   <- 1
y_hi    <- 52

L <- square_layout(counts7, m, gap, blank, panel_w, panel_h, y_hi)
x_lo <- L$x_lo[1]
x_hi <- L$x_hi[1]

p_var <- ggplot(data.frame(spot = L$x_pos, value = counts7),
                aes(x = spot, y = value)) +
  plot_base("variance: area = distance squared",
            x_breaks = L$x_pos,  x_limits = c(x_lo, x_hi),
            y_breaks = c(0, 10, 20, 30, 40), y_limits = c(0, y_hi)) +
  # the mean bar: thin dashed pink, with small text
  annotate("segment", x = x_lo, xend = x_hi, y = m, yend = m,
           linetype = "dashed", colour = accent, linewidth = 0.4) +
  annotate("text", x = x_lo + 0.5, y = m + 3.0, hjust = 0, size = 2.6,
           colour = accent, label = "mean = 11.57143") +
  # legend: the variance formula, in a white-framed, transparent box in the right corner
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
  geom_segment(aes(x = L$x_pos, xend = L$x_pos, y = counts7, yend = m),
               inherit.aes = FALSE, colour = accent, linewidth = 0.4) +
  # squares built on those lines
  geom_rect(data = L, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            inherit.aes = FALSE, fill = alpha(accent, 0.14), colour = accent, linewidth = 0.4) +
  # the numbers for the variance: each square's area = distance squared
  annotate("text", x = L$label_x, y = L$label_y, hjust = 0.5, size = 2.0,
           colour = accent, label = sprintf("%.1f", L$area)) +
  geom_point(size = 2, colour = text, fill = text) +
  # the spot numbers label the grid: 1..7 under the positions
  scale_x_continuous(breaks = L$x_pos, labels = spots7, limits = c(x_lo, x_hi),
                     expand = expansion(mult = c(0.02, 0.02))) +
  # every element drawn small, so the space between the spot numbers reads wide
  theme(
    plot.title   = element_text(size = 10),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6)
  )

save_fig(p_var, "variance.png")

cat("x range:", x_lo, "to", x_hi, "\n")
cat("square widths x:", round(L$xmax, 3), "\n")
cat("areas:", round(L$area, 3), "sum:", round(sum(L$area), 3), "variance:", var(counts7), "\n")
