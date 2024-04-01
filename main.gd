extends Node2D

@onready var _COIN_ROW = $Table/CoinRow
@onready var _SHOP : Shop = $Table/Shop

@onready var _RESULT_LABEL = $UI/ResultLabel

@onready var _RESET_BUTTON = $UI/ResetButton

func _ready() -> void:
	assert(_COIN_ROW)
	assert(_SHOP)
	
	assert(_RESULT_LABEL)
	
	assert(_RESET_BUTTON)
	
	Global.state_changed.connect(_on_state_changed)
	
	_on_reset_button_pressed()

func _on_state_changed() -> void:
	if Global.state == Global.State.GAME_OVER:
		_on_game_end()
	else:
		_RESULT_LABEL.hide()
		_RESET_BUTTON.hide()

func _on_game_end() -> void:
	var victory = Global.coin_value >= Global.GOAL_COIN_VALUE
	_RESULT_LABEL.text = "You win!" if victory else "You lose..."
	_RESULT_LABEL.show()
	_RESET_BUTTON.show()

func _on_reset_button_pressed() -> void:
	# delete all existing coins
	for coin in _COIN_ROW.get_children():
		coin.queue_free()
	
	Global.round_count = 1
	Global.lives = Global.LIVES_PER_ROUND[1]
	Global.coin_value = 1
	Global.fragments = 0
	Global.arrows = 0
	Global.active_coin_power = Global.Power.NONE
	
	# make a single starting coin
	_gain_coin(Global.make_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL))
	
	_RESULT_LABEL.hide()
	_RESET_BUTTON.hide()
	Global.state = Global.State.BEFORE_FLIP

func _on_flip_button_pressed() -> void:
	# flip all the coins
	for coin in _COIN_ROW.get_children() :
		coin = coin as CoinEntity
		coin.flip()
		coin.unlock() #remove any lock from a previous round
	Global.state = Global.State.AFTER_FLIP

func _on_accept_button_pressed():
	assert(Global.state != Global.State.GAME_OVER and Global.state != Global.State.BEFORE_FLIP, "this shouldn't happen")
	
	Global.active_coin_power = Global.Power.NONE
	Global.active_coin_power_coin = null
	
	match(Global.state):
		Global.State.AFTER_FLIP:
			for coin in _COIN_ROW.get_children():
				if coin.is_heads():
					Global.fragments += coin.get_fragments()
				else:
					Global.lives -= coin.get_life_loss()
		Global.State.SHOP:
			Global.round_count += 1
			if Global.round_count > Global.NUM_ROUNDS: # if the game ended, just exit
				return
				
			# refresh lives
			Global.lives = Global.LIVES_PER_ROUND[Global.round_count]
			
			# recharge all coin powers
			for coin in _COIN_ROW.get_children():
				coin = coin as CoinEntity
				coin.reset_power_uses()
		
	if Global.state != Global.State.GAME_OVER:
		Global.state = Global.State.BEFORE_FLIP

func _on_end_round_button_pressed():
	assert(Global.state == Global.State.BEFORE_FLIP)
	_SHOP.randomize_shop()
	Global.state = Global.State.SHOP

func _on_shop_coin_purchased(shop_item: ShopItem, price: int):
	# make sure we can afford this coin
	if Global.fragments < price:
		Global.show_warning("Insufficient fragments!")
		return 
	
	# we can afford it, so purchase this coin and remove it from the shop
	Global.fragments -= price
	_gain_coin_entity(shop_item.take_coin())
	shop_item.queue_free()

func _gain_coin(coin: Global.Coin) -> void:
	var new_coin: CoinEntity = load("res://coin.tscn").instantiate()
	new_coin.clicked.connect(_on_coin_clicked)
	_COIN_ROW.add_child(new_coin)
	new_coin.assign_coin(coin)
	Global.coin_value += coin.get_value()

func _gain_coin_entity(coin: CoinEntity):
	_COIN_ROW.add_child(coin)
	coin.clicked.connect(_on_coin_clicked)
	Global.coin_value += coin.get_value()

func _on_coin_clicked(coin: CoinEntity):
	# only use coin powers during after flip
	if Global.state != Global.State.AFTER_FLIP:
		return
	
	# if we have a coin power active, we're using a power on this coin; do that
	if Global.active_coin_power != Global.Power.NONE:
		if coin == Global.active_coin_power_coin:
			Global.show_warning("Cannot use a coin's power on itself!")
			return
		elif Global.active_coin_power == Global.Power.ARROW_REFLIP and coin.get_power() == Global.Power.GAIN_ARROW:
			Global.show_warning("Cannot reflip Apollo coins with Arrows!")
			return
		elif Global.active_coin_power == Global.Power.WISDOM and coin.get_power() == Global.Power.WISDOM:
			Global.show_warning("Cannot use Athena's power on Athena coins!")
			return
		
		match(Global.active_coin_power):
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
				if left_neighbor and left_neighbor != Global.active_coin_power_coin:
					left_neighbor.flip()
				if right_neighbor and right_neighbor != Global.active_coin_power_coin:
					right_neighbor.flip()
			Global.Power.CHANGE_AND_BLURSE:
				coin.change_face()
				coin.curse() if coin.is_heads() else coin.bless()
			Global.Power.WISDOM:
				if coin.get_life_loss() == 0:
					Global.show_warning("This coin already has no penalty!")
					return
				coin.apply_athena_wisdom()
			Global.Power.FORGE:
				if coin.get_denomination() == Global.Denomination.TETROBOL:
					Global.show_warning("This coin cannot be upgraded further!")
					return
				Global.coin_value -= coin.get_value()
				coin.upgrade_denomination()
				Global.coin_value += coin.get_value()
			Global.Power.RECHARGE:
				if coin.get_power() == Global.Power.NONE:
					Global.show_warning("This coin has no power to recharge!")
					return
				coin.recharge_power_uses_by(1)
			Global.Power.EXCHANGE:
				coin.assign_coin(Global.make_coin(Global.random_family(), coin.get_denomination()))
			Global.Power.BLESS:
				if coin.is_blessed():
					Global.show_warning("This coin is already blessed!")
					return
				coin.bless()
			Global.Power.DESTROY:
				Global.fragments += coin.get_store_price() + Global.active_coin_power_coin.get_store_price()
				Global.coin_value -= coin.get_value()
				coin.queue_free()
			Global.Power.ARROW_REFLIP:
				coin.flip()
				Global.arrows -= 1
				if Global.arrows == 0:
					Global.active_coin_power = Global.Power.NONE
				return #special case - this power is not from a coin, so just exit immediately
				
		Global.active_coin_power_coin.spend_power_use()
		if Global.active_coin_power_coin.get_power_uses_remaining() == 0:
			Global.active_coin_power_coin = null
			Global.active_coin_power = Global.Power.NONE
	
	# otherwise we're attempting to activate a coin
	elif coin.get_power() != Global.Power.NONE and coin.get_power_uses_remaining() > 0:
		# if this is a power which does not target, resolve it
		match coin.get_power():
			Global.Power.GAIN_LIFE:
				Global.lives += coin.get_power_uses_remaining()
				coin.spend_all_power_uses()
			Global.Power.GAIN_ARROW:
				Global.arrows += coin.get_power_uses_remaining()
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
				Global.active_coin_power_coin = coin
				Global.active_coin_power = coin.get_power()
		
func _on_arrow_button_pressed():
	Global.active_coin_power = Global.Power.ARROW_REFLIP

func _input(event):
	# right click with a god power disables it
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			Global.active_coin_power = Global.Power.NONE
			Global.active_coin_power_coin = null
