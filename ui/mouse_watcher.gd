# A helper class to help with various mouse uses.
# Can monitor for mouse entry/exit/click on CollisionPolygon2D or Control nodes.
# LIMITATION - Doesn't work with rotations.
class_name MouseWatcher
extends Node2D

signal clicked
signal clicked_elsewhere
signal mouse_entered
signal mouse_exited
signal changed

# should be a Control or CollisionPolygon2D
@export var watched: Node = null
var _watched_last_known_position = null
var _watched_polygon = null

var _mouse_over = false

@export var DEBUG = false

func _ready() -> void:
	assert(watched)
	assert(watched is Control or watched is CollisionPolygon2D)
	_update_mouse_over()

# this function is potentially slow
func _regenerate_watched_polygon():
	var as_colpoly = watched as CollisionPolygon2D
	_watched_polygon = []
	
	#minor optimization - make copy of polygon outside of loop instead of multiple times inside of it (polygon[i] copies)
	var copy_poly = watched.polygon
	for i in as_colpoly.polygon.size():
		_watched_polygon.append(copy_poly[i] + _watched_last_known_position)

func _update_mouse_over() -> void:
	assert(watched is CollisionPolygon2D or watched is Control)
	if not is_visible_in_tree():
		if DEBUG:
			print("not in tree")
		_mouse_over = false
		return
	
	if watched is CollisionPolygon2D:
		# optimization - we only need to remake the observed polygon
		# if watched has changed position since we last made it.
		if watched.global_position != _watched_last_known_position:
			_watched_last_known_position = watched.global_position
			_regenerate_watched_polygon()
		_mouse_over = Geometry2D.is_point_in_polygon(get_global_mouse_position(), _watched_polygon)
	else:
		var as_control = watched as Control
		_mouse_over = as_control.get_global_rect().has_point(get_global_mouse_position())
		if DEBUG:
			print("checking control")
			print(as_control.get_global_rect())
			print(get_global_mouse_position)
			print(_mouse_over)

func _process(_delta) -> void:
	assert(watched)
	
	# if we aren't visible in tree, make it clear the mouse exited and early return
	if not is_visible_in_tree():
		if DEBUG:
			print("not vis in tree")
		if _mouse_over:
			emit_signal("mouse_exited")
			_mouse_over = false
		return
	
	var prev_mouse_over = _mouse_over
	_update_mouse_over()
	
	if prev_mouse_over != _mouse_over:
		if DEBUG:
			print("changed mouse over state")
		emit_signal("mouse_entered") if _mouse_over else emit_signal("mouse_exited")
		emit_signal("changed")

var _mouse_down = false
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_mouse_down = true
			else:
				_mouse_down = false
				if _mouse_over:
					emit_signal("clicked")
					if DEBUG:
						print("emit clicked")
				else:
					emit_signal("clicked_elsewhere")
					if DEBUG:
						print("emit clicked elsewhere")

func is_over() -> bool:
	return _mouse_over
