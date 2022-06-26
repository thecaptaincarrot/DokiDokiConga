extends "res://Activatables/ActivatorBase.gd"

export var default_open = false

func _ready():
	if default_open:
		active = true
		blocking = false
		$DoorSprite.animation = "Open"
		$DoorSprite.frame = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func activate():
	if default_open:
		active = false
		blocking = true
		$DoorSprite.animation = "Close"
	else:
		active = true
		blocking = false
		$DoorSprite.animation = "Open"


func deactivate():
	if default_open:
		active = true
		blocking = false
		$DoorSprite.animation = "Open"
	else:
		active = false
		blocking = true
		$DoorSprite.animation = "Close"
