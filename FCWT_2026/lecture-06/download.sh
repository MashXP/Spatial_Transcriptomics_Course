#!/usr/bin/env bash
set -euo pipefail 


OUT_DIR="./counts"
mkdir -p "$OUT_DIR"

curl -o "$OUT_DIR/counts.tsv.gz" \
  "https://www.ncbi.nlm.nih.gov/geo/download/?type=rnaseq_counts&acc=GSE129221&format=file&file=GSE129221_raw_counts_GRCh38.p13_NCBI.tsv.gz"

gunzip -f "$OUT_DIR/counts.tsv.gz"

echo "File downloaded at $OUT_DIR/counts.tsv:"
ls -lh "$OUT_DIR"

echo "Head of the file:"
head -n 5 "$OUT_DIR/counts.tsv"