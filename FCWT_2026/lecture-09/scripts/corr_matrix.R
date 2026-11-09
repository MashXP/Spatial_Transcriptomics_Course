png("corr_matrix.png", width = 900, height = 600)

# 7 genes measured in the same 12 spots
genes <- rbind(
  MKI67  = c(58, 62, 51, 47, 20, 14, 12,  9,  5,  4,  3,  6),
  CDKN2A = c(30, 34, 20, 26, 15,  6,  9,  4,  2,  5,  2,  3),
  EPCAM  = c(44, 30, 40, 25, 20, 12, 14,  6,  4,  3,  5,  2),
  PTPRC  = c( 8, 25, 10,  5, 30, 42, 36, 28, 60, 66, 58, 44),
  COL1A1 = c(12, 25, 10, 20, 30, 35, 25, 32, 45, 50, 48, 30),
  MTOR   = c(20, 10, 30, 15, 25, 12, 35, 18, 22, 14, 28, 16),
  RPLPO  = c(100, 102, 98, 101, 99, 100, 101, 99, 102, 98, 100, 101)
)

r <- cor(t(genes))

library(corrplot)
corrplot(r, method = "number", type = "upper",
         main = "correlation matrix (Pearson r)", tl.col = "black",
         cl.pos = "n", tl.cex = 0.8, number.cex = 0.75)

dev.off()
