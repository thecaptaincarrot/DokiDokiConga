extends Node2D

const PARTIER = preload("res://Partier.tscn")

var last_partier #the last member of the line that was spawned
export var line_size = 10
export var need_exit = 10

var partiers_left

signal LevelOver
signal PartierDied

# Called when the node enters the scene tree for the first time.
func _ready():
	pair_activators()
	partiers_left = line_size
	need_exit = line_size


func start():
	$LevelEntry.start()
	$LevelExit.start()
	
	var t = Timer.new()
	t.wait_time = 1.0
	add_child(t)
	t.start()
	yield(t,"timeout")
	t.queue_free()
	add_leader()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_buttons()
	check_dead()


func pair_activators():
	for N in $Interactive/Switches.get_children():
		for active in $Interactive/Activators.get_children():
			if N.code == active.code:
				active.switches.append(N)


func add_leader():
	#Add a leader to the congo line at the level entry
	var new_leader = PARTIER.instance()
	new_leader.position = $LevelEntry.position
	new_leader.connect("MovementAttempted", self, "add_follower")
	new_leader.connect("PartierExitted",self,"partier_exit")
	new_leader.leader = true
	new_leader.parent_level = self
	$Metronome.connect("UpdateFrame",new_leader,"tick_tock")
	$People.add_child(new_leader)
	line_size -= 1
	last_partier = new_leader


func add_follower():
	#Add a follower following the leader at the level entry
	for N in $People.get_children():
		if N.grid_position == $LevelEntry.position:
			return
	
	if line_size > 0:
		var new_follower = PARTIER.instance()
		new_follower.position = $LevelEntry.position
		new_follower.connect("PartierExitted",self,"partier_exit")
		new_follower.front_person = last_partier
		new_follower.parent_level = self
		$Metronome.connect("UpdateFrame",new_follower,"tick_tock")
		$People.add_child(new_follower)
		line_size -= 1
		last_partier.follower = new_follower
		last_partier = new_follower
	else:
		$LevelEntry.animation = "Close"
		#disconnect signal?


func check_buttons():
	for N in $Interactive/Switches.get_children():
		if N.is_in_group("Button"):
			var button_pressed = false
			for P in $People.get_children():
				if P.grid_position == N.position:
					button_pressed = true
			
			if button_pressed:
				N.active = true
				N.get_node("AnimatedSprite").frame = 1
			else:
				N.active = false
				N.get_node("AnimatedSprite").frame = 0

func check_clear(destination,from):
	#return true if there is no blockage in the destination
	#else return false
	for N in $Obstacles.get_children():
		if N.is_in_group("Blocker") and N.position == destination:
			return false
		elif N.is_in_group("HBlocker") and (((destination.x - from.x < 0) and from == N.position) or ((destination.x - from.x > 0) and destination == N.position)):
			return false
		elif N.is_in_group("VBlocker") and (((destination.y - from.y < 0) and from == N.position) or ((destination.y - from.y > 0) and destination == N.position)):
			return false
		
	for N in $Interactive/Switches.get_children():
		if N.is_in_group("Blocker") and N.position == destination:
			return false

	for N in $Interactive/Activators.get_children():
		if N.blocking:
			for vector in N.blocked_spaces:
				if destination == N.position + vector:
					return false

	for N in $People.get_children():
		if N.is_in_group("Blocker") and N.grid_position == destination:
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
		emit_signal("LevelOver")


func check_dead():
	#Obstacles don't move and shouldn't kill people
	for partier in $People.get_children():
		for N in $Interactive/Activators.get_children():
			if N.blocking:
				for vector in N.blocked_spaces:
					if partier.grid_position == N.position + vector:
						partier.kill()
						emit_signal("PartierDied")
						$CanvasLayer/PartierDied.show()
						return


func delete_level():
	call_deferred("queue_free")
