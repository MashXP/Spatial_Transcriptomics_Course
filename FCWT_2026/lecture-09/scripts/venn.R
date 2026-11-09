png("venn.png", width = 900, height = 600)

# three gene sets. Counts are the set sizes:
#   Tumor DE 240, Control DE 180, Drug-response annotated 130
#   Tumor & Control 90, Tumor & Drug 40, Control & Drug 25, all three 12
plot.new()
plot.window(xlim = c(0, 1), ylim = c(0, 1), asp = 1)
title(main = "venn diagram: 3 gene sets")

circle <- function(cx, cy, r, col) {
  a <- seq(0, 2 * pi, length.out = 200)
  lines(cx + r * cos(a), cy + r * sin(a), col = col, lwd = 2)
}

circle(0.35, 0.62, 0.28, "darkgreen")   # Tumor DE
circle(0.65, 0.62, 0.28, "darkred")     # Control DE
circle(0.50, 0.42, 0.28, "darkblue")    # Drug-response annotated

# region counts
text(0.22, 0.72, "122", col = "darkgreen")
text(0.78, 0.72, "77",  col = "darkred")
text(0.50, 0.24, "77",  col = "darkblue")
text(0.50, 0.72, "78",  col = "black")
text(0.37, 0.44, "28",  col = "black")
text(0.63, 0.44, "13",  col = "black")
text(0.50, 0.55, "12",  col = "black")

# set names
text(0.28, 0.97, "Tumor DE", col = "darkgreen")
text(0.28, 0.90, "240", col = "darkgreen")
text(0.72, 0.97, "Control DE", col = "darkred")
text(0.72, 0.90, "180", col = "darkred")
text(0.50, 0.03, "Drug-response", col = "darkblue")
text(0.50, 0.16, "130", col = "darkblue")

dev.off()
