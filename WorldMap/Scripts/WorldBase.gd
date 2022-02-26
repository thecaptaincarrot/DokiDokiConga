extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for level_num in Completed.completed_levels[1]:
		var nodepath = "LevelTile" + str(level_num)
		get_node(nodepath).green()
	
	if Completed.first_complete and Completed.current_level[0] == 1:
		complete_level(Completed.current_level[1])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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
