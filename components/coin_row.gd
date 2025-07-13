class_name CoinRow
extends Control

func _on_child_entered_tree(_node) -> void:
	assert(_node is Coin or _node.name == "PLACEHOLDERS", "Coin Row cannot contain non-Coins!")
	if _state == _State.EXPANDED:
		call_deferred("expand")

func _on_child_exiting_tree(_node) -> void:
	# update 1 frame later once child is gone
	if _state == _State.EXPANDED:
		call_deferred("expand")

func _on_child_order_changed():
	if _state == _State.EXPANDED:
		call_deferred("expand")

enum _State {
	EXPANDED, RETRACTED
}
var _state = _State.EXPANDED

@onready var _PLACEHOLDERS = $PLACEHOLDERS
var _POSITION_MAP = {}
func _ready() -> void:
	# store placeholders
	var coin_num = 0
	for coin_count in _PLACEHOLDERS.get_children():
		coin_num += 1
		var pos_array = []
		for coin in coin_count.get_children():
			pos_array.push_back(coin.position + global_position)
		_POSITION_MAP[coin_num] = pos_array
	
	# now delete placeholders
	_PLACEHOLDERS.queue_free()
	remove_child(_PLACEHOLDERS)

func clear() -> void:
	for coin in get_children():
		coin.queue_free()
		remove_child(coin)

# returns array of all coins on tails
func get_tails() -> Array:
	assert(get_child_count() != 0)
	var tails = []
	for coin in get_children():
		if coin.is_tails():
			tails.append(coin)
	return tails

# returns array of all coins on heads
func get_heads() -> Array:
	assert(get_child_count() != 0)
	var heads = []
	for coin in get_children():
		if coin.is_heads():
			heads.append(coin)
	return heads

# returns an array containing all coins of the highest denomination amongst coins in this row
func get_highest_valued_that_can_be_targetted() -> Array:
	assert(get_child_count() != 0)
	var highestValues = []
	for coin in get_children():
		if not coin.can_target():
			continue
		if highestValues.is_empty() or highestValues[0].get_value() == coin.get_value():
			highestValues.append(coin)
		elif highestValues[0].get_value() < coin.get_value():
			highestValues.clear()
			highestValues.append(coin)
	return highestValues

func get_highest_valued_heads_that_can_be_targetted() -> Array:
	assert(get_child_count() != 0)
	var highestValues = []
	for coin in get_children():
		if coin.is_heads():
			if highestValues.is_empty() or highestValues[0].get_value() == coin.get_value():
				highestValues.append(coin)
			elif highestValues[0].get_value() < coin.get_value():
				highestValues.clear()
				highestValues.append(coin)
	return highestValues

# returns an array containing all coins of the highest denomination amongst coins in this row
func get_lowest_valued() -> Array:
	assert(get_child_count() != 0)	
	var lowestValues = []
	for coin in get_children():
		if lowestValues.is_empty() or lowestValues[0].get_value() == coin.get_value():
			lowestValues.append(coin)
		elif lowestValues[0].get_value() > coin.get_value():
			lowestValues.clear()
			lowestValues.append(coin)
	return lowestValues

# returns an array containing all coins from lowest to highest value; with each denom shuffled
func get_lowest_to_highest_value() -> Array:
	assert(get_child_count() != 0)
	var low_to_high = []
	for denom in [Global.Denomination.OBOL, Global.Denomination.DIOBOL, Global.Denomination.TRIOBOL, Global.Denomination.TETROBOL, Global.Denomination.PENTOBOL, Global.Denomination.DRACHMA]:
		var coins_of_denom = get_all_of_denomination(denom)
		coins_of_denom.shuffle()
		low_to_high.append_array(coins_of_denom)
	assert(low_to_high.size() == get_child_count())
	return low_to_high

# returns an array containing all coins from highest to lowest value
func get_highest_to_lowest_value() -> Array:
	var high_to_low = get_lowest_to_highest_value()
	high_to_low.reverse()
	return high_to_low

func get_highest_to_lowest_value_that_can_be_targetted() -> Array:
	var output = []
	for coin in get_highest_to_lowest_value():
		if coin.can_target():
			output.append(coin)
	return output

# returns the total value of coins in this row
func calculate_total_value() -> int:
	var sum = 0
	for coin in get_children():
		sum += coin.get_value()
	return sum

# returns an array of the coins from left to right
func get_leftmost_to_rightmost() -> Array:
	assert(get_child_count() != 0)
	return get_children()

# returns an array of coins from right to left
func get_rightmost_to_leftmost() -> Array:
	assert(get_child_count() != 0)
	var right_to_left = get_leftmost_to_rightmost()
	right_to_left.reverse()
	return right_to_left

# returns an array containing all coins matching the given denomination
func get_all_of_denomination(denom: Global.Denomination) -> Array:
	assert(get_child_count() != 0)
	var coins_of_denom = []
	for coin in get_children():
		if coin.get_denomination() == denom:
			coins_of_denom.append(coin)
	return coins_of_denom

func get_all_of_family(fam: Global.CoinFamily) -> Array:
	assert(get_child_count() != 0)
	var coins_of_fam = []
	for coin in get_children():
		if coin.get_coin_family() == fam:
			coins_of_fam.append(coin)
	return coins_of_fam

# returns the coins in a random order
func get_randomized() -> Array:
	assert(get_child_count() != 0)
	var randomized = get_children() 
	randomized.shuffle()
	return randomized

# returns a random coin
func get_random() -> Coin:
	assert(get_child_count() != 0)
	return Global.choose_one(get_children())

# returns the coin to the left, or nullptr if none
func get_left_of(coin: Coin) -> Coin:
	assert(get_children().has(coin))
	if coin.get_index() == 0: #nothing more to the left
		return null
	return get_child(coin.get_index() - 1)

# returns the coin to the right, or nullptr if none
func get_right_of(coin: Coin) -> Coin:
	assert(get_children().has(coin))
	if coin.get_index() + 1 == get_child_count(): #nothing more to the right
		return null
	return get_child(coin.get_index() + 1)

func get_all_left_of(coin: Coin) -> Array:
	assert(get_children().has(coin))
	var to_left = []
	var current = coin
	
	var left = get_left_of(current)
	while left != null:
		to_left.append(left)
		current = left
		left = get_left_of(current)
	
	return to_left

func get_all_right_of(coin: Coin) -> Array:
	assert(get_children().has(coin))
	var to_right = []
	var current = coin
	
	var right = get_right_of(coin)
	while right != null:
		to_right.append(right)
		current = right
		right = get_right_of(current)
	
	return to_right

static func FILTER_NOT_LUCKY(c: Coin) -> bool:
	return not c.is_lucky()

static func FILTER_LUCKY(c: Coin) -> bool:
	return c.is_lucky()

static func FILTER_NOT_UNLUCKY(c: Coin) -> bool:
	return not c.is_unlucky()

static func FILTER_UNLUCKY(c: Coin) -> bool:
	return c.is_unlucky()

static func FILTER_NOT_BLANK(c: Coin) -> bool:
	return not c.is_blank()

static func FILTER_BLANK(c: Coin) -> bool:
	return c.is_blank()

static func FILTER_NOT_BLESSED(c: Coin) -> bool:
	return not c.is_blessed()

static func FILTER_BLESSED(c: Coin) -> bool:
	return c.is_blessed()

static func FILTER_NOT_CURSED(c: Coin) -> bool:
	return not c.is_cursed()

static func FILTER_CURSED(c: Coin) -> bool:
	return c.is_cursed()

static func FILTER_NOT_IGNITED(c: Coin) -> bool:
	return not c.is_ignited()

static func FILTER_IGNITED(c: Coin) -> bool:
	return c.is_ignited()

static func FILTER_NOT_FROZEN(c: Coin) -> bool:
	return not c.is_frozen()

static func FILTER_FROZEN(c: Coin) -> bool:
	return c.is_frozen()

static func FILTER_NOT_STONE(c: Coin) -> bool:
	return not c.is_stone()

static func FILTER_STONE(c: Coin) -> bool:
	return c.is_stone()

static func FILTER_NOT_CHARGED(c: Coin) -> bool:
	return not c.is_charged()

static func FILTER_NOT_DESECRATED(c: Coin) -> bool:
	return not c.is_desecrated()

static func FILTER_BURIED(c: Coin) -> bool:
	return c.is_buried()

static func FILTER_NOT_BURIED(c: Coin) -> bool:
	return not c.is_buried()

static func FILTER_FLIPPABLE(c: Coin) -> bool:
	return c.can_flip()

static func FILTER_HEADS(c: Coin) -> bool:
	return c.is_heads()

static func FILTER_TAILS(c: Coin) -> bool:
	return c.is_tails()

static func FILTER_POWER(c: Coin) -> bool:
	return c.is_power_coin()

static func FILTER_ACTIVE_PAYOFF(c: Coin) -> bool:
	return c.is_active_face_payoff() and not c.is_buried()

static func FILTER_USABLE_POWER(c: Coin) -> bool:
	return c.is_power_coin() and c.get_active_power_charges() != 0 and not c.is_buried()

static func FILTER_CAN_INCREASE_PENALTY(c: Coin) -> bool:
	return c.can_change_life_penalty()

static func FILTER_RECHARGABLE(c: Coin) -> bool:
	return c.is_power_coin() and c.get_active_power_charges() != c.get_max_active_power_charges() and not c.is_buried()

static func FILTER_OBOL(c: Coin) -> bool:
	return c.get_denomination() == Global.Denomination.OBOL

static func FILTER_DIOBOL(c: Coin) -> bool:
	return c.get_denomination() == Global.Denomination.DIOBOL
	
static func FILTER_TRIOBOL(c: Coin) -> bool:
	return c.get_denomination() == Global.Denomination.TRIOBOL
	
static func FILTER_TETROBOL(c: Coin) -> bool:
	return c.get_denomination() == Global.Denomination.TETROBOL
	
static func FILTER_PENTOBOL(c: Coin) -> bool:
	return c.get_denomination() == Global.Denomination.PENTOBOL
	
static func FILTER_DRACHMA(c: Coin) -> bool:
	return c.get_denomination() == Global.Denomination.DRACHMA

static func FILTER_CAN_TARGET(c: Coin) -> bool:
	return c.can_target()

func get_filtered_randomized(filter_func) -> Array:
	return get_randomized().filter(filter_func)

func get_filtered(filter_func) -> Array:
	return get_children().filter(filter_func)

func get_multi_filtered(filter_funcs: Array) -> Array:
	var ret = get_children()
	for filt_func in filter_funcs:
		ret = ret.filter(filt_func)
	return ret

func get_multi_filtered_randomized(filter_funcs: Array) -> Array:
	var ret = get_randomized()
	for filt_func in filter_funcs:
		ret = ret.filter(filt_func)
	return ret

func has_coin(coin: Coin) -> bool:
	return get_children().has(coin)

func has_a_power_coin() -> bool:
	for c in get_children():
		if c.is_power_coin():
			return true
	return false

func shuffle() -> void:
	var all_coins = []
	for c in get_children():
		all_coins.append(c)
		remove_child(c)
	all_coins.shuffle()
	for c in all_coins:
		add_child(c)

func swap_positions(coin1: Coin, coin2: Coin) -> void:
	assert(coin1.get_parent() == self)
	assert(coin2.get_parent() == self)
	var index1 = coin1.get_index()
	var index2 = coin2.get_index()
	move_child(coin1, index2)
	move_child(coin2, index1)

func retract(retract_point: Vector2) -> void:
	_state = _State.RETRACTED
	if get_child_count() == 0:
		return
	
	for i in get_child_count():
		var coin = get_child(i)
		coin.move_to(retract_point, Global.COIN_TWEEN_TIME)
	await Global.delay(Global.COIN_TWEEN_TIME)

func retract_for_toss(retract_point: Vector2) -> void:
	_state = _State.RETRACTED
	if get_child_count() == 0:
		return
	
	# don't retract frozen or stoned coins
	var coins_to_retract = get_multi_filtered([FILTER_NOT_STONE, FILTER_NOT_FROZEN, FILTER_FLIPPABLE])
	
	# do a very minor delay if nothing to retract
	if coins_to_retract.size() == 0:
		await Global.delay(0.1)
		return
	
	for coin in coins_to_retract:
		coin.move_to(retract_point, Global.COIN_TWEEN_TIME)
	
	await Global.delay(Global.COIN_TWEEN_TIME)
	

func expand() -> void:
	_state = _State.EXPANDED
	if get_child_count() == 0:
		return
	
	# position all the coins
	var positions = _POSITION_MAP[get_child_count()]
	for i in get_child_count():
		var coin = get_child(i)
		coin.move_to(positions[i], Global.COIN_TWEEN_TIME)
	
	await Global.delay(Global.COIN_TWEEN_TIME)

func disable_interaction() -> void:
	for coin in get_children():
		coin.disable_interaction()

func enable_interaction() -> void:
	for coin in get_children():
		coin.enable_interaction()

func num_coins() -> int:
	return get_child_count()

# returns the first coin with the given family, or null if none exist
func find_first_of_family(family: Global.CoinFamily) -> Coin:
	for coin in get_children():
		if coin.get_coin_family() == family:
			return coin
	return null
