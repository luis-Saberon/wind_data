library(tidyverse)
library(ggcorrplot)

# The Pearson correlation coefficient (r) measures the strength and direction of 
# the linear relationship between two continuous variables. The interpretation depends
# on the context. 

# Load complete/cleaned DJI Flight Records
flight_data <- read_csv("../DJI_Flight_Records/complete_cleaned_dji_flight_records.csv")

numeric_cor <- flight_data %>% 
  select(where(is.numeric)) %>% # Calculates correlation coefficient on NUMERIC columns
  cor(method = "pearson", use = "complete.obs") # complete.obs skips rows with incomplete data

ggcorrplot(numeric_cor, 
           hc.order = TRUE, 
           type = "lower",
           lab = TRUE, 
           lab_size = 3, 
           colors = c("#6D9EC1", "white", "#E46726"),
           title = "Drone Flight Data Correlation Heatmap",
           ggtheme = theme_minimal())

# Yaw and Direction of Travel ($r = 0.80$): There is a strong positive correlation 
# ($0.80$) between yaw (the direction the drone's nose is pointing) and dir_of_travel 
# (the compass heading the drone is moving).

# Pitch vs. Controls (h_speed & pilot_elevator) ($r = -0.47$ and $-0.54$): This 
# aligns with drone physics. When the pilot pushes the elevator stick forward 
# (negative input/deflection), the drone tilts its nose down (negative pitch) to 
# generate forward thrust, causing the horizontal speed (h_speed) to increase.

# Wind Speed vs. Pitch ($r = 0.43$): This indicates the drone's flight controller 
# adjusting to environmental forces. As the wind picked up, the drone had to 
# pitch/tilt backward slightly to counter the wind vector and maintain its position 
# or trajectory.

# The low correlations of pilot_aileron and pilot_rudder might indicate straight
# forward moving flights than sharp turns and bends.
