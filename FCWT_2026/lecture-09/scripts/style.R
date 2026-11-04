#!/usr/bin/env Rscript
# Shared style for every lecture-09 figure script. Each figure lives in its own
# script; they all source this file. Nothing here draws a figure.
#
# Canvas: 1120 x 640 px (5.6 x 3.2 in at 200 dpi). Palette matched to the deck's
# dark background: bg #1e2233, text #e6e6ef, accent pink #d6336c, median gold
# #e7ad52, muted #98a3c7, grid #2a2f45, bold sans.

library(ggplot2)

bg     <- "#1e2233"
text   <- "#e6e6ef"
accent <- "#d6336c"
gold   <- "#e7ad52"
fade   <- "#98a3c7"
grid   <- "#2a2f45"

# every figure in the deck is drawn on this canvas
fig_w    <- 5.6
fig_h    <- 3.2
fig_dpi  <- 200
dot_size <- 2

# the directory this file (and the figure scripts) live in
script_dir <- function() {
  a <- commandArgs(trailingOnly = FALSE)
  f <- grep("--file=", a, value = TRUE)
  if (length(f)) return(dirname(normalizePath(sub("--file=", "", f[1]))))
  getwd()
}

assets_dir <- function() normalizePath(file.path(script_dir(), "../_assets"))

# Labels, axes and the dark theme for a spot-number plot. Grid lines are panel
# grid, so they sit UNDER the points and bars, never over them.
#
# title, x_breaks, x_limits, y_breaks, y_limits
plot_base <- function(title, x_breaks, x_limits, y_breaks, y_limits) {
  list(
    labs(x = "spot number", y = "spot value (UMI)", title = title),
    scale_x_continuous(limits = x_limits, breaks = x_breaks,
                       expand = expansion(mult = c(0.02, 0.02))),
    scale_y_continuous(limits = y_limits, breaks = y_breaks,
                       expand = expansion(mult = c(0.02, 0.02))),
    theme_minimal() +
    theme(
      plot.title   = element_text(size = 13.5, face = "bold", colour = text,
                                  hjust = 0, margin = margin(b = 6)),
      axis.title.x = element_text(size = 11, face = "bold", colour = text),
      axis.title.y = element_text(size = 11, face = "bold", colour = text),
      axis.text.x  = element_text(size = 9, color = fade),
      axis.text.y  = element_text(size = 9, color = fade),
      axis.line    = element_blank(),
      panel.border = element_blank(),
      # major grid at every break, no minor grid: one line per spot, one per
      # labelled UMI level
      panel.grid.major.x = element_line(colour = grid, linewidth = 0.4),
      panel.grid.major.y = element_line(colour = grid, linewidth = 0.4),
      panel.grid.minor   = element_blank(),
      plot.background    = element_rect(fill = bg, colour = NA),
      panel.background   = element_rect(fill = bg, colour = NA),
      legend.position    = "none",
      plot.margin        = margin(10, 12, 10, 10)
    )
  )
}

# Save a figure into _assets under the deck's canvas size.
save_fig <- function(p, name) {
  ggsave(file.path(assets_dir(), name), p,
         width = fig_w, height = fig_h, dpi = fig_dpi, bg = bg)
  cat("wrote", file.path(assets_dir(), name), "\n")
}
