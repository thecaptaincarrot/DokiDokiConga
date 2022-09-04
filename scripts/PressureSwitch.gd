extends Node2D

export var code = "AAA"

var active = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if active:
		$AnimatedSprite.frame = 1
	else:
		$AnimatedSprite.frame = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
