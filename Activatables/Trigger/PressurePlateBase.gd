tool
extends "res://Activatables/TriggerBase.gd"
#This node holds all pressure plates of a given code
#If another pressure plate of a given code is also paired, who knows what will happen
#Individual pressure plates are instanced to this parent node like normal
#And inherit the code from this node.  This node will do all the needed checking to see
#If it is active or not.

#From inherited
#signal activate
#signal deactivate
#
#export var code = "AAA"
#
#var active = true
#
#var active_turns = [] #When it goes from inactive to active
#var inactive_turns = [] #When it goes from active to inactive
#
#var parent_level

#Arrays of pressure plates, sorted by color?
var greens = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for plates in get_children():
		if plate.is_in_group("Green"):
			greens.append(plate)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		for plate in get_children(): #Will the children ever not be plates?
			if plate.code != code:
				plate.code = code


func get_active():
	#Greens, only one needs to be pressed
	for plate in greens:
		if parent_level.get_
