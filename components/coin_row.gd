class_name CoinRow
extends Control

func _on_child_entered_tree(_node) -> void:
	assert(_node is Coin, "Coin Row cannot contain non-Coins!")
	_update_coins()

func _on_child_exiting_tree(_node) -> void:
	# update 1 frame later once child is gone
	call_deferred("_update_coins")

# returns array of all coins on tails
func get_tails() -> Array:
	assert(get_child_count() != 0)
	var tails = []
	for coin in get_children():
		if coin.get_tails():
			tails.append(coin)
	return tails

# returns array of all coins on heads
func get_heads() -> Array:
	assert(get_child_count() != 0)
	var heads = []
	for coin in get_children():
		if coin.get_heads():
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

# randomly destroy one coin of the lowest denomination
func destroy_lowest_value() -> void:
	for denom in [Global.Denomination.OBOL, Global.Denomination.DIOBOL, Global.Denomination.TRIOBOL, Global.Denomination.TETROBOL]:
		var destroyable_coins = get_all_of_denomination(denom)
		if not destroyable_coins.is_empty():
			var destroy = Global.choose_one(destroyable_coins)
			destroy.queue_free()
			remove_child(destroy)
			return

func has_coin(coin: Coin) -> bool:
	return get_children().has(coin)

func shuffle() -> void:
	var all_coins = []
	for c in get_children():
		all_coins.append(c)
		remove_child(c)
	all_coins.shuffle()
	for c in all_coins:
		add_child(c)

func _update_coins() -> void:
	if get_child_count() == 0:
		return
	
	var coin_width = get_child(0).size.x - 2 #6 for left/right padding
	var start = size.x / 2.0 + 2 #center
	start -= ((get_child_count() * coin_width/2.0))
	
	# position all the coins
	for i in get_child_count():
		var coin = get_child(i)
		coin.position.x = start + (i*coin_width) - 3

func disable_interaction() -> void:
	for coin in get_children():
		coin.disable_interaction()

func enable_interaction() -> void:
	for coin in get_children():
		coin.enable_interaction()
