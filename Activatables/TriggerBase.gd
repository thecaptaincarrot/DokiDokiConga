extends Node2D

export var code = ["AAA"]

var active = false
var blocking = false

var active_turns = [] #When it goes from inactive to active
var inactive_turns = [] #When it goes from active to inactive

var parent_level

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func activate(): #only call when going from deactivated to activated
	active_turns.append(parent_level.get_turn())
	active = true
	print("Active, ", name)


func deactivate(): #only call when going from activated to deactivated
	inactive_turns.append(parent_level.get_turn())
	active = false



func update():
	pass


func get_active():
	return active


func undo(turn):
	pass
