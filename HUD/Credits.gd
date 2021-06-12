extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$VBoxContainer.rect_position.y -= delta * 50
	if $VBoxContainer.rect_position.y <= -1200:
		get_tree().change_scene("res://HUD/MainMenu.tscn")


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://HUD/MainMenu.tscn")
