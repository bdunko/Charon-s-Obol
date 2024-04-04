class_name Voyage
extends Node2D

@onready var _SHIP = $Ship
@onready var _BOAT_POSITION_FOR_ROUND = [-100, _SHIP.position.x, _SHIP.position.x + 33, _SHIP.position.x + 66, _SHIP.position.x + 99, _SHIP.position.x + 132, _SHIP.position.x + 148]

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
	tween.tween_property(_SHIP, "position:x", _BOAT_POSITION_FOR_ROUND[round_count], 1.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	await Global.delay(1.0)
