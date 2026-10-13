library(readxl)
library(openxlsx)
library(dplyr)
library(stringr)
library(lubridate)


library(Microsoft365R)
# Authenticate
site <- get_sharepoint_site("https://atlasairww.sharepoint.com/sites/DrugandAlcoholTestingPortal")
# 
# # Access a document library (e.g., "Documents")
# drive <- site$get_drive()
# 
# # List files
# drive$list_items()



install.packages("googledrive")
library(googledrive)

drive_auth()

folder <- drive_get("DAT Application")


# Define paths
paths <- list(
  uploads = "Uploads/",
  master = "Master Data/Master_Employee_Pool.xlsx",
  log = "Audit Logs/processed_files_log.xlsx",
  eligible = "Eligible employee pool/"
)

# Step 1a: Load processed file log or initialize
if (file.exists(paths$log)) {
  processed_log <- read.xlsx(paths$log)
} else {
  processed_log <- data.frame(filename = character(), processed_time = as.POSIXct(character()))
}

# Step 1b: List all Excel files in Uploads/ and filter out already processed
upload_files <- list.files(paths$uploads, pattern = "\\.xlsx$", full.names = TRUE)
new_files <- upload_files[!basename(upload_files) %in% processed_log$filename]

# Step 1c: Load master pool (or start fresh if missing)
if (file.exists(paths$master)) {
  master_pool <- read.xlsx(paths$master)
} else {
  master_pool <- data.frame()
}

# Step 1d: Process each new file and merge unique entries
for (file in new_files) {
  upload <- read.xlsx(file)
  
  required_cols <- c("EmployeeID", "Name", "Occupation", "Base Location", "Position", "Status")
  if (!all(required_cols %in% colnames(upload))) {
    message(paste("Skipping", basename(file), "- missing required columns."))
    next
  }
  
  upload <- upload %>% distinct(EmployeeID, .keep_all = TRUE)
  
  master_pool <- bind_rows(master_pool, upload) %>%
    arrange(desc(Status)) %>%
    distinct(EmployeeID, .keep_all = TRUE)
  
  processed_log <- bind_rows(processed_log, data.frame(
    filename = basename(file),
    processed_time = Sys.time()
  ))
}

# Step 1e: Save updated master pool and log
write.xlsx(master_pool, paths$master, overwrite = TRUE)
write.xlsx(processed_log, paths$log, overwrite = TRUE)

message("Master pool updated. Processed ", length(new_files), " new file(s).")

# -------------------------------------------------------
# Step 2: Filter to active employees and save snapshot
# -------------------------------------------------------

current_year <- 2025
current_quarter <- 2

eligible_pool <- master_pool %>% filter(Status == "Active")
eligible_filename <- sprintf("%s%d_Q%d_eligible.xlsx", paths$eligible, current_year, current_quarter)
write.xlsx(eligible_pool, eligible_filename, overwrite = TRUE)

message("Eligible pool saved to: ", eligible_filename)

# -------------------------------------------------------
# Step 3: Calculate headcounts and testing goals
# -------------------------------------------------------

# List all prior eligible pool files for this year up to the current quarter
eligible_files <- list.files(paths$eligible, pattern = paste0(current_year, "_Q[1-", current_quarter, "]_eligible.xlsx"), full.names = TRUE)

quarterly_counts <- data.frame()
for (file in eligible_files) {
  data <- read.xlsx(file)
  q_num <- as.numeric(gsub(".*Q([1-4])_eligible.xlsx", "\\1", file))
  count <- nrow(data)
  quarterly_counts <- bind_rows(quarterly_counts, data.frame(Quarter = q_num, Headcount = count))
}

avg_ytd_headcount <- mean(quarterly_counts$Headcount)

drug_pct <- 0.25
alcohol_pct <- 0.10

annual_drug_goal <- round(avg_ytd_headcount * drug_pct)
annual_alcohol_goal <- round(avg_ytd_headcount * alcohol_pct)

selection_periods <- 4
quarter_drug_target <- round((annual_drug_goal / selection_periods) * current_quarter)
quarter_alcohol_target <- round((annual_alcohol_goal / selection_periods) * current_quarter)

cat("----- TESTING GOALS SUMMARY -----\n")
cat("Avg YTD Headcount: ", avg_ytd_headcount, "\n")
cat("Annual Drug Goal (25%): ", annual_drug_goal, "\n")
cat("Annual Alcohol Goal (10%): ", annual_alcohol_goal, "\n")
cat("Target by end of Q", current_quarter, ": ", quarter_drug_target, " drug tests, ", quarter_alcohol_target, " alcohol tests\n", sep = "")

# -------------------------------------------------------
# Step 4.1–4.3: Randomization Engine (combo and drug-only)
# -------------------------------------------------------

set.seed(2025)  # For reproducibility

# Paths
selection_history_dir <- "Selection History/"
results_dir <- "Results/"
audit_dir <- "Audit Logs/"
dir.create(selection_history_dir, showWarnings = FALSE)
dir.create(results_dir, showWarnings = FALSE)
dir.create(audit_dir, showWarnings = FALSE)

# Load eligible pool again (safe redundancy)
eligible_pool <- read.xlsx(eligible_filename)

# Load prior selections to avoid repeats
prior_files <- list.files(selection_history_dir, pattern = paste0(current_year, "_Q[1-", current_quarter - 1, "]_selection.xlsx"), full.names = TRUE)
prior_selected_ids <- c()
for (file in prior_files) {
  past <- read.xlsx(file)
  if ("EmployeeID" %in% colnames(past)) {
    prior_selected_ids <- union(prior_selected_ids, past$EmployeeID)
  }
}

# Remove duplicates
eligible_pool <- eligible_pool %>% filter(!(EmployeeID %in% prior_selected_ids))

# Force one per occupation group (minimum requirement)
occupation_sample <- eligible_pool %>%
  group_by(Occupation) %>%
  slice_sample(n = 1) %>%
  ungroup()

# Remaining pool
remaining_pool <- eligible_pool %>% filter(!(EmployeeID %in% occupation_sample$EmployeeID))

# Hardcoded test targets for this quarter (manual testing only)
combo_target <- 15
drug_only_target <- 10

# Remove edge case: if required more than available
remaining_pool <- remaining_pool %>%
  filter(!(EmployeeID %in% occupation_sample$EmployeeID))

# Randomly select combo pool first
combo_draw <- remaining_pool %>%
  slice_sample(n = max(combo_target - nrow(occupation_sample), 0))

combo_group <- bind_rows(occupation_sample, combo_draw) %>%
  mutate(TestFor = "Combo (Drug + Alcohol)")

# Exclude combo-selected from remaining pool
remaining_after_combo <- eligible_pool %>%
  filter(!(EmployeeID %in% combo_group$EmployeeID))

# Drug-only group
drug_only_group <- remaining_after_combo %>%
  slice_sample(n = drug_only_target) %>%
  mutate(TestFor = "Drug Only")

# Final selection
final_selection <- bind_rows(combo_group, drug_only_group) %>%
  arrange(Occupation, Name)

# -------------------------------------------------------
# Step 4.4: Save results to Results/, Selection History/, Audit Logs/
# -------------------------------------------------------

# File names
result_file <- sprintf("%s%d_Q%d_selection.xlsx", results_dir, current_year, current_quarter)
history_file <- sprintf("%s%d_Q%d_selection.xlsx", selection_history_dir, current_year, current_quarter)
audit_file <- sprintf("%s%d_Q%d_auditlog.txt", audit_dir, current_year, current_quarter)

# Save results and history
write.xlsx(final_selection, result_file, overwrite = TRUE)
write.xlsx(final_selection, history_file, overwrite = TRUE)

# Save audit log
log_msg <- sprintf("Quarter: Q%d\nYear: %d\nTimestamp: %s\nCombo Tests: %d\nDrug-Only Tests: %d\nTotal Selected: %d\n\n",
                   current_quarter, current_year, Sys.time(),
                   nrow(combo_group), nrow(drug_only_group), nrow(final_selection))
writeLines(log_msg, con = audit_file)

cat("Random selection complete.\n")
cat("✔ Combo: ", nrow(combo_group), " | Drug-Only: ", nrow(drug_only_group), "\n")
cat("✔ Files saved to Results/, Selection History/, and Audit Logs/\n")


