library(tidyverse)
library(rsample)
library(ranger)

# 1. Load your local complete and cleaned dataset
flight_data <- read_csv("../DJI_Flight_Records/complete_cleaned_dji_flight_records.csv")

hover_data_fixed <- flight_data %>% 
  filter(h_speed == 0) %>% 
  mutate(total_tilt = sqrt(pitch^2 + roll^2)) %>% 
  select(wind_speed_mph, total_tilt, yaw) %>% 
  drop_na(wind_speed_mph)

# 2. Resplit the data
set.seed(42)
data_split_fixed <- initial_split(hover_data_fixed, prop = 0.80)
train_data_fixed <- training(data_split_fixed)
test_data_fixed  <- testing(data_split_fixed)

# 3. Train a new model using Total Tilt
fixed_model <- lm(wind_speed_mph ~ total_tilt, data = train_data_fixed)

# 4. Check the results
summary(fixed_model)

# ------------------------------------------------------------------------------

# Train the model
rf_model <- ranger(
  formula    = wind_speed_mph ~ total_tilt + yaw, 
  data       = train_data_fixed, 
  num.trees  = 500,          # Build 500 decision trees
  importance = "permutation" # Measures which variable is most important
)

# Print the summary results
print(rf_model)

# ------------------------------------------------------------------------------
# 1. Generate predictions for the test dataset
final_predictions <- predict(rf_model, data = test_data_fixed)$predictions

# 2. Build an evaluation table
test_results <- test_data_fixed %>%
  mutate(predicted_wind_speed = final_predictions)

# 3. Calculate the actual Mean Absolute Error (MAE) on test data
final_mae <- mean(abs(test_results$wind_speed_mph - test_results$predicted_wind_speed))
print(paste("Official Test Error: The model is off by an average of", round(final_mae, 2), "mph"))

# 4. View the first 10 rows to see actual vs predicted numbers
test_results %>% 
  select(wind_speed_mph, predicted_wind_speed, total_tilt, yaw) %>% 
  head(10)

# ------------------------------------------------------------------------------
