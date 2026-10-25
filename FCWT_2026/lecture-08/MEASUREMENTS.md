# STAR Lecture 8 — measurements

Environment: STAR 2.7.10b, 16 threads, no `--limitGenomeGenerateRAM`.
Reference: GRCh38 chr17/21/22 = 180,785,892 bp. Reads: 1.5 M pairs (150 bp).

## genomeGenerate

| | value |
|---|---|
| wall | **77.2 s** |
| peak RSS | **4.10 GB** |
| cpu | user 703 s |
| index on disk | 1.7 GB (Genome 189M, SA 1.4G, SAindex 94M, junction tables ~15M) |
| annotated junctions | 53,545 (from 44,417 transcripts) |

`--genomeSAsparseD 1` roughly doubled SA (1.4 GB vs 638 MB at sparseD 2) — the
memory-for-speed trade, deliberately spent because Colab has ~11.8 GB free.

## alignReads — peak memory does NOT scale with read count

| input | wall | **peak RSS** | unique mapped |
|---|---|---|---|
| 100 read pairs | ~1 s | — | 13.00% |
| 5,000 pairs | **23.1 s** | **3.18 GB** | 10.86% |
| 50,000 pairs | **214.9 s** | **3.18 GB** | — |
| 1.5 M pairs | ~1.8 h (est.) | — | — |

**A 10x increase in reads produced byte-identical peak RSS.** Alignment memory is
set by the index (3.18 GB, mostly the 1.7 GB index plus 53k junctions loaded into
RAM), not by how many reads are streamed through it. Read count is purely a
*time* cost; it can never be a memory cost.

This is why the RAM budget was never a real constraint:

| step | peak RSS | budget | binding constraint |
|---|---|---|---|
| genomeGenerate | 4.10 GB | 10 GB | CPU |
| alignReads | 3.18 GB (constant) | 11.8 GB | read count -> time |

**13% unique mapping is correct, not a bug.** The reads are whole-transcriptome
RNA-seq across all 24 chromosomes; the index holds only chr17/21/22 (~5.8% of
the genome). Evidence:

- 25-mers from the first reads: 0 hits in our 3-chromosome reference
- read GC 49.7%, reference GC 40.0% — both normal for human, so not a
  species or quality problem

The slowness is the same fact seen from the other side: **~87% of reads are
unmappable**, and each unmappable read must run an exhaustive seed search over
the index before STAR discards it. Parameter tuning cannot fix that; only the
dataset choice can.

## Options for the lecture

1. **Subset reads to chr17/21/22 genes** — mapping rate jumps to ~85-90%, and
   alignment becomes fast. Needs a step that selects reads by gene, which is
   circular (you need an alignment to know the gene).
2. **Accept ~13%** and present it honestly as the cost of a reduced reference.
   Alignment stays slow.
3. **Reduce read depth** for the demo (e.g. 150 k pairs instead of 1.5 M) so the
   exhaustive search is 10x cheaper, and say why.
4. **Add `--outFilterType BySJout`** — does NOT help unmapped reads; they still
   must be searched.

### How this resolved

Option 3 was taken, at a smaller depth than proposed: **5,000 read pairs**, not
150,000. The depth sweep below shows mapping rate is flat in depth, so the extra
reads would have cost hours of CPU and bought nothing. Option 2 stands as the
stated consequence: ~11% unique mapping is the honest result of a
three-chromosome reference.

Option 1 was rejected as circular, as predicted. Option 4
(`--outFilterType BySJout`) *was* adopted — for parity with
`mdd_RNAseq_pipeline/01_core_alignment/05_star_align.sh` — but it does not rescue
unmappable reads, exactly as option 4 said it would not.

---

# Full benchmark log — 2026-10-17

Everything below was measured from surviving artifacts (STAR `Log.final.out`,
`Log.out`, `genomeParameters.txt`, `samtools flagstat`, featureCounts output,
ENA). Where an earlier number could not be re-verified it is marked as such.

## 1. What actually ships

| | |
|---|---|
| reference | GRCh38 chr17/21/22, **180,785,892 bp = 5.85%** of the genome |
| | chr17 83,257,441 · chr21 46,709,983 · chr22 50,818,468 |
| annotation | GENCODE-style GTF, 6,661 genes / 44,417 transcripts / 329,671 exons |
| reads | **5,000 pairs = 10,000 reads**, 150 bp each |
| upload artifact | `lecture-08-data.tar.gz`, **57,779,840 bytes (56 MB)** |
| index | built in the notebook, **not** shipped — see §3 |

Read length verified directly from the FASTQ: R1 and R2 are both uniformly 150 bp.

## 2. genomeGenerate — re-verified

| | value |
|---|---|
| wall | **77.2 s** |
| peak RSS | **4.10 GB** |
| index on disk | **1.7 GB** total |
| ├ `Genome` | 197,151,459 B (188 MiB) |
| ├ `SA` | 1,469,531,022 B (1.37 GiB) |
| └ `SAindex` | 97,867,203 B (93 MiB) |
| annotated junctions | **53,545** (from 44,417 transcripts) |
| recorded params | `--genomeSAindexNbases 12`, `--genomeSAsparseD 1`, `--sjdbOverhang 149` |

`genomeSAindexNbases 12` is STAR's own recommendation for a ~181 Mb genome; the
default 14 seg-faults at mapping time on a subset this small.

## 3. Compression — why the index is not in the tarball

Measured with `gzip -9` on the real files:

| file | raw | gzipped | ratio |
|---|---|---|---|
| FASTQ (1.5 M pairs) | 498,777,792 | 112,314,959 | **4.4×** |
| GTF | 299,910,569 | 9,545,049 | **31.4×** |
| FASTA | 183,799,004 | 47,281,129 | **3.9×** |
| **`SA` (suffix array)** | 1,469,531,022 | 1,444,207,404 | **1.01×** |

The suffix array is already a dense binary and **does not compress**. Shipping it
would take the tarball from **56 MB to ~1.5 GB**, and rebuilding costs 77 s
locally / 25 min in Colab. Rebuilding in the notebook is the right trade, and the
tarball is 30× smaller without it.

## 4. Reference size trades index time, not alignment time

| index | wall (genomeGenerate) | align 5,000 pairs | unique |
|---|---|---|---|
| chr17 only | 22 s | ~24 s | **7.82%** |
| chr17/21/22 | **77 s** | 23–29 s | **10.86%** |

Alignment time is **flat** across reference sizes, because ~89% of reads are
unmappable no matter what, and each unmappable read pays a full exhaustive seed
search regardless. Cutting the reference buys index-build time only, and costs
mapping rate. This is why 3 chromosomes are kept.

(A 2-chromosome chr17+21 point measured at 33 s / 8.74% during the sweep; that
log did not survive, so it is not in the table above.)

## 5. Depth does NOT move the mapping rate

Same 3-chromosome index, the notebook's exact flags:

| depth | wall | input reads | unique | multi-mapped | splices |
|---|---|---|---|---|---|
| 5,000 pairs | 23 s | 5,000 | **11.06%** | 1.24% | 443 |
| 20,000 pairs | 94 s | 20,000 | **11.96%** | 1.14% | 1,868 |
| 50,000 pairs | 216 s | 50,000 | **11.58%** | 1.09% | 4,398 |

11.06 → 11.96 → 11.58 is **non-monotonic**, which is the signature of sampling
noise around a fixed value, not of a depth effect. Expected standard errors at
p ≈ 0.11 are ±0.44% (5 k), ±0.22% (20 k), ±0.14% (50 k) — all three sit within
~1 SE of each other.

The mapping rate is set by *which genes are expressed* versus *which chromosomes
we indexed*. It is a property of the reference choice, not of sample size.

**This is the measurement that justifies shipping 5,000 pairs.** At ±0.44% the
estimate already supports the claim "~11%", and the next 45,000 pairs would have
cost ~4 more minutes of CPU for no change in the number.

## 6. End-to-end run in Colab — the numbers students will see

Environment measured in the Colab runtime:

| | |
|---|---|
| Python | 3.13.16 |
| vCPU | 2 |
| RAM available | 11.8 GB (88 GB disk free) |
| glibc | 2.39 |
| `apt` STAR | rna-star **2.7.11b** |
| `apt` samtools | **1.19.2** |
| `apt` subread | **2.0.6** |

| step | wall |
|---|---|
| `genomeGenerate` | **24 min 55 s** (SA sort alone 21 min 16 s = 85%) |
| `alignReads`, 5,000 pairs | **83 s** (00:52:42 → 00:54:05) |

The index build, not the alignment, is what makes the notebook slow: **25 min
versus 83 s**, a 17× difference on the two steps students actually wait for.

A per-core speed comparison is *not* derivable from these two runs — the local
alignment used 16 threads and the Colab run used 2 — so no such ratio is claimed
here.

`genomeGenerate` produced `versionGenome 2.7.4a` locally, which 2.7.11b reads
without complaint — forward-compatible.

## 7. QC output

```
Number of input reads   | 5000
Uniquely mapped reads % | 11.06%
Number of splices: Total | 443
```

```
1472 in total        1230 primary        242 secondary
0 duplicates        0 supplementary     0 singletons
1230 properly paired (100.00%)
615 read1            615 read2
```

```
chr17    830
chr21    378
chr22    264
```

**830 + 378 + 264 = 1,472**, exactly the flagstat total. That arithmetic closing is
the best single end-to-end check in the notebook.

Note the two rates measure different denominators: STAR's 11.06% is over all
5,000 input reads; flagstat's 100% is over the 1,472 records that reached the
BAM. They are not in contradiction.

The 242 secondary alignments (16% of the BAM) are genuine repeats. flagstat
counts them in the total but excludes them from "primary".

## 8. QC tooling — what is and isn't available

| tool | in Colab `apt`? |
|---|---|
| rna-star 2.7.11b | yes |
| samtools 1.19.2 | yes |
| subread 2.0.6 | yes |
| **qualimap** | **no — `apt-cache policy qualimap` returns `Candidate: (none)`** |

Qualimap is absent from Ubuntu noble. Rather than install 44 MB of jars via conda
or an unversioned jar download, QC is **samtools-only**, and the notebook's
markdown names Qualimap and MultiQC as what a real sample would add.

That choice is also statistically right: at 5,000 read pairs the metrics those
tools report (5′/3′ bias, duplication, insert size) are not meaningful.

## 9. Counting with featureCounts, vs the Lecture-06 matrix

The Lecture-06 matrix is **not** a STAR re-alignment. It is NCBI's deposited
**HTSeq counts from HISAT2 v2.1.0 on GRCh38 p13**, fetched from GEO
(`GSE129221_raw_counts_GRCh38.p13_NCBI.tsv.gz`). So this is a cross-pipeline
check: different aligner, different annotation release, different counter.

Sample correspondence: **SRR8836894 = GSM3702795 = PC9_Control_1**.

Command:

```bash
featureCounts -p --countReadPairs -T 8 -t exon -g gene_id \
    -a data/gtf/Homo_sapiens.GRCh38.sub.gtf sample.Aligned.sortedByCoord.out.bam
```

Fragment assignment, from `fc_5k.txt.summary`:

| | fragments |
|---|---|
| assigned to a gene | **448** |
| unassigned, multi-mapping | 183 |
| unassigned, ambiguous (overlapping features) | 74 |
| unassigned, no features | 31 |
| **total** | **736** |

6,661 Ensembl genes in the GTF resolved to 3,209 Entrez IDs on these three
chromosomes (`org.Hs.eg.db`), of which **2,524** appear in the Lecture-06 matrix.

| | |
|---|---|
| genes on chr17/21/22 | 2,524 |
| detected by us (≥1 fragment) | **205 (8.1%)** |
| our fragments on those genes | 340 |
| matrix fragments on those genes | 1,813,215 |
| **ratio** | **1 : 5,333** |

Agreement:

| statistic | value |
|---|---|
| Spearman ρ (204 genes) | **0.492** |
| top-12 overlap with the matrix | **6 / 12** |
| shuffle null, 5,000 permutations | ρ 0.000 ± 0.069, p = **0.0002** |
| shuffle null, top-12 overlap | 0.7 ± 0.8, p = **0.0002** |

Stratified by how highly the matrix expresses the gene:

| stratum | genes | detected | Spearman ρ |
|---|---|---|---|
| matrix ≥ 1000 | 432 | 154 | **0.460** |
| matrix 100–999 | 707 | 46 | 0.001 |
| matrix 10–99 | 299 | 0 | — |
| matrix 1–9 | 382 | 0 | — |
| matrix 0 | 704 | 0 | — |

### The Poisson oracle

Assuming the rates are **perfect** and only counting noise differs, simulated
Poisson draws give ρ = **0.309 ± 0.066** and a top-12 overlap of **4.52/12**.

**We observe 0.492 and 6/12 — above the ceiling.** There is no residual
systematic disagreement left to find: the scatter is entirely counting noise
from 340 fragments spread over 2,524 genes.

Corroborating: only **1 of 205** genes we detected is a zero in the matrix
(99.5% detection agreement).

### Depth needed to reproduce the matrix

Fixed gene set (the 432 genes the matrix puts at ≥1,000), perfect rates, Poisson
noise only:

| depth | pairs | ρ vs matrix | genes with ≥1 fragment |
|---|---|---|---|
| **1×** | **5,000** | **0.422** | **56 / 432** |
| 2× | 10,000 | 0.520 | 142 / 432 |
| 5× | 25,000 | 0.657 | 408 / 432 |
| 10× | 50,000 | 0.751 | 432 / 432 |
| 20× | 100,000 | 0.832 | 432 / 432 |
| 100× | 500,000 | 0.947 | 432 / 432 |

At 5,000 pairs a gene with 1,000 counts in the matrix is expected to receive
**0.2 fragments**. That is why only 56 of 432 are detected.

### Rank agreement at the top

| rank | matrix | symbol | matrix count | ours |
|---|---|---|---|---|
| 1 | 71 | ACTG1 | 74,536 | 21 |
| 2 | 3880 | KRT19 | 57,482 | 10 |
| 3 | 2194 | FASN | 42,189 | 5 |
| 4 | 6122 | RPL3 | 39,002 | 7 |
| 5 | 4627 | MYH9 | 18,161 | 3 |
| 6 | 5034 | P4HB | 18,041 | 4 |

Six of our top 12 genes are in the matrix's top 12; the first two are identical.

### Strandedness sweep, measured on this run

Same BAM, same GTF, same flags; only `-s` changed:

| `-s` | assigned pairs |
|---|---|
| 0 — unstranded | **448** |
| 1 — forward | 270 |
| 2 — reverse | 267 |

The simulated library is unstranded, so `-s 0` is correct; forcing read-strand
logic discards 178 pairs (40% of `Assigned`). This measures the deck’s callout
(“the wrong `-s` halves your counts”) instead of asserting it.

### The matrix itself

`counts.txt`: 6,661 gene rows plus header (matching the 6,661 meta-features
featureCounts reported), one sample column, **253 rows non-zero**, column sum
**448** — exactly `Assigned` in the summary. `Chr`/`Start`/`End`/`Length` carry one
semicolon-separated entry per
exon.

`Unassigned_MappingQuality` is 0: the default `-q 0` filters nothing, and
STAR’s lowest `MAPQ` in this BAM is 1.

## 10. Library size — SRR8836894

From ENA `read_run`:

| | |
|---|---|
| read pairs (spots) | **24,641,002** |
| individual reads, R1 + R2 | **49,282,004** |
| read length | 150 bp × 2 |
| bases | 7,392,300,600 (7.39 Gbp) |
| layout / strategy | PAIRED / RNA-Seq |
| compressed size on ENA | 3.77 GB (1.81 GB R1 + 1.96 GB R2) |

`read_count` in ENA counts **spots, not reads**: 24,641,002 × 300 bases per pair
= 7,392,300,600 exactly, matching `base_count`.

| subset | pairs | share of the run |
|---|---|---|
| **shipped in the notebook** | **5,000** | **0.020%** (1/4,928) |
| local working copy | 1,500,000 | 6.09% |
| full run | 24,641,002 | 100% |

Three independent cross-checks:

1. Your matrix assigns 22,481,285 of 24,641,002 pairs — a **91.2%** assignment
   rate, what HTSeq should produce on a HISAT2 alignment.
2. chr17/21/22 hold 1,813,215 fragments = **8.07%** of all assigned fragments.
   Three of 24 chromosomes holding 8% of reads is consistent, slightly
   expression-enriched.
3. Fragment-count depth ratio 1/5,332 vs actual pair ratio 1/4,928 → our pipeline
   yields **92% as many fragments per pair** as HISAT2. The 8% gap is
   `--outFilterType BySJout` plus the three-chromosome restriction — precisely the
   two things that differ.

This is the number the whole design rests on: the real run is **3.77 GB**.

## 11. Traps hit while building this

Each of these produced a wrong answer that looked clean. They are recorded
because they will recur.

| trap | symptom | resolution |
|---|---|---|
| `samtools idxstats` needs a `.bai` | `[E::idx_find_and_load]` | STAR's `SortedByCoordinate` BAM has no index and nothing creates one |
| `samtools view -c FILE REGION` needs a `.bai` too | `Random alignment retrieval only works for indexed…` | the **region argument is what triggers** indexed access — stream and `awk` on column 3 instead |
| STAR "Average input read length **300**" | reads are actually 150 bp | it sums **both mates**; 2 × 150. `--sjdbOverhang 149` is correct |
| permuting gene labels to build a null | ρ identical to observed, p = 1.0 | it reorders both vectors together; the gene pairing is never broken |
| `as.numeric()` on a named vector | top-12 overlap reported as 0/10 | it silently strips names, so the comparison was against `NULL` |
| featureCounts with one BAM | columns are `22;22;22;…` | a single sample still emits one column per file; read the header, don't guess |
| ENA `read_count` | appears to be reads | it is spots; confirm via `base_count / read_count` |
| `apt` on Ubuntu noble | qualimap install fails | `Candidate: (none)` — absent, not broken |

The general lesson, applied twice: **the first error message usually states the
constraint.** Both samtools failures printed the missing-index complaint on the
first attempt, and the fix was either "build the index first" or "stream instead"
— not another indexed subcommand.