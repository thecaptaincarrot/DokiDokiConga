tool
extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.editor_hint:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = str(get_parent().get_parent().need_exit)
