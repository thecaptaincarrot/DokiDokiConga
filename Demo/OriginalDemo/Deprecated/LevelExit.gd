tool
extends AnimatedSprite


export var num_exit = 0

var limited = false
var open = true

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


func _on_LevelExit_animation_finished():
	if animation == "Open":
		animation = "Loop"
	elif animation == "Close":
		hide()
