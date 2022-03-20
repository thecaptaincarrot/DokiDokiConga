extends "res://WorldMap/Scripts/WorldBase.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	check_clears(1)
	portals[2] = $World2Portal


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func enter_level(level_number):
	match level_number:
		1:
			get_tree().change_scene("res://Levels/World1/Level1_1.tscn")
		2:
			get_tree().change_scene("res://Levels/World1/Level1_2.tscn")
		3:
			get_tree().change_scene("res://Levels/World1/Level1_3.tscn")
		4:
			pass
		5:
			pass
		6:
			pass
		7:
			pass
		8:
			pass
