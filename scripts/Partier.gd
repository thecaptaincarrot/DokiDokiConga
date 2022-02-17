extends Node2D

var parent_level = null

var grid_position = Vector2()
var leader = false
var can_move = true
var exiting = false

var followed = null
var follower = null

var mouse_in = false

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
		position += (grid_position - position) * delta * 20 #turn into interpolation
	
	if leader:
		$Sprite.show()
	else:
		$Sprite.hide()


func _unhandled_input(event):
	if leader:
		if event.is_action_pressed("ui_left"):
			move_to(grid_position + Vector2(-1 ,0) * Global.grid_size)
			can_move = false
			set_walker_animation("Left")
			emit_signal("MovementAttempted")
		elif event.is_action_pressed("ui_right"):
			move_to(grid_position + Vector2(1,0) * Global.grid_size)
			can_move = false
			set_walker_animation("Right")
			emit_signal("MovementAttempted")
		elif event.is_action_pressed("ui_up"):
			move_to(grid_position + Vector2(0,-1) * Global.grid_size)
			can_move = false
			set_walker_animation("Up")
			emit_signal("MovementAttempted")
		elif event.is_action_pressed("ui_down"):
			move_to(grid_position + Vector2(0,1) * Global.grid_size)
			can_move = false
			set_walker_animation("Down")
			emit_signal("MovementAttempted")
	else:
		if event.is_action_pressed("ui_click") and mouse_in and !leader and follower != null and followed.leader != true:
			if follower.follower != null and followed.followed.leader != true:
				become_leader()


func move_to(destination):
	#takes in a orthogonal unit vector, checks if it can move in that direction (i.e. space is unoccupied)
	#then moves in that direction
	#Check direction for animations (fuck)
	#placeholder for position check
	if parent_level.check_clear(destination,grid_position):
		var prev_position = grid_position
		grid_position = destination
		emit_signal("IMoved",prev_position)
		if !leader:
			check_follower_direction()
	
	if parent_level.check_exit(destination):
		exit()


func check_follower_direction():
	#animation
	if followed.grid_position.x - grid_position.x < 0:
		set_walker_animation("Left")
	elif followed.grid_position.x - grid_position.x > 0:
		set_walker_animation("Right")
	elif followed.grid_position.y - grid_position.y < 0:
		set_walker_animation("Up")
	elif followed.grid_position.y - grid_position.y > 0:
		set_walker_animation("Down")


func exit():
	if follower != null:
		follower.become_leader()
	
	exiting = true


func set_walker_animation(animation): #TODO the sprite should load a random resource rather than having
	#15000 animated sprites going at once
	for N in $Walkers.get_children():
		N.animation = animation


func tick_tock(frame):
	can_move = true
	for N in $Walkers.get_children():
		N.frame = frame
	

func _on_Area2D_mouse_entered():
	mouse_in = true


func _on_Area2D_mouse_exited():
	mouse_in = false


func become_leader():
	followed.follower = null
	followed.disconnect("IMoved",self,"move_to")
	followed = null
	
	leader = true


func kill():
	if follower != null:
		follower.become_leader()
	
	if followed != null:
		followed.follower = null
	
	queue_free()
	
