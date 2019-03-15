extends KinematicBody

export var max_speed = 20
export var max_sprint_speed = 50
export var jump_speed = 18
export var walk_accel = 4.5
export var sprint_accel = 18.0
export var deaccel = 16
export var max_slope_angle = 40

export var camera_max_angle = 80

var is_sprinting = false
var dir = Vector3()
var vel = Vector3()

onready var camera = $Camera
onready var weapon_mount = $Camera/weapon_mount
onready var info_label = main.info_label

# weapon test
var sword_test_prefab = preload('res://obj/mdl/weapons_test/rocketlauncher_fps_test.tscn')
var rocket_test_prefab = preload('res://obj/mdl/weapons_test/test_rocket.tscn')
var last_rocket_time = OS.get_ticks_msec()
var rocket_cooldown = 800
var sword

func _ready():
	sword = sword_test_prefab.instance()
	sword.transform.origin = weapon_mount.transform.origin
	weapon_mount.add_child(sword)
	main.connect('mouse_motion', self, 'mouse_look')

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	
func process_input(delta):
	# walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed('game_up'):
		input_movement_vector.y += 1
	if Input.is_action_pressed('game_down'):
		input_movement_vector.y -= 1
	if Input.is_action_pressed('game_right'):
		input_movement_vector.x += 1
	if Input.is_action_pressed('game_left'):
		input_movement_vector.x -= 1
		
	#weapon test
	if Input.is_action_pressed('game_attack') and OS.get_ticks_msec() >= (last_rocket_time + rocket_cooldown):
		last_rocket_time = OS.get_ticks_msec()
		var rocket = rocket_test_prefab.instance()
		rocket.global_transform.origin = sword.firing_point.global_transform.origin
		rocket.rotation.x = camera.rotation.x
		rocket.rotation.y = rotation.y
		main.current_scene().add_child(rocket)
	
	is_sprinting = Input.is_action_pressed('game_sprint')
	
	input_movement_vector = input_movement_vector.normalized()
	
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	
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
	vel = move_and_slide(vel, Vector3(0,1,0), 0.05, 4, deg2rad(max_slope_angle))
	
func mouse_look(relative):
	camera.rotate_x(deg2rad(relative.y * main.mouse_sensitivity * main.invert_look))
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -camera_max_angle, camera_max_angle)
	self.rotate_y(deg2rad(relative.x * main.mouse_sensitivity * -1))