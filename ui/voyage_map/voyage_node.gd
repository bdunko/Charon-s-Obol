class_name VoyageNode
extends Control

signal hovered

enum VoyageNodeType {
	LEFT_END, RIGHT_END,
	DOCK, NODE, NEMESIS, TRIAL, TOLLGATE
}

@onready var _PATH = $Path
@onready var _CUSTOM_ICON = $CustomIcon
@onready var _TYPE = $Type
@onready var _PRICE_LABEL = $Price
@onready var _TOOLTIP = $TooltipEmitter

const _PRICE_FORMAT = "[center][color=#e12f3b]-%d[/color][img=12x13]res://assets/icons/coin_icon.png[/img]"

func _ready():
	assert(_PATH)
	assert(_TYPE)
	assert(_PRICE_LABEL)
	assert(_TOOLTIP)
	_PRICE_LABEL.hide()
	_CUSTOM_ICON.hide()
	_TOOLTIP.tooltip_created.connect(_on_tooltip_created)

func ship_position() -> Vector2:
	return Vector2(position.x - 4, 29)

func init_node(vnt: VoyageNodeType, tooltip: String = "", price: int = 0, custom_icon: Texture2D = null) -> void:
	assert(tooltip == "" or (vnt == VoyageNodeType.NEMESIS or vnt == VoyageNodeType.TRIAL or vnt == VoyageNodeType.TOLLGATE))
	assert(price == 0 or vnt == VoyageNodeType.TOLLGATE)
	
	match(vnt):
		VoyageNodeType.LEFT_END:
			_TYPE.play("none")
			_PATH.play("left")
		VoyageNodeType.RIGHT_END:
			_TYPE.play("none")
			_PATH.play("right")
		VoyageNodeType.DOCK:
			_TYPE.play("dock")
			_PATH.play("full")
		VoyageNodeType.NODE:
			_TYPE.play("node")
			_PATH.play("full")
		VoyageNodeType.NEMESIS:
			_TYPE.play("nemesis")
			_PATH.play("full")
		VoyageNodeType.TRIAL:
			_TYPE.play("trial")
			_PATH.play("full")
		VoyageNodeType.TOLLGATE:
			_TYPE.play("tollgate")
			_PATH.play("full")
			_PRICE_LABEL.text = _PRICE_FORMAT % price
	
	# set custom icon and hide generic one if provided
	if custom_icon != null:
		_TYPE.hide()
		_CUSTOM_ICON.show()
		_CUSTOM_ICON.texture = custom_icon
	
	# update tooltip
	_TOOLTIP.set_tooltip(tooltip)
	
	# price label only visible for tollgates
	_PRICE_LABEL.visible = vnt == VoyageNodeType.TOLLGATE

func get_node_tooltip() -> String:
	return _TOOLTIP.get_tooltip_string()

func _on_tooltip_created():
	emit_signal("hovered")
