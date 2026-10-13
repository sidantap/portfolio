# Randomizer Script (Refactored for Google Drive Reliability)
# install.packages('plumber')

library(plumber)
library(readxl)
library(openxlsx)
library(dplyr)
library(stringr)
library(lubridate)
library(googledrive)

# Authenticate with Google Drive
drive_auth()

# Get folder ID for a subfolder by name
get_drive_folder_id <- function(parent_id, folder_name) {
  folders <- drive_ls(as_id(parent_id), type = "folder") %>% filter(name == folder_name)
  if (nrow(folders) != 1) stop(paste("Folder not uniquely found:", folder_name))
  return(folders$id)
}

# Download a file from a specific subfolder
download_drive_file <- function(parent_id, subfolder_name, file_name, local_path) {
  folder_id <- get_drive_folder_id(parent_id, subfolder_name)
  file <- drive_ls(as_id(folder_id)) %>% filter(name == file_name)
  if (nrow(file) == 1) drive_download(file, path = local_path, overwrite = TRUE)
}

# Upload a file to a specific subfolder
upload_drive_file <- function(parent_id, subfolder_name, local_path) {
  folder_id <- get_drive_folder_id(parent_id, subfolder_name)
  drive_upload(media = local_path, path = as_id(folder_id), overwrite = TRUE)
}

# Locate main folder and validate subfolders
main_folder <- drive_get("DAT Application")
main_id <- main_folder$id

# Get user input
current_year <- as.integer(readline("Enter year (e.g., 2025): "))
current_quarter <- as.integer(readline("Enter quarter (1–4): "))
combo_target <- as.integer(readline("Enter number of COMBO tests to select: "))
drug_only_target <- as.integer(readline("Enter number of DRUG-ONLY tests to select: "))

# Load or initialize Master Pool
master_file <- "Master_Employee_Pool.xlsx"
download_drive_file(main_id, "Master Data", master_file, master_file)
master_pool <- if (file.exists(master_file)) read.xlsx(master_file) else data.frame()

# Load or initialize Processed Log
log_file <- "processed_files_log.xlsx"
download_drive_file(main_id, "Audit Logs", log_file, log_file)
processed_log <- if (file.exists(log_file)) read.xlsx(log_file) else data.frame(filename = character(), processed_time = as.POSIXct(character()))

# Process new uploads
uploads_id <- get_drive_folder_id(main_id, "Uploads")
upload_files <- drive_ls(as_id(uploads_id))
new_files <- upload_files %>% filter(!(name %in% processed_log$filename))

for (file in new_files$name) {
  local_path <- file.path(tempdir(), file)
  download_drive_file(main_id, "Uploads", file, local_path)
  upload_data <- read.xlsx(local_path)
  required_cols <- c("EmployeeID", "Name", "Occupation", "Base Location", "Position", "Status")
  if (!all(required_cols %in% names(upload_data))) next
  upload_data <- distinct(upload_data, EmployeeID, .keep_all = TRUE)
  master_pool <- bind_rows(master_pool, upload_data) %>% arrange(desc(Status)) %>% distinct(EmployeeID, .keep_all = TRUE)
  processed_log <- bind_rows(processed_log, data.frame(filename = file, processed_time = Sys.time()))
}

write.xlsx(master_pool, master_file, overwrite = TRUE)
upload_drive_file(main_id, "Master Data", master_file)
write.xlsx(processed_log, log_file, overwrite = TRUE)
upload_drive_file(main_id, "Audit Logs", log_file)

# Filter active employees and save eligible pool
eligible_pool <- master_pool %>% filter(Status == "Active")
eligible_filename <- sprintf("%d_Q%d_eligible.xlsx", current_year, current_quarter)
write.xlsx(eligible_pool, eligible_filename, overwrite = TRUE)
upload_drive_file(main_id, "Eligible employee pool", eligible_filename)

# Headcount calculation
eligible_id <- get_drive_folder_id(main_id, "Eligible employee pool")
all_eligible_files <- drive_ls(as_id(eligible_id)) %>% filter(str_detect(name, paste0(current_year, "_Q[1-", current_quarter, "]_eligible.xlsx")))

quarterly_counts <- bind_rows(lapply(all_eligible_files$name, function(file) {
  tmp_path <- file.path(tempdir(), file)
  download_drive_file(main_id, "Eligible employee pool", file, tmp_path)
  df <- read.xlsx(tmp_path)
  q <- as.numeric(gsub(".*Q([1-4])_eligible.xlsx", "\\1", file))
  data.frame(Quarter = q, Headcount = nrow(df))
}))

avg_ytd_headcount <- mean(quarterly_counts$Headcount)
annual_drug_goal <- round(avg_ytd_headcount * 0.25)
annual_alcohol_goal <- round(avg_ytd_headcount * 0.10)

# Load prior selections to prevent duplicates
history_id <- get_drive_folder_id(main_id, "Selection History")
prior_files <- drive_ls(as_id(history_id)) %>% filter(str_detect(name, paste0(current_year, "_Q[1-", current_quarter - 1, "]_selection.xlsx")))

prior_selected_ids <- c()
for (file in prior_files$name) {
  local_path <- file.path(tempdir(), file)
  download_drive_file(main_id, "Selection History", file, local_path)
  df <- read.xlsx(local_path)
  if ("EmployeeID" %in% names(df)) {
    prior_selected_ids <- union(prior_selected_ids, df$EmployeeID)
  }
}

# Perform randomization
eligible_pool <- eligible_pool %>% filter(!(EmployeeID %in% prior_selected_ids))
occupation_sample <- eligible_pool %>% group_by(Occupation) %>% slice_sample(n = 1) %>% ungroup()
remaining_pool <- eligible_pool %>% filter(!(EmployeeID %in% occupation_sample$EmployeeID))
combo_draw <- remaining_pool %>% slice_sample(n = max(combo_target - nrow(occupation_sample), 0))
combo_group <- bind_rows(occupation_sample, combo_draw) %>% mutate(TestFor = "Combo (Drug + Alcohol)")
remaining_after_combo <- eligible_pool %>% filter(!(EmployeeID %in% combo_group$EmployeeID))
drug_only_group <- remaining_after_combo %>% slice_sample(n = drug_only_target) %>% mutate(TestFor = "Drug Only")
final_selection <- bind_rows(combo_group, drug_only_group) %>% arrange(Occupation, Name)

# Save final results and audit
result_file <- sprintf("%d_Q%d_selection.xlsx", current_year, current_quarter)
audit_file <- sprintf("%d_Q%d_auditlog.txt", current_year, current_quarter)

write.xlsx(final_selection, result_file, overwrite = TRUE)
upload_drive_file(main_id, "Results", result_file)
upload_drive_file(main_id, "Selection History", result_file)

log_msg <- sprintf("Quarter: Q%d\nYear: %d\nTimestamp: %s\nCombo Tests: %d\nDrug-Only Tests: %d\nTotal Selected: %d\n",
                   current_quarter, current_year, Sys.time(), nrow(combo_group), nrow(drug_only_group), nrow(final_selection))
writeLines(log_msg, audit_file)
upload_drive_file(main_id, "Audit Logs", audit_file)

cat("\n✅ Random selection complete!\n")
cat("✔ Combo: ", nrow(combo_group), " | Drug-Only: ", nrow(drug_only_group), "\n")
cat("✔ Files successfully uploaded to Google Drive folders\n")
