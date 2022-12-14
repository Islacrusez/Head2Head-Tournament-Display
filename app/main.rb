def tick(args)
	init(args) unless args.state.game_state
	case args.state.game_state
		when :menu then main_menu(args)
		when :settings then 
		when :loading_images then load_images(args)
		when :fight	then fight(args)
		when :interlude	then interlude(args)
		when :victor then declare_winner(args)
		when :final_eight then final_eight(args)
		when :final_four then final_four(args)
		when :final_two then final_two(args)
		else raise "Invalid Game State! Fatal!"
	end
end

def init(args)
	# get some defaults going
	args.state.settings.max_size_x = 500
	args.state.settings.max_size_y = 500
	args.state.settings.max_size_aspect = get_aspect({w: args.state.settings.max_size_x, h: args.state.settings.max_size_y = 500})
	
	args.state.settings.offset = (args.grid.right / 2 - args.state.settings.max_size_x) / 2
	
	args.state.settings.pos = []
	args.state.settings.pos[0] = {}
	args.state.settings.pos[1] = {}
	args.state.settings.pos[0][:x] = args.grid.right / 2 - args.state.settings.offset
	args.state.settings.pos[0][:y] = (args.grid.top - args.state.settings.max_size_y) / 2
	args.state.settings.pos[1][:x] = args.grid.right / 2 + args.state.settings.offset
	args.state.settings.pos[1][:y] = (args.grid.top - args.state.settings.max_size_y) / 2
	
	args.state.settings.tournament_size = 64
	args.state.competitors = []
	args.state.competitors_loaded = false
	args.state.upcoming_fights = []
	args.state.this_round = []
	
	args.state.game_state = :menu
end

def load(args = $gtk.args)
	start_loading_images(args)
end

def start(args = $gtk.args)
	resize_to_fight(args)
	args.state.game_state = :fight
end

def main_menu(args)
	args.outputs.primitives << args.state.competitors
end

def fight(args)
	if args.state.upcoming_fights.empty? && args.state.this_round.empty?
		args.state.game_state = :interlude
		return
	end
	args.outputs.labels << {x: args.grid.right / 2, y: args.grid.top / 2, text: "VS", alignment_enum: 1, vertical_alignment_enum: 1, size_enum: 3}
	if args.state.this_round.empty?
		prep_fight(args)
	end
	args.outputs.sprites << args.state.this_round
	
	if args.inputs.mouse.click
		clicked_comptetitor(args.inputs.mouse.x, args.inputs.mouse.y, args.state.this_round, args)
	end
end

def eliminate(loser, args)
	args.state.this_round[loser][:eliminated] = true
	args.state.this_round.clear
end

def prep_fight(args)
	args.state.this_round = args.state.upcoming_fights.shift
	args.state.this_round[0][:x] = args.state.settings.pos[0][:x] - args.state.this_round[0][:w]
	args.state.this_round[0][:y] = args.state.settings.pos[0][:y] + (args.state.settings.max_size_y - args.state.this_round[0][:h]) / 2
	args.state.this_round[1][:x] = args.state.settings.pos[1][:x]
	args.state.this_round[1][:y] = args.state.settings.pos[1][:y] + (args.state.settings.max_size_y - args.state.this_round[1][:h]) / 2
end

def interlude(args)
	pool = args.state.competitors.reject{|competitor| competitor[:eliminated]}
	case pool.length
		when 16
			pair_off(pool, args.state.upcoming_fights)	
		when 8
			pool.shuffle!
			pair_off(pool, args.state.upcoming_fights)	
			args.state.game_state = :final_eight
		when 4
			pool.shuffle!
			pair_off(pool, args.state.upcoming_fights)	
			args.state.game_state = :final_four
		when 2
			pool.shuffle!
			pair_off(pool, args.state.upcoming_fights)	
			args.state.game_state = :final_two
		when 1
			args.state.game_state = :victor
		else
			pair_off(pool, args.state.upcoming_fights)
	end
	#pair_off(pool, args.state.upcoming_fights)	
	return unless args.state.game_state == :interlude
	args.state.game_state = :fight
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
	args.outputs.labels << {x: args.grid.right / 2, y: args.grid.top / 2, text: "%i%" % load_percent, alignment_enum: 1, vertical_alignment_enum: 1, size_enum: 3}
	
	return unless args.state.competitors_loaded
	args.state.game_state = :menu
end

def load_one_image(image_num, args)
	competitors = args.state.competitors
	this_item = {path: "sprites/%02d.png" % (image_num + 1), primitive_marker: :sprite}
	this_item[:w], this_item[:h] = $gtk.calcspritebox(this_item[:path])
	this_item[:aspect] = get_aspect(this_item)
	this_item[:eliminated] = false
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

def clicked_comptetitor(x, y, buttons, args)
	buttons.each do |button|
		if [x, y].inside_rect?(buttons[0])
			eliminate(0, args)
		elsif [x, y].inside_rect?(buttons[1])
			eliminate(1, args)
		else
		end
	end
end

# tournament format

def pair_off(source, destination)
	unless source.length.even?
		raise "Invalid number of competitors. Odd numbers not currently supported"
		#FIXME
	end
	list = source.reject{|item| item[:eliminated]}
	puts list
	total_pairs = source.length.idiv(2)
	total_pairs.times do
		destination << [list.shift, list.shift]
	end
end

def declare_winner(args)
	unless args.state.winner
		args.state.winner = args.state.competitors.reject{|competitor| competitor[:eliminated]}[0]
		if args.state.competitors.reject{|competitor| competitor[:eliminated]}.length > 1
			raise "Logic failure, winner declared with competitors in play"
		elsif args.state.competitors.reject{|competitor| competitor[:eliminated]}.length < 1
			raise "Logic failure, winner declared but all competitors elimintated"
		else
			args.state.winner[:x] = args.grid.center_x - args.state.winner[:w] / 2 
		end
	end
	args.outputs.sprites << args.state.winner
end

def final_eight(args)
	$gtk.notify!("Final Eight!")
	args.state.game_state = :fight
end
def final_four(args)
	$gtk.notify!("Semi-finals!")
	args.state.game_state = :fight
end
def final_two(args)
	$gtk.notify!("Final showdown!")
	args.state.game_state = :fight
end
# settings