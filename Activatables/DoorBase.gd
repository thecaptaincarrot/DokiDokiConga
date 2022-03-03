extends AnimatedSprite

var blocking = true

var activators = []

export var all_or_nothing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var num_activated = 0
	
	for activator in activators:
		if activator.active:
			num_activated += 1
	
	
	if num_activated > 0:
		if all_or_nothing and num_activated == len(activators):
			activate()
		elif num_activated > 1:
			activate()
		else:
			deactivate()
		
	else:
		deactivate()


func activate():
	blocking = false
	animation = "Open"


func deactivate():
	blocking = true
	animation = "Close"
