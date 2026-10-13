library(plumber)
library(openxlsx)
library(jsonlite)

#* @get /load_master_pool
#* @serializer unboxedJSON
function() {
  file_path <- "Master Data/Master_Employee_Pool.xlsx"
  if (!file.exists(file_path)) return(list(error = "File not found"))
  
  pool <- read.xlsx(file_path)
  
  required_cols <- c("id", "name", "occupation", "base", "status")
  missing <- setdiff(required_cols, names(pool))
  if (length(missing) > 0) {
    return(list(error = paste("Missing column(s):", paste(missing, collapse = ", "))))
  }
  
  return(pool[required_cols])
}

pr("plumbertest.R") %>% pr_run(port = 8000)