import csv
import time
# weather headers WEATHER.windDirection,WEATHER.windRelativeDirection,WEATHER.windSpeed [MPH],WEATHER.maxWindSpeed [MPH],WEATHER.windStrength,WEATHER.isFacingWind,WEATHER.isFlyingIntoWind,

#time headers CUSTOM.date [local],CUSTOM.updateTime [local],OSD.flyTime,OSD.flyTime [s]

#direction headers OSD.altitude [ft],OSD.mileage [ft],OSD.hSpeed [MPH],OSD.hSpeedMax [MPH],OSD.xSpeed [MPH],OSD.xSpeedMax [MPH],OSD.ySpeed [MPH],OSD.ySpeedMax [MPH],OSD.zSpeed [MPH],OSD.zSpeedMax [MPH]

mph_mps_conversion = 0.44704

def read_flight_record(file = "flight_record_1.csv"):
  with open(file, newline = '') as csvfile:
    fields = []
    reader = csv.DictReader(csvfile, delimiter = ',')
    for row in reader:

      fields.append(row)
    
    return fields

#outputs a csv file of just the windspeed (converted to m/s) and timestamps in a csv in the current directory
def simple_output(input_file = "flight_record_1.csv", output_file = "simple_output", convert_units = True):
  input_rows = read_flight_record(input_file)
  conversion = 1
  if convert_units:
    conversion = mph_mps_conversion

  with open(output_file + ".csv", 'w',newline='') as csvfile:
    csvwriter = csv.writer(csvfile, delimiter = ',', quoting=csv.QUOTE_NONE, escapechar="/") #escape char should never be used, but just in case
    csvwriter.writerow(["decimalTime","flyTime","localTime","windSpeed"]) 

    for row in input_rows:
      windspeed = 0
      if row['WEATHER.windSpeed [MPH]'] != '':
        windspeed = float(row['WEATHER.windSpeed [MPH]'])
        windspeed = windspeed * conversion
      windTime = row['CUSTOM.updateTime [local]']
      hours = int(windTime[0:1])
      minutes = int(windTime[2:4])
      seconds = int(windTime[5:7])
      milliseconds = int(windTime[8:10])
      print(milliseconds)
      a_or_p = windTime[11:]
      seconds = seconds + (milliseconds / 1000)
      if a_or_p == "PM":
        hours = hours + 12

      windDecimalTime = (hours / 24.) + (minutes / 1440.) + (seconds/86400) 

      csvwriter.writerow(["{:.7f}".format(windDecimalTime), row['OSD.flyTime [s]'], f"{hours}:{minutes}:{seconds}", windspeed])


#syncs up 2 csv files using the column decimalTime
#returns the index of the 2 lists where they are most synced up
def sync_files(file_1, file_2):
  file_1_rows = read_flight_record(file_1)
  file_2_rows = read_flight_record(file_2)
  
  if file_1_rows[0]["decimalTime"] < file_2_rows[0]["decimalTime"]:
    pass
  if file_1_rows[0]["decimalTime"] > file_2_rows[0]["decimalTime"]:
    pass
  else:
    return (0,0)

#syncs the list so that the start index of lesser is as close as possible to the start of greater
def sync_list(lesser, greater):
  cur_idx = 0
  try:
    while lesser[cur_idx]["decimalTime"] < greater[0]["decimalTime"]:
      cur_idx += 1
    
    last_idx = cur_idx - 1 
    cur_idx_diff = lesser[cur_idx]["decimalTime"] - greater[0]["decimalTime"]
    last_idx_diff = lesser[last_idx]["decimalTime"] - greater[0]["decimalTime"]

    if abs(cur_idx_diff) < abs(last_idx_diff):
      return (cur_idx_diff, 0)
    else:
      return (last_idx_diff, 0)
  except IndexError:
    #the lists are not related at all, have no related times
    return(-1, 0)

if __name__ == "__main__":
  simple_output()