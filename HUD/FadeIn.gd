extends ColorRect

var fade_in = false

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fade_in:
		color.a += delta
		
		if color.a > 1.0:
			emit_signal("finished")
	elif color.a >= 0:
		color.a -= delta
