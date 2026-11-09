png("density_ridge.png", width = 900, height = 600)

ctl <- c(12, 15, 18, 20, 22, 25, 28, 30, 33, 35, 38, 40, 42, 45, 48, 50, 55, 60, 65, 70)
tum <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30)

d <- data.frame(umi = c(ctl, tum),
                group = rep(c("control", "tumor"), c(length(ctl), length(tum))))

library(ggplot2)
library(ggridges)
library(patchwork)

# left: both curves on one axis. right: one curve per row (ridgeline)
p_curve <- ggplot(d, aes(x = umi, fill = group)) +
  geom_density(alpha = 0.5) +
  labs(x = "UMI", y = "density", title = "density()")

p_ridge <- ggplot(d, aes(x = umi, y = group, fill = group)) +
  geom_density_ridges(alpha = 0.5) +
  labs(x = "UMI", y = NULL, title = "ridgeline")

print(p_curve + p_ridge)

dev.off()
