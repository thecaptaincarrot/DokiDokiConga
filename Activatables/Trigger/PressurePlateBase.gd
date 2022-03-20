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
var reds = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for plate in get_children(): #Will the children ever not be plates?
		if plate.code != code:
			plate.code = code
		#Color matching
		if plate.is_in_group("Green"):
			greens.append(plate)
		if plate.is_in_group("Red"):
			reds.append(plate)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		for plate in get_children(): #Will the children ever not be plates?
			if plate.code != code:
				plate.code = code
	else:
		check_pressed()


func check_pressed(): #Presses all buttons if a 
	for plate in get_children():
		if parent_level.get_partier_positions().has(plate.position):
			plate.play("Down")
		else:
			plate.play("Up")

func get_active(): #Only needs to return true once, doesn't matter if multiple true states
	#Greens, only one needs to be pressed
	for plate in greens:
		if parent_level.get_partier_positions().has(plate.position):
			return true
	if reds != []: #needs to have at least one red to make this check
		var red_check = true
		for plate in reds:
			if !parent_level.get_partier_positions().has(plate.position):
				red_check = false
		if red_check:
			return true
