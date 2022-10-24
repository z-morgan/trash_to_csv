def extract_data(str)
  str.split("\n").map do |line|
    tsi_regex = /\w+:\w+:.+:(.*),(.*\/.*\/.*) (.*),([\.\d]*)/
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