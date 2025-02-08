class_name VoyageMap
extends Node2D

signal trial_hovered #used for tutorial
signal clicked
signal closed

@onready var _RIVER = $Map/River
@onready var _NODES = $Map/Nodes
@onready var _SHIP = $Map/Ship
@onready var _CLICK_DETECTOR = $Map/ClickDetector
@onready var _X_BUTTON = $Map/XButton
@onready var _ANIMATION_PLAYER = $AnimationPlayer
@onready var _FX = $Map/FX

static var _NODE_SCENE = preload("res://ui/voyage_map/voyage_node.tscn")

func _ready() -> void:
	assert(_NODES)
	assert(_ANIMATION_PLAYER)
	assert(_SHIP)
	assert(_CLICK_DETECTOR)
	assert(_X_BUTTON)
	
	Global.state_changed.connect(_on_state_changed)
	
	_ANIMATION_PLAYER.play("boat")

func _on_trial_hovered():
	emit_signal("trial_hovered")

func _get_x_for_round(round_count: int) -> float:
	return _NODES.get_child(round_count+1).ship_position().x

func _on_state_changed() -> void:
	if Global.state == Global.State.GAME_OVER:
		_set_boat_start() # reset boat position

func _add_node(vnt: VoyageNode.VoyageNodeType, tooltip: String = "", price: int = 0, custom_icon: Texture2D = null):
	var node: VoyageNode = _NODE_SCENE.instantiate()
	_NODES.add_child(node)
	node.init_node(vnt, tooltip, price, custom_icon)
	if vnt == VoyageNode.VoyageNodeType.TRIAL:
		node.hovered.connect(_on_trial_hovered)

const _TRIAL_FORMAT = "%s\n%s\n\nYou must earn %d+(SOULS)."
const _NEMESIS_FORMAT = "%s\n%s\n\nYou must be victorious."
const _TOLLGATE_FORMAT = "Tollgate\nYou must pay %d(COIN)."

func update_tooltips() -> void:
	Global.free_children(_NODES)
	
	# create the left end
	_add_node(VoyageNode.VoyageNodeType.LEFT_END)
	
	for rnd in Global.VOYAGE:
		match(rnd.roundType):
			Global.RoundType.BOARDING:
				_add_node(VoyageNode.VoyageNodeType.DOCK)
			Global.RoundType.NORMAL:
				_add_node(VoyageNode.VoyageNodeType.NODE, "", 0, rnd.get_icon())
			Global.RoundType.TOLLGATE:
				_add_node(VoyageNode.VoyageNodeType.TOLLGATE, Global.replace_placeholders(_TOLLGATE_FORMAT % Global.get_toll_cost(rnd)), Global.get_toll_cost(rnd), rnd.get_icon())
			Global.RoundType.TRIAL1, Global.RoundType.TRIAL2:
				_add_node(VoyageNode.VoyageNodeType.TRIAL, Global.replace_placeholders(_TRIAL_FORMAT % [rnd.trialData.name, rnd.trialData.description, rnd.quota]), 0, rnd.get_icon())
			Global.RoundType.NEMESIS:
				_add_node(VoyageNode.VoyageNodeType.NEMESIS, _NEMESIS_FORMAT % [rnd.trialData.name, rnd.trialData.description], 0, rnd.get_icon())
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

func node_tooltip_string(i: int) -> String:
	if i >= _NODES.get_child_count():
		return "ERROR"
	return _NODES.get_child(i).get_node_tooltip()

func change_river_color(colorStyle: River.ColorStyle, instant: bool) -> void:
	_RIVER.change_color(colorStyle, instant)

var _glow_enabled = false
func enable_glow() -> void:
	_glow_enabled = true
	_update_glow()

func disable_glow() -> void:
	_glow_enabled = false
	_update_glow()

func _update_glow() -> void:
	if _glow_enabled and _hovered:
		_FX.start_glowing_solid(Color.AZURE, FX.FAST_GLOW_SPEED)
	else:
		_FX.stop_glowing()

var _hovered = false
func _on_click_detector_mouse_entered():
	_hovered = true
	_update_glow()

func _on_click_detector_mouse_exited():
	_hovered = false
	_update_glow()
