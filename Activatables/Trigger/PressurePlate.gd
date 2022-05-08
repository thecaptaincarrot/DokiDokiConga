extends "res://Activatables/TriggerBase.gd"

var stuck
var stuck_turn = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func activate(): #only call when going from deactivated to activated
	active_turns.append(parent_level.get_turn())
	$PlateSprite.play("Down")
	active = true
	print("Active, ", name)


func deactivate(): #only call when going from activated to deactivated
	inactive_turns.append(parent_level.get_turn())
	$PlateSprite.play("Up")
	active = false
	print("InActive, ", name)


func update():
	if is_in_group("Purple") and stuck:
		if !get_active():
			activate()
		return
	
	if parent_level.get_partier_positions().has(position):
		if !get_active():
			activate()
	else:
		if get_active():
			deactivate()


func undo(turn):
	if is_in_group("Purple"):
		if stuck:
			if turn == stuck_turn - 1:
				print("Unstick")
				stuck_turn = -1
				stuck = false
				update()
		else:
			update()
	else:
		update()
