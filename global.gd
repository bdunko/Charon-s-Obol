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
signal ante_changed
signal patron_changed
signal patron_uses_changed
signal rerolls_changed
signal souls_earned_this_round_changed
signal tutorial_state_changed
signal game_loaded

var character: CharacterData

func is_character(chara: Global.Character) -> bool:
	return character.character == chara

class CharacterData:
	var id: int
	var character: Global.Character
	var name: String
	var description: String:
		get:
			return Global.replace_placeholders(description)
	var introText: String
	var victoryDialogue: Array #[String]
	var victoryClosingLine: String
	
	func _init(ide: int, characterEnum: Global.Character, nameStr: String, introTxt: String, descriptionStr: String, victoryDlg: Array, victoryClosingLn: String):
		self.id = ide
		self.character = characterEnum
		self.name = nameStr
		self.introText = introTxt
		self.description = descriptionStr
		self.victoryDialogue = victoryDlg
		self.victoryClosingLine = victoryClosingLn

enum Character {
	ELEUSINIAN, LADY
}

enum TutorialState {
	INACTIVE,
	
	PROLOGUE_BEFORE_BOARDING, # set the scene and ask to board
	PROLOGUE_AFTER_BOARDING, # after the map animation plays, introduce the game
	
	ROUND1_OBOL_INTRODUCTION, # give an Obol, show the sides
	ROUND1_FIRST_HEADS, # after the first toss lands on heads
	ROUND1_FIRST_HEADS_ACCEPTED, # after the first toss is accepted
	ROUND1_FIRST_TAILS, # after the second toss lands on tails
	ROUND1_FIRST_TAILS_ACCEPTED, # after the second toss is accepted
	ROUND1_SHOP_BEFORE_BUYING_COIN, # introducing the shop
	ROUND1_SHOP_AFTER_BUYING_COIN, # after the player buys a coin
	
	ROUND2_POWER_INTRO, # explain powers
	ROUND2_POWER_ACTIVATED, # after activating a power
	ROUND2_POWER_USED, # after the power has been used
	ROUND2_POWER_UNUSABLE, # if a coin is on tails, it can't be used
	ROUND2_SHOP_BEFORE_UPGRADE, # explain upgrades
	ROUND2_SHOP_AFTER_UPGRADE, # some more text after upgrades
	
	ROUND3_PATRON_INTRO, # introduce the idea of the patron token
	ROUND3_PATRON_ACTIVATED, # after activating the token
	ROUND3_PATRON_USED, # after the token is used
	
	ROUND4_MONSTER_INTRO, #introduce monsters
	ROUND4_MONSTER_AFTER_TOSS, # after the monster tosses for first time
	ROUND4_VOYAGE, # explain the trials and tollgates
	
	ROUND5_INTRO, # flavor text
	
	ROUND6_TRIAL_INTRO, # explain the trial
	ROUND6_TRIAL_COMPLETED, # congrats/admonish
	
	ROUND7_TOLLGATE_INTRO, # explain the tollgate
	
	ENDING # ending text
}

var tutorialState: TutorialState:
	set(val):
		tutorialState = val
		emit_signal("tutorial_state_changed")

var CHARACTERS = {
	Character.LADY : CharacterData.new(0, Global.Character.LADY, "[color=brown]The Lady[/color]", 
		"\"Yet [color=springgreen]she[/color] was bound to return, willing or not, and in [color=springgreen]her[/color] passing the flowers wilted and trees weeped, for once [color=springgreen]she[/color] crossed the river, it would be many weeks until their renewal.\"\n-Homeric Hymn to Demeter",
		"Learn the rules of Charon's game.", 
		["So [color=springgreen]you've[/color] returned to [color=purple]me[/color] once more.",
		"[color=springgreen]You[/color] always were one to keep [color=purple]me[/color] waiting.",
		"Regardless, welcome back home."],
		"[color=springgreen]Persephone[/color]..."),
	
	Character.ELEUSINIAN : CharacterData.new(1, Global.Character.ELEUSINIAN, "[color=green]The Eleusinian[/color]", \
		"\"[color=purple]Death[/color] is nothing to us, since when we are, [color=purple]death[/color] has not come, and when [color=purple]death[/color] has come, we are not.\"\n-Epicurus",
		"The standard game.\nSurvive Trials, Tollgates, and a Nemesis to win.",
		["The birds are singing.", 
		"The sun is shining.",
		"People parade through the streets.",
		"All is at peace in the world.",
		"For with [color=springgreen]her[/color] return..."], 
		"...[color=springgreen]spring[/color] has come again.")
}

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
			return "Charon is Hostile\nCharon shall unleash his Malice."
		Difficulty.VENGEFUL:
			return "Charon is Malicious\nTrials shall have two modifiers and require more souls to pass."
		Difficulty.CRUEL:
			return "Charon is Cruel\nThe Nemesis is more powerful and Tollgates are more expensive."
		Difficulty.UNFAIR:
			return "Charon is Unfair\nYour coins shall land on tails 10% more often."
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

var souls_earned_this_round: int:
	set(val):
		souls_earned_this_round = val
		assert(souls_earned_this_round >= 0)
		emit_signal("souls_earned_this_round_changed")

const ARROWS_LIMIT = 20
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
		emit_signal("ante_changed")

var ante_modifier_this_round: int:
	set(val):
		ante_modifier_this_round = val
		emit_signal("ante_changed")

const COIN_TWEEN_TIME := 0.22
const DEFAULT_SHOP_PRICE_MULTIPLIER := 1.0
var shop_price_multiplier := DEFAULT_SHOP_PRICE_MULTIPLIER
const DEFAULT_SHOP_PRICE_FLAT_INCREASE := 0
var shop_price_flat_increase := DEFAULT_SHOP_PRICE_FLAT_INCREASE
var SHOP_MULTIPLIER_INCREASE := 0.33
var SHOP_FLAT_INCREASE := 2

var patron: Patron:
	set(val):
		patron = val
		emit_signal("patron_changed")

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

func clear_toll_coins() -> void:
	toll_coins_offered.clear()
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

func triangular(i: int) -> int:
	@warning_ignore("integer_division")
	return i*(i+1)/2

enum AnteFormula {
	THREE, FOUR, FIVE, SIX, SEVEN
}

# returns the life cost of a toss; min 0
func ante_cost() -> int:
	var base_ante = 0
	
	match(current_round_ante_formula()):
		AnteFormula.THREE:
			base_ante = flips_this_round * 3
		AnteFormula.FOUR:
			base_ante = flips_this_round * 4
		AnteFormula.FIVE:
			base_ante = flips_this_round * 5 
		AnteFormula.SIX:
			base_ante = flips_this_round * 6
		AnteFormula.SEVEN:
			base_ante = flips_this_round * 7
		_:
			assert(false, "Invalid ante formula...")
	
	return max(0, base_ante + ante_modifier_this_round)

enum RoundType {
	BOARDING, NORMAL, TRIAL1, TRIAL2, NEMESIS, TOLLGATE, END
}

class Round:
	var roundType: RoundType
	var lifeRegen: int
	var shopDenoms: Array
	var tollCost: int
	var monsterWaves: Array
	var quota: float
	var ante_formula: AnteFormula
	
	var trialData: TrialData
	
	func _init(roundTyp: RoundType, lifeRegn: int, shopDenms: Array, tollCst: int, rndQuota: int, mWaveDenoms: Array, anteForm: AnteFormula):
		self.roundType = roundTyp
		self.lifeRegen = lifeRegn
		self.shopDenoms = shopDenms
		self.tollCost = tollCst
		self.monsterWaves = mWaveDenoms
		self.quota = rndQuota
		self.trialData = null
		self.ante_formula = anteForm

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

var NO_MONSTERS = [[]]

var MONSTER_WAVE1 = [
	[Monster.new(Monster.Archetype.STANDARD, Denomination.OBOL)], # swarm
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

var MONSTER_WAVE_TUTORIAL = [
	[Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL)]
]

var MONSTER_WAVE_TUTORIAL2 = [
	[Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL)]
]

var VOYAGE

const _ANTE_LOW = AnteFormula.THREE
const _ANTE_MID = AnteFormula.FOUR
const _ANTE_HIGH = AnteFormula.FIVE

# STANDARD (2 Gate - 2 Trial [12])
# NNN1GNN2GNNB
var _VOYAGE_STANDARD = [
	Round.new(RoundType.BOARDING, 0, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW), 
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, MONSTER_WAVE1, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE2, _ANTE_LOW),
	Round.new(RoundType.TRIAL1, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 75, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.TOLLGATE, 0, [], 5, 0, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE3, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL], 0, 0, MONSTER_WAVE4, _ANTE_MID),
	Round.new(RoundType.TRIAL2, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 150, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.TOLLGATE, 0, [], 10, 0, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 0, MONSTER_WAVE5, _ANTE_HIGH),
	Round.new(RoundType.NORMAL, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 0, MONSTER_WAVE6, _ANTE_HIGH),
	Round.new(RoundType.NEMESIS, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 0, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.END, 0, [], 0, 0, NO_MONSTERS, _ANTE_HIGH)
]
 
# VARIANT (2 Gate - 2 Trial [12])
# NNNGNN1GNN2B
var _VOYAGE_VARIANT = [ 
	Round.new(RoundType.BOARDING, 0, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW), 
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, MONSTER_WAVE1, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE2, _ANTE_LOW),
	Round.new(RoundType.TOLLGATE, 0, [], 4, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE3, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL], 0, 0, MONSTER_WAVE4, _ANTE_MID),
	Round.new(RoundType.TRIAL1, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 100, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.TOLLGATE, 0, [], 12, 0, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL, Denomination.TRIOBOL], 0, 0, MONSTER_WAVE5, _ANTE_HIGH),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 0, MONSTER_WAVE6, _ANTE_HIGH),
	Round.new(RoundType.TRIAL2, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 150, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.NEMESIS, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 0, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.END, 0, [], 0, 0, NO_MONSTERS, _ANTE_HIGH)
]
	
# BACKLOADED (2 Gate - 3 Trial [111])
# NNNN1GN1GN1B 
var _VOYAGE_BACKLOADED = [
	Round.new(RoundType.BOARDING, 0, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW), 
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, MONSTER_WAVE1, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE2, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE4, _ANTE_MID),
	Round.new(RoundType.TRIAL1, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 80, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.TOLLGATE, 0, [], 8, 0, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE5, _ANTE_MID),
	Round.new(RoundType.TRIAL1, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 120, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.TOLLGATE, 0, [], 8, 0, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 0, MONSTER_WAVE6, _ANTE_HIGH),
	Round.new(RoundType.TRIAL1, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 160, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.NEMESIS, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 0, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.END, 0, [], 0, 0, NO_MONSTERS, _ANTE_HIGH)
]

# PARTITION (1 Gate - 2 Trial [22])
# NNNN2GNNN2B
var _VOYAGE_PARTITION = [
	Round.new(RoundType.BOARDING, 0, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW), 
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, MONSTER_WAVE1, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE2, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE3, _ANTE_LOW),
	Round.new(RoundType.TRIAL2, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 80, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.TOLLGATE, 0, [], 12, 0, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE4, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 0, MONSTER_WAVE5, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 0, MONSTER_WAVE6, _ANTE_HIGH),
	Round.new(RoundType.TRIAL2, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 160, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.NEMESIS, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 0,  NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.END, 0, [], 0, 0, NO_MONSTERS, _ANTE_HIGH)
]

# FRONTLOAD - (1 Gate - 3 Trial [112])
# NN1NN1GNN2B
var _VOYAGE_FRONTLOAD = [
	Round.new(RoundType.BOARDING, 0, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW), 
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, MONSTER_WAVE1, _ANTE_LOW),
	Round.new(RoundType.TRIAL1, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 60, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE2, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL], 0, 0, MONSTER_WAVE3, _ANTE_MID),
	Round.new(RoundType.TRIAL1, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 90, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.TOLLGATE, 0, [], 16, 0, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE4, _ANTE_HIGH),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 0, MONSTER_WAVE6, _ANTE_HIGH),
	Round.new(RoundType.TRIAL2, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 150, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.NEMESIS, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 0, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.END, 0, [], 0, 0, NO_MONSTERS, _ANTE_HIGH)
]

# INTERSPERSED - (3 Gate - 2 Trial [12)
# NNGN1NGN2NGNB
var _VOYAGE_INTERSPERSED = [
	Round.new(RoundType.BOARDING, 0, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW), 
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, MONSTER_WAVE1, _ANTE_LOW),
	Round.new(RoundType.TOLLGATE, 0, [], 3, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE2, _ANTE_LOW),
	Round.new(RoundType.TRIAL1, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 60, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE3, _ANTE_MID),
	Round.new(RoundType.TOLLGATE, 0, [], 6, 0, NO_MONSTERS, _ANTE_MID),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL], 0, 0, MONSTER_WAVE4, _ANTE_MID),
	Round.new(RoundType.TRIAL2, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 120, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.NORMAL, 100, [Denomination.DIOBOL, Denomination.TRIOBOL], 0, 0, MONSTER_WAVE5, _ANTE_HIGH),
	Round.new(RoundType.TOLLGATE, 0, [], 9, 0, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.NORMAL, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 0, MONSTER_WAVE6, _ANTE_HIGH),
	Round.new(RoundType.NEMESIS, 100, [Denomination.TRIOBOL, Denomination.TETROBOL], 0, 0, NO_MONSTERS, _ANTE_HIGH),
	Round.new(RoundType.END, 0, [], 0, 0, NO_MONSTERS, _ANTE_HIGH)
]

# TUTORIAL (2 Gate - 2 Trial [12])
# NNN1GNN2GNNB
var _VOYAGE_TUTORIAL = [
	Round.new(RoundType.BOARDING, 0, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW), 
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL], 0, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE_TUTORIAL, _ANTE_LOW),
	Round.new(RoundType.NORMAL, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 0, MONSTER_WAVE_TUTORIAL2, _ANTE_LOW),
	Round.new(RoundType.TRIAL1, 100, [Denomination.OBOL, Denomination.DIOBOL], 0, 100, NO_MONSTERS, _ANTE_LOW),
	Round.new(RoundType.TOLLGATE, 0, [], 8, 0, NO_MONSTERS, _ANTE_LOW), #8 is intentional to prevent possible bugs, don't increase
	Round.new(RoundType.END, 0, [], 0, 0, NO_MONSTERS, _ANTE_LOW)
]

const NUM_STANDARD_MONSTERS = 4
const NUM_ELITE_MONSTERS = 2
@onready var STANDARD_MONSTERS = [MONSTER_HELLHOUND_FAMILY, MONSTER_KOBALOS_FAMILY, MONSTER_ARAE_FAMILY, MONSTER_HARPY_FAMILY] + [MONSTER_CENTAUR_FAMILY, MONSTER_STYMPHALIAN_BIRDS_FAMILY]
@onready var ELITE_MONSTERS = [MONSTER_SIREN_FAMILY, MONSTER_CHIMERA_FAMILY, MONSTER_BASILISK_FAMILY]
var _standard_monster_pool = []
var _elite_monster_pool = []

func randomize_voyage() -> void:
	# special case - hardcoded setup for tutorial
	if is_character(Character.LADY):
		VOYAGE = _VOYAGE_TUTORIAL
		for rnd in VOYAGE:
			match(rnd.roundType):
				RoundType.TRIAL1:
					rnd.trialData = _PAIN_TRIAL
		_standard_monster_pool = [MONSTER_KOBALOS_FAMILY]
		_elite_monster_pool = [MONSTER_KOBALOS_FAMILY] # unused, but just in case...
		return
	
	# choose a voyage
	VOYAGE = choose_one_weighted(
		[_VOYAGE_STANDARD, _VOYAGE_VARIANT, _VOYAGE_BACKLOADED, _VOYAGE_PARTITION, _VOYAGE_FRONTLOAD, _VOYAGE_INTERSPERSED], 
		[300, 200, 125, 125, 125, 125])
	
	var possible_trials_lv1 = LV1_TRIALS.duplicate(true)
	var possible_trials_lv2 = LV2_TRIALS.duplicate(true)
	var possible_nemesis = NEMESES.duplicate(true)
	
	# randomize trials & nemesis
	for rnd in VOYAGE:
		# debug - seed trial
		match(rnd.roundType):
			RoundType.TRIAL1:
				var trial = Global.choose_one(possible_trials_lv1) if possible_trials_lv1.size() != 0 else Global.choose_one(LV1_TRIALS)
				possible_trials_lv1.erase(trial)
				rnd.trialData = trial
			RoundType.TRIAL2:
				var trial = Global.choose_one(possible_trials_lv2) if possible_trials_lv2.size() != 0 else Global.choose_one(LV2_TRIALS)
				possible_trials_lv2.erase(trial)
				rnd.trialData = trial
			RoundType.NEMESIS:
				var nemesis = Global.choose_one(possible_nemesis) if possible_nemesis.size() != 0 else Global.choose_one(NEMESES)
				possible_nemesis.erase(nemesis)
				rnd.trialData = nemesis
	
	# randomize the monster pool
	STANDARD_MONSTERS.shuffle()
	_standard_monster_pool = STANDARD_MONSTERS.slice(0, NUM_STANDARD_MONSTERS)
	_elite_monster_pool = ELITE_MONSTERS.slice(0, NUM_ELITE_MONSTERS)
	assert(_standard_monster_pool.size() == NUM_STANDARD_MONSTERS)
	assert(_elite_monster_pool.size() == NUM_ELITE_MONSTERS)

func voyage_length() -> int:
	return VOYAGE.size()

func current_round_type() -> RoundType:
	return VOYAGE[round_count-1].roundType

func current_round_life_regen() -> int:
	return VOYAGE[round_count-1].lifeRegen

func current_round_toll() -> int:
	return VOYAGE[round_count-1].tollCost

func current_round_quota() -> int:
	return VOYAGE[round_count-1].quota

func _current_round_shop_denoms() -> Array:
	return VOYAGE[round_count-1].shopDenoms

func current_round_ante_formula() -> AnteFormula:
	return VOYAGE[round_count-1].ante_formula

func did_ante_increase() -> bool:
	if round_count == 0 or round_count == 1:
		return false
	return VOYAGE[round_count-1].ante_formula != VOYAGE[round_count-2].ante_formula

# will be obsoleted eventually
func current_round_patron_uses() -> int:
	return 2

# returns an array of [monster_family, denom] pairs for current round
func current_round_enemy_coin_data() -> Array:
	var coin_data = []
	
	if current_round_type() == RoundType.TRIAL1:
		for trialFamily in VOYAGE[round_count-1].trialData.coinFamilies:
			coin_data.append([trialFamily, Denomination.OBOL])
	elif current_round_type() == RoundType.TRIAL2:
		for trialFamily in VOYAGE[round_count-1].trialData.coinFamilies:
			coin_data.append([trialFamily, Denomination.DIOBOL])
	elif current_round_type() == RoundType.NEMESIS:
		for nemesisFamily in VOYAGE[round_count-1].trialData.coinFamilies:
			coin_data.append([nemesisFamily, Denomination.TETROBOL])
	else:
		var monsters = Global.choose_one(VOYAGE[round_count-1].monsterWaves)
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

func is_current_round_trial() -> bool:
	var rtype = current_round_type()
	return rtype == RoundType.TRIAL1 or rtype == RoundType.TRIAL2 or rtype == RoundType.NEMESIS

func is_next_round_end() -> bool:
	if VOYAGE.size() == round_count:
		return false #next round is null lol - this should never happen though
	return VOYAGE[round_count].roundType == RoundType.END

func get_tollgate_cost(tollgateIndex: int) -> int:
	var tollgates = 0
	for rnd in VOYAGE:
		if rnd.roundType == RoundType.TOLLGATE:
			tollgates += 1
			if tollgates == tollgateIndex:
				return rnd.tollCost
	return 0

func _get_first_round_of_type(roundType: RoundType) -> TrialData:
	for rnd in VOYAGE:
		if rnd.roundType == roundType:
			return rnd.trialData
	return null

class TrialData:
	var name: String
	var coinFamilies: Array
	var description: String
	
	func _init(trialName: String, trialCoinFamilies: Array, trialDescription: String):
		self.name = trialName
		self.coinFamilies = trialCoinFamilies
		self.description = trialDescription

@onready var NEMESES = [
	TrialData.new("[color=lightgreen]The Gorgon Sisters[/color]", [EURYALE_FAMILY, MEDUSA_FAMILY, STHENO_FAMILY], "These three sisters will render you helpless with their petrifying gaze.")
]

# extra reference to this for use in tutorial
@onready var _PAIN_TRIAL = TrialData.new(TRIAL_PAIN_FAMILY.coin_name, [TRIAL_PAIN_FAMILY], TRIAL_POWER_FAMILY_PAIN.description)
@onready var LV1_TRIALS = [
	TrialData.new(TRIAL_IRON_FAMILY.coin_name, [TRIAL_IRON_FAMILY], TRIAL_POWER_FAMILY_IRON.description),
	TrialData.new(TRIAL_MISFORTUNE_FAMILY.coin_name, [TRIAL_MISFORTUNE_FAMILY], TRIAL_POWER_FAMILY_MISFORTUNE.description),
	#TrialData.new("Fossilization", [GENERIC_FAMILY], "When the trial begins, your highest value coin is turned to Stone."),
	#TrialData.new("Silence", [GENERIC_FAMILY], "Your leftmost 2 coins are Blank."),
	#TrialData.new("Silence", [GENERIC_FAMILY], "Your rightmost 2 coins are Blank."),
	#TrialData.new("Exhaustion", [GENERIC_FAMILY], "Every 3 payoffs, your lowest value coin is destroyed."),
	TrialData.new(TRIAL_EQUIVALENCE_FAMILY.coin_name, [TRIAL_EQUIVALENCE_FAMILY], TRIAL_POWER_FAMILY_EQUIVALENCE.description),
	_PAIN_TRIAL,
	TrialData.new(TRIAL_BLOOD_FAMILY.coin_name, [TRIAL_BLOOD_FAMILY], TRIAL_POWER_FAMILY_BLOOD.description),
	#TrialData.new("Draining", [GENERIC_FAMILY], "Using a power also drains a charge from each adjacent coin."),
	#TrialData.new("Suffering", [GENERIC_FAMILY], "Ante starts at 4."),
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
	var description: String:
		get:
			return Global.replace_placeholders(description)
	var show_uses: bool
	var uses_for_denom: Array[int]
	var powerType: PowerType
	var icon_path: String
	
	func _init(desc: String, uses_per_denom: Array[int], pwrType: PowerType, shw_uses: bool, icon: String) -> void:
		self.description = desc
		self.uses_for_denom = uses_per_denom
		self.powerType = pwrType
		self.show_uses = shw_uses
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
const SHOW_USES = true
const ONLY_SHOW_ICON = false

@onready var LOSE_LIFE_POWERS = [POWER_FAMILY_LOSE_LIFE, POWER_FAMILY_LOSE_LIFE_INCREASED, POWER_FAMILY_LOSE_LIFE_DOUBLED, POWER_FAMILY_LOSE_LIFE_THORNS]
var POWER_FAMILY_LOSE_LIFE = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [2, 4, 7, 10], PowerType.PAYOFF, SHOW_USES, "res://assets/icons/soul_fragment_red_icon.png")
var POWER_FAMILY_LOSE_LIFE_INCREASED = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [4, 6, 9, 12], PowerType.PAYOFF, SHOW_USES, "res://assets/icons/soul_fragment_red_icon.png")
var POWER_FAMILY_LOSE_LIFE_DOUBLED = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [4, 8, 14, 20], PowerType.PAYOFF, SHOW_USES, "res://assets/icons/soul_fragment_red_icon.png")
var POWER_FAMILY_LOSE_LIFE_THORNS = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [1, 2, 3, 4], PowerType.PAYOFF, SHOW_USES, "res://assets/icons/soul_fragment_red_icon.png")
var POWER_FAMILY_LOSE_ZERO_LIFE = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [0, 0, 0, 0], PowerType.PAYOFF, SHOW_USES, "res://assets/icons/soul_fragment_red_icon.png")

var POWER_FAMILY_LOSE_SOULS_THORNS = PowerFamily.new("-(CURRENT_CHARGES)(SOULS)", [1, 2, 3, 4], PowerType.PAYOFF, SHOW_USES, "res://assets/icons/soul_fragment_blue_icon.png")

var POWER_FAMILY_GAIN_SOULS = PowerFamily.new("+(CURRENT_CHARGES)(SOULS)", [5, 7, 10, 13], PowerType.PAYOFF, SHOW_USES, "res://assets/icons/soul_fragment_blue_icon.png")
var POWER_FAMILY_GAIN_LIFE = PowerFamily.new("+(1+1_PER_DENOM)(HEAL)", [1, 1, 1, 1], PowerType.POWER, SHOW_USES, "res://assets/icons/demeter_icon.png")
var POWER_FAMILY_REFLIP = PowerFamily.new("Reflip another coin.", [2, 3, 4, 5], PowerType.POWER, SHOW_USES,"res://assets/icons/zeus_icon.png")
var POWER_FAMILY_FREEZE = PowerFamily.new("(FREEZE) another coin.", [1, 2, 3, 4], PowerType.POWER, SHOW_USES,"res://assets/icons/poseidon_icon.png")
var POWER_FAMILY_REFLIP_AND_NEIGHBORS = PowerFamily.new("Reflip a coin and its neighbors.", [1, 2, 3, 4], PowerType.POWER, SHOW_USES,"res://assets/icons/hera_icon.png")
var POWER_FAMILY_GAIN_ARROW = PowerFamily.new("+(1_PER_DENOM)(ARROW).", [1, 1, 1, 1], PowerType.POWER, SHOW_USES,"res://assets/icons/artemis_icon.png")
var POWER_FAMILY_TURN_AND_BLURSE = PowerFamily.new("Turn a coin to its other face. Then, if it's (HEADS), (CURSE) it, if it's (TAILS) (BLESS) it.", [1, 2, 3, 4], PowerType.POWER, SHOW_USES,"res://assets/icons/apollo_icon.png")
var POWER_FAMILY_REFLIP_ALL = PowerFamily.new("Reflip all coins.", [1, 2, 3, 4], PowerType.POWER, SHOW_USES,"res://assets/icons/ares_icon.png")
var POWER_FAMILY_REDUCE_PENALTY = PowerFamily.new("Reduce another coin's (LIFE) penalty for this round.", [2, 3, 4, 5], PowerType.POWER, SHOW_USES,"res://assets/icons/athena_icon.png")
var POWER_FAMILY_UPGRADE_AND_IGNITE = PowerFamily.new("Upgrade (HEPHAESTUS_OPTIONS) and (IGNITE) it.", [1, 1, 1, 2], PowerType.POWER, SHOW_USES,"res://assets/icons/hephaestus_icon.png")
var POWER_FAMILY_COPY_FOR_TOSS = PowerFamily.new("Copy another coin's power for this toss.", [1, 1, 1, 1], PowerType.POWER, SHOW_USES,"res://assets/icons/aphrodite_icon.png")
var POWER_FAMILY_EXCHANGE = PowerFamily.new("Trade a coin for another of equal value.", [1, 2, 3, 4], PowerType.POWER, SHOW_USES,"res://assets/icons/hermes_icon.png")
var POWER_FAMILY_MAKE_LUCKY = PowerFamily.new("Make another coin (LUCKY).", [1, 2, 3, 4], PowerType.POWER, SHOW_USES,"res://assets/icons/hestia_icon.png")
var POWER_FAMILY_GAIN_COIN = PowerFamily.new("Gain a random Obol.", [1, 2, 3, 4], PowerType.POWER, SHOW_USES,"res://assets/icons/dionysus_icon.png")
var POWER_FAMILY_DOWNGRADE_FOR_LIFE = PowerFamily.new("Downgrade a coin. If the coin was yours, +(HADES_SELF_GAIN)(LIFE); if the coin was a monster, -(HADES_MONSTER_COST)(LIFE).", [1, 1, 1, 1], PowerType.POWER, SHOW_USES,"res://assets/icons/hades_icon.png")

var POWER_FAMILY_ARROW_REFLIP = PowerFamily.new("Reflip a coin.", [0, 0, 0, 0], PowerType.POWER, SHOW_USES,"")

var MONSTER_POWER_FAMILY_HELLHOUND = PowerFamily.new("(IGNITE) this coin.", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/hellhound_icon.png")
var MONSTER_POWER_FAMILY_KOBALOS = PowerFamily.new("A coin becomes (UNLUCKY).", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/kobalos_icon.png")
var MONSTER_POWER_FAMILY_ARAE = PowerFamily.new("(CURSE) a coin.", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/arae_icon.png")
var MONSTER_POWER_FAMILY_HARPY = PowerFamily.new("(BLANK) a coin.", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/harpy_icon.png")

var MONSTER_POWER_FAMILY_CENTAUR_HEADS = PowerFamily.new("A random coin becomes (LUCKY).", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/centaur_heads_icon.png")
var MONSTER_POWER_FAMILY_CENTAUR_TAILS = PowerFamily.new("A random coin becomes (UNLUCKY).", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/centaur_tails_icon.png")
var MONSTER_POWER_FAMILY_STYMPHALIAN_BIRDS = PowerFamily.new("+1(ARROW).", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/stymphalian_birds_icon.png")

var MONSTER_POWER_FAMILY_CHIMERA = PowerFamily.new("(IGNITE) a coin.", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/chimera_icon.png")
var MONSTER_POWER_FAMILY_SIREN = PowerFamily.new("(FREEZE) each (TAILS) coin.", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/siren_icon.png")
var MONSTER_POWER_FAMILY_BASILISK = PowerFamily.new("Lose half your (LIFE).", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/basilisk_icon.png")
var MONSTER_POWER_FAMILY_GORGON = PowerFamily.new("Turn a coin to (STONE).", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/monster/gorgon_icon.png")

var NEMESIS_POWER_FAMILY_MEDUSA_STONE = PowerFamily.new("Turn a coin to (STONE).", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/nemesis/medusa_icon.png")
const MEDUSA_DOWNGRADE_AMOUNT = 2
var NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE = PowerFamily.new("Twice, downgrade the most valuable coin.", [2, 2, 2, 2], PowerType.PAYOFF, SHOW_USES, "res://assets/icons/nemesis/downgrade_icon.png")
var NEMESIS_POWER_FAMILY_EURYALE_STONE = PowerFamily.new("Turn a coin to (STONE).", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/nemesis/euryale_icon.png")
const EURYALE_UNLUCKY_AMOUNT = 2
var NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY = PowerFamily.new("Make 2 coins (UNLUCKY).", [2, 2, 2, 2], PowerType.PAYOFF, SHOW_USES, "res://assets/icons/nemesis/unlucky_icon.png")
var NEMESIS_POWER_FAMILY_STHENO_STONE = PowerFamily.new("Turn a coin to (STONE)", [1, 1, 1, 1], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/nemesis/stheno_icon.png")
const STHENO_CURSE_AMOUNT = 2
var NEMESIS_POWER_FAMILY_STHENO_CURSE = PowerFamily.new("(CURSE) 2 coins.", [2, 2, 2, 2], PowerType.PAYOFF, SHOW_USES, "res://assets/icons/nemesis/curse_icon.png")

var TRIAL_POWER_FAMILY_IRON = PowerFamily.new("When the trial begins, you gain 2 Obols of Thorns. (If not enough space, destroy the rightmost coin until there is.)", [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/iron_icon.png")
const MISFORTUNE_QUANTITY = 3
var TRIAL_POWER_FAMILY_MISFORTUNE = PowerFamily.new("When the trial begins and after each payoff, three of your coins become (UNLUCKY).", [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/misfortune_icon.png")
var TRIAL_POWER_FAMILY_PAIN = PowerFamily.new("Damage you take from (LIFE) penalties is tripled.", [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/pain_icon.png")
const BLOOD_COST = 1
var TRIAL_POWER_FAMILY_BLOOD = PowerFamily.new("Using a power costs %d(LIFE)." % BLOOD_COST, [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/blood_icon.png")
var TRIAL_POWER_FAMILY_EQUIVALENCE = PowerFamily.new("After a coin lands on (HEADS), it becomes (UNLUCKY). After a coin lands on (TAILS), it becomes (LUCKY).", [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/equivalence_icon.png")

var TRIAL_POWER_FAMILY_FAMINE = PowerFamily.new("You do not replenish (HEAL) at the start of the round.", [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/famine_icon.png")
var TRIAL_POWER_FAMILY_TORTURE = PowerFamily.new("After payoff, your highest value (HEADS) coin is downgraded.", [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/torture_icon.png")
var TRIAL_POWER_FAMILY_LIMITATION = PowerFamily.new("Reduce any payoffs less than 10(SOULS) to 0.", [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/limitation_icon.png")
var TRIAL_POWER_FAMILY_COLLAPSE = PowerFamily.new("After payoff, (CURSE) and (FREEZE) each coin on (TAILS).", [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/collapse_icon.png")
var TRIAL_POWER_FAMILY_SAPPING = PowerFamily.new("Coins replenish only a single power charge each toss.", [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/sapping_icon.png")
var TRIAL_POWER_FAMILY_OVERLOAD = PowerFamily.new("After payoff, you lose 1(LIFE) for each unspent power charge on a (HEADS) coin.", [0, 0, 0, 0], PowerType.PASSIVE, ONLY_SHOW_ICON, "res://assets/icons/trial/overload_icon.png")

var CHARON_POWER_DEATH = PowerFamily.new("(CHARON_DEATH) Die.", [0, 0, 0, 0], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/charon_death_icon.png")
var CHARON_POWER_LIFE = PowerFamily.new("(CHARON_LIFE) Live. End the round.", [0, 0, 0, 0], PowerType.PAYOFF, ONLY_SHOW_ICON, "res://assets/icons/charon_life_icon.png")

func replace_placeholders(tooltip: String) -> String:
	# images
	tooltip = tooltip.replace("(HEADS)", "[img=12x13]res://assets/icons/heads_icon.png[/img]")
	tooltip = tooltip.replace("(TAILS)", "[img=12x13]res://assets/icons/tails_icon.png[/img]")
	tooltip = tooltip.replace("(COIN)", "[img=12x13]res://assets/icons/coin_icon.png[/img]")
	tooltip = tooltip.replace("(ARROW)", "[img=10x13]res://assets/icons/arrow_icon.png[/img]")
	tooltip = tooltip.replace("(LIFE)", "[img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img]")
	tooltip = tooltip.replace("(HEAL)", "[img=10x13]res://assets/icons/soul_fragment_red_heal_icon.png[/img]")	
	tooltip = tooltip.replace("(SOULS)", "[img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]")
	
	tooltip = tooltip.replace("(CHARON_DEATH)", "[img=10x13]res://assets/icons/charon_death_icon.png[/img]")
	tooltip = tooltip.replace("(CHARON_LIFE)", "[img=10x13]res://assets/icons/charon_life_icon.png[/img]")
	
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
signal left_click_input

var DEBUG = true # utility flag for debugging mode

var RNG = RandomNumberGenerator.new()

const _SCREENSHOT_ENABLED = true
const _SCREENSHOT_KEY = KEY_EQUAL
const _SCREENSHOT_PATH_FORMAT = "res://screenshots/Obol_%s_%s.png"
func take_screenshot(): # Function for taking screenshots and saving them
	var date: String = Time.get_date_string_from_system().replace(".","_") 
	var time: String = Time.get_time_string_from_system().replace(":","")
	var screenshot_path = _SCREENSHOT_PATH_FORMAT % [date, time] # the path for our scree"Game/Table/CoinRow"nshot.
	var image = get_viewport().get_texture().get_image() # We get what our player sees
	image.save_png(screenshot_path)

var _mouse_down = false
var _last_any_input_time = 0.0
const _MIN_TIME_BETWEEN_ANY_INPUT_MS = 100 #0.2 sec
func _input(event: InputEvent) -> void:
	if DEBUG and Input.is_key_pressed(KEY_SPACE):
		breakpoint
	if DEBUG and Input.is_key_pressed(_SCREENSHOT_KEY):
		take_screenshot()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_mouse_down = true
				if Time.get_ticks_msec()  - _last_any_input_time >= _MIN_TIME_BETWEEN_ANY_INPUT_MS:
					_last_any_input_time = Time.get_ticks_msec()
					emit_signal("left_click_input")
			else:
				_mouse_down = false

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

# Randomly return 1 element of options, with the corresponding index of weight determining likelihood
func choose_one_weighted(options, weights):
	if options.size() != weights.size():
		assert(options.size() == weights.size(), "options and weights should be same size.")
		return choose_one(options)
	
	var sum = 0
	for w in weights:
		sum += w

	var r = Global.RNG.randi_range(1, sum)
	for i in range(0, options.size()):
		r -= weights[i]
		if r <= 0:
			return options[i]

# Removes and frees each child of the given node
func free_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

# creates a delay of a given time
# await on this function call
func delay(delay_in_secs: float):
	await get_tree().create_timer(delay_in_secs).timeout

# dictionary of global timers; String -> Timer
var _timers = {}

# creates a new timer with the given wait_time. 
# if a timer with this key already exists, returns it instead and update the wait_time.
func create_timer(key: String, wait_time: float, autostart: bool = true) -> Timer:
	if _timers.has(key):
		_timers[key].wait_time = wait_time
		return _timers[key]
	var timer = Timer.new()
	timer.autostart = autostart
	timer.wait_time = wait_time
	_timers[key] = timer
	add_child(timer)
	if autostart:
		timer.start()
	return timer

func get_timer(key: String) -> Timer:
	if not _timers.has(key):
		return null
	return _timers[key]

func delete_timer(key: String) -> bool:
	if not _timers.has(key):
		return false
	_timers[key].queue_free()
	_timers.erase(key)
	return true

# helper class for managing a tween which may be interrupted by another tween on the same property
class ManagedTween:
	var _object: Object
	var _property: NodePath
	var _tween: Tween = null
	var _tween_final_val: Variant = null
	var _tween_duration: float = 0.0
	
	func _init(obj: Object, prop: NodePath):
		_object = obj
		_property = prop
	
	func tween(final_val: Variant, duration: float, trans := Tween.TransitionType.TRANS_LINEAR, easing := Tween.EaseType.EASE_IN_OUT):
		if _tween:
			if _tween_final_val == final_val and _tween_duration == duration:
				return
			_tween.kill()
		_tween = _object.create_tween()
		_tween.tween_property(_object, _property, final_val, duration).set_trans(trans).set_ease(easing)
		_tween_final_val = final_val
		_tween_duration = duration
		await _tween.finished
	
	func kill() -> void:
		if _tween:
			_tween.kill()

# helpers for moving something to a specific z index while remembering its previous z-index
# mostly useful for tutorials and the like
var _z_map = {}
func temporary_set_z(node: Node2D, z: int) -> void:
	_z_map[node] = node.z_index
	node.z_index = z

func restore_z(node: Node2D) -> void:
	assert(_z_map.has(node))
	node.z_index = _z_map[node]
	_z_map.erase(node)


# todo - this should be in another file, PatronData I think?
class Patron:
	var god_name: String
	var token_name: String
	var description: String:
		get:
			return Global.replace_placeholders(description)
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
var PATRON_POWER_FAMILY_APHRODITE = PowerFamily.new("Aphrodite", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_APOLLO = PowerFamily.new("Apollo", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_ARES = PowerFamily.new("Ares", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_ARTEMIS = PowerFamily.new("Artemis", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_ATHENA = PowerFamily.new("Athena", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_DEMETER = PowerFamily.new("Demeter", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_DIONYSUS = PowerFamily.new("Dionysus", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_HADES = PowerFamily.new("Hades", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_HEPHAESTUS = PowerFamily.new("Hephaestus", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_HERA = PowerFamily.new("Hera", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_HERMES = PowerFamily.new("Hermes", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_HESTIA = PowerFamily.new("Hestia", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_POSEIDON = PowerFamily.new("Poseidon", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");
var PATRON_POWER_FAMILY_ZEUS = PowerFamily.new("Zeus", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");

var PATRON_POWER_FAMILY_CHARON = PowerFamily.new("Charon", [1, 2, 3, 4], PowerType.POWER, ONLY_SHOW_ICON, "");

var immediate_patron_powers = [PATRON_POWER_FAMILY_DEMETER, PATRON_POWER_FAMILY_APOLLO, PATRON_POWER_FAMILY_ARTEMIS, PATRON_POWER_FAMILY_ARES, PATRON_POWER_FAMILY_APHRODITE, PATRON_POWER_FAMILY_DIONYSUS]


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
	
	CHARON # used for tutorial
}

const HADES_PATRON_MULTIPLIER = 10

var _GODLESS_STATUE = preload("res://components/patron_statues/godless.tscn")
@onready var PATRONS = [
	Patron.new("[color=lightpink]Aphrodite[/color]", "[color=lightpink]Aphrodite's Heart[/color]", "Recharge all your coins.", PatronEnum.APHRODITE, PATRON_POWER_FAMILY_APHRODITE, preload("res://components/patron_statues/aphrodite.tscn"), preload("res://components/patron_tokens/aphrodite.tscn"), [APHRODITE_FAMILY]),
	Patron.new("[color=orange]Apollo[/color]", "[color=orange]Apollo's Lyre[/color]", "Turn all coins to their other face.", PatronEnum.APOLLO, PATRON_POWER_FAMILY_APOLLO, preload("res://components/patron_statues/apollo.tscn"), preload("res://components/patron_tokens/apollo.tscn"), [APOLLO_FAMILY]),
	Patron.new("[color=indianred]Ares[/color]", "[color=indianred]Are's Spear[/color]", "Reflip all coins and remove all their statuses.", PatronEnum.ARES, PATRON_POWER_FAMILY_ARES, preload("res://components/patron_statues/ares.tscn"), preload("res://components/patron_tokens/ares.tscn"), [ARES_FAMILY]),
	Patron.new("[color=purple]Artemis[/color]", "[color=purple]Artemis's Bow[/color]", "Turn all coins to (TAILS), then gain 1 (ARROW) for each.", PatronEnum.ARTEMIS, PATRON_POWER_FAMILY_ARTEMIS, preload("res://components/patron_statues/artemis.tscn"), preload("res://components/patron_tokens/artemis.tscn"), [ARTEMIS_FAMILY]),
	Patron.new("[color=cyan]Athena[/color]", "[color=cyan]Athena's Aegis[/color]", "Permanently reduce a coin's (LIFE) penalty by 1.", PatronEnum.ATHENA, PATRON_POWER_FAMILY_ATHENA, preload("res://components/patron_statues/athena.tscn"), preload("res://components/patron_tokens/athena.tscn"), [ATHENA_FAMILY]),
	Patron.new("[color=lightgreen]Demeter[/color]", "[color=lightgreen]Demeter's Wheat[/color]", "For each coin on (TAILS), +(HEAL) equal to its (LIFE) penalty. ", PatronEnum.DEMETER, PATRON_POWER_FAMILY_DEMETER, preload("res://components/patron_statues/demeter.tscn"), preload("res://components/patron_tokens/demeter.tscn"), [DEMETER_FAMILY]),
	Patron.new("[color=plum]Dionysus[/color]", "[color=plum]Dionysus's Chalice[/color]", "Gain a random Obol and make it (LUCKY).", PatronEnum.DIONYSUS, PATRON_POWER_FAMILY_DIONYSUS, preload("res://components/patron_statues/dionysus.tscn"), preload("res://components/patron_tokens/dionysus.tscn"), [DIONYSUS_FAMILY]),
	Patron.new("[color=slateblue]Hades[/color]", "[color=slateblue]Hades's Bident[/color]", "Destroy a coin you own, then gain (SOULS) and heal (LIFE) equal to %dx its value(COIN)." % HADES_PATRON_MULTIPLIER, PatronEnum.HADES, PATRON_POWER_FAMILY_HADES, preload("res://components/patron_statues/hades.tscn"), preload("res://components/patron_tokens/hades.tscn"), [HADES_FAMILY]),
	Patron.new("[color=sienna]Hephaestus[/color]", "[color=sienna]Hephaestus's Hammer[/color]", "Choose a coin. Downgrade it, then upgrade its neighbors.", PatronEnum.HEPHAESTUS, PATRON_POWER_FAMILY_HEPHAESTUS, preload("res://components/patron_statues/hephaestus.tscn"), preload("res://components/patron_tokens/hephaestus.tscn"), [HEPHAESTUS_FAMILY]),
	Patron.new("[color=silver]Hera[/color]", "[color=silver]Hera's Lotus[/color]", "Turn a coin and its neighbors to their other face.", PatronEnum.HERA, PATRON_POWER_FAMILY_HERA, preload("res://components/patron_statues/hera.tscn"), preload("res://components/patron_tokens/hera.tscn"), [HERA_FAMILY]),
	Patron.new("[color=lightskyblue]Hermes[/color]", "[color=lightskyblue]Herme's Caduceus[/color]", "Trade a coin for another of equal or [color=lightgray](25% of the time)[/color] greater value.", PatronEnum.HERMES, PATRON_POWER_FAMILY_HERMES, preload("res://components/patron_statues/hermes.tscn"), preload("res://components/patron_tokens/hermes.tscn"), [HERMES_FAMILY]),
	Patron.new("[color=sandybrown]Hestia[/color]", "[color=sandybrown]Hestia's Warmth[/color]", "(BLESS) a coin and make it (LUCKY).", PatronEnum.HESTIA, PATRON_POWER_FAMILY_HESTIA, preload("res://components/patron_statues/hestia.tscn"), preload("res://components/patron_tokens/hestia.tscn"), [HESTIA_FAMILY]),
	Patron.new("[color=lightblue]Poseidon[/color]", "[color=lightblue]Poseidon's Trident[/color]", "(FREEZE) a coin and its neighbors.", PatronEnum.POSEIDON, PATRON_POWER_FAMILY_POSEIDON, preload("res://components/patron_statues/poseidon.tscn"), preload("res://components/patron_tokens/poseidon.tscn"), [POSEIDON_FAMILY]),
	Patron.new("[color=yellow]Zeus[/color]", "[color=yellow]Zeus's Thunderbolt[/color]", "(SUPERCHARGE) a coin, then reflip it.", PatronEnum.ZEUS, PATRON_POWER_FAMILY_ZEUS, preload("res://components/patron_statues/zeus.tscn"), preload("res://components/patron_tokens/zeus.tscn"), [ZEUS_FAMILY]),

	Patron.new("[color=mediumorchid]Charon[/color]", "[color=mediumorchid]Charon's Oar[/color]", "Turn a coin to its other face and make it (LUCKY).", PatronEnum.CHARON, PATRON_POWER_FAMILY_CHARON, preload("res://components/patron_statues/zeus.tscn"), preload("res://components/patron_tokens/charon.tscn"), [HADES_FAMILY])
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
	var id: int
	
	var coin_name: String
	var subtitle: String
	
	var store_price_for_denom: Array
	var heads_power_family: PowerFamily
	var tails_power_family: PowerFamily

	var appeasal_price_for_denom: Array
	
	var _sprite_style: _SpriteStyle
	
	func _init(ide: int, nme: String, 
			sub_title: String, prices: Array,
			heads_pwr: PowerFamily, tails_pwr: PowerFamily,
			style: _SpriteStyle, app_price := [NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE]) -> void:
		id = ide
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
const CHEAP = [3, 10, 23, 45]
const STANDARD = [5, 13, 28, 50] 
const PRICY = [6, 15, 32, 55] 
const RICH = [10, 20, 41, 64]

# Coin Families
# stores a list of all player coins (coins that can be bought in shop)
@onready var _ALL_PLAYER_COINS = [GENERIC_FAMILY, 
	ZEUS_FAMILY, HERA_FAMILY, POSEIDON_FAMILY, DEMETER_FAMILY, APOLLO_FAMILY, ARTEMIS_FAMILY,
	ARES_FAMILY, ATHENA_FAMILY, HEPHAESTUS_FAMILY, APHRODITE_FAMILY, HERMES_FAMILY, HESTIA_FAMILY, DIONYSUS_FAMILY, HADES_FAMILY]

# payoff coins
var GENERIC_FAMILY = CoinFamily.new(0, "(DENOM)", "[color=gray]Common Currency[/color]", CHEAP, POWER_FAMILY_GAIN_SOULS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.PAYOFF)

# power coins
var ZEUS_FAMILY = CoinFamily.new(1, "(DENOM) of Zeus", "[color=yellow]Lighting Strikes[/color]", STANDARD, POWER_FAMILY_REFLIP, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HERA_FAMILY = CoinFamily.new(2, "(DENOM) of Hera", "[color=silver]Envious Wrath[/color]", STANDARD, POWER_FAMILY_REFLIP_AND_NEIGHBORS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var POSEIDON_FAMILY = CoinFamily.new(3, "(DENOM) of Poseidon", "[color=lightblue]Wave of Ice[/color]", RICH, POWER_FAMILY_FREEZE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var DEMETER_FAMILY = CoinFamily.new(4, "(DENOM) of Demeter", "[color=lightgreen]Grow Ever Stronger[/color]", STANDARD, POWER_FAMILY_GAIN_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var APOLLO_FAMILY = CoinFamily.new(5, "(DENOM) of Apollo", "[color=orange]Harmonic, Melodic[/color]", STANDARD, POWER_FAMILY_TURN_AND_BLURSE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var ARTEMIS_FAMILY = CoinFamily.new(6, "(DENOM) of Artemis", "[color=purple]Arrows of Night[/color]", PRICY, POWER_FAMILY_GAIN_ARROW, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var ARES_FAMILY = CoinFamily.new(7, "(DENOM) of Ares", "[color=indianred]Chaos of War[/color]", STANDARD, POWER_FAMILY_REFLIP_ALL, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var ATHENA_FAMILY = CoinFamily.new(8, "(DENOM) of Athena", "[color=cyan]Phalanx Strategy[/color]", RICH, POWER_FAMILY_REDUCE_PENALTY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HEPHAESTUS_FAMILY = CoinFamily.new(9, "(DENOM) of Hephaestus", "[color=sienna]Forged With Fire[/color]", RICH, POWER_FAMILY_UPGRADE_AND_IGNITE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var APHRODITE_FAMILY = CoinFamily.new(10, "(DENOM) of Aphrodite", "[color=lightpink]True Lovers, Unified[/color]", STANDARD, POWER_FAMILY_COPY_FOR_TOSS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HERMES_FAMILY = CoinFamily.new(11, "(DENOM) of Hermes", "[color=lightskyblue]From Lands Distant[/color]", PRICY, POWER_FAMILY_EXCHANGE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HESTIA_FAMILY = CoinFamily.new(12, "(DENOM) of Hestia", "[color=sandybrown]Weary Bones Rest[/color]", STANDARD,  POWER_FAMILY_MAKE_LUCKY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var DIONYSUS_FAMILY = CoinFamily.new(13, "(DENOM) of Dionysus", "[color=plum]Wanton Revelry[/color]", STANDARD, POWER_FAMILY_GAIN_COIN, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
const HADES_SELF_GAIN = [7, 9, 11, 13]
const HADES_MONSTER_COST = [7, 5, 3, 1]
var HADES_FAMILY = CoinFamily.new(14, "(DENOM) of Hades", "[color=slateblue]Beyond the Pale[/color]", CHEAP, POWER_FAMILY_DOWNGRADE_FOR_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)

# monsters
const STANDARD_APPEASE = [8, 19, 30, 42]
const ELITE_APPEASE = [30, 45, 60, 75]
const NEMESIS_MEDUSA_APPEASE = [40, 45, 50, 55]

# stores a list of all monster coins and trial coins
@warning_ignore("unused_private_class_variable")
@onready var _ALL_MONSTER_AND_TRIAL_COINS = [MONSTER_FAMILY, 
	MONSTER_HELLHOUND_FAMILY, MONSTER_KOBALOS_FAMILY, MONSTER_ARAE_FAMILY, MONSTER_HARPY_FAMILY, MONSTER_CENTAUR_FAMILY, MONSTER_STYMPHALIAN_BIRDS_FAMILY,
	MONSTER_SIREN_FAMILY, MONSTER_BASILISK_FAMILY, MONSTER_CHIMERA_FAMILY,
	MEDUSA_FAMILY, EURYALE_FAMILY, STHENO_FAMILY, 
	TRIAL_IRON_FAMILY, TRIAL_MISFORTUNE_FAMILY, TRIAL_PAIN_FAMILY, TRIAL_BLOOD_FAMILY, TRIAL_EQUIVALENCE_FAMILY,
	TRIAL_FAMINE_FAMILY, TRIAL_TORTURE_FAMILY, TRIAL_LIMITATION_FAMILY, TRIAL_COLLAPSE_FAMILY, TRIAL_SAPPING_FAMILY, TRIAL_OVERLOAD_FAMILY]

var MONSTER_FAMILY = CoinFamily.new(1000, "[color=gray]Monster[/color]", "[color=purple]It Bars the Path[/color]", NO_PRICE, POWER_FAMILY_LOSE_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_HELLHOUND_FAMILY = CoinFamily.new(1001, "[color=gray]Hellhound[/color]", "[color=purple]Infernal Pursurer[/color]", NO_PRICE, MONSTER_POWER_FAMILY_HELLHOUND, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_KOBALOS_FAMILY = CoinFamily.new(1002, "[color=gray]Kobalos[/color]", "[color=purple]Obstreperous Scamp[/color]", NO_PRICE, MONSTER_POWER_FAMILY_KOBALOS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_ARAE_FAMILY = CoinFamily.new(1003, "[color=gray]Arae[/color]", "[color=purple]Encumber With Guilt[/color]", NO_PRICE, MONSTER_POWER_FAMILY_ARAE, POWER_FAMILY_LOSE_ZERO_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_HARPY_FAMILY = CoinFamily.new(1004, "[color=gray]Harpy[/color]", "[color=purple]Shrieking Wind[/color]", NO_PRICE, MONSTER_POWER_FAMILY_HARPY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_CENTAUR_FAMILY = CoinFamily.new(1005, "[color=gray]Centaur[/color]", "[color=purple]Are the Stars Right?[/color]", NO_PRICE, MONSTER_POWER_FAMILY_CENTAUR_HEADS, MONSTER_POWER_FAMILY_CENTAUR_TAILS, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_STYMPHALIAN_BIRDS_FAMILY = CoinFamily.new(1006, "[color=gray]Stymphalian Birds[/color]", "[color=purple]Piercing Quills[/color]", NO_PRICE, MONSTER_POWER_FAMILY_STYMPHALIAN_BIRDS, POWER_FAMILY_LOSE_LIFE_INCREASED, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
# elite monsters
var MONSTER_SIREN_FAMILY = CoinFamily.new(1007, "[color=gray]Siren[/color]", "[color=purple]Lure into Blue[/color]", NO_PRICE, MONSTER_POWER_FAMILY_SIREN, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, ELITE_APPEASE)
var MONSTER_BASILISK_FAMILY = CoinFamily.new(1008, "[color=gray]Basilisk[/color]", "[color=purple]Gaze of Death[/color]", NO_PRICE, MONSTER_POWER_FAMILY_BASILISK, POWER_FAMILY_LOSE_ZERO_LIFE, _SpriteStyle.NEMESIS, ELITE_APPEASE)
#var MONSTER_GORGON_FAMILY = CoinFamily.new(1009, "[color=gray]Gorgon[/color]", "[color=purple]Petrifying Beauty[/color]", NO_PRICE, MONSTER_POWER_FAMILY_GORGON, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, ELITE_APPEASE)
var MONSTER_CHIMERA_FAMILY = CoinFamily.new(1010, "[color=gray]Chimera[/color]", "[color=purple]Great Blaze[/color]", NO_PRICE, MONSTER_POWER_FAMILY_CHIMERA, POWER_FAMILY_LOSE_LIFE_DOUBLED, _SpriteStyle.NEMESIS, ELITE_APPEASE)

# nemesis
var MEDUSA_FAMILY = CoinFamily.new(2000, "[color=greenyellow]Medusa[/color]", "[color=purple]Mortal Sister[/color]", NO_PRICE, NEMESIS_POWER_FAMILY_MEDUSA_STONE, NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE, _SpriteStyle.NEMESIS, NEMESIS_MEDUSA_APPEASE)
var EURYALE_FAMILY = CoinFamily.new(2001, "[color=mediumaquamarine]Euryale[/color]", "[color=purple]Lamentful Cry[/color]", NO_PRICE, NEMESIS_POWER_FAMILY_EURYALE_STONE, NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY, _SpriteStyle.NEMESIS, NEMESIS_MEDUSA_APPEASE)
var STHENO_FAMILY = CoinFamily.new(2002, "[color=rosybrown]Stheno[/color]", "[color=purple]Huntress of Man[/color]", NO_PRICE, NEMESIS_POWER_FAMILY_STHENO_STONE, NEMESIS_POWER_FAMILY_STHENO_CURSE, _SpriteStyle.NEMESIS, NEMESIS_MEDUSA_APPEASE)

# trials
var TRIAL_IRON_FAMILY = CoinFamily.new(3000, "[color=darkgray]Trial of Iron[/color]", "[color=lightgray]Weighted Down[/color]", NO_PRICE, TRIAL_POWER_FAMILY_IRON, TRIAL_POWER_FAMILY_IRON, _SpriteStyle.PASSIVE)
var THORNS_FAMILY = CoinFamily.new(9000, "(DENOM) of Thorns", "[color=darkgray]Metallic Barb[/color]\nCannot pay tolls.", NO_PRICE, POWER_FAMILY_LOSE_SOULS_THORNS, POWER_FAMILY_LOSE_LIFE_THORNS, _SpriteStyle.THORNS)
var TRIAL_MISFORTUNE_FAMILY = CoinFamily.new(3001, "[color=purple]Trial of Misfortune[/color]", "[color=lightgray]Against the Odds[/color]", NO_PRICE, TRIAL_POWER_FAMILY_MISFORTUNE, TRIAL_POWER_FAMILY_MISFORTUNE, _SpriteStyle.PASSIVE)
var TRIAL_PAIN_FAMILY = CoinFamily.new(3003, "[color=tomato]Trial of Pain[/color]", "[color=lightgray]Pulse Amplifier[/color]", NO_PRICE, TRIAL_POWER_FAMILY_PAIN, TRIAL_POWER_FAMILY_PAIN, _SpriteStyle.PASSIVE)
var TRIAL_BLOOD_FAMILY = CoinFamily.new(3004, "[color=crimson]Trial of Blood[/color]", "[color=lightgray]Paid in Crimson[/color]", NO_PRICE, TRIAL_POWER_FAMILY_BLOOD, TRIAL_POWER_FAMILY_BLOOD, _SpriteStyle.PASSIVE)
var TRIAL_EQUIVALENCE_FAMILY = CoinFamily.new(3005, "[color=gold]Trial of Equivalence[/color]", "[color=lightgray]Fair, in a Way[/color]", NO_PRICE, TRIAL_POWER_FAMILY_EQUIVALENCE, TRIAL_POWER_FAMILY_EQUIVALENCE, _SpriteStyle.PASSIVE)
var TRIAL_FAMINE_FAMILY = CoinFamily.new(3006, "[color=burlywood]Trial of Famine[/color]", "[color=lightgray]Endless Hunger[/color]", NO_PRICE, TRIAL_POWER_FAMILY_FAMINE, TRIAL_POWER_FAMILY_FAMINE, _SpriteStyle.PASSIVE)
var TRIAL_TORTURE_FAMILY = CoinFamily.new(3007, "[color=darkred]Trial of Torture[/color]", "[color=lightgray]Boiling Veins[/color]", NO_PRICE, TRIAL_POWER_FAMILY_TORTURE, TRIAL_POWER_FAMILY_TORTURE, _SpriteStyle.PASSIVE)
var TRIAL_LIMITATION_FAMILY = CoinFamily.new(3008, "[color=lightgray]Trial of Limitation[/color]", "[color=lightgray]Less is Less[/color]", NO_PRICE, TRIAL_POWER_FAMILY_LIMITATION, TRIAL_POWER_FAMILY_LIMITATION, _SpriteStyle.PASSIVE)
var TRIAL_COLLAPSE_FAMILY = CoinFamily.new(3009, "[color=moccasin]Trial of Collapse[/color]", "[color=lightgray]Falling Down[/color]", NO_PRICE, TRIAL_POWER_FAMILY_COLLAPSE, TRIAL_POWER_FAMILY_COLLAPSE, _SpriteStyle.PASSIVE)
var TRIAL_SAPPING_FAMILY = CoinFamily.new(3010, "[color=paleturquoise]Trial of Sapping[/color]", "[color=lightgray]Unnatural Fatigue[/color]", NO_PRICE, TRIAL_POWER_FAMILY_SAPPING, TRIAL_POWER_FAMILY_SAPPING, _SpriteStyle.PASSIVE)
var TRIAL_OVERLOAD_FAMILY = CoinFamily.new(3011, "[color=steelblue]Trial of Overload[/color]", "[color=lightgray]Energy Untethered[/color]", NO_PRICE, TRIAL_POWER_FAMILY_OVERLOAD, TRIAL_POWER_FAMILY_OVERLOAD, _SpriteStyle.PASSIVE)

var CHARON_OBOL_FAMILY = CoinFamily.new(10000, "[color=magenta]Charon's Obol[/color]", "Last Chance", NO_PRICE, CHARON_POWER_LIFE, CHARON_POWER_DEATH, _SpriteStyle.CHARONS)



# stores the active pool of coins for this run
# updated via generate_coinpool at the start of each run
var _COINPOOL = []

func generate_coinpool() -> void:
	_COINPOOL.clear()
	
	# generate based on unlocks
	for coin_family in _ALL_PLAYER_COINS:
		if is_coin_unlocked(coin_family):
			_COINPOOL.append(coin_family)
	
	assert(_COINPOOL.size() != 0)
	# in the future, character specific coinpools can be set here
	
	#for coin in _COINPOOL:
	#	print(coin.coin_name)

func random_family() -> CoinFamily:
	return choose_one(_COINPOOL)

func random_family_excluding(excluded: Array) -> CoinFamily:
	var roll = random_family()
	if roll in excluded:
		return random_family_excluding(excluded)
	return roll

func random_god_family() -> CoinFamily:
	var coin = random_family()
	if coin.heads_power_family.is_power():
		return coin
	return random_god_family()

func random_shop_denomination_for_round() -> Denomination:
	return choose_one(_current_round_shop_denoms())

func is_passive_active(passivePower: PowerFamily) -> bool:
	assert(passivePower.powerType == PowerType.PASSIVE)
	
	for row in COIN_ROWS:
		for coin in row.get_children():
			if coin.is_passive() and coin.get_active_power_family() == passivePower:
				return true
	return false

const _SAVE_PATH = "user://save.charonsobol"
const _SAVE_COIN_KEY = "coin"
const _SAVE_CHAR_KEY = "character"
var _save_dict = {
	_SAVE_COIN_KEY : {
		GENERIC_FAMILY.id : true,
		ZEUS_FAMILY.id : true,
		HERA_FAMILY.id : true,
		POSEIDON_FAMILY.id : true,
		DEMETER_FAMILY.id : true,
		APOLLO_FAMILY.id : false,
		ARTEMIS_FAMILY.id : false,
		ARES_FAMILY.id : true,
		ATHENA_FAMILY.id : true,
		HEPHAESTUS_FAMILY.id : true, 
		APHRODITE_FAMILY.id : true,
		HERMES_FAMILY.id : true,
		HESTIA_FAMILY.id : true,
		DIONYSUS_FAMILY.id : true,
		HADES_FAMILY.id : false
	},
	_SAVE_CHAR_KEY : {
		CHARACTERS[Character.LADY].id : true,
		CHARACTERS[Character.ELEUSINIAN].id : false
	}
}

func unlock_coin(coin: CoinFamily) -> void:
	_save_dict[_SAVE_COIN_KEY][coin.id] = true
	Global.write_save()

func unlock_character(chara: Character) -> void:
	_save_dict[_SAVE_CHAR_KEY][CHARACTERS[chara].id] = true
	Global.write_save()

func unlock_all() -> void:
	for family in _ALL_PLAYER_COINS:
		unlock_coin(family)
	for chara in Character.values():
		unlock_character(chara)

func is_coin_unlocked(coin: CoinFamily) -> bool:
	return _save_dict[_SAVE_COIN_KEY][coin.id]

func is_character_unlocked(chara: Character) -> bool:
	return _save_dict[_SAVE_CHAR_KEY][CHARACTERS[chara].id]

func load_save() -> void:
	# some sanity asserts
	for family in _ALL_PLAYER_COINS:
		assert(_save_dict[_SAVE_COIN_KEY][family.id] != null)
	for chara in Character.values():
		assert(_save_dict[_SAVE_CHAR_KEY][CHARACTERS[chara].id] != null)
	
	var file = FileAccess.open(_SAVE_PATH, FileAccess.READ)
	
	if file != null:
		var saved = file.get_var()
		if saved != null:
			# overwrite all values in the _save_dict with the loaded save file
			# we do it this way for two reasons -
			# 1) if we add a new key into the default _save_dict, we don't want to remove it by replacing the whole _save_dict with saved
			# 2) if we remove a key from _save_dict, we want to also 'remove' it from the saved by skipping over it
			_recursive_overwrite_dictionary(saved, _save_dict)
	#print("load")
	#print(_save_dict)
	emit_signal("game_loaded")

func _recursive_overwrite_dictionary(dict: Dictionary, dict_to_overwrite: Dictionary) -> void:
	for key in dict.keys():
		# if the dict to overwrite doesn't have this key, skip
		if not dict_to_overwrite.has(key):
			continue
		
		var dict_subdictionary = dict[key] is Dictionary
		var dict_overwrite_subdictionary = dict_to_overwrite[key] is Dictionary
		
		# if one is a dictionary and other isn't, complain...
		if dict_subdictionary != dict_overwrite_subdictionary:
			assert(false, "don't do this")
			continue
		
		# if both are dictionaries have a subdictionary, recur
		if dict_subdictionary and dict_overwrite_subdictionary:
			_recursive_overwrite_dictionary(dict[key], dict_to_overwrite[key])
			continue
			
		# otherwise, overwrite dict_to_overwrite with dict's value
		dict_to_overwrite[key] = dict[key]

func write_save() -> void:
	var file = FileAccess.open(_SAVE_PATH, FileAccess.WRITE)
	file.store_var(_save_dict)
	#print("save")
	#print(_save_dict)
