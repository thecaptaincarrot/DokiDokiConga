extends "res://WorldMap/Scripts/WorldBase.gd"


func _ready():
	check_clears(2)
	portals[1] = $World1Portal


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func enter_level(level_number):
	match level_number:
		1:
			get_tree().change_scene("res://Levels/World2/Level2_1.tscn")
		2:
			pass
		3:
			pass
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
