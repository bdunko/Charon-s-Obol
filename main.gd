extends Node2D

@onready var _COINS = $Coins

@onready var _POINTS_LABEL = $UI/PointsLabel
@onready var _LIVES_LABEL = $UI/LivesLabel
@onready var _ROUNDS_LABEL = $UI/RoundsLabel
@onready var _GOAL_LABEL = $UI/GoalLabel
@onready var _RESULT_LABEL = $UI/ResultLabel

@onready var _FLIP_BUTTON = $UI/FlipButton
@onready var _NEXT_ROUND_BUTTON = $UI/NextRoundButton
@onready var _RESET_BUTTON = $UI/ResetButton

var _rounds_remaining = 5:
	set(val):
		_rounds_remaining = val
		_ROUNDS_LABEL.text = "Rounds: %s" % _rounds_remaining
		if _rounds_remaining == -1:
			_on_game_end()

const _goal_points = 20
var _points = 0:
	set(val):
		_points = val
		_POINTS_LABEL.text = "Points: %s" % _points
		if _points > _goal_points:
			_on_game_end()

var _lives = 3:
	set(val):
		_lives = val
		_LIVES_LABEL.text = "Lives: %s" % _lives
		if _lives == -1:
			_on_game_end()

func _ready() -> void:
	assert(_COINS)
	
	assert(_POINTS_LABEL)
	assert(_LIVES_LABEL)
	assert(_ROUNDS_LABEL)
	assert(_GOAL_LABEL)
	assert(_RESULT_LABEL)
	
	assert(_FLIP_BUTTON)
	assert(_NEXT_ROUND_BUTTON)
	assert(_RESET_BUTTON)
	
	_on_reset_button_pressed()

func _on_game_end() -> void:
	var victory = _points >= _goal_points
	_RESULT_LABEL.text = "You win!" if victory else "You lose..."
	_FLIP_BUTTON.disabled = true
	_NEXT_ROUND_BUTTON.disabled = true
	_RESULT_LABEL.show()
	_RESET_BUTTON.show()

func _on_reset_button_pressed() -> void:
	_lives = 3
	_points = 0
	_rounds_remaining = 5
	_FLIP_BUTTON.disabled = false
	_NEXT_ROUND_BUTTON.disabled = false
	_RESULT_LABEL.hide()
	_RESET_BUTTON.hide()

func _on_flip_button_pressed() -> void:
	# flip all the coins
	for coin in _COINS.get_children() :
		coin = coin as Coin
		coin.flip()
		
		# for each coin on heads, gain a point
		if coin.is_heads():
			_points += 1
		else:
			_lives -= 1

func _on_next_round_button_pressed():
	# refresh lives
	_lives = 3 
	_rounds_remaining -= 1
