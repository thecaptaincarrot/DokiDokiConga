extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$FadeIn.fade_in = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Play_pressed():
	$Play.disabled = true
	$Credits.disabled = true
	
	$FadeIn.fade_in = true
	
	yield($FadeIn,"finished")
	
	get_tree().change_scene("res://Game.tscn")


func _on_Credits_pressed():
	$Play.disabled = true
	$Credits.disabled = true
	
	$FadeIn.fade_in = true
	
	yield($FadeIn,"finished")
	
	get_tree().change_scene("res://HUD/Credits.tscn")
