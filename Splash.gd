extends Control

var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	timer += 1
	match timer:
		1:
			$SaltySquad.hide()
			$Godot.show()
		2:
			$Godot.hide()
			get_tree().change_scene("res://HUD/MainMenu.tscn")
