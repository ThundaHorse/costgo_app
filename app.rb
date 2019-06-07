require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'http'
require 'figaro'
require 'yaml'
require 'pry'

ENV = YAML.load_file('config/application.yml')

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
  response = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{formatted_origin}&destination=#{formatted_destination}&key=#{ENV['API_KEY']}")
  response_2 = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=215+w+ohio+st&destination=Niagra+Falls&&mode=transit&key=#{ENV['API_KEY']}")

  @data = response.parse
  @data2 = response_2.parse 

  erb :index
end 


