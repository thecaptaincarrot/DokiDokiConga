extends Timer

const frame_order = [1,0,2,0,1,0,3,3,2,0,1,0,2,0,4,4] #This is based on the current spritesheet
var frame = 0

signal UpdateFrame

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Metronome_timeout():
	frame += 1
	if frame > len(frame_order) - 1:
		frame = 0
	
	emit_signal("UpdateFrame",frame_order[frame])
