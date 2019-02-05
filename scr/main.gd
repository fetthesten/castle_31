extends Spatial

# cardinal directions for topdown movement
const V3_ZERO = Vector3(0,0,0)
const V3_LEFT = Vector3(-1,0,0)
const V3_RIGHT = Vector3(1,0,0)
const V3_UP = Vector3(0,0,-1)
const V3_DOWN = Vector3(0,0,1)
# world up vector for lookat
const V3_WORLDUP = Vector3(0,1,0)
const V3_GRAVITY = Vector3(0,-1.7,0)

onready var info_label = $'layer_hud/ingame_menu'.get_info_label()
onready var hud_weapon = $'layer_hud/ingame_menu'.get_hud_item(0)
onready var current_scene = get_parent().get_child(1)
onready var debug_label = $'layer_debug/label_debug'
onready var debug_bg = $'layer_debug/bg'

var current_window_size
var invert_look = true

var mouse_state = {
	move = Vector2.ZERO,
	last_move = 0,
		buttons = {
			scroll_up = false,
			scroll_down = false,
		}
	}

func _ready():
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_window_size = get_viewport().get_size()
	debug_bg.color = Color(0.0,0.5,0.2,0.3)
	debug_label.rect_global_position = Vector2(current_window_size.x - 256, 0)
	debug_label.rect_min_size = Vector2(256, 64)
	debug_bg.rect_global_position = Vector2(current_window_size.x - 256, 0)
	debug_bg.rect_min_size = Vector2(256, 64)
	
func _process(delta):
	for button in mouse_state.buttons.keys():
		mouse_state.buttons[button] = false
	debug_label.text = 'fps: ' + str(Engine.get_frames_per_second())

func _input(event):
	if event is InputEventMouseMotion:
		mouse_state.move = event.relative
		mouse_state.last_move = OS.get_ticks_msec()
	if event is InputEventMouseButton:
		mouse_state.buttons.scroll_up = event.button_index == BUTTON_WHEEL_UP
		mouse_state.buttons.scroll_down = event.button_index == BUTTON_WHEEL_DOWN
#		mouse_state.buttons.left = event.button_index == BUTTON_LEFT
#		mouse_state.buttons.right = event.button_index == BUTTON_RIGHT
#		mouse_state.buttons.middle = event.button_index == BUTTON_MIDDLE
#		mouse_state.buttons.x1 = event.button_index == BUTTON_WHEEL_LEFT
#		mouse_state.buttons.x2 = event.button_index == BUTTON_WHEEL_RIGHT