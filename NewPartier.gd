extends Node2D

var grid_position = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(stepify(position.x,Global.grid_size),stepify(position.y,Global.grid_size))	
	grid_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
