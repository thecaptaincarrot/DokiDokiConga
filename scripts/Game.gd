extends Node2D

var level = 0

var can_reset = true

# Called when the node enters the scene tree for the first time.
func _ready():
	add_level("res://Levels/PartyLevel0.tscn")
	$HUDLayer/FadeOut.set_fade_in(false)
	yield($HUDLayer/FadeOut,"finished")
	$LevelContainer.get_child(0).start()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if event.is_action_pressed("reset") and can_reset:
		reset_level()


func level_over():
	can_reset = false
	#1. fade to black or swirl
	$HUDLayer/FadeOut.set_fade_in(true)
	yield($HUDLayer/FadeOut,"finished")
	#2. unload old level
	$LevelContainer.get_child(0).delete_level()
	#3. fade in on level
	level += 1
	if level == 8:
		get_tree().change_scene("res://HUD/Credits.tscn")
		return
	
	add_level(get_level_path(level))
	
	$HUDLayer/FadeOut.set_fade_in(false)
	yield($HUDLayer/FadeOut,"finished")
	#4. play portals opening animations / other beginning of level stuff
	
	$LevelContainer.get_child(0).start()
	can_reset = true


func reset_level():
	can_reset = false
	get_tree().paused = true
	#1. fade to black or swirl
	$HUDLayer/FadeOut.set_fade_in(true)
	yield($HUDLayer/FadeOut,"finished")
	#2. unload old level
	$LevelContainer.get_child(0).delete_level()
	add_level(get_level_path(level))

	$HUDLayer/FadeOut.set_fade_in(false)
	yield($HUDLayer/FadeOut,"finished")
	#4. play portals opening animations / other beginning of level stuff
	get_tree().paused = false
	$LevelContainer.get_child(0).start()
	can_reset = true
	


func add_level(level_path):
	var new_level = load(level_path).instance()
	new_level.connect("LevelOver",self,"level_over")
	new_level.connect("PartierDied",self,"partier_died")
	
	$LevelContainer.add_child(new_level)


func partier_died():
	$HUDLayer/FadeOut.RED()



func get_level_path(target_level):
	match level:
		0:
			return "res://Levels/PartyLevel0.tscn"
		1:
			return "res://Levels/PartyLevel1.tscn"
		2:
			return "res://Levels/FutureLevel0.tscn"
		3:
			return "res://Levels/FutureLevel1.tscn"
		4:
			return "res://Levels/FutureLevel2.tscn"
		5:
			return "res://Levels/HospitalLevel0.tscn"
		6:
			return "res://Levels/HospitalLevel1.tscn"
		7:
			return "res://Levels/HospitalLevel2.tscn"
		8:
			get_tree().change_scene("res://HUD/Credits.tscn")
