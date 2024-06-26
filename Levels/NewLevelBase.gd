extends Node
const PARTIER = preload("res://Partier.tscn")

export(String, "Party", "Medieval", "SciFi") var theme = "Party"

#const HELPER_COLORS = [Color.lightblue,Color.aquamarine,Color.red, Color.orange, Color.purple, Color.yellow, Color.green, Color.pink,Color.coral]
const HELPER_COLORS = [Color.red, Color.lime, Color.blue, Color.gold, Color.darkorange, Color.aqua, Color.fuchsia, Color.green, Color.sienna,\
						Color.yellowgreen, Color.darkcyan, Color.deeppink, Color.darkgoldenrod, Color.dimgray, Color.tomato,\
						Color.mediumslateblue, Color.moccasin, Color.lightsalmon, Color.lightgreen, Color.powderblue, Color.purple,\
						Color.orchid, Color.navyblue, Color.darkolivegreen, Color.pink, Color.dodgerblue, Color.palevioletred,\
						Color.steelblue, Color.blueviolet, Color.springgreen, Color.darkslateblue, Color.darkseagreen]

#Game State
export var time_sensitive = false

var need_exit = 0

var helpers = false

var partiers_left

var something_happened = false
var play_active = false

var turn = 0
var undo_actions = []

#var party_positions = []

signal LevelOver
signal PartierDied

#Node declarations
onready var Walls = $Tilemaps/Walls
onready var ThinWalls = $Tilemaps/ThinWalls
onready var Obstacles = $Tilemaps/Obstacles

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_camera()
	
	for entry in $Entries.get_children():
		need_exit += entry.line_size
		add_leader(entry)
		for i in need_exit - 1: #add remaining followers onto same space
			pass
			add_follower(entry)
			#Followers need to be hidden until the person they follow moves for the first time
			#When a partier leaves the portal, decrement the portal number
		
		entry.parent_level = self
	
	for exit in $Exits.get_children():
		exit.parent_level = self
		
	
	#Triggers and Activators
	var code_colors = {}
	var color_index = 0
	for trigger in $Triggers.get_children():
		for code in trigger.code:
			if !code_colors.keys().has(code): #Code colors for helper lines
				code_colors[code] = HELPER_COLORS[color_index]
				color_index += 1
		
		trigger.parent_level = self
		trigger.theme = theme
		#This matches a trigger with its activators
		#Also use to draw helper lines
		for code in trigger.code:
			for activator in $Activators.get_children():
				activator.parent_level = self
				if activator.code == code:
					activator.pair_trigger(trigger)
					#New helper line
					var new_line = Line2D.new()
					new_line.default_color = code_colors[code]
					new_line.add_point(trigger.position + trigger.helper_offset)
					new_line.add_point(activator.position + activator.helper_offset)
					
					new_line.width = 2
					new_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
					new_line.end_cap_mode = Line2D.LINE_CAP_ROUND
					new_line.joint_mode = Line2D.LINE_JOINT_BEVEL
					new_line.z_index = 99
					new_line.hide()
					
					$Lines.add_child(new_line)
	
	#Teleporter Pads
	var i = 0
	for pad in $Pads.get_children():
		if pad.is_in_group("Teleport") and pad.paired == false:
			for pad_pair in $Pads.get_children():
				if pad_pair.is_in_group("Teleport"):
					if pad.code == pad_pair.code and pad != pad_pair:
						pad.paired_pad = pad_pair
						pad.paired = true
						pad.self_modulate = HELPER_COLORS[i]
						
						pad_pair.paired_pad = pad
						pad_pair.paired = true
						pad_pair.self_modulate = HELPER_COLORS[i]
						i += 1
						if i >= len(HELPER_COLORS):
							i = 0
	
	
	
	start()
	$PlayArea.hide()


func start(): #TODO: turn into animation
	for entry in $Entries.get_children():
		entry.start()
	for exit in $Exits.get_children():
		exit.start()
	
	var t = Timer.new()
	t.wait_time = 1.0
	add_child(t)
	t.start()
	yield(t,"timeout")
	t.queue_free()

	for leader in get_leaders():
		leader.show()
	play_active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HUD/ExitNum.text = str(need_exit) 
#	check_buttons()
#	party_positions = get_partier_positions()


func _unhandled_input(event):
	if play_active:
		if event.is_action_pressed("ui_left"):
			move(Vector2(-1 ,0))
		elif event.is_action_pressed("ui_right"):
			move(Vector2(1,0))
		elif event.is_action_pressed("ui_up"):
			move(Vector2(0,-1))
		elif event.is_action_pressed("ui_down"):
			move(Vector2(0,1))
	
	if event.is_action_pressed("ui_click") and helpers:
		_on_Helper_pressed()
	
	if event.is_action_pressed("undo"):
		undo()
	
	if event.is_action_pressed("ui_escape"):
		escape()
	
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func move(direction): #move all leaders in the given directions
	#0. If nothing happens, do not advance the turn
	something_happened = false
	
	#1. find all leaders among all partiers
	var leaders = []
	for partier in $People.get_children():
		if partier.is_leader:
			leaders.append(partier)
	#2. Simulate movements for all leaders, checking only environmental factors
	#Use Check Clear to see if the leader moves
	var simulated_positions = []
	var leader_info = []
	for leader in leaders:
		var fixed_direction = direction
		#Movement Modifiers
		if leader.confused:
			fixed_direction *= -1
		if leader.force_move:
			fixed_direction = leader.force_move_vector
		
		leader.set_walker_animation_direction(fixed_direction)
		
		var can_move = false
		var leader_move = leader.grid_position + fixed_direction * Global.grid_size
		var conga_positions = leader.get_line_positions() #line positions of line that is not moving
		if check_clear(fixed_direction, leader): #Leader can move in the direction, continue simulation
			#Check if target is outside of bounds play area
			
			conga_positions.append(leader_move)
			conga_positions.erase(leader.get_caboose().grid_position)
			can_move = true
		else: #Way is blocked, cannot move so the orignal array is fine
			pass
		simulated_positions += conga_positions
		leader_info.append({"leader" : leader, "positions" : conga_positions, "leader_move" : leader_move, "moving" : can_move , "direction": fixed_direction})
	#I now have all leaders and where they're going to be.
	#**Checks for running into other partiers**
	#Next check to see if the leader is running into their own line
	var movement_occured = false
	var checking_movement = true
	var i = 0
	while checking_movement:
		checking_movement = false
		i += 1
		for leader_dict in leader_info:
			#Don't care if the leader isn't moving from the obstacle check
			if leader_dict["moving"]:
				something_happened = true
				#check if their prospective position is already taken up by their own congaline
				#must be taken up at least twice since their own position is in the array too
				var self_check = false
				var can_move = true
				for simulated_position in simulated_positions:
					if simulated_position == leader_dict["leader_move"]:
						if self_check:
							#I found myself and one other person and I cannot move
							#TODO check if two leaders are trying to enter the same space
							can_move = false
							break
						else:
							self_check = true
							#Found myself in the array, anyone else?
#				if can_move:
#					leader_dict["leader"].move_to(leader_dict["leader_move"]) #Is this the last check? I think so
				if !can_move: #I can't move. therefore, I should add my caboose to simulated movements
					var new_caboose = leader_dict["leader"].get_caboose()
					simulated_positions.append(new_caboose.grid_position)
#					leader_dict["leader"].bounce(leader_dict["direction"])
					#Redo check
					checking_movement = true
				leader_dict["moving"] = can_move
			else:
				leader_dict["leader"].bounce(leader_dict["direction"])
	
	for leader_dict in leader_info:
		if leader_dict["moving"]:
			pass
			leader_dict["leader"].move_to(leader_dict["leader_move"]) #Is this the last check? I think so
			#step on pad checks
			for pad in $Pads.get_children():
				if leader_dict["leader"].grid_position == pad.position:
					if pad.is_in_group("Confusion"):
						leader_dict["leader"].confuse()
						break
					elif pad.is_in_group("Teleport"):
						leader_dict["leader"].teleport_to(pad.paired_pad.position)
						break
	if something_happened: #Something happened that should be recorded
		turn += 1
#		print("turn: ", turn)
	for trigger in $Triggers.get_children():
		trigger.update()
	
	for activator in $Activators.get_children():
		activator.active_check()
	check_dead()


func check_clear(direction, person_moving):
	#only checks obstacles, not people
	#TODO activators
	var grid_position = person_moving.grid_position / Global.grid_size
	var destination = person_moving.grid_position + direction * Global.grid_size
	var grid_destination = destination / Global.grid_size

	#This checks the destination of the congaline and does appropriate actions
	#Must return true if the target is open for movement
	#Must return false if the congaline cannot move to the destination
		#Even if there's an activator or something else for the congaline to hit
	#Check tileset
		#compare the destination (which is in 32x32 blocks) to the tilemap
		#If filled with a tile, return false
	if Walls.get_cellv(destination / Global.grid_size) != -1 or Obstacles.get_cellv(destination / Global.grid_size) != -1:
		return false
	#Thin Walls
		#Vertical thin walls can't be crossed from X -1 to 0 or 0 to -1
		#Horizontal thin walls can't be crossed from Y -1 to 0 or 0 to -1
		#just do position - destination and see if it's negative
	var thin_wall_end_index = ThinWalls.get_cellv(grid_destination)
	var thin_wall_start_index = ThinWalls.get_cellv(grid_position)
	if thin_wall_end_index != -1: #destination is a thin wall
		var thin_wall_name = ThinWalls.tile_set.tile_get_name(thin_wall_end_index)
		if thin_wall_name == "Vertical" and grid_position.x - grid_destination.x < 0:#Moving Left
			return false
		elif thin_wall_name == "Horizontal" and grid_position.y - grid_destination.y < 0 :#Moving Up
			return false
	
	if thin_wall_start_index != -1:  #current position is a thin wall
		var thin_wall_name = ThinWalls.tile_set.tile_get_name(thin_wall_start_index)
		if thin_wall_name == "Vertical" and grid_position.x - grid_destination.x > 0:#Moving Right
			return false
		elif thin_wall_name == "Horizontal" and grid_position.y - grid_destination.y > 0 : #Moving Down
			return false
	
	#Check Triggers
	#Some Pressure plates and gates do not block movement, but switches do
	#This will only be called if movement is attempted, right? Can we activate switches here?
	for trigger in $Triggers.get_children():
		if trigger.position == destination and trigger.blocking:
			if trigger.is_in_group("Lever"):
				something_happened = true
				trigger.toggle()
			return false
	
	#Check Activators
	#Doors will toggle between blocking and not blocking
	#They can move into a door while it closes, but this will kill them
	for activator in $Activators.get_children():
		if activator.position == destination and activator.blocking == true:
			activator.active_check()
			return false
	
	#Check Playarea Bounds
	if destination.x < $PlayArea.margin_left\
	or destination.x > $PlayArea.margin_right\
	or destination.y < $PlayArea.margin_top\
	or destination.y > $PlayArea.margin_bottom:
		return false
	
	return true


func new_leader_added():
	turn += 1

func undo():
	if turn <= 0:
		return
	turn -= 1
	for partier in $People.get_children():
		partier.undo_move(turn)
		if partier.became_leader == turn:
			partier.undo_leader()
	
	for exit in $Exits.get_children():
		exit.undo() #???
	
	for trigger in $Triggers.get_children():
		trigger.undo(turn)
	
	if !play_active:
		yield(get_tree().create_timer(0.1),"timeout")
		play_active = true
		$HUD/Dead.hide()
	check_dead()


func escape():
#	get_tree().change_scene("res://WorldMap/WorldMap.tscn")
	DemoAutoLoad.stop_timing()
	get_tree().change_scene("res://Demo/DemoWorldMap.tscn")



func add_leader(entry): #entry is the portal that the leader is coming out of
	#Add a leader to the congo line at the level entry
	var new_leader = PARTIER.instance()
	new_leader.position = entry.position
	new_leader.entered_level = turn - 1
#	new_leader.connect("IMoved", self, "add_follower") #No this sucks
	new_leader.connect("PartierExitted",self,"partier_exit")
	new_leader.connect("PartierUnExitted",self,"partier_unexit")
	new_leader.connect("BecomeLeader",self,"new_leader_added")
	new_leader.connect("PartierDied",self,"partier_died")
	new_leader.is_leader = true
	new_leader.get_node("Sprite").show()
	new_leader.parent_level = self
	$Metronome.connect("UpdateFrame",new_leader,"tick_tock")
	$People.add_child(new_leader)
	entry.line_size -= 1
	entry.last_partier = new_leader
	new_leader.hide()


func add_follower(entry):
	#This gets called way too often, every time movement is attempted
	#Add a follower following the leader at the level entry
	if entry.line_size > 0:
		var new_follower = PARTIER.instance()
		new_follower.position = entry.position
		new_follower.entered_level = turn
		new_follower.connect("PartierExitted",self,"partier_exit")
		new_follower.connect("PartierUnExitted",self,"partier_unexit")
		new_follower.connect("BecomeLeader",self,"new_leader_added")
		new_follower.connect("PartierDied",self,"partier_died")
		new_follower.front_person = entry.last_partier
		new_follower.parent_level = self
		$Metronome.connect("UpdateFrame",new_follower,"tick_tock")
		$People.add_child(new_follower)
		entry.line_size -= 1
		entry.last_partier.follower = new_follower
		entry.last_partier = new_follower
		new_follower.hide()
	else:
		entry.animation = "Close"
		#disconnect signal?


func check_dead(): #Checks if a door closed on a person.
	#There may be other reasons to kill people, but I can deal with that elsewhere
	#Kill should be a generic function
	for activator in $Activators.get_children():
		if activator.is_in_group("Door"):
			activator.active_check()
			for partier in $People.get_children():
				if activator.position == partier.grid_position and activator.blocking:
					partier.kill()
					break
	
	#Kill Tiles
	for obstacle in $Scenery.get_children():
		if obstacle.is_in_group("Death"):
			for partier in $People.get_children():
				if partier.grid_position == obstacle.position:
					partier.kill()
					break


func check_exit(destination):
	if get_exit_positions().has(destination):
		#so... This is called when a partier wants to know where the exit is
		#i.e. when it is trying to move onto an exit
		#So. Logically. It follows that at this point I can also decrement\
		#the exit portal's number
		
		#It's so hacky and I hate it.
		get_exit(destination).decrement()
		return true
	else:
		return false


func partier_exit():
	need_exit -= 1
	if need_exit <= 0:
		for exit in $Exits.get_children():
			exit.animation = "Close"
		#Go back to world map, etc
		end_level()


func partier_unexit():
	need_exit += 1


func partier_died():
	play_active = false
	#TODO: UI Elements
	$HUD/Dead.show()


func end_level():
	#Readd when not a demo thing
#	Completed.level_completed()
#	#TODO ADD ANIMATIONS OR WHATEVER
#	get_tree().change_scene("res://WorldMap/WorldMap.tscn")
	DemoAutoLoad.complete_level()
	pass


func get_turn():
	return turn


func get_partier_positions(): #in grid positions
	var position_array = []
	for partier in $People.get_children():
		position_array.append(partier.grid_position)
	return position_array


func get_exit_positions():
	var exit_array = []
	for exit in $Exits.get_children():
		exit_array.append(exit.position)
	
	return exit_array


func get_exit(location):
	for exit in $Exits.get_children():
		if exit.position == location: return exit
	print('ERROR! Could not find exit at ',str(location))
	return false


func get_leaders():
	var leaders = []
	for partier in $People.get_children():
		if partier.is_leader:
			leaders.append(partier)
	
	return leaders


func set_camera():
	#Do on startup
	var resolution = get_viewport().get_visible_rect().size
	
	var center_point = Vector2(0,0)
	
	var playarea_size = Vector2($PlayArea.margin_right - $PlayArea.margin_left,$PlayArea.margin_bottom - $PlayArea.margin_top)
	
	center_point.x = ($PlayArea.margin_left + $PlayArea.margin_right) / 2.0
	center_point.y = ($PlayArea.margin_top + $PlayArea.margin_bottom) / 2.0
	
	var zoom_factor = Vector2(0,0)
	zoom_factor.x = playarea_size.x / resolution.x
	zoom_factor.y = playarea_size.y / resolution.y
	
	var max_zoom_factor = max(zoom_factor.x,zoom_factor.y)
	
	$MainCamera.zoom = Vector2(max_zoom_factor,max_zoom_factor)
	$MainCamera.offset = center_point


func show_helpers():
	$HUD/ColorBlocker.show()
	for line in $Lines.get_children():
		line.show()


func hide_helpers():
	$HUD/ColorBlocker.hide()
	for line in $Lines.get_children():
		line.hide()


func _on_Helper_mouse_entered():
	show_helpers()


func _on_Helper_mouse_exited():
	if !helpers:
		hide_helpers()


func _on_Helper_pressed():
	if helpers:
		hide_helpers()
	else:
		show_helpers()
	
	play_active = !play_active

	helpers = !helpers
