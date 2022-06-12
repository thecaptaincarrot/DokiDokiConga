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


#Default End_Level() function


func escape(): #if tutorial has not been completed once, do not go to world map
	if Completed.completed_levels.has([0,1]):
		get_tree().change_scene("res://WorldMap/WorldMap.tscn")
	else:
		pass
