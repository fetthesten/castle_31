extends KinematicBody

export var movement_speed = 30
export var jump_speed = 5
export var deceleration = 80
export var max_movement_speed = 20

onready var camera = $Camera
onready var weapon_mount = $weapon_mount
onready var info_label = main.info_label

var sword_test_prefab = preload('res://obj/mdl/weapons_test/fps_sword_test.tscn')

var current_movespeed = 0
var current_jumpmagnitude = 0
# movement vector at the time of a jump to direct aerial movement
var last_grounded_move_vector = main.V3_GRAVITY
# make look sensitivity adjustable, suggest settings from 0.001 to 0.01 for mouse
var mouse_sensitivity = 0.005
# maybe 0.0003 to 0.001 for stick
var stick_sensitivity = 0.001
# make stick deadzone adjustable because not all sticks are equal, 0.3 works fine for me
var stick_deadzone = 0.3
# msec tick time for last mouse movement, to avoid duplicating mouse events
var last_mouse_move = 1
var is_grounded = false



func _ready():
	var sword = sword_test_prefab.instance()
	sword.transform.origin = weapon_mount.transform.origin
	weapon_mount.add_child(sword)

func _process(delta):
	var move = main.V3_GRAVITY
	var look = Vector2.ZERO
	
	# get move axes/inputs, stick overrides keys
	if Input.is_action_pressed('game_up'):
		move -= transform.basis.z
	elif Input.is_action_pressed('game_down'):
		move += transform.basis.z
	if Input.is_action_pressed('game_left'):
		move -= transform.basis.x
	elif Input.is_action_pressed('game_right'):
		move += transform.basis.x
	
	if abs(Input.get_joy_axis(0, JOY_ANALOG_LX)) > stick_deadzone:
		move += transform.basis.x * Input.get_joy_axis(0, JOY_ANALOG_LX)
	if abs(Input.get_joy_axis(0, JOY_ANALOG_LY)) > stick_deadzone:
		move += transform.basis.z * Input.get_joy_axis(0, JOY_ANALOG_LY)
	
	if is_grounded: 
		last_grounded_move_vector = move
		if Input.is_action_pressed('game_jump'):
			current_jumpmagnitude = 1.0
	else:
		move = lerp(last_grounded_move_vector, move, 0.25)
	
	
	# get look axes, stick overrides mouse
	if main.mouse_state.last_move != last_mouse_move:
		last_mouse_move = main.mouse_state.last_move
		look = main.mouse_state.move * -mouse_sensitivity
		look.y = -look.y if main.invert_look else look.y
	
	if abs(Input.get_joy_axis(0, JOY_ANALOG_RX)) > stick_deadzone:
		look.x = Input.get_joy_axis(0, JOY_ANALOG_RX) * -stick_sensitivity
	if abs(Input.get_joy_axis(0, JOY_ANALOG_RY)) > stick_deadzone:
		look.y = Input.get_joy_axis(0, JOY_ANALOG_RY) * -stick_sensitivity
		look.y = -look.y if main.invert_look else look.y
	
	if move != main.V3_ZERO:
		current_movespeed += movement_speed * delta
		current_movespeed = min(current_movespeed, max_movement_speed)
	else:
		current_movespeed -= deceleration * delta
		current_movespeed = max(current_movespeed, 0)
	
	if current_jumpmagnitude > 0:
		current_jumpmagnitude += main.V3_GRAVITY.y * delta
	
	move.y += jump_speed * current_jumpmagnitude
	
	var collision = move_and_collide(move * current_movespeed * delta)
	if collision:
		if collision.travel.y < 0:
			is_grounded = true
	else:
		is_grounded = false
	
	main.info_label.text = str('grounded: ' + str(is_grounded))
	#camera.rotate_object_local(Vector3(1,0,0), deg2rad(look.y))
	#self.rotate_object_local(Vector3(0,1,0), deg2rad(look.x))
	self.set_rotation(self.get_rotation() + Vector3(0, look.x, 0))
	var cam_rotation = camera.get_rotation() + Vector3(look.y, 0, 0)
	cam_rotation.x = clamp(cam_rotation.x, PI / -2, PI /2)
	camera.set_rotation(cam_rotation)
	
	transform = transform.orthonormalized()