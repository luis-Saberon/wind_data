library(tidyverse)

# 1. Load your local combined dataset
flight_data <- read_csv("../DJI_Flight_Records/complete_dji_flight_records_csv.csv")

print(names(flight_data), max = 300)

# 2. Clean up the data
cleaned_flight_data <- flight_data %>% 
  select(
    # Time, Space & Tracking
    local_time = `CUSTOM.date [local]`,
    latitude     = `OSD.latitude`,
    longitude    = `OSD.longitude`,
    altitude_ft  = `OSD.altitude [ft]`,
    
    # Direct Wind Data
    wind_speed_mph      = `WEATHER.windSpeed [MPH]`,
    max_wind_speed_mph  = `WEATHER.maxWindSpeed [MPH]`,
    wind_dir            = `WEATHER.windDirection`,
    wind_rel_dir        = `WEATHER.windRelativeDirection`,
    facing_wind         = `WEATHER.isFacingWind`,
    flying_into_wind    = `WEATHER.isFlyingIntoWind`,
    
    # Actual Drone Attitude & Movement (Output)
    pitch      = `OSD.pitch`,
    roll       = `OSD.roll`,
    yaw        = `OSD.yaw [360]`,
    h_speed  = `OSD.hSpeed [MPH]`,
    dir_of_travel = `OSD.directionOfTravel`,
    
    # Pilot Commands / Sticks (Input - Fixed!)
    pilot_elevator = `RC.elevator`,
    pilot_aileron  = `RC.aileron`,
    pilot_throttle = `RC.throttle`,
    pilot_rudder   = `RC.rudder`,
  ) %>% 
  # Drop rows where wind speed
  filter(!is.na(wind_speed_mph), !is.na(dir_of_travel))

write_csv(cleaned_flight_data, "../DJI_Flight_Records/complete_cleaned_dji_flight_records.csv")
# 3. Peek at the clean dataframe
glimpse(cleaned_flight_data)