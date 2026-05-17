library(tidyverse)
library(rsample)
library(ranger)
library(ggplot2)
library(yardstick)

deg_to_rad <- pi / 180
rad_to_deg <- 180 / pi

# Load complete/clean DJI Flight Records
flight_data <- read_csv("../DJI_Flight_Records/complete_cleaned_dji_flight_records.csv")

filtered_data <- flight_data %>% 
  mutate(
    pitch_rad = pitch * deg_to_rad,
    roll_rad  = roll * deg_to_rad,
    total_tilt_rad = atan(sqrt(tan(pitch_rad)^2 + tan(roll_rad)^2)),
    total_tilt = total_tilt_rad * rad_to_deg, # Convert final tilt to degrees after using formula

    # CRITICAL: Convert character text columns into factors for machine learning
    wind_dir     = as.factor(wind_dir),
    wind_rel_dir = as.factor(wind_rel_dir),
    facing_wind  = as.factor(facing_wind),
    flying_into_wind = as.factor(flying_into_wind),
  ) %>% 
  select(wind_speed_mph, total_tilt, yaw, pitch, roll, wind_dir, wind_rel_dir, facing_wind, flying_into_wind, h_speed) %>% 
  drop_na(wind_speed_mph, wind_dir, wind_rel_dir, facing_wind, flying_into_wind) # Drop rows missing wind data

# Split the data into training/testing
set.seed(42)
split_data <- initial_split(filtered_data, prop = 0.80)
train_data <- training(split_data)
test_data  <- testing(split_data)

# Train Random Forest ML Model ( ~ . uses all other columns to predict wind_speed_mph)
rf_model <- ranger(
  formula    = wind_speed_mph ~ ., 
  data       = train_data, 
  num.trees  = 600,          
  importance = "permutation" 
)
print(rf_model)

# ------- TESTING -------

# Run tests with Random Forst Model 
test_predictions <- predict(rf_model, data = test_data)

# Add predicted_wind_speed column
evaluation_data <- test_data %>%
  mutate(predicted_wind_speed = test_predictions$predictions)

# Calculate Model Performance Metrics (RMSE, Rsquared, MAE)
# Root Mean Squared Error: Model predictions off by +-
# R-Squared: The proportion of variance explained. 
# Mean Absolute Error: Median expected error, similar to RMSE. 
performance_metrics <- metrics(
  data = evaluation_data, 
  truth = wind_speed_mph, 
  estimate = predicted_wind_speed
)
print("--- MODEL PERFORMANCE METRICS ---")
print(performance_metrics)

# 4. Create an Actual vs. Predicted Visualization
ggplot(evaluation_data, aes(x = wind_speed_mph, y = predicted_wind_speed)) +
  geom_point(alpha = 0.4, color = "darkblue") +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red", linewidth = 1) +
  labs(
    title = "Drone Telemetry Wind Speed Evaluation",
    subtitle = "Random Forest Regression (Test Dataset)",
    x = "Actual Wind Speed (mph)",
    y = "Predicted Wind Speed (mph)"
  ) +
  theme_minimal()