class_name Coin
extends Control

signal clicked

# if this coin is on the heads side
var _heads := true:
	set(val):
		_heads = val
		_SIDE_LABEL.text = "Heads" if _heads else "Tails"
		_SPRITE.color = _HEADS_COLOR if _heads else _TAILS_COLOR

const _HEADS_COLOR = Color("#6db517")
const _TAILS_COLOR = Color("#ea1e2d")

@onready var _SPRITE = $Sprite
@onready var _SIDE_LABEL = $SideLabel

func _ready():
	assert(_SPRITE)
	assert(_SIDE_LABEL)
	_heads = true

func is_heads() -> bool:
	return _heads

func flip() -> void:
	# randomly flip the coin
	_heads = Global.RNG.randi_range(0, 1) == 1

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("clicked")
				emit_signal("clicked")
