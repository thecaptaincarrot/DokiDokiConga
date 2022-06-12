extends Node

var completed_levels = {
	0 : [],
	1 : [], #Key is the world, array holds integers representing levels that have been completed
	2 : [],
	3 : [],
	4 : [],
}

var first_complete = false
var current_level = [-1,-1]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func level_completed():
	print("Completed level: ", current_level)
	if !completed_levels[current_level[0]].has(current_level[1]):
		completed_levels[current_level[0]].append(current_level[1])
		first_complete = true
