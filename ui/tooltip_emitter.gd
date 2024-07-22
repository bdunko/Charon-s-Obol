class_name TooltipEmitter
extends Control

@export var _tooltip: String = ""
@export var _enabled: bool = true
var _tooltip_visible = false

func set_tooltip(new_tooltip: String) -> void:
	_tooltip = new_tooltip
	
	# if a tooltip is currently active, update its text
	if _tooltip_visible:
		_show_tooltip()

func enable() -> void:
	_enabled = true

func disable() -> void:
	_enabled = false

func _on_mouse_entered():
	_show_tooltip()

func _on_mouse_exited():
	_tooltip_visible = false

func _show_tooltip() -> void:
	if _tooltip != "":
		UITooltip.create(self, _tooltip, get_global_mouse_position(), get_tree().root)
		_tooltip_visible = true
