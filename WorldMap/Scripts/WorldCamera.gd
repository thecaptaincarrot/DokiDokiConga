extends Camera2D

var current_world
var target_location = Vector2(0,0)
var lerp_scalar = 0.08

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = lerp(position,target_location,lerp_scalar)


func change_world(world_num):
	match world_num:
		1: target_location = Vector2(384, 192)
		2: target_location = Vector2(1216,192)
	print("world # and Vector: " , world_num , target_location)


func warp_camera():
	position = target_location
