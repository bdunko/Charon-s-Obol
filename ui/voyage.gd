class_name Voyage
extends Node2D

@onready var _SHIP = $Ship
@onready var _BOAT_POSITION_FOR_ROUND = [-100, _SHIP.position.x, _SHIP.position.x + 13, _SHIP.position.x + 24, _SHIP.position.x + 37, 
_SHIP.position.x + 48, _SHIP.position.x + 58, _SHIP.position.x + 70, _SHIP.position.x + 83, _SHIP.position.x + 94, _SHIP.position.x + 104,
_SHIP.position.x + 116, _SHIP.position.x + 129, _SHIP.position.x + 140, _SHIP.position.x + 149]

func _ready() -> void:
	assert(_BOAT_POSITION_FOR_ROUND.size()-2 == Global.NUM_ROUNDS)
	
	Global.state_changed.connect(_on_state_changed)
	
	$AnimationPlayer.play("boat")
	
	hide()
	
func _on_state_changed() -> void:
	if Global.state == Global.State.GAME_OVER:
		_SHIP.position.x = _BOAT_POSITION_FOR_ROUND[1] #reset boat position

func move_boat(round_count: int) -> void:
	await Global.delay(0.3)
	var tween = create_tween()
	tween.tween_property(_SHIP, "position:x", _BOAT_POSITION_FOR_ROUND[round_count], 1.0).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	await Global.delay(0.3)
