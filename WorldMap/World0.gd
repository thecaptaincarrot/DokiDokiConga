extends "res://WorldMap/Scripts/WorldBase.gd"

signal TutorialComplete

# Called when the node enters the scene tree for the first time.
func _ready():
	check_clears(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func enter_level(level_number):
	match level_number:
		1:
			get_tree().change_scene("res://Levels/Tutorial/Tutorial1.tscn")


func check_clears(world_num):
	for level_num in Completed.completed_levels[world_num]:
		var nodepath = "LevelTile" + str(level_num)
		get_node(nodepath).green()
	
	if Completed.first_complete and Completed.current_level[0] == world_num:
		complete_level(Completed.current_level[1])
		emit_signal("TutorialComplete")
		first_clear()


func first_clear():
	$BridgeAnimation.play("Bridge")
