extends Node2D

var followed

signal IMoved

# Called when the node enters the scene tree for the first time.
func _ready():
	if followed != null:
		followed.connect("IMoved",self,"move_to")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func move_to(destination):
	#Followers should never need to check where they're going
	var prev_position = position
	
	position = destination
	
	emit_signal("IMoved",prev_position)
