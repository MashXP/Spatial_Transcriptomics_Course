#!/bin/bash
# goal: run FastQC on the Lecture 8 reads
set -e

tar -xzf lecture-08-data.tar.gz
mkdir -p data/qc_raw
fastqc data/raw_fastq/*.fq -o data/qc_raw
