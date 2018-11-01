tool
extends EditorPlugin

func _enter_tree():
	add_custom_type('AreaRoom', 'Area2D', preload('res://addons/area_room/area_room.gd'), preload('res://gfx/icon_room.png'))

func _exit_tree():
	remove_custom_type('AreaRoom')
