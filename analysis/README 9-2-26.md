# Citations for Source Data

myebird_raw --> personal ebird data (LINK)
ebird_taxonomy_raw -> ebird (LINK)
local_status_raw --> state-specific data from ebird (LINK)

# Raw data pre-processing

- Location data that is more granular than state has been deleted from all raw csv files
- The experiment location has been pre-filtered, so all birding entries loaded in 00_data-prep were part of this experiment, at the same location
- All personal comment columns deleted
- The location has been anonymized to "Local Park"

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