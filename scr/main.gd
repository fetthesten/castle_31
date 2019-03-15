extends Spatial

onready var info_label = $'layer_hud/ingame_menu'.get_info_label()
onready var hud_weapon = $'layer_hud/ingame_menu'.get_hud_item(0)
onready var debug_label = $'layer_debug/label_debug'
onready var debug_bg = $'layer_debug/bg'
onready var crosshair = $'layer_hud/crosshair'

var current_window_size
var invert_look = 1
var mouse_sensitivity = 0.1
var stick_sensitivity = 0.001
var stick_deadzone = 0.3
var gravity = -24.8

# signals
signal mouse_motion
signal mouse_scroll_up
signal mouse_scroll_down

func _ready():
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_window_size = get_viewport().get_size()
	debug_bg.color = Color(0.0,0.5,0.2,0.3)
	debug_label.rect_global_position = Vector2(current_window_size.x - 256, 0)
	debug_label.rect_min_size = Vector2(256, 64)
	debug_bg.rect_global_position = Vector2(current_window_size.x - 256, 0)
	debug_bg.rect_min_size = Vector2(256, 64)
	crosshair.rect_global_position = Vector2((current_window_size.x / 2) - 4, (current_window_size.y / 2) - 4)
	
func _process(delta):
	debug_label.text = 'fps: ' + str(Engine.get_frames_per_second())
	debug_label.text += '\ncurrent scene: ' + current_scene().name

func _input(event):
	if event is InputEventMouseMotion:
		emit_signal("mouse_motion", event.relative)
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			emit_signal("mouse_scroll_up")
		if event.button_index == BUTTON_WHEEL_DOWN:
			emit_signal("mouse_scroll_down")
		
func current_scene():
	return get_tree().current_scene