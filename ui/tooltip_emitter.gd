class_name TooltipEmitter
extends Control

signal tooltip_created
signal tooltip_removed

@export_multiline var _tooltip: String = ""
@export var _enabled: bool = true
@export var style: UITooltip.Style = UITooltip.Style.CLEAR
var _tooltip_visible = false

func set_tooltip(new_tooltip: String) -> void:
	_tooltip = Global.replace_placeholders(new_tooltip)
	
	# if a tooltip is currently active, update its text
	if _tooltip_visible:
		_show_tooltip()

func get_tooltip_string() -> String:
	return _tooltip

func _ready() -> void:
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	set_tooltip(_tooltip)

func enable() -> void:
	_enabled = true

func disable() -> void:
	_enabled = false

func is_enabled():
	return _enabled

func _on_mouse_entered():
	_show_tooltip()

func _on_mouse_exited():
	_tooltip_visible = false
	emit_signal("tooltip_removed")

func _show_tooltip() -> void:
	if _tooltip != "":
		UITooltip.create(self, _tooltip, get_global_mouse_position(), get_tree().root, style)
		_tooltip_visible = true
		emit_signal("tooltip_created")
