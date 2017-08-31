require 'pry'
require 'gif.rb'
require 'player.rb'

class Game

	def initialize 
		@categories = ["Actions", "Food & Drink", "Animals", "TV Shows", "Sports", "Music", "Celebrities", "Movies"]
		@seed_word = nil
		@position = 0
		@how_many = 3
	end

	def build_response(message, seed_word)
		if seed_word != nil
			case message
			when seed_word
				reply = { text: "You are correct!\n'start' to play again." }
			when "give up"
				reply = { text: "Correct answer: #{@seed_word}\n'start' to play again." }
			else
				reply = { text: "Nope! Try Again!\n'give up' to see the answer" }
			end
		else
			case message
			when "START" 
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
				reply = start
			end
		end
		reply 
	end

	def get_categories(text)
		@options = @categories[@position, @how_many]
		return { 
			attachment: load_categories(text, @options) 
		}
	end

	def start
		return {
			type: 'template',
			payload: {
				template_type: 'button',
				text: 'Welcome to Gif Guesser!',
				buttons: [
					{ type: 'postback', title: "Start", payload: "START"}
				]
			}
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
end
