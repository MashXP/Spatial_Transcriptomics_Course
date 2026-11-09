png("umap.png", width = 900, height = 600)

# 180 cells, 3 clusters, coordinates from a fake UMAP layout
set.seed(1)
centers <- rbind(c(0, 0), c(7, 1), c(3.5, 6.5))
pts <- do.call(rbind, lapply(1:3, function(k)
  cbind(centers[k, 1] + rnorm(60, 0, 0.8), centers[k, 2] + rnorm(60, 0, 0.8))))
cluster <- rep(c("CD8 T", "epithelial", "stroma"), each = 60)

plot(pts, col = 1:3, pch = 16, main = "UMAP / tSNE: cells as points",
     xlab = "UMAP_1", ylab = "UMAP_2", xlim = c(-3, 10), ylim = c(-3, 9))
legend("bottomright", legend = c("CD8 T", "epithelial", "stroma"),
       col = 1:3, pch = 16, bty = "n")

dev.off()
