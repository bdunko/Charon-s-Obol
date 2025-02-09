class_name VoyageNode
extends Control

signal hovered

enum VoyageNodeType {
	LEFT_END, RIGHT_END,
	DOCK, NODE, NEMESIS, TRIAL, TOLLGATE
}

@onready var _PATH = $Path


# TODO - TEST DOUBLE TRIALS

# used for most nodes
@onready var _TYPE = $Icon/Type
# used for nemesis or single trials
@onready var _CUSTOM_ICON = $Icon/CustomIcon
# used for double trials
@onready var _CUSTOM_ICON_DOUBLE_TOP = $Icon/CustomDoubleTop
@onready var _CUSTOM_ICON_DOUBLE_BOTTOM = $Icon/CustomDoubleBottom

@onready var _PRICE_LABEL = $Price

# used for most tooltips
@onready var _TOOLTIP = $TooltipEmitter
# used when we have a double trial, since we need two different tooltips
@onready var _TOOLTIP_TOP = $TooltipEmitterTop
@onready var _TOOLTIP_BOTTOM = $TooltipEmitterBottom


const _PRICE_FORMAT = "[center][color=#e12f3b]-%d[/color][img=12x13]res://assets/icons/coin_icon.png[/img]"

func _ready():
	assert(_PATH)
	assert(_TYPE)
	assert(_CUSTOM_ICON)
	assert(_CUSTOM_ICON_DOUBLE_TOP)
	assert(_CUSTOM_ICON_DOUBLE_BOTTOM)
	assert(_PRICE_LABEL)
	assert(_TOOLTIP)
	_TYPE.show()
	_PRICE_LABEL.hide()
	_CUSTOM_ICON.hide()
	_CUSTOM_ICON_DOUBLE_TOP.hide()
	_CUSTOM_ICON_DOUBLE_BOTTOM.hide()
	_TOOLTIP_TOP.hide()
	_TOOLTIP_BOTTOM.hide()
	_TOOLTIP.hide()
	
	_TOOLTIP.tooltip_created.connect(_on_tooltip_created)
	_TOOLTIP_TOP.tooltip_created.connect(_on_tooltip_created)
	_TOOLTIP_BOTTOM.tooltip_created.connect(_on_tooltip_created)

func ship_position() -> Vector2:
	return Vector2(position.x - 4, 29)

func init_node(vnt: VoyageNodeType, tooltips, price: int = 0, custom_icons = []) -> void:
	assert(tooltips.size() == 1 or tooltips.size() == 2)
	assert(custom_icons == null or custom_icons.size() >= 0 and custom_icons.size() <= 2)
	assert(tooltips[0] == "" or (vnt == VoyageNodeType.NEMESIS or vnt == VoyageNodeType.TRIAL or vnt == VoyageNodeType.TOLLGATE))
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
	if custom_icons != null:
		if custom_icons.size() == 1:
			_TYPE.hide()
			_CUSTOM_ICON.show()
			_CUSTOM_ICON.texture = custom_icons[0]
		elif custom_icons.size() == 2:
			_TYPE.hide()
			_CUSTOM_ICON_DOUBLE_TOP.texture = custom_icons[0]
			_CUSTOM_ICON_DOUBLE_BOTTOM.texture = custom_icons[1]
			_CUSTOM_ICON_DOUBLE_TOP.show()
			_CUSTOM_ICON_DOUBLE_BOTTOM.show()
	
	# update tooltip
	if tooltips.size() == 1:
		_TOOLTIP.set_tooltip(tooltips[0])
		_TOOLTIP.show()
	elif tooltips.size() == 2:
		_TOOLTIP_TOP.set_tooltip(tooltips[0])
		_TOOLTIP_BOTTOM.set_tooltip(tooltips[1])
		_TOOLTIP_TOP.show()
		_TOOLTIP_BOTTOM.show()
	
	# price label only visible for tollgates
	_PRICE_LABEL.visible = vnt == VoyageNodeType.TOLLGATE

func get_node_tooltips() -> Array[String]:
	if _TOOLTIP.visible:
		return [_TOOLTIP.get_tooltip_string()]
	return [_TOOLTIP_TOP.get_tooltip_string(), _TOOLTIP_BOTTOM.get_tooltip_string()]

func _on_tooltip_created():
	emit_signal("hovered")
