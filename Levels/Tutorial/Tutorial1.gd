extends "res://Levels/NewLevelBase.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func end_level():
	get_tree().change_scene("res://Levels/Tutorial/Tutorial2.tscn")


func escape(): #if tutorial has not been completed once, do not go to world map
	print(Completed.completed_levels)
	if Completed.completed_levels[0].has(1):
#		get_tree().change_scene("res://WorldMap/WorldMap.tscn")
		get_tree().change_scene("res://Demo/DemoWorldMap.tscn")
	else:
		pass
