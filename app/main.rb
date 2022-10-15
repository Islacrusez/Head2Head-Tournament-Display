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
	
	args.state.settings.tournament_size = 64
	args.state.competitors = []
	
	
	
	args.state.game_state = :menu
end

def main_menu(args)
	args.outputs.primitives << args.state.competitors
end

def fight(args)
	args.outputs.labels << {x: 1280/2, y: 720/2, text: "VS", alignment_enum: 1, vertical_alignment_enum: 1, size_enum: 3}

end

# load images
def return_image_folder(args)
	$gtk.get_game_dir
end

def open_image_folder(args)
	$gtk.open_game_dir
end

def load_images(args)
	total_images = args.state.settings.tournament_size
	competitors = args.state.competitors
	competitors.clear
	competitor = 0
	total_images.times do |competitor|
		item_number = competitor + 1
		this_item = {path: "sprites/%02d.png" % item_number, primitive_marker: :sprite}
		this_item[:w], this_item[:h] = $gtk.calcspritebox(this_item[:path])
		competitors << this_item
	end
end

def load_one_image(path, args)
	
end

# figure out their sizes, and scale them to fit

# buttons

# tournament format

# settings