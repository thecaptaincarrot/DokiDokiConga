extends Node2D
const PARTIER = preload("res://Partier.tscn")

export var time_sensitive = false

var need_exit = 0

var partiers_left

var something_happened = false
var play_active = true

var turn = 0
var undo_actions = []

#var party_positions = []

signal LevelOver
signal PartierDied

# Called when the node enters the scene tree for the first time.
func _ready():
	for entry in $Entries.get_children():
		need_exit += entry.line_size
		add_leader(entry)
		for i in need_exit - 1: #add remaining followers onto same space
			pass
			add_follower(entry)
			#Followers need to be hidden until the person they follow moves for the first time
			#When a partier leaves the portal, decrement the portal number
	
	#Triggers and Activators
	for trigger in $Triggers.get_children():
		trigger.parent_level = self
		for activator in $Activators.get_children():
			if activator.code == trigger.code:
				activator.triggers.append(trigger)
	
	start()


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
	
	if event.is_action_pressed("undo"):
		undo()
	
	if event.is_action_pressed("ui_escape"):
		get_tree().change_scene("res://WorldMap/WorldMap.tscn")
	
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
		if leader.reverse:
			fixed_direction *= -1
		if leader.force_move:
			fixed_direction = leader.force_move_vector
		
		leader.set_walker_animation_direction(fixed_direction)
		
		var can_move = false
		var leader_move = leader.grid_position + fixed_direction * Global.grid_size
		var conga_positions = leader.get_line_positions() #line positions of line that is not moving
		if check_clear(fixed_direction, leader): #Leader can move in the direction, continue simulation
#			leader_move = leader.grid_position + fixed_direction * Global.grid_size
			conga_positions.append(leader_move)
			conga_positions.erase(leader.get_caboose().grid_position)
			can_move = true
		else: #Way is blocked, cannot move so the orignal array is fine
			pass
		simulated_positions += conga_positions
		leader_info.append({"leader" : leader, "positions" : conga_positions, "leader_move" : leader_move, "moving" : can_move })
	#I now have all leaders and where they're going to be. Now I need to see if they can move
	var movement_occured = false
	for leader_dict in leader_info:
		#Don't care if the leader isn't moving from the obstacle check
		if leader_dict["moving"]:
			something_happened = true
			#check if their prospective position is already taken up
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
			if can_move:
				leader_dict["leader"].move_to(leader_dict["leader_move"]) #Is this the last check? I think so
				
	if something_happened: #Something happened that should be recorded
		turn += 1
		print("turn: ", turn)
	check_dead()


func new_leader_added():
	print("new leader on turn ", turn)
	turn += 1

func undo():
	print("undid turn, ", turn)
	if turn <= 0:
		return
	turn -= 1
	for partier in $People.get_children():
		partier.undo_move(turn)
		if partier.became_leader == turn:
			partier.undo_leader()
	
	for trigger in $Triggers.get_children():
		trigger.undo(turn)
	
	if !play_active:
		yield(get_tree().create_timer(0.1),"timeout")
		play_active = true
		$HUD/Dead.hide()
	check_dead()


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


func check_clear(direction, person_moving):
	#only checks obstacles, not people
	#TODO activators
	var grid_position = person_moving.grid_position
	var destination = person_moving.grid_position + direction * Global.grid_size
	#This checks the destination of the congaline and does appropriate actions
	#Must return true if the target is open for movement
	#Must return false if the congaline cannot move to the destination
		#Even if there's an activator or something else for the congaline to hit
	#Check tileset
		#compare the destination (which is in 32x32 blocks) to the tilemap
		#If filled with a tile, return false
	if $Walls.get_cellv(destination / Global.grid_size) != -1:
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
		if activator.position == destination and activator.blocking:
			return false
	return true


func check_dead(): #Checks if a door closed on a person.
	#There may be other reasons to kill people, but I can deal with that elsewhere
	#Kill should be a generic function
	for partier in $People.get_children():
		for activator in $Activators.get_children():
			if activator.is_in_group("Door"):
				activator.force_active_check()
				if activator.position == partier.grid_position and activator.blocking:
					partier.kill()
					break


func check_exit(destination):
	if get_exit_positions().has(destination):
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
	Completed.level_completed()
	#TODO ADD ANIMATIONS OR WHATEVER
	get_tree().change_scene("res://WorldMap/WorldMap.tscn")


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


func get_leaders():
	var leaders = []
	for partier in $People.get_children():
		if partier.is_leader:
			leaders.append(partier)
	
	return leaders
