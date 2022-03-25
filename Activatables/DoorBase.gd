tool
extends AnimatedSprite

export var code = "AAA"

var blocking = true

var triggers = []

var active = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		pass
	
	else:
		var active_check = false
		for trigger in triggers:
			if trigger.get_active(): #Only need one true state
				active_check = true
				break
		
		if active_check != active:
			if active_check:
				activate()
			else:
				deactivate()

func activate():
	active = true
	blocking = false
	animation = "Open"


func deactivate():
	active = false
	blocking = true
	animation = "Close"
