extends AnimatedSprite

export var line_size = 10

var partiers_inside = 0

var last_partier #the last member of the line that was spawned
var parent_level

# Called when the node enters the scene tree for the first time.
func _ready():
	start()


func _process(delta):
	if animation != "Close":
		partiers_inside = 0
		for pos in parent_level.get_partier_positions():
			if pos == position:
				partiers_inside += 1
		if partiers_inside <= 1:
			play("Close")


func start():
	show()
	play("Open")
	position = Vector2(stepify(position.x,Global.grid_size),stepify(position.y,Global.grid_size))


func _on_LevelEntry_animation_finished():
	if animation == "Open":
		animation = "Loop"


func add_follower(_destionation):
	pass
