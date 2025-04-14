class_name VoyageNode
extends Control

signal hovered

enum VoyageNodeType {
	LEFT_END, RIGHT_END,
	DOCK, NODE, NEMESIS, TRIAL, TOLLGATE
}

@onready var _PATH = $Path

# used for most nodes
@onready var _TYPE = $Icon/Type
# used for nemesis
@onready var _CUSTOM_ICON_NEMESIS = $Icon/CustomNemesis
# used for trials
@onready var _CUSTOM_ICON_TRIAL = $Icon/CustomTrial
# used for double trials
@onready var _CUSTOM_ICON_TRIAL_TOP = $Icon/CustomTrialTop
@onready var _CUSTOM_ICON_TRIAL_BOTTOM = $Icon/CustomTrialBottom

@onready var _PRICE_LABEL = $Price

# used for most tooltips
@onready var _TOOLTIP = $TooltipEmitter
# used when we have a double trial, since we need two different tooltips
@onready var _TOOLTIP_TOP = $TooltipEmitterTop
@onready var _TOOLTIP_BOTTOM = $TooltipEmitterBottom

const _PRICE_FORMAT = "[center][color=#e12f3b]-%d[/color](VALUE)"

func _ready():
	assert(_PATH)
	assert(_TYPE)
	assert(_CUSTOM_ICON_TRIAL)
	assert(_CUSTOM_ICON_NEMESIS)
	assert(_CUSTOM_ICON_TRIAL_TOP)
	assert(_CUSTOM_ICON_TRIAL_BOTTOM)
	assert(_PRICE_LABEL)
	assert(_TOOLTIP)
	_TYPE.show()
	_PRICE_LABEL.hide()
	_CUSTOM_ICON_TRIAL.hide()
	_CUSTOM_ICON_NEMESIS.hide()
	_CUSTOM_ICON_TRIAL_TOP.hide()
	_CUSTOM_ICON_TRIAL_BOTTOM.hide()
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
			if custom_icons == null:
				_TYPE.show()
			elif custom_icons.size() == 1:
				_TYPE.hide()
				_CUSTOM_ICON_NEMESIS.show()
				_CUSTOM_ICON_NEMESIS.texture = custom_icons[0]
		VoyageNodeType.TRIAL:
			_TYPE.play("trial")
			_PATH.play("full")
			if custom_icons == null:
				_TYPE.show()
			elif custom_icons.size() == 1:
				_TYPE.hide()
				_CUSTOM_ICON_TRIAL.show()
				_CUSTOM_ICON_TRIAL.texture = custom_icons[0]
			elif custom_icons.size() == 2:
				_TYPE.hide()
				_CUSTOM_ICON_TRIAL_TOP.show()
				_CUSTOM_ICON_TRIAL_TOP.texture = custom_icons[0]
				_CUSTOM_ICON_TRIAL_BOTTOM.show()
				_CUSTOM_ICON_TRIAL_BOTTOM.texture = custom_icons[1]
		VoyageNodeType.TOLLGATE:
			_TYPE.play("tollgate")
			_PATH.play("full")
			_PRICE_LABEL.text = Global.replace_placeholders(_PRICE_FORMAT % price)
	
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
