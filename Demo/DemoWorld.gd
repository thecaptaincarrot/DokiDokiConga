extends "res://WorldMap/Scripts/WorldBase.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	check_clears(1)
	portals[2] = $World2Portal


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func enter_level(level_number):
	var test_name = "test" + str(level_number)
	var test_path = "res://Levels/Tests/" + test_name + ".tscn"
	
	get_tree().change_scene(test_path)
