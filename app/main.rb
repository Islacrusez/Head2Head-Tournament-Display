def tick(args)
	init(args) unless args.state.game_state
	case args.state.game_state
		when :menu then main_menu(args)
		when :settings then 
		when :loading_images then load_images(args)
		when :fight	then fight(args)
		when :interlude	then 
		else raise "Invalid Game State! Fatal!"
	end
end

def init(args)
	# get some defaults going
	args.state.settings.max_size_x = 500
	args.state.settings.max_size_y = 500
	args.state.settings.max_size_aspect = get_aspect({w: args.state.settings.max_size_x, h: args.state.settings.max_size_y = 500})
	
	args.state.settings.tournament_size = 64
	args.state.competitors = []
	args.state.competitors_loaded = false
	
	
	
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

def start_loading_images(args)
	args.state.competitors.clear
	args.state.competitors_loaded = false
	args.state.competitors_to_load = args.state.settings.tournament_size

	args.state.game_state = :loading_images
end

def load_images(args)
	image = args.state.settings.tournament_size - args.state.competitors_to_load
	load_one_image(image, args)
	args.state.competitors_to_load -= 1
	args.state.competitors_loaded = true if args.state.competitors_to_load == 0
	load_percent = image / args.state.settings.tournament_size * 100
	args.outputs.labels << {x: 1280/2, y: 720/2, text: "%i%" % load_percent, alignment_enum: 1, vertical_alignment_enum: 1, size_enum: 3}
	
	return unless args.state.competitors_loaded
	args.state.game_state = :menu
end

def load_one_image(image_num, args)
	competitors = args.state.competitors
	this_item = {path: "sprites/%02d.png" % (image_num + 1), primitive_marker: :sprite}
	this_item[:w], this_item[:h] = $gtk.calcspritebox(this_item[:path])
	this_item[:aspect] = get_aspect(this_item)
	competitors << this_item
end

# and scale them to fit

def aspect_check(image, canvas_aspect)
	if image[:w] == image[:h]
		return :square
	elsif image[:aspect] < canvas_aspect
		return :wide
	else
		return :tall
	end
end

def get_aspect(image)
	image[:h] / image[:w]
end

def resize_to_fight(args)
	size = 0
	if args.state.settings.max_size_x == args.state.settings.max_size_y
		size = args.state.settings.max_size_x
	elsif args.state.settings.max_size_x > args.state.settings.max_size_y
		size = args.state.settings.max_size_y
	else
		size = args.state.settings.max_size_x
	end
	
	args.state.competitors.each do |image|
		case aspect_check(image, args.state.settings.max_size_aspect)
			when :square then resize_square(image, size)
			when :wide then resize_wide(image, size)
			when :tall then resize_tall(image, size)
			else raise "Aspect Check Failed, Fatal."
		end
	end
end

def resize_square(image, size)
	image[:w], image[:h] = size, size
end

def resize_wide(image, size)
	ratio = image[:h] / image[:w]
	image[:w] = size
	image[:h] = size * ratio
end

def resize_tall(image, size)
	ratio = image[:w] / image[:h]
	image[:h] = size
	image[:w] = size * ratio
end

# buttons

# tournament format

# settings