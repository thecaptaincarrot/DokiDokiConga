extends Node2D

export var code = "AAA"

var parent_level

var active = false
var blocking = false

#arrays that will keep hold all the triggers that are coded to this activator
var switches = []
#Pressure Plates
var green_plates = []
var red_plates = []
var purple_plates = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func activate():
	print("Active ",name)


func deactivate():
	print("Inactive ",name)


func active_check():
	if check_all_triggers():
		activate()
	else:
		deactivate()


func check_all_triggers():
	if check_plates():
		return true
	
	#Levers: Do they toggle with each press?
	#Check if at least one lever is currently pressed
	for switch in switches: 
		if switch.get_active():
			return true


func check_plates():
	#return true if any button condition is fulfilled
	#if any green pressure plate is pushed down, return true
	for plate in green_plates:
		if plate.get_active():
			return true
	#if all red pressure paltes are pushed down, return true
	if red_plates != []: #needs to have at least one red to make this check
		var red_check = true
		for plate in red_plates:
			if !plate.get_active():
				red_check = false
		if red_check:
			return true
	#If all purple plates are pushed down, they stay stuck.
	#I don't *love* that this is handled by an activator, but I don't
	#Know where else to put this.
	if purple_plates != []:
		var purple_check = true
		for plate in purple_plates:
			if !plate.get_active():
				purple_check = false
		if purple_check:
			for plate in purple_plates:
				if !plate.stuck:
					plate.stuck = true
					plate.stuck_turn = parent_level.turn
			return true
	
	return false


func pair_trigger(new_trigger):
	print("Pairing With ", new_trigger)
	if new_trigger.is_in_group("Green"):
		green_plates.append(new_trigger)
	elif new_trigger.is_in_group("Red"):
		red_plates.append(new_trigger)
	elif new_trigger.is_in_group("Purple"):
		purple_plates.append(new_trigger)
	elif new_trigger.is_in_group("Switch") or new_trigger.is_in_group("Lever"):
		
		switches.append(new_trigger)
