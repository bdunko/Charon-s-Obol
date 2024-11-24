class_name VoyageMap
extends Node2D

signal clicked
signal closed

@onready var _SHIP = $Map/Ship
@onready var _SHIP_POSITIONS = $ShipPositions
@onready var _TRIAL1_TOOLTIP = $Map/Trial1/TooltipEmitter
@onready var _TRIAL2_TOOLTIP = $Map/Trial2/TooltipEmitter
@onready var _NEMESIS_TOOLTIP = $Map/Nemesis/TooltipEmitter
@onready var _TOLLGATE1_TOOLTIP = $Map/TollgateTooltip1
@onready var _TOLLGATE2_TOOLTIP = $Map/TollgateTooltip2
@onready var _TOLLGATE3_TOOLTIP = $Map/TollgateTooltip3

@onready var _CLICK_DETECTOR = $Map/ClickDetector
@onready var _X_BUTTON = $Map/XButton

@onready var _ANIMATION_PLAYER = $AnimationPlayer

func _ready() -> void:
	assert(_SHIP_POSITIONS.get_children().size() == Global.voyage_length())
	assert(_ANIMATION_PLAYER)
	assert(_SHIP)
	assert(_SHIP_POSITIONS)
	assert(_TRIAL1_TOOLTIP)
	assert(_TRIAL2_TOOLTIP)
	assert(_NEMESIS_TOOLTIP)
	assert(_TOLLGATE1_TOOLTIP)
	assert(_TOLLGATE2_TOOLTIP)
	assert(_TOLLGATE3_TOOLTIP)
	assert(_CLICK_DETECTOR)
	assert(_X_BUTTON)
	
	Global.state_changed.connect(_on_state_changed)
	
	_ANIMATION_PLAYER.play("boat")

func _get_x_for_round(round_count: int) -> float:
	return _SHIP_POSITIONS.get_child(round_count).position.x

func _on_state_changed() -> void:
	if Global.state == Global.State.GAME_OVER:
		_SHIP.position.x = _get_x_for_round(0) #reset boat position

func update_tooltips() -> void:
	const _TRIAL_FORMAT = "%s\n%s"
	var trial1 = Global.get_trial1()
	_TRIAL1_TOOLTIP.set_tooltip(_TRIAL_FORMAT % [trial1.name, trial1.description])
	var trial2 = Global.get_trial2()
	_TRIAL2_TOOLTIP.set_tooltip(_TRIAL_FORMAT % [trial2.name, trial2.description])
	
	const _NEMESIS_FORMAT = "%s\n%s"
	var nemesis = Global.get_nemesis()
	_NEMESIS_TOOLTIP.set_tooltip(_NEMESIS_FORMAT % [nemesis.name, nemesis.description])
	
	const _TOLLGATE_FORMAT = "Tollgate %d\nCost: %d[img=12x13]res://assets/icons/coin_icon.png[/img]"
	_TOLLGATE1_TOOLTIP.set_tooltip(_TOLLGATE_FORMAT % [1, Global.get_tollgate_cost(1)])
	_TOLLGATE2_TOOLTIP.set_tooltip(_TOLLGATE_FORMAT % [2, Global.get_tollgate_cost(2)])
	_TOLLGATE3_TOOLTIP.set_tooltip(_TOLLGATE_FORMAT % [3, Global.get_tollgate_cost(3)])

func move_boat(round_count: int) -> void:
	await Global.delay(0.3)
	var tween = create_tween()
	tween.tween_property(_SHIP, "position:x", _get_x_for_round(round_count), 1.0).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

func set_closeable(closeable: bool) -> void:
	_X_BUTTON.visible = closeable

func _on_click_detector_pressed() -> void:
	emit_signal("clicked")

func _on_x_button_pressed() -> void:
	emit_signal("closed")
