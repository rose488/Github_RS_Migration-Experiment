# Spring Migration Experiment (2026)

An analysis of my own eBird checklists from a single local patch across spring
migration 2026, comparing what I actually observed against two independent
expectations: eBird's modeled regional abundance (via `ebirdst`) and
BirdCast's nocturnal migration intensity data for the area.

This was also my first project in R — the code is intentionally left close
to how I actually wrote/learned it (including sections co-written with
Claude, marked with `# CLAUDE` comments) rather than polished into something
unrecognizable, since re-reading it is part of how I'm learning.

## What's here

- `9-9-26_Mig Exp_01_Story 1.Rmd` — the main analysis: data setup, species
  filtering, richness calculations, and all figures (heatmaps, ridgeline
  plots, observed-vs-expected panels, migration-wave delta charts).
- `data/derived/` — cleaned checklist data used directly by the Rmd.
- `data/raw/` — reference data (BirdCast summary, eBird taxonomy, regional
  abundance stats). My personal raw eBird export is intentionally excluded
  (see **Privacy** below).
- `figures/` — saved output figures.

## Privacy: why the Checklist IDs look like "CHK-0001"

Real eBird checklists have a public Submission ID (e.g. `CHK-0011`) that
anyone can look up at `ebird.org/checklist/<ID>` to see the exact GPS
location of that outing and the account that submitted it. To keep this
project reproducible without exposing precise location or my eBird identity,
every real ID was swapped for an arbitrary code before this data was
committed, using a one-time local script (`deidentify_checklist_ids.R`).
The real IDs never leave my computer — the lookup key and my raw personal
export are both excluded via `.gitignore`. The species, counts, dates, and
generic location name ("Local Park") are unchanged, so the analysis itself
reproduces exactly.

## Reproducing this analysis

1. Install R packages: `tidyverse`, `tibble`, `here`, `lubridate`,
   `wesanderson`, `viridisLite`, `ggridges`, `patchwork`, `purrr`, `auk`,
   `ebirdst`, `tigris`, `terra`.
2. `ebirdst` requires a (free) Cornell Lab access key to download regional
   abundance data — see the
   [ebirdst package docs](https://ebird.github.io/ebirdst/) for how to
   request one and set it as an environment variable.
3. Open the `.Rmd` in RStudio and run chunks top to bottom, or Knit.
