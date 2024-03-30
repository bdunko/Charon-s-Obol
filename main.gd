extends Node2D

enum State {
	FLIPPING, SHOP, GAME_OVER
}

@onready var _COIN_ROW = $Table/CoinRow
@onready var _SHOP : Shop = $Table/Shop

@onready var _COIN_VALUE_LABEL = $UI/CoinValueLabel
@onready var _LIVES_LABEL = $UI/LivesLabel
@onready var _ROUNDS_LABEL = $UI/RoundsLabel
@onready var _GOAL_LABEL = $UI/GoalLabel
@onready var _RESULT_LABEL = $UI/ResultLabel
@onready var _FRAGMENT_LABEL = $UI/FragmentsLabel

@onready var _FLIP_BUTTON = $UI/FlipButton
@onready var _CONTINUE_BUTTON = $UI/ContinueButton
@onready var _RESET_BUTTON = $UI/ResetButton

var _state := State.FLIPPING:
	set(val):
		_state = val
		if _state == State.FLIPPING:
			_FLIP_BUTTON.disabled = false
			_LIVES_LABEL.show()
			_SHOP.hide()
		elif _state == State.SHOP:
			_FLIP_BUTTON.disabled = true
			_LIVES_LABEL.hide()
			_SHOP.populate()
			_SHOP.show()
		elif _state == State.GAME_OVER:
			_on_game_end()

const _ROUNDS = 5
var _rounds_remaining = _ROUNDS:
	set(val):
		_rounds_remaining = val
		_ROUNDS_LABEL.text = "Rounds: %s" % _rounds_remaining
		if _rounds_remaining == -1:
			_on_game_end()

var _fragments = 0:
	set(val):
		_fragments = val
		_FRAGMENT_LABEL.text = "Fragments: %s" % _fragments

const _GOAL_COIN_VALUE = 5
var _coin_value:
	set(val):
		_coin_value = val
		_COIN_VALUE_LABEL.text = "Total Coin Value: %s" % _coin_value
		if _coin_value >= _GOAL_COIN_VALUE:
			_on_game_end()

const _LIVES_PER_ROUND = 5
var _lives = _LIVES_PER_ROUND:
	set(val):
		_lives = val
		_LIVES_LABEL.text = "Lives: %s" % _lives
		if _lives == -1:
			_on_game_end()

func _ready() -> void:
	assert(_COIN_ROW)
	assert(_SHOP)
	
	assert(_COIN_VALUE_LABEL)
	assert(_LIVES_LABEL)
	assert(_ROUNDS_LABEL)
	assert(_GOAL_LABEL)
	assert(_RESULT_LABEL)
	
	assert(_FLIP_BUTTON)
	assert(_CONTINUE_BUTTON)
	assert(_RESET_BUTTON)
	
	_GOAL_LABEL.text = "Goal Coin Value: %d" % _GOAL_COIN_VALUE
	
	_on_reset_button_pressed()

func _on_game_end() -> void:
	var victory = _coin_value >= _GOAL_COIN_VALUE
	_RESULT_LABEL.text = "You win!" if victory else "You lose..."
	_FLIP_BUTTON.disabled = true
	_CONTINUE_BUTTON.disabled = true
	_SHOP.hide()
	_RESULT_LABEL.show()
	_RESET_BUTTON.show()

func _on_reset_button_pressed() -> void:
	_lives = _LIVES_PER_ROUND
	_coin_value = 1
	_fragments = 0
	_rounds_remaining = _ROUNDS
	_FLIP_BUTTON.disabled = false
	_CONTINUE_BUTTON.disabled = false
	_RESULT_LABEL.hide()
	_RESET_BUTTON.hide()
	_state = State.FLIPPING

func _on_flip_button_pressed() -> void:
	# flip all the coins
	for coin in _COIN_ROW.get_children() :
		coin = coin as Coin
		coin.flip()
		
		# for each coin on heads, gain a point
		if coin.is_heads():
			_fragments += 1
		else:
			_lives -= 1

func _on_continue_button_pressed():
	assert(_state != State.GAME_OVER, "this shouldn't happen")
	match(_state):
		State.FLIPPING: # if we're currently flipping, change to shop
			_state = State.SHOP
		State.SHOP: # if we're currently shopping, change to flips
			_rounds_remaining -= 1
			if _rounds_remaining == -1: # if the game ended, just exit
				return
			_lives = _LIVES_PER_ROUND
			_state = State.FLIPPING

func _on_shop_coin_purchased(shop_item: ShopItem, price: int):
	# make sure we can afford this coin
	if _fragments < price:
		print("cant afford!")
		return #todo - error msg
	
	# we can afford it, so purchase this coin and remove it from the shop
	_fragments -= price
	_COIN_ROW.add_child(shop_item.take_coin())
	_coin_value += 1
	shop_item.queue_free()
	
