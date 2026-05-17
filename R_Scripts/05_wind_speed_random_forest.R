library(tidyverse)
library(rsample)
library(ranger)

# 1. Load data and include wind direction columns
flight_data <- read_csv("../DJI_Flight_Records/complete_cleaned_dji_flight_records.csv")

hover_data_advanced <- flight_data %>% 
  filter(h_speed == 0) %>% 
  mutate(
    total_tilt = sqrt(pitch^2 + roll^2),
    # CRITICAL: Convert character text columns into factors for machine learning
    wind_dir     = as.factor(wind_dir),
    wind_rel_dir = as.factor(wind_rel_dir)
  ) %>% 
  # Select our new advanced feature list
  select(wind_speed_mph, total_tilt, yaw, pitch, roll, wind_dir, wind_rel_dir) %>% 
  drop_na(wind_speed_mph, wind_dir, wind_rel_dir) # Drop rows missing wind data

# 2. Resplit the data exactly the same way
set.seed(42)
data_split_adv <- initial_split(hover_data_advanced, prop = 0.80)
train_data_adv <- training(data_split_adv)
test_data_adv  <- testing(data_split_adv)

# 3. Train the upgraded Random Forest Model
# Using the "." shortcut tells R to predict wind speed using ALL other columns in the data frame
rf_model_advanced <- ranger(
  formula    = wind_speed_mph ~ ., 
  data       = train_data_adv, 
  num.trees  = 500,          
  importance = "permutation" 
)

# 4. Print the summary results to check the new OOB R-squared!
print(rf_model_advanced)

# Generate predictions and calculate new MAE
final_predictions_adv <- predict(rf_model_advanced, data = test_data_adv)$predictions

test_results_adv <- test_data_adv %>%
  mutate(predicted_wind_speed = final_predictions_adv)

final_mae_adv <- mean(abs(test_results_adv$wind_speed_mph - test_results_adv$predicted_wind_speed))
print(paste("Advanced Test Error: The model is off by an average of", round(final_mae_adv, 2), "mph"))

# ------------------------------------------------------------------------------
library(tidyverse)
library(ranger)

# 1. Prepare your ALL-DATA dataset (do not filter by h_speed == 0)
all_flight_data_prepared <- flight_data %>% 
  mutate(
    total_tilt = sqrt(pitch^2 + roll^2),
    wind_dir     = as.factor(wind_dir),
    wind_rel_dir = as.factor(wind_rel_dir)
  ) %>% 
  select(wind_speed_mph, total_tilt, yaw, pitch, roll, wind_dir, wind_rel_dir, h_speed) %>% 
  drop_na(wind_speed_mph, wind_dir, wind_rel_dir)

# 2. Use your advanced model to predict wind speeds for every single row
all_predictions <- predict(rf_model_advanced, data = all_flight_data_prepared)$predictions

# 3. Build a master evaluation table
all_data_results <- all_flight_data_prepared %>%
  mutate(predicted_wind_speed = all_predictions)

# 4. Calculate the overall error across everything
overall_mae <- mean(abs(all_data_results$wind_speed_mph - all_data_results$predicted_wind_speed))
print(paste("Overall Error across ALL flight data:", round(overall_mae, 2), "mph"))