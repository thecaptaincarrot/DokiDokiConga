extends Sprite

export var level_num = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func allow_move():
	return true


func green():
	self_modulate = Color.green


func confetti():
	$Confetti.emitting = true
