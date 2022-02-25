extends Node2D

var grid_size = 64

var world = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _unhandled_input(event):
	#movement
	if event.is_action_pressed("ui_right"):
		attempt_movement(Vector2(1,0))
	elif event.is_action_pressed("ui_left"):
		attempt_movement(Vector2(-1,0))
	elif event.is_action_pressed("ui_up"):
		attempt_movement(Vector2(0,-1))
	elif event.is_action_pressed("ui_down"):
		attempt_movement(Vector2(0,1))
	#other
	if event.is_action_pressed("ui_select"):
		var tile = check_tile($WorldPlayer.position)
		if tile:
			enter_level(tile)


func check_tile(pos):
	#checks to see if there is a map tile in the chosen location
	#if so, returns true
	
	for world in $Worlds.get_children():
		for tile in world.get_children():
			if tile.position == pos:
				return tile
	return false


func attempt_movement(direction):
	var new_position = $WorldPlayer.position + direction * grid_size
	if check_tile(new_position):
		
		$WorldPlayer.set_movement_tween(new_position)


func enter_level(tile):
	match world:
		1:
			$Worlds/World1.enter_level(tile.level_num)
		2:
			pass
