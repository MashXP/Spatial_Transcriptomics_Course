png("bar_box_hist.png", width = 900, height = 600)

v <- c(2, 5, 8, 12, 18, 1, 2, 3, 4, 6)              # UMI, 10 spots
g <- rep(c("control", "tumor"), each = 5)           # 5 + 5

par(mfrow = c(1, 3))

hist(v, main = "hist()", xlab = "UMI")
boxplot(v ~ g, main = "boxplot(v ~ g)", ylab = "UMI")
barplot(tapply(v, g, mean), main = "barplot()", ylab = "mean UMI")

dev.off()
