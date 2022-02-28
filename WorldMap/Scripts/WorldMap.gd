extends Node2D

var grid_size = 64

var current_world = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	#turn all completed levels green
	print(Completed.completed_levels)
	
	#put the player on the last completed level
	if Completed.current_level[0] != 0:
		current_world = Completed.current_level[0]
		
		var worldpath = "Worlds/World" + str(Completed.current_level[0])
		var completion_world = get_node(worldpath)
		var leveltile = completion_world.get_tile(Completed.current_level[1])
		$WorldPlayer.position = leveltile.position
		
		$WorldCamera.change_world(Completed.current_level[0])
	else:
		$WorldPlayer.position = $Worlds/World1/LevelTile1.position
		$WorldCamera.change_world(1)
	
	$WorldCamera.warp_camera()

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


func enter_level(tile):
	if tile.is_in_group("LevelTile"):
		Completed.current_level = [current_world,tile.level_num]
		print(" New Level Entered: ", Completed.current_level)
		print("world: ", current_world)
		match current_world:
			1:
				$Worlds/World1.enter_level(tile.level_num)
			2:
				$Worlds/World2.enter_level(tile.level_num)
	elif tile.is_in_group("Portal"):
		#1. find what world we're going to
		var target_world_num = tile.target_world
		var target_world = get_world_node(target_world_num)
		#2. get the position of the portal in the target world that leads to this world
		if target_world:
			var target_portal = target_world.get_portal(current_world)
			if target_portal:
				#teleport player to the target_portal
				current_world = target_world_num
				$WorldPlayer.position = target_portal.global_position
				$WorldCamera.change_world(current_world)

func get_world_node(world_num):
	match world_num:
		1:
			return $Worlds/World1
		2:
			return $Worlds/World2
	return null
