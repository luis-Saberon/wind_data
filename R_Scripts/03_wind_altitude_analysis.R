library(tidyverse)

# 1. Load your local complete and cleaned dataset
flight_data <- read_csv("../DJI_Flight_Records/complete_cleaned_dji_flight_records.csv")

# 2 Filter for clean flight segments
wind_profile_data <- flight_data %>% 
  filter(
    altitude_ft > 5,             # Ignore ground/takeoff noise
    !is.na(wind_speed_mph),      # Ensure wind speed exists
    wind_speed_mph > 0           # Remove flat zeros (usually errors)
  )

# Simple linear regression: Wind Speed explained by Altitude
wind_alt_model <- lm(wind_speed_mph ~ altitude_ft, data = wind_profile_data)

# See the statistical summary
summary(wind_alt_model)

# Swapping the axes: Altitude on X, Wind Speed on Y
ggplot(wind_profile_data, aes(x = altitude_ft, y = wind_speed_mph)) +
  # Add points with a nice sky-blue color and transparency
  geom_point(color = "deepskyblue4", alpha = 0.2, size = 1) +
  
  # Add the linear regression trendline running left-to-right
  geom_smooth(method = "lm", color = "darkred", linewidth = 1.2) +
  
  # Clean, professional look for slides
  theme_minimal(base_size = 14) +
  labs(
    title = "Wind Speed Explained by Flight Altitude",
    subtitle = paste("Standard Statistical Layout (R² =", 
                     round(summary(wind_alt_model)$r.squared, 2), ")"),
    x = "Drone Flight Altitude (Feet Above Ground)",
    y = "Measured Wind Speed (MPH)",
    caption = "Source: Aggregated DJI Telemetry Logs"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    panel.grid.minor = element_blank()
  )