extends Node2D

var level = 0

var can_reset = true

# Called when the node enters the scene tree for the first time.
func _ready():
	add_level("res://Levels/TutorialLevel0.tscn")
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
	
	match level:
		0:
			add_level("res://Levels/TutorialLevel0.tscn")
		1:
			add_level("res://Levels/TutorialLevel1.tscn")
		2:
			add_level("res://Levels/TutorialLevel2.tscn")
		3:
			add_level("res://Levels/Level3.tscn")
		4:
			add_level("res://Levels/Level4.tscn")
		5:
			get_tree().change_scene("res://HUD/Credits.tscn")

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
	match level:
		0:
			add_level("res://Levels/TutorialLevel0.tscn")
		1:
			add_level("res://Levels/TutorialLevel1.tscn")
		2:
			add_level("res://Levels/TutorialLevel2.tscn")
		3:
			add_level("res://Levels/Level3.tscn")
		4:
			add_level("res://Levels/Level4.tscn")

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
