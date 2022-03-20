tool
extends AnimatedSprite

export var code = "AAA"

var blocking = true

var triggers = []

var active = false

export var all_or_nothing = false

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
			if trigger.get_active():
				active_check = true
		
		if active_check != active:
			if active_check:
				activate()
			else:
				deactivate()

func activate():
	blocking = false
	animation = "Open"


func deactivate():
	blocking = true
	animation = "Close"
