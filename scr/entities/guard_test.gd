extends KinematicBody

# enemy prototype script

export var max_speed = 10
export var max_sprint_speed = 20
export var jump_speed = 8
export var walk_accel = 4.5
export var sprint_accel = 18.0
export var deaccel = 16
export var max_slope_angle = 40

var is_sprinting = false
var dir = Vector3()
var vel = Vector3()

# possible states
var states = [
	'idle',
	'walking',
	'alert',
	'chasing',
	'attacking'	
]
var current_state = states[0]
var current_target = null
var waypoint = 'waypoint0'

func _ready():
	pass

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	
func process_input(delta):
	# walking
	dir = Vector3()

	var input_movement_vector = Vector2()
	
	# find target
	if current_target == null:
		current_target = find_target()
	
	# decide on action (walk, run, idle, attack)
	if current_target != null:
		look_at(current_target.global_transform.origin, Vector3.UP)
		rotation_degrees.x = 0
		input_movement_vector.y = -1
	
	# rotate towards target
	
	input_movement_vector = input_movement_vector.normalized()
	
	dir += global_transform.basis.z.normalized() * input_movement_vector.y
	dir += global_transform.basis.x.normalized() * input_movement_vector.x
	
	# jumping
	if is_on_floor():
		if Input.is_action_just_pressed('game_jump'):
			vel.y = jump_speed	

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	
	vel.y += delta * main.gravity
	var hvel = vel
	hvel.y = 0
	var target = dir
	target *= max_sprint_speed if is_sprinting else max_speed
	
	var accel
	if dir.dot(hvel) > 0:
		accel = sprint_accel if is_sprinting else walk_accel
	else:
		accel = deaccel
		
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3.UP, 0.05, 4, deg2rad(max_slope_angle))
	
func find_target():
	var bodies = $detection_area.get_overlapping_bodies()
	for body in bodies:
		if body.name.find('player') != -1:
			return body
		