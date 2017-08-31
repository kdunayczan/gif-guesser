require "facebook/messenger"
require 'net/http'
require 'json'
require 'pry'
require 'gif.rb'
require 'game.rb'
require 'player.rb'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

@players = {}

Bot.on :message do |message|
	player_id = message.sender['id']
	if !@players[player_id]
		player = Player.new(player_id)
		@players[player_id] = player
	else
		player = @players[player_id]
	end
	if player.is_active?
		game = player.active_game
		message.reply(game.build_response(message.text.downcase.singularize, player))
	else
		game = player.start
	end
end

Bot.on :postback do |postback|
	player_id = postback.sender['id']
	player = Player.new(player_id)
	postback.reply(
		attachment: Gif.new(postback.payload.downcase, player).request
	)

	postback.reply(
		text: "What is your guess?"
	)
end

 


