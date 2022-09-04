extends Node2D

var grid_size = 32

var current_world = -1

var movement_disabled

# Called when the node enters the scene tree for the first time.
func _ready():
	#turn all completed levels green
	#put the player on the last completed level
#	if Completed.current_level[0] != -1:
#		current_world = Completed.current_level[0]
#
#		var worldpath = "Worlds/World" + str(Completed.current_level[0])
#		var completion_world = get_node(worldpath)
#		var leveltile = completion_world.get_tile(Completed.current_level[1])
#		$WorldPlayer.position = leveltile.position
#
#		#if completed the tutorial for the first time
#		if Completed.current_level==[0,1] and Completed.first_complete:
#			#put player at the node
#			print("Smiley Face")
#			pass
#	else:
	$WorldPlayer.position = $Worlds/DemoWorld/LevelTile4.position

	for completed in DemoAutoLoad.completed:
		print(completed)
		var node_path = "Worlds/DemoWorld/LevelTile" + str(completed)
		get_node(node_path).modulate = Color.green


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _unhandled_input(event):
	#movement
	if movement_disabled:
		return
	
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
			if tile.is_in_group("Tile"):
				if tile.global_position == pos:
					return tile
	return false


func attempt_movement(direction):
	var new_position = $WorldPlayer.position + direction * grid_size
	var tile = check_tile(new_position)
	if !tile:
		return
	
	if tile.allow_move():
		$WorldPlayer.set_movement_tween(new_position)
	
	if tile.is_in_group("Tutorial"):
		current_world = 0
	elif current_world == 0:
		current_world = -1


func enter_level(tile):
	if tile.is_in_group("LevelTile"):
		Completed.current_level = [current_world,tile.level_num]
		match current_world:
			-1:
				if !DemoAutoLoad.completed.has(tile.level_num):
					$Worlds/DemoWorld.enter_level(tile.level_num)
			0:
				$Worlds/World0.enter_level(tile.level_num)
			1:
				$Worlds/World1.enter_level(tile.level_num)
			2:
				$Worlds/World2.enter_level(tile.level_num)
	elif tile.is_in_group("Portal"):
		#End Demo
		pass
		get_tree().change_scene("res://Demo/DemoEndScreen.tscn")


func get_world_node(world_num):
	match world_num:
		0:
			return $Worlds/World0
		1:
			return $Worlds/World1
		2:
			return $Worlds/World2
	return null


func _on_World0_TutorialComplete():
	movement_disabled = true #Disable Movement Inputs
	

func _on_BridgeAnimation_animation_finished(anim_name):
	movement_disabled = false
