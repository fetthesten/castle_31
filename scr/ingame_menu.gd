extends Control

export var margin = 48

onready var grid_mainlayout = $tween_anchor/grid_mainlayout
onready var bg_menu = $tween_anchor/bg_menu
onready var tween_anchor = $tween_anchor
onready var tween_movemenu = $menu_movetween

var is_menu_active = false
var pos_menuactive # viewport pos for menu when active
var pos_menuinactive # viewport pos for menu when inactive


func _ready():
	
	bg_menu.color = Color(0.3,0.1,0.01,0.95)
	connect('resized', self, 'set_sizes_and_positions')
	set_sizes_and_positions()

func _process(delta):
	if Input.is_action_just_pressed("ui_home"):
		if not tween_movemenu.is_active():
			toggle()

func set_sizes_and_positions():
	# called upon ready and resize
	var viewsize = get_viewport_rect().size
	grid_mainlayout.rect_min_size = Vector2(viewsize.x - margin * 2, viewsize.y - margin)
	bg_menu.rect_min_size = grid_mainlayout.rect_min_size
	
	# position according to active status
	pos_menuactive = Vector2(margin, margin)
	pos_menuinactive = Vector2(margin, viewsize.y - margin)
	tween_anchor.rect_global_position = pos_menuactive if is_menu_active else pos_menuinactive
	
func toggle():
	if is_menu_active:
		tween_movemenu.interpolate_property(tween_anchor, 'rect_global_position', tween_anchor.rect_global_position, pos_menuinactive, 0.3, Tween.TRANS_EXPO, Tween.EASE_IN)
		tween_movemenu.start()
	else:
		tween_movemenu.interpolate_property(tween_anchor, 'rect_global_position', tween_anchor.rect_global_position, pos_menuactive, 0.3, Tween.TRANS_EXPO, Tween.EASE_IN)
		tween_movemenu.start()
	
	is_menu_active = !is_menu_active
	
func get_info_label():
	return $tween_anchor/grid_mainlayout/label_info
	
func get_hud_item(idx = 0):
	# eventually actually choose among item list perhaps
	return $tween_anchor/grid_mainlayout/hud_item0