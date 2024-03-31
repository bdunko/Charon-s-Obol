extends Node

var RNG = RandomNumberGenerator.new()

func choose_one(arr: Array):
	return arr[RNG.randi_range(0, arr.size()-1)]

enum Denomination {
	OBOL = 0, 
	DIOBOL = 1, 
	TRIOBOL = 2, 
	TETROBOL = 3
}

enum Power {
	NONE
}

enum CoinType {
	GENERIC
}

class _CoinFamily:
	var of_suffix
	var store_subtitle
	var store_price_for_denom: Array[int]
	var heads_fragments_for_denom: Array[int]
	var tails_life_loss_for_denom: Array[int]
	var power: Power
	var power_uses_for_denom: Array[int]
	
	func _init(suffix: String, 
			subtitle: String, prices: Array[int],
			fragments_on_heads: Array[int], life_loss_on_tails: Array[int], 
			coin_power: Power, power_uses: Array[int]) -> void:
		of_suffix = suffix
		store_subtitle = subtitle
		store_price_for_denom = prices
		
		heads_fragments_for_denom = fragments_on_heads
		tails_life_loss_for_denom = life_loss_on_tails
		
		power = coin_power
		power_uses_for_denom = power_uses

class Coin:
	var _coin_family: _CoinFamily
	var _denomination: Denomination
	
	func _init(family: _CoinFamily, denomination: Denomination):
		_coin_family = family
		_denomination = denomination
	
	func get_fragments() -> int:
		return _coin_family.heads_fragments_for_denom[_denomination]
	
	func get_life_loss() -> int:
		return _coin_family.tails_life_loss_for_denom[_denomination]
	
	func get_store_price() -> int:
		return _coin_family.store_price_for_denom[_denomination]
	
	func get_store_subtitle() -> String:
		return _coin_family.store_subtitle
	
	const _STORE_DESCRIPTION_FORMAT = "Heads - %s\nTails - %s"
	func get_store_description() -> String:
		var heads_effect = "Nothing happens."
		var tails_effect = "Nothing happens."
		
		if get_fragments() != 0:
			heads_effect = "+%d Frags" % get_fragments()
		#todo - powers
		
		if get_life_loss() != 0:
			tails_effect = "-%d Life" % get_life_loss()
		
		return _STORE_DESCRIPTION_FORMAT % [heads_effect, tails_effect]
	
	func get_name() -> String:
		match(_denomination):
			Denomination.OBOL:
				return "Obol%s" % _coin_family.of_suffix
			Denomination.DIOBOL:
				return "Diobol%s" % _coin_family.of_suffix
			Denomination.TRIOBOL:
				return "Triobol%s" % _coin_family.of_suffix
			Denomination.TETROBOL:
				return "Tetrobol%s" % _coin_family.of_suffix
		return "ERROR"
	
	func get_value() -> int:
		match(_denomination):
			Denomination.OBOL:
				return 1
			Denomination.DIOBOL:
				return 2
			Denomination.TRIOBOL:
				return 3
			Denomination.TETROBOL:
				return 4
		return 0

var _GENERIC_FAMILY = _CoinFamily.new("", "Common Currency", [1, 4, 9, 16], [1, 3, 8, 13], [1, 2, 3, 4], Power.NONE, [0, 0, 0, 0])


func random_coin_type():
	return choose_one([CoinType.GENERIC])

func random_denomination():
	return choose_one([Denomination.OBOL, Denomination.DIOBOL, Denomination.TRIOBOL, Denomination.TETROBOL])

func make_coin(type: CoinType, denomination: Denomination) -> Coin:
	match(type):
		CoinType.GENERIC:
			return Coin.new(_GENERIC_FAMILY, denomination)
	breakpoint
	return null
