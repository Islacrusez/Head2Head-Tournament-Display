def tick(args)
	init(args) unless args.state.game_state
	case args.state.game_state
		when :menu then main_menu(args)
		when :settings then 
		when :fight	then fight(args)
		when :interlude	then 
		else raise "Invalid Game State! Fatal!"
	end
end

def init(args)
	# get some defaults going
	
	args.state.settings.max_size_x = 500
	args.state.settings.max_size_y = 500
	
	
	
	
	args.state.game_state = :menu
end

def main_menu(args)
	
end

def fight(args)
	args.outputs.labels << {x: 1280/2, y: 720/2, text: "VS", alignment_enum: 1, vertical_alignment_enum: 1}

end

# load images
def return_image_folder(args)
	$gtk.get_game_dir
end

def open_image_folder(args)
	$gtk.open_game_dir
end

def load_images(args)

end

# figure out their sizes, and scale them to fit

# buttons

# tournament format

# settings