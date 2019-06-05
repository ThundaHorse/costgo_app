require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'http'
require 'figaro'
require 'yaml'
ENV =  YAML.load_file('config/application.yml')

current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

get '/home' do 
  erb :home
end 

get '/info' do 
  response = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=215+w+ohio+st&destination=Niagra+Falls&key=#{ENV['API_KEY']}")
  @data = response.parse
  erb :index
end 