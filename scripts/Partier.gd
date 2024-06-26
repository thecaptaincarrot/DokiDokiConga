extends Node2D

const FILEPATH = "res://Sprites/NewPartier/tres/"

const frame_order = [1,0,2,0,1,0,3,3,2,0,1,2,4,4]
const Heads = ["FHair1","FHair2","FHair3","FHair4","FHair5",\
"MHair1","MHair2","MHair3","MHair4","MHat",\
]
const Shirts = ["Shirt1_1","Shirt2_1","Shirt3_1","Shirt4_1",\
"Shirt1_2","Shirt2_2","Shirt3_2","Shirt4_2",\
"Shirt1_3","Shirt2_3","Shirt3_3","Shirt4_3",\
"Shirt1_4","Shirt2_4","Shirt3_4","Shirt4_4",\
]

const Pants = ["Pants1_1","Pants1_2","Pants1_3","Pants1_4",\
"Pants2_1","Pants2_2","Pants2_3","Pants2_4",\
"Pants4_1","Pants4_2","Pants4_3","Pants4_4",\
"Pants3_1","Pants3_2","Pants3_3","Pants3_4",\
]

var frame = 0

var parent_level = null

var grid_position = Vector2()
var movement_time = 0.075
var is_leader = false
var is_exit = false
var can_move = true
var exiting = false
var teleporting = false
var to_teleport = false
var teleport_walk_to = Vector2(0,0)
var dead = false

var tweens = []

var visible_check = false

#Undo shit
var move_undo = {}
var teleport_undo = {}
var became_leader = -1
var entered_level = -1
var last_front = null
var max_undo = 100 #TODO: max number of moves to save in dict
var turn_exited = -1
var turn_died = -1

var front_person = null
var follower = null
var leader = null
var playable = true

var mouse_in = false

#Weird States
var confused = false
var force_move = false
var force_move_vector = Vector2(0,0) #must be unit vector or 0

signal MovementAttempted
signal IMoved
signal ITeleported
signal PartierExitted
signal PartierUnExitted
signal PartierDied
signal BecomeLeader


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	position = Vector2(stepify(position.x,Global.grid_size),stepify(position.y,Global.grid_size))	
	grid_position = position
	if front_person != null:
		front_person.connect("IMoved",self,"move_to")
		front_person.connect("ITeleported",self,"set_teleport")
	
	#Animations
	Heads.shuffle()
	var head = SpriteFrames.new()
	head = load(FILEPATH + Heads.front() + ".tres")
	
	Pants.shuffle()
	var pants = SpriteFrames.new()
	pants = load(FILEPATH + Pants.front() + ".tres")
	
	Shirts.shuffle()
	var shirt = SpriteFrames.new()
	shirt = load(FILEPATH + Shirts.front() + ".tres")
	
	
	$Head.frames = head
	$UpperBody.frames = shirt
	$LowerBody.frames = pants
	
	var walkers = $Walkers.get_children()
	walkers[randi() % len(walkers)].show()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if grid_position != position:
#		position = lerp(position, grid_position, 0.1) #turn into interpolation
#		if grid_position.distance_squared_to(position) < .001:
#			position = grid_position #Snap
#	if dead:
#		hide()
#	elif !dead and !exiting:
#		show()
	
	if tweens != []:
		if !tweens[0].is_active():
			tweens[0].start()
	
	if visible_check and !visible:
		show()
	pass


func _unhandled_input(event):
	if event.is_action_pressed("ui_click") and mouse_in and get_caboose_distance() >= 2 and get_leader_distance() >= 3:
		if follower.follower != null and front_person.front_person.leader != true:
			leader_click()


func move_to(destination):
	if !playable: return
#	#takes in a orthogonal unit vector, then moves to that location.
#	#No checks are done here, this is a forced movemnet
	var prev_position = grid_position

	move_undo[parent_level.get_turn()] = prev_position
	
	grid_position = destination
	emit_signal("IMoved",prev_position)
	if teleporting:
		teleporting = false
		var new_tween = Tween.new()
		new_tween.connect("tween_all_completed",self,"_on_MovementTween_tween_all_completed")
		new_tween.interpolate_property(self,"position", prev_position, teleport_walk_to, movement_time)
		tweens.append(new_tween)
		$Tweens.add_child(new_tween)
		prev_position = teleport_walk_to
		
		teleport_undo[parent_level.get_turn()] = prev_position
		
		emit_signal("ITeleported",teleport_walk_to)
	
	
	if !is_leader:
		check_follower_direction() #Change animation to face towards next in line
		
	var new_tween = Tween.new()
	new_tween.connect("tween_all_completed",self,"_on_MovementTween_tween_all_completed")
	new_tween.interpolate_property(self,"position", prev_position, destination, movement_time)
	tweens.append(new_tween)
	$Tweens.add_child(new_tween)
#	$MovementTween.interpolate_property(self,"position", position, destination, movement_time)
#	$MovementTween.start()
	
	if parent_level.check_exit(destination): #????? This sucks I think
		var exit_direction = (grid_position - prev_position).normalized()
		exit(exit_direction)
	
	#Hack, change if necessary
	if prev_position != destination and follower: #I actually moved trust me bro
		follower.show() #Unhide follower coming out of portal
		visible_check = true


func undo_move(turn):
	if turn_died != -1:
		print(turn_died)
		
	if move_undo.has(turn):
		if turn_died != -1:
			print(turn_died)
		
		var prev_position = grid_position
		
		if teleport_undo.has(turn):
			print("undid Tele")
			var new_tween = Tween.new()
			new_tween.connect("tween_all_completed",self,"_on_MovementTween_tween_all_completed")
			new_tween.interpolate_property(self,"position", grid_position, teleport_undo[turn], movement_time)
			tweens.append(new_tween)
			$Tweens.add_child(new_tween) 
			
			prev_position = teleport_undo[turn]
			
			if !is_leader:
				teleporting = true
				teleport_walk_to = prev_position
			
			if follower:
				follower.teleporting = false
			
			teleport_undo.erase(turn)
			
		grid_position = move_undo[turn]
		
		var direction = (grid_position - prev_position).normalized()
		
		move_undo.erase(turn)
		set_walker_animation_direction(-direction)
		
		if teleport_undo.keys().has(turn+1):
#			#1. zip back to previous
#			#2. set where I walked on to the teleporter from
#			#3. walk backwards off first pad
			if follower:
				follower.teleporting = false
			
		var new_tween = Tween.new()
		new_tween.connect("tween_all_completed",self,"_on_MovementTween_tween_all_completed")
		new_tween.interpolate_property(self,"position", prev_position, grid_position, movement_time)
		tweens.append(new_tween)
		$Tweens.add_child(new_tween)
#		$MovementTween.interpolate_property(self,"position", position, grid_position, movement_time)
#		$MovementTween.start()
	
	if turn == turn_exited:
		exiting = false
		playable = true
		is_leader = true
		show()
		visible_check = true
		turn_exited = -1
		emit_signal("PartierUnExitted")

	if turn == turn_died:
		dead = false
		turn_died = -1
		visible = true
		visible_check = true
		show()
		


func teleport_to(destination):
	#takes in a orthogonal unit vector, then moves to that location.
	#No checks are done here, this is a forced movemnet
	var prev_position = grid_position
	grid_position = destination
	
	teleport_undo[parent_level.get_turn()] = prev_position #Position of pad
	
	emit_signal("ITeleported",prev_position)
	if !is_leader:
		check_follower_direction() #Change animation to face towards next in line
	
	
	var new_tween = Tween.new()
	new_tween.connect("tween_all_completed",self,"_on_MovementTween_tween_all_completed")
	new_tween.interpolate_property(self,"position", prev_position, destination, movement_time)
	tweens.append(new_tween)
	$Tweens.add_child(new_tween)
	print(tweens)

	
	if parent_level.check_exit(destination): #????? This sucks I think  You'll never exit on a teleport
		var exit_direction = (grid_position - prev_position).normalized()
		exit(exit_direction)


func set_teleport(old_position):
	teleporting = true
	teleport_walk_to = old_position


func check_follower_direction(): #Changes the animation based on where its leader is
	var test_position = front_person.grid_position
	if front_person.teleporting:
		test_position = front_person.teleport_walk_to #This shouldn't work but it does
	#animation
	if test_position.x - grid_position.x > 64: #This is a hack, if something breaks it's this line's fault
		return
	
	if test_position.x - grid_position.x < 0:
		set_body_animation("Left")
		set_walker_animation("Left")
	elif test_position.x - grid_position.x > 0:
		set_body_animation("Right")
		set_walker_animation("Right")
	elif test_position.y - grid_position.y < 0:
		set_body_animation("Up")
		set_walker_animation("Up")
	elif test_position.y - grid_position.y > 0:
		set_body_animation("Down")
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
			set_body_animation("Right")
			set_walker_animation("Right")
		Vector2(-1,0):
			set_body_animation("Left")
			set_walker_animation("Left")
		Vector2(0,1):
			set_body_animation("Down")
			set_walker_animation("Down")
		Vector2(0,-1):
			set_body_animation("Up")
			set_walker_animation("Up")


func set_walker_animation(animation): #TODO the sprite should load a random resource rather than having
	#15000 animated sprites going at once
	for N in $Walkers.get_children():
		N.animation = animation


func set_body_animation(animation):
	$NewBody.animation = animation
	$Head.animation = animation
	$UpperBody.animation = animation
	$LowerBody.animation = animation


func bounce(direction):
	pass
	if len(tweens) > 2:
		return
	var destination = grid_position + direction * 12.0
	var new_tween = Tween.new()
	new_tween.connect("tween_all_completed",self,"_on_MovementTween_tween_all_completed")
	new_tween.interpolate_property(self,"position", grid_position, destination, movement_time/2.0)
	tweens.append(new_tween)
	$Tweens.add_child(new_tween)
#	$MovementTween.interpolate_property(self,"position", position, destination, movement_time / 2.0)
#	$MovementTween.start()
#	$MovementTween.interpolate_property(self,"position", position, grid_position, movement_time / 2.0)
#	$MovementTween.start()
	var new_tween2 = Tween.new()
	new_tween2.connect("tween_all_completed",self,"_on_MovementTween_tween_all_completed")
	new_tween2.interpolate_property(self,"position", destination, grid_position, movement_time/2.0)
	tweens.append(new_tween2)
	$Tweens.add_child(new_tween2)
	print(tweens)



func leader_click():
	become_leader()
	emit_signal("BecomeLeader")


func become_leader():
	front_person.follower = null
	front_person.disconnect("IMoved",self,"move_to")
	front_person.disconnect("ITeleported",self,"set_teleport")
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
	dead = true
	turn_died = parent_level.get_turn() - 1 #The scalar is shit and I hope it never breaks
	print("I died on turn ", turn_died, " and the current turn is ", parent_level.get_turn())
	emit_signal("PartierDied")
	visible_check = false
	hide()


func confuse():
	confused = !confused
	if confused:
		$Confused.show()
	else:
		$Confused.hide()


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
	$NewBody.frame = frame
	$Head.frame = frame
	$UpperBody.frame = frame
	$LowerBody.frame = frame
	
#	for N in $Walkers.get_children():
#		N.frame = frame


func _on_MovementTween_tween_all_completed():
	tweens.pop_front().queue_free()
	if len(tweens) > 0:
		
		tweens[0].start()
	if tweens == []:
		if exiting:
			visible_check = false
			hide()
			playable = false
#	elif teleporting:
#		teleport_to(teleport_pad)
#		teleport_pad = null
#		teleporting = false
#	elif teleport_walk_off:
#		teleport_walk_off = false
#		$MovementTween.interpolate_property(self,"position", position, teleport_walk_to, movement_time)
#		$MovementTween.start()
#	z_index = grid_position.y/Global.grid_size - 1
