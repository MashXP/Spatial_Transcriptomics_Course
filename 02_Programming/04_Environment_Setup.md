# Module 4: Environment Setup & Google Colab

Imagine you download a beautiful script to analyze single-cell data, but it immediately crashes with: `Error: package 'Seurat' is version 4.0 but version 5.0 is required`. You update `Seurat`, but that breaks a second script you run daily. Now, none of your tools work, and your local package installation is corrupted.

This is "dependency hell." **Isolated Environments** solve this by creating separate, independent toolboxes for each project so packages never conflict. In this chapter, we will learn how to run code instantly in the cloud using **Google Colab** and how to manage local environments on your machine using **Micromamba** and **uv**.

---

## 1. Introduction to Google Colab (Run R Instantly in the Cloud)

**Google Colab** (short for Collaboratory) is a free service provided by Google that lets you write and run code directly in your web browser. 

It is ideal for beginners because:
*   **No Installation Needed**: You do not have to install R, RStudio, or Python on your computer.
*   **Free Access**: You run code on Google's cloud servers (which also include hardware accelerators like GPUs/TPUs).
*   **Shareable**: Colab notebooks save to your Google Drive and can be shared like Google Docs.

---

### A. How a Colab Notebook is Structured

A Colab document is called a **Notebook**. It is composed of two types of boxes, called **Cells**:

1.  **Code Cells**: Where you write R code. Each code cell has a small circle **Play button** (or `[ ]`) on its left. Clicking it runs the code.
2.  **Text Cells**: Where you write notes, headings, and descriptions using simple Markdown.

```
+-------------------------------------------------------------+
|  [Play]  total_spots <- 150                                 |  <-- Code Cell
|          print(total_spots)                                 |
+-------------------------------------------------------------+
|                                                             |
|  ## Quality Control Diagnostics                             |  <-- Text Cell
|  We will now filter the low count spots from our dataset.   |
+-------------------------------------------------------------+
```

---

### B. Steps to Start and Run Your First R Notebook

1.  **Open an R Notebook**: Click the link 👉 **[colab.to/r](https://colab.to/r)** to start a blank R notebook.
2.  **Add a Code Cell**: Click the `+ Code` button at the top left of the screen.
3.  **Write and Run Code**:
    *   Inside the new cell, type:
        ```R
        message <- "My first line of code in Google Colab!"
        print(message)
        ```
    *   Press the **Play** button on the left of the cell, OR press the keyboard shortcut **`Ctrl + Enter`** (Windows) or **`Cmd + Enter`** (Mac).
    *   The output will print directly underneath the cell.

---

### C. Useful Keyboard Shortcuts
*   `Ctrl + Enter` (or `Cmd + Enter`): Run the active cell.
*   `Shift + Enter`: Run the active cell and automatically move to the next cell.
*   `Alt + Enter` (or `Option + Enter`): Run the active cell and insert a new blank code cell below it.
*   `Ctrl + M B`: Insert a new code cell below the current cell.
*   `Ctrl + M Y`: Toggle the current cell format to a Code cell.
*   `Ctrl + M M` (or `Ctrl + M T`): Toggle the current cell format to a Text (Markdown) cell.

---

### D. Uploading Data Spreadsheets to Colab

If you want to read a CSV dataset inside Colab, you need to upload it first:
1.  Click the **Folder icon** 📁 on the left sidebar to open the Files panel.
2.  Drag and drop your `metadata.csv` or expression count files into the file panel list.
3.  Right-click the uploaded file, select **Copy path**, and paste it into your `read.csv()` function:
    ```R
    # Load the uploaded file in Colab
    my_data <- read.csv("/content/metadata.csv")
    ```

> [!WARNING]
> Files uploaded this way are **temporary**. If your browser disconnects or stays idle, Google Colab will reset the server and delete your uploaded files. To save files permanently, upload them to your Google Drive and click the **Mount Drive** icon in the Files panel to connect Colab to your Drive folder.

---

### E. Installing & Loading Packages in Colab
Colab comes with hundreds of popular R packages pre-installed. If a package is missing, install it using `install.packages()`:

```R
# 1. Install the ggplot2 plotting library (Run once)
install.packages("ggplot2")

# 2. Load the library to use it in your code
library(ggplot2)
```

---

### F. Colab Resources & Pro Runtime Settings
*   **System Resource Monitoring**: On the top-right toolbar, you can monitor your runtime hardware usage. The free tier allocates approximately **12GB RAM** and **100GB Disk storage**.
*   **Changing Runtime Type**: You can change the base programming language runtime at any time. Go to **Runtime -> Change runtime type** in the top menu and choose between **Python** or **R**.
*   **Colab Pro**: For large datasets, Colab Pro provides access to high-RAM runtimes and GPUs/TPUs using "compute units" on a subscription basis.

---

### G. Running Terminal Commands (Bash Integration)
In bioinformatics, you frequently need to run terminal/shell scripts. You can run any Bash command directly inside a Colab cell by prefixing the line with an exclamation mark `!`:

```bash
# Print a message to the console
!echo "Running terminal commands inside Colab"

# View files and search using grep
!ls -la /content | grep metadata.csv
```

---

### H. Multi-Language R Magic Support
If you prefer to work inside a Python environment but still want to run R code, you can use R magic commands without switching the runtime:

```python
# 1. Load the rpy2 R interface extension in a Python cell
%load_ext rpy2.ipython

# 2. Execute R code in a cell by prefixing it with %%R
%%R
library(ggplot2)
print("This R script is running inside a Python runtime!")
```

---

### I. Mathematical LaTeX Formatting in Markdown
Text cells support mathematical notation rendering using LaTeX syntax. Wrap equations in single `$` for inline math or double `$$` for block equations:

```
Calculate log-transformed expression with offset:
$$y = \log_2(x + 0.1)$$
```

---

## 2. Local Setup: Micromamba (Your R Package Installer)

> **The Problem:** You need to share your bioinformatics script with a colleague. They try to run it but get compilation errors because they have a different version of R or are missing required libraries on their machine.
>
> **The Solution:** An **`environment.yml` configuration file** allows package managers to build an identical local environment toolbox on any computer, ensuring your code works exactly the same way.

If you are running R on your own machine, you need a package manager. We use **Micromamba** because it is extremely fast and lightweight.

Think of Micromamba as an App Store for bioinformatic tools. You tell it what you want, and it installs everything for you inside a specific environment.

### A. The Environment File (`environment.yml`)
Instead of typing commands to install packages one by one, we write a list of what we need in a simple text file named `environment.yml`:

```yaml
name: spatial_basics
channels:
  - conda-forge
  - defaults
dependencies:
  - r-base=4.3.0
  - r-ggplot2
  - r-matrix
```

### B. Commands to Manage Environments (Fish Shell Compatible)
Here are the essential commands to create, update, and remove your toolbox:

```fish
# 1. Create your toolbox using the environment file
micromamba create -f environment.yaml

# 2. Register the R kernel for Jupyter & VS Code (run once after creation)
micromamba run -n spatial_basics R -e 'IRkernel::installspec(user = TRUE)'

# 3. Enter (activate) your toolbox
micromamba activate spatial_basics

# 3. Update an existing environment when you add new packages to environment.yaml
micromamba update -n spatial_basics -f environment.yaml --prune

# 4. Leave (deactivate) your toolbox when you are done
micromamba deactivate

# 5. List all environments installed on your system
micromamba env list

# 6. Remove (delete) an environment completely when no longer needed
micromamba env remove -n spatial_basics

# 7. Remove unused packages and cached archives (⚠️ ONLY USE IF RUNNING OUT OF SPACE!)
micromamba clean --all
```

> [!CAUTION]
> **Disk Space Emergency Cleanup (`micromamba clean --all`):**  
> **Only use this if you are running out of storage space!** This command deletes all cached installer tarballs and unused packages from your drive. While it frees up gigabytes of disk space, any future environment setups will need to re-download packages over the internet instead of reusing local caches.

---

## 3. Local Setup: uv (Your Python Package Installer)

Sometimes spatial transcriptomics tools are written in Python instead of R. To manage Python packages quickly, we use a tool called **`uv`**.

```fish
# 1. Create a Python virtual environment folder named .venv
uv venv .venv

# 2. Activate the virtual environment (tells your shell to use this toolbox)
source .venv/bin/activate.fish

# 3. Install a Python package (example: pandas for spreadsheet manipulation)
uv pip install pandas
```

### Quick Python Alias
If you have a Python script `script.py` and want to run it without activating the virtual environment, you can run it directly:
```fish
# Run script using the local virtual environment Python
./.venv/bin/python script.py
```

---

## 🧑‍💻 Hands-On Practice Examples & Exercises

### Exercise 1: Build a Custom Environment File
Write an `environment.yml` file to create a toolbox named `my_first_env` containing:
1. R version 4.3.0
2. The `r-ggplot2` package
3. The `r-cowplot` package (a package used to combine multiple plots together)
Then, write out the Fish shell commands to create and enter this environment.

### Exercise 2: Python environment via `uv`
Write down the Fish shell commands to:
1. Create a new Python virtual environment.
2. Activate it.
3. Install the Python package named `numpy`.

---

### Solutions

<details>
<summary>Click to view solutions</summary>

#### Solution 1: Micromamba setup
Create a file named `environment.yml` with this content:
```yaml
name: my_first_env
channels:
  - conda-forge
  - defaults
dependencies:
  - r-base=4.3.0
  - r-ggplot2
  - r-cowplot
```

Fish commands:
```fish
# Create the environment
micromamba create -f environment.yml

# Activate it
micromamba activate my_first_env
```

#### Solution 2: Python setup
```fish
# Create venv
uv venv .venv

# Activate in Fish
source .venv/bin/activate.fish

# Install numpy
uv pip install numpy
```
</details>
