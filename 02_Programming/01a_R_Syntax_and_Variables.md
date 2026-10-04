# Module 1a: R Programming Fundamentals

> 🚀 **Interactive Google Colab Notebooks:** [Part 1: Syntax & Variables](./01a1_R_Syntax_and_Variables.ipynb) | [Part 2: Logic & Conditionals](./01a2_R_Logic_and_Conditionals.ipynb)
>
> 🤖 **How to Use AI in This Course:**  
> You are welcome to use AI as a tutor. You can ask AI: *"Can you explain what this line of code does in simple terms?"* or *"Why did I get this error?"*  
> Please do **not** use AI to copy-paste answers to the exercises. You are here to learn how to code, and you only learn by typing it yourself!

### 🎯 What You Will Learn Today (In Simple Words):
1. **Running Code:** How to run R code and write notes to yourself (comments).
2. **Variables:** How to save numbers and names into containers using `<-`.
3. **Data Types:** How R works with numbers, text (words), and TRUE / FALSE values.
4. **Bio-Math:** How to calculate basic cell numbers and gene counts.
5. **File Paths:** How to find where your files live on your computer.

## 🧬 0. Why Do Biologists Need R?

### Why Not Just Use Microsoft Excel?
Most people start analyzing data in Microsoft Excel. But in spatial transcriptomics—where we measure 20,000 genes across thousands of tissue spots—Excel causes serious problems:

1. **Excel Freezes and Crashes:** Excel can only hold ~1 million rows. Spatial data has tens of millions of data points. Excel simply cannot open these files without crashing.
2. **Excel Ruining Gene Names:** Excel tries to be "smart" and automatically converts gene names into dates! For example, the gene `SEPT2` (Septin 2) gets permanently converted into `2-Sep` (September 2nd). This error has corrupted thousands of published scientific papers!
3. **The "Click" Problem:** If you clean data by clicking buttons in menus, you cannot remember all 50 clicks you made two weeks from now. Your experiment cannot be repeated by others.

### Why R is Our Superpower:
* 🚀 **Handles Huge Data:** R easily processes millions of cells and gene measurements without slowing down.
* 📦 **Built for Biology (Bioconductor):** Biologists around the world have already written thousands of free, specialized tools for spatial data (like `SpatialExperiment`, `Seurat`, and `Voyager`).
* 📜 **A Reusable Recipe:** In R, your code is an exact recipe. You can re-run your entire analysis on a new patient sample in seconds with one click.

---

## 💻 Setting Up Your R Environment

You have two simple ways to run the code in this course:

### Option A: Google Colab (Zero Installation — Recommended for Beginners)
* Run R directly inside your web browser on Google cloud servers.
* Click the **[Open In Colab](./01a1_R_Syntax_and_Variables.ipynb)** badge at the top of this guide.
* Works instantly on any operating system without installing local software.

### Option B: Local Setup (On Your Own Computer with Micromamba & VS Code)
If you prefer running notebooks on your personal computer:
1. Open your terminal in the course directory.
2. Create the environment from `environment.yaml`:
   ```bash
   micromamba create -f environment.yaml
   ```
3. Register the R Jupyter kernel:
   ```bash
   micromamba run -n R_tutorial R -e 'IRkernel::installspec(prefix = Sys.getenv("CONDA_PREFIX"))'
   ```
4. Open the notebook in VS Code, click the **kernel button** in the top-right corner, and select **`R`**.

---

## 1. Syntax, Comments & Print

### Printing Output
To display text or values on the screen, use the `print()` function, or simply type the value in R:

```R
print("Hello World!")
# Output: "Hello World!"

5 + 5
# Output: 10
```

### Writing Comments
Comments are notes for humans. R completely ignores them. To write a comment, start the line with a hash symbol `#`:

```R
# This is a comment. R will not run this.
print("Hello!") # This prints Hello!
```

### Working Directory Management
To keep track of where files are read from and saved to, use these functions:
*   `getwd()`: Returns the current working directory path.
*   `setwd("path/to/folder")`: Sets a new working directory.
*   `dir()`: Lists all files and subdirectories in the current working directory.

```R
getwd() # Returns current directory path (e.g. "/home/mashxp/Project")
# setwd("/home/mashxp/Project/data") # Change directory
dir()   # List files in the directory
```

---

## 2. R Variables

A **variable** is a named container used to store data. In R, we assign values using the assignment operator `<-`:

```R
x <- 40
y <- 5
```

### Variable Names (Rules)
*   Must start with a letter (e.g., `cell_count`).
*   Can contain letters, numbers, dots `.`, and underscores `_`.
*   Cannot start with a number or underscore.
*   Are case-sensitive (`myVar` and `myvar` are different variables).

### Concatenating Elements
To join text strings together, use the `paste()` function:

```R
text1 <- "Spatial"
text2 <- "Transcriptomics"
full_text <- paste(text1, text2)
print(full_text)
# Output: "Spatial Transcriptomics"
```

### Assigning Multiple Variables
You can assign the same value to multiple variables in one line:

```R
var1 <- var2 <- var3 <- "GAPDH"
```

---

## 3. Data Types & Numbers

R has several basic data types. The most common are:

```
                  +-----------------------------------+
                  |         Basic Data Types          |
                  +-----------------------------------+
                                    |
          +--------------------------+--------------------------+
          |                          |                          |
    [ Numeric ]                [ Character ]               [ Logical ]
    (Decimal numbers)         (Text / Strings)            (TRUE or FALSE)
    Example: 10.5, 42          Example: "ACTB"            Example: TRUE, FALSE
```

*   **Numeric**: Decimal numbers (like `10.5` or `42`).
*   **Integer**: Whole numbers without decimals. In R, add an `L` after the number (e.g., `42L`).
*   **Character**: Text strings enclosed in quotes (like `"GAPDH"`).
*   **Logical (Boolean)**: Either `TRUE` or `FALSE`.
*   **Complex**: Handles complex numbers (e.g., `3 + 2i`).
*   **Special Values**:
    *   `NA`: Missing or unavailable data.
    *   `NaN`: "Not a Number" (e.g., undefined results like `0/0`).
    *   `Inf` and `-Inf`: Infinity and negative infinity (e.g., `5/0`).

```R
# Check the type of a variable using class()
class(10.5)     # "numeric"
class(5L)       # "integer"
class("Hello")  # "character"
class(TRUE)     # "logical"
```

### Data Coercion
If you combine different data types together (e.g., in a vector), R will automatically convert ("coerce") them to the most flexible type (logical -> integer -> numeric -> character):

```R
# Coercion: TRUE becomes 1 (numeric), character dominates both
mixed_vector <- c(TRUE, 42, "GAPDH")
class(mixed_vector) # Output: "character" (everything became text)
```

### Vector Recycling Rule
When performing operations on two vectors of unequal lengths, R will repeat ("recycle") the shorter vector to match the longer one. If the longer length is not a multiple of the shorter length, R will print a warning, but still execute the calculation:

```R
vec1 <- c(1, 2, 3, 4)
vec2 <- c(10, 20)

vec1 + vec2
# vec2 is recycled to match the length of vec1: c(10, 20, 10, 20)
# Output: 11 22 13 24
```

---

## 4. R Math Functions & Arithmetic Operators

R comes equipped with standard mathematical operators and built-in functions:

| Operator / Function | What It Does | Biological Code Example |
| :--- | :--- | :--- |
| `+` | Addition | `tot_reads <- 12000 + 3500` |
| `-` | Subtraction | `bg_spots <- 4992 - 3820` |
| `*` | Multiplication | `mito_pct <- 0.074 * 100` |
| `/` | Division | `depth_scale <- 45 / 15000` |
| `^` | Exponentiation (power) | `fc <- 2^3` |
| `%%` | Modulo (remainder) | `batch_rem <- 10 %% 3` |
| `%/%` | Integer division | `cohort_grp <- 10 %/% 3` |
| `sqrt()` | Square root | `spot_dist <- sqrt(144)` |
| `log2()` | Log base 2 | `log2_fc <- log2(8)` |
| `round()` | Round decimals | `pval <- round(0.003412, 3)` |

---

## 5. Strings & Escape Characters

A string is used to store text. Strings must be enclosed in single or double quotes.

### Escape Characters
If you need to include quotes, new lines, or tab spacing inside a string, use backslash `\` escape sequences:
*   `\"`: Double quote
*   `\n`: New line
*   `\t`: Tab space

```R
# Including quotes inside quotes
quote_text <- "The gene was named \"GAPDH\" by scientists."
cat(quote_text) # cat() renders the escape characters properly
# Output: The gene was named "GAPDH" by scientists.
```

---

## 6. R Operators

Operators are symbols used to perform actions on values.

### A. Arithmetic Operators
*   `+` (Addition): `x + y`
*   `-` (Subtraction): `x - y`
*   `*` (Multiplication): `x * y`
*   `/` (Division): `x / y`
*   `^` (Exponent): `x^y`

### B. Comparison Operators (Result is always `TRUE` or `FALSE`)
*   `==` (Equal to): `x == y`
*   `!=` (Not equal to): `x != y`
*   `>` (Greater than): `x > y`
*   `<` (Less than): `x < y`
*   `>=` (Greater than or equal to): `x >= y`
*   `<=` (Less than or equal to): `x <= y`

### C. Logical Operators
*   `&` (Logical AND): Returns `TRUE` if both conditions are true.
*   `|` (Logical OR): Returns `TRUE` if at least one condition is true.
*   `!` (Logical NOT): Reverses the logical state (turns `TRUE` to `FALSE`).

```R
x <- 10
y <- 20

(x > 5) & (y < 30) # TRUE & TRUE   -> TRUE
(x > 15) | (y < 30) # FALSE | TRUE -> TRUE
!(x == 10)          # !TRUE        -> FALSE
```

---

## 7. Control Flow (If...Else, Loops)

> **The Problem:** What if you only want to analyze genes with expression values greater than 50 and skip the rest? Or what if you need to run the same analysis script on 100 different cells? Writing the code manually 100 times is slow and prone to copy-paste errors.
>
> **The Solution:** **Control flow structures** (`if-else` and loops) let you check conditions and automate repetitive calculations.

### A. If...Else Statements
Used to run code blocks based on conditions.

```R
expression_val <- 450

if (expression_val > 500) {
  print("High Expression")
} else if (expression_val >= 100) {
  print("Medium Expression")
} else {
  print("Low Expression")
}
# Output: "Medium Expression"
```

### B. While Loops
A `while` loop runs code as long as a condition remains `TRUE`:

```R
count <- 1
while (count <= 3) {
  print(paste("Loop index:", count))
  count <- count + 1 # Increase count by 1 to prevent infinite loop
}
# Output:
# "Loop index: 1"
# "Loop index: 2"
# "Loop index: 3"
```

### C. For Loops
A `for` loop is used to iterate over a list or vector of items:

```R
genes <- c("GAPDH", "ACTB", "CD8A")
for (g in genes) {
  print(paste("Analyzing:", g))
}
# Output:
# "Analyzing: GAPDH"
# "Analyzing: ACTB"
# "Analyzing: CD8A"
```

#### Loop Control: Next & Break
*   `next`: Skips the current iteration of a loop and moves to the next one.
*   `break`: Exits the loop entirely.

```R
# Skip 3 and exit the loop when number exceeds 4
for (i in 1:6) {
  if (i == 3) {
    next
  }
  if (i > 4) {
    break
  }
  print(i)
}
# Output:
# 1
# 2
# 4
```

#### Nested Loops
You can place a loop inside another loop:

```R
for (row in 1:2) {
  for (col in 1:2) {
    print(paste("Row:", row, "Col:", col))
  }
}
```

---

## 🧑‍💻 Practice Exercises

### Exercise 1: Variables and Math
1. Assign the value `150L` to a variable named `gene_count` and verify its data type class.
2. Calculate the square root of `225` and round the decimal number `12.6` down to the nearest integer.

### Exercise 2: Conditional Logic & Loops
1. Write a `for` loop that iterates through numbers `1` to `6`.
2. For each number, if the number is even (divisible by 2, e.g., `num %% 2 == 0`), print "Even: [number]". If it is odd, print "Odd: [number]".
3. Use the `next` statement to skip the number `4` entirely.

---

### Solutions

<details>
<summary>Click to view solutions</summary>

#### Solution 1:
```R
# 1. Type verification
gene_count <- 150L
class(gene_count) # "integer"

# 2. Math calculations
sqrt(225)   # 15
floor(12.6) # 12
```

#### Solution 2:
```R
for (num in 1:6) {
  if (num == 4) {
    next
  }
  if (num %% 2 == 0) {
    print(paste("Even:", num))
  } else {
    print(paste("Odd:", num))
  }
}
# Output:
# "Odd: 1"
# "Even: 2"
# "Odd: 3"
# "Odd: 5"
# "Even: 6"
```
</details>

---

### Next Modules
- Continuation: [Module 1b: R Data Manipulation](./01b_R_Data_Manipulation.md)
- Continuation: [Module 1c: R Graphics and Statistics](./01c_R_Graphics_and_Statistics.md)
