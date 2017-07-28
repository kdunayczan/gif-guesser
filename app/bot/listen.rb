require "facebook/messenger"
require 'net/http'
require 'json'
require 'pry'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

Bot.on :message do |message|
	if message.text.downcase == 'gif guesser'
		message.reply(
		  attachment: {
		    type: 'template',
		    payload: {
		      template_type: 'button',
		      text: 'Would you like to play?',
		      buttons: [
		        { type: 'postback', title: 'Yes', payload: 'PLAY' },
		        { type: 'postback', title: 'No', payload: 'QUIT' }
		      ]
		    }
		  }
		)

	elsif is_correct?(message)
		message.reply(text: 'You are correct!')
	else
		message.reply(text: 'Nope!')
	end	 
end

Bot.on :postback do |postback|
	case postback.payload
	when 'PLAY'
  	generate_random_gif
		url = "http://api.giphy.com/v1/gifs/search?q=#{@random_gif}&api_key=#{ENV['GIPHY_API_KEY']}"
		resp = Net::HTTP.get_response(URI.parse(url))
		buffer = resp.body
		result = JSON.parse(buffer)

	  attachment = { 
	  	type: 'image', 
	  	payload: { 
	  		url: result["data"].sample["images"]["original"]["url"] 
	  	} 
	  }

		postback.reply(
			attachment: attachment
		)

		postback.reply(
			text: "What is your guess?"
		)
	when 'QUIT'
		postback.reply(
			text: "Goodbye!"
		)
	end
end

def generate_random_gif 
	data = CSV.read("tags.csv")
	@random_gif = data[0].sample
end

def is_correct?(message)
	message.text.downcase == @random_gif
end





