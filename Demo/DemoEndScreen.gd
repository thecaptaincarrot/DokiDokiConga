extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range (1,15):
		get_node("Panel/VBoxContainer/Level" + str (i) + "/Time").text = str(DemoAutoLoad.completion_times[i])
		if DemoAutoLoad.gave_up.has(i):
			get_node("Panel/VBoxContainer/Level" + str (i) + "/Gave Up")
		
#	$Panel/VBoxContainer/Level1/Time = str(DemoAutoLoad.completion_times)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
