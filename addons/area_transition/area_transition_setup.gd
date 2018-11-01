tool
extends EditorPlugin

func _enter_tree():
	add_custom_type('AreaTransition', 'Area2D', preload('res://addons/area_transition/area_transition.gd'), preload('res://gfx/icon_transition.png'))

func _exit_tree():
	remove_custom_type('AreaTransition')
