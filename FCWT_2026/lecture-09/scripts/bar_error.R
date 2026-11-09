png("bar_error.png", width = 900, height = 600)

v <- c(2, 5, 8, 12, 18, 1, 2, 3, 4, 6)              # UMI, 10 spots
g <- rep(c("control", "tumor"), each = 5)           # 5 + 5

m  <- tapply(v, g, mean)
sd <- tapply(v, g, sd)

bp <- barplot(m, main = "bar + error bars", ylab = "mean UMI",
             ylim = c(0, 17), col = c("darkgreen", "darkred"))

arrows(bp, m - sd, bp, m + sd, code = 3, angle = 15, lwd = 2)
arrows(bp, m + sd, bp, m - sd, code = 3, angle = 15, lwd = 2)

dev.off()
