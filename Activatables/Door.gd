extends "res://Activatables/ActivatorBase.gd"



func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func activate():
	active = true
	blocking = false
	$DoorSprite.animation = "Open"


func deactivate():
	active = false
	blocking = true
	$DoorSprite.animation = "Close"
