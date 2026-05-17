# -*- coding: utf-8 -*-
"""
Created on Thu May 25 14:14:59 2023

Function to process a raw anemometer datalogger file to correct for minor
real-time clock issues and to put a unique timestamp to each record in 
decimal day format

@author: Stuart Stevenson stuart.stevenson@nrc-cnrc.gc.ca
Copyright 2023 National Research Council Canada
"""

##################################################################################
# IMPORTS
##################################################################################

from numpy import linspace
from functools import partial

##################################################################################
# USER VARIABLES
##################################################################################

raw_anemometer_file = 'C:\\Users\\walla\\Desktop\\CITY23\\sonicdata\\210923\\AS152910.CSV'

output_file_suffix = '_proc'

# You can use a UTC offset to correct for local time zone, 
# note however TestSLATE uses uncorrected UTC time, leave as 0 if merging 

UTC_offset = 0

DEBUG_output = True

##################################################################################
# process_raw_anemometer_file function
##################################################################################

# Function to read and process a raw sonic anemometer datalogger file.
# Function corrects for known issues with onboard RTC where hours or minutes
# sometimes update before seconds. Args are input raw file path, output file path,
# optional utc to local timezone offset in hours (EDT = -4) and optional console
# debug output
# This function will overwite an existing file at the output file path without
# warning

def process_raw_anemometer_file(raw_file_path,output_file_path,utc_offset=0,
                                debug_output=False):
  
  good_char_list = ['$','I','M','V','W','1','2','3','4','5','6','7','8','9','0',
                    '-',' ','.',',','R','A','*','a','b','c','d','e','f','\r']
  # Do not allow user to accidentally overwrite the raw file
  if raw_file_path == output_file_path:
    raise ValueError('Input and output file paths must be different')

  raw_data = []
  line = ''
  # First rip the raw file into memory
  with open(raw_file_path,'rb') as openfile:
    for byte in iter(partial(openfile.read,1),b''):
      try:
        if byte == b'\r':
          char = byte.decode('utf-8')
          line = line + char

          if len(line) <= 70:
            raw_data.append(line)
          line = ''
        else:

          char = byte.decode('utf-8')
          # print(char)
          if char in good_char_list:
            line = line + char

      except UnicodeDecodeError:
        print("Unicode decode error")
      
  """  
  with open(raw_file_path,'r') as openfile:
    for line in openfile:
      raw_data.append(line)
  """
  # Figure out if it's a 2d or 3d file
  if len(raw_data[0].split(',')) > 2:
    sample_rate = 10
  else:
    sample_rate = 5
    
  # Now we need to find 10 good records in a row so we have a good start time
  try:
    start_time = int(raw_data[0].split(',')[0])
  except ValueError:
    start_time = 0

    
  start_idx = 0
  good_count = 1
  
  work_idx = 1

  # Keep looping until we find 10 timestamps in a row that match
  while good_count < sample_rate:
    
    # This just prevents a corrupted line from crashing the script
    try:
     work_time = int(raw_data[work_idx].split(',')[0])
    except ValueError:
      work_time = 0
    except IndexError:
      print(raw_data[0])
      
    if work_time == start_time:
      good_count += 1
      
    else:
      start_idx = work_idx
      start_time = work_time
      good_count = 1

    work_idx += 1 
  
  # End while good count < 10
  
  if debug_output:
    print('Found first good timestamp '+str(start_time)+' at idx '+str(start_idx))

  EOF = False
  data_out = []
  
  while not EOF:  

    # Now look 100 records forward for the same 10 times in a row
    # First check that there are at least 10100 records to go
    
    if work_idx + 120 >= len(raw_data):
      
      # There are not at least 10100 records left, start at the last record and 
      # work backwards to find the last 10 identical timestamps
      # set the EOF flag so the main while doesn't trigger anymore
      EOF = True
      
      # Skip the very last line as it is likely blank
      end_idx = len(raw_data) - 2 
      
      try:
        end_time = int(raw_data[end_idx].split(',')[0])
      except ValueError:
        end_time = 0
        
      work_idx = end_idx - 1
      good_count = 1
      
      while good_count < sample_rate:
        
        try:
          work_time = int(raw_data[work_idx].split(',')[0])
        except ValueError:
          work_time = 0
          
        if work_time == end_time:
          good_count += 1
        
        else:
          end_time = work_time
          end_idx = work_idx
          good_count = 1
        
        work_idx -= 1
      
      # End while good count < 10
      
      if debug_output:
        print('Found file end time '+str(end_time)+' ad idx '+str(end_idx))
    
    # Otherwise we're not at the end the end of the file yet
    else:
      work_idx += 100
      
      try:
        end_time = int(raw_data[work_idx].split(',')[0])
      except ValueError:
        end_time = 0
      
      good_count = 1
      work_idx += 1

      # Keep looping until we find 10 timestamps in a row that match
      while good_count < sample_rate:
        
        # This just prevents a corrupted line from crashing the script
        try:
          work_time = int(raw_data[work_idx].split(',')[0])
        except ValueError:
          work_time = 0
          
        if work_time == end_time:
          good_count += 1
          end_idx = work_idx
          
        else:
          end_idx = work_idx
          end_time = work_time
          good_count = 1
      
        work_idx += 1 
      
      # End while good count < 10
      
      if debug_output:
        print('Found section end time '+str(end_time)+' at idx '+str(end_idx))
    
    # End if work_idx + 10100 >= len(raw_data)
    
    # Now we have a start and end time, create an interpolated time vector,
    # prepend it to each record and add them to the data_out
    
    start_time_EU = ( ( (start_time // 10000) + utc_offset) / 24.) + \
                    ( ( (start_time % 10000) // 100 ) / 1440.) + \
                    ( (start_time % 100) / 86400. )
    


    if debug_output:
      print('Converted '+str(start_time)+' in HHMMSS to '+str(start_time_EU)+\
            ' in .dddddd')

    
    end_time_EU = ( ( (end_time // 10000) + utc_offset) / 24.) + \
                  ( ( (end_time % 10000) // 100 ) / 1440.) + \
                  ( ( (end_time % 100) +0.9) / 86400. )
    
    
    try:
      time_vector = linspace(start_time_EU, end_time_EU,num=end_idx-start_idx+1)

      if debug_output:
        print('Check '+str(end_idx)+' == '+str(start_idx+(end_idx-start_idx)))

      
      idx_delta = (end_idx - start_idx) / sample_rate
      
      EU_delta = (end_time_EU - start_time_EU) * 86400
      
      if EU_delta < idx_delta + 3: 
        for record_idx in range(end_idx-start_idx+1):
          data_out.append(str(round(time_vector[record_idx],6))+','+
                          raw_data[start_idx+record_idx])
      else:
        if debug_output:
          print('Time Skip from '+str(start_time)+' to '+str(end_time))
        if debug_output:
          print('idx = '+str(round(idx_delta,1))+' EU = '+str(round(EU_delta,1)))
    
    except ValueError:
      pass
    
    # Now since we just found a good end time, assume next record is a good start
    # time for the next iteration
    
    start_idx = end_idx + 1
    
    if end_time % 100 < 59:
      start_time = end_time + 1
    else:
      # End time is 59 seconds, need to increment minute
      if (end_time % 10000) // 100 < 59:
        start_time = end_time - 59 + 100
      else:
        # End time is 59 minutes, need to increment hour
        start_time = end_time - 5959 + 10000
    
    
  # End while not EOF
  
  # write data_out to file and we're done
  with open(output_file_path,'w') as openfile:

    #write field headers
    openfile.write("decimalTime,dateTime,uWind (E-W),vWind (N-S),wWind (Vert),Temp,speedOfSound\n")
    for record in range(len(data_out)):
      
      #very hack way to fix formatting
      replaced = data_out[record].replace(',', " ")
      replaced = replaced.replace("   ", "")
      replaced = replaced.replace('  ', " ")
      replaced = replaced.replace(' ', ",")
      openfile.write(replaced)
  

##################################################################################
# Main Section
##################################################################################

# This convention allows this script to be called directly using the user
# variables to control execution or to be used as an include in other scripts

if __name__ == '__main__':
  
  # if output_file_suffix == '':
  #   raise ValueError('Output suffix can not be blank.')
  # else:
  #   output_filename = raw_anemometer_file.split('.')[0] + output_file_suffix + \
  #                     '.' + raw_anemometer_file.split('.')[1]
    
  #   process_raw_anemometer_file(raw_anemometer_file,output_filename,
  #                               utc_offset=UTC_offset,debug_output=DEBUG_output)

  process_raw_anemometer_file("GR000000.CSV", "output_anemometer.csv", utc_offset=UTC_offset, debug_output=DEBUG_output)
  # process_raw_anemometer_file("GV214130.CSV", "output_anemometer.csv", utc_offset=UTC_offset, debug_output=DEBUG_output)
  
