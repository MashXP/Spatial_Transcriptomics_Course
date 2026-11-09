png("stacked_bars.png", width = 900, height = 600)

# spots per cell type per sample. Rows = cell types, columns = samples.
mat <- rbind(immune    = c(120,  90,  40),
            epithelial = c(340, 210, 120),
            stroma     = c( 60,  40,  20))
colnames(mat) <- c("Tumor", "Adjacent", "Control")

cols <- c("darkgreen", "darkred", "darkblue")

par(mfrow = c(1, 2))

barplot(mat, main = "stacked bars", ylab = "spots", col = cols)
barplot(100 * prop.table(mat, 2), main = "100% stacked", ylab = "share (%)",
        col = cols, legend.text = TRUE)

dev.off()
