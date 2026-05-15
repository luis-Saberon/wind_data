import csv

# weather headers WEATHER.windDirection,WEATHER.windRelativeDirection,WEATHER.windSpeed [MPH],WEATHER.maxWindSpeed [MPH],WEATHER.windStrength,WEATHER.isFacingWind,WEATHER.isFlyingIntoWind,

#time headers CUSTOM.date [local],CUSTOM.updateTime [local],OSD.flyTime,OSD.flyTime [s]

#direction headers OSD.altitude [ft],OSD.mileage [ft],OSD.hSpeed [MPH],OSD.hSpeedMax [MPH],OSD.xSpeed [MPH],OSD.xSpeedMax [MPH],OSD.ySpeed [MPH],OSD.ySpeedMax [MPH],OSD.zSpeed [MPH],OSD.zSpeedMax [MPH]

mph_to_mps_conversion = 0.44704

def read_flight_record(file = "flight_record_1.csv"):
  with open(file, newline = '') as csvfile:
    fields = []
    reader = csv.DictReader(csvfile, delimiter = ',')
    # print(reader.fieldnames)
    for row in reader:
      # print(row['WEATHER.windDirection'],row['WEATHER.windRelativeDirection'],row['WEATHER.windSpeed [MPH]'])
      fields.append(row)
    return fields

#outputs a csv file of just the windspeed (converted to m/s) and timestamps in a csv in the current directory
def simple_output(inputfile = "flight_record_1.csv", output_file = "simple_output", convert_units = True):
  input_rows = read_flight_record(inputfile)
  conversion = 1
  if convert_units:
    conversion = mph_to_mps_conversion

  with open(output_file + ".csv", 'w',newline='') as csvfile:
    csvwriter = csv.writer(csvfile, delimiter = ',', quoting=csv.QUOTE_NONE, escapechar="/") #escape char should never be used, but just in case
    csvwriter.writerow(["flyTime","localTime","windSpeed"]) 

    for row in input_rows:
      windspeed = 0
      if row['WEATHER.windSpeed [MPH]'] != '':
        windspeed = float(row['WEATHER.windSpeed [MPH]'])
        windspeed = windspeed * conversion
      csvwriter.writerow([row['OSD.flyTime [s]'], row['CUSTOM.updateTime [local]'], windspeed])

if __name__ == "__main__":
  simple_output()