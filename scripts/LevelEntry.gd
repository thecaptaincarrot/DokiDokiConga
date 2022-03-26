extends AnimatedSprite

export var line_size = 10

var last_partier #the last member of the line that was spawned

# Called when the node enters the scene tree for the first time.
func _ready():
	start()


func start():
	show()
	play("Open")
	position = Vector2(stepify(position.x,Global.grid_size),stepify(position.y,Global.grid_size))


func _on_LevelEntry_animation_finished():
	if animation == "Open":
		animation = "Loop"


func add_follower(_destionation):
	pass
