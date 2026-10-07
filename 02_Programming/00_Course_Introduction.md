# Programming for Spatial Transcriptomics: Course Introduction

Welcome to the **Programming for Spatial Transcriptomics** track. This course is designed to equip you with the essential computational skills required to process, analyze, and visualize high-resolution spatial transcriptomics data. 

Spatial Transcriptomics (STx) is an interdisciplinary field bridging wet-lab biology, upstream genomics pipelines, R/Bioconductor bioinformatics, and spatial statistics. While understanding the biology is critical, performing the analysis requires a robust foundation in programming, environment management, version control, and coding best practices.

---

## 🗺️ Course Syllabus Map

This module contains six core chapters, structured sequentially to take you from a programming novice to a bioinformatician capable of managing reproducible research workflows.

1. **R Programming Track**
   * **[01a. R Programming Fundamentals](./01a_R_Syntax_and_Variables.md)**: Master base syntax, comment notes, variable rules, operators, math/string helpers, data types, recycling rules, and working directory management.
   * **[01b. R Data Manipulation](./01b_R_Data_Manipulation.md)**: Explore data structures (vectors, lists, matrices, data frames, factors), list indexing (`[[]]`), regular expressions (`grep`, `sub`), missing data cleaning, the vectorized `apply` family, custom functions, and fast I/O (`fread`).
   * **[01c. R Graphics and Statistics](./01c_R_Graphics_and_Statistics.md)**: Reshape tables (`melt`), generate base R and `ggplot2` plots (boxplots, density curves, volcano plots, heatmaps), export graphics (`pdf()`), check normality assumptions (Shapiro-Wilk), choose statistical tests, run correlations, model linear regressions, and practice proactive programming.
2. **[02. Git and GitHub for Reproducible Science](./02_Git_and_GitHub.md)**
   * Establish a solid version control workflow. Learn to track changes, manage branches (create, checkout, merge, delete), authenticate securely using SSH keys or PAT tokens, and protect large datasets with `.gitignore` files.
3. **[03. Good Coding Practices](./03_Good_Coding_Practices.md)**
   * Transition from writing "spaghetti code" to clean, modular, and well-documented scripts. Learn naming conventions, Roxygen2, and basic defensive programming.
4. **[04. Environment Setup & Google Colab](../FCWT_2026/Environment_Setup.md)**
   * Build reproducible computing environments using `micromamba` and `uv`, run terminal commands in the cloud using Google Colab's shell operator (`!`), format equations in LaTeX, and run multi-language R code magic (`%%R`).
5. **[05. Project Structure & Timeline](./05_Project_Structure.md)**
   * Design standardized directories for your raw data, scripts, and results, 
6. **[06. Course Announcement & Communication Templates](./06_Communications_Template.md)**
   * Access customizable email and syllabus proposal templates to announce the course to students or academic coordinators.

---

## 📅 Course Milestones Timeline (2-Week Track: 2 Hours/Week, 1 Lesson/Week)

Here is the weekly agenda for our 2-week course:

*   **Week 1: Lesson 1 (2 Hours) — R Fundamentals & Data Manipulation**
    *   **Agenda**:
        *   **Hour 1: R Syntax, Operators, and Basic Control Flow** (corresponds to [Module 1a](./01a_R_Syntax_and_Variables.md))
            *   Print outputs, write comments, variable naming, data types (Special values `NA`/`NaN`/`Inf`), coercion, and recycling rules.
            *   Operators (arithmetic, logical, comparison), if-else, while loops, for loops (loop controls `next`/`break`), and directory commands (`getwd`, `setwd`).
        *   **Hour 2: R Data Structures & Functional Manipulations** (corresponds to [Module 1b](./01b_R_Data_Manipulation.md))
            *   Vectors, Lists (nested index `[[]]`), Matrices, Arrays, Data Frames, and Factors.
            *   String manipulation regex (`grep`, `sub`, `gsub`, `toupper`, `tolower`, `nchar`).
            *   Data cleaning (NA handling, `complete.cases()`), custom functions, fast I/O (`fread()`), and directory-wide table merging.
    *   **Weekly Goal**: Write structured, clean code to clean large biological datasets and manipulate nested lists/tables.

*   **Week 2: Lesson 2 (2 Hours) — Graphics, Statistics, Version Control & Environments**
    *   **Agenda**:
        *   **Hour 1: Reshaping, Scientific Plotting & Assumptive Statistics** (corresponds to [Module 1c](./01c_R_Graphics_and_Statistics.md))
            *   Data reshaping (`melt`), exploratory Base R plotting (step/both lines, dot charts, density curves), ggplot2 volcano plots, and FDR corrections (`p.adjust(method="BH")`).
            *   Descriptive statistics, normality checking (Shapiro-Wilk test, QQ-plots), test selection logic (parametric t-test/ANOVA vs Wilcoxon/Kruskal-Wallis), correlation coefficients, linear regression modeling, and PCA/unsupervised clustering (`prcomp()`, `kmeans()`, `hclust()`).
        *   **Hour 2: Version Control, Good Code, and Setup** (corresponds to [Module 2](./02_Git_and_GitHub.md), [Module 3](./03_Good_Coding_Practices.md), and [Module 4](../FCWT_2026/Environment_Setup.md))
            *   Git version control (Working, Staging, commits, remote push/pull) and branching/merge collaboration strategy (pointer, local/remote branch deletion).
            *   SSH keys and PAT security tokens authentication; `.gitignore` rules for biological files.
            *   snake_case naming, Roxygen2 docs, Google Colab notebooks (Bash shell commands `!`, R magic `%%R`, LaTeX equations), Micromamba, `uv` environments, and path resolution using `here`.
    *   **Weekly Goal**: Run advanced statistical assays and export publication-ready plots from reproducible, git-versioned pipeline tools.
---


## 🛠️ Prerequisites & Setup

No prior programming experience is assumed. However, to get the most out of this course, you will need:
* A web browser to access Google Colab.
* A GitHub account for version control exercises.
* A terminal shell (preferably Fish, though Bash/Zsh are common) to practice command-line workflows.

Let's begin by diving into **[Module 1a: R Programming Fundamentals](./01a_R_Syntax_and_Variables.md)**.
