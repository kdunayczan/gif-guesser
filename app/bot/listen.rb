require "facebook/messenger"
require 'net/http'
require 'json'
require 'pry'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

@categories = ["Actions", "Food & Drink", "Animals", "TV Shows", "Sports", "Music", "Celebrities", "Movies"]
@position = 0
@how_many = 3

Bot.on :message do |message|
	message.reply(build_response(message.text.downcase.singularize))
end

Bot.on :postback do |postback|
	postback.reply(
		attachment: gif_request(postback.payload.downcase)
	)

	postback.reply(
		text: "What is your guess?"
	)
end

def build_response(message)
	if @seed_word
		case message
		when @seed_word
			reply = { text: "You are correct!\n'start' to play again." }
			@seed_word = nil
		when "give up"
			reply = { text: "Correct answer: #{@seed_word}\n'start' to play again." }
			@seed_word = nil
		else
			reply = { text: "Nope! Try Again!\n'give up' to see the answer" }
		end
	else
		case message
		when "start" 
			@position = 0
			text = "Pick a category!\n'more' to see more categories"
			reply = get_categories(text) 		
		when "more"
			@position += @how_many
			text = "Pick a category!\n'back' to go back"
			reply = get_categories(text)		
		when "back"
			if @position > 2
				@position -= @how_many
				text = "Pick a category!\n'back' to go back\n'more' to see more categories"
				reply = get_categories(text)
			else
				text = "Pick a category!\n'more' to see more categories"
				reply = get_categories(text)
			end
		else
			reply = { text: "Welcome to Gif Guesser!\nPlease type 'start' to begin." }
		end
	end
	reply 
end

def gif_request(category)
	data = CSV.read("#{category}.csv")
	@seed_word = data[0].sample
	url = "http://api.giphy.com/v1/gifs/search?q=#{@seed_word}&api_key=#{ENV['GIPHY_API_KEY']}"
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

def get_categories(text)
	@options = @categories[@position, @how_many]
	return { 
		attachment: load_categories(text, @options) 
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
 


