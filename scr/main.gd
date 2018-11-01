extends Node2D

const V2_ZERO = Vector2(0,0)
const V2_LEFT = Vector2(-1,0)
const V2_RIGHT = Vector2(1,0)
const V2_UP = Vector2(0,-1)
const V2_DOWN = Vector2(0,1)

onready var info_label = $layer_hud/label_info
onready var hud_weapon = $layer_hud/hud_weapon
onready var current_scene = get_parent().get_child(1)
var current_camera
var bg_tex
var current_window_size

func _ready():
	set_camera()
	current_window_size = get_viewport().get_size()
	$layer_bg/tex_bg.rect_size = current_window_size
	hud_weapon.rect_global_position = current_window_size - hud_weapon.rect_size
	bg_tex = Texture.new()

func set_camera():
	if current_camera == null:
		var cam = Camera2D.new()
		cam.name = 'Camera2D'
		cam.current = true
		cam.smoothing_enabled = true
		cam.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
		current_scene.add_child(cam)
	current_camera = current_scene.get_node('Camera2D')

func get_camera():
	return(current_camera)	