require "facebook/messenger"
require 'net/http'
require 'json'
require 'pry'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

Bot.on :message do |message|

	if message.text.downcase == 'hi' || message.text.downcase == 'back'
		text = 'Pick a category or type "more" to see more categories:'
		title_1 = "Actions"
		title_2 = "Food & Drink"
		title_3 = "Animals"
		message.reply(attachment: load_categories(text, title_1, title_2, title_3))

	elsif message.text.downcase == 'more'
		text = 'Pick a category or type "back" to go back:'
		title_1 = "TV Shows"
		title_2 = "Sports"
		title_3 = "Music"
		message.reply(attachment: load_categories(text, title_1, title_2, title_3))

	elsif is_correct?(message)
		message.reply(text: 'You are correct!')

		text = 'Pick a category or type "more" to see more categories:'
		title_1 = "Actions"
		title_2 = "Food & Drink"
		title_3 = "Animals"
		message.reply(attachment: load_categories(text, title_1, title_2, title_3))

	elsif message.text.downcase == 'give up'
			message.reply(text: "Correct answer: #{@random_gif}")
	else
		message.reply(text: "Nope! Try Again!\nOr type 'give up' to see the answer")
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

def is_correct?(message)
	message.text.downcase == @random_gif
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

def load_categories(text, title_1, title_2, title_3)
	return {
    type: 'template',
    payload: {
      template_type: 'button',
      text: "#{text}",
      buttons: [
        { type: 'postback', title: "#{title_1}", payload: "#{title_1.upcase.delete(' ')}" },
        { type: 'postback', title: "#{title_2}", payload: "#{title_2.upcase.delete(' ')}" },
        { type: 'postback', title: "#{title_3}", payload: "#{title_3.upcase.delete(' ')}" }
      ]
    }
  }
end




