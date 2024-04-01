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
@onready var _ARROWS_BUTTON = $UI/ArrowsButton

@onready var _WARNING_LABEL = $UI/WarningLabel
@onready var _WARNING_TIMER = $UI/WarningLabel/Timer

var _state := State.BEFORE_FLIP:
	set(val):
		_state = val
		if _state == State.BEFORE_FLIP:
			_FLIP_BUTTON.show()
			_END_ROUND_BUTTON.show()
			_ACCEPT_BUTTON.hide()
			_LIVES_LABEL.show()
			_ARROWS_BUTTON.hide()
			_SHOP.hide()
		elif _state == State.AFTER_FLIP:
			_WARNING_LABEL.hide()
			_FLIP_BUTTON.hide()
			_END_ROUND_BUTTON.hide()
			if _arrows > 0:
				_ARROWS_BUTTON.show()
			_ACCEPT_BUTTON.show()
		elif _state == State.SHOP:
			_WARNING_LABEL.hide()
			_FLIP_BUTTON.hide()
			_END_ROUND_BUTTON.hide()
			_ACCEPT_BUTTON.show()
			_LIVES_LABEL.hide()
			_ARROWS_BUTTON.hide()
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
var _active_coin_power:
	set(val):
		_active_coin_power = val
		if _active_coin_power != Global.Power.NONE:
			if _active_coin_power == Global.Power.ARROW_REFLIP: # special case - arrow power has no coin
				_POWER_LABEL.text = "Power: Arrow Reflip"
			else:
				_POWER_LABEL.text = "Power: %s" % _active_coin_power_coin.get_power_string()
			_POWER_LABEL.show()
		else:
			_POWER_LABEL.hide()

var _arrows: int:
	set(val):
		_arrows = val
		assert(_arrows >= 0)
		_ARROWS_BUTTON.visible = _arrows != 0
		_ARROWS_BUTTON.text = "Arrows: %d" % _arrows
		

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
	assert(_ARROWS_BUTTON)
	
	_GOAL_LABEL.text = "Goal Coin Value: %d" % _GOAL_COIN_VALUE
	
	_on_reset_button_pressed()

func _on_game_end() -> void:
	var victory = _coin_value >= _GOAL_COIN_VALUE
	_RESULT_LABEL.text = "You win!" if victory else "You lose..."
	
	# hide most of the UI
	_FLIP_BUTTON.hide()
	_END_ROUND_BUTTON.hide()
	_ACCEPT_BUTTON.hide()
	_ARROWS_BUTTON.hide()
	_SHOP.hide()
	_ROUNDS_LABEL.hide()
	_FRAGMENT_LABEL.hide()
	_LIVES_LABEL.hide()
	_WARNING_LABEL.hide()
	
	_RESULT_LABEL.show()
	_RESET_BUTTON.show()

func _on_reset_button_pressed() -> void:
	# delete all existing coins
	for coin in _COIN_ROW.get_children():
		coin.queue_free()
	
	_round = 1
	_lives = _LIVES_PER_ROUND[1]
	_coin_value = 1
	_fragments = 0
	_arrows = 0
	_active_coin_power = Global.Power.NONE
	
	# make a single starting coin
	_gain_coin(Global.make_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL))
	
	_ROUNDS_LABEL.show()
	_FRAGMENT_LABEL.show()
	_LIVES_LABEL.show()
	
	_WARNING_LABEL.hide()
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
				coin.reset_power_uses()
		
	if _state != State.GAME_OVER:
		_state = State.BEFORE_FLIP

func _on_end_round_button_pressed():
	assert(_state == State.BEFORE_FLIP)
	_SHOP.randomize_shop()
	_state = State.SHOP

func _on_shop_coin_purchased(shop_item: ShopItem, price: int):
	# make sure we can afford this coin
	if _fragments < price:
		_display_warning("Insufficient fragments!")
		return 
	
	# we can afford it, so purchase this coin and remove it from the shop
	_fragments -= price
	_gain_coin_entity(shop_item.take_coin())
	shop_item.queue_free()

func _gain_coin(coin: Global.Coin) -> void:
	var new_coin: CoinEntity = load("res://coin.tscn").instantiate()
	new_coin.clicked.connect(_on_coin_clicked)
	_COIN_ROW.add_child(new_coin)
	new_coin.assign_coin(coin)
	_coin_value += coin.get_value()

func _gain_coin_entity(coin: CoinEntity):
	_COIN_ROW.add_child(coin)
	coin.clicked.connect(_on_coin_clicked)
	_coin_value += coin.get_value()

func _on_coin_clicked(coin: CoinEntity):
	# only use coin powers during after flip
	if _state != State.AFTER_FLIP:
		return
	
	# if we have a coin power active, we're using a power on this coin; do that
	if _active_coin_power != Global.Power.NONE:
		if coin == _active_coin_power_coin:
			_display_warning("Cannot use a coin's power on itself!")
			return
		elif _active_coin_power == Global.Power.ARROW_REFLIP and coin.get_power() == Global.Power.GAIN_ARROW:
			_display_warning("Cannot reflip Apollo coins with Arrows!")
			return
		elif _active_coin_power == Global.Power.WISDOM and coin.get_power() == Global.Power.WISDOM:
			_display_warning("Cannot use Athena's power on Athena coins!")
			return
		
		match(_active_coin_power):
			Global.Power.REFLIP:
				coin.flip()
			Global.Power.LOCK:
				coin.lock()
			Global.Power.FLIP_AND_NEIGHBORS:
				# find neighboring coins
				var left_neighbor: CoinEntity = null
				var right_neighbor: CoinEntity = null
				for i in _COIN_ROW.get_child_count():
					var curr_coin = _COIN_ROW.get_child(i)
					if curr_coin == coin:
						# if there is a right neighbor, grab it
						if i+1 < _COIN_ROW.get_child_count():
							right_neighbor = _COIN_ROW.get_child(i+1)
						break #then we're done
					left_neighbor = curr_coin
				
				# flip coin and neighbors
				coin.flip()
				if left_neighbor and left_neighbor != _active_coin_power_coin:
					left_neighbor.flip()
				if right_neighbor and right_neighbor != _active_coin_power_coin:
					right_neighbor.flip()
			Global.Power.CHANGE_AND_BLURSE:
				coin.change_face()
				coin.curse() if coin.is_heads() else coin.bless()
			Global.Power.WISDOM:
				if coin.get_life_loss() == 0:
					_display_warning("This coin already has no penalty!")
					return
				coin.apply_athena_wisdom()
			Global.Power.FORGE:
				if coin.get_denomination() == Global.Denomination.TETROBOL:
					_display_warning("This coin cannot be upgraded further!")
					return
				_coin_value -= coin.get_value()
				coin.upgrade_denomination()
				_coin_value += coin.get_value()
			Global.Power.RECHARGE:
				if coin.get_power() == Global.Power.NONE:
					_display_warning("This coin has no power to recharge!")
					return
				coin.recharge_power_uses_by(1)
			Global.Power.EXCHANGE:
				coin.assign_coin(Global.make_coin(Global.random_family(), coin.get_denomination()))
			Global.Power.BLESS:
				if coin.is_blessed():
					_display_warning("This coin is already blessed!")
					return
				coin.bless()
			Global.Power.DESTROY:
				_fragments += coin.get_store_price() + _active_coin_power_coin.get_store_price()
				_coin_value -= coin.get_value()
				coin.queue_free()
			Global.Power.ARROW_REFLIP:
				coin.flip()
				_arrows -= 1
				if _arrows == 0:
					_active_coin_power = Global.Power.NONE
				return #special case - this power is not from a coin, so just exit immediately
				
		_active_coin_power_coin.spend_power_use()
		if _active_coin_power_coin.get_power_uses_remaining() == 0:
			_active_coin_power_coin = null
			_active_coin_power = Global.Power.NONE
	
	# otherwise we're attempting to activate a coin
	elif coin.get_power() != Global.Power.NONE and coin.get_power_uses_remaining() > 0:
		# if this is a power which does not target, resolve it
		match coin.get_power():
			Global.Power.GAIN_LIFE:
				_lives += coin.get_power_uses_remaining()
				coin.spend_all_power_uses()
			Global.Power.GAIN_ARROW:
				_arrows += coin.get_power_uses_remaining()
				coin.spend_all_power_uses()
			Global.Power.REFLIP_ALL:
				for c in _COIN_ROW.get_children():
					c = c as CoinEntity
					if c != coin:
						c.flip()
				coin.spend_power_use()
			Global.Power.GAIN_COIN:
				_gain_coin(Global.make_coin(Global.random_family(), coin.get_denomination()))
				coin.spend_power_use()
			_: # otherwise, make this the active coin and coin power and await click on target
				_active_coin_power_coin = coin
				_active_coin_power = coin.get_power()
		
func _on_arrow_button_pressed():
	_active_coin_power = Global.Power.ARROW_REFLIP

func _display_warning(warning_msg: String) -> void:
	_WARNING_LABEL.text = warning_msg
	_WARNING_TIMER.start()
	_WARNING_LABEL.show()

func _on_warning_timer_timeout():
	_WARNING_LABEL.hide()

func _input(event):
	# right click with a god power disables it
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_active_coin_power = Global.Power.NONE
			_active_coin_power_coin = null
