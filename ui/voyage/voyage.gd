class_name Voyage
extends Node2D

@onready var _SHIP = $Ship
@onready var _SHIP_POSITIONS = $ShipPositions
@onready var _TRIAL1_TOOLTIP = $Trial1/TooltipEmitter
@onready var _TRIAL2_TOOLTIP = $Trial2/TooltipEmitter
@onready var _NEMESIS_TOOLTIP = $Nemesis/TooltipEmitter
@onready var _TOLLGATE1_TOOLTIP = $TollgateTooltip1
@onready var _TOLLGATE2_TOOLTIP = $TollgateTooltip2
@onready var _TOLLGATE3_TOOLTIP = $TollgateTooltip3

func _ready() -> void:
	assert(_SHIP_POSITIONS.get_children().size() == Global.voyage_length())
	
	Global.state_changed.connect(_on_state_changed)
	
	$AnimationPlayer.play("boat")
	
	hide()
	
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
