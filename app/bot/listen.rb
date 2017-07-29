require "facebook/messenger"
require 'net/http'
require 'json'
require 'pry'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

Bot.on :message do |message|
	if message.text.downcase == 'hi'
		message.reply(
		  attachment: {
		    type: 'template',
		    payload: {
		      template_type: 'button',
		      text: 'Pick a category:',
		      buttons: [
		        { type: 'postback', title: 'Actions', payload: 'ACTIONS' },
		        { type: 'postback', title: 'Animals', payload: 'ANIMALS' },
		        { type: 'postback', title: 'Sports', payload: 'SPORTS' }
		      ]
		    }
		  }
		)

	elsif is_correct?(message)
		message.reply(text: 'You are correct!')
		
		message.reply(
		  attachment: {
		    type: 'template',
		    payload: {
		      template_type: 'button',
		      text: 'Pick a category:',
		      buttons: [
		        { type: 'postback', title: 'Actions', payload: 'ACTIONS' },
		        { type: 'postback', title: 'Animals', payload: 'ANIMALS' },
		        { type: 'postback', title: 'Sports', payload: 'SPORTS' }
		      ]
		    }
		  }
		)
	else
		message.reply(text: 'Nope! Try Again.')
	end	 
end

Bot.on :postback do |postback|
	case postback.payload
	when 'ACTIONS'
  	data = CSV.read("actions.csv")
		@random_gif = data[0].sample
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
	when 'ANIMALS'
  	data = CSV.read("animals.csv")
		@random_gif = data[0].sample
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
	when 'SPORTS'
  	data = CSV.read("sports.csv")
		@random_gif = data[0].sample
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
	end
end

def is_correct?(message)
	message.text.downcase == @random_gif
end





