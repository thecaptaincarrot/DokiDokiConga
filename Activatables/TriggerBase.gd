extends Node2D

signal activate
signal deactivate

export var code = "AAA"

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


func pair(node):
	connect("activate", node, "activate") #The actor (?) needs to have an activate function
	connect("deactivate", node, "deactivate") #The actor (?) needs to have a deactivate function


func activate(): #only call when going from deactivated to activated
	active_turns.append(parent_level.get_turn())
	emit_signal("activate")
	active = true
	print("Active, ", name)


func deactivate(): #only call when going from activated to deactivated
	inactive_turns.append(parent_level.get_turn())
	emit_signal("deactivate")
	active = false
	print("InActive, ", name)
	

func get_active():
	return active


func undo(turn):
	pass
