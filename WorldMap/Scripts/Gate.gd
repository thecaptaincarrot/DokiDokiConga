extends AnimatedSprite

export var pass_num = 0 #number of levels needed to unlock gate
export var world = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var num_completed = len(Completed.completed_levels[world])
	if num_completed >= pass_num:
		animation = "Open"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func allow_move():
	var num_completed = len(Completed.completed_levels[world])
	return num_completed >= pass_num
