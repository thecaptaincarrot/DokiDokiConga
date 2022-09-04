tool
extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		text = str(get_parent().line_size)
	else:
		text = str(get_parent().partiers_inside)
		if get_parent().partiers_inside == 1:
			queue_free()
