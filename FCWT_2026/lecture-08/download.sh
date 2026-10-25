#!/usr/bin/env bash
#
# download.sh - Prepares minimal reference and FASTQ subset for Lecture 8.
#
# Usage (in 'mdd' environment):
#   bash download.sh
#   CONTIGS="21 22" bash download.sh
#   N_READ_PAIRS=3000000 bash download.sh

set -eu

# --- Config ---
CONTIGS="${CONTIGS:-17 21 22}"
N_READ_PAIRS="${N_READ_PAIRS:-5000}"
RUN="${RUN:-SRR8836894}"             # GSM3702795 (PC9 Control, GSE129221)
RELEASE=115
ASM="GRCh38"

OUT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/data"
mkdir -p "$OUT/ref" "$OUT/gtf" "$OUT/raw_fastq"

export GEM_PATH="${CONDA_PREFIX:-}/share/rubygems:${GEM_PATH:-}"

cleanup() {
    pkill -P $$ 2>/dev/null || true
    rm -f "$OUT/ref/"*.tmp "$OUT/gtf/"*.tmp "$OUT/raw_fastq/"*.tmp
    exit 1
}
trap cleanup SIGTERM SIGINT

# Configurable full reference paths (can be overridden via env vars)
PRIMARY_FA="${PRIMARY_FA:-$OUT/ref/Homo_sapiens.${ASM}.dna.primary_assembly.fa}"
FULL_GTF="${FULL_GTF:-$OUT/gtf/Homo_sapiens.${ASM}.${RELEASE}.gtf}"

# Auto-detect existing full FASTA if placed in data/ref
if [[ ! -s "$PRIMARY_FA" ]]; then
    detected_fa=$(ls "$OUT/ref"/Homo_sapiens.${ASM}.*.fa 2>/dev/null | grep -v 'chr' | head -n1 || true)
    [[ -n "$detected_fa" ]] && PRIMARY_FA="$detected_fa"
fi

# Auto-detect existing full GTF if placed in data/gtf (e.g. 115.gtf)
if [[ ! -s "$FULL_GTF" ]]; then
    detected_gtf=$(ls "$OUT/gtf"/Homo_sapiens.${ASM}.*.gtf 2>/dev/null | grep -v 'sub\.gtf' | head -n1 || true)
    [[ -n "$detected_gtf" ]] && FULL_GTF="$detected_gtf"
fi

# --- 1. Primary Assembly FASTA & Subset Extraction ---
setup_fasta() {
    # Check if all subset contig files already exist and are verified
    local all_cached=true
    for c in $CONTIGS; do
        local fa="$OUT/ref/chr$c.fa"
        if [[ ! -s "$fa" ]] || [[ $(stat -c%s "$fa") -lt 30000000 ]]; then
            all_cached=false
            break
        fi
    done

    if [[ "$all_cached" = true ]]; then
        echo "  [cached & verified] All contigs (chr $CONTIGS)"
        return
    fi

    # Step 1A: Ensure full primary assembly exists
    if [[ ! -s "$PRIMARY_FA" ]]; then
        echo "  [downloading] Full Primary Assembly FASTA from Ensembl (~840 MB)..."
        local url="https://ftp.ensembl.org/pub/release-${RELEASE}/fasta/homo_sapiens/dna/Homo_sapiens.${ASM}.dna.primary_assembly.fa.gz"
        curl -# -fL --retry 3 "$url" | gzip -dc > "$PRIMARY_FA.tmp"
        mv "$PRIMARY_FA.tmp" "$PRIMARY_FA"
    else
        echo "  [using local full FASTA] $(basename "$PRIMARY_FA")"
    fi

    # Step 1B: Ensure .fai index exists
    if [[ ! -s "${PRIMARY_FA}.fai" ]]; then
        echo "  [indexing] Building samtools faidx for $(basename "$PRIMARY_FA")..."
        samtools faidx "$PRIMARY_FA"
    fi

    # Step 1C: Extract requested contigs
    for c in $CONTIGS; do
        local fa="$OUT/ref/chr$c.fa"
        echo "  [extracting] chr$c from primary assembly..."
        samtools faidx "$PRIMARY_FA" "$c" > "$fa.tmp"
        mv "$fa.tmp" "$fa"
    done
}

# --- 2. Full GTF & Subset Extraction ---
setup_gtf() {
    local sub_gtf="$OUT/gtf/Homo_sapiens.${ASM}.sub.gtf"
    local last_contig
    last_contig=$(echo "$CONTIGS" | awk '{print $NF}')

    if [[ -s "$sub_gtf" ]] && grep -m1 -q "^${last_contig}[[:space:]]" "$sub_gtf"; then
        echo "  [cached & verified] $(basename "$sub_gtf")"
        return
    fi

    # Step 2A: Ensure full GTF exists
    if [[ ! -s "$FULL_GTF" ]]; then
        echo "  [downloading] Full GTF from Ensembl (~55 MB)..."
        local url="https://ftp.ensembl.org/pub/release-${RELEASE}/gtf/homo_sapiens/Homo_sapiens.${ASM}.${RELEASE}.gtf.gz"
        curl -# -fL --retry 3 "$url" | gzip -dc > "$FULL_GTF.tmp"
        mv "$FULL_GTF.tmp" "$FULL_GTF"
    else
        echo "  [using local full GTF] $(basename "$FULL_GTF")"
    fi

    # Step 2B: Slice requested contigs
    echo "  [filtering] Slicing chr $CONTIGS to $(basename "$sub_gtf")..."
    awk -v want="$CONTIGS" '
        BEGIN { n = split(want, c, " "); for (i = 1; i <= n; i++) keep[c[i]] = 1 }
        /^#/     { print; next }
        keep[$1] { print }
    ' "$FULL_GTF" > "$sub_gtf.tmp"
    mv "$sub_gtf.tmp" "$sub_gtf"
    echo "  [done] Filtered GTF created."
}

# --- 3. Subsampled FASTQ ---
# Compressed bytes to request per read pair. A 150 bp record is ~350 bytes
# uncompressed and compresses ~3.3x, so 200 is a safe upper estimate.
BYTES_PER_PAIR_GZ="${BYTES_PER_PAIR_GZ:-200}"
URL1="" URL2=""

# Fetch only the leading bytes of a remote gzip, keeping the first N reads.
# A truncated gzip still decompresses every record before the cut, so gzip -dc
# yields valid FASTQ and head -n does the subsetting.
take_prefix() {
    local url="$1" out="$2" want_lines="$3" want_bytes="$4"
    curl -fsSL --retry 3 -r "0-${want_bytes}" "$url" 2>/dev/null \
        | gzip -dc 2>/dev/null \
        | head -n "$want_lines" > "$out" || true
    [[ -s "$out" ]] && [[ $(wc -l < "$out") -eq "$want_lines" ]]
}

# Set URL1/URL2 for a run. ENA API first; deterministic ENA layout as fallback.
resolve_urls() {
    local run="$1"
    local ena_api="https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${run}&result=read_run&fields=fastq_ftp&format=tsv"
    local urls
    urls=$(curl -fsS --retry 2 "$ena_api" 2>/dev/null | awk -F'\t' 'NR==2 {print $2}' || true)

    if [[ "$urls" == *ftp.sra.ebi.ac.uk* ]]; then
        IFS=';' read -r u1 u2 <<< "$urls"
        URL1="https://$(echo "$u1" | sed -E 's|^[^/]+/||')"
        URL2="https://$(echo "$u2" | sed -E 's|^[^/]+/||')"
    else
        # Standard ENA layout for 10-character accessions (SRR + 7 digits)
        local base="https://ftp.sra.ebi.ac.uk/vol1/fastq/${run:0:6}/00${run: -1}/${run}"
        URL1="${base}/${run}_1.fastq.gz"
        URL2="${base}/${run}_2.fastq.gz"
    fi
}

download_reads() {
    local run="$1"
    local n_pairs="$2"
    local target_lines=$((n_pairs * 4))
    local want_bytes=$((n_pairs * BYTES_PER_PAIR_GZ))
    local fq1="$OUT/raw_fastq/${run}_R1.sub.fq"
    local fq2="$OUT/raw_fastq/${run}_R2.sub.fq"

    # Strict check: exact line count on both files
    if [[ -s "$fq1" && -s "$fq2" ]] && \
       [[ $(wc -l < "$fq1") -eq "$target_lines" ]] && \
       [[ $(wc -l < "$fq2") -eq "$target_lines" ]]; then
        echo "  [cached & verified] ${run}_R1.sub.fq & R2.sub.fq (${n_pairs} pairs)"
        return
    fi

    local raw1="$OUT/raw_fastq/${run}_1.fastq.gz"
    local raw2="$OUT/raw_fastq/${run}_2.fastq.gz"

    # Fast path: pull only the leading bytes we need instead of 3.8 GB.
    if [[ ! -s "$raw1" || ! -s "$raw2" ]]; then
        resolve_urls "$run"
        echo "  [ranged] Fetching first ~$((want_bytes / 1048576)) MB per mate..."
        if take_prefix "$URL1" "$fq1.tmp" "$target_lines" "$want_bytes" \
           && take_prefix "$URL2" "$fq2.tmp" "$target_lines" "$want_bytes"; then
            mv "$fq1.tmp" "$fq1"
            mv "$fq2.tmp" "$fq2"
            echo "  [done] ${n_pairs} pairs via HTTP range."
            return
        fi
        rm -f "$fq1.tmp" "$fq2.tmp"
        echo "  [fallback] Range came up short; fetching the full archive via ascli..."
    else
        echo "  [using local full FASTQ] $(basename "$raw1") & $(basename "$raw2")"
    fi

    if [[ ! -s "$raw1" || ! -s "$raw2" ]]; then
        resolve_urls "$run"
        echo "  [Aspera] Downloading full FASTQ via ascli..."
        ascli -Pera server download "${URL1#https://ftp.sra.ebi.ac.uk/}" --to-folder="$OUT/raw_fastq"
        ascli -Pera server download "${URL2#https://ftp.sra.ebi.ac.uk/}" --to-folder="$OUT/raw_fastq"
    fi

    echo "  [slicing] Subsetting first ${n_pairs} pairs..."
    gzip -dc "$raw1" | head -n "$target_lines" > "$fq1.tmp"
    gzip -dc "$raw2" | head -n "$target_lines" > "$fq2.tmp"

    # Verify sliced line count
    if [[ $(wc -l < "$fq1.tmp") -ne "$target_lines" ]] || [[ $(wc -l < "$fq2.tmp") -ne "$target_lines" ]]; then
        echo "Error: Sliced files do not match ${target_lines} lines. Aborting." >&2
        exit 1
    fi

    mv "$fq1.tmp" "$fq1"
    mv "$fq2.tmp" "$fq2"
    echo "  [done] Sliced ${n_pairs} pairs into .sub.fq; raw archives retained."
}

# --- Main Pipeline ---
main() {
    local start=$SECONDS

    echo "==> 1. Reference FASTA (Ensembl ${RELEASE}, ${ASM})"
    setup_fasta

    echo -e "\n==> 2. Filtered GTF"
    setup_gtf

    echo -e "\n==> 3. FASTQ via Aspera (${RUN})"
    download_reads "$RUN" "$N_READ_PAIRS"

    echo -e "\n==> Finished in $((SECONDS - start))s"
    echo "  Reference : $OUT/ref/chr*.fa"
    echo "  GTF       : $OUT/gtf/Homo_sapiens.${ASM}.sub.gtf"
    echo "  FASTQ     : $OUT/raw_fastq/${RUN}_R{1,2}.sub.fq"
}

main "$@"
