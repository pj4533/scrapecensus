require 'faraday'
require 'json'
require 'csv'  

def fcc_data_for_lat_lng(lat,lng)

	conn = Faraday.new(:url => 'http://data.fcc.gov') do |faraday|
	  faraday.request  :url_encoded             # form-encode POST params
	  # faraday.response :logger  
	  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
	end

	response = conn.get 'api/block/find', { :latitude => lat, :longitude => lng, :format => 'json' }
	json_response = JSON.parse(response.body)

	census_fips = json_response['Block']['FIPS']
	if census_fips
		census_state = census_fips[0,2]
		census_county = census_fips[2,3]
		census_tract = census_fips[5,6]
		census_block = census_fips[11,4]

		return census_state,census_county,census_tract,census_block
	else
		return nil,nil,nil,nil
	end
end

def census_metric_for_lat_lng(api_key,metric,lat,lng)

	state,county,tract,block = fcc_data_for_lat_lng(lat,lng)

	if state and county and tract and block
		conn = Faraday.new(:url => 'http://api.census.gov/') do |faraday|
		  faraday.request  :url_encoded             # form-encode POST params
		  # faraday.response :logger  
		  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
		end


		response = conn.get 'data/2010/acs5', { 
			:key => api_key, 
			:get => metric, 
			:for => 'tract:' + tract,
			:in => 'state:' + state + '+county:' + county
		}

		if response.body and response.body != ''
			json_response = JSON.parse(response.body)

			metric_hash = Hash[json_response[0].map.with_index.to_a]
			metric_index = metric_hash["#{metric}"]
			return json_response[1][metric_index]
		else
			puts response.status
			return nil			
		end
	else
		return nil		
	end
end


command :'file:metric' do |c|
	c.syntax = 'census:metric METRIC FILENAME'
	c.summary = 'Pull census metrics'
	c.option '--start STRING', String, 'Line to start loading from file'

	api_key = ENV['CENSUS_API_KEY']

	say_error "Census API key not set, use environment variable CENSUS_API_KEY" and abort if !api_key

	c.action do |args, options|
    	say_error "Missing arguments, expected METRIC FILENAME" and abort if args.nil? or args.empty? or args.count < 2

		trap("INT") { exit }

		census_metric_id = args[0]

		file = File.open(census_metric_id + ".csv", "a")

		lines_to_drop = 0
		if options.start
			lines_to_drop = options.start.to_i - 1
		else
			file.write("\"person_id\",\"" + census_metric_id + "\"\n")
		end

		c = CSV.open args[1]

		current_index = lines_to_drop
	  	c.drop(lines_to_drop).each do |row|
	  		current_index += 1
	    	person_id, lat, lng = row
			metric = census_metric_for_lat_lng(api_key,census_metric_id,lat,lng)
			if metric
				say_ok "**** (" + current_index.to_s + ") " + person_id.to_s + " = " + metric.to_s
				file.write(person_id.to_s + "," + metric.to_s + "\n")
			else
				say_error "**** (" + current_index.to_s + ") NOT FOUND"
			end
	    end

	end

end
