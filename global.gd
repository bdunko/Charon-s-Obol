extends Node

signal state_changed
signal round_changed
signal souls_count_changed
signal life_count_changed
signal arrow_count_changed
signal active_coin_power_family_changed
signal toll_coins_changed
signal flips_this_round_changed
signal strain_changed
signal patron_changed
signal patron_uses_changed
signal rerolls_changed

var character: Character

enum Character {
	ELEUSINIAN, LADY
}

var difficulty: Difficulty

enum Difficulty {
	INDIFFERENT, HOSTILE, VENGEFUL, CRUEL, UNFAIR
}

func difficulty_tooltip_for(diff: Difficulty) -> String:
	#todo - fill these description with colors too
	match diff:
		Difficulty.INDIFFERENT:
			return "Charon is Indifferent\nThe regular difficulty."
		Difficulty.HOSTILE:
			return "Charon is Hostile\nCharon will occasionally unleash his Malice."
		Difficulty.VENGEFUL:
			return "Charon is Vengeful\nEach Trial has two modifiers.\nThe Nemesis is more powerful."
		Difficulty.CRUEL:
			return "Charon is Cruel\nTollgates are more expensive.\nCoins purchasable in the Shop may have negative statuses."
		Difficulty.UNFAIR:
			return "Charon is Unfair\nYour coins will land on tails 10% more often.\nCharon's Malice is more targeted.\nYou cannot view future Trials until completing the previous one."
	assert(false, "shouldn't happen..")
	return ""

enum State {
	BOARDING, BEFORE_FLIP, AFTER_FLIP, SHOP, VOYAGE, TOLLGATE, GAME_OVER
}

func reroll_cost() -> int:
	return (1+shop_rerolls) * (1+shop_rerolls)

var shop_rerolls: int:
	set(val):
		shop_rerolls = val
		assert(shop_rerolls >= 0)
		emit_signal("rerolls_changed")

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

var round_count:
	set(val):
		round_count = val
		emit_signal("round_changed")

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
		emit_signal("strain_changed")

var strain_modifier: int:
	set(val):
		strain_modifier = val
		emit_signal("strain_changed")

# returns the life cost of a toss; min 0
func strain_cost() -> int:
	return max(0, flips_this_round + strain_modifier)

var patron: Patron:
	set(val):
		patron = val
		emit_signal("patron_changed")

const PATRON_USES_PER_ROUND = [-1, 0, 1, 1, 1, 2, 0, 2, 2, 3, 0, 3, 3, 5, 0]
var patron_uses: int:
	set(val):
		patron_uses = val
		emit_signal("patron_uses_changed")

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

var active_coin_power_coin: Coin = null
var active_coin_power_family: PowerFamily:
	set(val):
		active_coin_power_family = val
		emit_signal("active_coin_power_family_changed")

const COIN_LIMIT = 8

enum RoundType {
	BOARDING, NORMAL, TRIAL1, TRIAL2, NEMESIS, TOLLGATE, END
}

class Round:
	var roundType: RoundType
	var lifeRegen: int
	var shopDenoms: Array
	var tollCost: int
	var trialData: TrialData
	
	func _init(roundTyp: RoundType, lifeRegn: int, shopDenms: Array, tollCst: int, triData: TrialData):
		self.roundType = roundTyp
		self.lifeRegen = lifeRegn
		self.shopDenoms = shopDenms
		self.tollCost = tollCst
		self.trialData = triData

var _VOYAGE = [
	Round.new(RoundType.BOARDING, 0, [Denomination.OBOL], 0, null),
	Round.new(RoundType.NORMAL, 5, [Denomination.OBOL], 0, null),
	Round.new(RoundType.NORMAL, 6, [Denomination.OBOL], 0, null),
	Round.new(RoundType.NORMAL, 7, [Denomination.OBOL, Denomination.DIOBOL], 0, null),
	Round.new(RoundType.TRIAL1, 10, [Denomination.OBOL, Denomination.DIOBOL], 0, null),
	Round.new(RoundType.TOLLGATE, 0, [], 5, null),
	Round.new(RoundType.NORMAL, 10, [Denomination.OBOL, Denomination.DIOBOL], 0, null),
	Round.new(RoundType.NORMAL, 10, [Denomination.DIOBOL], 0, null),
	Round.new(RoundType.TRIAL2, 20, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, null),
	Round.new(RoundType.TOLLGATE, 0, [], 10, null),
	Round.new(RoundType.NORMAL, 20, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, null),
	Round.new(RoundType.NORMAL, 20, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, null),
	Round.new(RoundType.NEMESIS, 30, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, null),
	Round.new(RoundType.TOLLGATE, 0, [], 25, null),
	Round.new(RoundType.END, 0, [], 0, null)
]

func randomize_voyage() -> void:
	for rnd in _VOYAGE:
		match(rnd.roundType):
			RoundType.TRIAL1:
				rnd.trialData = Global.choose_one(LV1_TRIALS)
			RoundType.TRIAL2:
				rnd.trialData = Global.choose_one(LV2_TRIALS)
			RoundType.NEMESIS:
				rnd.trialData = Global.choose_one(NEMESES)

func voyage_length() -> int:
	return _VOYAGE.size()

func current_round_type() -> RoundType:
	return _VOYAGE[round_count-1].roundType

func current_round_life_regen() -> int:
	return _VOYAGE[round_count-1].lifeRegen

func current_round_toll() -> int:
	return _VOYAGE[round_count-1].tollCost

func _current_round_shop_denoms() -> Array:
	return _VOYAGE[round_count-1].shopDenoms

func current_round_trial() -> TrialData:
	return _VOYAGE[round_count-1].trialData

func get_trial1() -> TrialData:
	return _get_first_round_of_type(RoundType.TRIAL1)

func get_trial2() -> TrialData:
	return _get_first_round_of_type(RoundType.TRIAL2)

func get_nemesis() -> TrialData:
	return _get_first_round_of_type(RoundType.NEMESIS)

func get_tollgate_cost(tollgateIndex: int) -> int:
	var tollgates = 0
	for rnd in _VOYAGE:
		if rnd.roundType == RoundType.TOLLGATE:
			tollgates += 1
			if tollgates == tollgateIndex:
				return rnd.tollCost
	return 0

func _get_first_round_of_type(roundType: RoundType) -> TrialData:
	for rnd in _VOYAGE:
		if rnd.roundType == roundType:
			return rnd.trialData
	return null

class TrialData:
	var coins
	var name
	var description
	
	func _init(trialName, trialCoins, trialDescription):
		self.name = trialName
		self.coins = trialCoins
		self.description = trialDescription

@onready var NEMESES = [
	TrialData.new("[color=lightgreen]The Gorgon Sisters[/color]", [EURYALE_FAMILY, MEDUSA_FAMILY, STHENO_FAMILY], "These three sisters will render you helpless with their petrifying gaze.")
]

@onready var LV1_TRIALS = [
	TrialData.new("[color=gray]Iron[/color]", [TRIAL_IRON_FAMILY], "When the trial begins, you gain 3 Obols of Thorns. (If not enough space, destroy coins until there is.)"),
	TrialData.new("Misfortune", [GENERIC_FAMILY], "When the trial begins, all your coins become Unlucky."),
	TrialData.new("Fossilization", [GENERIC_FAMILY], "When the trial begins, your highest value coin is turned to Stone."),
	TrialData.new("Polarization", [GENERIC_FAMILY], "Diobols are Blank."),
	TrialData.new("Silence", [GENERIC_FAMILY], "Your leftmost 2 coins are Blank."),
	TrialData.new("Silence", [GENERIC_FAMILY], "Your rightmost 2 coins are Blank."),
	TrialData.new("Exhaustion", [GENERIC_FAMILY], "Every 3 payoffs, your lowest value coin is destroyed."),
	TrialData.new("Equivalence", [GENERIC_FAMILY], "After payoff, Bless each coin on tails and Curse each coin on heads."),
	TrialData.new("Pain", [GENERIC_FAMILY], "Damage you take from tails penalties is tripled."),
	TrialData.new("Blood", [GENERIC_FAMILY], "Activating a power costs 1 life."),
	TrialData.new("Draining", [GENERIC_FAMILY], "Using a power also drains a charge from each adjacent coin."),
	TrialData.new("Suffering", [GENERIC_FAMILY], "Strain starts at 4."),
	TrialData.new("Restraint", [GENERIC_FAMILY], "After using a coin's power, that coin becomes Locked."),
]

@onready var LV2_TRIALS = [
	TrialData.new("Famine", [GENERIC_FAMILY], "Life does not replenish at the start of the this round."),
	TrialData.new("Vainglory", [GENERIC_FAMILY], "When the trial begins, your Obols and Diobols are destroyed."),
	TrialData.new("Torture", [GENERIC_FAMILY], "After payoff, downgrade the highest value coin."),
	TrialData.new("Petrification", [GENERIC_FAMILY], "When the trial begins, your two highest value coins are turned to Stone."),
	TrialData.new("Fate", [GENERIC_FAMILY], "Coins cannot be reflipped by powers."),
	TrialData.new("Limitation", [GENERIC_FAMILY], "During payoff, each coin may earn no more than 3 Souls."),
	TrialData.new("Gating", [GENERIC_FAMILY], "During payoff, any coin which earns fewer than 10 Souls earns 0 instead."),
	TrialData.new("Impatience", [GENERIC_FAMILY], "You must perform exactly 3 total tosses this round."),
	TrialData.new("Flames", [GENERIC_FAMILY], "When the trial begins, all your coins Ignite."),
	TrialData.new("Malaise", [GENERIC_FAMILY], "After payoff, your leftmost non-Blank coin becomes Blank."),
	
	# todo - rename to poverty and redo icon
	TrialData.new("Resistance", [GENERIC_FAMILY], "Your payoff coins land on tails 90% of the time."),
	TrialData.new("Collapse", [GENERIC_FAMILY], "After payoff, each coin on tails becomes Cursed and Frozen."),
	TrialData.new("Chaos", [GENERIC_FAMILY], "All coin powers have random targets when activated."),
	TrialData.new("Overload", [GENERIC_FAMILY], "After payoff, you lose 1 life for each unused power charge on a heads coin."),
	TrialData.new("Sapping", [GENERIC_FAMILY], "Coins replenish only a single charge each toss."),
	TrialData.new("Singularity", [GENERIC_FAMILY], "Every power coin has only a single charge."),
	TrialData.new("Recklessness", [GENERIC_FAMILY], "You cannot end the round until your life is 5 or fewer."),
	TrialData.new("Adversity", [GENERIC_FAMILY], "Gain a random permanent Monster coin. (If not enough space, destroy coins until there is.)"),
	TrialData.new("Fury", [GENERIC_FAMILY], "Charon's Malice increases 3 times as fast."),
	TrialData.new("Chains", [GENERIC_FAMILY], "When the trial begins, each of your non-payoff coins becomes Locked."),
	TrialData.new("Transfiguration", [GENERIC_FAMILY], "When the trial begins, 3 of your non-payoff coins are randomly transformed into different coins of the same value."),
	
	# unused idea
	#TrialData.new("Balance", [GENERIC_FAMILY], "After payoff, each coin on heads becomes Unlucky."),
]

enum PowerType {
	PAYOFF, POWER, PASSIVE
}

class PowerFamily:
	var description: String
	var uses_for_denom: Array[int]
	var powerType: PowerType
	var icon_path: String
	
	func _init(desc: String, uses_per_denom: Array[int], pwrType: PowerType, icon: String) -> void:
		self.description = desc
		self.uses_for_denom = uses_per_denom
		self.powerType = pwrType
		self.icon_path = icon
		if icon != "":
			assert(FileAccess.file_exists(self.icon_path))
	
	func is_payoff() -> bool:
		return powerType == PowerType.PAYOFF
	
	func is_power() -> bool:
		return powerType == PowerType.POWER
	
	func is_passive() -> bool:
		return powerType == PowerType.PASSIVE

var POWER_FAMILY_GAIN_SOULS = PowerFamily.new("+(CURRENT_CHARGES)[img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]", [2, 4, 7, 10], PowerType.PAYOFF, "res://assets/icons/soul_fragment_blue_icon.png")
var POWER_FAMILY_LOSE_LIFE = PowerFamily.new("-(CURRENT_CHARGES)[img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img]", [1, 2, 3, 4], PowerType.PAYOFF, "res://assets/icons/soul_fragment_red_icon.png")
var POWER_FAMILY_REFLIP = PowerFamily.new("Reflip a coin.", [2, 3, 4, 5], PowerType.POWER, "res://assets/icons/zeus_icon.png")
var POWER_FAMILY_FREEZE = PowerFamily.new("Freeze another coin.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/poseidon_icon.png")
var POWER_FAMILY_REFLIP_AND_NEIGHBORS = PowerFamily.new("Reflip a coin and its neighbors.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/hera_icon.png")
var POWER_FAMILY_GAIN_LIFE = PowerFamily.new("+(1+1_PER_DENOM)[img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img]", [1, 1, 1, 1], PowerType.POWER, "res://assets/icons/demeter_icon.png")
var POWER_FAMILY_GAIN_ARROW = PowerFamily.new("+(1_PER_DENOM) Arrow(s).", [1, 1, 1, 1], PowerType.POWER, "res://assets/icons/artemis_icon.png")
var POWER_FAMILY_TURN_AND_BLURSE = PowerFamily.new("Turn a coin to its other face. Then, if it's [img=12x13]res://assets/icons/heads_icon.png[/img], Curse it, if [img=12x13]res://assets/icons/tails_icon.png[/img] Bless it.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/apollo_icon.png")
var POWER_FAMILY_REFLIP_ALL = PowerFamily.new("Reflip all coins and shuffle their position.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/ares_icon.png")
var POWER_FAMILY_REDUCE_PENALTY = PowerFamily.new("Reduce another coin's [img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img] penalty this round.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/athena_icon.png")
var POWER_FAMILY_UPGRADE_AND_IGNITE = PowerFamily.new("Upgrade another coin and Ignite it.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/hephaestus_icon.png")
var POWER_FAMILY_RECHARGE = PowerFamily.new("Recharge another coin's power.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/aphrodite_icon.png")
var POWER_FAMILY_EXCHANGE = PowerFamily.new("Trade a coin for another of equal value.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/hermes_icon.png")
var POWER_FAMILY_MAKE_LUCKY = PowerFamily.new("Make another coin Lucky.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/hestia_icon.png")
var POWER_FAMILY_GAIN_COIN = PowerFamily.new("Gain a random Obol.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/dionysus_icon.png")
var POWER_FAMILY_DESTROY_FOR_LIFE = PowerFamily.new("Destroy a coin and heal [img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img] equal to (HADES_MULTIPLIER)x that coin's value.", [1, 1, 1, 1], PowerType.POWER, "res://assets/icons/hades_icon.png")

var POWER_FAMILY_ARROW_REFLIP = PowerFamily.new("Reflip a coin.", [1, 1, 1, 1], PowerType.POWER, "")

var NEMESIS_POWER_FAMILY_MEDUSA_STONE = PowerFamily.new("Turn the most valuable non-Stoned coin to Stone.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/nemesis/medusa_icon.png")
var NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE = PowerFamily.new("Downgrade the most valuable coin.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/nemesis/downgrade_icon.png")
var NEMESIS_POWER_FAMILY_EURYALE_STONE = PowerFamily.new("Turn the leftmost non-Stoned coin to Stone.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/nemesis/euryale_icon.png")
var NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY2 = PowerFamily.new("Make 2 random coins Unlucky.", [2, 2, 2, 2], PowerType.PAYOFF, "res://assets/icons/nemesis/unlucky_icon.png")
var NEMESIS_POWER_FAMILY_STHENO_STONE = PowerFamily.new("Turn the rightmost non-Stoned coin to Stone.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/nemesis/stheno_icon.png")
var NEMESIS_POWER_FAMILY_STHENO_STRAIN = PowerFamily.new("Increase Strain by 1.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/nemesis/strain_icon.png")

var TRIAL_POWER_FAMILY_IRON = PowerFamily.new("At the start of the round, gain 2 Obols of Thorns.", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/iron_icon.png")

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
	var patron_enum: PatronEnum
	var power_family: PowerFamily
	var patron_statue: PackedScene
	var patron_token: PackedScene
	
	func _init(name: String, token: String, power_desc: String, ptrn_enum: PatronEnum, pwr_fmly: PowerFamily, statue: PackedScene, tkn: PackedScene) -> void:
		self.god_name = name
		self.token_name = token
		self.description = power_desc
		self.patron_enum = ptrn_enum
		self.power_family = pwr_fmly
		self.patron_statue = statue
		self.patron_token = tkn

# placeholder powers... kinda a $HACK$
var PATRON_POWER_FAMILY_APHRODITE = PowerFamily.new("Aphrodite", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_APOLLO = PowerFamily.new("Apollo", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_ARES = PowerFamily.new("Ares", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_ARTEMIS = PowerFamily.new("Artemis", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_ATHENA = PowerFamily.new("Athena", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_DEMETER = PowerFamily.new("Demeter", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_DIONYSUS = PowerFamily.new("Dionysus", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_HADES = PowerFamily.new("Hades", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_HEPHAESTUS = PowerFamily.new("Hephaestus", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_HERA = PowerFamily.new("Hera", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_HERMES = PowerFamily.new("Hermes", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_HESTIA = PowerFamily.new("Hestia", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_POSEIDON = PowerFamily.new("Poseidon", [1, 2, 3, 4], PowerType.POWER, "");
var PATRON_POWER_FAMILY_ZEUS = PowerFamily.new("Zeus", [1, 2, 3, 4], PowerType.POWER, "");

# exists so I can define a value for the Patron in the editor for patron statues
enum PatronEnum {
	NONE, #used as default for debugging purposes
	APHRODITE,
	APOLLO,
	ARES,
	ARTEMIS,
	ATHENA,
	DEMETER,
	DIONYSUS,
	HADES,
	HEPHAESTUS,
	HERA,
	HERMES,
	HESTIA,
	POSEIDON,
	ZEUS,
	GODLESS, # used as a placeholder for the godless statue, not a real power
}

var PATRONS = [
	Patron.new("[color=lightpink]Aphrodite[/color]", "[color=lightpink]Aphrodite's Heart[/color]", "Recharge all your coins.", PatronEnum.APHRODITE, PATRON_POWER_FAMILY_APHRODITE, preload("res://components/patron_statues/aphrodite.tscn"), preload("res://components/patron_tokens/aphrodite.tscn")),
	Patron.new("[color=orange]Apollo[/color]", "[color=orange]Apollo's Lyre[/color]", "Turn all coins to their other face.", PatronEnum.APOLLO, PATRON_POWER_FAMILY_APOLLO, preload("res://components/patron_statues/apollo.tscn"), preload("res://components/patron_tokens/apollo.tscn")),
	Patron.new("[color=indianred]Ares[/color]", "[color=indianred]Are's Spear[/color]", "Reflip all coins, shuffle their positions, and remove all their statuses.", PatronEnum.ARES, PATRON_POWER_FAMILY_ARES, preload("res://components/patron_statues/ares.tscn"), preload("res://components/patron_tokens/ares.tscn")),
	Patron.new("[color=purple]Artemis[/color]", "[color=purple]Artemis's Bow[/color]", "Turn all coins to tails, then gain 1 Arrow for each.", PatronEnum.ARTEMIS, PATRON_POWER_FAMILY_ARTEMIS, preload("res://components/patron_statues/artemis.tscn"), preload("res://components/patron_tokens/artemis.tscn")),
	Patron.new("[color=cyan]Athena[/color]", "[color=cyan]Athena's Aegis[/color]", "Permanently reduce a coin's tails penalty by 1.", PatronEnum.ATHENA, PATRON_POWER_FAMILY_ATHENA, preload("res://components/patron_statues/athena.tscn"), preload("res://components/patron_tokens/athena.tscn")),
	Patron.new("[color=lightgreen]Demeter[/color]", "[color=lightgreen]Demeter's Wheat[/color]", "For each coin on tails, heal [img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img] equal to its tails penalty. ", PatronEnum.DEMETER, PATRON_POWER_FAMILY_DEMETER, preload("res://components/patron_statues/demeter.tscn"), preload("res://components/patron_tokens/demeter.tscn")),
	Patron.new("[color=plum]Dionysus[/color]", "[color=plum]Dionysus's Chalice[/color]", "Gain a random Obol and make it Lucky.", PatronEnum.DIONYSUS, PATRON_POWER_FAMILY_DIONYSUS, preload("res://components/patron_statues/dionysus.tscn"), preload("res://components/patron_tokens/dionysus.tscn")),
	Patron.new("[color=slateblue]Hades[/color]", "[color=slateblue]Hades's Bident[/color]", "Destroy a coin, then gain [img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img] and [img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img] based on its value.", PatronEnum.HADES, PATRON_POWER_FAMILY_HADES, preload("res://components/patron_statues/hades.tscn"), preload("res://components/patron_tokens/hades.tscn")),
	Patron.new("[color=sienna]Hephaestus[/color]", "[color=sienna]Hephaestus's Hammer[/color]", "Choose a coin. Downgrade it, then upgrade its neighbors.", PatronEnum.HEPHAESTUS, PATRON_POWER_FAMILY_HEPHAESTUS, preload("res://components/patron_statues/hephaestus.tscn"), preload("res://components/patron_tokens/hephaestus.tscn")),
	Patron.new("[color=silver]Hera[/color]", "[color=silver]Hera's Lotus[/color]", "Turn a coin and its neighbors to their other face.", PatronEnum.HERA, PATRON_POWER_FAMILY_HERA, preload("res://components/patron_statues/hera.tscn"), preload("res://components/patron_tokens/hera.tscn")),	
	Patron.new("[color=lightskyblue]Hermes[/color]", "[color=lightskyblue]Herme's Caduceus[/color]", "Trade a coin for another of equal or [color=lightgray](25% of the time)[/color] greater value.", PatronEnum.HERMES, PATRON_POWER_FAMILY_HERMES, preload("res://components/patron_statues/hermes.tscn"), preload("res://components/patron_tokens/hermes.tscn")),
	Patron.new("[color=sandybrown]Hestia[/color]", "[color=sandybrown]Hestia's Warmth[/color]", "Make a coin Lucky and Blessed.", PatronEnum.HESTIA, PATRON_POWER_FAMILY_HESTIA, preload("res://components/patron_statues/hestia.tscn"), preload("res://components/patron_tokens/hestia.tscn")),
	Patron.new("[color=lightblue]Poseidon[/color]", "[color=lightblue]Poseidon's Trident[/color]", "Freeze a coin and its neighbors.", PatronEnum.POSEIDON, PATRON_POWER_FAMILY_POSEIDON, preload("res://components/patron_statues/poseidon.tscn"), preload("res://components/patron_tokens/poseidon.tscn")),
	Patron.new("[color=yellow]Zeus[/color]", "[color=yellow]Zeus's Thunderbolt[/color]", "Supercharge a coin, then reflip it.", PatronEnum.ZEUS, PATRON_POWER_FAMILY_ZEUS, preload("res://components/patron_statues/zeus.tscn"), preload("res://components/patron_tokens/zeus.tscn"))
	
]

func patron_for_enum(enm: PatronEnum) -> Patron:
	if enm == PatronEnum.GODLESS:
		return choose_one(PATRONS)
	for possible_patron in PATRONS:
		if possible_patron.patron_enum == enm:
			return possible_patron
	assert(false, "Patron does not exist.")
	return null

func is_patron_power(power_family: PowerFamily) -> bool:
	for possible_patron in PATRONS:
		if possible_patron.power_family == power_family:
			return true
	return false

# todo - refactor this into a separate file probably; CoinInfo
enum Denomination {
	OBOL = 0, 
	DIOBOL = 1, 
	TRIOBOL = 2, 
	TETROBOL = 3
}

func denom_to_string(denom: Denomination) -> String:
	match(denom):
		Denomination.OBOL:
			return "Obol"
		Denomination.DIOBOL:
			return "Diobol"
		Denomination.TRIOBOL:
			return "Triobol"
		Denomination.TETROBOL:
			return "Tetrobol"
	assert(false, "No matching case for denom...?")
	return "ERROR"

enum _SpriteStyle {
	PAYOFF, POWER, PASSIVE, NEMESIS
}

class CoinFamily:
	var coin_name: String
	var subtitle: String
	
	var store_price_for_denom: Array[int]
	var heads_power_family: PowerFamily
	var tails_power_family: PowerFamily
	
	var _sprite_style: _SpriteStyle
	
	func _init(nme: String, 
			sub_title: String, prices: Array[int],
			heads_pwr: PowerFamily, tails_pwr: PowerFamily,
			style: _SpriteStyle) -> void:
		coin_name = nme
		subtitle = sub_title
		store_price_for_denom = prices
		heads_power_family = heads_pwr
		tails_power_family = tails_pwr
		_sprite_style = style
	
	func get_style_string() -> String:
		match(_sprite_style):
			_SpriteStyle.PAYOFF:
				return "payoff"
			_SpriteStyle.POWER:
				return "power"
			_SpriteStyle.NEMESIS:
				return "nemesis"
			_SpriteStyle.PASSIVE:
				return "passive"
		breakpoint
		return ""

var GENERIC_FAMILY = CoinFamily.new("(DENOM)", "[color=gray]Common Currency[/color]", [1, 4, 10, 22], POWER_FAMILY_GAIN_SOULS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.PAYOFF)
var ZEUS_FAMILY = CoinFamily.new("(DENOM) of Zeus", "[color=yellow]Lighting Strikes[/color]", [2, 8, 20, 44], POWER_FAMILY_REFLIP, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HERA_FAMILY = CoinFamily.new("(DENOM) of Hera", "[color=silver]Envious Wrath[/color]", [2, 8, 20, 44], POWER_FAMILY_REFLIP_AND_NEIGHBORS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var POSEIDON_FAMILY = CoinFamily.new("(DENOM) of Poseidon", "[color=lightblue]Wave of Ice[/color]", [2, 8, 20, 44], POWER_FAMILY_FREEZE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var DEMETER_FAMILY = CoinFamily.new("(DENOM) of Demeter", "[color=lightgreen]Grow Ever Stronger[/color]", [2, 8, 20, 44], POWER_FAMILY_GAIN_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var APOLLO_FAMILY = CoinFamily.new("(DENOM) of Apollo", "[color=orange]Harmonic, Melodic[/color]", [2, 8, 20, 44], POWER_FAMILY_TURN_AND_BLURSE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var ARTEMIS_FAMILY = CoinFamily.new("(DENOM) of Artemis", "[color=purple]Arrows of Night[/color]", [2, 8, 20, 44], POWER_FAMILY_GAIN_ARROW, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var ARES_FAMILY = CoinFamily.new("(DENOM) of Ares", "[color=indianred]Chaos of War[/color]", [3, 12, 30, 66], POWER_FAMILY_REFLIP_ALL, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var ATHENA_FAMILY = CoinFamily.new("(DENOM) of Athena", "[color=cyan]Phalanx Strategy[/color]", [2, 8, 20, 44], POWER_FAMILY_REDUCE_PENALTY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HEPHAESTUS_FAMILY = CoinFamily.new("(DENOM) of Hephaestus", "[color=sienna]Forged in Fire[/color]", [4, 16, 40, 88], POWER_FAMILY_UPGRADE_AND_IGNITE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var APHRODITE_FAMILY = CoinFamily.new("(DENOM) of Aphrodite", "[color=lightpink]A Moment of Warmth[/color]", [2, 8, 20, 44], POWER_FAMILY_RECHARGE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HERMES_FAMILY = CoinFamily.new("(DENOM) of Hermes", "[color=lightskyblue]From Lands Distant[/color]", [2, 8, 20, 44], POWER_FAMILY_EXCHANGE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HESTIA_FAMILY = CoinFamily.new("(DENOM) of Hestia", "[color=sandybrown]Weary Bones Rest[/color]", [1, 4, 10, 22],  POWER_FAMILY_MAKE_LUCKY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var DIONYSUS_FAMILY = CoinFamily.new("(DENOM) of Dionysus", "[color=plum]Wanton Revelry[/color]", [2, 8, 20, 44], POWER_FAMILY_GAIN_COIN, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HADES_FAMILY = CoinFamily.new("(DENOM) of Hades", "[color=slateblue]Beyond the Pale[/color]", [1, 4, 10, 22], POWER_FAMILY_DESTROY_FOR_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)

var MEDUSA_FAMILY = CoinFamily.new("[color=greenyellow]Medusa[/color]", "[color=purple]Mortal Sister[/color]", [0, 0, 0, 0], NEMESIS_POWER_FAMILY_MEDUSA_STONE, NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE, _SpriteStyle.NEMESIS)
var EURYALE_FAMILY = CoinFamily.new("[color=mediumaquamarine]Euryale[/color]", "[color=purple]Lamentful Cry[/color]", [0, 0, 0, 0], NEMESIS_POWER_FAMILY_EURYALE_STONE, NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY2, _SpriteStyle.NEMESIS)
var STHENO_FAMILY = CoinFamily.new("[color=rosybrown]Stheno[/color]", "[color=purple]Huntress of Man[/color]", [0, 0, 0, 0], NEMESIS_POWER_FAMILY_STHENO_STONE, NEMESIS_POWER_FAMILY_STHENO_STRAIN, _SpriteStyle.NEMESIS)

var TRIAL_IRON_FAMILY = CoinFamily.new("[color=darkgray]Trial of Iron[/color]", "[color=lightgray]The First Test[/color]", [0, 0, 0, 0], TRIAL_POWER_FAMILY_IRON, TRIAL_POWER_FAMILY_IRON, _SpriteStyle.PASSIVE)

var _GOD_FAMILIES = [ZEUS_FAMILY, HERA_FAMILY, POSEIDON_FAMILY, DEMETER_FAMILY, APOLLO_FAMILY, ARTEMIS_FAMILY,
		ARES_FAMILY, ATHENA_FAMILY, HEPHAESTUS_FAMILY, APHRODITE_FAMILY, HERMES_FAMILY, HESTIA_FAMILY, DIONYSUS_FAMILY, HADES_FAMILY]

func random_family() -> CoinFamily:
	return choose_one([GENERIC_FAMILY] + _GOD_FAMILIES)

func random_god_family() -> CoinFamily:
	return choose_one(_GOD_FAMILIES)

func random_shop_denomination_for_round() -> Denomination:
	return choose_one(_current_round_shop_denoms())
