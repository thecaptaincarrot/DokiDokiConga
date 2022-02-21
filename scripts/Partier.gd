extends Node2D

var parent_level = null

var grid_position = Vector2()
var is_leader = false
var can_move = true
var exiting = false

var followed = null
var follower = null
var leader = null

var mouse_in = false

#Weird States
var reverse = false

signal MovementAttempted
signal IMoved
signal PartierExitted

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(stepify(position.x,Global.grid_size),stepify(position.y,Global.grid_size))	
	grid_position = position
	if followed != null:
		followed.connect("IMoved",self,"move_to")
	var walkers = $Walkers.get_children()
	walkers[randi() % len(walkers)].show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if grid_position != position:
		position = lerp(position, grid_position, 0.1) #turn into interpolation
		if grid_position.distance_squared_to(position) < .001:
			position = grid_position #Snap
			if is_leader:
				print(position)
	
	if is_leader:
		$Sprite.show()
	else:
		$Sprite.hide()


func _unhandled_input(event):
	if is_leader:
		if !reverse:
			if event.is_action_pressed("ui_left"):
				leader_move(Vector2(-1 ,0))
				set_walker_animation("Left")
				emit_signal("MovementAttempted")
			elif event.is_action_pressed("ui_right"):
				leader_move(Vector2(1,0))
				set_walker_animation("Right")
				emit_signal("MovementAttempted")
			elif event.is_action_pressed("ui_up"):
				leader_move(Vector2(0,-1))
				set_walker_animation("Up")
				emit_signal("MovementAttempted")
			elif event.is_action_pressed("ui_down"):
				leader_move(Vector2(0,1))
				set_walker_animation("Down")
				emit_signal("MovementAttempted")
			elif event.is_action_pressed("ui_rclick") and mouse_in:
				if is_leader:
					reverse = true
					print(reverse)
		else:
			if event.is_action_pressed("ui_left"):
				leader_move(Vector2(1 ,0))
				set_walker_animation("Right") 
				emit_signal("MovementAttempted")
			elif event.is_action_pressed("ui_right"):
				leader_move(Vector2(-1,0))
				set_walker_animation("Left")
				emit_signal("MovementAttempted")
			elif event.is_action_pressed("ui_up"):
				leader_move(Vector2(0,1))
				set_walker_animation("Down")
				emit_signal("MovementAttempted")
			elif event.is_action_pressed("ui_down"):
				leader_move(Vector2(0,-1))
				set_walker_animation("Up")
				emit_signal("MovementAttempted")
			elif event.is_action_pressed("ui_rclick") and mouse_in:
				if is_leader:
					reverse = false
					print(reverse)
	else:
		if event.is_action_pressed("ui_click") and mouse_in and get_caboose_distance() > 2 and get_leader_distance() > 2:
			if follower.follower != null and followed.followed.leader != true:
				become_leader()



func leader_move(direction):
	#takes in a orthogonal unit vector, checks if it can move in that direction (i.e. space is unoccupied)
	#if true: move_to that direction
	#if false: bounce animation ***TODO***
	
	if parent_level.check_clear(direction, self):
		move_to(grid_position + direction * Global.grid_size)
	else:
		pass #Bounce animation
	


func move_to(destination):
	#takes in a orthogonal unit vector, then moves to that location.
	#No checks are done here, this is a forced movemnet
	var prev_position = grid_position
	grid_position = destination
	emit_signal("IMoved",prev_position)
	if !is_leader:
		check_follower_direction() #Change animation to face towards next in line
	
	if parent_level.check_exit(destination): #????? This sucks I think
		exit()


func check_follower_direction(): #Changes the animation based on where its leader is
	#animation
	if followed.grid_position.x - grid_position.x < 0:
		set_walker_animation("Left")
	elif followed.grid_position.x - grid_position.x > 0:
		set_walker_animation("Right")
	elif followed.grid_position.y - grid_position.y < 0:
		set_walker_animation("Up")
	elif followed.grid_position.y - grid_position.y > 0:
		set_walker_animation("Down")


func exit(): #Leave the level
	if follower != null:
		follower.become_leader()
	
	exiting = true


func set_walker_animation(animation): #TODO the sprite should load a random resource rather than having
	#15000 animated sprites going at once
	for N in $Walkers.get_children():
		N.animation = animation


func tick_tock(frame): #timer based animation to keep every sprite on beat
	for N in $Walkers.get_children():
		N.frame = frame
	

func _on_Area2D_mouse_entered():
	mouse_in = true


func _on_Area2D_mouse_exited():
	mouse_in = false


func get_leader_distance():
	if is_leader: return 0
	
	var i = 0
	var searching = true
	var tested_person = followed
	while searching:
		i += 1
		if tested_person.is_leader:
			return i
		
		tested_person = tested_person.followed


func get_caboose_distance():
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
	var searching = true
	var tested_person = followed
	while searching:
		if tested_person.is_leader:
			return tested_person
		
		tested_person = tested_person.followed


func set_leader():
	if is_leader:
		leader = self
	else:
		leader = followed.leader


func is_caboose():
	if follower:
		print("no follower")
		return false
	else:
		return true


func become_leader():
	followed.follower = null
	followed.disconnect("IMoved",self,"move_to")
	followed = null
	
	is_leader = true


func kill(): #rewrite because this isn't very cool
	if follower != null:
		follower.become_leader()
	
	if followed != null:
		followed.follower = null
	
	queue_free()
