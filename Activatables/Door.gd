extends "res://Activatables/ActivatorBase.gd"


var blocking = false


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if check_active():
		blocking = false
		$AnimatedSprite.play("Open")
	else:
		blocking = true
		$AnimatedSprite.play("Close")
