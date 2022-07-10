extends "res://Activatables/ActivatorBase.gd"

var completed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	if !completed:
		var i = 0
		for plate in purple_plates:
			if !plate.get_active():
				i += 1
		
		$CounterText.text = str(i)
		
		if i == 0:
			completed = true
			$Background.hide()
			$CounterText.hide()
			$Completed.show()
