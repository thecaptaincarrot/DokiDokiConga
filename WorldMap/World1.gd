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
			get_tree().change_scene("res://Levels/Tests/Test1.tscn")
		2:
			get_tree().change_scene("res://Levels/Tests/Test2.tscn")
		3:
			get_tree().change_scene("res://Levels/Tests/Test3.tscn")
		4:
			get_tree().change_scene("res://Levels/Tests/Test4.tscn")
		5:
			get_tree().change_scene("res://Levels/Tests/Test5.tscn")
		6:
			get_tree().change_scene("res://Levels/World1/Level1_1.tscn")
		7:
			pass
		8:
			pass
