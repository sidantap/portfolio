
# KPI + Analytics Script (Part 2)
# Contains: Completion tracking, quarterly summaries, forecasts, clustering, and outliers

library(readxl)
library(openxlsx)
library(dplyr)
library(ggplot2)

current_year <- 2025
current_quarter <- 2
selection_history_dir <- "Selection History/"

# Step 5: Completion Metrics – Drug & Alcohol Progress
all_history_files <- list.files(selection_history_dir, pattern = paste0(current_year, "_Q[1-", current_quarter, "]_selection.xlsx"), full.names = TRUE)

all_selections <- data.frame()
for (file in all_history_files) {
  df <- read.xlsx(file)
  if ("TestFor" %in% colnames(df)) {
    df$Quarter <- as.numeric(gsub(".*Q([1-4])_selection.xlsx", "\\1", file))
    all_selections <- bind_rows(all_selections, df)
  }
}

summary_counts <- all_selections %>%
  group_by(TestFor) %>%
  summarise(Total = n(), .groups = "drop")

combo_completed <- summary_counts %>% filter(TestFor == "Combo (Drug + Alcohol)") %>% pull(Total)
drug_only_completed <- summary_counts %>% filter(TestFor == "Drug Only") %>% pull(Total)

combo_completed <- ifelse(length(combo_completed) == 0, 0, combo_completed)
drug_only_completed <- ifelse(length(drug_only_completed) == 0, 0, drug_only_completed)

total_drug_tests <- combo_completed + drug_only_completed
total_alcohol_tests <- combo_completed

# Substitute these with values saved earlier or from a config
annual_drug_goal <- 38
annual_alcohol_goal <- 15

drug_pct_complete <- round(100 * total_drug_tests / annual_drug_goal, 1)
alcohol_pct_complete <- round(100 * total_alcohol_tests / annual_alcohol_goal, 1)

drug_flag <- ifelse(drug_pct_complete >= 100, "✅", ifelse(drug_pct_complete >= 75, "⚠", "❌"))
alcohol_flag <- ifelse(alcohol_pct_complete >= 100, "✅", ifelse(alcohol_pct_complete >= 75, "⚠", "❌"))

cat("\n----- FAA TESTING COMPLETION METRICS (YTD) -----\n")
cat("Drug Tests Completed: ", total_drug_tests, "/", annual_drug_goal, " (", drug_pct_complete, "%)\n", sep = "")
cat("Alcohol Tests Completed (Combo only): ", total_alcohol_tests, "/", annual_alcohol_goal, " (", alcohol_pct_complete, "%)\n", sep = "")
cat("Drug Testing Status: ", drug_flag, "\n")
cat("Alcohol Testing Status: ", alcohol_flag, "\n")

# Step 6: Extra KPI Metrics

# Quarterly Breakdown
quarterly_summary <- all_selections %>%
  group_by(Quarter, TestFor) %>%
  summarise(Count = n(), .groups = "drop") %>%
  arrange(Quarter, TestFor)

cat("\n----- QUARTERLY TEST SELECTION BREAKDOWN -----\n")
print(quarterly_summary)

# Occupation Group Coverage
occupation_summary <- all_selections %>%
  group_by(Occupation, TestFor) %>%
  summarise(Count = n(), .groups = "drop") %>%
  arrange(desc(Count))

cat("\n----- OCCUPATION GROUP SELECTION COUNTS (YTD) -----\n")
print(occupation_summary)

# Forecast
projected_drug <- round((total_drug_tests / current_quarter) * 4)
projected_alcohol <- round((total_alcohol_tests / current_quarter) * 4)

forecast_flag <- function(projected, goal) {
  if (projected >= goal) return("✅ On Track")
  if (projected >= 0.8 * goal) return("⚠ At Risk")
  return("❌ Behind")
}

cat("\n----- TESTING FORECAST (BASED ON CURRENT PACE) -----\n")
cat("Projected Drug Tests by Q4: ", projected_drug, " (Goal: ", annual_drug_goal, ")\n", sep = "")
cat("Projected Alcohol Tests by Q4: ", projected_alcohol, " (Goal: ", annual_alcohol_goal, ")\n", sep = "")
cat("Drug Forecast Status: ", forecast_flag(projected_drug, annual_drug_goal), "\n")
cat("Alcohol Forecast Status: ", forecast_flag(projected_alcohol, annual_alcohol_goal), "\n")

# Linear Trend
cat("\n----- LINEAR TREND OF TESTS PER QUARTER -----\n")
if (nrow(quarterly_summary) > 1) {
  trend_model <- lm(Count ~ Quarter, data = quarterly_summary)
  print(summary(trend_model))
} else {
  cat("Trend not available — need data from multiple quarters.\n")
}

# K-Means Clustering
cat("\n----- K-MEANS CLUSTERING: EMPLOYEE SELECTION FREQUENCY -----\n")
employee_freq <- all_selections %>%
  group_by(EmployeeID) %>%
  summarise(Selections = n(), .groups = "drop")

if (nrow(employee_freq) >= 5) {
  scaled_freq <- scale(employee_freq$Selections)
  set.seed(123)
  kmeans_model <- kmeans(scaled_freq, centers = 3)
  employee_freq$Cluster <- kmeans_model$cluster
  print(employee_freq)
} else {
  cat("Not enough data for clustering (need at least 5 unique employees).\n")
}

# Outlier Detection
cat("\n----- OUTLIER DETECTION: OCCUPATION SELECTION COUNTS -----\n")
iqr_table <- occupation_summary %>%
  group_by(TestFor) %>%
  mutate(
    Q1 = quantile(Count, 0.25),
    Q3 = quantile(Count, 0.75),
    IQR = Q3 - Q1,
    Outlier = ifelse(Count < Q1 - 1.5 * IQR | Count > Q3 + 1.5 * IQR, "Yes", "No")
  )

print(iqr_table %>% filter(Outlier == "Yes"))
