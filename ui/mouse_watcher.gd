# A helper class to help with various mouse uses.
# Can monitor for mouse entry/exit/click on CollisionPolygon2D or Control nodes.
class_name MouseWatcher
extends Node2D

signal clicked
signal entered
signal exited
signal changed

@export var watched: Node = null

var _mouse_over = false

func _ready() -> void:
	assert(watched)
	assert(watched is Control or watched is CollisionPolygon2D)
	_update_mouse_over()

func _update_mouse_over() -> void:
	assert(watched is CollisionPolygon2D or watched is Control)
	if not is_visible_in_tree():
		_mouse_over = false
		return
	
	if watched is CollisionPolygon2D:
		var as_colpoly = watched as CollisionPolygon2D
		var adj_poly = []
		for i in as_colpoly.polygon.size():
			adj_poly.append(watched.polygon[i] + as_colpoly.global_position)
		_mouse_over = Geometry2D.is_point_in_polygon(get_global_mouse_position(), adj_poly)
	else:
		var as_control = watched as Control
		_mouse_over = as_control.get_global_rect().has_point(get_global_mouse_position())

func _process(_delta) -> void:
	# if we aren't visible in tree, make it clear the mouse exited and early return
	if not is_visible_in_tree():
		if _mouse_over:
			emit_signal("exited")
			_mouse_over = false
		return
	
	var prev_mouse_over = _mouse_over
	_update_mouse_over()
	
	if prev_mouse_over != _mouse_over:
		emit_signal("entered") if _mouse_over else emit_signal("exited")
		emit_signal("changed")
	
func _input(event):
	if _mouse_over:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					emit_signal("clicked")

func is_over() -> bool:
	return _mouse_over
