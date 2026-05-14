import csv

# weather headers WEATHER.windDirection,WEATHER.windRelativeDirection,WEATHER.windSpeed [MPH],WEATHER.maxWindSpeed [MPH],WEATHER.windStrength,WEATHER.isFacingWind,WEATHER.isFlyingIntoWind,

#time headers CUSTOM.date [local],CUSTOM.updateTime [local],OSD.flyTime,OSD.flyTime [s]

#direction headers OSD.altitude [ft],OSD.mileage [ft],OSD.hSpeed [MPH],OSD.hSpeedMax [MPH],OSD.xSpeed [MPH],OSD.xSpeedMax [MPH],OSD.ySpeed [MPH],OSD.ySpeedMax [MPH],OSD.zSpeed [MPH],OSD.zSpeedMax [MPH]



def read_flight_record(file = "flight_record_1.csv"):
  with open(file, newline = '') as csvfile:
    reader = csv.DictReader(csvfile, delimiter = ',')
    # print(reader.fieldnames)
    for row in reader:
      print(row['WEATHER.windSpeed [MPH]'], row['CUSTOM.updateTime [local]'], row['OSD.flyTime [s]'])
    # for row in reader:
    #   print(row['WEATHER.windDirection'],row['WEATHER.windRelativeDirection'],row['WEATHER.windSpeed [MPH]'])
    return reader

#outputs a csv file of just the windspeed (converted to m/s) and timestamps
def simple_output(file = "flight_record_1.csv"):
  pass

if __name__ == "__main__":
  read_flight_record()