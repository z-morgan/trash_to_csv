require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'

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
  @csv_data = @raw.upcase
  erb :index
end