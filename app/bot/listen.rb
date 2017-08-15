require "facebook/messenger"
require 'net/http'
require 'json'
require 'pry'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

@categories = ["Actions", "Food & Drink", "Animals", "TV Shows", "Sports", "Music"]
@position = 0
@how_many = 3

Bot.on :message do |message|
	response = message.text.downcase
	if @random_gif 
		case response
		when @random_gif
			message.reply(text: "You are correct!\n'start' to play again.")
			@random_gif = nil
		when "give up"
			message.reply(text: "Correct answer: #{@random_gif}")
			@random_gif = nil
		else
			message.reply(text: "Nope! Try Again!\n'give up' to see the answer")
		end
	else
		case response
		when "start" 
			@position = 0
			@text = "Pick a category!\n'more' to see more categories"
			message.reply(get_categories)		
		when "more"
			@position += @how_many
			@text = "Pick a category!\n'back' to go back\n'more' to see more categories"
			message.reply(get_categories)		
		when "back"
			if @position > 2
				@position -= @how_many
				@text = "Pick a category!\n'back' to go back\n'more' to see more categories"
				message.reply(get_categories)
			else
				@text = "Pick a category!\n'more' to see more categories"
				message.reply(get_categories)
			end
		else
			message.reply(text: "Welcome to Gif Guesser! Please type 'start' to begin.")
		end
	end
end

Bot.on :postback do |postback|
	postback.reply(
		attachment: gif_request(postback.payload.downcase)
	)

	postback.reply(
		text: "What is your guess?"
	)
end

def gif_request(category)
	data = CSV.read("#{category}.csv")
	@random_gif = data[0].sample
	url = "http://api.giphy.com/v1/gifs/search?q=#{@random_gif}&api_key=#{ENV['GIPHY_API_KEY']}"
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

def get_categories
	@options = @categories[@position, @how_many]
	return { 
		attachment: load_categories(@text, @options) 
	}
end

def load_categories(text, options)
	return {
    type: 'template',
    payload: {
      template_type: 'button',
      text: "#{text}",
      buttons: [
        { type: 'postback', title: "#{options[0]}", payload: "#{options[0].upcase.delete(' ')}" },
        { type: 'postback', title: "#{options[1]}", payload: "#{options[1].upcase.delete(' ')}" },
        { type: 'postback', title: "#{options[2]}", payload: "#{options[2].upcase.delete(' ')}" }
      ]
    }
  }
end
 


