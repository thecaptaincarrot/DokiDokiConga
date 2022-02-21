extends Node2D

const PARTIER = preload("res://Partier.tscn")

const movement_events = ["ui_left","ui_right","ui_up","ui_down"]

var last_partier #the last member of the line that was spawned
export var line_size = 10
export var need_exit = 10

var partiers_left

signal LevelOver
signal PartierDied

# Called when the node enters the scene tree for the first time.
func _ready():
	partiers_left = line_size
	need_exit = line_size
	
	start()


func start():
	$LevelEntry.start()
	$LevelExit.start()
	
	var t = Timer.new()
	t.wait_time = 1.0
	add_child(t)
	t.start()
	yield(t,"timeout")
	t.queue_free()
	add_leader() #turn this into an animation instead??


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	check_buttons()
#	check_dead()
	pass


func _unhandled_input(event):
	pass


func add_leader():
	#Add a leader to the congo line at the level entry
	var new_leader = PARTIER.instance()
	new_leader.position = $LevelEntry.position
	new_leader.connect("IMoved", self, "add_follower") #No this sucks
	new_leader.connect("PartierExitted",self,"partier_exit")
	new_leader.is_leader = true
	new_leader.parent_level = self
	$Metronome.connect("UpdateFrame",new_leader,"tick_tock")
	$People.add_child(new_leader)
	line_size -= 1
	last_partier = new_leader


func add_follower(_destination):
	#This gets called way too often, every time movement is attempted
	#Add a follower following the leader at the level entry
	
	if line_size > 0:
		var new_follower = PARTIER.instance()
		new_follower.position = $LevelEntry.position
		new_follower.connect("PartierExitted",self,"partier_exit")
		new_follower.followed = last_partier
		new_follower.parent_level = self
		$Metronome.connect("UpdateFrame",new_follower,"tick_tock")
		$People.add_child(new_follower)
		line_size -= 1
		last_partier.follower = new_follower
		last_partier = new_follower
	else:
		$LevelEntry.animation = "Close"
		#disconnect signal?


func check_clear(direction, person_moving):
	var grid_position = person_moving.grid_position
	var destination = person_moving.grid_position + direction * Global.grid_size #if the person is reversed, check here
	#This checks the destination of the congaline and does appropriate actions
	#Must return true if the target is open for movement
	#Must return false if the congaline cannot move to the destination
		#Even if there's an activator or something else for the congaline to hit
	#Check tileset
		#compare the destination (which is in 32x32 blocks) to the tilemap
		#If filled with a tile, return false
	if $Walls.get_cellv(destination / Global.grid_size) != -1:
		return false
	#Check other partiers
	for person in $People.get_children():
		if person.grid_position == destination: #There is a person in my way, check one
			#check 2: if the person is not a caboose, return false
			#It will not move out of the way in time
			
			if !person.is_caboose():
				return false
			else:#Person is caboose, so now we need to know if the leader can move
				var leader = person.get_leader()
				if leader != person_moving:
					if !check_clear(direction, leader):
						return false
	return true

func check_exit(destination):
	if destination == $LevelExit.position:
		return true
	else:
		return false


func partier_exit():
	need_exit -= 1
	if need_exit <= 0:
		$LevelExit.animation = "Close"
		print("done")
		emit_signal("LevelOver")
