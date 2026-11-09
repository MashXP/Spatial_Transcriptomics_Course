png("hist_plot.png", width = 900, height = 600)

v <- c(2, 5, 8, 12, 18, 1, 2, 3, 4, 6)              # UMI, 10 spots

hist(v, main = "hist()", breaks = seq(0, 20, by = 5), xlab = "UMI")

dev.off()
