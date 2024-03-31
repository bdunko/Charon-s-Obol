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
			_SHOP.show()
		elif _state == State.GAME_OVER:
			_on_game_end()

const _ROUNDS = 5
var _round:
	set(val):
		_round = val
		_ROUNDS_LABEL.text = "Rounds Left: %s" % (_ROUNDS - _round)
		if _round > _ROUNDS:
			_on_game_end()

var _fragments:
	set(val):
		_fragments = val
		_FRAGMENT_LABEL.text = "Fragments: %s" % _fragments

const _GOAL_COIN_VALUE = 20
var _coin_value:
	set(val):
		_coin_value = val
		_COIN_VALUE_LABEL.text = "Total Coin Value: %s" % _coin_value
		if _coin_value >= _GOAL_COIN_VALUE:
			_on_game_end()

const _LIVES_PER_ROUND = [-1, 3, 5, 8, 10, 15]
var _lives:
	set(val):
		_lives = val
		_LIVES_LABEL.text = "Lives: %s" % _lives
		if _lives < 0:
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
	# delete all existing coins
	for coin in _COIN_ROW.get_children():
		coin.queue_free()
	
	# make a single starting coin
	var starting_coin: CoinEntity = load("res://coin.tscn").instantiate()
	_COIN_ROW.add_child(starting_coin)
	starting_coin.assign_coin(Global.make_coin(Global.CoinType.GENERIC, Global.Denomination.OBOL))
	
	_round = 1
	_lives = _LIVES_PER_ROUND[1]
	_coin_value = 1
	_fragments = 0
	_FLIP_BUTTON.disabled = false
	_CONTINUE_BUTTON.disabled = false
	_RESULT_LABEL.hide()
	_RESET_BUTTON.hide()
	_state = State.FLIPPING

func _on_flip_button_pressed() -> void:
	# flip all the coins
	for coin in _COIN_ROW.get_children() :
		coin = coin as CoinEntity
		coin.flip()
		
		if coin.is_heads():
			_fragments += coin.get_fragments()
		else:
			_lives -= coin.get_life_loss()

func _on_continue_button_pressed():
	assert(_state != State.GAME_OVER, "this shouldn't happen")
	match(_state):
		State.FLIPPING: # if we're currently flipping, change to shop
			_SHOP.randomize_shop()
			_state = State.SHOP
		State.SHOP: # if we're currently shopping, change to flips
			_round += 1
			if _round > _ROUNDS: # if the game ended, just exit
				return
			_lives = _LIVES_PER_ROUND[_round]
			_state = State.FLIPPING

func _on_shop_coin_purchased(shop_item: ShopItem, price: int):
	# make sure we can afford this coin
	if _fragments < price:
		print("cant afford!")
		return #todo - error msg
	
	# we can afford it, so purchase this coin and remove it from the shop
	_fragments -= price
	_gain_coin(shop_item.take_coin())
	shop_item.queue_free()

func _gain_coin(coin: CoinEntity):
	_COIN_ROW.add_child(coin)
	_coin_value += coin.get_value()
