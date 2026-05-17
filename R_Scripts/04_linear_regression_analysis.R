library(tidyverse)
library(rsample)
library(ranger)

deg_to_rad <- pi / 180
rad_to_deg <- 180 / pi

# Load complete/cleaned DJI Flight Records
flight_data <- read_csv("../DJI_Flight_Records/complete_cleaned_dji_flight_records.csv")

# Calculate the Inclination Angle (Total Tilt)
# In 3D space, an inclination angle generally measures the tilt or angle of an 
# object (a line, plane, or axis) relative to a fixed reference plane (like the horizontal) 
# or a reference direction (like the vertical zenith. This formula is calculating 
# the true 3D inclination angle of the drone from its pitch and roll. 
                                                                                                                                                                                                 
hover_data <- flight_data %>%  
  filter(h_speed == 0) %>% # Remove tilting for movement, keep just to fight the wind.
  mutate(
    # 1. Convert pitch and roll from degrees to radians
    pitch_rad = pitch * deg_to_rad,
    roll_rad  = roll * deg_to_rad,
    
    # 2. Apply formula
    total_tilt_rad = atan(sqrt(tan(pitch_rad)^2 + tan(roll_rad)^2)),
    
    # 3. Convert the final tilt back into degrees for your model
    total_tilt = total_tilt_rad * rad_to_deg
  ) %>%  
  select(wind_speed_mph, total_tilt, pitch, roll, yaw) %>%  
  drop_na(wind_speed_mph)

# Split the data into training/testing
set.seed(42)
split_data <- initial_split(hover_data, prop = 0.80)
train_data <- training(split_data)
test_data  <- testing(split_data)

# Create Linear Regression Model
lr_model <- lm(wind_speed_mph ~ total_tilt, data = train_data)
summary(lr_model)

# total_tilt Estimate (0.133299): This means that for every 1 degree your drone 
# tilts, the wind speed is expected to increase by roughly 0.13 mph.
# 
# Pr(>|t|) (< 2e-16 ***): This is your p-value. It is essentially zero. The three 
# asterisks *** mean it is highly statistically significant. The mathematical 
# relationship between the drone's tilt and the wind speed isn't a random fluke or 
# a coincidence.
# 
# An $R^2$ of 0.0106 means that your total_tilt variable explains only 1.06% of the 
# variance in wind speed. The other 98.94% of what determines the wind speed is 
# completely unaccounted for by a simple straight line.

# An $R^2$ of 0.2112 (or 21.12%) tells you that your mathematically exact total_tilt 
# variable is successfully capturing and explaining roughly 21% of the variation in 
# the wind speed data when the drone is hovering, but a single straight line is too 
# primitive a tool to map the full engineering reality.
