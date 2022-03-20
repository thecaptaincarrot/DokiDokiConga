tool
extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = str(get_parent().line_size)
	if get_parent().line_size == 0:
		queue_free()
