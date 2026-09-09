# ============================================================
# De-identify eBird Submission IDs -- run this BEFORE 00-data-prep
# ============================================================
#
# WHY THIS EXISTS:
# Each "Submission.ID" (e.g. "CHK-0011") is a real, public eBird
# Submission ID. Anyone can put it into ebird.org/checklist/<ID> and see
# the exact GPS location of that outing and the eBird account that
# submitted it.
#
# WHAT THIS SCRIPT DOES:
# 1. Reads the raw personal export (data/raw/myebirdraw_LTH.csv).
# 2. Builds (or reuses) one master real-ID -> fake-code lookup table.
# 3. Writes a de-identified copy to data/raw/myebird_raw_deidentified.csv,
#    with Submission.ID replaced by fake codes (e.g. "CHK-0001"). This is
#    the file 00-data-prep.Rmd reads -- real IDs never reach that script,
#    or anything it produces.
# 4. Saves the real<->fake key to data/PRIVATE_id_key/checklist_id_key.csv.
#
# IMPORTANT -- BEFORE YOU PUSH TO GITHUB:
#   - NEVER commit data/PRIVATE_id_key/        (the real IDs live here)
#   - NEVER commit data/raw/myebirdraw_LTH.csv (your raw personal export)
# Both are already listed in the .gitignore template included in this folder.
# data/raw/myebird_raw_deidentified.csv is SAFE to commit -- it has no real IDs.
#
# Run this once. If you re-run it, it reuses the existing key file so the
# same real checklist always maps to the same fake code.
# ============================================================

library(dplyr)

raw_path          <- "data/raw/myebirdraw_LTH.csv"
deidentified_path <- "data/raw/myebird_raw_deidentified.csv"
key_dir           <- "data/PRIVATE_id_key"
key_path          <- file.path(key_dir, "checklist_id_key.csv")

dir.create(key_dir, showWarnings = FALSE, recursive = TRUE)

myebird_raw <- read.csv(raw_path)

# ---- Build (or load) the master real -> fake ID key ----
if (file.exists(key_path)) {
  id_key <- read.csv(key_path, stringsAsFactors = FALSE)
} else {
  all_ids <- sort(unique(myebird_raw$Submission.ID))
  id_key <- data.frame(
    Submission.ID = all_ids,
    Fake.ID       = sprintf("CHK-%04d", seq_along(all_ids)),
    stringsAsFactors = FALSE
  )
  write.csv(id_key, key_path, row.names = FALSE)
}

# ---- Write a de-identified copy of the raw file ----
myebird_deidentified <- myebird_raw %>%
  left_join(id_key, by = "Submission.ID") %>%
  mutate(Submission.ID = Fake.ID) %>%
  select(-Fake.ID)

write.csv(myebird_deidentified, deidentified_path, row.names = FALSE)

cat("De-identified raw file written to:", deidentified_path,
    "\nKey file (KEEP LOCAL, NEVER COMMIT):", key_path, "\n")
