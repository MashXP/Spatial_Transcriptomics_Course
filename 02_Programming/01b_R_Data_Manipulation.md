# Module 1b: R Data Manipulation

> 🚀 **Interactive Google Colab Notebook:** [01b_R_Data_Manipulation.ipynb](./01b_R_Data_Manipulation.ipynb)

Imagine you finally loaded your gene dataset, but it is a complete mess: some cells are empty (`NA`), others have formatting typos like `"Actb-mouse"` mixed with `"ACTB"`, and you need to filter down to only the top 100 highly expressed genes. Doing this manually for thousands of rows is a nightmare.

This module covers **R Data Manipulation**. You will learn how R stores different types of collections (like vectors, matrices, and data frames) and how to clean, filter, and restructure them using fast, automated commands.

---

## 1. R Data Structures

R has six basic data structures designed to store data collections:

```
                       +-----------------------------------+
                       |       R Data Structures           |
                       +-----------------------------------+
                                         |
       +--------------------+------------+------------+--------------------+
       |                    |                         |                    |
  [ Vectors ]           [ Lists ]                [ Matrices ]       [ Data Frames ]
  (Same type, 1D)     (Any type, 1D)            (Same type, 2D)    (Any type, 2D table)
```

### A. Vectors (1D, Homogeneous)
Vectors are 1D arrays of items of the same data type. Created using `c()`.
*   **Sequences**: Create numeric sequences using `:` or `seq()`.
*   **Repetitions**: Repeat elements using `rep()`.

```R
vals <- c(10, 20, 30)
range_seq <- 1:5              # 1 2 3 4 5
rep_seq <- rep(1, 3)          # 1 1 1
custom_seq <- seq(from=2, to=10, by=2) # 2 4 6 8 10

# Subsetting (counting starts at 1)
vals[2]   # Output: 20
vals[-1]  # Output: 20 30 (negative indices remove elements)
```

### B. Lists (1D, Heterogeneous)
Lists can store multiple data types and structures together. Accessing nested list elements requires double brackets `[[]]`.

```R
my_list <- list(name = "Spot_01", coordinates = c(12, 14), qc_pass = TRUE)

# Accessing named lists
my_list$name      # Output: "Spot_01"

# Double brackets access elements directly (preserving type)
my_list[[2]]      # Output: 12 14 (numeric vector)
my_list[2]        # Output: $coordinates 12 14 (returns a list containing the vector)
```

### C. Matrices & Arrays (Homogeneous, Multi-Dimensional)
*   **Matrix**: A 2D grid of items that are all of the same data type.
*   **Array**: A multi-dimensional structure (like stacking matrices).

```R
# Create a 2x3 matrix
my_matrix <- matrix(c(1, 2, 3, 4, 5, 6), nrow = 2, ncol = 3)
# Subsetting: [row, column]
my_matrix[2, 3] # Row 2, Column 3 -> Output: 6

# Create a 3D array (2 rows, 3 columns, 2 matrices deep)
my_array <- array(c(1:12), dim = c(2, 3, 2))
```

### D. Data Frames (2D, Heterogeneous Table)
The most important structure for tabular bioinformatics datasets. Columns can have different data types.

```R
df <- data.frame(
  spot = c("S1", "S2", "S3"),
  count = c(12, 45, 0),
  in_tissue = c(TRUE, TRUE, FALSE),
  stringsAsFactors = FALSE
)

# Exploration commands
head(df, n = 2)     # Inspect first 2 rows
dim(df)             # Returns dimensions (rows, columns)
nrow(df)            # Number of rows
colnames(df)        # Column names
str(df)             # Table structure overview

# Subsetting
df$count            # Access count column -> 12 45 0
df[df$count > 10, ] # Filter table where count > 10
```

### E. Factors (Categorical Variables)
Factors represent category groupings (e.g., `"Treated"` vs `"Control"`, or Cell Types).

```R
cell_types <- factor(c("T-cell", "B-cell", "T-cell"))
levels(cell_types) # Output: "B-cell" "T-cell"
```

---

## 2. Regular Expressions & String Manipulation

> **The Problem:** Your dataset contains a list of thousands of gene names like `"GAPDH"`, `"ACTB-mouse"`, and `"CD8A-mouse"`. You need to clean them by removing the `"-mouse"` suffix. Editing them one-by-one in Excel is slow and prone to errors.
>
> **The Solution:** **Regular expressions** and string helpers (`sub`, `gsub`, `nchar`, `grep`) allow you to detect patterns and clean text labels across thousands of entries in a single step.

*   `grep()`: Searches for pattern matches in a vector. Returns indices or values.
*   `sub()`: Replaces the first match of a pattern.
*   `gsub()`: Replaces all occurrences of a match.
*   `substr()`: Extracts sub-sections of a string.
*   `toupper()` / `tolower()`: Converts text case to uppercase or lowercase.
*   `nchar()`: Counts the number of characters in a string.

```R
genes <- c("GAPDH", "ACTB-mouse", "CD8A-mouse", "IL6")

# Search for patterns
grep("mouse", genes)               # Output: 2 3 (indices)
grep("mouse", genes, value = TRUE) # Output: "ACTB-mouse" "CD8A-mouse"

# Substitute strings
sub("-mouse", "", genes)           # Output: "GAPDH" "ACTB" "CD8A" "IL6"

# Convert case
toupper("gapdh")                   # Output: "GAPDH"
tolower("ACTB")                    # Output: "actb"

# Count characters
nchar(genes)                       # Output: 5 10 10 3
```

---

## 3. Data Cleaning & Handling NA Values

Genomic datasets contain missing values (`NA`) and zero counts that must be resolved.

```R
expression <- c(12, NA, 45, 0, NA, 99)

# 1. Identify NA values
is.na(expression)  # FALSE TRUE FALSE FALSE TRUE FALSE

# 2. Count NA and non-NA values
sum(is.na(expression))  # Output: 2 (TRUE counts as 1)
sum(!is.na(expression)) # Output: 4

# 3. Clean NA values
na.omit(expression)     # Removes NA values completely
clean_vector <- expression[complete.cases(expression)] # Alternative

# 4. Remove NA during computation
mean(expression)                # Output: NA (fails due to NA)
mean(expression, na.rm = TRUE)  # Output: 39 (computes correctly)
```

---

## 4. Vectorization & The apply Family

> **The Problem:** You want to compute the average expression of 20,000 genes across samples. Writing a traditional `for` loop in R requires executing R code at each index step, which is slow and memory-intensive for large genomic datasets.
>
> **The Solution:** R is built for **vectorization**. The **`apply` family of functions** performs iterations in compiled C/Fortran code, completing calculations across entire matrices almost instantly.

```
+----------+------------------------------------------+-----------------------+
| Function | Target Structure                         | Return Type           |
+----------+------------------------------------------+-----------------------+
| apply    | Matrix / Data Frame (Margin 1=Row, 2=Col)| Vector / Matrix       |
| lapply   | Vector / List                            | List                  |
| sapply   | Vector / List                            | Vector / Matrix (Simp)|
| tapply   | Vector (grouped by Factor)               | Vector                |
+----------+------------------------------------------+-----------------------+
```

```R
# Setup matrix
expr_matrix <- matrix(1:12, nrow = 3, ncol = 4)

# 1. apply: Compute mean for each row (Margin 1)
apply(expr_matrix, 1, mean) # Output: 2.5 5.5 8.5 (vector of row means)

# 2. lapply: Returns a list of square roots
lapply(c(4, 9), sqrt)       # Output: List of 2 and 3

# 3. sapply: Returns a simplified numeric vector
sapply(c(4, 9), sqrt)       # Output: 2 3

# 4. tapply: Average expression grouped by cell type category
expression_levels <- c(12, 15, 100, 110)
groups <- factor(c("Control", "Control", "Treated", "Treated"))
tapply(expression_levels, groups, mean)
# Output: Control = 13.5, Treated = 105.0
```

---

## 5. Custom Functions

Create reusable blocks of code. Always use `return()` to pass outputs programmatically rather than just `print()` which only displays to the console.

```R
# Calculate UMI percentage
calc_percentage <- function(gene_count, total_umi) {
  # Input validation
  if (!is.numeric(gene_count) | !is.numeric(total_umi)) {
    stop("Inputs must be numeric!")
  }
  
  pct <- (gene_count / total_umi) * 100
  return(pct)
}

# Run function
calc_percentage(25, 500) # Output: 5
```

---

## 6. File Input / Output & Merging Datasets

### Standard I/O
Always set `row.names = FALSE` when writing CSV files to avoid appending coordinate index columns.

```R
# Write
write.csv(df, "spots.csv", row.names = FALSE)

# Read
my_df <- read.csv("spots.csv")
```

### High-Throughput Reading & Directory Merging
For large datasets, base R `read.csv()` is slow. Use `data.table::fread()` for extreme speed. To read and merge multiple files from a folder:

```R
# Combine multiple file tables using do.call and rbind
file_paths <- list.files(path = "./raw_data", pattern = "*.csv", full.names = TRUE)
tables_list <- lapply(file_paths, read.csv)
merged_df <- do.call(rbind, tables_list)
```

---

## 🧑‍💻 Practice Exercises

### Exercise 1: Lists & Double Brackets
Extract the second element from this list and compute the mean of its values:
```R
qc_report <- list(
  sample_name = "Visium_HD_01",
  umi_counts = c(200, 450, 12, 90, 800),
  pass_status = TRUE
)
```

### Exercise 2: apply & Data Cleaning
You have a matrix containing gene expression values with missing items:
```R
test_data <- matrix(c(5, 10, NA, 2, 8, 12, 1, NA, 3), nrow = 3, ncol = 3)
```
1. Write code to replace all `NA` values in the matrix with `0`.
2. Use the `apply()` function to compute the median value of each column (margin 2).

---

### Solutions

<details>
<summary>Click to view solutions</summary>

#### Solution 1:
```R
# Extract using [[]]
counts <- qc_report[[2]]
mean(counts) # Output: 310.4
```

#### Solution 2:
```R
# 1. Replace NA with 0
test_data[is.na(test_data)] <- 0

# 2. Column-wise median
apply(test_data, 2, median) # Output: 5 8 1
```
</details>

---

### Next Modules
- Predecessor: [Lesson 5: R Programming Fundamentals](../FCWT_2026/lesson-05/lesson-05_study-notes.md)
- Continuation: [Module 1c: R Graphics and Statistics](./01c_R_Graphics_and_Statistics.md)
