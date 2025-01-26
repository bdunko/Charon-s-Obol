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

enum _State {
	EXPANDED, RETRACTED
}
var _state = _State.EXPANDED

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
func get_highest_valued() -> Array:
	assert(get_child_count() != 0)
	var highestValues = []
	for coin in get_children():
		if highestValues.is_empty() or highestValues[0].get_value() == coin.get_value():
			highestValues.append(coin)
		elif highestValues[0].get_value() < coin.get_value():
			highestValues.clear()
			highestValues.append(coin)
	return highestValues

func get_highest_valued_heads() -> Array:
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

# returns an array containing all coins from lowest to highest value
func get_lowest_to_highest_value() -> Array:
	assert(get_child_count() != 0)
	var low_to_high = []
	low_to_high.append_array(get_all_of_denomination(Global.Denomination.OBOL))
	low_to_high.append_array(get_all_of_denomination(Global.Denomination.DIOBOL))
	low_to_high.append_array(get_all_of_denomination(Global.Denomination.TRIOBOL))
	low_to_high.append_array(get_all_of_denomination(Global.Denomination.TETROBOL))
	assert(low_to_high.size() == get_child_count())
	return low_to_high

# returns an array containing all coins from highest to lowest value
func get_highest_to_lowest_value() -> Array:
	var high_to_low = get_lowest_to_highest_value()
	high_to_low.reverse()
	return high_to_low

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

static func FILTER_NOT_LUCKY(c: Coin) -> bool:
	return not c.is_lucky()

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

static func FILTER_NOT_SUPERCHARGED(c: Coin) -> bool:
	return c.is_supercharged()

static func FILTER_HEADS(c: Coin) -> bool:
	return c.is_heads()

static func FILTER_TAILS(c: Coin) -> bool:
	return c.is_tails()

static func FILTER_POWER(c: Coin) -> bool:
	return c.is_power()

static func FILTER_RECHARGABLE(c: Coin) -> bool:
	return c.is_power() and c.get_active_power_charges() != c.get_max_active_power_charges()

func get_filtered_randomized(filter_func) -> Array:
	return get_randomized().filter(filter_func)

func get_filtered(filter_func) -> Array:
	return get_children().filter(filter_func)

func has_coin(coin: Coin) -> bool:
	return get_children().has(coin)

func has_a_power_coin() -> bool:
	for c in get_children():
		if c.is_power():
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
	var coins_to_retract = get_children().filter(FILTER_NOT_STONE).filter(FILTER_NOT_FROZEN)
	
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
	
	var coin_width = get_child(0).size.x - 4
	var start = size.x / 2.0 + 2#center
	start -= ((get_child_count() * coin_width/2.0))
	
	# position all the coins
	for i in get_child_count():
		var coin = get_child(i)
		coin.move_to(Vector2(start + (i*coin_width) + 2, position.y), Global.COIN_TWEEN_TIME)
	
	await Global.delay(Global.COIN_TWEEN_TIME)

func disable_interaction() -> void:
	for coin in get_children():
		coin.disable_interaction()

func enable_interaction() -> void:
	for coin in get_children():
		coin.enable_interaction()
