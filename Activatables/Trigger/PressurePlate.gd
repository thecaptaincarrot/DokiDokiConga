extends "res://Activatables/TriggerBase.gd"

var stuck
var stuck_turn = -1

var theme = "" setget set_theme


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	
func activate(): #only call when going from deactivated to activated
	active_turns.append(parent_level.get_turn())
	$PlateSprite.play(get_anim_name("Down"))
	active = true
	print("Active, ", name)


func deactivate(): #only call when going from activated to deactivated
	inactive_turns.append(parent_level.get_turn())
	$PlateSprite.play(get_anim_name("Up"))
	active = false


func get_anim_name(updown):
	print(theme + updown)
	return theme + updown


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
				stuck_turn = -1
				stuck = false
				update()
		else:
			update()
	else:
		update()


func set_theme(new_theme):
	theme = new_theme
	$PlateSprite.play(get_anim_name("Up"))
