extends Node

var MusicPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	MusicPlayer = AudioStreamPlayer.new()
#	get_node("/root/").call_deferred("add_child",MusicPlayer)
#	MusicPlayer.stream = load("res://music_dave_miles_carnival_vibes_007.wav")
#	MusicPlayer.play()

func change_track(tracknum):
	#TODO fade out old track and fade in new track
	pass
