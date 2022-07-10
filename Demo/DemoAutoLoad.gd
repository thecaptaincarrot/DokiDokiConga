extends Node

var completion_times = {}
var completed = []



var current_level = -1
var current_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(0,15):
		completion_times[i] = 0.00
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_time != -1:
		current_time += delta


func complete_level():
	completed.append(current_level)
	stop_timing()
	
	
	print(completion_times)
	
	get_tree().change_scene("res://Demo/DemoWorldMap.tscn")
	
#	current_level += 1
#	go_to_level(current_level)



func go_to_level(level):
	if level > 14:
		get_tree().change_scene("res://Demo/DemoEndScreen.tscn") #GOTO the end screen
		return
	
	var level_path = "res://Levels/Tests/test" + str(level) + ".tscn"
	get_tree().change_scene(level_path)


func start_timing():
	if completion_times.has(current_level):
		current_time = completion_times[current_level]
		print("loaded time ",current_time," for level ", current_level)
	else:
		current_time = 0.0
		completion_times[current_level] = current_time
		print("started new timer for level ",current_level)


func stop_timing():
	print("Stopped timing for level ", current_level, " at time ", current_time)
	completion_times[current_level] = current_time
	current_level = -1
	
	
