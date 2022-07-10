extends Control

var Go = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if event is InputEventKey and Go:
		get_tree().change_scene("res://Demo/DemoWorldMap.tscn")
		#Continue to test 1


func _on_ContinueTimer_timeout():
	Go = true
	$Label2.show()
