def tick(args)
	init(args) unless args.state.game_state
	case args.state.game_state
		when :menu then 
		when :settings then 
		when :fight	then 
		when :interlude	then 
		else raise "Invalid Game State! Fatal!"
	end
end

def init(args)
	
	
	args.state.game_state = :menu
end

# load images

# figure out their sizes, and scale them to fit

# buttons

# tournament format

# settings