require 'pry'

class Gif
	def initialize(category, player)
		@category = category
		@player = player
	end

	def request
		data = CSV.read("#{@category}.csv")
		seed_word = data[0].sample
		url = "http://api.giphy.com/v1/gifs/search?q=#{seed_word}&api_key=#{ENV['GIPHY_API_KEY']}"
		resp = Net::HTTP.get_response(URI.parse(url))
		buffer = resp.body
		result = JSON.parse(buffer)

	  return { 
	  	type: 'image', 
	  	payload: { 
	  		url: result["data"].sample["images"]["original"]["url"] 
	  	} 
	  }
	end
end