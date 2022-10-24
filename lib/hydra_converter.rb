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
