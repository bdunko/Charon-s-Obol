class_name VoyageNode
extends Control

enum VoyageNodeType {
	LEFT_END, RIGHT_END,
	DOCK, NODE, NEMESIS, TRIAL, TOLLGATE
}

@onready var _PATH = $Path
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

func ship_position() -> Vector2:
	return Vector2(position.x - 4, 29)

func init_node(vnt: VoyageNodeType, tooltip: String = "", price: int = 0) -> void:
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
	
	# update tooltip
	_TOOLTIP.set_tooltip(tooltip)
	
	# price label only visible for tollgates
	_PRICE_LABEL.visible = vnt == VoyageNodeType.TOLLGATE
