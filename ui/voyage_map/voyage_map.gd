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

@onready var _M1 = $Map/Monsters/Monster1
@onready var _M2 = $Map/Monsters/Monster2
@onready var _M3 = $Map/Monsters/Monster3
@onready var _M4 = $Map/Monsters/Monster4
@onready var _M5 = $Map/Monsters/Monster5
@onready var _M6 = $Map/Monsters/Monster6
@onready var _MONSTERS = [_M1, _M2, _M3, _M4, _M5, _M6]

static var _NODE_SCENE = preload("res://ui/voyage_map/voyage_node.tscn")

func _ready() -> void:
	assert(_NODES)
	assert(_ANIMATION_PLAYER)
	assert(_SHIP)
	assert(_CLICK_DETECTOR)
	assert(_X_BUTTON)
	assert(_MONSTERS)
	for node in _MONSTERS:
		assert(node)
	
	Global.state_changed.connect(_on_state_changed)
	
	_ANIMATION_PLAYER.play("boat")

func _on_trial_hovered():
	emit_signal("trial_hovered")

func _get_x_for_round(round_count: int) -> float:
	return _NODES.get_child(round_count+1).ship_position().x

func _on_state_changed() -> void:
	if Global.state == Global.State.GAME_OVER:
		_set_boat_start() # reset boat position

func _add_node(vnt: VoyageNode.VoyageNodeType, tooltips = [""], price: int = 0, custom_icons = []):
	var node: VoyageNode = _NODE_SCENE.instantiate()
	_NODES.add_child(node)
	node.init_node(vnt, tooltips, price, custom_icons)
	if vnt == VoyageNode.VoyageNodeType.TRIAL:
		node.hovered.connect(_on_trial_hovered)

const _TRIAL_FORMAT = "%s\n%s\n\nYou must earn %d+(SOULS)."
const _NEMESIS_FORMAT = "%s\n%s\n\nYou must be victorious."
const _TOLLGATE_FORMAT = "Tollgate\nYou must pay %d(VALUE)."

func update() -> void:
	Global.free_children(_NODES)
	
	# create the left end
	_add_node(VoyageNode.VoyageNodeType.LEFT_END)
	
	for rnd in Global.VOYAGE:
		match(rnd.roundType):
			Global.RoundType.BOARDING:
				_add_node(VoyageNode.VoyageNodeType.DOCK)
			Global.RoundType.NORMAL:
				_add_node(VoyageNode.VoyageNodeType.NODE, [""], 0, rnd.get_icons())
			Global.RoundType.TOLLGATE:
				_add_node(VoyageNode.VoyageNodeType.TOLLGATE, [_TOLLGATE_FORMAT % Global.get_toll_cost(rnd)], Global.get_toll_cost(rnd), rnd.get_icons())
			Global.RoundType.TRIAL1, Global.RoundType.TRIAL2:
				# should have two trials
				if Global.is_difficulty_active(Global.Difficulty.CRUEL3):
					assert(rnd.trialDatas.size() == 2)
					var tooltip1 = _TRIAL_FORMAT % [rnd.trialDatas[0].name, rnd.trialDatas[0].description, Global.get_quota(rnd)]
					var tooltip2 = _TRIAL_FORMAT % [rnd.trialDatas[1].name, rnd.trialDatas[1].description, Global.get_quota(rnd)]
					_add_node(VoyageNode.VoyageNodeType.TRIAL, [tooltip1, tooltip2], 0, rnd.get_icons())
				else:
					_add_node(VoyageNode.VoyageNodeType.TRIAL, [_TRIAL_FORMAT % [rnd.trialDatas[0].name, rnd.trialDatas[0].description, Global.get_quota(rnd)]], 0, [rnd.get_icons()[0]])
			Global.RoundType.NEMESIS:
				_add_node(VoyageNode.VoyageNodeType.NEMESIS, [_NEMESIS_FORMAT % [rnd.trialDatas[0].name, rnd.trialDatas[0].description]], 0, rnd.get_icons())
			Global.RoundType.END:
				_add_node(VoyageNode.VoyageNodeType.RIGHT_END)
	
	var monsters = Global.get_standard_monster_pool() + Global.get_elite_monster_pool()
	var i = 0
	for monster in monsters:
		_MONSTERS[i].texture = load(monster.icon_path)
		i += 1
	
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

func make_tooltip(node_index: int, tooltip_index: int) -> UITooltip:
	if node_index >= _NODES.get_child_count():
		return null
	return _NODES.get_child(node_index).make_tooltip(tooltip_index)

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
