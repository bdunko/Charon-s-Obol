extends Node

signal state_changed
signal round_changed
signal souls_count_changed
signal life_count_changed
signal arrow_count_changed
signal active_coin_power_coin_changed
signal active_coin_power_family_changed
signal toll_coins_changed
signal flips_this_round_changed
signal strain_changed
signal patron_changed
signal patron_uses_changed
signal rerolls_changed

var character: CharacterData

class CharacterData:
	var character: Global.Character
	var name: String
	var description: String
	var victoryDialogue: Array #[String]
	var victoryClosingLine: String
	
	func _init(characterEnum: Global.Character, nameStr: String, descriptionStr: String, victoryDlg: Array, victoryClosingLn: String):
		self.character = characterEnum
		self.name = nameStr
		self.description = descriptionStr
		self.victoryDialogue = victoryDlg
		self.victoryClosingLine = victoryClosingLn

enum Character {
	ELEUSINIAN, LADY
}

var CHARACTERS = [
	CharacterData.new(Global.Character.LADY, "[color=brown]The Lady[/color]", 
		"Learn the rules of Charon's game.", 
		["So you've returned to me once more.",
		"You always were one to keep me waiting.",
		"Regardless, welcome back home."],
		"...Persephone."),
	
	CharacterData.new(Global.Character.ELEUSINIAN, "[color=green]The Eleusinian[/color]", 
		"The standard game.\n10 Rounds, 3 Tollgates, 2 Trials, 1 Nemesis.",
		["The birds are singing.", 
		"The sun is shining.",
		"People parade through the streets.",
		"All is well in the world.",
		"Spring has come again."], 
		"...Thank you."),
]

var difficulty: Difficulty

enum Difficulty {
	INDIFFERENT, HOSTILE, VENGEFUL, CRUEL, UNFAIR
}

func difficulty_tooltip_for(diff: Difficulty) -> String:
	# potential difficulty revamp - 
	# 1 regular difficulty
	# 2 adds unpredictability - Charon Malice
	# 3 amp up trials - Trials have 2 modifiers. You cannot view future Trials until completing the previous one. Nemesis is stronger.
	# 4 more challenge - Charon will sometimes summon monsters.
	# 5 shop behavior change - You start with 5 Obol of Stone. Coins in the Shop may have negative statuses. 
	# 6 general difficulty bump - Your coins land on tails more often. Tollgates are more expensive. Charon is more aggressive.
	
	# Normal difficulty.
	# Charon will unleash his Malice.
	# Each Trial has two modifiers. The Nemesis is more powerful. 
	# Charon may summon monsters at the start of non-Trial rounds. Coins available in the Shop may have negative statuses. 
	# You cannot view future Trials until completing the previous one. Tollgates are more expensive. 
	# Your coins land on tails 10% more often. Charon's behavior is more unpredictable. (he has a chance to diverge from his attack pattern and mix in an unused attack)
	
	#todo - fill these description with colors too
	match diff:
		Difficulty.INDIFFERENT:
			return "Charon is Indifferent\nThe base difficulty."
		Difficulty.HOSTILE:
			return "Charon is Hostile\nMonsters shall bar your path..."
		Difficulty.VENGEFUL:
			return "Charon is Malicious\nCharon shall occasionally unleash his Malice..."
		Difficulty.CRUEL:
			return "Charon is Cruel\nTrials shall have two modifiers..."
		Difficulty.UNFAIR:
			return "Charon is Unfair\nYour coins shall land on tails 10% more often..."
	assert(false, "shouldn't happen..")
	return ""

enum State {
	BOARDING, BEFORE_FLIP, AFTER_FLIP, SHOP, VOYAGE, TOLLGATE, GAME_OVER, CHARON_OBOL_FLIP
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

var flips_this_round: int:
	set(val):
		flips_this_round = val
		emit_signal("flips_this_round_changed")
		emit_signal("strain_changed")

var strain_modifier: int:
	set(val):
		strain_modifier = val
		emit_signal("strain_changed")

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

# coins that cannot be offered at tolls
@onready var TOLL_EXCLUDE_COIN_FAMILIES = [THORNS_FAMILY]
# coins that cannot be upgraded
@onready var UPGRADE_EXCLUDE_COIN_FAMILIES = [THORNS_FAMILY]

func calculate_toll_coin_value() -> int:
	var sum = 0
	for coin in toll_coins_offered:
		sum += coin.get_value()
	return sum

var active_coin_power_coin: Coin = null:
	set(val):
		active_coin_power_coin = val
		emit_signal("active_coin_power_coin_changed")
		
var active_coin_power_family: PowerFamily:
	set(val):
		active_coin_power_family = val
		emit_signal("active_coin_power_family_changed")
		#if val == null: #should not be necessary...
		#	active_coin_power_coin = null

const COIN_LIMIT = 8

var COIN_ROWS: Array

# returns the life cost of a toss; min 0
func strain_cost() -> int:
	return max(0, (flips_this_round * 3) + strain_modifier)

enum RoundType {
	BOARDING, NORMAL, TRIAL1, TRIAL2, NEMESIS, TOLLGATE, END
}

class Round:
	var roundType: RoundType
	var lifeRegen: int
	var shopDenoms: Array
	var tollCost: int
	var shopPriceMultiplier: float
	var monsterWaves: Array
	
	var trialData: TrialData
	
	func _init(roundTyp: RoundType, lifeRegn: int, shopDenms: Array, tollCst: int, priceMult: float, mWaveDenoms: Array):
		self.roundType = roundTyp
		self.lifeRegen = lifeRegn
		self.shopDenoms = shopDenms
		self.tollCost = tollCst
		self.shopPriceMultiplier = priceMult
		self.monsterWaves = mWaveDenoms
		
		self.trialData = null

class Monster:
	enum Archetype {
		STANDARD,
		ELITE
	}
	var archetype: Archetype
	var denom: Denomination
	
	func _init(arc: Archetype, dnm: Denomination):
		self.archetype = arc
		self.denom = dnm

var MONSTER_WAVE1 = [
	[Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL)], # swarm
]
var MONSTER_WAVE2 = [
	[Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL)], # swarm
	[Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL)], # lieutenant
]
var MONSTER_WAVE3 = [ 
	[Monster.new(Monster.Archetype.ELITE, Denomination.DIOBOL)], # juggernaut
	[Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL)], # lieutenant
	[Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL)], # brothers in arms
	[Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL)], # swarm
]
var MONSTER_WAVE4 = [
	[Monster.new(Monster.Archetype.ELITE, Denomination.TRIOBOL)], # juggernaut
	[Monster.new(Monster.Archetype.ELITE, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL)], # commander
	[Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.ELITE, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL)], # marauders
]
var MONSTER_WAVE5 = [
	[Monster.new(Monster.Archetype.ELITE, Denomination.TRIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.TRIOBOL)], # commander
	[Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL), Monster.new(Monster.Archetype.ELITE, Denomination.TRIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL)], # marauders
	[Monster.new(Monster.Archetype.STANDARD, Denomination.TRIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.TRIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.TRIOBOL)], # brothers in arms
	[Monster.new(Monster.Archetype.ELITE, Denomination.TRIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL)], # taskmaster
	[Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.TRIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL)], # lieutenant
	[Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL)], # swarm
]
var MONSTER_WAVE6 = [
	[Monster.new(Monster.Archetype.ELITE, Denomination.TRIOBOL), Monster.new(Monster.Archetype.ELITE, Denomination.TRIOBOL)], # juggernaut
]

var _VOYAGE = [
	Round.new(RoundType.BOARDING, 0, [Denomination.OBOL], 0, 0, [[]]), 
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 1.0, [[]]),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 1.25, MONSTER_WAVE1),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 1.5, MONSTER_WAVE2),
	Round.new(RoundType.TRIAL1, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 1.75, [[]]),
	Round.new(RoundType.TOLLGATE, 0, [], 5, 0, [[]]),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 2.0, MONSTER_WAVE3),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL], 0, 2.25, MONSTER_WAVE4),
	Round.new(RoundType.TRIAL2, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 2.5, [[]]),
	Round.new(RoundType.TOLLGATE, 0, [], 10, 0, [[]]),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 2.75, MONSTER_WAVE5),
	Round.new(RoundType.NORMAL, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 3.0, MONSTER_WAVE6),
	Round.new(RoundType.NEMESIS, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 3.25, [[]]),
	Round.new(RoundType.TOLLGATE, 0, [], 0, 0, [[]]),
	Round.new(RoundType.END, 0, [], 0, 0, [[]])
]
#1 board
#2 normal 3 normal 4 normal 5 trial1 6 toll1
#7 normal 8 normal 9 trial2 10 toll2
#11 normal 12 normal 13 nemesis
#14 end

const NUM_STANDARD_MONSTERS = 4
const NUM_ELITE_MONSTERS = 2
@onready var STANDARD_MONSTERS = [MONSTER_HELLHOUND_FAMILY, MONSTER_KOBALOS_FAMILY, MONSTER_ARAE_FAMILY, MONSTER_HARPY_FAMILY] + [MONSTER_CENTAUR_FAMILY, MONSTER_STYMPHALIAN_BIRDS_FAMILY]
@onready var ELITE_MONSTERS = [MONSTER_SIREN_FAMILY, MONSTER_CHIMERA_FAMILY, MONSTER_GORGON_FAMILY, MONSTER_BASILISK_FAMILY]
var _standard_monster_pool = []
var _elite_monster_pool = []

func randomize_voyage() -> void:
	# randomize trials & nemesis
	for rnd in _VOYAGE:
		# debug - seed trial
		match(rnd.roundType):
			RoundType.TRIAL1:
				rnd.trialData = Global.choose_one(LV1_TRIALS)
				#rnd.trialData = LV1_TRIALS[0]
			RoundType.TRIAL2:
				rnd.trialData = Global.choose_one(LV2_TRIALS)
			RoundType.NEMESIS:
				rnd.trialData = Global.choose_one(NEMESES)
	
	# randomize the monster pool
	STANDARD_MONSTERS.shuffle()
	_standard_monster_pool = STANDARD_MONSTERS.slice(0, NUM_STANDARD_MONSTERS)
	_elite_monster_pool = ELITE_MONSTERS.slice(0, NUM_ELITE_MONSTERS)
	assert(_standard_monster_pool.size() == NUM_STANDARD_MONSTERS)
	assert(_elite_monster_pool.size() == NUM_ELITE_MONSTERS)

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

# returns an array of [monster_family, denom] pairs for current round
func current_round_enemy_coin_data() -> Array:
	var coin_data = []
	
	if current_round_type() == RoundType.TRIAL1:
		for trialFamily in _VOYAGE[round_count-1].trialData.coinFamilies:
			coin_data.append([trialFamily, Denomination.OBOL])
	elif current_round_type() == RoundType.TRIAL2:
		for trialFamily in _VOYAGE[round_count-1].trialData.coinFamilies:
			coin_data.append([trialFamily, Denomination.DIOBOL])
	elif current_round_type() == RoundType.NEMESIS:
		for nemesisFamily in _VOYAGE[round_count-1].trialData.coinFamilies:
			coin_data.append([nemesisFamily, Denomination.TETROBOL])
	else:
		var monsters = Global.choose_one(_VOYAGE[round_count-1].monsterWaves)
		# elite_index just used to assure the final round has 2 different elites
		# but for standard monsters, duplicates are permitted
		var elite_index = 0
		_elite_monster_pool.shuffle()
		for monster in monsters:
			var denom = monster.denom
			match monster.archetype:
				Monster.Archetype.STANDARD:
					coin_data.append([Global.choose_one(_standard_monster_pool), denom])
				Monster.Archetype.ELITE:
					coin_data.append([_elite_monster_pool[elite_index], denom])
					elite_index += 1
			
	return coin_data

func current_round_price_multiplier() -> float:
	return _VOYAGE[round_count-1].shopPriceMultiplier

func is_current_round_trial() -> bool:
	var rtype = current_round_type()
	return rtype == RoundType.TRIAL1 or rtype == RoundType.TRIAL2 or rtype == RoundType.NEMESIS

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
	var coinFamilies
	var name
	var description
	
	func _init(trialName, trialCoinFamilies, trialDescription):
		self.name = trialName
		self.coinFamilies = trialCoinFamilies
		self.description = trialDescription

@onready var NEMESES = [
	TrialData.new("[color=lightgreen]The Gorgon Sisters[/color]", [EURYALE_FAMILY, MEDUSA_FAMILY, STHENO_FAMILY], "These three sisters will render you helpless with their petrifying gaze.")
]

@onready var LV1_TRIALS = [
	TrialData.new(TRIAL_IRON_FAMILY.coin_name, [TRIAL_IRON_FAMILY], TRIAL_POWER_FAMILY_IRON.description),
	TrialData.new(TRIAL_MISFORTUNE_FAMILY.coin_name, [TRIAL_MISFORTUNE_FAMILY], TRIAL_POWER_FAMILY_MISFORTUNE.description),
	#TrialData.new("Fossilization", [GENERIC_FAMILY], "When the trial begins, your highest value coin is turned to Stone."),
	TrialData.new(TRIAL_POLARIZATION_FAMILY.coin_name, [TRIAL_POLARIZATION_FAMILY], TRIAL_POWER_FAMILY_POLARIZATION.description),
	#TrialData.new("Silence", [GENERIC_FAMILY], "Your leftmost 2 coins are Blank."),
	#TrialData.new("Silence", [GENERIC_FAMILY], "Your rightmost 2 coins are Blank."),
	#TrialData.new("Exhaustion", [GENERIC_FAMILY], "Every 3 payoffs, your lowest value coin is destroyed."),
	TrialData.new(TRIAL_EQUIVALENCE_FAMILY.coin_name, [TRIAL_EQUIVALENCE_FAMILY], TRIAL_POWER_FAMILY_EQUIVALENCE.description),
	TrialData.new(TRIAL_PAIN_FAMILY.coin_name, [TRIAL_PAIN_FAMILY], TRIAL_POWER_FAMILY_PAIN.description),
	TrialData.new(TRIAL_BLOOD_FAMILY.coin_name, [TRIAL_BLOOD_FAMILY], TRIAL_POWER_FAMILY_BLOOD.description),
	#TrialData.new("Draining", [GENERIC_FAMILY], "Using a power also drains a charge from each adjacent coin."),
	#TrialData.new("Suffering", [GENERIC_FAMILY], "Strain starts at 4."),
	#TrialData.new("Restraint", [GENERIC_FAMILY], "After using a coin's power, that coin becomes Locked."),
]

@onready var LV2_TRIALS = [
	TrialData.new(TRIAL_FAMINE_FAMILY.coin_name, [TRIAL_FAMINE_FAMILY], TRIAL_POWER_FAMILY_FAMINE.description),
	#TrialData.new("Vainglory", [GENERIC_FAMILY], "When the trial begins, your Obols and Diobols are destroyed."),
	TrialData.new(TRIAL_TORTURE_FAMILY.coin_name, [TRIAL_TORTURE_FAMILY], TRIAL_POWER_FAMILY_TORTURE.description),
	#TrialData.new("Petrification", [GENERIC_FAMILY], "When the trial begins, your two highest value coins are turned to Stone."),
	#TrialData.new("Fate", [GENERIC_FAMILY], "Coins cannot be reflipped by powers."),
	TrialData.new(TRIAL_LIMITATION_FAMILY.coin_name, [TRIAL_LIMITATION_FAMILY], TRIAL_POWER_FAMILY_LIMITATION.description),
	#TrialData.new("Gating", [GENERIC_FAMILY], "During payoff, any coin which earns more than 10 Souls earns 0 instead."),
	#TrialData.new("Impatience", [GENERIC_FAMILY], "You must perform exactly 3 total tosses this round."),
	#TrialData.new("Immolation", [GENERIC_FAMILY], "When the trial begins, all your coins Ignite."),
	#TrialData.new("Aging", [GENERIC_FAMILY], "After payoff, your leftmost non-Blank coin becomes Blank."),
	# todo - rename resistance to poverty and redo icon
	#TrialData.new("Resistance", [GENERIC_FAMILY], "Your payoff coins land on tails 90% of the time."),
	TrialData.new(TRIAL_COLLAPSE_FAMILY.coin_name, [TRIAL_COLLAPSE_FAMILY], TRIAL_POWER_FAMILY_COLLAPSE.description),
	#TrialData.new("Chaos", [GENERIC_FAMILY], "All coin powers have random targets when activated."),
	TrialData.new(TRIAL_OVERLOAD_FAMILY.coin_name, [TRIAL_OVERLOAD_FAMILY], TRIAL_POWER_FAMILY_OVERLOAD.description),
	TrialData.new(TRIAL_SAPPING_FAMILY.coin_name, [TRIAL_SAPPING_FAMILY], TRIAL_POWER_FAMILY_SAPPING.description),
	#TrialData.new("Singularity", [GENERIC_FAMILY], "Every power coin has only a single charge."),
	#TrialData.new("Recklessness", [GENERIC_FAMILY], "You cannot end the round until your life is 5 or fewer."),
	#TrialData.new("Adversity", [GENERIC_FAMILY], "Gain a random permanent Monster coin. (If not enough space, destroy coins until there is.)"),
	#TrialData.new("Fury", [GENERIC_FAMILY], "Charon's Malice increases 3 times as fast."),
	#TrialData.new("Chains", [GENERIC_FAMILY], "When the trial begins, each of your non-payoff coins becomes Locked."),
	#TrialData.new("Transfiguration", [GENERIC_FAMILY], "When the trial begins, 3 of your non-payoff coins are randomly transformed into different coins of the same value."),
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

# Coin Powers
var POWER_FAMILY_GAIN_SOULS = PowerFamily.new("+(CURRENT_CHARGES)(SOULS)", [5, 8, 11, 14], PowerType.PAYOFF, "res://assets/icons/soul_fragment_blue_icon.png")
var POWER_FAMILY_LOSE_SOULS = PowerFamily.new("-(CURRENT_CHARGES)(SOULS)", [3, 4, 5, 6], PowerType.PAYOFF, "res://assets/icons/soul_fragment_blue_icon.png")
var POWER_FAMILY_LOSE_LIFE = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [2, 3, 4, 5], PowerType.PAYOFF, "res://assets/icons/soul_fragment_red_icon.png")
var POWER_FAMILY_LOSE_ZERO_LIFE = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [0, 0, 0, 0], PowerType.PAYOFF, "res://assets/icons/soul_fragment_red_icon.png")

var POWER_FAMILY_GAIN_LIFE = PowerFamily.new("+(1+1_PER_DENOM)(HEAL)", [1, 1, 1, 1], PowerType.POWER, "res://assets/icons/demeter_icon.png")
var POWER_FAMILY_REFLIP = PowerFamily.new("Reflip another coin.", [2, 3, 4, 5], PowerType.POWER, "res://assets/icons/zeus_icon.png")
var POWER_FAMILY_FREEZE = PowerFamily.new("(FREEZE) another coin.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/poseidon_icon.png")
var POWER_FAMILY_REFLIP_AND_NEIGHBORS = PowerFamily.new("Reflip a coin and its neighbors.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/hera_icon.png")
var POWER_FAMILY_GAIN_ARROW = PowerFamily.new("+(1_PER_DENOM) (ARROW).", [1, 1, 1, 1], PowerType.POWER, "res://assets/icons/artemis_icon.png")
var POWER_FAMILY_TURN_AND_BLURSE = PowerFamily.new("Turn a coin to its other face. Then, if it's (HEADS), (CURSE) it, if (TAILS) (BLESS) it.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/apollo_icon.png")
var POWER_FAMILY_REFLIP_ALL = PowerFamily.new("Reflip all coins.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/ares_icon.png")
var POWER_FAMILY_REDUCE_PENALTY = PowerFamily.new("Reduce another coin's (LIFE) penalty for this round.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/athena_icon.png")
var POWER_FAMILY_UPGRADE_AND_IGNITE = PowerFamily.new("Upgrade (HEPHAESTUS_OPTIONS) and (IGNITE) it.", [1, 1, 1, 2], PowerType.POWER, "res://assets/icons/hephaestus_icon.png")
var POWER_FAMILY_RECHARGE = PowerFamily.new("Recharge another coin's power.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/aphrodite_icon.png")
var POWER_FAMILY_EXCHANGE = PowerFamily.new("Trade a coin for another of equal value.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/hermes_icon.png")
var POWER_FAMILY_MAKE_LUCKY = PowerFamily.new("Make another coin (LUCKY).", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/hestia_icon.png")
var POWER_FAMILY_GAIN_COIN = PowerFamily.new("Gain a random Obol.", [1, 2, 3, 4], PowerType.POWER, "res://assets/icons/dionysus_icon.png")
var POWER_FAMILY_DESTROY_FOR_LIFE = PowerFamily.new("Destroy a coin and heal [img=10x13]res://assets/icons/soul_fragment_red_heal_icon.png[/img] equal to (HADES_MULTIPLIER)x that coin's value.", [1, 1, 1, 1], PowerType.POWER, "res://assets/icons/hades_icon.png")

var POWER_FAMILY_ARROW_REFLIP = PowerFamily.new("Reflip a coin.", [1, 1, 1, 1], PowerType.POWER, "")

var MONSTER_POWER_FAMILY_HELLHOUND = PowerFamily.new("(IGNITE) this coin..", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")
var MONSTER_POWER_FAMILY_KOBALOS = PowerFamily.new("Make a coin (UNLUCKY).", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")
var MONSTER_POWER_FAMILY_ARAE = PowerFamily.new("(CURSE) a coin.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")
var MONSTER_POWER_FAMILY_HARPY = PowerFamily.new("(BLANK) a coin.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")
var MONSTER_POWER_FAMILY_CENTAUR_HEADS = PowerFamily.new("Make a coin (LUCKY).", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")
var MONSTER_POWER_FAMILY_CENTAUR_TAILS = PowerFamily.new("Make a coin (UNLUCKY).", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")

var MONSTER_POWER_FAMILY_STYMPHALIAN_BIRDS = PowerFamily.new("+1 [ARROW].", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")

var MONSTER_POWER_FAMILY_CHIMERA = PowerFamily.new("(IGNITE) a coin.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")
var MONSTER_POWER_FAMILY_SIREN = PowerFamily.new("(FREEZE) each tails coin.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")
var MONSTER_POWER_FAMILY_BASILISK = PowerFamily.new("Lose half your (LIFE).", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")
var MONSTER_POWER_FAMILY_GORGON = PowerFamily.new("Turn a coin to (STONE).", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/todo_icon.png")

var NEMESIS_POWER_FAMILY_MEDUSA_STONE = PowerFamily.new("Turn a coin to (STONE).", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/nemesis/medusa_icon.png")
var NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE = PowerFamily.new("Downgrade the most valuable coin.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/nemesis/downgrade_icon.png")
var NEMESIS_POWER_FAMILY_EURYALE_STONE = PowerFamily.new("Turn a coin to (STONE).", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/nemesis/euryale_icon.png")
var NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY2 = PowerFamily.new("Make 2 coins (UNLUCKY).", [2, 2, 2, 2], PowerType.PAYOFF, "res://assets/icons/nemesis/unlucky_icon.png")
var NEMESIS_POWER_FAMILY_STHENO_STONE = PowerFamily.new("Turn a coin to (STONE)", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/nemesis/stheno_icon.png")
var NEMESIS_POWER_FAMILY_STHENO_STRAIN = PowerFamily.new("Increase Strain by 1.", [1, 1, 1, 1], PowerType.PAYOFF, "res://assets/icons/nemesis/strain_icon.png")

var TRIAL_POWER_FAMILY_IRON = PowerFamily.new("When the trial begins, you gain 2 Obols of Thorns. (If not enough space, destroy coins until there is.)", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/iron_icon.png")
var TRIAL_POWER_FAMILY_MISFORTUNE = PowerFamily.new("When the trial begins, all your coins become (UNLUCKY).", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/misfortune_icon.png")
var TRIAL_POWER_FAMILY_POLARIZATION = PowerFamily.new("Your Diobols are (BLANK).", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/polarization_icon.png")
var TRIAL_POWER_FAMILY_PAIN = PowerFamily.new("Damage you take from (LIFE) penalties is tripled.", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/pain_icon.png")
var TRIAL_POWER_FAMILY_BLOOD = PowerFamily.new("Using a power costs 1 (LIFE).", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/blood_icon.png")
var TRIAL_POWER_FAMILY_EQUIVALENCE = PowerFamily.new("After a coin lands on (HEADS), it becomes (UNLUCKY). After a coin lands on (TAILS), it becomes (LUCKY).", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/equivalence_icon.png")

var TRIAL_POWER_FAMILY_FAMINE = PowerFamily.new("You do not replenish (HEAL) at the start of the trial.", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/famine_icon.png")
var TRIAL_POWER_FAMILY_TORTURE = PowerFamily.new("After payoff, your highest value coin is downgraded.", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/torture_icon.png")
var TRIAL_POWER_FAMILY_LIMITATION = PowerFamily.new("Reduce any payoffs less than 10 (SOULS) to 0.", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/limitation_icon.png")
var TRIAL_POWER_FAMILY_COLLAPSE = PowerFamily.new("After payoff, (CURSE) and (FREEZE) each coin on (TAILS).", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/collapse_icon.png")
var TRIAL_POWER_FAMILY_SAPPING = PowerFamily.new("Coins replenish only a single charge each toss.", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/sapping_icon.png")
var TRIAL_POWER_FAMILY_OVERLOAD = PowerFamily.new("After payoff, you lose 1 (LIFE) for each unused power charge on a heads coin.", [0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/overload_icon.png")

var CHARON_POWER_DEATH = PowerFamily.new("Die.", [0, 0, 0, 0], PowerType.PAYOFF, "res://assets/icons/charon_death_icon.png")
var CHARON_POWER_LIFE = PowerFamily.new("Live. End the round.", [0, 0, 0, 0], PowerType.PAYOFF, "res://assets/icons/charon_life_icon.png")

func replace_placeholders(tooltip: String) -> String:
	# images
	tooltip = tooltip.replace("(HEADS)", "[img=10x13]res://assets/icons/heads_icon.png[/img]")
	tooltip = tooltip.replace("(TAILS)", "[img=10x13]res://assets/icons/tails_icon.png[/img]")
	tooltip = tooltip.replace("(ARROW)", "[img=10x13]res://assets/icons/arrow_icon.png[/img]")
	tooltip = tooltip.replace("(LIFE)", "[img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img]")
	tooltip = tooltip.replace("(HEAL)", "[img=10x13]res://assets/icons/soul_fragment_red_heal_icon.png[/img]")	
	tooltip = tooltip.replace("(SOULS)", "[img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]")
	
	# statuses
	const STATUS_FORMAT = "[color=%s]%s[/color][img=10x13]%s[/img]"
	tooltip = tooltip.replace("(IGNITE)", STATUS_FORMAT % ["red", "Ignite", "res://assets/icons/status/ignite_icon.png"])
	tooltip = tooltip.replace("(FREEZE)", STATUS_FORMAT % ["aqua", "Freeze", "res://assets/icons/status/freeze_icon.png"])
	tooltip = tooltip.replace("(LUCKY)", STATUS_FORMAT % ["lawngreen", "Lucky", "res://assets/icons/status/lucky_icon.png"])
	tooltip = tooltip.replace("(UNLUCKY)", STATUS_FORMAT % ["orangered", "Unlucky", "res://assets/icons/status/unlucky_icon.png"])
	tooltip = tooltip.replace("(BLESS)", STATUS_FORMAT % ["palegoldenrod", "Bless", "res://assets/icons/status/bless_icon.png"])
	tooltip = tooltip.replace("(CURSE)", STATUS_FORMAT % ["mediumorchid", "Curse", "res://assets/icons/status/curse_icon.png"])
	tooltip = tooltip.replace("(BLANK)", STATUS_FORMAT % ["ghostwhite", "Blank", "res://assets/icons/status/blank_icon.png"])
	tooltip = tooltip.replace("(SUPERCHARGE)", STATUS_FORMAT % ["yellow", "Supercharge", "res://assets/icons/status/supercharge_icon.png"])
	tooltip = tooltip.replace("(STONE)", STATUS_FORMAT % ["slategray", "Stone", "res://assets/icons/status/stone_icon.png"])
	
	# used for the coin status indicator tooltips
	tooltip = tooltip.replace("(S_IGNITED)", STATUS_FORMAT % ["red", "Ignited", "res://assets/icons/status/ignite_icon.png"])
	tooltip = tooltip.replace("(S_FROZEN)", STATUS_FORMAT % ["aqua", "Frozen", "res://assets/icons/status/freeze_icon.png"])
	tooltip = tooltip.replace("(S_LUCKY)", STATUS_FORMAT % ["lawngreen", "Lucky", "res://assets/icons/status/lucky_icon.png"])
	tooltip = tooltip.replace("(S_UNLUCKY)", STATUS_FORMAT % ["orangered", "Unlucky", "res://assets/icons/status/unlucky_icon.png"])
	tooltip = tooltip.replace("(S_BLESSED)", STATUS_FORMAT % ["palegoldenrod", "Blessed", "res://assets/icons/status/bless_icon.png"])
	tooltip = tooltip.replace("(S_CURSED)", STATUS_FORMAT % ["mediumorchid", "Cursed", "res://assets/icons/status/curse_icon.png"])
	tooltip = tooltip.replace("(S_BLANKED)", STATUS_FORMAT % ["ghostwhite", "Blanked", "res://assets/icons/status/blank_icon.png"])
	tooltip = tooltip.replace("(S_SUPERCHARGED)", STATUS_FORMAT % ["yellow", "Supercharged", "res://assets/icons/status/supercharge_icon.png"])
	tooltip = tooltip.replace("(S_TURNED_TO_STONE)", STATUS_FORMAT % ["slategray", "Turned to Stone", "res://assets/icons/status/stone_icon.png"])
	
	return tooltip

# todo - refactor this into Util
signal any_input

var debug = true # utility flag for debugging mode
const _BREAKPOINT_ON_SPACE = true

var RNG = RandomNumberGenerator.new()

const _SCREENSHOT_ENABLED = true
const _SCREENSHOT_KEY = KEY_EQUAL
const _SCREENSHOT_PATH_FORMAT = "res://screenshots/Obol_%s_%s.png"
func take_screenshot(): # Function for taking screenshots and saving them
	var date: String = Time.get_date_string_from_system().replace(".","_") 
	var time: String = Time.get_time_string_from_system().replace(":","")
	var screenshot_path = _SCREENSHOT_PATH_FORMAT % [date, time] # the path for our screenshot.
	var image = get_viewport().get_texture().get_image() # We get what our player sees
	image.save_png(screenshot_path)

var _is_depressed = false
var _last_any_input_time = 0.0
const _MIN_TIME_BETWEEN_ANY_INPUT_MS = 100 #0.2 sec
func _input(_event: InputEvent) -> void:
	if _BREAKPOINT_ON_SPACE and Input.is_key_pressed(KEY_SPACE):
		breakpoint
	if _SCREENSHOT_ENABLED and Input.is_key_pressed(_SCREENSHOT_KEY):
		take_screenshot()
	elif Input.is_anything_pressed() and not _is_depressed:
		_is_depressed = true
		
		# don't let the signal go faster than a set rate
		if Time.get_ticks_msec()  - _last_any_input_time >= _MIN_TIME_BETWEEN_ANY_INPUT_MS:
			_last_any_input_time = Time.get_ticks_msec()
			emit_signal("any_input")
	else:
		_is_depressed = false

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
		#assert(false, "excluding all elements in choose_on_excluding...")
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
	var _starting_coinpool: Array
	
	func _init(name: String, token: String, power_desc: String, ptrn_enum: PatronEnum, pwr_fmly: PowerFamily, statue: PackedScene, tkn: PackedScene, start_cpl: Array) -> void:
		self.god_name = name
		self.token_name = token
		self.description = power_desc
		self.patron_enum = ptrn_enum
		self.power_family = pwr_fmly
		self.patron_statue = statue
		self.patron_token = tkn
		self._starting_coinpool = start_cpl
	
	func get_random_starting_coin_family() -> CoinFamily:
		return Global.choose_one(_starting_coinpool)

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

var _GODLESS_STATUE = preload("res://components/patron_statues/godless.tscn")
@onready var PATRONS = [
	Patron.new("[color=lightpink]Aphrodite[/color]", "[color=lightpink]Aphrodite's Heart[/color]", "Recharge all your coins.", PatronEnum.APHRODITE, PATRON_POWER_FAMILY_APHRODITE, preload("res://components/patron_statues/aphrodite.tscn"), preload("res://components/patron_tokens/aphrodite.tscn"), [APHRODITE_FAMILY]),
	Patron.new("[color=orange]Apollo[/color]", "[color=orange]Apollo's Lyre[/color]", "Turn all coins to their other face.", PatronEnum.APOLLO, PATRON_POWER_FAMILY_APOLLO, preload("res://components/patron_statues/apollo.tscn"), preload("res://components/patron_tokens/apollo.tscn"), [APOLLO_FAMILY]),
	Patron.new("[color=indianred]Ares[/color]", "[color=indianred]Are's Spear[/color]", "Reflip all coins, shuffle their positions, and remove all their statuses.", PatronEnum.ARES, PATRON_POWER_FAMILY_ARES, preload("res://components/patron_statues/ares.tscn"), preload("res://components/patron_tokens/ares.tscn"), [ARES_FAMILY]),
	Patron.new("[color=purple]Artemis[/color]", "[color=purple]Artemis's Bow[/color]", "Turn all coins to (TAILS), then gain 1 (ARROW) for each.", PatronEnum.ARTEMIS, PATRON_POWER_FAMILY_ARTEMIS, preload("res://components/patron_statues/artemis.tscn"), preload("res://components/patron_tokens/artemis.tscn"), [ARTEMIS_FAMILY]),
	Patron.new("[color=cyan]Athena[/color]", "[color=cyan]Athena's Aegis[/color]", "Permanently reduce a coin's (LIFE) penalty by 1.", PatronEnum.ATHENA, PATRON_POWER_FAMILY_ATHENA, preload("res://components/patron_statues/athena.tscn"), preload("res://components/patron_tokens/athena.tscn"), [ATHENA_FAMILY]),
	Patron.new("[color=lightgreen]Demeter[/color]", "[color=lightgreen]Demeter's Wheat[/color]", "For each coin on (TAILS), heal (LIFE) equal to its (LIFE) penalty. ", PatronEnum.DEMETER, PATRON_POWER_FAMILY_DEMETER, preload("res://components/patron_statues/demeter.tscn"), preload("res://components/patron_tokens/demeter.tscn"), [DEMETER_FAMILY]),
	Patron.new("[color=plum]Dionysus[/color]", "[color=plum]Dionysus's Chalice[/color]", "Gain a random Obol and make it (LUCKY).", PatronEnum.DIONYSUS, PATRON_POWER_FAMILY_DIONYSUS, preload("res://components/patron_statues/dionysus.tscn"), preload("res://components/patron_tokens/dionysus.tscn"), [DIONYSUS_FAMILY]),
	Patron.new("[color=slateblue]Hades[/color]", "[color=slateblue]Hades's Bident[/color]", "Destroy a coin, then gain (SOULS) and heal (LIFE) based on its value.", PatronEnum.HADES, PATRON_POWER_FAMILY_HADES, preload("res://components/patron_statues/hades.tscn"), preload("res://components/patron_tokens/hades.tscn"), [HADES_FAMILY]),
	Patron.new("[color=sienna]Hephaestus[/color]", "[color=sienna]Hephaestus's Hammer[/color]", "Choose a coin. Downgrade it, then upgrade its neighbors.", PatronEnum.HEPHAESTUS, PATRON_POWER_FAMILY_HEPHAESTUS, preload("res://components/patron_statues/hephaestus.tscn"), preload("res://components/patron_tokens/hephaestus.tscn"), [HEPHAESTUS_FAMILY]),
	Patron.new("[color=silver]Hera[/color]", "[color=silver]Hera's Lotus[/color]", "Turn a coin and its neighbors to their other face.", PatronEnum.HERA, PATRON_POWER_FAMILY_HERA, preload("res://components/patron_statues/hera.tscn"), preload("res://components/patron_tokens/hera.tscn"), [HERA_FAMILY]),
	Patron.new("[color=lightskyblue]Hermes[/color]", "[color=lightskyblue]Herme's Caduceus[/color]", "Trade a coin for another of equal or [color=lightgray](25% of the time)[/color] greater value.", PatronEnum.HERMES, PATRON_POWER_FAMILY_HERMES, preload("res://components/patron_statues/hermes.tscn"), preload("res://components/patron_tokens/hermes.tscn"), [HERMES_FAMILY]),
	Patron.new("[color=sandybrown]Hestia[/color]", "[color=sandybrown]Hestia's Warmth[/color]", "(BLESS) a coin and make it (LUCKY).", PatronEnum.HESTIA, PATRON_POWER_FAMILY_HESTIA, preload("res://components/patron_statues/hestia.tscn"), preload("res://components/patron_tokens/hestia.tscn"), [HESTIA_FAMILY]),
	Patron.new("[color=lightblue]Poseidon[/color]", "[color=lightblue]Poseidon's Trident[/color]", "(FREEZE) a coin and its neighbors.", PatronEnum.POSEIDON, PATRON_POWER_FAMILY_POSEIDON, preload("res://components/patron_statues/poseidon.tscn"), preload("res://components/patron_tokens/poseidon.tscn"), [POSEIDON_FAMILY]),
	Patron.new("[color=yellow]Zeus[/color]", "[color=yellow]Zeus's Thunderbolt[/color]", "(SUPERCHARGE) a coin, then reflip it.", PatronEnum.ZEUS, PATRON_POWER_FAMILY_ZEUS, preload("res://components/patron_statues/zeus.tscn"), preload("res://components/patron_tokens/zeus.tscn"), [ZEUS_FAMILY])
]

func statue_scene_for_patron_enum(enm: PatronEnum) -> PackedScene:
	if enm == PatronEnum.GODLESS:
		return _GODLESS_STATUE
	for possible_patron in PATRONS:
		if possible_patron.patron_enum == enm:
			return possible_patron.patron_statue
	assert(false, "Patron does not exist. (statue scene for patron enum)")
	return null

func patron_for_enum(enm: PatronEnum) -> Patron:
	if enm == PatronEnum.GODLESS:
		return choose_one(PATRONS)
	for possible_patron in PATRONS:
		if possible_patron.patron_enum == enm:
			return possible_patron
	assert(false, "Patron does not exist. (patron for enum)")
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
	PAYOFF, POWER, PASSIVE, NEMESIS, THORNS, CHARONS
}

const NOT_APPEASEABLE_PRICE = -888

class CoinFamily:
	var coin_name: String
	var subtitle: String
	
	var store_price_for_denom: Array
	var heads_power_family: PowerFamily
	var tails_power_family: PowerFamily

	var appeasal_price_for_denom: Array
	
	var _sprite_style: _SpriteStyle
	
	func _init(nme: String, 
			sub_title: String, prices: Array,
			heads_pwr: PowerFamily, tails_pwr: PowerFamily,
			style: _SpriteStyle, app_price := [NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE]) -> void:
		coin_name = nme
		subtitle = sub_title
		store_price_for_denom = prices
		heads_power_family = heads_pwr
		tails_power_family = tails_pwr
		appeasal_price_for_denom = app_price
		_sprite_style = style
		assert(store_price_for_denom.size() == 4)
		assert(appeasal_price_for_denom.size() == 4)
	
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
			_SpriteStyle.THORNS:
				return "thorns"
			_SpriteStyle.CHARONS:
				return "charons"
		breakpoint
		return ""

const NO_PRICE = [0, 0, 0, 0]
const CHEAP = [3, 11, 22, 35] # 3 + 8 + 11 + 13
const STANDARD = [5, 15, 27, 42] # 5 + 10 + 12 + 15
const PRICY = [8, 19, 33, 51] # 8 + 11 + 14 + 18
const RICH = [12, 25, 40, 60] # 12 + 13 + 15 + 20

# Coin Families
# payoff coins
var GENERIC_FAMILY = CoinFamily.new("(DENOM)", "[color=gray]Common Currency[/color]", CHEAP, POWER_FAMILY_GAIN_SOULS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.PAYOFF)

# power coins
var ZEUS_FAMILY = CoinFamily.new("(DENOM) of Zeus", "[color=yellow]Lighting Strikes[/color]", STANDARD, POWER_FAMILY_REFLIP, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HERA_FAMILY = CoinFamily.new("(DENOM) of Hera", "[color=silver]Envious Wrath[/color]", STANDARD, POWER_FAMILY_REFLIP_AND_NEIGHBORS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var POSEIDON_FAMILY = CoinFamily.new("(DENOM) of Poseidon", "[color=lightblue]Wave of Ice[/color]", STANDARD, POWER_FAMILY_FREEZE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var DEMETER_FAMILY = CoinFamily.new("(DENOM) of Demeter", "[color=lightgreen]Grow Ever Stronger[/color]", STANDARD, POWER_FAMILY_GAIN_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var APOLLO_FAMILY = CoinFamily.new("(DENOM) of Apollo", "[color=orange]Harmonic, Melodic[/color]", STANDARD, POWER_FAMILY_TURN_AND_BLURSE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var ARTEMIS_FAMILY = CoinFamily.new("(DENOM) of Artemis", "[color=purple]Arrows of Night[/color]", PRICY, POWER_FAMILY_GAIN_ARROW, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var ARES_FAMILY = CoinFamily.new("(DENOM) of Ares", "[color=indianred]Chaos of War[/color]", STANDARD, POWER_FAMILY_REFLIP_ALL, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var ATHENA_FAMILY = CoinFamily.new("(DENOM) of Athena", "[color=cyan]Phalanx Strategy[/color]", RICH, POWER_FAMILY_REDUCE_PENALTY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HEPHAESTUS_FAMILY = CoinFamily.new("(DENOM) of Hephaestus", "[color=sienna]Forged in Fire[/color]", RICH, POWER_FAMILY_UPGRADE_AND_IGNITE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var APHRODITE_FAMILY = CoinFamily.new("(DENOM) of Aphrodite", "[color=lightpink]A Moment of Warmth[/color]", STANDARD, POWER_FAMILY_RECHARGE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HERMES_FAMILY = CoinFamily.new("(DENOM) of Hermes", "[color=lightskyblue]From Lands Distant[/color]", PRICY, POWER_FAMILY_EXCHANGE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HESTIA_FAMILY = CoinFamily.new("(DENOM) of Hestia", "[color=sandybrown]Weary Bones Rest[/color]", STANDARD,  POWER_FAMILY_MAKE_LUCKY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var DIONYSUS_FAMILY = CoinFamily.new("(DENOM) of Dionysus", "[color=plum]Wanton Revelry[/color]", STANDARD, POWER_FAMILY_GAIN_COIN, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HADES_FAMILY = CoinFamily.new("(DENOM) of Hades", "[color=slateblue]Beyond the Pale[/color]", CHEAP, POWER_FAMILY_DESTROY_FOR_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)

# monsters
var MONSTER_FAMILY = CoinFamily.new("[color=gray]Monster[/color]", "[color=purple]It Bars the Path[/color]", NO_PRICE, POWER_FAMILY_LOSE_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [10, 20, 30, 40])
var MONSTER_HELLHOUND_FAMILY = CoinFamily.new("[color=gray]Hellhound[/color]", "[color=purple]Infernal Pursurer[/color]", NO_PRICE, MONSTER_POWER_FAMILY_HELLHOUND, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [10, 20, 30, 40])
var MONSTER_KOBALOS_FAMILY = CoinFamily.new("[color=gray]Kobalos[/color]", "[color=purple]Obstreperous Scamp[/color]", NO_PRICE, MONSTER_POWER_FAMILY_KOBALOS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [10, 20, 30, 40])
var MONSTER_ARAE_FAMILY = CoinFamily.new("[color=gray]Arae[/color]", "[color=purple]Encumbered by Guilt[/color]", NO_PRICE, MONSTER_POWER_FAMILY_ARAE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [10, 20, 30, 40])
var MONSTER_HARPY_FAMILY = CoinFamily.new("[color=gray]Harpy[/color]", "[color=purple]Shrieking Wind[/color]", NO_PRICE, MONSTER_POWER_FAMILY_HARPY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [10, 20, 30, 40])
var MONSTER_CENTAUR_FAMILY = CoinFamily.new("[color=gray]Centaur[/color]", "[color=purple]Are the Stars Right?[/color]", NO_PRICE, MONSTER_POWER_FAMILY_CENTAUR_HEADS, MONSTER_POWER_FAMILY_CENTAUR_TAILS, _SpriteStyle.NEMESIS, [10, 20, 30, 40])
var MONSTER_STYMPHALIAN_BIRDS_FAMILY = CoinFamily.new("[color=gray]Stymphalian Birds[/color]", "[color=purple]Piercing Quills[/color]", NO_PRICE, MONSTER_POWER_FAMILY_STYMPHALIAN_BIRDS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [10, 20, 30, 40])
# elite monsters
var MONSTER_SIREN_FAMILY = CoinFamily.new("[color=gray]Siren[/color]", "[color=purple]Lure into Blue[/color]", NO_PRICE, MONSTER_POWER_FAMILY_SIREN, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [25, 35, 45, 55])
var MONSTER_BASILISK_FAMILY = CoinFamily.new("[color=gray]Basilisk[/color]", "[color=purple]Gaze of Death[/color]", NO_PRICE, MONSTER_POWER_FAMILY_BASILISK, POWER_FAMILY_LOSE_ZERO_LIFE, _SpriteStyle.NEMESIS, [25, 35, 45, 55])
var MONSTER_GORGON_FAMILY = CoinFamily.new("[color=gray]Gorgon[/color]", "[color=purple]Petrifying Beauty[/color]", NO_PRICE, MONSTER_POWER_FAMILY_GORGON, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [25, 35, 45, 55])
var MONSTER_CHIMERA_FAMILY = CoinFamily.new("[color=gray]Chimera[/color]", "[color=purple]Great Blaze[/color]", NO_PRICE, MONSTER_POWER_FAMILY_CHIMERA, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [25, 35, 45, 55])


# nemesis
var MEDUSA_FAMILY = CoinFamily.new("[color=greenyellow]Medusa[/color]", "[color=purple]Mortal Sister[/color]", NO_PRICE, NEMESIS_POWER_FAMILY_MEDUSA_STONE, NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE, _SpriteStyle.NEMESIS, [80, 80, 80, 80])
var EURYALE_FAMILY = CoinFamily.new("[color=mediumaquamarine]Euryale[/color]", "[color=purple]Lamentful Cry[/color]", NO_PRICE, NEMESIS_POWER_FAMILY_EURYALE_STONE, NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY2, _SpriteStyle.NEMESIS, [80, 80, 80, 80])
var STHENO_FAMILY = CoinFamily.new("[color=rosybrown]Stheno[/color]", "[color=purple]Huntress of Man[/color]", NO_PRICE, NEMESIS_POWER_FAMILY_STHENO_STONE, NEMESIS_POWER_FAMILY_STHENO_STRAIN, _SpriteStyle.NEMESIS, [80, 80, 80, 80])

# trials
var TRIAL_IRON_FAMILY = CoinFamily.new("[color=darkgray]Trial of Iron[/color]", "[color=lightgray]Weighted Down[/color]", NO_PRICE, TRIAL_POWER_FAMILY_IRON, TRIAL_POWER_FAMILY_IRON, _SpriteStyle.PASSIVE)
var THORNS_FAMILY = CoinFamily.new("(DENOM) of Thorns", "[color=darkgray]Metallic Barb[/color]\nCannot pay tolls.", NO_PRICE, POWER_FAMILY_LOSE_SOULS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.THORNS)
var TRIAL_MISFORTUNE_FAMILY = CoinFamily.new("[color=purple]Trial of Misfortune[/color]", "[color=lightgray]Against the Odds[/color]", NO_PRICE, TRIAL_POWER_FAMILY_MISFORTUNE, TRIAL_POWER_FAMILY_MISFORTUNE, _SpriteStyle.PASSIVE)
var TRIAL_POLARIZATION_FAMILY = CoinFamily.new("[color=skyblue]Trial of Polarization[/color]", "[color=lightgray]One or Another[/color]", NO_PRICE, TRIAL_POWER_FAMILY_POLARIZATION, TRIAL_POWER_FAMILY_POLARIZATION, _SpriteStyle.PASSIVE)
var TRIAL_PAIN_FAMILY = CoinFamily.new("[color=tomato]Trial of Pain[/color]", "[color=lightgray]Pulse Amplifier[/color]", NO_PRICE, TRIAL_POWER_FAMILY_PAIN, TRIAL_POWER_FAMILY_PAIN, _SpriteStyle.PASSIVE)
var TRIAL_BLOOD_FAMILY = CoinFamily.new("[color=crimson]Trial of Blood[/color]", "[color=lightgray]Paid in Crimson[/color]", NO_PRICE, TRIAL_POWER_FAMILY_BLOOD, TRIAL_POWER_FAMILY_BLOOD, _SpriteStyle.PASSIVE)
var TRIAL_EQUIVALENCE_FAMILY = CoinFamily.new("[color=gold]Trial of Equivalence[/color]", "[color=lightgray]Fair, in a Way[/color]", NO_PRICE, TRIAL_POWER_FAMILY_EQUIVALENCE, TRIAL_POWER_FAMILY_EQUIVALENCE, _SpriteStyle.PASSIVE)
var TRIAL_FAMINE_FAMILY = CoinFamily.new("[color=burlywood]Trial of Famine[/color]", "[color=lightgray]Endless Hunger[/color]", NO_PRICE, TRIAL_POWER_FAMILY_FAMINE, TRIAL_POWER_FAMILY_FAMINE, _SpriteStyle.PASSIVE)
var TRIAL_TORTURE_FAMILY = CoinFamily.new("[color=darkred]Trial of Torture[/color]", "[color=lightgray]Boiling Veins[/color]", NO_PRICE, TRIAL_POWER_FAMILY_TORTURE, TRIAL_POWER_FAMILY_TORTURE, _SpriteStyle.PASSIVE)
var TRIAL_LIMITATION_FAMILY = CoinFamily.new("[color=lightgray]Trial of Limitation[/color]", "[color=lightgray]Less is Less[/color]", NO_PRICE, TRIAL_POWER_FAMILY_LIMITATION, TRIAL_POWER_FAMILY_LIMITATION, _SpriteStyle.PASSIVE)
var TRIAL_COLLAPSE_FAMILY = CoinFamily.new("[color=moccasin]Trial of Collapse[/color]", "[color=lightgray]Falling Down[/color]", NO_PRICE, TRIAL_POWER_FAMILY_COLLAPSE, TRIAL_POWER_FAMILY_COLLAPSE, _SpriteStyle.PASSIVE)
var TRIAL_SAPPING_FAMILY = CoinFamily.new("[color=paleturquoise]Trial of Sapping[]/color]", "[color=lightgray]Unnatural... fatigue...[/color]", NO_PRICE, TRIAL_POWER_FAMILY_SAPPING, TRIAL_POWER_FAMILY_SAPPING, _SpriteStyle.PASSIVE)
var TRIAL_OVERLOAD_FAMILY = CoinFamily.new("[color=steelblue]Trial of Overload[/color]", "[color=lightgray]Energy Untethered[/color]", NO_PRICE, TRIAL_POWER_FAMILY_OVERLOAD, TRIAL_POWER_FAMILY_OVERLOAD, _SpriteStyle.PASSIVE)

var CHARON_OBOL_FAMILY = CoinFamily.new("[color=magenta]Charon's Obol[/color]", "Last Chance", NO_PRICE, CHARON_POWER_LIFE, CHARON_POWER_DEATH, _SpriteStyle.CHARONS)

var _GOD_FAMILIES = [ZEUS_FAMILY, HERA_FAMILY, POSEIDON_FAMILY, DEMETER_FAMILY, APOLLO_FAMILY, ARTEMIS_FAMILY,
		ARES_FAMILY, ATHENA_FAMILY, HEPHAESTUS_FAMILY, APHRODITE_FAMILY, HERMES_FAMILY, HESTIA_FAMILY, DIONYSUS_FAMILY, HADES_FAMILY]

func random_family() -> CoinFamily:
	return choose_one([GENERIC_FAMILY] + _GOD_FAMILIES)

func random_god_family() -> CoinFamily:
	return choose_one(_GOD_FAMILIES)

func random_shop_denomination_for_round() -> Denomination:
	return choose_one(_current_round_shop_denoms())

func is_passive_active(passivePower: PowerFamily) -> bool:
	assert(passivePower.powerType == PowerType.PASSIVE)
	for row in COIN_ROWS:
		for coin in row.get_children():
			if coin.is_passive() and coin.get_active_power_family() == passivePower:
				return true
	return false
