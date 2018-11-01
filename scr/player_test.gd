extends KinematicBody2D

export var movement_speed = 6000
onready var area_check = $Area2D
onready var camera = main.current_camera
onready var info_label = main.info_label

const V2_ZERO = Vector2(0,0)
const V2_UP = Vector2(0,-1)
const V2_DOWN = Vector2(0,1)
const V2_LEFT = Vector2(-1,0)
const V2_RIGHT = Vector2(1,0)

var weapons = []
var current_weapon = 0
var last_dir = V2_UP
var weap_img
var weapon_offset = V2_ZERO
var weap_tween
var can_move = true

var current_area = ''
var camera_target = self

func _ready():
	weap_tween = Tween.new()
	add_child(weap_tween)
	weapon_offset = $sorter/Sprite.texture.get_size() / 2
	
	weapons.append({'name': 'knife', 'damage': 1, 'scale': 1.0, 'distance': 8, 'cooldown': Timer.new(), 'movestop': Timer.new(), 'ingame_img': preload('res://gfx/ingame/knife01.png'), 'hud_img': preload('res://gfx/hud/knife01.png')})
	weapons.append({'name': 'sword', 'damage': 3, 'scale': 1.0, 'distance': 16, 'cooldown': Timer.new(), 'movestop': Timer.new(), 'ingame_img': preload('res://gfx/ingame/sword01.png'),  'hud_img': preload('res://gfx/hud/sword01.png')})
	weapons[0].cooldown.one_shot = true
	weapons[0].cooldown.wait_time = 0.3
	weapons[0].cooldown.connect('timeout', self, 'attack_stop')
	add_child(weapons[0].cooldown)
	weapons[0].movestop.one_shot = true
	weapons[0].movestop.wait_time = 0.001
	weapons[0].movestop.connect('timeout', self, 'move_restore')
	add_child(weapons[0].movestop)
	weapons[1].cooldown.one_shot = true
	weapons[1].cooldown.wait_time = 0.5
	weapons[1].cooldown.connect('timeout', self, 'attack_stop')
	add_child(weapons[1]['cooldown'])
	weapons[1].movestop.one_shot = true
	weapons[1].movestop.wait_time = 0.15
	weapons[1].movestop.connect('timeout', self, 'move_restore')
	add_child(weapons[1].movestop)

	weap_img = Sprite.new()
	weap_img.visible = false
	weap_img.centered = false
	$sorter.add_child(weap_img)
	change_weapon(true)
	
func _process(delta):
	var move = V2_ZERO
	if Input.is_action_pressed('game_up'):
		move += V2_UP
	elif Input.is_action_pressed('game_down'):
		move += V2_DOWN
	if Input.is_action_pressed('game_left'):
		move += V2_LEFT
	elif Input.is_action_pressed('game_right'):
		move += V2_RIGHT
	
	if Input.is_action_just_pressed('game_change_weapon'):
		change_weapon()
	
	if move != V2_ZERO:
		last_dir = move
	
	if Input.is_action_pressed('game_attack'):
		attack_start()
	
	if not can_move:
		move = V2_ZERO
	
	move = move.normalized()
	
	check_areas(area_check.get_overlapping_areas())
	
	move_and_slide(move * movement_speed * delta)
	if camera == null:
		camera = main.get_camera()
	camera.position = camera_target.transform.origin
	
	info_label.text = 'current area: ' + current_area
	info_label.text += '\nweapon: ' + weapons[current_weapon].name
	info_label.text += '\nfps: ' + str(Engine.get_frames_per_second())

func attack_start():
	if weapons[current_weapon].cooldown.is_stopped():
		var weapon = weapons[current_weapon]
		weapon.cooldown.start()
		weap_img.visible = true
		weap_img.set_scale(Vector2(weapon.scale, weapon.scale))
		var offset = last_dir.normalized() * weapon_offset
		weap_img.global_position = global_position + offset
		weap_img.look_at(position + (last_dir * 100))
		var tween_target = (weap_img.global_position + offset)
		#tween_path *= 1.05
		weap_tween.targeting_property(weap_img, 'global_position', weap_img, 'global_position', tween_target, weapon.cooldown.time_left, Tween.TRANS_LINEAR, Tween.EASE_IN)
		weap_tween.start()
		can_move = false
		weapon.movestop.start()

func move_restore():
	can_move = true

func attack_stop():
	weap_img.visible = false

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
	weap_img.texture = weapons[current_weapon].ingame_img
	weap_img.offset = Vector2(0, -(weap_img.texture.get_size().y * 0.5))
	main.hud_weapon.texture = weapons[current_weapon].hud_img