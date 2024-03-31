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
	NONE,
	REFLIP, LOCK, FLIP_AND_NEIGHBORS, GAIN_LIFE, GAIN_ARROW, CHANGE_AND_BLURSE, REFLIP_ALL, REDUCE_LOSS, FORGE, RECHARGE, EXCHANGE, BLESS, GAIN_COIN, DESTROY,
	ARROW_REFLIP
}

class CoinFamily:
	var of_suffix: String
	var store_subtitle: String
	var store_price_for_denom: Array[int]
	var heads_fragments_for_denom: Array[int]
	var tails_life_loss_for_denom: Array[int]
	var power: Power
	var power_string: String
	var power_uses_for_denom: Array[int]
	
	func _init(suffix: String, 
			subtitle: String, prices: Array[int],
			fragments_on_heads: Array[int], life_loss_on_tails: Array[int], 
			coin_power: Power, power_str: String, power_uses: Array[int]) -> void:
		of_suffix = suffix
		store_subtitle = subtitle
		store_price_for_denom = prices
		
		heads_fragments_for_denom = fragments_on_heads
		tails_life_loss_for_denom = life_loss_on_tails
		
		power = coin_power
		power_string = power_str
		power_uses_for_denom = power_uses

class Coin:
	var _coin_family: CoinFamily
	var _denomination: Denomination
	
	func _init(family: CoinFamily, denomination: Denomination):
		_coin_family = family
		_denomination = denomination
	
	func get_fragments() -> int:
		return _coin_family.heads_fragments_for_denom[_denomination]
	
	func get_life_loss() -> int:
		return _coin_family.tails_life_loss_for_denom[_denomination]
	
	func get_store_price() -> int:
		return _coin_family.store_price_for_denom[_denomination]
	
	func get_power() -> Power:
		return _coin_family.power
	
	func get_power_string() -> String:
		return _coin_family.power_string
	
	func get_max_power_uses() -> int:
		return _coin_family.power_uses_for_denom[_denomination]
	
	func get_store_subtitle() -> String:
		return _coin_family.store_subtitle
	
	const _STORE_DESCRIPTION_FORMAT = "Heads: %s\nTails: %s"
	func get_store_description() -> String:
		var heads_effect = "Nothing happens."
		var tails_effect = "Nothing happens."
		
		if get_fragments() != 0:
			assert(_coin_family.power == Power.NONE)
			heads_effect = "+%d Frags" % get_fragments()
		else:
			heads_effect = "%d %s" % [get_max_power_uses(), get_power_string()]
			
		
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

var GENERIC_FAMILY = CoinFamily.new("", "Common Currency", [1, 4, 9, 16], [1, 3, 8, 13], [1, 2, 3, 4], Power.NONE, "No Power", [0, 0, 0, 0])
var ZEUS_FAMILY = CoinFamily.new(" of Zeus", "Bolt of Lightning", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.REFLIP, "Reflip", [2, 3, 4, 5])
var HERA_FAMILY = CoinFamily.new(" of Hera", "Jealous Chains", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.LOCK, "Lock", [1, 2, 3, 4])
var POSEIDON_FAMILY = CoinFamily.new(" of Poseidon", "Rattle the Earth", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.FLIP_AND_NEIGHBORS, "Quake", [1, 2, 3, 4])
var DEMETER_FAMILY = CoinFamily.new(" of Demeter", "Grow Ever Higher", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.GAIN_LIFE, "Revitalize", [1, 2, 3, 4])
var APOLLO_FAMILY = CoinFamily.new(" of Apollo", "Arrow of Light", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.GAIN_ARROW, "Arrow", [1, 2, 3, 4])
var ARTEMIS_FAMILY = CoinFamily.new(" of Artemis", "The Wild Moon", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.CHANGE_AND_BLURSE, "Harmony", [1, 2, 3, 4])
var ARES_FAMILY = CoinFamily.new(" of Ares", "Chaos of War", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.REFLIP_ALL, "War", [3, 4, 5, 6])
var ATHENA_FAMILY = CoinFamily.new(" of Athena", "Patience, and Wisdom", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.REDUCE_LOSS, "Wisdom", [1, 2, 3, 4])
var HEPHAESTUS_FAMILY = CoinFamily.new(" of Hephaestus", "Forged in Fire", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.FORGE, "Forge", [1, 2, 3, 4])
var APHRODITE_FAMILY = CoinFamily.new(" of Aphrodite", "Moment of Warmth", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.RECHARGE, "Recharge", [1, 2, 3, 4])
var HERMES_FAMILY = CoinFamily.new(" of Hermes", "From Distant Lands", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.EXCHANGE, "Exchange", [1, 2, 3, 4])
var HESTIA_FAMILY = CoinFamily.new(" of Hestia", "A Comforting Hearth", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.BLESS, "Bless", [1, 2, 3, 4])
var DIONYSUS_FAMILY = CoinFamily.new(" of Dionysus", "Baleful Revelry", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.GAIN_COIN, "Offering", [1, 2, 3, 4])
var HADES_FAMILY = CoinFamily.new(" of Hades", "Beyond the Pale", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.DESTROY, "Destroy", [1, 2, 3, 4])

func random_god_coin_type() -> CoinFamily:
	return choose_one([ZEUS_FAMILY, HERA_FAMILY, POSEIDON_FAMILY, DEMETER_FAMILY, APOLLO_FAMILY, ARTEMIS_FAMILY,
		ARES_FAMILY, ATHENA_FAMILY, HEPHAESTUS_FAMILY, APHRODITE_FAMILY, HERMES_FAMILY, HESTIA_FAMILY, DIONYSUS_FAMILY, HADES_FAMILY])

func random_shop_denomination() -> Denomination:
	return choose_one([Denomination.OBOL, Denomination.DIOBOL, Denomination.TRIOBOL])

func make_coin(family: CoinFamily, denomination: Denomination) -> Coin:
	return Coin.new(family, denomination)
