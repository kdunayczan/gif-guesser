require 'pry'

class Player
	attr_reader 'active_game'

	def initialize(player_id)
		@player_id = player_id
		@active_game = nil
	end

	def start
		@active_game = Game.new
	end

	def is_active?
		@active_game != nil
	end

end