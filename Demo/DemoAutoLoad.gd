extends Node

var completion_times = {}
var completed = []


var current_level = 1
var current_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(0,15):
		completion_times[i] = 0.00
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_time += delta


func complete_level():
	completion_times[current_level] = current_time
	current_time = 0
	
	print(completion_times)
	
	current_level += 1
	go_to_level(current_level)



func go_to_level(level):
	if level > 14:
		get_tree().change_scene("res://Demo/DemoEndScreen.tscn") #GOTO the end screen
		return
	
	var level_path = "res://Levels/Tests/test" + str(level) + ".tscn"
	get_tree().change_scene(level_path)

