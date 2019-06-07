require 'http'
require 'yaml'
FIGARO =  YAML.load_file('config/application.yml')


class Trip
  attr_accessor :car_time_text, :car_time_value, :car_hours, :transit_time_text, :transit_time_value, :transit_hours, :gas_cost, :transit_cost,  :start_location, :end_location

  # def initialize(trip_data)
  def initialize(start_location, end_location, toll_type="prepaid")
    # @response_car = trip_data: "car_http"
    # @response_transit = trip_data: "transit_http"
    # @response_toll = trip_data: "toll_http"
    # @start_location = trip_data: start_location
    # @end_location = trip_data: end_location

    @response_car = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=215+w+ohio+st&destination=Niagra+Falls&key=#{FIGARO['API_KEY']}")
    @response_transit = HTTP.get("https://maps.googleapis.com/maps/api/directions/json?origin=215+w+ohio+st&destination=Niagra+Falls&&mode=transit&key=#{FIGARO['API_KEY']}")
    @response_toll = HTTP.headers("x-api-key" => 'DQ50B1qFE0ao4mo4oYAFG8qE2uJRfyrQ6jOYUOqN', "Content-Type" => "application/json").post(
                        'https://dev.tollguru.com/beta00/calc/gmaps',
                        json: {
                              "from": {"address": start_location},
                              "to": {"address": end_location}
                            })
    @start_location = start_location
    @end_location = end_location
    @car_time_text = 0
    @car_time_value = 0
    @car_hours = @car_time_value/3600.00  
    @transit_time_text = 0
    @transit_time_value = 0
    @transit_hours = @transit_time_value/3600.00  
    @toll = calculate_toll(trip_data: "toll_type")
    @gas_cost = calculate_gas
    @transit_cost = calculate_transit
  end

  def calculate_toll(toll_type)
    prepaid_toll = @response_toll.parse["routes"][0]["costs"]["prepaidCard"]
    cash_toll = @response_toll.parse["routes"][0]["costs"]["cash"]
    if toll_type == "cash"
      return cash_toll
    else
      return prepaid_toll
    end
  end

  def calculate_gas
    data = @response_car.parse["routes"][0]["legs"][0]
    @car_time_text = data["duration"]["text"]
    @car_time_value = data["duration"]["value"]
    distance = data["distance"]
    distance_value =  distance["value"]
    miles = distance_value/1609.344
    mpg = miles/mph_per_car
    total = mpg * gas_per_location
    total += @toll
    total.round 
  end

  def calculate_transit
    bus_fare = 2.25
    # Transfer(up to 2 additional rides within 2 hrs) .25
    l_train_fare = 2.50
    day_cta_pass = 10
    data = @response_transit.parse["routes"][0]["legs"][0]
    @transit_time_text = data["duration"]["text"]
    @transit_time_value = data["duration"]["value"]
    total = 0
    train_total = 0
    data["steps"].each do |step|
      if step["travel_mode"] == "TRANSIT"
        if step["transit_details"]["line"]['vehicle']["name"] == "Train"
          train_total += l_train_fare
        elsif step["transit_details"]["line"]['vehicle']["name"] == "Bus"
          total += bus_fare
        end
      end    
    end
    train_total = 10 if train_total > 10
    total += train_total
  end

  def gas_per_location
    gas = 2.80
    # @response_toll.parse["routes"].each do |data|
    #   if data["costs"]["prepaidCard"] != nil
    #     prepaid_toll += data["costs"]["prepaidCard"]
    #     cash_toll += data["costs"]["cash"]
    #     gas = data["costs"]["fuel"]
    #   end
    # end
  end

  def mph_per_car
    mph = 22.0
  end
end





trip = Trip.new("Milwaukee, WI", "Chicago, IL")
# p trip
p trip.car_time_text
p trip.car_time_value
p trip.car_hours
p trip.transit_time_text
p trip.transit_time_value
p trip.transit_hours






# def calculate_toll(input_data)
#   # ["routes"][0]["costs"][0]
#   cash = 0
#   prepaid = 0
#   input_data["routes"].each do |data|
#     if data["costs"]["prepaidCard"] != nil
#       prepaid += data["costs"]["prepaidCard"]
#       cash += data["costs"]["cash"]
#       # gas = data["costs"]["fuel"]
#     end
#   end
#   @cash
#   @prepaid
# end


# data = {
#   "status" => "OK",
#   "summary" => {
#     "route" => [
#       {
#         "location" => {
#           "lat" => 43.0389025,
#           "lng" => -87.9064736
#         },
#         "address" => "Milwaukee, WI, USA"
#       },
#       {
#         "location" => {
#           "lat" => 41.8781136,
#           "lng" => -87.6297982
#         },
#         "address" => "Chicago, IL, USA"
#       }
#     ],
#     "rates" => {
#       "USD" => 1,
#       "CAD" => 1.33716,
#       "MXN" => 19.662202,
#       "INR" => 69.123502
#     },
#     "currency" => "USD",
#     "countries" => [
#       "US"
#     ],
#     "departure_time" => 1559858282,
#     "fuelPrice" => {
#       "value" => 2,
#       "currency" => "USD"
#     },
#     "fuelEfficiency" => {
#       "city" => 23.4,
#       "hwy" => 30,
#       "units" => "mpg"
#     },
#     "vehicleType" => "2AxlesAuto",
#     "share" => {
#       "prefix" => "milwaukee%2Cwi-chicago%2Cil",
#       "uuid" => "ea311886-2be6-49a9-ba0d-217b678fbf1a"
#     },
#     "source" => "GMAPS"
#   },
#   "routes" => [
#     {
#       "summary" => {
#         "hasTolls" => true,
#         "diffs" => {
#           "cheapest" => 2.52,
#           "fastest" => 0
#         },
#         "url" => "https =>//www.google.com/maps/?saddr=43.0388982,-87.9065461&daddr=43.0279178,-87.92271699999999+to =>42.4352772,-87.95487469999999+to =>42.154785,-87.87446489999999+to =>42.1495089,-87.86328320000001+to =>41.88166289999999,-87.6459596+to =>41.8781139,-87.6297872&via=1,2,3,4,5",
#         "distance" => {
#           "text" => "92.1 mi",
#           "metric" => "148.3 km",
#           "value" => 148261
#         },
#         "duration" => {
#           "text" => "1 h 39 min",
#           "value" => 5943
#         },
#         "name" => "I-94 E"
#       },
#       "costs" => {
#         "fuel" => 6.17,
#         "tag" => 2.35,
#         "cash" => 4.7,
#         "licensePlate" => false,
#         "creditCard" => false,
#         "prepaidCard" => 2.35
#       },
#       "tolls" => [
#         {
#           "id" => 90002,
#           "lat" => 42.43725,
#           "lng" => -87.95565,
#           "name" => "Waukegan",
#           "road" => "Tri-State Tollway (I-94/I-294/I-80)",
#           "state" => "Illinois",
#           "type" => "barrier",
#           "tagCost" => 1.4,
#           "tagPriCost" => 1.4,
#           "tagSecCost" => 1.4,
#           "cashCost" => 2.8,
#           "licensePlateCost" => false,
#           "prepaidCardCost" => 1.4,
#           "creditCardCost" => false,
#           "currency" => "USD",
#           "tagPrimary" => [
#             "I-Pass"
#           ],
#           "tagSecondary" => [
#             "E-ZPass",
#             "E-ZPass IN",
#             "E-ZPass MD",
#             "E-ZPass MA",
#             "E-ZPass ME",
#             "E-ZPass NC",
#             "E-ZPass NH",
#             "E-ZPass NJ",
#             "E-ZPass NY",
#             "E-ZPass OH",
#             "E-ZPass PA",
#             "E-ZPass RI",
#             "E-ZPass VA",
#             "E-ZPass WV",
#             "I-Pass",
#             "RiverLink"
#           ],
#           "licensePlatePrimary" => "Pay Online",
#           "licensePlateSecondary" => false,
#           "height" => "No"
#         },
#         {
#           "id" => 90010,
#           "lat" => 42.14955,
#           "lng" => -87.86385,
#           "name" => "Edens Spur",
#           "road" => "Tri-State Tollway (I-94/I-294/I-80)",
#           "state" => "Illinois",
#           "type" => "barrier",
#           "tagCost" => 0.95,
#           "tagPriCost" => 0.95,
#           "tagSecCost" => 0.95,
#           "cashCost" => 1.9,
#           "licensePlateCost" => false,
#           "prepaidCardCost" => 0.95,
#           "creditCardCost" => false,
#           "currency" => "USD",
#           "tagPrimary" => [
#             "I-Pass"
#           ],
#           "tagSecondary" => [
#             "E-ZPass",
#             "E-ZPass IN",
#             "E-ZPass MD",
#             "E-ZPass MA",
#             "E-ZPass ME",
#             "E-ZPass NC",
#             "E-ZPass NH",
#             "E-ZPass NJ",
#             "E-ZPass NY",
#             "E-ZPass OH",
#             "E-ZPass PA",
#             "E-ZPass RI",
#             "E-ZPass VA",
#             "E-ZPass WV",
#             "I-Pass",
#             "RiverLink"
#           ],
#           "licensePlatePrimary" => "Pay Online",
#           "licensePlateSecondary" => false,
#           "height" => "No"
#         }
#       ],
#       "directions" => [
#         {
#           "position" => {
#             "lat" => 43.0375251,
#             "lng" => -87.9063889
#           },
#           "html_instructions" => "Head <b>south</b> on <b>N Milwaukee St</b> toward <b>E Wisconsin Ave</b>",
#           "distance" => 153,
#           "duration" => 39
#         },
#         {
#           "position" => {
#             "lat" => 43.0376502,
#             "lng" => -87.9038834
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> at the 2nd cross street onto <b>E Michigan St</b>",
#           "distance" => 204,
#           "duration" => 54
#         },
#         {
#           "position" => {
#             "lat" => 43.0364619,
#             "lng" => -87.90377509999999
#           },
#           "maneuver" => "turn-right",
#           "html_instructions" => "Turn <b>right</b> onto <b>N Jackson St</b>",
#           "distance" => 132,
#           "duration" => 22
#         },
#         {
#           "position" => {
#             "lat" => 43.035884,
#             "lng" => -87.90868739999999
#           },
#           "html_instructions" => "Take the <b>I-794 W</b> ramp to <b>I-94 W</b>",
#           "distance" => 433,
#           "duration" => 31
#         },
#         {
#           "position" => {
#             "lat" => 43.0357607,
#             "lng" => -87.9137227
#           },
#           "maneuver" => "merge",
#           "html_instructions" => "Merge onto <b>I-794</b>",
#           "distance" => 410,
#           "duration" => 17
#         },
#         {
#           "position" => {
#             "lat" => 43.0279178,
#             "lng" => -87.92271699999999
#           },
#           "maneuver" => "ramp-right",
#           "html_instructions" => "Take exit <b>1B-1C</b> for <b>Interstate 43 S</b>/<b>Interstate 94 E</b>/<b>U.S. 41</b> toward <b>Chicago</b>",
#           "distance" => 1626,
#           "duration" => 72
#         },
#         {
#           "position" => {
#             "lat" => 42.4352772,
#             "lng" => -87.95487469999999
#           },
#           "maneuver" => "merge",
#           "html_instructions" => "Merge onto <b>I-94 E</b><div style=\"font-size =>0.9em\">Partial toll road</div><div style=\"font-size =>0.9em\">Parts of this road may be closed at certain times or days</div><div style=\"font-size =>0.9em\">Entering Illinois</div>",
#           "distance" => 68337,
#           "duration" => 2379
#         },
#         {
#           "position" => {
#             "lat" => 42.154785,
#             "lng" => -87.87446489999999
#           },
#           "maneuver" => "fork-left",
#           "html_instructions" => "Keep <b>left</b> at the fork to stay on <b>I-94 E</b><div style=\"font-size =>0.9em\">Partial toll road</div>",
#           "distance" => 33124,
#           "duration" => 1079
#         },
#         {
#           "position" => {
#             "lat" => 42.1495089,
#             "lng" => -87.86328320000001
#           },
#           "maneuver" => "fork-left",
#           "html_instructions" => "Keep <b>left</b> at the fork to stay on <b>I-94 E</b><div style=\"font-size =>0.9em\">Toll road</div>",
#           "distance" => 1341,
#           "duration" => 51
#         },
#         {
#           "position" => {
#             "lat" => 41.88166289999999,
#             "lng" => -87.6459596
#           },
#           "maneuver" => "fork-left",
#           "html_instructions" => "Keep <b>left</b> at the fork to stay on <b>I-94 E</b><div style=\"font-size =>0.9em\">Partial toll road</div>",
#           "distance" => 40725,
#           "duration" => 1799
#         },
#         {
#           "position" => {
#             "lat" => 41.8804264,
#             "lng" => -87.6462403
#           },
#           "maneuver" => "ramp-right",
#           "html_instructions" => "Take exit <b>51 F-G</b> for <b>W Adams St</b> toward <b>200 S</b>",
#           "distance" => 139,
#           "duration" => 10
#         },
#         {
#           "position" => {
#             "lat" => 41.8779635,
#             "lng" => -87.64619379999999
#           },
#           "maneuver" => "fork-left",
#           "html_instructions" => "Keep <b>left</b> at the fork to continue on <b>Exit 51G</b>, follow signs for <b>East Jackson Boulevard</b>",
#           "distance" => 275,
#           "duration" => 35
#         },
#         {
#           "position" => {
#             "lat" => 41.8781499,
#             "lng" => -87.62978869999999
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> onto <b>W Jackson Blvd</b><div style=\"font-size =>0.9em\">Pass by Starbucks (on the right in 0.6&nbsp;mi)</div>",
#           "distance" => 1358,
#           "duration" => 351
#         },
#         {
#           "position" => {
#             "lat" => 41.8781139,
#             "lng" => -87.6297872
#           },
#           "maneuver" => "turn-right",
#           "html_instructions" => "Turn <b>right</b> onto <b>S Federal St</b>",
#           "distance" => 4,
#           "duration" => 4
#         }
#       ],
#       "polyline" => "c`ueG|"
#     },
#     {
#       "summary" => {
#         "hasTolls" => true,
#         "diffs" => {
#           "cheapest" => 2.98,
#           "fastest" => 5
#         },
#         "url" => "https =>//www.google.com/maps/?saddr=43.0388982,-87.9065461&daddr=43.0279178,-87.92271699999999+to =>42.4352772,-87.95487469999999+to =>42.154785,-87.87446489999999+to =>41.8824503,-87.91955949999999+to =>41.875551,-87.6349358+to =>41.8781139,-87.6297872&via=1,2,3,4,5",
#         "distance" => {
#           "text" => "101.6 mi",
#           "metric" => "163.4 km",
#           "value" => 163412
#         },
#         "duration" => {
#           "text" => "1 h 44 min",
#           "value" => 6272
#         },
#         "name" => "I-94 E and I-294 S"
#       },
#       "costs" => {
#         "fuel" => 6.83,
#         "tag" => 2.15,
#         "cash" => 4.3,
#         "licensePlate" => false,
#         "creditCard" => false,
#         "prepaidCard" => 2.15
#       },
#       "tolls" => [
#         {
#           "id" => 90002,
#           "lat" => 42.43725,
#           "lng" => -87.95565,
#           "name" => "Waukegan",
#           "road" => "Tri-State Tollway (I-94/I-294/I-80)",
#           "state" => "Illinois",
#           "type" => "barrier",
#           "tagCost" => 1.4,
#           "tagPriCost" => 1.4,
#           "tagSecCost" => 1.4,
#           "cashCost" => 2.8,
#           "licensePlateCost" => false,
#           "prepaidCardCost" => 1.4,
#           "creditCardCost" => false,
#           "currency" => "USD",
#           "tagPrimary" => [
#             "I-Pass"
#           ],
#           "tagSecondary" => [
#             "E-ZPass",
#             "E-ZPass IN",
#             "E-ZPass MD",
#             "E-ZPass MA",
#             "E-ZPass ME",
#             "E-ZPass NC",
#             "E-ZPass NH",
#             "E-ZPass NJ",
#             "E-ZPass NY",
#             "E-ZPass OH",
#             "E-ZPass PA",
#             "E-ZPass RI",
#             "E-ZPass VA",
#             "E-ZPass WV",
#             "I-Pass",
#             "RiverLink"
#           ],
#           "licensePlatePrimary" => "Pay Online",
#           "licensePlateSecondary" => false,
#           "height" => "No"
#         },
#         {
#           "id" => 90029,
#           "lat" => 41.96275,
#           "lng" => -87.87615,
#           "name" => "Irving Park Rd (Illinois 19)",
#           "road" => "Tri-State Tollway (I-94/I-294/I-80)",
#           "state" => "Illinois",
#           "type" => "barrier",
#           "tagCost" => 0.75,
#           "tagPriCost" => 0.75,
#           "tagSecCost" => 0.75,
#           "cashCost" => 1.5,
#           "licensePlateCost" => false,
#           "prepaidCardCost" => 0.75,
#           "creditCardCost" => false,
#           "currency" => "USD",
#           "tagPrimary" => [
#             "I-Pass"
#           ],
#           "tagSecondary" => [
#             "E-ZPass",
#             "E-ZPass IN",
#             "E-ZPass MD",
#             "E-ZPass MA",
#             "E-ZPass ME",
#             "E-ZPass NC",
#             "E-ZPass NH",
#             "E-ZPass NJ",
#             "E-ZPass NY",
#             "E-ZPass OH",
#             "E-ZPass PA",
#             "E-ZPass RI",
#             "E-ZPass VA",
#             "E-ZPass WV",
#             "I-Pass",
#             "RiverLink"
#           ],
#           "licensePlatePrimary" => "Pay Online",
#           "licensePlateSecondary" => false,
#           "height" => "No"
#         }
#       ],
#       "directions" => [
#         {
#           "position" => {
#             "lat" => 43.0375251,
#             "lng" => -87.9063889
#           },
#           "html_instructions" => "Head <b>south</b> on <b>N Milwaukee St</b> toward <b>E Wisconsin Ave</b>",
#           "distance" => 153,
#           "duration" => 39
#         },
#         {
#           "position" => {
#             "lat" => 43.0376502,
#             "lng" => -87.9038834
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> at the 2nd cross street onto <b>E Michigan St</b>",
#           "distance" => 204,
#           "duration" => 54
#         },
#         {
#           "position" => {
#             "lat" => 43.0364619,
#             "lng" => -87.90377509999999
#           },
#           "maneuver" => "turn-right",
#           "html_instructions" => "Turn <b>right</b> onto <b>N Jackson St</b>",
#           "distance" => 132,
#           "duration" => 22
#         },
#         {
#           "position" => {
#             "lat" => 43.035884,
#             "lng" => -87.90868739999999
#           },
#           "html_instructions" => "Take the <b>I-794 W</b> ramp to <b>I-94 W</b>",
#           "distance" => 433,
#           "duration" => 31
#         },
#         {
#           "position" => {
#             "lat" => 43.0357607,
#             "lng" => -87.9137227
#           },
#           "maneuver" => "merge",
#           "html_instructions" => "Merge onto <b>I-794</b>",
#           "distance" => 410,
#           "duration" => 17
#         },
#         {
#           "position" => {
#             "lat" => 43.0279178,
#             "lng" => -87.92271699999999
#           },
#           "maneuver" => "ramp-right",
#           "html_instructions" => "Take exit <b>1B-1C</b> for <b>Interstate 43 S</b>/<b>Interstate 94 E</b>/<b>U.S. 41</b> toward <b>Chicago</b>",
#           "distance" => 1626,
#           "duration" => 72
#         },
#         {
#           "position" => {
#             "lat" => 42.4352772,
#             "lng" => -87.95487469999999
#           },
#           "maneuver" => "merge",
#           "html_instructions" => "Merge onto <b>I-94 E</b><div style=\"font-size =>0.9em\">Partial toll road</div><div style=\"font-size =>0.9em\">Parts of this road may be closed at certain times or days</div><div style=\"font-size =>0.9em\">Entering Illinois</div>",
#           "distance" => 68337,
#           "duration" => 2379
#         },
#         {
#           "position" => {
#             "lat" => 42.154785,
#             "lng" => -87.87446489999999
#           },
#           "maneuver" => "fork-left",
#           "html_instructions" => "Keep <b>left</b> at the fork to stay on <b>I-94 E</b><div style=\"font-size =>0.9em\">Partial toll road</div>",
#           "distance" => 33124,
#           "duration" => 1079
#         },
#         {
#           "position" => {
#             "lat" => 41.8824503,
#             "lng" => -87.91955949999999
#           },
#           "maneuver" => "fork-right",
#           "html_instructions" => "Keep <b>right</b> at the fork to continue on <b>I-294 S</b>, follow signs for <b>Indiana - O'Hare</b><div style=\"font-size =>0.9em\">Partial toll road</div>",
#           "distance" => 33662,
#           "duration" => 1150
#         },
#         {
#           "position" => {
#             "lat" => 41.875551,
#             "lng" => -87.6349358
#           },
#           "maneuver" => "ramp-right",
#           "html_instructions" => "Take exit <b>31B</b> to merge onto <b>I-290 E</b>/<b>Eisenhower Expy</b> toward <b>Chicago</b>",
#           "distance" => 24534,
#           "duration" => 1248
#         },
#         {
#           "position" => {
#             "lat" => 41.8755647,
#             "lng" => -87.6292114
#           },
#           "maneuver" => "keep-left",
#           "html_instructions" => "Keep <b>left</b> to continue on <b>W Congress Pkwy</b>/<b>W Ida B. Wells Dr</b>",
#           "distance" => 474,
#           "duration" => 69
#         },
#         {
#           "position" => {
#             "lat" => 41.8769068,
#             "lng" => -87.62926809999999
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> onto <b>S Dearborn St</b>",
#           "distance" => 149,
#           "duration" => 57
#         },
#         {
#           "position" => {
#             "lat" => 41.8769003,
#             "lng" => -87.6297353
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> at the 1st cross street onto <b>W Van Buren St</b>",
#           "distance" => 39,
#           "duration" => 18
#         },
#         {
#           "position" => {
#             "lat" => 41.8781139,
#             "lng" => -87.6297872
#           },
#           "maneuver" => "turn-right",
#           "html_instructions" => "Turn <b>right</b> at the 1st cross street onto <b>S Federal St</b>",
#           "distance" => 135,
#           "duration" => 37
#         }
#       ],
#       "polyline" => "c`ueG"
#     },
#     {
#       "summary" => {
#         "hasTolls" => true,
#         "diffs" => {
#           "cheapest" => 3.75,
#           "fastest" => 56
#         },
#         "url" => "https =>//www.google.com/maps/?saddr=43.0388982,-87.9065461&daddr=43.0279178,-87.92271699999999+to =>42.5476882,-87.952563+to =>42.3814219,-88.2354766+to =>42.3211555,-88.2743672+to =>42.0663677,-88.29167489999999+to =>42.0671892,-88.2918136+to =>42.01943989999999,-87.9474374+to =>41.88166289999999,-87.6459596+to =>41.8781139,-87.6297872&via=1,2,3,4,5,6,7,8",
#         "distance" => {
#           "text" => "122.3 mi",
#           "metric" => "196.7 km",
#           "value" => 196715
#         },
#         "duration" => {
#           "text" => "2 h 34 min",
#           "value" => 9285
#         },
#         "name" => "I-94 E and I-90 E"
#       },
#       "costs" => {
#         "fuel" => 8.45,
#         "tag" => 1.3,
#         "cash" => 2.6,
#         "licensePlate" => false,
#         "creditCard" => false,
#         "prepaidCard" => 1.3
#       },
#       "tolls" => [
#         {
#           "id" => 87023,
#           "lat" => 42.06725,
#           "lng" => -88.29335,
#           "name" => "Illinois 31",
#           "road" => "Jane Addams Memorial Tollway (I-90)",
#           "state" => "Illinois",
#           "type" => "barrier",
#           "tagCost" => 0.55,
#           "tagPriCost" => 0.55,
#           "tagSecCost" => 0.55,
#           "cashCost" => 1.1,
#           "licensePlateCost" => false,
#           "prepaidCardCost" => 0.55,
#           "creditCardCost" => false,
#           "currency" => "USD",
#           "tagPrimary" => [
#             "I-Pass"
#           ],
#           "tagSecondary" => [
#             "E-ZPass",
#             "E-ZPass IN",
#             "E-ZPass MD",
#             "E-ZPass MA",
#             "E-ZPass ME",
#             "E-ZPass NC",
#             "E-ZPass NH",
#             "E-ZPass NJ",
#             "E-ZPass NY",
#             "E-ZPass OH",
#             "E-ZPass PA",
#             "E-ZPass RI",
#             "E-ZPass VA",
#             "E-ZPass WV",
#             "I-Pass",
#             "RiverLink"
#           ],
#           "licensePlatePrimary" => "Pay Online",
#           "licensePlateSecondary" => false,
#           "height" => "No"
#         },
#         {
#           "id" => 87043,
#           "lat" => 41.98535,
#           "lng" => -87.85745,
#           "name" => "River Rd",
#           "road" => "Jane Addams Memorial Tollway (I-90)",
#           "state" => "Illinois",
#           "type" => "barrier",
#           "tagCost" => 0.75,
#           "tagPriCost" => 0.75,
#           "tagSecCost" => 0.75,
#           "cashCost" => 1.5,
#           "licensePlateCost" => false,
#           "prepaidCardCost" => 0.75,
#           "creditCardCost" => false,
#           "currency" => "USD",
#           "tagPrimary" => [
#             "I-Pass"
#           ],
#           "tagSecondary" => [
#             "E-ZPass",
#             "E-ZPass IN",
#             "E-ZPass MD",
#             "E-ZPass MA",
#             "E-ZPass ME",
#             "E-ZPass NC",
#             "E-ZPass NH",
#             "E-ZPass NJ",
#             "E-ZPass NY",
#             "E-ZPass OH",
#             "E-ZPass PA",
#             "E-ZPass RI",
#             "E-ZPass VA",
#             "E-ZPass WV",
#             "I-Pass",
#             "RiverLink"
#           ],
#           "licensePlatePrimary" => "Pay Online",
#           "licensePlateSecondary" => false,
#           "height" => "No"
#         }
#       ],
#       "directions" => [
#         {
#           "position" => {
#             "lat" => 43.0375251,
#             "lng" => -87.9063889
#           },
#           "html_instructions" => "Head <b>south</b> on <b>N Milwaukee St</b> toward <b>E Wisconsin Ave</b>",
#           "distance" => 153,
#           "duration" => 39
#         },
#         {
#           "position" => {
#             "lat" => 43.0376502,
#             "lng" => -87.9038834
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> at the 2nd cross street onto <b>E Michigan St</b>",
#           "distance" => 204,
#           "duration" => 54
#         },
#         {
#           "position" => {
#             "lat" => 43.0364619,
#             "lng" => -87.90377509999999
#           },
#           "maneuver" => "turn-right",
#           "html_instructions" => "Turn <b>right</b> onto <b>N Jackson St</b>",
#           "distance" => 132,
#           "duration" => 22
#         },
#         {
#           "position" => {
#             "lat" => 43.035884,
#             "lng" => -87.90868739999999
#           },
#           "html_instructions" => "Take the <b>I-794 W</b> ramp to <b>I-94 W</b>",
#           "distance" => 433,
#           "duration" => 31
#         },
#         {
#           "position" => {
#             "lat" => 43.0357607,
#             "lng" => -87.9137227
#           },
#           "maneuver" => "merge",
#           "html_instructions" => "Merge onto <b>I-794</b>",
#           "distance" => 410,
#           "duration" => 17
#         },
#         {
#           "position" => {
#             "lat" => 43.0279178,
#             "lng" => -87.92271699999999
#           },
#           "maneuver" => "ramp-right",
#           "html_instructions" => "Take exit <b>1B-1C</b> for <b>Interstate 43 S</b>/<b>Interstate 94 E</b>/<b>U.S. 41</b> toward <b>Chicago</b>",
#           "distance" => 1626,
#           "duration" => 72
#         },
#         {
#           "position" => {
#             "lat" => 42.5476882,
#             "lng" => -87.952563
#           },
#           "maneuver" => "merge",
#           "html_instructions" => "Merge onto <b>I-94 E</b><div style=\"font-size =>0.9em\">Parts of this road may be closed at certain times or days</div>",
#           "distance" => 55060,
#           "duration" => 1945
#         },
#         {
#           "position" => {
#             "lat" => 42.544,
#             "lng" => -87.9534754
#           },
#           "maneuver" => "ramp-right",
#           "html_instructions" => "Take exit <b>345</b> for <b>County Road C W</b>/<b>County Road C E</b>",
#           "distance" => 420,
#           "duration" => 24
#         },
#         {
#           "position" => {
#             "lat" => 42.5385065,
#             "lng" => -88.0007462
#           },
#           "maneuver" => "fork-right",
#           "html_instructions" => "Keep <b>right</b> at the fork and merge onto <b>Wilmot Rd</b>",
#           "distance" => 4024,
#           "duration" => 196
#         },
#         {
#           "position" => {
#             "lat" => 42.5118395,
#             "lng" => -88.1791234
#           },
#           "maneuver" => "roundabout-right",
#           "html_instructions" => "At the traffic circle, take the <b>2nd</b> exit onto <b>93rd St</b>/<b>Wilmot Rd</b><div style=\"font-size =>0.9em\">Continue to follow Wilmot Rd</div>",
#           "distance" => 15692,
#           "duration" => 781
#         },
#         {
#           "position" => {
#             "lat" => 42.5127746,
#             "lng" => -88.18180459999999
#           },
#           "html_instructions" => "Continue onto <b>113th St</b>",
#           "distance" => 243,
#           "duration" => 24
#         },
#         {
#           "position" => {
#             "lat" => 42.495142,
#             "lng" => -88.198576
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> onto <b>County Hwy W</b>/<b>Fox River Rd</b><div style=\"font-size =>0.9em\">Entering Illinois</div>",
#           "distance" => 2488,
#           "duration" => 161
#         },
#         {
#           "position" => {
#             "lat" => 42.3814219,
#             "lng" => -88.2354766
#           },
#           "html_instructions" => "Continue onto <b>Johnsburg Rd</b>/<b>W Wilmot Rd</b><div style=\"font-size =>0.9em\">Continue to follow W Wilmot Rd</div>",
#           "distance" => 13148,
#           "duration" => 742
#         },
#         {
#           "position" => {
#             "lat" => 42.380339,
#             "lng" => -88.24167399999999
#           },
#           "html_instructions" => "Continue onto <b>N Johnsburg Rd</b>",
#           "distance" => 529,
#           "duration" => 41
#         },
#         {
#           "position" => {
#             "lat" => 42.3714594,
#             "lng" => -88.2349596
#           },
#           "maneuver" => "roundabout-right",
#           "html_instructions" => "At the traffic circle, take the <b>3rd</b> exit onto <b>N Chapel Hill Rd</b>",
#           "distance" => 1272,
#           "duration" => 93
#         },
#         {
#           "position" => {
#             "lat" => 42.3357215,
#             "lng" => -88.2477294
#           },
#           "html_instructions" => "Continue onto <b>N Chapel Hill Rd</b>",
#           "distance" => 4524,
#           "duration" => 275
#         },
#         {
#           "position" => {
#             "lat" => 42.3239019,
#             "lng" => -88.2487704
#           },
#           "html_instructions" => "Continue onto <b>N River Rd</b>",
#           "distance" => 1321,
#           "duration" => 70
#         },
#         {
#           "position" => {
#             "lat" => 42.3233962,
#             "lng" => -88.2497032
#           },
#           "maneuver" => "turn-slight-right",
#           "html_instructions" => "Slight <b>right</b> toward <b>Charles J Miller Memorial Hwy</b>",
#           "distance" => 104,
#           "duration" => 8
#         },
#         {
#           "position" => {
#             "lat" => 42.3214691,
#             "lng" => -88.2712231
#           },
#           "maneuver" => "turn-slight-right",
#           "html_instructions" => "Slight <b>right</b> onto <b>Charles J Miller Memorial Hwy</b>",
#           "distance" => 1842,
#           "duration" => 115
#         },
#         {
#           "position" => {
#             "lat" => 42.3211555,
#             "lng" => -88.2743672
#           },
#           "html_instructions" => "Continue onto <b>Bull Valley Rd</b>",
#           "distance" => 264,
#           "duration" => 35
#         },
#         {
#           "position" => {
#             "lat" => 42.0663677,
#             "lng" => -88.29167489999999
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> onto <b>State Rte 31 S</b>/<b>N Illinois Route 31</b><div style=\"font-size =>0.9em\">Continue to follow State Rte 31 S</div><div style=\"font-size =>0.9em\">Pass by Dairy Queen (Treat) (on the left in 11.9&nbsp;mi)</div>",
#           "distance" => 29543,
#           "duration" => 1726
#         },
#         {
#           "position" => {
#             "lat" => 42.0671892,
#             "lng" => -88.2918136
#           },
#           "maneuver" => "ramp-right",
#           "html_instructions" => "Take the <b>Interstate 90 E</b> ramp to <b>Chicago</b>",
#           "distance" => 423,
#           "duration" => 34
#         },
#         {
#           "position" => {
#             "lat" => 42.01943989999999,
#             "lng" => -87.9474374
#           },
#           "maneuver" => "merge",
#           "html_instructions" => "Merge onto <b>I-90 E</b><div style=\"font-size =>0.9em\">Toll road</div>",
#           "distance" => 29873,
#           "duration" => 950
#         },
#         {
#           "position" => {
#             "lat" => 41.988446,
#             "lng" => -87.86420009999999
#           },
#           "maneuver" => "keep-left",
#           "html_instructions" => "Keep <b>left</b> to stay on <b>I-90 E</b><div style=\"font-size =>0.9em\">Toll road</div>",
#           "distance" => 7822,
#           "duration" => 262
#         },
#         {
#           "position" => {
#             "lat" => 41.88166289999999,
#             "lng" => -87.6459596
#           },
#           "maneuver" => "fork-left",
#           "html_instructions" => "Keep <b>left</b> at the fork to stay on <b>I-90 E</b><div style=\"font-size =>0.9em\">Partial toll road</div>",
#           "distance" => 23389,
#           "duration" => 1168
#         },
#         {
#           "position" => {
#             "lat" => 41.8804264,
#             "lng" => -87.6462403
#           },
#           "maneuver" => "ramp-right",
#           "html_instructions" => "Take exit <b>51 F-G</b> for <b>W Adams St</b> toward <b>200 S</b>",
#           "distance" => 139,
#           "duration" => 10
#         },
#         {
#           "position" => {
#             "lat" => 41.8779635,
#             "lng" => -87.64619379999999
#           },
#           "maneuver" => "fork-left",
#           "html_instructions" => "Keep <b>left</b> at the fork to continue on <b>Exit 51G</b>, follow signs for <b>East Jackson Boulevard</b>",
#           "distance" => 275,
#           "duration" => 35
#         },
#         {
#           "position" => {
#             "lat" => 41.8781499,
#             "lng" => -87.62978869999999
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> onto <b>W Jackson Blvd</b><div style=\"font-size =>0.9em\">Pass by Starbucks (on the right in 0.6&nbsp;mi)</div>",
#           "distance" => 1358,
#           "duration" => 351
#         },
#         {
#           "position" => {
#             "lat" => 41.8781139,
#             "lng" => -87.6297872
#           },
#           "maneuver" => "turn-right",
#           "html_instructions" => "Turn <b>right</b> onto <b>S Federal St</b>",
#           "distance" => 4,
#           "duration" => 4
#         }
#       ],
#       "polyline" => "c`ueG|f"
#     },
#     {
#       "summary" => {
#         "hasTolls" => false,
#         "diffs" => {
#           "cheapest" => 0,
#           "fastest" => 7
#         },
#         "url" => "https =>//www.google.com/maps/?saddr=43.0388982,-87.9065461&daddr=43.0279178,-87.92271699999999+to =>42.4816453,-87.9476284+to =>42.4723538,-87.94717159999999+to =>42.1433467,-87.79276+to =>41.88166289999999,-87.6459596+to =>41.8781139,-87.6297872&via=1,2,3,4,5",
#         "distance" => {
#           "text" => "89.1 mi",
#           "metric" => "143.4 km",
#           "value" => 143352
#         },
#         "duration" => {
#           "text" => "1 h 46 min",
#           "value" => 6361
#         },
#         "name" => "I-94 E"
#       },
#       "costs" => {
#         "fuel" => 6
#       },
#       "tolls" => [],
#       "directions" => [
#         {
#           "position" => {
#             "lat" => 43.0375251,
#             "lng" => -87.9063889
#           },
#           "html_instructions" => "Head <b>south</b> on <b>N Milwaukee St</b> toward <b>E Wisconsin Ave</b>",
#           "distance" => 153,
#           "duration" => 39
#         },
#         {
#           "position" => {
#             "lat" => 43.0376502,
#             "lng" => -87.9038834
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> at the 2nd cross street onto <b>E Michigan St</b>",
#           "distance" => 204,
#           "duration" => 54
#         },
#         {
#           "position" => {
#             "lat" => 43.0364619,
#             "lng" => -87.90377509999999
#           },
#           "maneuver" => "turn-right",
#           "html_instructions" => "Turn <b>right</b> onto <b>N Jackson St</b>",
#           "distance" => 132,
#           "duration" => 22
#         },
#         {
#           "position" => {
#             "lat" => 43.035884,
#             "lng" => -87.90868739999999
#           },
#           "html_instructions" => "Take the <b>I-794 W</b> ramp to <b>I-94 W</b>",
#           "distance" => 433,
#           "duration" => 31
#         },
#         {
#           "position" => {
#             "lat" => 43.0357607,
#             "lng" => -87.9137227
#           },
#           "maneuver" => "merge",
#           "html_instructions" => "Merge onto <b>I-794</b>",
#           "distance" => 410,
#           "duration" => 17
#         },
#         {
#           "position" => {
#             "lat" => 43.0279178,
#             "lng" => -87.92271699999999
#           },
#           "maneuver" => "ramp-right",
#           "html_instructions" => "Take exit <b>1B-1C</b> for <b>Interstate 43 S</b>/<b>Interstate 94 E</b>/<b>U.S. 41</b> toward <b>Chicago</b>",
#           "distance" => 1626,
#           "duration" => 72
#         },
#         {
#           "position" => {
#             "lat" => 42.4816453,
#             "lng" => -87.9476284
#           },
#           "maneuver" => "merge",
#           "html_instructions" => "Merge onto <b>I-94 E</b><div style=\"font-size =>0.9em\">Parts of this road may be closed at certain times or days</div><div style=\"font-size =>0.9em\">Entering Illinois</div>",
#           "distance" => 62447,
#           "duration" => 2185
#         },
#         {
#           "position" => {
#             "lat" => 42.4723538,
#             "lng" => -87.94717159999999
#           },
#           "maneuver" => "ramp-left",
#           "html_instructions" => "Take exit <b>1B</b> on the <b>left</b> for <b>US-41 S</b> toward <b>Waukegan</b>",
#           "distance" => 1035,
#           "duration" => 37
#         },
#         {
#           "position" => {
#             "lat" => 42.1433467,
#             "lng" => -87.79276
#           },
#           "html_instructions" => "Continue onto <b>US-41 S</b>",
#           "distance" => 40460,
#           "duration" => 1975
#         },
#         {
#           "position" => {
#             "lat" => 41.88166289999999,
#             "lng" => -87.6459596
#           },
#           "maneuver" => "merge",
#           "html_instructions" => "Merge onto <b>I-94 E</b>",
#           "distance" => 34676,
#           "duration" => 1529
#         },
#         {
#           "position" => {
#             "lat" => 41.8804264,
#             "lng" => -87.6462403
#           },
#           "maneuver" => "ramp-right",
#           "html_instructions" => "Take exit <b>51 F-G</b> for <b>W Adams St</b> toward <b>200 S</b>",
#           "distance" => 139,
#           "duration" => 10
#         },
#         {
#           "position" => {
#             "lat" => 41.8779635,
#             "lng" => -87.64619379999999
#           },
#           "maneuver" => "fork-left",
#           "html_instructions" => "Keep <b>left</b> at the fork to continue on <b>Exit 51G</b>, follow signs for <b>East Jackson Boulevard</b>",
#           "distance" => 275,
#           "duration" => 35
#         },
#         {
#           "position" => {
#             "lat" => 41.8781499,
#             "lng" => -87.62978869999999
#           },
#           "maneuver" => "turn-left",
#           "html_instructions" => "Turn <b>left</b> onto <b>W Jackson Blvd</b><div style=\"font-size =>0.9em\">Pass by Starbucks (on the right in 0.6&nbsp;mi)</div>",
#           "distance" => 1358,
#           "duration" => 351
#         },
#         {
#           "position" => {
#             "lat" => 41.8781139,
#             "lng" => -87.6297872
#           },
#           "maneuver" => "turn-right",
#           "html_instructions" => "Turn <b>right</b> onto <b>S Federal St</b>",
#           "distance" => 4,
#           "duration" => 4
#         }
#       ],
#       "polyline" => "c`?"
#     }
#   ],
#   "meta" => {
#     "userId" => "Google_100231534942475115779",
#     "customerId" => "cus_FCT46BC95LRQSB",
#     "tx" => 5,
#     "type" => "general",
#     "client" => "api",
#     "source" => "GMAPS"
#   }
# }



# calculate_toll(data)