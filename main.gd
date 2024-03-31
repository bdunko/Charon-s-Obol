extends Node2D

enum State {
	BEFORE_FLIP, AFTER_FLIP, SHOP, GAME_OVER
}

@onready var _COIN_ROW = $Table/CoinRow
@onready var _SHOP : Shop = $Table/Shop

@onready var _COIN_VALUE_LABEL = $UI/CoinValueLabel
@onready var _LIVES_LABEL = $UI/LivesLabel
@onready var _ROUNDS_LABEL = $UI/RoundsLabel
@onready var _GOAL_LABEL = $UI/GoalLabel
@onready var _RESULT_LABEL = $UI/ResultLabel
@onready var _FRAGMENT_LABEL = $UI/FragmentsLabel
@onready var _POWER_LABEL = $UI/PowerLabel

@onready var _FLIP_BUTTON = $UI/FlipButton
@onready var _END_ROUND_BUTTON = $UI/EndRoundButton
@onready var _ACCEPT_BUTTON = $UI/AcceptButton
@onready var _RESET_BUTTON = $UI/ResetButton

var _state := State.BEFORE_FLIP:
	set(val):
		_state = val
		if _state == State.BEFORE_FLIP:
			_FLIP_BUTTON.show()
			_END_ROUND_BUTTON.show()
			_ACCEPT_BUTTON.hide()
			_LIVES_LABEL.show()
			_SHOP.hide()
		elif _state == State.AFTER_FLIP:
			_FLIP_BUTTON.hide()
			_END_ROUND_BUTTON.hide()
			_ACCEPT_BUTTON.show()
		elif _state == State.SHOP:
			_FLIP_BUTTON.hide()
			_END_ROUND_BUTTON.hide()
			_ACCEPT_BUTTON.show()
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
			_state = State.GAME_OVER

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
			_state = State.GAME_OVER

const _LIVES_PER_ROUND = [-1, 3, 5, 8, 10, 15]
var _lives:
	set(val):
		_lives = val
		_LIVES_LABEL.text = "Lives: %s" % _lives
		if _lives < 0:
			_state = State.GAME_OVER

var _active_coin_power_coin: CoinEntity = null
var _active_coin_power := Global.Power.NONE:
	set(val):
		_active_coin_power = val
		if _active_coin_power != Global.Power.NONE:
			_POWER_LABEL.text = "Power: %s" % _active_coin_power_coin.get_power_string()
			_POWER_LABEL.show()
		else:
			_POWER_LABEL.hide()

func _ready() -> void:
	assert(_COIN_ROW)
	assert(_SHOP)
	
	assert(_COIN_VALUE_LABEL)
	assert(_LIVES_LABEL)
	assert(_ROUNDS_LABEL)
	assert(_GOAL_LABEL)
	assert(_RESULT_LABEL)
	assert(_POWER_LABEL)
	assert(_FRAGMENT_LABEL)
	
	assert(_FLIP_BUTTON)
	assert(_ACCEPT_BUTTON)
	assert(_END_ROUND_BUTTON)
	assert(_RESET_BUTTON)
	
	_GOAL_LABEL.text = "Goal Coin Value: %d" % _GOAL_COIN_VALUE
	
	_on_reset_button_pressed()

func _on_game_end() -> void:
	var victory = _coin_value >= _GOAL_COIN_VALUE
	_RESULT_LABEL.text = "You win!" if victory else "You lose..."
	
	# hide most of the UI
	_FLIP_BUTTON.hide()
	_END_ROUND_BUTTON.hide()
	_ACCEPT_BUTTON.hide()
	_SHOP.hide()
	_ROUNDS_LABEL.hide()
	_FRAGMENT_LABEL.hide()
	_LIVES_LABEL.hide()
	
	_RESULT_LABEL.show()
	_RESET_BUTTON.show()

func _on_reset_button_pressed() -> void:
	# delete all existing coins
	for coin in _COIN_ROW.get_children():
		coin.queue_free()
	
	# make a single starting coin
	var starting_coin: CoinEntity = load("res://coin.tscn").instantiate()
	starting_coin.clicked.connect(_on_coin_clicked)
	_COIN_ROW.add_child(starting_coin)
	starting_coin.assign_coin(Global.make_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL))
	
	# debug - give myself what I need
	var debug_coin: CoinEntity = load("res://coin.tscn").instantiate()
	debug_coin.clicked.connect(_on_coin_clicked)
	_COIN_ROW.add_child(debug_coin)
	debug_coin.assign_coin(Global.make_coin(Global.HERA_FAMILY, Global.Denomination.DIOBOL))
	# todo - remove this
	
	_round = 1
	_lives = _LIVES_PER_ROUND[1]
	_coin_value = 1
	_fragments = 0
	
	_ROUNDS_LABEL.show()
	_FRAGMENT_LABEL.show()
	_LIVES_LABEL.show()
	
	_RESULT_LABEL.hide()
	_RESET_BUTTON.hide()
	_state = State.BEFORE_FLIP

func _on_flip_button_pressed() -> void:
	# flip all the coins
	for coin in _COIN_ROW.get_children() :
		coin = coin as CoinEntity
		coin.flip()
		coin.unlock() #remove any lock from a previous round
	_state = State.AFTER_FLIP

func _on_accept_button_pressed():
	assert(_state != State.GAME_OVER and _state != State.BEFORE_FLIP, "this shouldn't happen")
	
	_active_coin_power = Global.Power.NONE
	_active_coin_power_coin = null
	
	match(_state):
		State.AFTER_FLIP:
			for coin in _COIN_ROW.get_children():
				if coin.is_heads():
					_fragments += coin.get_fragments()
				else:
					_lives -= coin.get_life_loss()
		State.SHOP:
			_round += 1
			if _round > _ROUNDS: # if the game ended, just exit
				return
				
			# refresh lives
			_lives = _LIVES_PER_ROUND[_round]
			
			# recharge all coin powers
			for coin in _COIN_ROW.get_children():
				coin = coin as CoinEntity
				coin.recharge_power_uses_fully()
		
	if _state != State.GAME_OVER:
		_state = State.BEFORE_FLIP

func _on_end_round_button_pressed():
	assert(_state == State.BEFORE_FLIP)
	_SHOP.randomize_shop()
	_state = State.SHOP

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
	coin.clicked.connect(_on_coin_clicked)
	_coin_value += coin.get_value()

func _on_coin_clicked(coin: CoinEntity):
	# only use coin powers during after flip
	if _state != State.AFTER_FLIP:
		return
	
	# if we have a coin power active, we're using a power on this coin; do that
	if _active_coin_power != Global.Power.NONE:
		assert(_active_coin_power_coin, "What coin is using this power??")
		
		if coin == _active_coin_power_coin:
			print("coin cannot activate on itself")
			# todo - error msg
			return
		
		match(_active_coin_power):
			Global.Power.REFLIP:
				coin.flip()
			Global.Power.LOCK:
				coin.lock()
		
		_active_coin_power_coin.spend_power_use()
		if _active_coin_power_coin.get_power_uses_remaining() == 0:
			_active_coin_power_coin = null
			_active_coin_power = Global.Power.NONE
	
	# otherwise we're attempting to activate a coin
	elif coin.get_power() != Global.Power.NONE and coin.get_power_uses_remaining() > 0:
		# make this the active coin and coin power
		_active_coin_power_coin = coin
		_active_coin_power = coin.get_power()
