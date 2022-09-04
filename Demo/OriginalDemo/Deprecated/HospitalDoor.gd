extends AnimatedSprite

export var code = "AAA"

export var blocked_spaces = [Vector2(0,0),Vector2(0,32)]

var switches = []
export var all_or_nothing = false
var active = false

var blocking = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var num_switches = len(switches)
	var num_activated = 0
	
	for activator in switches:
		if activator.active:
			num_activated += 1
	
	if all_or_nothing:
		if num_activated >= num_switches:
			activate()
	else:
		if num_activated > 0:
			activate()
		else:
			deactivate()


func activate():
	blocking = false
	animation = "Open"


func deactivate():
	blocking = true
	animation = "Close"


