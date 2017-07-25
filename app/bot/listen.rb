require "facebook/messenger"
require 'net/http'
require 'json'
require 'pry'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])



Bot.on :message do |message|
	url = "http://api.giphy.com/v1/gifs/search?q=#{message.text}&api_key=#{ENV['GIPHY_API_KEY']}"
	resp = Net::HTTP.get_response(URI.parse(url))
	buffer = resp.body
	result = JSON.parse(buffer)
	puts result

  message.reply(
    	attachment: { 'type' => 'image', 'payload' => { 'url' => result["data"].first["images"]["original"]["url"] } }
  )
end


