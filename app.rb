require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'

# require_relative "lib/TSI_converter"
# require_relative "lib/hydra_converter"

configure :development do
  set :server, 'webrick'
  also_reload 'lib/*.rb'
end

configure do
  enable :sessions
  set :session_secret, "secret"
end

get "/" do
  erb :index
end

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

post "/" do
  @raw = params[:raw]

  if params[:algorithm] == "Hydra"
    @csv_data = convert_hydra_to_CSV(@raw)
  elsif params[:algorithm] == "TSI"
    @csv_data = convert_TSI_to_CSV(@raw)
  end

  erb :index
end