# Lecture 10 demo — two scripts, one pipeline

The point of this folder: save the work as **scripts**, numbered in run order, so
anyone can rebuild everything from the raw reads on a fresh machine.

## What is in here

- `01_raw_fastqc.sh` — FastQC on the raw reads → `data/qc_raw/`
- `02_analyse.R` — mean TPM per gene → `results/mean_tpm.csv` + `results/mean_tpm.png`
- `data/counts/counts.tsv` — the real input: 39,376 genes × 12 samples, downloaded, not committed
- `data/raw_fastq/`, `data/gtf/`, `data/ref/` — unpacked by script 1, read-only
- `results/` — generated figures and tables
- `lecture-08-data.tar.gz` — the archive script 1 unpacks

## Get the data

Download the Lecture 8 data folder:
<https://drive.google.com/file/d/1RCf4kJOXrEvZdOjLWc18GdRdHdcq6D2S/view?usp=drive_link>

Unzip it and keep `lecture-08-data.tar.gz` next to the two scripts. It unpacks its
own `data/` folder, so the archive itself stays outside `data/`.

Counts: download by hand from GEO. Open
<https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE129221>, get
`GSE129221_raw_counts_GRCh38.p13_NCBI.tsv.gz` from the supplementary files, unzip
it, and rename the result to `data/counts/counts.tsv`.

## Run it

```bash
micromamba create -f environment.yml   # builds env "demo"
micromamba activate demo               # fastqc, R, ggplot2
bash 01_raw_fastqc.sh
Rscript 02_analyse.R
```

Expected: 4 FastQC reports in `data/qc_raw/`, a 20-row CSV and one bar chart in
`results/`. The top gene is `4512` at **28,176** mean TPM.

## Rules this demo follows

- Raw input is **read-only**: scripts read `data/`, never edit it.
- Generated files are **not committed** — see `.gitignore`. Anyone can rebuild them.
- One file, one job, run in numeric order.
