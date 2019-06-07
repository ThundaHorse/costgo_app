def calculate_gas(response)
  data = response["routes"][0]["legs"][0]
  distance = data["distance"]
  distance_value =  distance["value"]
  miles = distance_value/1609.344
  total = miles * 2.80
  total.round
end

def calculate_transit(response)
  data = response["routes"][0]["legs"][0]
  total = 0
  train_total = 0
  data["steps"].each do |step|
    if step["travel_mode"] == "TRANSIT"
      if step["transit_details"]["line"]['vehicle']["name"] == "Train"
        train_total += 2.50
      elsif step["transit_details"]["line"]['vehicle']["name"] == "Bus"
        total += 2.25
      end
    end    
  end
  train_total = 10 if train_total > 10
  total += train_total
  return 'fdsfdslfdsfds'
end 

