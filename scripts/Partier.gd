extends Node2D

var parent_level = null

var grid_position = Vector2()
var movement_time = 0.1
var is_leader = false
var is_exit = false
var can_move = true
var exiting = false

#Undo shit
var move_undo = {}
var became_leader = -1
var entered_level = -1
var last_front = null
var max_undo = 100 #TODO: max number of moves to save in dict
var turn_exited = -1

var front_person = null
var follower = null
var leader = null
var playable = true

var mouse_in = false

#Weird States
var reverse = false
var force_move = false
var force_move_vector = Vector2(0,0) #must be unit vector or 0

signal MovementAttempted
signal IMoved
signal PartierExitted
signal PartierUnExitted
signal BecomeLeader


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(stepify(position.x,Global.grid_size),stepify(position.y,Global.grid_size))	
	grid_position = position
	if front_person != null:
		front_person.connect("IMoved",self,"move_to")
	var walkers = $Walkers.get_children()
	walkers[randi() % len(walkers)].show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if grid_position != position:
#		position = lerp(position, grid_position, 0.1) #turn into interpolation
#		if grid_position.distance_squared_to(position) < .001:
#			position = grid_position #Snap
	pass


func _unhandled_input(event):
	if event.is_action_pressed("ui_click") and mouse_in and get_caboose_distance() > 2 and get_leader_distance() > 2:
		if follower.follower != null and front_person.front_person.leader != true:
			leader_click()
	
	elif event.is_action_pressed("ui_rclick") and mouse_in:
		reverse = !reverse


func move_to(destination):
	if !playable: return
#	#takes in a orthogonal unit vector, then moves to that location.
#	#No checks are done here, this is a forced movemnet
	var prev_position = grid_position
	move_undo[parent_level.get_turn()] = prev_position
	grid_position = destination
	emit_signal("IMoved",prev_position)
	if !is_leader:
		check_follower_direction() #Change animation to face towards next in line
	$MovementTween.interpolate_property(self,"position", position, destination, movement_time)
	$MovementTween.start()
	
	if parent_level.check_exit(destination): #????? This sucks I think
		var exit_direction = (grid_position - prev_position).normalized()
		exit(exit_direction)


func undo_move(turn):
	if move_undo.has(turn):
		var prev_position = grid_position
		grid_position = move_undo[turn]
		
		var direction = (grid_position - prev_position).normalized()
		
		move_undo.erase(turn)
		
		if turn_exited != -1:
			print(turn,turn_exited)
		if turn == turn_exited:
			exiting = false
			playable = true
			is_leader = true
			show()
			turn_exited = -1
			emit_signal("PartierUnExitted")
		
		$MovementTween.interpolate_property(self,"position", position, grid_position, movement_time)
		$MovementTween.start()
		
		set_walker_animation_direction(-direction)


func teleport_to(destination):
	#takes in a orthogonal unit vector, then moves to that location.
	#No checks are done here, this is a forced movemnet
	var prev_position = grid_position
	grid_position = destination
	position = destination
	emit_signal("IMoved",prev_position)
	if !is_leader:
		check_follower_direction() #Change animation to face towards next in line
	
	if parent_level.check_exit(destination): #????? This sucks I think  You'll never exit on a teleport
		var exit_direction = (grid_position - prev_position).normalized()
		exit(exit_direction)


func check_follower_direction(): #Changes the animation based on where its leader is
	#animation
	if front_person.grid_position.x - grid_position.x > 64: #This is a hack, if something breaks it's this line's fault
		return
	
	if front_person.grid_position.x - grid_position.x < 0:
		set_walker_animation("Left")
	elif front_person.grid_position.x - grid_position.x > 0:
		set_walker_animation("Right")
	elif front_person.grid_position.y - grid_position.y < 0:
		set_walker_animation("Up")
	elif front_person.grid_position.y - grid_position.y > 0:
		set_walker_animation("Down")


func exit(exit_direction): #Leave the level
	is_leader = false
	if follower:
		if get_line_length() <= 3:
			follower.is_exit = true
			follower.force_move = true
			follower.force_move_vector = exit_direction
		follower.become_leader()

	turn_exited = parent_level.get_turn()
	exiting = true
	emit_signal("PartierExitted")


func set_walker_animation_direction(direction : Vector2):
	match direction:
		Vector2(1,0):
			set_walker_animation("Right")
		Vector2(-1,0):
			set_walker_animation("Left")
		Vector2(0,1):
			set_walker_animation("Down")
		Vector2(0,-1):
			set_walker_animation("Up")



func set_walker_animation(animation): #TODO the sprite should load a random resource rather than having
	#15000 animated sprites going at once
	for N in $Walkers.get_children():
		N.animation = animation


func leader_click():
	become_leader()
	emit_signal("BecomeLeader")


func become_leader():
	front_person.follower = null
	front_person.disconnect("IMoved",self,"move_to")
	last_front = front_person
	front_person = null
	
	is_leader = true
	
	became_leader = parent_level.get_turn()
	
	if !is_exit:
		$Sprite.show()


func undo_leader():
	front_person = last_front
	front_person.follower = self
	front_person.connect("IMoved",self,"move_to")
	last_front = null
	
	became_leader = -1
	
	is_leader = false
	$Sprite.hide()


func kill(): #rewrite because this isn't very cool
	if follower != null:
		follower.become_leader()
	
	if front_person != null:
		front_person.follower = null
	
	queue_free()


func get_conga_line():
	pass
	#Check front, then back, then self
	var line = [self]
	
	var checked_person = self
	
	while true: #check towards front
		if checked_person.front_person:
			line.append(checked_person.front_person)
			checked_person = checked_person.front_person
		else:
			break
	
	checked_person = self
	while true:
		if checked_person.follower:
			line.append(checked_person.follower)
			checked_person = checked_person.follower
		else:
			break
	
	return line


func get_line_length():
	return len(get_conga_line())


func get_line_positions():
	var line = get_conga_line()
	var positions = []
	for partier in line:
		positions.append(partier.grid_position)
	
	return positions


func check_line_fill(pos):
	for grid_pos in get_line_positions():
		if pos == grid_pos:
			return true
	return false

func get_leader_distance():
	if is_leader: return 0
	
	var i = 0
	var searching = true
	var tested_person = front_person
	while searching:
		i += 1
		if tested_person.is_leader:
			return i
		
		tested_person = tested_person.front_person


func get_caboose_distance(): #returns distance to the caboose
	if is_caboose(): return 0
	
	var i = 0
	var searching = true
	var tested_person = follower
	while searching:
		i += 1
		if tested_person.is_caboose():
			return i
		
		tested_person = tested_person.follower


func get_leader():
	if is_leader:
		return self
	var searching = true
	var tested_person = front_person
	while searching:
		if tested_person.is_leader:
			return tested_person
		
		tested_person = tested_person.front_person


func get_caboose():
	if is_caboose():
		return self
	var searching = true
	var tested_person = follower
	while searching:
		if tested_person.is_caboose():
			return tested_person
		
		tested_person = tested_person.follower


func set_leader():
	if is_leader:
		leader = self
	else:
		leader = front_person.leader


func is_caboose():
	if follower:
		return false
	else:
		return true


func _on_Area2D_mouse_entered():
	mouse_in = true


func _on_Area2D_mouse_exited():
	mouse_in = false


func tick_tock(frame): #timer based animation to keep every sprite on beat
	for N in $Walkers.get_children():
		N.frame = frame


func _on_MovementTween_tween_all_completed():
	if exiting:
		hide()
		playable = false
