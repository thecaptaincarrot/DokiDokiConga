extends Node2D

var grid_position = Vector2()
var leader = false

signal IMoved

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(stepify(position.x,Global.grid_size),stepify(position.y,Global.grid_size))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _unhandled_input(event):
	if event.is_action_pressed("ui_left"):
		move_to(Vector2(-1,0))
	elif event.is_action_pressed("ui_right"):
		move_to(Vector2(1,0))
	elif event.is_action_pressed("ui_up"):
		move_to(Vector2(0,-1))
	elif event.is_action_pressed("ui_down"):
		move_to(Vector2(0,1))


func move_to(delta_vector):
	#takes in a orthogonal unit vector, checks if it can move in that direction (i.e. space is unoccupied
	#then moves in that direction
	
	var target_position = (delta_vector * Global.grid_size) + position
	
	#placeholder for position check
	#if target position is !occupied:
	var prev_position = position
	
	position = target_position
	
	emit_signal("IMoved",prev_position)
