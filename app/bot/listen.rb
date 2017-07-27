require "facebook/messenger"
require 'net/http'
require 'json'
require 'pry'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

def generate_random_gif 
	data = CSV.read("tags.csv")
	@random_gif = data[0].sample
end

Bot.on :message do |message|
	if message.text.downcase == 'play'
		generate_random_gif
		url = "http://api.giphy.com/v1/gifs/search?q=#{@random_gif}&api_key=#{ENV['GIPHY_API_KEY']}"
		resp = Net::HTTP.get_response(URI.parse(url))
		buffer = resp.body
		result = JSON.parse(buffer)

	  message.reply(
	    attachment: { 'type' => 'image', 'payload' => { 'url' => result["data"].first["images"]["original"]["url"] } }	
	  )

	  message.reply(text: 'What is your guess?') 
	elsif message.text.downcase == @random_gif
		message.reply(text: 'You are correct!')
	else
		message.reply(text: 'Nope!')
	end	 
end


