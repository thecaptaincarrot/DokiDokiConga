tool
extends AnimatedSprite

var parent_level

export var num_exit = 0

var limited = false
var open = true

var exit_turns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	start()
	$Label.text = str(num_exit)
	if num_exit != 0:
		limited = true
	else:
		limited = false


func _process(delta):
	if Engine.editor_hint:
		if num_exit != 0: $Label.text = str(num_exit)
		else: $Label.text = ""


func start():
	show()
	play("Open")
	position = Vector2(stepify(position.x,Global.grid_size),stepify(position.y,Global.grid_size))


func close():
	play("Open")


func undo():
	pass
	#The partiers will leave the portal on their own
	#The portal only needs to increase its number if it's limited
	#If it is not limited, pass.
	#If undo turn is in undo[]
	#1. Reopen the portal if num_exit == 0 before the undo
	#2. pop the undo turn from the array
	#3. increment the number needed to exit
#


func decrement():
	pass


func _on_LevelExit_animation_finished():
	if animation == "Open":
		animation = "Loop"
	elif animation == "Close":
		hide()
