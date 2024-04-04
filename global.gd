extends Node

enum State {
	BEFORE_FLIP, AFTER_FLIP, SHOP, GAME_OVER
}

signal state_changed
signal round_changed
signal fragments_count_changed
signal life_count_changed
signal arrow_count_changed
signal active_coin_power_changed

signal warning
func show_warning(warning_str: String) -> void:
	emit_signal("warning", warning_str)

var power_text_source: Node
var power_text: String:
	set(val):
		power_text = val
		emit_signal("power_text_changed")
signal power_text_changed

var fragments: int:
	set(val):
		fragments = val
		assert(fragments >= 0)
		emit_signal("fragments_count_changed")

var arrows: int:
	set(val):
		arrows = val
		assert(arrows >= 0)
		emit_signal("arrow_count_changed")

var state := State.BEFORE_FLIP:
	set(val):
		state = val
		emit_signal("state_changed")

const NUM_ROUNDS = 5
var round_count:
	set(val):
		round_count = val
		emit_signal("round_changed")
		if round_count > NUM_ROUNDS:
			state = State.GAME_OVER

const LIVES_PER_ROUND = [-1, 3, 5, 8, 10, 13]
var lives:
	set(val):
		lives = val
		emit_signal("life_count_changed")
		if lives < 0:
			state = State.GAME_OVER


const GOAL_COIN_VALUE = 20
var coin_value:
	set(val):
		coin_value = val
		if coin_value >= GOAL_COIN_VALUE:
			state = State.GAME_OVER


var active_coin_power_coin: CoinEntity = null
var active_coin_power:
	set(val):
		active_coin_power = val
		emit_signal("active_coin_power_changed")

const COIN_LIMIT = 8


# refactor this into Util
var RNG = RandomNumberGenerator.new()

func choose_one(arr: Array):
	return arr[RNG.randi_range(0, arr.size()-1)]

# creates a delay of a given time
# await on this function call
func delay(delay_in_secs: float):
	await get_tree().create_timer(delay_in_secs).timeout







# todo - refactor this into a separate file probably; CoinInfo

enum Denomination {
	OBOL = 0, 
	DIOBOL = 1, 
	TRIOBOL = 2, 
	TETROBOL = 3
}

enum Power {
	NONE,
	REFLIP, LOCK, FLIP_AND_NEIGHBORS, GAIN_LIFE, GAIN_ARROW, CHANGE_AND_BLURSE, REFLIP_ALL, WISDOM, FORGE, RECHARGE, EXCHANGE, BLESS, GAIN_COIN, DESTROY,
	ARROW_REFLIP
}

class CoinFamily:
	var of_suffix: String
	var subtitle: String
	var store_price_for_denom: Array[int]
	var heads_fragments_for_denom: Array[int]
	var tails_life_loss_for_denom: Array[int]
	var power: Power
	var power_string: String
	var power_uses_for_denom: Array[int]
	var heads_icon_path: String
	var tails_icon_path: String
	
	func _init(suffix: String, 
			sub_title: String, prices: Array[int],
			fragments_on_heads: Array[int], life_loss_on_tails: Array[int], 
			coin_power: Power, power_str: String, power_uses: Array[int],
			heads_icon: String, tails_icon: String) -> void:
		of_suffix = suffix
		subtitle = sub_title
		store_price_for_denom = prices
		
		heads_fragments_for_denom = fragments_on_heads
		tails_life_loss_for_denom = life_loss_on_tails
		
		power = coin_power
		power_string = power_str
		power_uses_for_denom = power_uses
		
		heads_icon_path = heads_icon
		tails_icon_path = tails_icon
		
		assert(FileAccess.file_exists(heads_icon_path))
		assert(FileAccess.file_exists(tails_icon_path))

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
	
	func get_sell_price() -> int:
		return max(1, int(get_store_price()/3.0))
	
	func get_power() -> Power:
		return _coin_family.power
	
	func get_power_string() -> String:
		return _coin_family.power_string
	
	func get_max_power_uses() -> int:
		return _coin_family.power_uses_for_denom[_denomination]
	
	func get_denomination() -> Denomination:
		return _denomination
	
	func get_subtitle() -> String:
		return _coin_family.subtitle
	
	func get_heads_icon_path() -> String:
		return _coin_family.heads_icon_path
	
	func get_tails_icon_path() -> String:
		return _coin_family.tails_icon_path
	
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
	
	func upgrade_denomination() -> void:
		assert(_denomination != Denomination.TETROBOL)
		match(_denomination):
			Denomination.OBOL:
				_denomination = Denomination.DIOBOL
			Denomination.DIOBOL:
				_denomination = Denomination.TRIOBOL
			Denomination.TRIOBOL:
				_denomination = Denomination.TETROBOL

var _FRAGMENT_ICON_BLUE = "res://assets/icons/soul_fragment_blue_icon.png"
var _FRAGMENT_ICON_RED = "res://assets/icons/soul_fragment_red_icon.png"
var _ZEUS_ICON = "res://assets/icons/zeus_icon.png"
var _HERA_ICON = "res://assets/icons/hera_icon.png"
var _POSEIDON_ICON = "res://assets/icons/poseidon_icon.png"
var _DEMETER_ICON = "res://assets/icons/demeter_icon.png"
var _APOLLO_ICON = "res://assets/icons/apollo_icon.png"
var _ARTEMIS_ICON = "res://assets/icons/artemis_icon.png"
var _ARES_ICON = "res://assets/icons/ares_icon.png"
var _ATHENA_ICON = "res://assets/icons/athena_icon.png"
var _HEPHAESTUS_ICON = "res://assets/icons/hephaestus_icon.png"
var _APHRODITE_ICON = "res://assets/icons/aphrodite_icon.png"
var _HERMES_ICON = "res://assets/icons/hermes_icon.png"
var _HESTIA_ICON = "res://assets/icons/hestia_icon.png"
var _DIONYSUS_ICON = "res://assets/icons/dionysus_icon.png"
var _HADES_ICON = "res://assets/icons/hades_icon.png"

var GENERIC_FAMILY = CoinFamily.new("", "Common Currency", [1, 4, 9, 16], [1, 3, 8, 13], [1, 2, 3, 4], Power.NONE, "Gain souls.", [0, 0, 0, 0], _FRAGMENT_ICON_BLUE, _FRAGMENT_ICON_RED)
var ZEUS_FAMILY = CoinFamily.new(" of Zeus", "Lighting Strikes", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.REFLIP, "Reflip a coin.", [2, 3, 4, 5], _ZEUS_ICON, _FRAGMENT_ICON_RED)
var HERA_FAMILY = CoinFamily.new(" of Hera", "Envious Chains", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.LOCK, "Lock a coin, preventing it from flipping.", [1, 2, 3, 4], _HERA_ICON, _FRAGMENT_ICON_RED)
var POSEIDON_FAMILY = CoinFamily.new(" of Poseidon", "Shake the Earth", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.FLIP_AND_NEIGHBORS, "Reflip a coin and its neighbors.", [1, 2, 3, 4], _POSEIDON_ICON, _FRAGMENT_ICON_RED)
var DEMETER_FAMILY = CoinFamily.new(" of Demeter", "Grow Ever Stronger", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.GAIN_LIFE, "Restores life.", [1, 2, 3, 4], _DEMETER_ICON, _FRAGMENT_ICON_RED)
var APOLLO_FAMILY = CoinFamily.new(" of Apollo", "Arrow of Light", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.GAIN_ARROW, "Gain an Arrow of Light.", [1, 2, 3, 4], _APOLLO_ICON, _FRAGMENT_ICON_RED)
var ARTEMIS_FAMILY = CoinFamily.new(" of Artemis", "Moonlit Ritual", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.CHANGE_AND_BLURSE, "Swap heads to tails or vice versa, but...", [1, 2, 3, 4], _ARTEMIS_ICON, _FRAGMENT_ICON_RED)
var ARES_FAMILY = CoinFamily.new(" of Ares", "Chaos of War", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.REFLIP_ALL, "Reflip ALL other coins.", [3, 4, 5, 6], _ARES_ICON, _FRAGMENT_ICON_RED)
var ATHENA_FAMILY = CoinFamily.new(" of Athena", "Phalanx Strategy", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.WISDOM, "Reduce a coin's tails life loss.", [1, 2, 3, 4], _ATHENA_ICON, _FRAGMENT_ICON_RED)
var HEPHAESTUS_FAMILY = CoinFamily.new(" of Hephaestus", "Forged in Fire", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.FORGE, "Upgrade a coin's value.", [1, 2, 3, 4], _HEPHAESTUS_ICON, _FRAGMENT_ICON_RED)
var APHRODITE_FAMILY = CoinFamily.new(" of Aphrodite", "A Moment of Warmth", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.RECHARGE, "Recharge a coin's power.", [1, 2, 3, 4], _APHRODITE_ICON, _FRAGMENT_ICON_RED)
var HERMES_FAMILY = CoinFamily.new(" of Hermes", "From Lands Distant", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.EXCHANGE, "Trade a coin for another of equal value.", [1, 2, 3, 4], _HERMES_ICON, _FRAGMENT_ICON_RED)
var HESTIA_FAMILY = CoinFamily.new(" of Hestia", "Weary Bones Rest", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.BLESS, "Bless a coin.", [1, 2, 3, 4], _HESTIA_ICON, _FRAGMENT_ICON_RED)
var DIONYSUS_FAMILY = CoinFamily.new(" of Dionysus", "Wanton Revelry", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.GAIN_COIN, "Gain a random coin.", [1, 1, 1, 1], _DIONYSUS_ICON, _FRAGMENT_ICON_RED)
var HADES_FAMILY = CoinFamily.new(" of Hades", "Beyond the Pale", [2, 8, 18, 32], [0, 0, 0, 0], [1, 2, 3, 4], Power.DESTROY, "Destroy a coin and gain souls.", [1, 1, 1, 1], _HADES_ICON, _FRAGMENT_ICON_RED)

var _GOD_FAMILIES = [ZEUS_FAMILY, HERA_FAMILY, POSEIDON_FAMILY, DEMETER_FAMILY, APOLLO_FAMILY, ARTEMIS_FAMILY,
		ARES_FAMILY, ATHENA_FAMILY, HEPHAESTUS_FAMILY, APHRODITE_FAMILY, HERMES_FAMILY, HESTIA_FAMILY, DIONYSUS_FAMILY, HADES_FAMILY]

func random_family() -> CoinFamily:
	return choose_one([GENERIC_FAMILY] + _GOD_FAMILIES)

func random_god_family() -> CoinFamily:
	return choose_one(_GOD_FAMILIES)

func random_shop_denomination_for_round() -> Denomination:
	if Global.round_count == 1:
		return Denomination.OBOL
	elif Global.round_count == 2:
		return choose_one([Denomination.OBOL, Denomination.DIOBOL])
	elif Global.round_count == 3:
		return choose_one([Denomination.OBOL, Denomination.DIOBOL, Denomination.TRIOBOL])
	elif Global.round_count == 4:
		return choose_one([Denomination.OBOL, Denomination.DIOBOL, Denomination.TRIOBOL, Denomination.TETROBOL])
	else:
		return choose_one([Denomination.DIOBOL, Denomination.TRIOBOL, Denomination.TETROBOL])

func make_coin(family: CoinFamily, denomination: Denomination) -> Coin:
	return Coin.new(family, denomination)
