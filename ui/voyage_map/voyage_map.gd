class_name VoyageMap
extends Node2D

signal clicked
signal closed

@onready var _NODES = $Map/Nodes
@onready var _SHIP = $Map/Ship
@onready var _CLICK_DETECTOR = $Map/ClickDetector
@onready var _X_BUTTON = $Map/XButton
@onready var _ANIMATION_PLAYER = $AnimationPlayer

static var _NODE_SCENE = preload("res://ui/voyage_map/voyage_node.tscn")

func _ready() -> void:
	assert(_NODES)
	assert(_ANIMATION_PLAYER)
	assert(_SHIP)
	assert(_CLICK_DETECTOR)
	assert(_X_BUTTON)
	
	Global.state_changed.connect(_on_state_changed)
	
	_ANIMATION_PLAYER.play("boat")

func _get_x_for_round(round_count: int) -> float:
	return _NODES.get_child(round_count+1).ship_position().x

func _on_state_changed() -> void:
	if Global.state == Global.State.GAME_OVER:
		_set_boat_start() # reset boat position

func _add_node(vnt: VoyageNode.VoyageNodeType, tooltip: String = "", price: int = 0):
	var node: VoyageNode = _NODE_SCENE.instantiate()
	_NODES.add_child(node)
	node.init_node(vnt, tooltip, price)

const _TRIAL_FORMAT = "%s\n%s\n\nYou must earn %d+[img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]."
const _NEMESIS_FORMAT = "%s\n%s\nYou must be victorious."
const _TOLLGATE_FORMAT = "Tollgate\nYou must pay %d[img=12x13]res://assets/icons/coin_icon.png[/img]."

func update_tooltips() -> void:
	Global.free_children(_NODES)
	
	# create the left end
	_add_node(VoyageNode.VoyageNodeType.LEFT_END)
	
	for rnd in Global.VOYAGE:
		match(rnd.roundType):
			Global.RoundType.BOARDING:
				_add_node(VoyageNode.VoyageNodeType.DOCK)
			Global.RoundType.NORMAL:
				_add_node(VoyageNode.VoyageNodeType.NODE)
			Global.RoundType.TOLLGATE:
				_add_node(VoyageNode.VoyageNodeType.TOLLGATE, _TOLLGATE_FORMAT % rnd.tollCost, rnd.tollCost)
			Global.RoundType.TRIAL1, Global.RoundType.TRIAL2:
				_add_node(VoyageNode.VoyageNodeType.TRIAL, _TRIAL_FORMAT % [rnd.trialData.name, rnd.trialData.description, rnd.quota])
			Global.RoundType.NEMESIS:
				_add_node(VoyageNode.VoyageNodeType.NEMESIS, _NEMESIS_FORMAT % [rnd.trialData.name, rnd.trialData.description])
			Global.RoundType.END:
				_add_node(VoyageNode.VoyageNodeType.RIGHT_END)
	
	# move ship to initial position...
	call_deferred("_set_boat_start")

func _set_boat_start() -> void:
	_SHIP.position.x = _get_x_for_round(0)

func move_boat(round_count: int) -> void:
	await Global.delay(0.3)
	var tween = create_tween()
	tween.tween_property(_SHIP, "position:x", _get_x_for_round(round_count), 0.8).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

func set_closeable(closeable: bool) -> void:
	_X_BUTTON.visible = closeable

func _on_click_detector_pressed() -> void:
	emit_signal("clicked")

func _on_x_button_pressed() -> void:
	emit_signal("closed")

func node_position(i: int) -> Vector2:
	if i >= _NODES.get_child_count():
		return Vector2(-1, -1)
	return _NODES.get_child(i).get_global_position()
