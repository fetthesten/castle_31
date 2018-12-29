extends Spatial

# cardinal directions for topdown movement
const V3_ZERO = Vector3(0,0,0)
const V3_LEFT = Vector3(-1,0,0)
const V3_RIGHT = Vector3(1,0,0)
const V3_UP = Vector3(0,0,-1)
const V3_DOWN = Vector3(0,0,1)
# world up vector for lookat
const V3_WORLDUP = Vector3(0,1,0)

onready var info_label = $'layer_hud/ingame_menu'.get_info_label()
onready var hud_weapon = $'layer_hud/ingame_menu'.get_hud_item(0)
onready var current_scene = get_parent().get_child(1)
var current_camera
#var bg_tex
var current_window_size

func _ready():
	set_camera()
	current_window_size = get_viewport().get_size()
	#bg_tex = Texture.new()

func set_camera():
	if current_camera == null:
		var cam = Camera.new()
		cam.name = 'Camera'
		cam.current = true
		#cam.smoothing_enabled = true
		#cam.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
		current_scene.add_child(cam)
	current_camera = current_scene.get_node('Camera')

func get_camera():
	return(current_camera)	