extends KinematicBody

export var movement_speed = 30
export var deceleration = 80
export var max_movement_speed = 20
export var rotation_speed = 100
export var camera_offset = Vector3(0,20,12)
onready var area_check = $area_check
onready var camera = main.current_camera
onready var info_label = main.info_label

var weapons = []
var current_weapon = 0
var current_movespeed = 0
var forward = main.V3_UP

var weapon_model
var last_dir = main.V3_UP
var last_movetime = 0
var last_step = 0
onready var weapon_offset = $weapon_offset
var weap_tween
var can_move = true

var current_area = ''
var camera_target = self

func _ready():
	weap_tween = Tween.new()
	add_child(weap_tween)
	
	weapons.append({'name': 'knife', 'damage': 1, 'scale': 1.0, 'distance': 8, 'cooldown': Timer.new(), 'movestop': Timer.new(), 'ingame_mdl': load('res://obj/mdl/weapons/knife01.tscn').instance(), 'hud_img': preload('res://gfx/hud/knife01.png')})
	weapons.append({'name': 'sword', 'damage': 3, 'scale': 1.0, 'distance': 16, 'cooldown': Timer.new(), 'movestop': Timer.new(), 'ingame_mdl': load('res://obj/mdl/weapons/sword01.tscn').instance(),  'hud_img': preload('res://gfx/hud/sword01.png')})
	weapons[0].cooldown.one_shot = true
	weapons[0].cooldown.wait_time = 0.3
	weapons[0].cooldown.connect('timeout', self, 'attack_stop')
	add_child(weapons[0].cooldown)
	weapons[0].movestop.one_shot = true
	weapons[0].movestop.wait_time = 0.001
	weapons[0].movestop.connect('timeout', self, 'move_restore')
	add_child(weapons[0].movestop)
	add_child(weapons[0].ingame_mdl)
	weapons[0].ingame_mdl.visible = false
	weapons[1].cooldown.one_shot = true
	weapons[1].cooldown.wait_time = 0.5
	weapons[1].cooldown.connect('timeout', self, 'attack_stop')
	add_child(weapons[1]['cooldown'])
	weapons[1].movestop.one_shot = true
	weapons[1].movestop.wait_time = 0.15
	weapons[1].movestop.connect('timeout', self, 'move_restore')
	add_child(weapons[1].movestop)
	add_child(weapons[1].ingame_mdl)
	weapons[1].ingame_mdl.visible = false
	
	weapon_model = weapons[0].ingame_mdl
	
	change_weapon(true)
	
func _process(delta):
	var move = main.V3_ZERO
	if Input.is_action_pressed('game_up'):
		move += main.V3_UP
	elif Input.is_action_pressed('game_down'):
		move += main.V3_DOWN
	if Input.is_action_pressed('game_left'):
		move += main.V3_LEFT
	elif Input.is_action_pressed('game_right'):
		move += main.V3_RIGHT
	
	if Input.is_action_just_pressed('game_change_weapon'):
		change_weapon()
	
	if move != main.V3_ZERO:
		current_movespeed += movement_speed * delta
		current_movespeed = min(current_movespeed, max_movement_speed)
		if move != last_dir:
			last_movetime = OS.get_ticks_msec()
		last_dir = move
	else:
		current_movespeed -= deceleration * delta
		current_movespeed = max(current_movespeed, 0)
	
	transform = transform.orthonormalized()
	
	if Input.is_action_pressed('game_attack'):
		attack_start()
	
	# rotation
	# first snap to final orientation, then gradually slerp towards it if
	# player moved recently
	var current_rot = Quat(transform.basis)
	if move != main.V3_ZERO:
		look_at(global_transform.origin + move, main.V3_WORLDUP)
	var target_rot = Quat(transform.basis)
	var step = float((OS.get_ticks_msec() - last_movetime))
	
	if (step * delta) <= 1:
		transform.basis = Basis(current_rot.slerp(target_rot, rotation_speed * delta))
	last_step = step
	forward = -global_transform.basis.z
	
	if not can_move:
		move = main.V3_ZERO
	
	move = move.normalized()
	
	check_areas(area_check.get_overlapping_areas())
	
	var collision = move_and_collide(forward * current_movespeed * delta)
	
	# anim test
	if current_movespeed > 0 and not $character_player_test/AnimationPlayer.current_animation == 'walking' and not $character_player_test/AnimationPlayer.current_animation == 'swing_right_arm':
		$character_player_test/AnimationPlayer.play('walking')
	if current_movespeed == 0 and not $character_player_test/AnimationPlayer.current_animation == 'swing_right_arm' and $character_player_test/AnimationPlayer.is_playing():
		$character_player_test/AnimationPlayer.stop()
	
	if camera == null:
		camera = main.get_camera()
	camera.transform.origin = camera_target.transform.origin + camera_offset
	camera.rotation_degrees = Vector3(-45, 0,0)
	
	#weapon_model.global_transform.origin = $character_player_test/arm_right/item_anchor_arm_right.global_transform.origin
	weapon_model.global_transform = $character_player_test/arm_right/item_anchor_arm_right.global_transform
	
	info_label.text = ''
	info_label.text += 'weapon: ' + weapons[current_weapon].name
	info_label.text += '\nfps: ' + str(Engine.get_frames_per_second())
	#info_label.text += '\nmovespeed: ' + str(current_movespeed)
	#info_label.text += '\nrot: ' + str(rotation_speed * delta)

func attack_start():
	if weapons[current_weapon].cooldown.is_stopped():
		var weapon = weapons[current_weapon]
		weapon.cooldown.start()
		
		$character_player_test/AnimationPlayer.play('swing_right_arm')
		can_move = false
		weapon.movestop.start()

func move_restore():
	can_move = true

func attack_stop():
	#weap_img.visible = false
	pass

func check_areas(current_areas):
	for area in current_areas:
		# single area, first entered (probably)
		if current_area == '':
			current_area = area.room_name
			camera_target = area.get_child(0)
		# multiple areas, transitioning to new area
		elif area.name != current_area:
			current_area = area.room_name
			camera_target = area.get_child(0)
	if current_areas.size() == 0:
		current_area = 'THE VOID omg'
		camera_target = self

func change_weapon(init = false):
	if not init:
		current_weapon += 1
		if current_weapon >= weapons.size():
			current_weapon = 0
	weapon_model.visible = false
	weapon_model = weapons[current_weapon].ingame_mdl
	weapon_model.visible = true
	main.hud_weapon.texture = weapons[current_weapon].hud_img