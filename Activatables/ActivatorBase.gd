extends Node2D

export var code = "AAA"

var parent_level

var active = false

#arrays that will keep hold all the triggers that are coded to this activator
var switches = []
#Pressure Plates
var green_plates = []
var red_plates = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func activate():
	pass


func check_active():
	if check_buttons():
		return true
	
	#Levers: Do they toggle with each press?
	#Check if at least one lever is currently pressed
	for switch in switches: 
		if switch.active:
			return true


func check_buttons():
	#return true if any button condition is fulfilled
	#if any green pressure plate is pushed down, return true
	for plate in green_plates:
		if parent_level.get_partier_positions().has(plate.position):
			return true
	#if all red pressure paltes are pushed down, return true
	if red_plates != []: #needs to have at least one red to make this check
		var red_check = true
		for plate in red_plates:
			if !parent_level.get_partier_positions().has(plate.position):
				red_check = false
		if red_check:
			return true
	return false


func pair_trigger(new_trigger):
	if new_trigger.is_in_group("Green"):
		green_plates.append(new_trigger)
	elif new_trigger.is_in_group("Red"):
		red_plates.append(new_trigger)
	elif new_trigger.is_in_group("Switch"):
		switches.append(new_trigger)
