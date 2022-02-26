extends "res://WorldMap/Scripts/WorldBase.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
