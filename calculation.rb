# require 'sinatra'
# require 'sinatra/reloader'
# require 'sinatra/activerecord'
require 'http'
# require 'figaro'
require 'yaml'
FIGARO =  YAML.load_file('config/application.yml')
response = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=215+w+ohio+st&destination=Niagra+Falls&key=#{FIGARO['API_KEY']}")

def calculate_gas(response)
  data = response.parse["routes"][0]["legs"][0]
  distance = data["distance"]
  distance_value =  distance["value"]
  miles = distance_value/1609.344
  total = miles * 2.80
  total.round
end

def calculate_gas(response)
  data = response.parse["routes"][0]["legs"][0]
  distance = data["distance"]
  distance_value =  distance["value"]
  miles = distance_value/1609.344
  total = miles * 2.80
  total.round
end



data = response.parse["routes"][0]["legs"][0]
distance = data["distance"]
duration = data["duration"]
distance_text = distance["text"]
distance_value =  distance["value"]
miles = distance_value/1609.344

duration_text = duration["text"]
# duration_value =  duration["value"]
# hours = duration_value/3600.00
p calculate_gas(response)


"
Bus fare 2.25
'L' train fare  $2.50
1-Day CTA Pass  $10
Transfer(up to 2 additional rides within 2 hrs) .25

$2.80 a gallon for gas
"