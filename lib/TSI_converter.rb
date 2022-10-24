=begin
method converts this string:

ESS:TESTSTAND:X-601:ET100,2022/10/19 16:29:20,0.000000
ESS:TESTSTAND:X-601:ET102,2022/10/19 16:29:20,0.005203
ESS:TESTSTAND:X-601:FT340,2022/10/19 16:29:20,0.000000

to CSV format:
Date, Time, ET100, ET102, FT340,
2022/10/19, 16:29:20, 0.000000, 0.05203, 0.000000

assumptions:
- the input string represents a large number of input nodes, which eventually repeat
with new time snapshots.
- nodes always occur in the same order for each time data point




D: 
nested array? - data needs to be ordered.
[['Date', 'Time', 'ET100', 'ET102', 'FT340'], ['2022/10/19', '16:29:20', '0.000000', '0.05203', '0.000000']]


A:
initialize a result array
push on a two element array containg the strings 'Date' and 'Time'

split the input string into an array of lines
  create a new array of lines array with a sub-array for each line where:
  the first element in the subarray is the node title
  the second element in the subarray is the date
  the third element in the subarray is the time point
  the fourth element in the subarray is the data value

set a variable `start_time` to the time in the first line
iterate through the array of lines, until the current line has a time different from the start_time:
  get the node title, and push it onto the first sub-array of the result array
(alternatively, just get all of the unique node titles from the array of lines)

get all of the unique times from the array of lines:
for each unique time, 
  add a new sub-array to the results array
  push on the date and the current time point as elements
  push on `nil` until the length of the new sub-array equals the length of the first sub-array in result array

iterate through the array of lines and for each:
  extract the time
  extract the node title
  extract the data value
  find the index of the probe title in the first result sub-array
  find the index of the subarray for the time point
  add the data value into the subarray at the identified position

join the elements of each sub-array in the result array into a string with ', ' as the delimiter
join the elements of the result array into a string with '\n' as the delimiter

=end

def extract_data(str)
  str.split("\n").map do |line|
    tsi_regex = /ESS:TESTSTAND:.+:(.*),(.*\/.*\/.*) (.*),([\.\d]*)/
    matches = line.match(tsi_regex)
    [matches[1], matches[2], matches[3], matches[4]]
  end
end

def add_probe_titles(title_row, array_of_lines)
  probe_titles = array_of_lines.uniq(&:first).map(&:first)
  probe_titles.each { |probe_title| title_row << probe_title }
end

def add_time_points(result, array_of_lines)
  unique_date_time = array_of_lines.uniq{ |line| line[2] }.map do |line|
    [line[1], line[2]]
  end

  column_count = result[0].size

  unique_date_time.each do |date_time|
    (column_count - 2).times { date_time << nil }
    result << date_time
  end
end

def add_data_values(result, array_of_lines)
  array_of_lines.each do |line|
    time = line[2]
    probe = line[0]
    datum = line[3]

    probe_idx = result[0].index(probe)
    time_idx = result.index { |time_pt| time_pt[1] == time }
    result[time_idx][probe_idx] = datum
  end
end

def convert_TSI_to_CSV(input_str)
  result = [['Date', 'Time']]

  array_of_lines = extract_data(input_str)
  add_probe_titles(result[0], array_of_lines)
  add_time_points(result, array_of_lines)
  add_data_values(result, array_of_lines)
  
  result.map{|row| row.join(', ')}.join("\n")
end


# input_string =<<~TSI
#   ESS:TESTSTAND:X-601:ET100,2022/10/19 16:29:20,0.000000
#   ESS:TESTSTAND:X-601:ET102,2022/10/19 16:29:20,0.005203
#   ESS:TESTSTAND:X-601:FT340,2022/10/19 16:29:20,0.000000
#   ESS:TESTSTAND:X-601:ET100,2022/10/19 16:29:24,0.000200
#   ESS:TESTSTAND:X-601:ET102,2022/10/19 16:29:24,0.004000
#   ESS:TESTSTAND:X-601:FT340,2022/10/19 16:29:24,0.060000
# TSI

# puts convert_TSI_to_CSV(input_string)
