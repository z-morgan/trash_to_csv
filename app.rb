require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'

require_relative "lib/TSI_converter"
require_relative "lib/hydra_converter"

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

post "/" do
  @raw = params[:raw]

  if params[:algorithm] == "Hydra"
    @csv_data = convert_hydra_to_CSV(@raw)
  elsif params[:algorithm] == "TSI"
    @csv_data = convert_TSI_to_CSV(@raw)
  end

  erb :index
end