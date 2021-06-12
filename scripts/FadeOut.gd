extends ColorRect

var fade_in = true setget set_fade_in

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fade_in:
		if color.a < 1.0:
			color.a += delta
		else:
			emit_signal("finished")
	else:
		if color.a > 0.0:
			color.a -= delta
		else:
			emit_signal("finished")


func set_fade_in(new_fade):
	color.r = 0.0
	color.g = 0.0
	color.b = 0.0
	
	fade_in = new_fade


func RED():
	color = Color.red
