class_name Voyage
extends Node2D

@onready var _SHIP = $Ship
@onready var _SHIP_POSITIONS = $ShipPositions

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

func move_boat(round_count: int) -> void:
	await Global.delay(0.3)
	var tween = create_tween()
	tween.tween_property(_SHIP, "position:x", _get_x_for_round(round_count), 1.0).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
