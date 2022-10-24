=begin
method converts a string with this input:
**********************************************************
Termite log, started at Wed Jul 27 10:04:25 2022
**********************************************************

00: 
10:03:33  07/27/22
 1:  0032.5  C          2:  0037.8  C          3:  0037.5  C       
 4:  0039.9  C          5:  0038.6  C          6:  0039.8  C       
ALM:15  DIO:255  TOTAL:0
14: 
10:03:48  07/27/22
 1:  0032.6  C          2:  0037.8  C          3:  0037.5  C       
 4:  0039.9  C          5:  0038.6  C          6:  0039.8  C       
ALM:15  DIO:255  TOTAL:0
29: 
10:04:03  07/27/22
 1:  0032.6  C          2:  0037.8  C          3:  0037.5  C       
 4:  0039.9  C          5:  0038.6  C          6:  0039.8  C       
ALM:15  DIO:255  TOTAL:0

**********************************************************
Termite log, started at Wed Jul 27 10:05:10 2022
**********************************************************

10:04:18  07/27/22
 1:  0032.6  C          2:  0037.8  C          3:  0037.4  C       
 4:  0039.9  C          5:  0038.7  C          6:  0039.7  C       
ALM:15  DIO:255  TOTAL:0

10:04:33  07/27/22
 1:  0032.7  C          2:  0037.8  C          3:  0037.4  C       
 4:  0039.9  C          5:  0038.7  C          6:  0039.7  C       
ALM:15  DIO:255  TOTAL:0


to a csv with this output:

Date, Time, CH1, CH2, CH3, CH4, CH5, CH6
07/27/22, 10:03:33, 32.5, 37.8, 37.5, 39.9, 38.6, 39.8
07/27/22, 10:03:48, 32.6, 37.8, 37.5, 39.9, 38.6, 39.8


D: nested array

A:
initialize a result array where the first element is an array 
  containing the static title values

parse the input string into an array where each element is a string representing each time entry
  split the string using a regex which matches an empty line (two consecutive line breaks) OR
    a line containing two digits and a colon
iterate through the time entries, and for each:
  extract the date, time, and data points into an 8 element array
  add the array into a result array which represents the parsed input data

take the parsed data array, and prepend the title values row
iterate through the rows and for each row, 
  join the elements into a string delimited by commas
join the top-level array into a string delimited by line-breaks


=end


def extract_data_points(input_str)
  time_entries = input_str.gsub("\r", '').split(/\n\n/).select do |str|
    str =~ /\d\d\/\d\d\/\d\d/
  end

  time_entries[0] = time_entries[0].split(/\d\d: \n/)
  time_entries[0].shift
  time_entries.flatten!

  time_entries.map do |entry|
    pattern = /(\d\d:\d\d:\d\d)  (.*)\n 1: +(\S+) +.* 2: +(\S+) +.* 3: +(\S+) +.*\n 4: +(\S+) +.* 5: +(\S+) +.* 6: +(\S+) +/
    caps = entry.match(pattern)
    [caps[2], caps[1], caps[3], caps[4], caps[5], caps[6], caps[7], caps[8]]
  end
end

def convert_hydra_to_CSV(input_str)
  title_row = ['Date', 'Time', 'CH1', 'CH2', 'CH3', 'CH4', 'CH5', 'CH6']

  data_points = extract_data_points(input_str)
  data_points.unshift(title_row)
  data_points.map{ |row| row.join(', ') }.join("\n")
end


trash_input = <<~HYD
**********************************************************
Termite log, started at Wed Jul 27 10:04:18 2022
**********************************************************

**********************************************************
Termite log, started at Wed Jul 27 10:04:25 2022
**********************************************************

00: 
10:03:33  07/27/22
 1:  0032.5  C          2:  0037.8  C          3:  0037.5  C       
 4:  0039.9  C          5:  0038.6  C          6:  0039.8  C       
ALM:15  DIO:255  TOTAL:0
14: 
10:03:48  07/27/22
 1:  0032.6  C          2:  0037.8  C          3:  0037.5  C       
 4:  0039.9  C          5:  0038.6  C          6:  0039.8  C       
ALM:15  DIO:255  TOTAL:0
29: 
10:04:03  07/27/22
 1:  0032.6  C          2:  0037.8  C          3:  0037.5  C       
 4:  0039.9  C          5:  0038.6  C          6:  0039.8  C       
ALM:15  DIO:255  TOTAL:0

**********************************************************
Termite log, started at Wed Jul 27 10:05:10 2022
**********************************************************

10:04:18  07/27/22
 1:  0032.6  C          2:  0037.8  C          3:  0037.4  C       
 4:  0039.9  C          5:  0038.7  C          6:  0039.7  C       
ALM:15  DIO:255  TOTAL:0

10:06:18  07/27/22
 1:  0032.7  C          2:  0037.8  C          3:  0037.4  C       
 4:  0040.0  C          5:   OTC    C          6:  0039.4  C       
ALM:15  DIO:255  TOTAL:0
HYD

puts convert_hydra_to_CSV(trash_input)