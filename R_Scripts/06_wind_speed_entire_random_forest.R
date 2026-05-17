library(tidyverse)
library(rsample)
library(ranger)

# 1. Load your local complete and cleaned dataset
flight_data <- read_csv("../DJI_Flight_Records/complete_cleaned_dji_flight_records.csv")

# 2. Prepare the ENTIRE dataset (No filter on h_speed!)
all_flight_data <- flight_data %>% 
  mutate(
    total_tilt = sqrt(pitch^2 + roll^2),
    wind_dir     = as.factor(wind_dir),
    wind_rel_dir = as.factor(wind_rel_dir)
  ) %>% 
  # CRITICAL: We include h_speed in the selection so the model can learn flight vs hover physics
  select(wind_speed_mph, total_tilt, yaw, pitch, roll, wind_dir, wind_rel_dir, h_speed) %>% 
  drop_na(wind_speed_mph, wind_dir, wind_rel_dir)

# 3. Split the entire dataset into 80% train and 20% test
set.seed(42)
global_split <- initial_split(all_flight_data, prop = 0.80)
global_train <- training(global_split)
global_test  <- testing(global_split)

# 4. Train the Global Random Forest Model
# This model will look at 500 decision trees to figure out how h_speed interacts with tilt
global_rf_model <- ranger(
  formula    = wind_speed_mph ~ ., 
  data       = global_train, 
  num.trees  = 500,          
  importance = "permutation" 
)

# 5. Print the global model summary
print(global_rf_model)

# ------------------------------------------------------------------------------
# 6. Validate the model on unseen flight data
# ------------------------------------------------------------------------------
global_predictions <- predict(global_rf_model, data = global_test)$predictions

global_results <- global_test %>%
  mutate(predicted_wind_speed = global_predictions)

# Calculate the Mean Absolute Error (MAE)
global_mae <- mean(abs(global_results$wind_speed_mph - global_results$predicted_wind_speed))
print(paste("Global Model Test Error: The model is off by an average of", round(global_mae, 2), "mph"))

# View variable importance to see if h_speed was helpful
print("Variable Importance Scores:")
print(importance(global_rf_model))