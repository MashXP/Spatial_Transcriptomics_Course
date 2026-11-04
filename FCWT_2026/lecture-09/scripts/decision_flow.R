#!/usr/bin/env Rscript
# decision_flow.png — the test-choice ladder: five question boxes on a vertical spine
# down the left, two test boxes branching right on every row. Every connector is
# right-angled, and the condition is written on the arrow.
#
# Colour rule: gold = normal-distribution (parametric) test, pink = rank test. The counting row
# is drawn pink: neither Fisher nor chi-square assumes the normal distribution.
#
# row 1  2 groups?           -> t-test (if normal) / Wilcoxon (if not)
# row 2  Paired?             -> paired t (if normal) / Wilcoxon signed-rank (if not)
# row 3  3+ groups?          -> ANOVA (if normal) / Kruskal-Wallis (if not)
# row 4  Counting data?      -> Fisher (expected < 5) / chi-square (expected >= 5)
# row 5  Not sure about the shape? -> use the rank test, and say which you used
#
# Run inside the R env (R is not on the default PATH):
#   micromamba run -n R_tutorial Rscript scripts/decision_flow.R

source(file.path(dirname(normalizePath(sub("--file=", "",
  grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))), "style.R"))

library(scales)

# hand-set canvas: 9.2 units wide, 10 tall, five rows on a pitch of 1.95.
# The canvas is taller than the deck standard (3.2 in) so each row's two boxes have
# room for two lines of text and the spine has room between rows.
x_lo <- 0;    x_hi <- 9.2
y_lo <- -5;   y_hi <- 5
pitch <- 1.95

# question boxes sit on the spine at x = spine_x
q_x1 <- 0.15; q_x2 <- 2.35; q_h <- 1.0
spine_x <- (q_x1 + q_x2) / 2

# the two branching test boxes: upper box (normal), lower box (rank).
# t_h fits two lines of text at size 2.4, and the lanes sit at +/- lane_off inside
# each row, so the two boxes never touch.
t_x1 <- 4.85; t_x2 <- 7.55; t_h <- 0.7
b_x2 <- 8.8
lane_off <- 0.45

# the corner where every arm bends, between the question box and the test boxes
elbow_x <- 3.6

# row centres, top row first, centred on y = 0
rows <- c(3.9, 1.95, 0, -1.95, -3.9)

qbox <- function(y, label) {
  list(
    annotate("rect", xmin = q_x1, xmax = q_x2, ymin = y - q_h / 2, ymax = y + q_h / 2,
             fill = alpha(fade, 0.85), colour = NA),
    annotate("text", x = spine_x, y = y, label = label, hjust = 0.5,
             colour = bg, size = 3.2)
  )
}

tbox <- function(x1, x2, y, label, fill, tcol) {
  list(
    annotate("rect", xmin = x1, xmax = x2, ymin = y - t_h / 2, ymax = y + t_h / 2,
             fill = alpha(fill, 0.85), colour = NA),
    annotate("text", x = (x1 + x2) / 2, y = y, label = label, hjust = 0.5,
             colour = tcol, size = 2.4)
  )
}

# one right-angled arm: straight right from the question box, a corner at elbow_x,
# then straight to the test box. dir = +1 is the upper lane, dir = -1 the lower.
# The condition is written on the horizontal run leaving the question box.
arm <- function(y, dir, label) {
  list(
    annotate("segment", x = q_x2, xend = elbow_x, y = y, yend = y,
             colour = fade, linewidth = 0.4),
    annotate("segment", x = elbow_x, xend = elbow_x, y = y, yend = y + dir * lane_off,
             colour = fade, linewidth = 0.4),
    annotate("segment", x = elbow_x, xend = t_x1, y = y + dir * lane_off,
             yend = y + dir * lane_off, colour = fade, linewidth = 0.4,
             arrow = arrow(length = unit(0.12, "cm"), angle = 25, type = "closed")),
    annotate("text", x = (q_x2 + elbow_x) / 2, y = y + dir * 0.27, label = label,
             hjust = 0.5, colour = fade, size = 2.2)
  )
}

# the spine: one arrow from the bottom of each question box into the top of the next,
# reading top to bottom. The condition "no" is written beside the arrow.
spine <- function(y, label) {
  list(
    annotate("segment", x = spine_x, xend = spine_x,
             y = y - q_h / 2, yend = y - pitch + q_h / 2,
             colour = fade, linewidth = 0.4,
             arrow = arrow(length = unit(0.12, "cm"), angle = 25, type = "closed")),
    annotate("text", x = spine_x + 0.4, y = y - pitch / 2, label = label, hjust = 0,
             colour = fade, size = 2.2)
  )
}

p_flow <- ggplot() +
  # question boxes on the spine
  qbox(rows[1], "2 groups?") +
  qbox(rows[2], "Paired?") +
  qbox(rows[3], "3+ groups?") +
  qbox(rows[4], "Counting data?") +
  qbox(rows[5], "Not sure about\nthe shape?") +
  # the branching test boxes: gold for normal-distribution, pink for rank
  tbox(t_x1, t_x2, rows[1] + lane_off, "t-test", gold, bg) +
  tbox(t_x1, t_x2, rows[1] - lane_off, "Wilcoxon", accent, "white") +
  tbox(t_x1, t_x2, rows[2] + lane_off, "paired t", gold, bg) +
  tbox(t_x1, t_x2, rows[2] - lane_off, "Wilcoxon\nsigned-rank", accent, "white") +
  tbox(t_x1, t_x2, rows[3] + lane_off, "ANOVA", gold, bg) +
  tbox(t_x1, t_x2, rows[3] - lane_off, "Kruskal-Wallis", accent, "white") +
  tbox(t_x1, t_x2, rows[4] + lane_off, "Fisher", accent, "white") +
  tbox(t_x1, t_x2, rows[4] - lane_off, "chi-square", accent, "white") +
  # row 5: one box, the wide answer
  annotate("rect", xmin = t_x1, xmax = b_x2, ymin = rows[5] - t_h / 2,
           ymax = rows[5] + t_h / 2, fill = alpha(accent, 0.85), colour = NA) +
  annotate("text", x = (t_x1 + b_x2) / 2, y = rows[5], hjust = 0.5, size = 2.4,
           colour = "white", label = "use the rank test, and say which you used") +
  # the arrows, on top: spine with "no", arms with the condition
  spine(rows[1], "no") + spine(rows[2], "no") + spine(rows[3], "no") + spine(rows[4], "no") +
  arm(rows[1],  1, "if normal") + arm(rows[1], -1, "if not") +
  arm(rows[2],  1, "if normal") + arm(rows[2], -1, "if not") +
  arm(rows[3],  1, "if normal") + arm(rows[3], -1, "if not") +
  arm(rows[4],  1, "expected < 5") + arm(rows[4], -1, "expected >= 5") +
  annotate("segment", x = q_x2, xend = t_x1, y = rows[5], yend = rows[5],
           colour = fade, linewidth = 0.4,
           arrow = arrow(length = unit(0.12, "cm"), angle = 25, type = "closed")) +
  # no axes, no grid, no title: the slide heading is the title
  labs(x = NULL, y = NULL, title = NULL) +
  coord_cartesian(xlim = c(x_lo, x_hi), ylim = c(y_lo, y_hi), expand = FALSE) +
  theme_minimal() +
  theme(
    plot.title      = element_blank(),
    axis.title      = element_blank(),
    axis.text       = element_blank(),
    axis.line       = element_blank(),
    axis.ticks      = element_blank(),
    panel.border    = element_blank(),
    panel.grid      = element_blank(),
    plot.background = element_rect(fill = bg, colour = NA),
    panel.background = element_rect(fill = bg, colour = NA),
    legend.position = "none",
    plot.margin     = margin(10, 12, 10, 10)
  )

save_fig(p_flow, "decision_flow.png")
