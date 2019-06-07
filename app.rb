require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'http'
require 'figaro'
require 'yaml'
require 'pry'
require_relative './helpers/calculation.rb'

FIGARO = YAML.load_file('config/application.yml')

current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

get '/back_to_home' do 
  redirect '/home'
end 

get '/home' do 
  erb :home
end 

get '/info' do 
  origin = params[:origin]
  formatted_origin = origin.split(" ").join('+')
  destination = params[:destination]
  formatted_destination = destination.split(" ").join('+')

  response = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{formatted_origin}&destination=#{formatted_destination}&key=#{FIGARO['API_KEY']}")

  transit_response = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{formatted_origin}&destination=#{formatted_destination}&&mode=transit&key=#{FIGARO['API_KEY']}")

  @data = response.parse
  @transit_data = transit_response.parse 
  erb :index
end 


