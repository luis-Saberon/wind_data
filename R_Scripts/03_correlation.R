library(tidyverse)

# 1. Load your local complete and cleaned dataset
flight_data <- read_csv("../DJI_Flight_Records/complete_cleaned_dji_flight_records.csv")

numeric_cor <- flight_data %>% 
  select(where(is.numeric)) %>% 
  cor(method = "pearson", use = "complete.obs")
cor(numeric_cor , method="pearson")

install.packages("ggcorrplot")
library(ggcorrplot)

# Assuming you saved your correlation matrix as 'my_cor_matrix'
ggcorrplot(cor(numeric_cor , method="pearson"), 
           hc.order = TRUE, 
           type = "lower",
           lab = TRUE, 
           lab_size = 3, 
           colors = c("#6D9EC1", "white", "#E46726"),
           title = "Drone Flight Data Correlation Heatmap",
           ggtheme = theme_minimal())

# Finding: 

# Pitch and Horizontal Speed (h_speed): $r = -0.83$: The Takeaway: This strong negative 
# correlation is pure drone physics. To move forward and gain horizontal speed, a drone 
# must pitch forward (tilt down). In many telemetry logs, pitching forward is recorded 
# as a negative angle, perfectly explaining why speed goes up as the pitch angle goes down.

# Yaw and Direction of Travel (dir_of_travel): $r = 0.95$: The Takeaway: A near-perfect 
# positive correlation. As the drone rotates its nose (yaw), its actual heading changes 
# almost identically. This means the drone is likely flying straight ahead relative to its 
# body axis most of the time, rather than drifting sideways.

# Pilot Elevator and Pitch / Speed ($r = -0.87$ and $0.84$): The pilot's elevator input 
# (pushing the stick forward/backward) has a massive correlation with both pitch ($-0.87$) 
# and h_speed ($0.84$). This tells you the aircraft is highly responsive to the pitch controls, 
# and the pilot is actively controlling the forward velocity.

# Wind Speed vs. Pitch: $r = 0.63$: When wind speed goes up, the drone's pitch angle 
# increases positively (tilts back). This suggests that the drone has to fight the wind 
# to stay stable or maintain position, forcing it to tilt against the incoming air vector.

# Wind Speed vs. Horizontal Speed (h_speed): $r = -0.38$: A moderate negative correlation 
# indicating that higher wind speeds generally drag down the drone's ground speed, likely 
# because it's spending more energy fighting the wind than moving forward.