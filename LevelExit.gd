extends AnimatedSprite


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func start():
	show()
	play("Open")
	position = Vector2(stepify(position.x,Global.grid_size),stepify(position.y,Global.grid_size))


func _on_LevelExit_animation_finished():
	if animation == "Open":
		animation = "Loop"
