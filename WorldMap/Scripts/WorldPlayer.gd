extends AnimatedSprite

var grid_position = Vector2(0,0)

var movement_scalar = 100
var movement_time = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	grid_position = Vector2(stepify(position.x, 64), stepify(position.y, 64))
	position = grid_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_movement_tween(new_position):
	$MovementTween.interpolate_property(self,"position",position,new_position, .5)
	$MovementTween.start()
