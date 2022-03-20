extends "res://Activatables/TriggerBase.gd"



# Called when the node enters the scene tree for the first time.
func _ready():
	blocking = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func toggle():
	if active:
		$LeverSprite.play("Off")
		deactivate()
	else:
		$LeverSprite.play("On")
		activate()


func undo(turn):
	if active_turns.has(turn):
		print("Undid Active)")
		emit_signal("deactivate")
		active = false
		$LeverSprite.play("Off")
		
		active_turns.erase(turn)
	elif inactive_turns.has(turn):
		print("Undid Inactive)")
		emit_signal("activate")
		active = true
		$LeverSprite.play("On")
		
		active_turns.erase(turn)
