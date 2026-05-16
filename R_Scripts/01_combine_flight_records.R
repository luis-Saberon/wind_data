library(readxl)
library(tidyverse)

# 1. Define Path (Error --> Navigate to session, set working directory, and click to source file location)
folder_path <- "../DJI_Flight_Records/Excel_Flight_Records"

# 2. List and combine files (.xls/.xlsx + UpperCase)
file_list <- list.files(path = folder_path, pattern = "(?i)\\.xlsx?$", full.names = TRUE)

combined_data <- file_list %>% 
  map_df(~read_excel(.x))

# 3. Save the final combined dataset as a CSV file
write_csv(combined_data, "../DJI_Flight_Records/complete_dji_flight_records_csv.csv")