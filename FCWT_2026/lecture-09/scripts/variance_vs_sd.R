#!/usr/bin/env Rscript
# variance_vs_sd.png — two panels on one canvas: the tight vector on the left, the
# wide vector on the right. Same mean (11), same y scale, so the squares drawn on
# the mean bar compare directly: tiny areas on the left, huge areas on the right.
#
# Each square's height is |value - mean|, so its AREA is the squared deviation.
# To draw a real square on the page, the x width is converted between the panel's
# x and y pixel scales. The canvas is 1120 x 640 px split into two panels, so each
# panel's plotting area is 406 x 447 px.
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/variance_vs_sd.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

library(gridExtra)

# the new observation is drawn in cyan, distinct from the pink squares and the gold sd lines
cyan <- "#00FFFF"

# panel geometry measured from the canvas, in pixels. On the 1120 x 640 canvas split
# into two panels, each panel's plotting area measures 421 x 468 px (measured from
# the rendered PNG: the mean bar spans 421 px, 20 y units span 360 px).
panel_w <- 421
panel_h <- 468

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

# the two vectors: same mean, 5 spots each
tight <- c(9, 10, 11, 12, 13)
wide  <- c(1, 5, 11, 17, 21)
m     <- mean(tight)          # 11 for both

gap     <- 1
blank   <- 1
y_hi    <- 26
y_lo    <- 0

gap_panel <- function(counts, title, verdict, vy, dy_up, dy_dn) {
  L <- square_layout(counts, m, gap, blank, panel_w, panel_h, y_hi)
  x_lo <- L$x_lo[1]
  x_hi <- L$x_hi[1]
  s <- sd(counts)
  ggplot(data.frame(spot = L$x_pos, value = counts),
         aes(x = spot, y = value)) +
    plot_base(title,
              x_breaks = L$x_pos,  x_limits = c(x_lo, x_hi),
              y_breaks = c(0, 10, 20), y_limits = c(y_lo, y_hi)) +
    # the mean bar: thin dashed pink, with small text
    annotate("segment", x = x_lo, xend = x_hi, y = m, yend = m,
             linetype = "dashed", colour = accent, linewidth = 0.4) +
    annotate("text", x = x_lo + 0.5, y = m + 1.5, hjust = 0, size = 2.6,
             colour = accent, label = "mean = 11") +
    # the two sd lines, mean - sd and mean + sd
    annotate("segment", x = x_lo, xend = x_hi, y = m + s, yend = m + s,
             linetype = "dashed", colour = gold, linewidth = 0.4) +
    annotate("segment", x = x_lo, xend = x_hi, y = m - s, yend = m - s,
             linetype = "dashed", colour = gold, linewidth = 0.4) +
    annotate("text", x = x_hi - 0.1, y = m + s + dy_up, hjust = 1, size = 2.0,
             colour = gold, label = sprintf("mean + sd = %.2f", m + s)) +
    annotate("text", x = x_hi - 0.1, y = m - s - dy_dn, hjust = 1, size = 2.0,
             colour = gold, label = sprintf("mean - sd = %.2f", m - s)) +
    # lines connecting each point to the mean line, under the dots
    geom_segment(aes(x = L$x_pos, xend = L$x_pos, y = counts, yend = m),
                 inherit.aes = FALSE, colour = accent, linewidth = 0.4) +
    # squares built on those lines
    geom_rect(data = L, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              inherit.aes = FALSE, fill = alpha(accent, 0.14), colour = accent, linewidth = 0.4) +
    # each square's area = distance squared
    annotate("text", x = L$label_x, y = L$label_y, hjust = 0.5, size = 2.0,
             colour = accent, label = sprintf("%.0f", L$area)) +
    geom_point(size = 2, colour = text, fill = text) +
    # the new observation: a cyan point at 18, in the right blank of each panel,
    # with the verdict against this panel's sd band written above it
    annotate("point", x = x_hi - 0.3, y = 18, size = 2, colour = cyan, fill = cyan) +
    annotate("text", x = x_hi - 0.3, y = vy, hjust = 1, size = 2.6,
             colour = cyan, label = verdict) +
    # the spot numbers label the grid: 1..5 under the positions
    scale_x_continuous(breaks = L$x_pos, labels = seq_along(counts),
                       limits = c(x_lo, x_hi),
                       expand = expansion(mult = c(0.02, 0.02))) +
    # every element drawn small, so the space between the spot numbers reads wide
    theme(
      plot.title   = element_text(size = 10),
      axis.title.x = element_text(size = 8),
      axis.title.y = element_text(size = 8),
      axis.text.x  = element_text(size = 6),
      axis.text.y  = element_text(size = 6)
    )
}

p_t <- gap_panel(tight, "Tight",
                 "Significant!", vy = 19.7, dy_up = 2.0, dy_dn = 2.0)
p_w <- gap_panel(wide,  "Wide",
                 "Not significant", vy = 20.7, dy_up = 3.0, dy_dn = 1.2)

# grid.arrange leaves the canvas transparent, so ggsave(bg = bg) paints the deck
# background across the whole canvas. patchwork paints its own white canvas instead.
p_two <- gridExtra::grid.arrange(p_t, p_w, ncol = 2)

save_fig(p_two, "variance_vs_sd.png")

cat("tight x range:", -blank, "to",
    (2 * blank + (length(tight) - 1) * gap) / (1 - max(abs(tight - m)) * panel_h / y_hi / panel_w) - blank, "\n")
cat("wide  x range:", -blank, "to",
    (2 * blank + (length(wide) - 1) * gap) / (1 - max(abs(wide - m)) * panel_h / y_hi / panel_w) - blank, "\n")
cat("tight areas:", round((tight - m)^2, 3), "var:", var(tight), "sd:", sd(tight), "\n")
cat("wide  areas:", round((wide - m)^2, 3), "var:", var(wide), "sd:", sd(wide), "\n")
cat("ratios: sd", sd(wide) / sd(tight), "var", var(wide) / var(tight), "\n")
cat("tight band:", m - sd(tight), "to", m + sd(tight), "-> 18 outside\n")
cat("wide  band:", m - sd(wide), "to", m + sd(wide), "-> 18 inside\n")