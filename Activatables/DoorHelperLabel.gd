tool
extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	if !Engine.editor_hint:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = get_parent().code
