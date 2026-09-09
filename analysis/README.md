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

eBird checklists have a public Submission ID to see the exact GPS
location and the account that submitted it. To keep this
project reproducible without exposing precise location or my eBird identity,
every real ID was swapped for an arbitrary code before this data was
committed, using a one-time local script (`deidentify_checklist_ids.R`).
The real IDs never leave my computer — the lookup key and my raw personal
export are both excluded via `.gitignore`. 

## Reproducing this analysis

1. Install R packages: `tidyverse`, `tibble`, `here`, `lubridate`,
   `wesanderson`, `viridisLite`, `ggridges`, `patchwork`, `purrr`, `auk`,
   `ebirdst`, `tigris`, `terra`.
2. `ebirdst` requires a (free) Cornell Lab access key to download regional
   abundance data — see the
   [ebirdst package docs](https://ebird.github.io/ebirdst/) for how to
   request one and set it as an environment variable.
3. Open the `.Rmd` in RStudio and run chunks top to bottom, or Knit.


# Citations for Source Data

myebird_raw --> personal ebird data (LINK)
ebird_taxonomy_raw -> ebird (LINK)
local_status_raw --> state-specific data from ebird (LINK)

# Raw data pre-processing

- Location data that is more granular than state has been deleted from all raw csv files
- The experiment location has been pre-filtered, so all birding entries loaded in 00_data-prep were part of this experiment, at the same location
- All personal comment columns deleted
- The location has been anonymized to "Local Park"
- Submission IDs have been swapped with a random "code." Only that random code is visible in Github.

# 00_data-prep file

## Definitions

- checklist
- paired checklist
- complete/incomplete checklist

## Explanation of birding-specific data cleaning

- Auk roll-up (in code comments)
- Zero-filling


# Other notes

- "EXP" is short for "experiment," and used in my code to distinguish variables, dataframes, etc. that are specific to this experiment

# 01_analysis

ORDER OF OPERATIONS

1. Main dataframes (myebird):
   1. Load libraries and data
   2. Quick column cleaning (names; Protocol titles)
   3. Auk Rollup
   4. Add Paired/Unpaired
   5. FILTER CHECKLISTS
  
2. External Bird Metadata

    1. Taxonomy, population
    2. Massachusetts Breeding
  
3. Data cleaning: Main dataframe (myebird)

4. Make `checklists` Dataframe (wide form)
    - each checklist has one row
    - every species has a separate column
    - value = count for that checklist
    - zero filling
    - binning
 
5. Pivot back to myebird (long form)
    - one row per observation
    - every checklist now has one row for each species seen DURING ENTIRE EXPERIMENT
      - zero filled
      - number of rows should equal: num_checklists * num_species
