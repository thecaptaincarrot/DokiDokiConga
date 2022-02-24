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
	if event.is_action_pressed("ui_left"):
		move(Vector2(-1 ,0))
	elif event.is_action_pressed("ui_right"):
		move(Vector2(1,0))
	elif event.is_action_pressed("ui_up"):
		move(Vector2(0,-1))
	elif event.is_action_pressed("ui_down"):
		move(Vector2(0,1))


func move(direction): #move all leaders in the given directions
	#1. find all leaders among all partiers
	var leaders = []
	for partier in $People.get_children():
		if partier.is_leader:
			leaders.append(partier)
	#2. Simulate movements for all leaders, checking only environmental factors
	#Use Check Clear to see if the leader moves
	var simulated_positions = []
	var leader_info = []
	for leader in leaders:
		var fixed_direction = direction
		if leader.reverse:
			fixed_direction *= -1
		var can_move = false
		var leader_move = leader.grid_position + fixed_direction * Global.grid_size
		var conga_positions = leader.get_line_positions() #line positions of line that is not moving
		if check_clear(fixed_direction, leader) and !leader.check_line_fill(leader_move): #Leader can move in the direction, continue simulation
#			leader_move = leader.grid_position + fixed_direction * Global.grid_size
			conga_positions.append(leader_move)
			conga_positions.erase(leader.get_caboose().grid_position)
			can_move = true
		else: #Way is blocked, cannot move so the orignal array is fine
			pass
		simulated_positions += conga_positions
		leader_info.append({"leader" : leader, "positions" : conga_positions, "leader_move" : leader_move, "moving" : can_move })
	#I now have all leaders and where they're going to be. Now I need to see if they can move
	for leader_dict in leader_info:
		#Don't care if the leader isn't moving from the obstacle check
		if leader_dict["moving"]:
			#check if their prospective position is already taken up
			#must be taken up at least twice since their own position is in the array too
			var self_check = false
			var can_move = true
			for simulated_position in simulated_positions:
				if simulated_position == leader_dict["leader_move"]:
					if self_check:
						#I found myself and one other person and I cannot move
						#TODO check if two leaders are trying to enter the same space
						can_move = false
						break
					else:
						self_check = true
						#Found myself in the array, anyone else?
			if can_move:
				leader_dict["leader"].move_to(leader_dict["leader_move"]) #Is this the last check? I think so

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


func check_clear(direction, person_moving):
	#only checks obstacles, not people
	#TODO activators
	var grid_position = person_moving.grid_position
	var destination = person_moving.grid_position + direction * Global.grid_size
	#This checks the destination of the congaline and does appropriate actions
	#Must return true if the target is open for movement
	#Must return false if the congaline cannot move to the destination
		#Even if there's an activator or something else for the congaline to hit
	#Check tileset
		#compare the destination (which is in 32x32 blocks) to the tilemap
		#If filled with a tile, return false
	if $Walls.get_cellv(destination / Global.grid_size) != -1:
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
