# require 'sinatra'
# require 'sinatra/reloader'
# require 'sinatra/activerecord'
require 'http'
# require 'figaro'
require 'yaml'
FIGARO =  YAML.load_file('config/application.yml')
response = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=215+w+ohio+st&destination=Niagra+Falls&key=#{FIGARO['API_KEY']}")

response2 = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=215+w+ohio+st&destination=Niagra+Falls&&mode=transit&key=#{FIGARO['API_KEY']}")

def calculate_gas(response)
  data = response.parse["routes"][0]["legs"][0]
  distance = data["distance"]
  distance_value =  distance["value"]
  miles = distance_value/1609.344
  total = miles * 2.80
  total.round
end

def calculate_transit(response)
  data = response.parse["routes"][0]["legs"][0]
  # response.parse["routes"][0]["legs"][0]["travel_mode"]
  total = 0
  train_total = 0
  data["steps"].each do |step|
    if step["travel_mode"] == "TRANSIT"
      if step["transit_details"]["line"]['vehicle']["name"] == "Train"
        train_total += 2.50
      elsif step["transit_details"]["line"]['vehicle']["name"] == "Bus"
        total += 2.25
      end
      p "total"
      p total
      p train_total
    end    
  end
  train_total = 10 if train_total > 10
  total += train_total
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
p calculate_transit(response2)


"
Bus fare 2.25
'L' train fare  $2.50
1-Day CTA Pass  $10
Transfer(up to 2 additional rides within 2 hrs) .25

$2.80 a gallon for gas
"