extends Node2D

var portals = {1 : null, 2 : null, 3 : null, 4 : null, 5 : null}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func check_clears(world_num):
	for level_num in Completed.completed_levels[world_num]:
		var nodepath = "LevelTile" + str(level_num)
		get_node(nodepath).green()
	
	if Completed.first_complete and Completed.current_level[0] == world_num:
		complete_level(Completed.current_level[1])


func enter_level(level_number):
	#TODO add level transiitons or fadeout or some animation
	print("And error has occured, I am using the default level entry function")


func complete_level(level_num):
	var nodepath = "LevelTile" + str(level_num)
	get_node(nodepath).confetti()
	Completed.first_complete = false


func get_tile(level_num):
	var nodepath = "LevelTile" + str(level_num)
	return get_node(nodepath)


func get_portal(target_world : int):
	return portals[target_world]
