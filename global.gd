extends Node

const UNAFFORDABLE_COLOR = "#e12f3b"
const AFFORDABLE_COLOR = "#ffffff"

enum State {
	BOARDING, BEFORE_FLIP, AFTER_FLIP, SHOP, VOYAGE, TOLLGATE, GAME_OVER
}

signal state_changed
signal round_changed
signal souls_count_changed
signal life_count_changed
signal arrow_count_changed
signal active_coin_power_changed
signal toll_coins_changed
signal flips_this_round_changed
signal patron_changed
signal patron_uses_changed

func strain_cost() -> int:
	return floor(flips_this_round)

var power_text_source: Node
var power_text: String:
	set(val):
		power_text = val
		emit_signal("power_text_changed")
signal power_text_changed

var souls: int:
	set(val):
		souls = val
		assert(souls >= 0)
		emit_signal("souls_count_changed")

var arrows: int:
	set(val):
		arrows = val
		assert(arrows >= 0)
		emit_signal("arrow_count_changed")

var state := State.BEFORE_FLIP:
	set(val):
		state = val
		emit_signal("state_changed")

const NUM_ROUNDS = 14
var round_count:
	set(val):
		round_count = val
		emit_signal("round_changed")
		if round_count > NUM_ROUNDS:
			state = State.GAME_OVER

const LIVES_PER_ROUND = [-1, 0, 5, 5, 5, 10, 0, 10, 10, 20, 0, 15, 15, 30, 0]
var lives:
	set(val):
		lives = val
		emit_signal("life_count_changed")
		if lives < 0:
			state = State.GAME_OVER

var flips_this_round: int:
	set(val):
		flips_this_round = val
		emit_signal("flips_this_round_changed")

var patron: Patron:
	set(val):
		patron = val
		emit_signal("patron_changed")

const PATRON_USES_PER_ROUND = [-1, 0, 1, 1, 1, 2, 0, 2, 2, 3, 0, 3, 3, 5, 0]
var patron_uses: int:
	set(val):
		patron_uses = val
		emit_signal("patron_uses_changed")

const TOLLGATE_ROUNDS = [6, 10, 14]
const TOLLGATE_PRICES = [5, 10, 25]
var toll_index = 0
var toll_coins_offered := []
func add_toll_coin(coin) -> void:
	toll_coins_offered.append(coin)
	emit_signal("toll_coins_changed")

func remove_toll_coin(coin) -> void:
	toll_coins_offered.erase(coin)
	emit_signal("toll_coins_changed")
		
func calculate_toll_coin_value() -> int:
	var sum = 0
	for coin in toll_coins_offered:
		sum += coin.get_value()
	return sum

var active_coin_power_coin: CoinEntity = null
var active_coin_power:
	set(val):
		active_coin_power = val
		emit_signal("active_coin_power_changed")

const COIN_LIMIT = 8

class BossData:
	var coins
	var name
	var description
	
	func _init(bossName, bossCoins, bossDescription):
		self.coins = bossCoins
		self.name = bossName
		self.description = bossDescription

const BOSS_ROUND = 2
@onready var BOSSES = [BossData.new("Hades", [GENERIC_FAMILY, HADES_FAMILY, HADES_FAMILY], "This is a a boss!"),
			BossData.new("Cerberus I guess", [POSEIDON_FAMILY, ZEUS_FAMILY, GENERIC_FAMILY], "This is a a boss2!")]
var boss = null

enum Power {
	NONE,
	REFLIP, FREEZE, FLIP_AND_NEIGHBORS, GAIN_LIFE, GAIN_ARROW, 
	CHANGE_AND_BLURSE, REFLIP_ALL, WISDOM, UPGRADE_AND_IGNITE, RECHARGE, 
	EXCHANGE, MAKE_LUCKY, GAIN_COIN, DESTROY_FOR_LIFE,
	
	ARROW_REFLIP,
	
	PATRON_APHRODITE,
	PATRON_APOLLO,
	PATRON_ARES,
	PATRON_ARTEMIS,
	PATRON_ATHENA,
	PATRON_DEMETER,
	PATRON_DIONYSUS,
	PATRON_HADES,
	PATRON_HEPHAESTUS,
	PATRON_HERA,
	PATRON_HERMES,
	PATRON_HESTIA,
	PATRON_POSEIDON,
	PATRON_ZEUS,
	PATRON_GODLESS # used as a placeholder for the godless statue, not a real power
}

# todo - refactor this into Util
var RNG = RandomNumberGenerator.new()

# Randomly return one element of the array
func choose_one(arr: Array):
	return arr[RNG.randi_range(0, arr.size()-1)]

# Randomly return on element of the array, except the given exclude elements; returns null if impossible
func choose_one_excluding(arr: Array, exclude: Array):
	# if every element in arr is in exclude, can't be done...
	var all_excluded = true
	for elem in arr:
		if not exclude.has(elem):
			all_excluded = false
			break
	if all_excluded:
		assert(false, "excluding all elements in choose_on_excluding...")
		return null
	
	var rand_element = choose_one(arr)
	while exclude.has(rand_element):
		rand_element = choose_one(arr)
	return rand_element

# creates a delay of a given time
# await on this function call
func delay(delay_in_secs: float):
	await get_tree().create_timer(delay_in_secs).timeout

# todo - this should be in another file, PatronData I think?
class Patron:
	var god_name: String
	var token_name: String
	var description: String
	var power: Power
	var patron_statue: PackedScene
	var patron_token: PackedScene
	
	func _init(name: String, token: String, power_desc: String, pwr: Power, statue: PackedScene, tkn: PackedScene) -> void:
		self.god_name = name
		self.token_name = token
		self.description = power_desc
		self.power = pwr
		self.patron_statue = statue
		self.patron_token = tkn

var PATRONS = [
	Patron.new("[color=lightpink]Aphrodite[/color]", "[color=lightpink]Aphrodite's Heart[/color]", "Recharge every coin.", Power.PATRON_APHRODITE, preload("res://components/patron_statues/aphrodite.tscn"), preload("res://components/patron_tokens/aphrodite.tscn")),
	Patron.new("[color=orange]Apollo[/color]", "[color=orange]Apollo's Lyre[/color]", "Turn each coin to their other face.", Power.PATRON_APOLLO, preload("res://components/patron_statues/apollo.tscn"), preload("res://components/patron_tokens/apollo.tscn")),
	Patron.new("[color=indianred]Ares[/color]", "[color=indianred]Are's Spear[/color]", "Reflip all coins and remove all statuses from them.", Power.PATRON_ARES, preload("res://components/patron_statues/ares.tscn"), preload("res://components/patron_tokens/ares.tscn")),
	Patron.new("[color=purple]Artemis[/color]", "[color=purple]Artemis's Bow[/color]", "Gain 2 Arrows for each coin on heads, then turn all coins to tails.", Power.PATRON_ARTEMIS, preload("res://components/patron_statues/artemis.tscn"), preload("res://components/patron_tokens/artemis.tscn")),
	Patron.new("[color=cyan]Athena[/color]", "[color=cyan]Athena's Aegis[/color]", "Permanently reduce a coin's tails penalty by 1.", Power.PATRON_ATHENA, preload("res://components/patron_statues/athena.tscn"), preload("res://components/patron_tokens/athena.tscn")),
	Patron.new("[color=lightgreen]Demeter[/color]", "[color=lightgreen]Demeter's Wheat[/color]", "For each coin on tails, heal [img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img] equal to its tails penalty. ", Power.PATRON_DEMETER, preload("res://components/patron_statues/demeter.tscn"), preload("res://components/patron_tokens/demeter.tscn")),
	Patron.new("[color=plum]Dionysus[/color]", "[color=plum]Dionysus's Chalice[/color]", "Gain a random Obol and make it Lucky.", Power.PATRON_DIONYSUS, preload("res://components/patron_statues/dionysus.tscn"), preload("res://components/patron_tokens/dionysus.tscn")),
	Patron.new("[color=slateblue]Hades[/color]", "[color=slateblue]Hades's Bident[/color]", "Destroy a coin, then gain [img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img] and [img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img] based on its value.", Power.PATRON_HADES, preload("res://components/patron_statues/hades.tscn"), preload("res://components/patron_tokens/hades.tscn")),
	Patron.new("[color=sienna]Hephaestus[/color]", "[color=sienna]Hephaestus's Hammer[/color]", "Upgrade a coin.", Power.PATRON_HEPHAESTUS, preload("res://components/patron_statues/hephaestus.tscn"), preload("res://components/patron_tokens/hephaestus.tscn")),
	Patron.new("[color=silver]Hera[/color]", "[color=silver]Hera's Lotus[/color]", "Turn a coin and its neighbors to their other face.", Power.PATRON_HERA, preload("res://components/patron_statues/hera.tscn"), preload("res://components/patron_tokens/hera.tscn")),	
	Patron.new("[color=lightskyblue]Hermes[/color]", "[color=lightskyblue]Herme's Caduceus[/color]", "Trade a coin for another of equal or (25% of the time) greater value.", Power.PATRON_HERMES, preload("res://components/patron_statues/hermes.tscn"), preload("res://components/patron_tokens/hermes.tscn")),
	Patron.new("[color=sandybrown]Hestia[/color]", "[color=sandybrown]Hestia's Warmth[/color]", "Make a coin Lucky and Blessed.", Power.PATRON_HESTIA, preload("res://components/patron_statues/hestia.tscn"), preload("res://components/patron_tokens/hestia.tscn")),
	Patron.new("[color=lightblue]Poseidon[/color]", "[color=lightblue]Poseidon's Trident[/color]", "Freeze a coin and its neighbors.", Power.PATRON_POSEIDON, preload("res://components/patron_statues/poseidon.tscn"), preload("res://components/patron_tokens/poseidon.tscn")),
	Patron.new("[color=yellow]Zeus[/color]", "[color=yellow]Zeus's Thunderbolt[/color]", "Supercharge a coin, then reflip it.", Power.PATRON_ZEUS, preload("res://components/patron_statues/zeus.tscn"), preload("res://components/patron_tokens/zeus.tscn"))
]

func patron_for_power(power: Power) -> Patron:
	if power == Power.PATRON_GODLESS:
		return choose_one(PATRONS)
	for possible_patron in PATRONS:
		if possible_patron.power == power:
			return possible_patron
	assert(false, "Patron does not exist.")
	return null

func is_patron_power(power: Power) -> bool:
	for possible_patron in PATRONS:
		if possible_patron.power == power:
			return true
	return false

# todo - refactor this into a separate file probably; CoinInfo
enum Denomination {
	OBOL = 0, 
	DIOBOL = 1, 
	TRIOBOL = 2, 
	TETROBOL = 3
}

enum _SpriteStyle {
	GENERIC, GOD
}

class CoinFamily:
	var of_suffix: String
	var subtitle: String
	var store_price_for_denom: Array[int]
	var souls_for_denom: Array[int]
	var tails_life_loss_for_denom: Array[int]
	var power: Power
	var power_string: String
	var power_uses_for_denom: Array[int]
	var heads_icon_path: String
	var tails_icon_path: String
	var _sprite_style: _SpriteStyle
	
	func _init(suffix: String, 
			sub_title: String, prices: Array[int],
			souls_on_heads: Array[int], life_loss_on_tails: Array[int], 
			coin_power: Power, power_str: String, power_uses: Array[int],
			heads_icon: String, tails_icon: String,
			style: _SpriteStyle) -> void:
		of_suffix = suffix
		subtitle = sub_title
		store_price_for_denom = prices
		
		souls_for_denom = souls_on_heads
		tails_life_loss_for_denom = life_loss_on_tails
		
		power = coin_power
		power_string = power_str
		power_uses_for_denom = power_uses
		
		heads_icon_path = heads_icon
		tails_icon_path = tails_icon
		
		_sprite_style = style
		
		assert(FileAccess.file_exists(heads_icon_path))
		assert(FileAccess.file_exists(tails_icon_path))
	
	func get_style_string() -> String:
		match(_sprite_style):
			_SpriteStyle.GENERIC:
				return "generic"
			_SpriteStyle.GOD:
				return "god"
		breakpoint
		return ""

class Coin:
	var _coin_family: CoinFamily
	var _denomination: Denomination
	
	func _init(family: CoinFamily, denomination: Denomination):
		_coin_family = family
		_denomination = denomination
	
	func get_souls() -> int:
		return _coin_family.souls_for_denom[_denomination]
	
	func get_life_loss() -> int:
		return _coin_family.tails_life_loss_for_denom[_denomination]
	
	func get_store_price() -> int:
		return _coin_family.store_price_for_denom[_denomination]
	
	func get_sell_price() -> int:
		#breakpoint #deprecated for now
		return max(1, int(get_store_price()/3.0))
	
	func get_upgrade_price() -> int:
		match(_denomination):
			Denomination.OBOL:
				return _coin_family.store_price_for_denom[Denomination.DIOBOL] - _coin_family.store_price_for_denom[Denomination.OBOL] + 1
			Denomination.DIOBOL:
				return _coin_family.store_price_for_denom[Denomination.TRIOBOL] - _coin_family.store_price_for_denom[Denomination.DIOBOL] + 3
			Denomination.TRIOBOL:
				return _coin_family.store_price_for_denom[Denomination.TETROBOL] - _coin_family.store_price_for_denom[Denomination.TRIOBOL] + 5
			Denomination.TETROBOL:
				return 100000 #error case really
		breakpoint
		return 10000
	
	func can_upgrade() -> bool:
		return _denomination != Denomination.TETROBOL
	
	func get_power() -> Power:
		return _coin_family.power
	
	func get_power_string() -> String:
		var power_string = _coin_family.power_string
		power_string = power_string.replace("(SOULS)", str(get_souls()))
		power_string = power_string.replace("(POWER_USES)", str(get_max_power_uses()))
		power_string = power_string.replace("(HADES_MULTIPLIER)", str(get_value() * 2))
		power_string = power_string.replace("(1_PER_DENOM)", str(get_denomination_as_int()))
		power_string = power_string.replace("(1+1_PER_DENOM)", str(get_denomination_as_int() + 1))
		return power_string
	
	func get_max_power_uses() -> int:
		return _coin_family.power_uses_for_denom[_denomination]
	
	func get_denomination() -> Denomination:
		return _denomination
	
	func get_denomination_as_int() -> int:
		match(_denomination):
			Denomination.OBOL:
				return 1
			Denomination.DIOBOL:
				return 2
			Denomination.TRIOBOL:
				return 3
			Denomination.TETROBOL:
				return 4
		assert(false)
		return -9999
	
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
		assert(false)
		return "ERROR"
	
	func get_style_string() -> String:
		return _coin_family.get_style_string()
	
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

var GENERIC_FAMILY = CoinFamily.new("", "[color=gray]Common Currency[/color]", [1, 4, 10, 22], [2, 4, 7, 10], [1, 2, 3, 4], Power.NONE, "+(SOULS)[img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]", [0, 0, 0, 0], _FRAGMENT_ICON_BLUE, _FRAGMENT_ICON_RED, _SpriteStyle.GENERIC)
var ZEUS_FAMILY = CoinFamily.new(" of Zeus", "[color=yellow]Lighting Strikes[/color]", [2, 8, 20, 44], [0, 0, 0, 0], [1, 2, 3, 4], Power.REFLIP, "Reflip a coin.", [2, 3, 4, 5], _ZEUS_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var HERA_FAMILY = CoinFamily.new(" of Hera", "[color=silver]Envious Wrath[/color]", [2, 8, 20, 44], [0, 0, 0, 0], [1, 2, 3, 4], Power.FLIP_AND_NEIGHBORS, "Reflip and coin and its neighbors.", [1, 2, 3, 4], _HERA_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var POSEIDON_FAMILY = CoinFamily.new(" of Poseidon", "[color=lightblue]Wave of Ice[/color]", [2, 8, 20, 44], [0, 0, 0, 0], [1, 2, 3, 4], Power.FREEZE, "Freeze another coin.", [1, 2, 3, 4], _POSEIDON_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var DEMETER_FAMILY = CoinFamily.new(" of Demeter", "[color=lightgreen]Grow Ever Stronger[/color]", [2, 8, 20, 44], [0, 0, 0, 0], [1, 2, 3, 4], Power.GAIN_LIFE, "+(1+1_PER_DENOM)[img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img]", [1, 1, 1, 1], _DEMETER_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var APOLLO_FAMILY = CoinFamily.new(" of Apollo", "[color=orange]Harmonic, Melodic[/color]", [2, 8, 20, 44], [0, 0, 0, 0], [1, 2, 3, 4], Power.CHANGE_AND_BLURSE, "Turn a coin to its other face. Then, if it's [img=10x13]res://assets/icons/heads_icon.png[/img], Curse it, if [img=10x13]res://assets/icons/tails_icon.png[/img] Bless it.", [1, 2, 3, 4], _APOLLO_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var ARTEMIS_FAMILY = CoinFamily.new(" of Artemis", "[color=purple]Arrows of Night[/color]", [2, 8, 20, 44], [0, 0, 0, 0], [1, 2, 3, 4], Power.GAIN_ARROW, "+(POWER_USES) Arrow(s).\n(Arrows can be used to reflip coins.)", [1, 2, 3, 4], _ARTEMIS_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var ARES_FAMILY = CoinFamily.new(" of Ares", "[color=indianred]Chaos of War[/color]", [3, 12, 30, 66], [0, 0, 0, 0], [1, 2, 3, 4], Power.REFLIP_ALL, "Reflip ALL coins.", [1, 2, 3, 4], _ARES_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var ATHENA_FAMILY = CoinFamily.new(" of Athena", "[color=cyan]Phalanx Strategy[/color]", [2, 8, 20, 44], [0, 0, 0, 0], [1, 2, 3, 4], Power.WISDOM, "Reduce another coin's [img=10x13]res://assets/icons/tails_icon.png[/img] [img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img] penalty this round.", [1, 2, 3, 4], _ATHENA_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var HEPHAESTUS_FAMILY = CoinFamily.new(" of Hephaestus", "[color=sienna]Forged in Fire[/color]", [4, 16, 40, 88], [0, 0, 0, 0], [1, 2, 3, 4], Power.UPGRADE_AND_IGNITE, "Upgrade another coin and Ignite it.", [1, 2, 3, 4], _HEPHAESTUS_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var APHRODITE_FAMILY = CoinFamily.new(" of Aphrodite", "[color=lightpink]A Moment of Warmth[/color]", [2, 8, 20, 44], [0, 0, 0, 0], [1, 2, 3, 4], Power.RECHARGE, "Recharge another coin's power.", [1, 2, 3, 4], _APHRODITE_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var HERMES_FAMILY = CoinFamily.new(" of Hermes", "[color=lightskyblue]From Lands Distant[/color]", [2, 8, 20, 44], [0, 0, 0, 0], [1, 2, 3, 4], Power.EXCHANGE, "Trade a coin for another of equal value.", [1, 2, 3, 4], _HERMES_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var HESTIA_FAMILY = CoinFamily.new(" of Hestia", "[color=sandybrown]Weary Bones Rest[/color]", [1, 4, 10, 22], [0, 0, 0, 0], [1, 2, 3, 4], Power.MAKE_LUCKY, "Make another coin Lucky.", [1, 2, 3, 4], _HESTIA_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var DIONYSUS_FAMILY = CoinFamily.new(" of Dionysus", "[color=plum]Wanton Revelry[/color]", [2, 8, 20, 44], [0, 0, 0, 0], [1, 2, 3, 4], Power.GAIN_COIN, "Gain a random Obol.", [1, 2, 3, 4], _DIONYSUS_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)
var HADES_FAMILY = CoinFamily.new(" of Hades", "[color=slateblue]Beyond the Pale[/color]", [1, 4, 10, 22], [0, 0, 0, 0], [1, 2, 3, 4], Power.DESTROY_FOR_LIFE, "Destroy a coin and heal [img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img] equal to (HADES_MULTIPLIER)x that coin's value.", [1, 1, 1, 1], _HADES_ICON, _FRAGMENT_ICON_RED, _SpriteStyle.GOD)

var _GOD_FAMILIES = [ZEUS_FAMILY, HERA_FAMILY, POSEIDON_FAMILY, DEMETER_FAMILY, APOLLO_FAMILY, ARTEMIS_FAMILY,
		ARES_FAMILY, ATHENA_FAMILY, HEPHAESTUS_FAMILY, APHRODITE_FAMILY, HERMES_FAMILY, HESTIA_FAMILY, DIONYSUS_FAMILY, HADES_FAMILY]

func random_family() -> CoinFamily:
	return choose_one([GENERIC_FAMILY] + _GOD_FAMILIES)

func random_god_family() -> CoinFamily:
	return choose_one(_GOD_FAMILIES)

func random_shop_denomination_for_round() -> Denomination:
	# B 1 2 3 4 T 5 6 7 T  8  9  10 T
	# 1 2 3 4 5 6 7 8 9 10 11 12 13 14
	if Global.round_count <= 3: #rounds 1-2
		return Denomination.OBOL
	elif Global.round_count <= 7: #rounds 3-5
		return choose_one([Denomination.OBOL, Denomination.DIOBOL])
	elif Global.round_count == 11: #rounds 6-8
		return choose_one([Denomination.DIOBOL, Denomination.TRIOBOL])
	else:
		return choose_one([Denomination.TRIOBOL, Denomination.TETROBOL])

func make_coin(family: CoinFamily, denomination: Denomination) -> Coin:
	return Coin.new(family, denomination)
