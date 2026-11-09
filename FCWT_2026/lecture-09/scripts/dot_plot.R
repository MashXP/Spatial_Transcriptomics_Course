png("dot_plot.png", width = 900, height = 600)

v <- c(2, 5, 8, 12, 18, 1, 2, 3, 4, 6)              # UMI, 10 spots
g <- rep(c("control", "tumor"), each = 5)           # 5 + 5

stripchart(v ~ g, method = "stack", main = "stripchart (dot plot)",
           xlab = "UMI", pch = 16, col = c("darkgreen", "darkred"),
           xlim = c(0, 20), ylim = c(0.5, 2.5))

dev.off()
