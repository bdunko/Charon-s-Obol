extends Node

var DEBUG = true # utility flag for debugging mode
var DEBUG_DONT_FORCE_FIRST_TOSS = false

signal state_changed
signal round_changed
signal souls_count_changed
signal life_count_changed
signal arrow_count_changed
signal active_coin_power_coin_changed
signal active_coin_power_family_changed
signal toll_coins_changed
signal flips_this_round_changed
signal powers_this_round_changed
signal monsters_destroyed_this_round_changed
signal ante_changed
signal patron_changed
signal patron_used_this_toss_changed
signal patron_uses_changed
signal rerolls_changed
signal souls_earned_this_round_changed
signal tutorial_state_changed
signal game_loaded
signal malice_changed

signal passive_triggered

var character: CharacterData

func is_character(chara: Global.Character) -> bool:
	return character.character == chara
	
func get_character() -> Global.Character:
	return character.character

func get_character_color() -> Color:
	return character.color

func get_character_intro_text() -> String:
	return character.introText

func get_character_victory_dialogue() -> Array:
	return character.victoryDialogue

func get_character_victory_closing_line() -> String:
	return character.victoryClosingLine

class CharacterData:
	var id: int
	var character: Global.Character
	var color: Color
	var name: String
	var description: String:
		get:
			return Global.replace_placeholders(description)
	var introText: String
	var victoryDialogue: Array #[String]
	var victoryClosingLine: String
	
	func _init(ide: int, characterEnum: Global.Character, clr: Color, nameStr: String, introTxt: String, descriptionStr: String, victoryDlg: Array, victoryClosingLn: String):
		self.id = ide
		self.character = characterEnum
		self.color = clr
		self.name = nameStr
		self.introText = introTxt
		self.description = descriptionStr
		self.victoryDialogue = victoryDlg
		self.victoryClosingLine = victoryClosingLn

enum Character {
	ELEUSINIAN, LADY, MERCHANT
}

class UnlockedDifficulty:
	var character: Character
	var difficulty: Difficulty
	
	func _init(chara: Character, diff: Difficulty) -> void:
		self.character = chara
		self.difficulty = diff

enum OrphicTabletPage {
	BASE, TIP1
}

class UnlockedFeature:
	enum FeatureType {
		SCALES_OF_THEMIS, ORPHIC_TABLETS, ORPHIC_TABLET_PAGE
	}
	
	var name: String
	var description: String
	var feature_type: FeatureType
	var sprite_path: String
	
	func _init(feat_type: FeatureType, nme: String, desc: String, sprt: String) -> void:
		self.feature_type = feat_type
		self.name = nme
		self.description = desc
		self.sprite_path = sprt

class UnlockedOrphicPageFeature extends UnlockedFeature:
	var page
	
	func _init(feat_type, nme, desc, sprt: String, tablet_pg: OrphicTabletPage):
		super._init(feat_type, nme, desc, sprt)
		self.page = tablet_pg

const _NO_CHARACTER = Character.LADY
const _NO_DIFFICULTY = Difficulty.INDIFFERENT1

var UNLOCKED_FEATURE_SCALES_OF_THEMIS = UnlockedFeature.new(UnlockedFeature.FeatureType.SCALES_OF_THEMIS, "The Scales of Themis",\
	"More options to configure the difficulty.\nAvailable from the main menu.",\
	"res://assets/icons/trial/equivalence_icon.png")
var UNLOCKED_FEATURE_ORPHIC_TABLETS = UnlockedFeature.new(UnlockedFeature.FeatureType.ORPHIC_TABLETS, "The Orphic Tablets",\
	"Contains detailed explainations for the game's rules.\nNew pages will unlock periodically.\nAvailable from the main menu.",\
	"res://assets/icons/trial/polymorph_icon.png")
var UNLOCKED_FEATURE_ORPHIC_PAGE1 = UnlockedOrphicPageFeature.new(UnlockedFeature.FeatureType.ORPHIC_TABLETS, "Orphic Tablets Updated",\
	"Additional information about status effects added to Orphic Tablets.\nView the Orphic Tablets from the main menu.",\
	"res://assets/icons/trial/polarization_icon.png", OrphicTabletPage.TIP1)

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
	
	ROUND2_INTRO, # explain gaining life
	ROUND2_POWER_INTRO, # explain powers
	ROUND2_POWER_ACTIVATED, # after activating a power
	ROUND2_POWER_USED, # after the power has been used
	ROUND2_POWER_UNUSABLE, # if a coin is on tails, it can't be used
	ROUND2_SHOP_BEFORE_UPGRADE, # explain upgrades
	ROUND2_SHOP_AFTER_UPGRADE, # some more text after upgrades
	
	ROUND3_INTRO, 
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
var tutorial_warned_zeus_reflip := false
var tutorial_pointed_out_patron_passive := false
var tutorial_patron_passive_active := false

var tutorialState: TutorialState:
	set(val):
		tutorialState = val
		emit_signal("tutorial_state_changed")

var CHARACTERS = {
	Character.LADY : CharacterData.new(0, Global.Character.LADY, Color("#A52A2A"), "[color=A52A2A]The Lady[/color]", 
		"\"Yet [color=springgreen]she[/color] was bound to return, willing or not, and in [color=springgreen]her[/color] passing the flowers wilted and trees weeped, for once [color=springgreen]she[/color] crossed the river, it would be many weeks until their renewal.\"\n-Homeric Hymn to Demeter",
		"Learn the rules of Charon's game.\n[color=lightslategray]Click Embark to begin the tutorial.[/color]", 
		["So [color=springgreen]you've[/color] returned to [color=purple]me[/color] once more.",
		"[color=springgreen]You[/color] always were one to keep [color=purple]me[/color] waiting.",
		"Regardless, welcome back home."],
		"[color=springgreen]Persephone[/color]..."),
	
	Character.ELEUSINIAN : CharacterData.new(1, Global.Character.ELEUSINIAN, Color("#008000"), "[color=green]The Eleusinian[/color]", \
		"\"[color=purple]Death[/color] is nothing to us, since when we are, [color=purple]death[/color] has not come, and when [color=purple]death[/color] has come, we are not.\"\n-Epicurus",
		"The standard game.\nSurvive Trials, Tollgates, and a Nemesis to win.",
		["The birds are singing.", 
		"The sun is shining.",
		"People parade through the streets.",
		"All is at peace in the world.",
		"For with [color=springgreen]her[/color] return..."], 
		"...[color=springgreen]spring[/color] has come again."),
	
	Character.MERCHANT : CharacterData.new(2, Global.Character.MERCHANT, Color("#FFD700"), "[color=gold]The Merchant[/color]", \
		"\"Virtue does not come from [color=gold]wealth[/color], but [color=gold]wealth[/color], and every other good thing which men have comes from virtue.\"\n-Socrates",
		"Coins may be sold back to the Shop.\nCoins cannot be upgraded in the Shop.\nThe shop offers 2 more coins.",
		["The birds are singing.", 
		"The sun is shining.",
		"People parade through the streets.",
		"All is at peace in the world.",
		"For with [color=springgreen]her[/color] return..."], 
		"...[color=springgreen]spring[/color] has come again.")
}

var difficulty: Difficulty

enum Difficulty {
	INDIFFERENT1 = 0, 
	HOSTILE2 = 1000, 
	CRUEL3 = 2000, 
	GREEDY4 = 3000, 
	UNFAIR5 = 4000, 
	BEATEN_ALL_DIFFICULTIES = 5000
}

# increased prices and multiplier for greedy
const _GREEDY_DIOBOL_INCREASE = 5
const _GREEDY_TRIOBOL_INCREASE = 15
const _GREEDY_TETROBOL_INCREASE = 25
const _GREEDY_PENTOBOL_INCREASE = 35
const _GREEDY_DRACHMA_INCREASE = 40
const _GREEDY_SHOP_MULTIPLIER_INCREASE = 0.3 #additive
const _GREEDY_TOLLGATE_MULTIPLIER = 1.25 #multiplicative

# increased trial quotas for cruel
const _CRUEL_SOUL_QUOTA_MULTIPLIER = 1.5 #multiplicative

# increased monster strength for unfair
const _UNFAIR_MONSTER_STRENGTH_MULTIPLIER = 1.5 #multiplicative
const _UNFAIR_NEMESIS_DENOM = Denomination.DRACHMA

func is_difficulty_active(diff_level: Difficulty) -> bool:
	return difficulty >= diff_level

func difficulty_tooltip_for(diff: Difficulty) -> String:
	match diff:
		Difficulty.INDIFFERENT1:
			return "[color=purple]Charon is Indifferent[/color]\nThe base difficulty level."
		Difficulty.HOSTILE2:
			return "[color=purple]Charon is Hostile[/color]\nCharon may occasionally unleash his Malice."
		Difficulty.CRUEL3:
			return "[color=purple]Charon is Cruel[/color]\nTrials have two modifiers.\nTrial soul quotas are higher."
		Difficulty.GREEDY4:
			return "[color=purple]Charon is Greedy[/color]\nCoins are more expensive.\nTollgates require a larger payment."
		Difficulty.UNFAIR5:
			return "[color=purple]Charon is Unfair[/color]\nMonsters are stronger and more numerous.\nThe Nemesis is more powerful."
	assert(false, "shouldn't happen..")
	return ""

enum State {
	BOARDING, BEFORE_FLIP, AFTER_FLIP, SHOP, VOYAGE, TOLLGATE, GAME_OVER, CHARON_OBOL_FLIP
}

func reroll_cost() -> int:
	return (shop_rerolls) * (shop_rerolls)

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
		if souls_earned_this_round < 0:
			souls_earned_this_round = 0
		emit_signal("souls_earned_this_round_changed")

const ARROWS_LIMIT = 10
var arrows: int:
	set(val):
		arrows = val
		assert(arrows >= 0)
		emit_signal("arrow_count_changed")

var state := State.BEFORE_FLIP:
	set(val):
		state = val
		emit_signal("state_changed")

const FIRST_ROUND = 2
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

var powers_this_round: int:
	set(val):
		powers_this_round = val
		emit_signal("powers_this_round_changed")

var monsters_destroyed_this_round: int:
	set(val):
		monsters_destroyed_this_round = val
		emit_signal("monsters_destroyed_this_round_changed")

var ante_modifier_this_round: int:
	set(val):
		ante_modifier_this_round = val
		emit_signal("ante_changed")

const MALICE_ACTIVATION_THRESHOLD_AFTER_POWER := 100
const MALICE_ACTIVATION_THRESHOLD_AFTER_TOSS := 95
const MALICE_INCREASE_ON_POWER_USED := 1.0
const MALICE_INCREASE_ON_HEADS_PAYOFF := 3.0
const MALICE_INCREASE_ON_TOSS_FINISHED := 5.0
const MALICE_TRIAL_MULTIPLIER := 2.0
const MALICE_MULTIPLIER_END_ROUND := 0.33
var malice: float:
	set(val):
		if is_difficulty_active(Difficulty.HOSTILE2):
			malice = val
			print("malice = %d" % malice)
			emit_signal("malice_changed")

const COIN_TWEEN_TIME := 0.22

var patron: Patron:
	set(val):
		patron = val
		emit_signal("patron_changed")

var patron_uses: int:
	set(val):
		patron_uses = val
		emit_signal("patron_uses_changed")

var patron_used_this_toss: bool:
	set(val):
		patron_used_this_toss = val
		emit_signal("patron_used_this_toss_changed")

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
@onready var TOLL_EXCLUDE_COIN_FAMILIES = []
# coins with a negative value at tolls
@onready var TOLL_NEGATIVE_COIN_FAMILIES = [THORNS_FAMILY]
# coins that cannot be upgraded
@onready var UPGRADE_EXCLUDE_COIN_FAMILIES = [THORNS_FAMILY]

func calculate_toll_coin_value() -> int:
	var sum = 0
	for coin in toll_coins_offered:
		if coin.get_coin_family() in Global.TOLL_NEGATIVE_COIN_FAMILIES:
			sum -= coin.get_value()
		else:
			sum += coin.get_value()
	return sum

var active_coin_power_coin: Coin = null:
	set(val):
		active_coin_power_coin = val
		emit_signal("active_coin_power_coin_changed")
		
var active_coin_power_family: PowerFamily:
	set(val):
		active_coin_power_family = val
		
		# update mouse cursor
		if active_coin_power_family == null:
			clear_custom_mouse_cursor()
		else:
			set_custom_mouse_cursor_to_icon(active_coin_power_family.icon_path)
		emit_signal("active_coin_power_family_changed")
		#if val == null: #should not be necessary...
		#	active_coin_power_coin = null

const COIN_LIMIT = 10
var COIN_ROWS: Array

# note - this trims off a pixel on the left since that's the format for our icons. Keep this in mind...
func set_custom_mouse_cursor_to_icon(icon_path: String) -> void:
	var img: Image = load(icon_path).get_image()
	assert(img is Image)
	# remove the leftmost y... this is a transparent column used for spacing the img; don't need for cursor
	img = img.get_region(Rect2(Vector2i(1, 0), img.get_size() - Vector2i(1, 0)))
	# resize it up a bit... starts at 9x13; resize this by 5x or so
	img.resize(img.get_width() * 5, img.get_height() * 5, Image.INTERPOLATE_NEAREST)
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(img), Input.CURSOR_ARROW, img.get_size() / 2.0)

func clear_custom_mouse_cursor() -> void:
	Input.set_custom_mouse_cursor(null)

func triangular(i: int) -> int:
	@warning_ignore("integer_division")
	return i*(i+1)/2

enum AnteFormula {
	THREE, FOUR, FIVE, SIX, SEVEN,
	THREE_WITH_EXP, FOUR_WITH_EXP, FIVE_WITH_EXP, SIX_WITH_EXP, SEVEN_WITH_EXP
}

# returns the life cost of a toss; min 0
func ante_cost() -> int:
	var base_ante = 0
	var add_exp = false
	
	match(current_round_ante_formula()):
		AnteFormula.THREE:
			base_ante = flips_this_round * 3
		AnteFormula.THREE_WITH_EXP:
			base_ante = flips_this_round * 3
			add_exp = true
		AnteFormula.FOUR:
			base_ante = flips_this_round * 4
		AnteFormula.FOUR_WITH_EXP:
			base_ante = flips_this_round * 4
			add_exp = true
		AnteFormula.FIVE:
			base_ante = flips_this_round * 5 
		AnteFormula.FIVE_WITH_EXP:
			base_ante = flips_this_round * 5 
			add_exp = true
		AnteFormula.SIX:
			base_ante = flips_this_round * 6
		AnteFormula.SIX_WITH_EXP:
			base_ante = flips_this_round * 6
			add_exp = true
		AnteFormula.SEVEN:
			base_ante = flips_this_round * 7
		AnteFormula.SEVEN_WITH_EXP:
			base_ante = flips_this_round * 7
			add_exp = true
		_:
			assert(false, "Invalid ante formula...")
	
	const EXP_STARTS_AT = 7
	if add_exp and flips_this_round >= EXP_STARTS_AT:
		base_ante += pow(2, flips_this_round - 5)
	
	return max(0, base_ante + ante_modifier_this_round)

var VOYAGE

enum RoundType {
	BOARDING, NORMAL, TRIAL1, TRIAL2, NEMESIS, TOLLGATE, END
}

class Round:
	var roundType: RoundType
	var lifeRegen: int
	var shopDenoms: Array
	var shop_multiplier: float
	var tollCost: int
	var monsterWave: MonsterWave
	var quota: float
	var ante_formula: AnteFormula
	var malice_multiplier: float
	
	var trialDatas: Array[TrialData]
	
	func _init(roundTyp: RoundType, lifeRegn: int, shopDenms: Array, shopMult: float, tollCst: int, rndQuota: int, mWave: MonsterWave, anteForm: AnteFormula, maliceMult: float):
		self.roundType = roundTyp
		self.lifeRegen = lifeRegn
		self.shopDenoms = shopDenms
		self.shop_multiplier = shopMult
		self.tollCost = tollCst
		self.monsterWave = mWave
		self.quota = rndQuota
		self.trialDatas = []
		self.ante_formula = anteForm
		self.malice_multiplier = maliceMult
	
	func get_icons():
		if trialDatas.size() == 0:
			return null
		
		var icons = []
		for trial in trialDatas:
			icons.append(trial.get_icon())
		return icons

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

class MonsterWave:
	enum WaveType {
		SPECIFIC_WAVE, 
		RANDOMIZED_STRENGTH_STANDARD_ONLY,
		RANDOMIZED_STRENGTH_WITH_ELITES, 
		NO_MONSTERS
	}
	
	var wave_type: WaveType
	var strength: int
	var wave_styles: Array
	var min_monsters: int
	var max_monsters: int # used for randomized waves, maximum monster quantity
	var randomization_amount: int # used as a +/- when calcualing strength for monster waves
	var possible_num_neutrals: Array
	
	func _init(wType: WaveType, streng: int = 0, mnMonsters = 0, mxMonsters = 0, randAmt = 0, waveSty: Array = [], neutrals: Array = [0]) -> void:
		self.wave_type = wType
		self.strength = streng
		self.wave_styles = waveSty
		self.randomization_amount = randAmt
		self.min_monsters = mnMonsters
		self.max_monsters = mxMonsters
		self.possible_num_neutrals = neutrals
		assert(max_monsters <= 6 and max_monsters >= 0)
		assert((wave_type == WaveType.NO_MONSTERS)\
			or (wave_type == WaveType.SPECIFIC_WAVE and wave_styles.size() != 0)\
			or ((wave_type == WaveType.RANDOMIZED_STRENGTH_STANDARD_ONLY or wave_type == WaveType.RANDOMIZED_STRENGTH_WITH_ELITES) and strength != -1 and max_monsters > 0))

var _MONSTER_WAVE_NONE = MonsterWave.new(MonsterWave.WaveType.NO_MONSTERS)
var _MONSTER_WAVE1 = MonsterWave.new(MonsterWave.WaveType.RANDOMIZED_STRENGTH_STANDARD_ONLY, 3, 1, 1, 0, [], [0])
var _MONSTER_WAVE2 = MonsterWave.new(MonsterWave.WaveType.RANDOMIZED_STRENGTH_STANDARD_ONLY, 8, 2, 2, 1, [1])
var _MONSTER_WAVE3 = MonsterWave.new(MonsterWave.WaveType.RANDOMIZED_STRENGTH_STANDARD_ONLY, 14, 2, 3, 2, [1, 2])
var _MONSTER_WAVE4 = MonsterWave.new(MonsterWave.WaveType.SPECIFIC_WAVE, -1, 0, 0, 0, [[Monster.new(Monster.Archetype.ELITE, Denomination.TRIOBOL)]])
var _MONSTER_WAVE5 = MonsterWave.new(MonsterWave.WaveType.RANDOMIZED_STRENGTH_STANDARD_ONLY, 28, 3, 5, 2, [0, 1])
var _MONSTER_WAVE6 = MonsterWave.new(MonsterWave.WaveType.SPECIFIC_WAVE, -1, 0, 0, 0, [[Monster.new(Monster.Archetype.ELITE, Denomination.TETROBOL), Monster.new(Monster.Archetype.ELITE, Denomination.TETROBOL)]])

var _MONSTER_WAVE_TUTORIAL1 = MonsterWave.new(MonsterWave.WaveType.SPECIFIC_WAVE, -1, 0, 0, 0, [[Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL)]])
var _MONSTER_WAVE_TUTORIAL2 = MonsterWave.new(MonsterWave.WaveType.SPECIFIC_WAVE, -1, 0, 0, 0, [[Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL)]])


const STORE_UPGRADE_DISCOUNT = 0.75

const _ANTE_LOW = AnteFormula.THREE_WITH_EXP
const _ANTE_MID = AnteFormula.FIVE_WITH_EXP
const _ANTE_HIGH = AnteFormula.SEVEN_WITH_EXP

const _MALICE_NONE := 0.0
const _MALICE_LOW := 1.0
const _MALICE_MID := 1.5
const _MALICE_HIGH := 2.0

const _NOSHOP = []
const _SHOP1 = [Denomination.OBOL]
const _SHOP12 = [Denomination.OBOL, Denomination.DIOBOL]
const _SHOP123 = [Denomination.OBOL, Denomination.DIOBOL, Denomination.TRIOBOL]
const _SHOP1234 = [Denomination.OBOL, Denomination.DIOBOL, Denomination.TRIOBOL, Denomination.TETROBOL]
const _SHOP2 = [Denomination.DIOBOL]
const _SHOP23 = [Denomination.DIOBOL, Denomination.TRIOBOL]
const _SHOP234 = [Denomination.DIOBOL, Denomination.TRIOBOL, Denomination.TETROBOL]
const _SHOP3 = [Denomination.TRIOBOL]
const _SHOP34 = [Denomination.TRIOBOL, Denomination.TETROBOL]
const _SHOP4 = [Denomination.TETROBOL]

const _NOMULT = 0.0
const _SHOP_MULT1 = 1.0
const _SHOP_MULT2 = 2.0
const _SHOP_MULT3 = 2.5
const _SHOP_MULT4 = 3.0
const _SHOP_MULT5 = 2.0
const _SHOP_MULT6 = 2.25
const _SHOP_MULT7 = 2.5
const _SHOP_MULT8 = 5.0
const _SHOP_MULT9 = 5.0

# STANDARD (2 Gate - 2 Trial [12])
# NNN1GNN2GNNB
var _VOYAGE_STANDARD = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT2, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TRIAL1, 100, _SHOP123, _SHOP_MULT4, 0, 60, _MONSTER_WAVE_NONE, _ANTE_MID, _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 5, 0, _MONSTER_WAVE_NONE, _ANTE_MID, _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT5,0, 0, _MONSTER_WAVE3, _ANTE_MID, _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP123, _SHOP_MULT6,0, 0, _MONSTER_WAVE4, _ANTE_MID, _MALICE_MID),
	Round.new(RoundType.TRIAL2, 100, _SHOP23, _SHOP_MULT7,0, 110, _MONSTER_WAVE_NONE, _ANTE_HIGH, _MALICE_HIGH),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 8, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH, _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP234, _SHOP_MULT8,0, 0, _MONSTER_WAVE5, _ANTE_HIGH, _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT9,0, 0, _MONSTER_WAVE6, _ANTE_HIGH, _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH, _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH, _MALICE_HIGH)
]
 
# VARIANT (2 Gate - 2 Trial [12])
# NNNGNN1GNN2B
var _VOYAGE_VARIANT = [ 
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT2, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 4, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT4, 0, 0, _MONSTER_WAVE3, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT5, 0, 0, _MONSTER_WAVE4, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TRIAL1, 100, _SHOP23, _SHOP_MULT6, 0, 80, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 9, 0, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT7, 0, 0, _MONSTER_WAVE5, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT8, 0, 0, _MONSTER_WAVE6, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TRIAL2, 100, _SHOP34, _SHOP_MULT9,0 , 130, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH)
]
	
# BACKLOADED (2 Gate - 3 Trial [111])
# NNNN1GN1GN1B 
var _VOYAGE_BACKLOADED = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT2, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT4, 0, 0, _MONSTER_WAVE4, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TRIAL1, 100, _SHOP23, _SHOP_MULT5, 0, 70, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 6, 0, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT6, 0, 0, _MONSTER_WAVE5, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TRIAL1, 100, _SHOP34, _SHOP_MULT7, 0, 100, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 7, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT8, 0, 0, _MONSTER_WAVE6, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TRIAL1, 100, _SHOP34, _SHOP_MULT9, 0, 130, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT,0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT,0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH)
]

# PARTITION (1 Gate - 2 Trial [22])
# NNNN2GNNN2B
var _VOYAGE_PARTITION = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT2, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT4, 0, 0, _MONSTER_WAVE3, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TRIAL2, 100, _SHOP23, _SHOP_MULT5, 0, 60, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT,10, 0, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT6, 0, 0, _MONSTER_WAVE4, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT7, 0, 0, _MONSTER_WAVE5, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT8, 0, 0, _MONSTER_WAVE6, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TRIAL2, 100, _SHOP34, _SHOP_MULT9, 0, 120, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT, 0, 0,  _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH)
]

# FRONTLOAD - (1 Gate - 3 Trial [112])
# NN1NN1GNN2B
var _VOYAGE_FRONTLOAD = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT2, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TRIAL1, 100, _SHOP12, _SHOP_MULT3, 0, 40, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT4, 0, 0, _MONSTER_WAVE2, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT5, 0, 0, _MONSTER_WAVE3, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TRIAL1, 100, _SHOP23, _SHOP_MULT6, 0, 70, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 11, 0, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT7, 0, 0, _MONSTER_WAVE4, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100,_SHOP34, _SHOP_MULT8, 0, 0, _MONSTER_WAVE6, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TRIAL2, 100, _SHOP34, _SHOP_MULT9, 0, 120, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH)
]

# INTERSPERSED - (3 Gate - 2 Trial [12)
# NNGN1NGN2NGNB
var _VOYAGE_INTERSPERSED = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT2, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 2, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TRIAL1, 100, _SHOP23, _SHOP_MULT4, 0, 50, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT5, 0, 0, _MONSTER_WAVE3, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 5, 0, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT6, 0, 0, _MONSTER_WAVE4, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TRIAL2, 100, _SHOP34, _SHOP_MULT7, 0, 100, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT8, 0, 0, _MONSTER_WAVE5, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 8, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT9, 0, 0, _MONSTER_WAVE6, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH)
]

# TUTORIAL (2 Gate - 2 Trial [12])
# NNN1GNN2GNNB
var _VOYAGE_TUTORIAL = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT2, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT4, 0, 0, _MONSTER_WAVE_TUTORIAL1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT5, 0, 0, _MONSTER_WAVE_TUTORIAL2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TRIAL1, 100, _SHOP23, _SHOP_MULT6, 0, 70, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 8, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), #8 is intentional to prevent possible bugs, don't increase
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW)
]

const NUM_STANDARD_MONSTERS = 4
const NUM_ELITE_MONSTERS = 2
@onready var NEUTRAL_MONSTERS = [MONSTER_CENTAUR_FAMILY, MONSTER_STYMPHALIAN_BIRDS_FAMILY]
@onready var STANDARD_MONSTERS = [MONSTER_HELLHOUND_FAMILY, MONSTER_KOBALOS_FAMILY, MONSTER_ARAE_FAMILY, MONSTER_HARPY_FAMILY]
@onready var ELITE_MONSTERS = [MONSTER_SIREN_FAMILY, MONSTER_CHIMERA_FAMILY, MONSTER_BASILISK_FAMILY]
var _neutral_monster_pool = []
var _standard_monster_pool = []
var _elite_monster_pool = []

func get_neutral_monster() -> CoinFamily:
	return Global.choose_one(_neutral_monster_pool)

func get_standard_monster() -> CoinFamily:
	return Global.choose_one(_standard_monster_pool)

func get_elite_monster() -> CoinFamily:
	return Global.choose_one(_elite_monster_pool)

func randomize_voyage() -> void:
	# special case - hardcoded setup for tutorial
	if is_character(Character.LADY):
		VOYAGE = _VOYAGE_TUTORIAL
		for rnd in VOYAGE:
			match(rnd.roundType):
				RoundType.TRIAL1:
					rnd.trialDatas = [_PAIN_TRIAL, _PAIN_TRIAL]
		_neutral_monster_pool = [MONSTER_KOBALOS_FAMILY]
		_standard_monster_pool = [MONSTER_KOBALOS_FAMILY]
		_elite_monster_pool = [MONSTER_KOBALOS_FAMILY] # unused, but just in case...
		return
	
	# choose a voyage
	#VOYAGE = choose_one_weighted(
	#	[_VOYAGE_STANDARD, _VOYAGE_VARIANT, _VOYAGE_BACKLOADED, _VOYAGE_PARTITION, _VOYAGE_FRONTLOAD, _VOYAGE_INTERSPERSED], 
	#	[250, 200, 200, 200, 200, 200])
	VOYAGE = _VOYAGE_STANDARD
	
	var possible_trials_lv1 = LV1_TRIALS.duplicate(true)
	var possible_trials_lv2 = LV2_TRIALS.duplicate(true)
	var possible_nemesis = NEMESES.duplicate(true)
	
	# randomize trials & nemesis
	for rnd in VOYAGE:
		# debug - seed trial
		match(rnd.roundType):
			RoundType.TRIAL1:
				for i in range(0, 2):
					var trial = Global.choose_one(possible_trials_lv1) if possible_trials_lv1.size() != 0 else Global.choose_one(LV1_TRIALS)
					possible_trials_lv1.erase(trial)
					rnd.trialDatas.append(trial)
			RoundType.TRIAL2:
				for i in range(0, 2):
					var trial = Global.choose_one(possible_trials_lv2) if possible_trials_lv2.size() != 0 else Global.choose_one(LV2_TRIALS)
					possible_trials_lv2.erase(trial)
					rnd.trialDatas.append(trial)
			RoundType.NEMESIS:
				var nemesis = Global.choose_one(possible_nemesis) if possible_nemesis.size() != 0 else Global.choose_one(NEMESES)
				possible_nemesis.erase(nemesis)
				rnd.trialDatas.append(nemesis)
	
	# randomize the monster pool
	_neutral_monster_pool = NEUTRAL_MONSTERS
	STANDARD_MONSTERS.shuffle()
	_standard_monster_pool = STANDARD_MONSTERS.slice(0, NUM_STANDARD_MONSTERS)
	ELITE_MONSTERS.shuffle()
	_elite_monster_pool = ELITE_MONSTERS.slice(0, NUM_ELITE_MONSTERS)
	assert(_neutral_monster_pool.size() != 0)
	assert(_standard_monster_pool.size() == NUM_STANDARD_MONSTERS)
	assert(_elite_monster_pool.size() == NUM_ELITE_MONSTERS)

func voyage_length() -> int:
	return VOYAGE.size()

func current_round_type() -> RoundType:
	return VOYAGE[round_count-1].roundType

func current_round_life_regen() -> int:
	return VOYAGE[round_count-1].lifeRegen

func current_round_toll() -> int:
	return get_toll_cost(VOYAGE[round_count-1])

func get_toll_cost(rnd: Round):
	return ceil(rnd.tollCost * (_GREEDY_TOLLGATE_MULTIPLIER if is_difficulty_active(Difficulty.GREEDY4) else 1.0))

func current_round_quota() -> int:
	return get_quota(VOYAGE[round_count-1])

func get_quota(rnd: Round):
	return ceil(rnd.quota * (_CRUEL_SOUL_QUOTA_MULTIPLIER if is_difficulty_active(Difficulty.CRUEL3) else 1.0))

func _current_round_shop_denoms() -> Array:
	return VOYAGE[round_count-1].shopDenoms

func current_round_ante_formula() -> AnteFormula:
	return VOYAGE[round_count-1].ante_formula

func current_round_malice_multiplier() -> float:
	return VOYAGE[round_count-1].malice_multiplier * (MALICE_TRIAL_MULTIPLIER if is_current_round_trial() else 1.0)

func current_round_shop_multiplier() -> float:
	var diff_addition = 0
	if is_difficulty_active(Difficulty.GREEDY4):
		diff_addition += _GREEDY_SHOP_MULTIPLIER_INCREASE
	return VOYAGE[round_count-1].shop_multiplier + diff_addition

func did_ante_increase() -> bool:
	if round_count == 0 or round_count == 1:
		return false
	return VOYAGE[round_count-1].ante_formula != VOYAGE[round_count-2].ante_formula

func current_round_wave_strength() -> int:
	return VOYAGE[round_count-1].monsterWave.strength

# returns an array of [monster_family, denom] pairs for current round
const _TRIAL1_DENOM = Denomination.DIOBOL
const _TRIAL2_DENOM = Denomination.TETROBOL
const _NEMESIS_DENOM = Denomination.TETROBOL
func current_round_enemy_coin_data() -> Array:
	var coin_data = []
	
	if current_round_type() == RoundType.TRIAL1:
		for trialFamily in VOYAGE[round_count-1].trialDatas[0].coinFamilies:
			coin_data.append([trialFamily, _TRIAL1_DENOM])
		if is_difficulty_active(Difficulty.CRUEL3): # if high difficulty, show both trials
			for trialFamily in VOYAGE[round_count-1].trialDatas[1].coinFamilies:
				coin_data.append([trialFamily, _TRIAL1_DENOM])
	elif current_round_type() == RoundType.TRIAL2:
		for trialFamily in VOYAGE[round_count-1].trialDatas[0].coinFamilies:
			coin_data.append([trialFamily, _TRIAL2_DENOM])
		if is_difficulty_active(Difficulty.CRUEL3): # if high difficulty, show both trials
			for trialFamily in VOYAGE[round_count-1].trialDatas[1].coinFamilies:
				coin_data.append([trialFamily, _TRIAL2_DENOM])
	elif current_round_type() == RoundType.NEMESIS:
		for nemesisFamily in VOYAGE[round_count-1].trialDatas[0].coinFamilies:
			var nem_denom = _NEMESIS_DENOM if not is_difficulty_active(Difficulty.UNFAIR5) else _UNFAIR_NEMESIS_DENOM
			coin_data.append([nemesisFamily, nem_denom])
	else:
		var wave: MonsterWave = VOYAGE[round_count-1].monsterWave
		
		match wave.wave_type:
			# we provide an array of possible wave styles, comprised of Standard or Elite monsters
			# with denoms. From this, we randomize the monster types according to the monster pool.
			MonsterWave.WaveType.SPECIFIC_WAVE:
				# choose one of the possible wave styles
				var monsters = Global.choose_one(wave.wave_styles)
				
				# elite_index just used to assure the final round has 2 different elites
				# but for standard monsters, duplicates are permitted
				var elite_index = 0
				_elite_monster_pool.shuffle()
				for monster in monsters:
					var denom = monster.denom
					if is_difficulty_active(Difficulty.UNFAIR5) and denom != Denomination.DRACHMA: #on unfair, bump all denoms 
						denom += 1
					match monster.archetype:
						Monster.Archetype.STANDARD:
							coin_data.append([Global.choose_one(_standard_monster_pool), denom])
						Monster.Archetype.ELITE:
							coin_data.append([_elite_monster_pool[elite_index], denom])
							elite_index += 1
			
			# we are provided with a strength level. Randomly create a wave style adding up to that strength.
			# elites may or may not be permitted depending on the WaveType
			MonsterWave.WaveType.RANDOMIZED_STRENGTH_STANDARD_ONLY, MonsterWave.WaveType.RANDOMIZED_STRENGTH_WITH_ELITES:
				var elites_allowed = wave.wave_type == MonsterWave.WaveType.RANDOMIZED_STRENGTH_WITH_ELITES
				var min_monsters = wave.min_monsters
				var max_monsters = wave.max_monsters
				var strength = wave.strength
				var randomization_amount = wave.randomization_amount
				var num_neutrals = Global.choose_one(wave.possible_num_neutrals)
				
				# these values MUST be different or the code will not work, unfortunately
				const MAX_ENEMIES = 6
				const standard_obol_strength = 3
				const standard_diobol_strength = 5
				const standard_triobol_strength = 7
				const standard_tetrobol_strength = 9
				const standard_pentobol_strength = 11
				const standard_drachma_strength = 13
				var strength_to_denom_standard = {
					standard_obol_strength : Denomination.OBOL,
					standard_diobol_strength : Denomination.DIOBOL,
					standard_triobol_strength : Denomination.TRIOBOL,
					standard_tetrobol_strength : Denomination.TETROBOL,
					standard_pentobol_strength : Denomination.PENTOBOL,
					standard_drachma_strength : Denomination.DRACHMA
				}
				
				const elite_triobol_strength = 12
				const elite_tetrobol_strength = 16
				const elite_pentobol_strength = 20
				const elite_drachma_strength = 24
				var strength_to_denom_elite = {
					elite_triobol_strength : Denomination.TRIOBOL,
					elite_tetrobol_strength : Denomination.TETROBOL,
					elite_pentobol_strength : Denomination.PENTOBOL,
					elite_drachma_strength : Denomination.DRACHMA
				}
				
				var values = [standard_obol_strength, standard_diobol_strength, standard_triobol_strength]
				if elites_allowed:
					values += [elite_triobol_strength, elite_tetrobol_strength]
				
				if is_difficulty_active(Difficulty.UNFAIR5): # permit higher denominations on unfair
					if elites_allowed:
						values += [elite_pentobol_strength, elite_drachma_strength]
						values.erase(elite_triobol_strength) # remove the triobol possibility
					strength = ceil(strength * _UNFAIR_MONSTER_STRENGTH_MULTIPLIER)
				
				# exception rule - no obols above a certain strength
				if strength >= 20:
					values.erase(standard_obol_strength)
				
				for i in num_neutrals+1:
					# neutral denom based on strength, though always low
					var denom = Denomination.OBOL
					if strength >= 10:
						denom = Denomination.DIOBOL
					if strength >= 20:
						denom = Denomination.TRIOBOL
					coin_data.append([Global.choose_one(_neutral_monster_pool), denom])
				
				# if the maximum monsters permitted plus neutrals randomized is > maximum possible (by space in row); reduce max_monsters to fit
				if max_monsters + num_neutrals > MAX_ENEMIES:
					max_monsters = MAX_ENEMIES - num_neutrals
				if min_monsters > max_monsters: #clamp the min
					min_monsters = max_monsters
				
				# if we have ONLY neutral monsters, we're done
				if max_monsters > 0:
					# calculate all possible combinations...
					var possibilities = []
					possibilities += combination_sum(strength, values, min_monsters, max_monsters)
					
					# do this for also +/- randomization amount for a bit more variety and safety
					for i in range(1, randomization_amount + 1):
						possibilities += combination_sum(strength+i, values, min_monsters, max_monsters)
						possibilities += combination_sum(strength-i, values, min_monsters, max_monsters)
					print(possibilities)
					
					# if we absolutely cannot find anything in the desired range, start going up/down until we find SOMETHING possible
					var force = randomization_amount
					while possibilities.size() == 0: 
						force += 1
						possibilities += combination_sum(strength + force, values, min_monsters, max_monsters)
						possibilities += combination_sum(strength - force, values, min_monsters, max_monsters)
					
					# now choose a random combination and translate it into coin_data, rolling specific monster types
					var combination = Global.choose_one(possibilities)
					print(combination)
					for val in combination:
						if strength_to_denom_standard.has(val):
							coin_data.append([Global.choose_one(_standard_monster_pool), strength_to_denom_standard[val]])
						else:
							assert(strength_to_denom_elite.has(val))
							coin_data.append([Global.choose_one(_elite_monster_pool), strength_to_denom_elite[val]])
	print(coin_data)
	return coin_data

# returns an array of arrays of combinations of 'values' that make up 'target' when summed.
# max_length - reject combinations larger than this size
# warning - doesn't work with negative numbers
func combination_sum(target: int, values: Array, min_length: int, max_length: int) -> Array:
	var answers = []
	_combination_sum_recur([], target, values, min_length, max_length, answers)
	return answers

func _combination_sum_recur(combination: Array, remaining: int, values: Array, min_length: int, max_length: int, answers: Array):
	if remaining < 0 or combination.size() > max_length: #this isn't a valid answer
		return
	if remaining == 0: #we found an answer
		if combination.size() < min_length: #too long... not a true answer
			return
		answers.append(combination)
		return
	
	# continue recurring
	for val in values:
		if val > remaining:
			continue
		_combination_sum_recur([] + combination + [val], remaining - val, values, min_length, max_length, answers)

func is_current_round_trial() -> bool:
	var rtype = current_round_type()
	return rtype == RoundType.TRIAL1 or rtype == RoundType.TRIAL2

func is_current_round_nemesis() -> bool:
	var rtype = current_round_type()
	return rtype == RoundType.NEMESIS

func is_next_round_nemesis() -> bool:
	if VOYAGE.size() == round_count:
		return false #next round is null lol - this should never happen though
	return VOYAGE[round_count].roundType == RoundType.NEMESIS

func is_next_round_end() -> bool:
	if VOYAGE.size() == round_count:
		return false #next round is null lol - this should never happen though
	return VOYAGE[round_count].roundType == RoundType.END

func is_current_round_end() -> bool:
	if round_count >= VOYAGE.size():
		return true #this is the case that actually gets triggered btw in normal circumstances
	return VOYAGE[round_count].roundType == RoundType.END

class TrialData:
	var name: String
	var coinFamilies: Array
	var description: String
	var _icon_path: String
	
	func _init(trialName: String, trialCoinFamilies: Array, trialDescription: String, icn_path: String):
		self.name = trialName
		self.coinFamilies = trialCoinFamilies
		self.description = trialDescription
		self._icon_path = icn_path
	
	func get_icon() -> Texture2D:
		return load(_icon_path)

@onready var NEMESES = [
	TrialData.new("[color=lightgreen]The Gorgon Sisters[/color]", [EURYALE_FAMILY, MEDUSA_FAMILY, STHENO_FAMILY], "These three sisters will render you helpless with their petrifying gaze.", NEMESIS_POWER_FAMILY_MEDUSA_STONE.icon_path)
]

# extra reference to this for use in tutorial
@onready var _PAIN_TRIAL = TrialData.new(TRIAL_PAIN_FAMILY.coin_name, [TRIAL_PAIN_FAMILY], TRIAL_POWER_FAMILY_PAIN.description, TRIAL_POWER_FAMILY_PAIN.icon_path)
@onready var LV1_TRIALS = [
	TrialData.new(TRIAL_IRON_FAMILY.coin_name, [TRIAL_IRON_FAMILY], TRIAL_POWER_FAMILY_IRON.description, TRIAL_POWER_FAMILY_IRON.icon_path),
	TrialData.new(TRIAL_MISFORTUNE_FAMILY.coin_name, [TRIAL_MISFORTUNE_FAMILY], TRIAL_POWER_FAMILY_MISFORTUNE.description, TRIAL_POWER_FAMILY_MISFORTUNE.icon_path),
	#TrialData.new("Fossilization", [GENERIC_FAMILY], "When the trial begins, your highest value coin is turned to Stone."),
	#TrialData.new("Silence", [GENERIC_FAMILY], "Your leftmost 2 coins are Blank."),
	#TrialData.new("Silence", [GENERIC_FAMILY], "Your rightmost 2 coins are Blank."),
	#TrialData.new("Exhaustion", [GENERIC_FAMILY], "Every 3 payoffs, your lowest value coin is destroyed."),
	TrialData.new(TRIAL_EQUIVALENCE_FAMILY.coin_name, [TRIAL_EQUIVALENCE_FAMILY], TRIAL_POWER_FAMILY_EQUIVALENCE.description, TRIAL_POWER_FAMILY_EQUIVALENCE.icon_path),
	_PAIN_TRIAL,
	TrialData.new(TRIAL_BLOOD_FAMILY.coin_name, [TRIAL_BLOOD_FAMILY], TRIAL_POWER_FAMILY_BLOOD.description, TRIAL_POWER_FAMILY_BLOOD.icon_path),
	#TrialData.new("Draining", [GENERIC_FAMILY], "Using a power also drains a charge from each adjacent coin."),
	#TrialData.new("Suffering", [GENERIC_FAMILY], "Ante starts at 4."),
	#TrialData.new("Restraint", [GENERIC_FAMILY], "After using a coin's power, that coin becomes Locked."),
]

@onready var LV2_TRIALS = [
	TrialData.new(TRIAL_FAMINE_FAMILY.coin_name, [TRIAL_FAMINE_FAMILY], TRIAL_POWER_FAMILY_FAMINE.description, TRIAL_POWER_FAMILY_FAMINE.icon_path),
	#TrialData.new("Vainglory", [GENERIC_FAMILY], "When the trial begins, your Obols and Diobols are destroyed."),
	TrialData.new(TRIAL_TORTURE_FAMILY.coin_name, [TRIAL_TORTURE_FAMILY], TRIAL_POWER_FAMILY_TORTURE.description, TRIAL_POWER_FAMILY_TORTURE.icon_path),
	#TrialData.new("Petrification", [GENERIC_FAMILY], "When the trial begins, your two highest value coins are turned to Stone."),
	#TrialData.new("Fate", [GENERIC_FAMILY], "Coins cannot be reflipped by powers."),
	TrialData.new(TRIAL_LIMITATION_FAMILY.coin_name, [TRIAL_LIMITATION_FAMILY], TRIAL_POWER_FAMILY_LIMITATION.description, TRIAL_POWER_FAMILY_LIMITATION.icon_path),
	#TrialData.new("Gating", [GENERIC_FAMILY], "During payoff, any coin which earns more than 10 Souls earns 0 instead."),
	#TrialData.new("Impatience", [GENERIC_FAMILY], "You must perform exactly 3 total tosses this round."),
	#TrialData.new("Immolation", [GENERIC_FAMILY], "When the trial begins, all your coins Ignite."),
	#TrialData.new("Aging", [GENERIC_FAMILY], "After payoff, your leftmost non-Blank coin becomes Blank."),
	# todo - rename resistance to poverty and redo icon
	#TrialData.new("Resistance", [GENERIC_FAMILY], "Your payoff coins land on tails 90% of the time."),
	TrialData.new(TRIAL_COLLAPSE_FAMILY.coin_name, [TRIAL_COLLAPSE_FAMILY], TRIAL_POWER_FAMILY_COLLAPSE.description, TRIAL_POWER_FAMILY_COLLAPSE.icon_path),
	#TrialData.new("Chaos", [GENERIC_FAMILY], "All coin powers have random targets when activated."),
	TrialData.new(TRIAL_OVERLOAD_FAMILY.coin_name, [TRIAL_OVERLOAD_FAMILY], TRIAL_POWER_FAMILY_OVERLOAD.description, TRIAL_POWER_FAMILY_OVERLOAD.icon_path),
	TrialData.new(TRIAL_SAPPING_FAMILY.coin_name, [TRIAL_SAPPING_FAMILY], TRIAL_POWER_FAMILY_SAPPING.description, TRIAL_POWER_FAMILY_SAPPING.icon_path),
	#TrialData.new("Singularity", [GENERIC_FAMILY], "Every power coin has only a single charge."),
	#TrialData.new("Recklessness", [GENERIC_FAMILY], "You cannot end the round until your life is 5 or fewer."),
	#TrialData.new("Adversity", [GENERIC_FAMILY], "Gain a random permanent Monster coin. (If not enough space, destroy coins until there is.)"),
	#TrialData.new("Fury", [GENERIC_FAMILY], "Charon's Malice increases 3 times as fast."),
	#TrialData.new("Chains", [GENERIC_FAMILY], "When the trial begins, each of your non-payoff coins becomes Locked."),
	#TrialData.new("Transfiguration", [GENERIC_FAMILY], "When the trial begicns, 3 of your non-payoff coins are randomly transformed into different coins of the same value."),
]

enum PowerType {
	POWER_TARGETTING, POWER_NON_TARGETTING,
	
	PASSIVE,
	
	CHARON,
	
	PAYOFF_GAIN_SOULS, PAYOFF_LOSE_SOULS,
	PAYOFF_LOSE_LIFE,
	PAYOFF_GAIN_ARROWS, 
	PAYOFF_IGNITE_SELF, PAYOFF_IGNITE, PAYOFF_UNLUCKY, PAYOFF_CURSE, PAYOFF_BLANK, PAYOFF_LUCKY, 
	PAYOFF_FREEZE_TAILS, PAYOFF_HALVE_LIFE, PAYOFF_STONE, 
	PAYOFF_DOWNGRADE_MOST_VALUABLE
}

class PowerFamily:
	enum Tag {
		REFLIP, FREEZE, LUCKY, GAIN, DESTROY, UPGRADE, HEAL, POSITIONING, CURSE, BLESS, TURN, TRADE, IGNITE
	}
	
	var description: String:
		get:
			return Global.replace_placeholders(description)
	var uses_for_denom: Array[int]
	var power_type: PowerType
	var icon_path: String
	var prefer_icon_only: bool
	var tags: Array
	
	func _init(desc: String, uses_per_denom: Array[int], pwrType: PowerType, icon: String, pref_icn_only: bool, tgs: Array = []) -> void:
		self.description = desc
		self.uses_for_denom = uses_per_denom
		self.power_type = pwrType
		self.icon_path = icon
		self.prefer_icon_only = pref_icn_only
		if icon != "":
			assert(FileAccess.file_exists(self.icon_path))
		self.tags = tgs
	
	func get_power_type_placeholder() -> String:
		if is_power():
			return "(POWER)"
		if is_passive():
			return "(PASSIVE)"
		if is_payoff():
			if power_type == PowerType.PAYOFF_GAIN_SOULS or power_type == PowerType.PAYOFF_LOSE_SOULS:
				return "(PAYOFF_SOULS)"
			elif power_type == PowerType.PAYOFF_LOSE_LIFE:
				return "(PAYOFF_LIFE)"
			else:
				return "(PAYOFF_PURPLE)"
		assert(is_charon())
		return ""
	
	func is_payoff() -> bool:
		return power_type != PowerType.POWER_TARGETTING and power_type != PowerType.POWER_NON_TARGETTING and power_type != PowerType.PASSIVE and power_type != PowerType.CHARON
	
	func is_charon() -> bool:
		return power_type == PowerType.CHARON
	
	func is_power() -> bool:
		return power_type == PowerType.POWER_TARGETTING or power_type == PowerType.POWER_NON_TARGETTING
	
	func is_passive() -> bool:
		return power_type == PowerType.PASSIVE
	
	func has_tag(tag: Tag) -> bool:
		return tags.has(tag)

const ONLY_SHOW_ICON = true
const ICON_AND_CHARGES = false

var POWER_FAMILY_LOSE_LIFE = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [2, 4, 7, 10, 14, 19], PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", ICON_AND_CHARGES)
var POWER_FAMILY_LOSE_LIFE_INCREASED = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [4, 6, 9, 12, 17, 22], PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", ICON_AND_CHARGES)
var POWER_FAMILY_LOSE_LIFE_DOUBLED = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [4, 8, 14, 20, 28, 38], PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", ICON_AND_CHARGES)
var POWER_FAMILY_LOSE_LIFE_THORNS = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [1, 2, 3, 4, 5, 6], PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", ICON_AND_CHARGES)
var POWER_FAMILY_LOSE_ZERO_LIFE = PowerFamily.new("-(CURRENT_CHARGES)(LIFE)", [0, 0, 0, 0], PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", ICON_AND_CHARGES)

var POWER_FAMILY_LOSE_SOULS_THORNS = PowerFamily.new("-(CURRENT_CHARGES)(SOULS)", [1, 2, 3, 4, 5, 6], PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_blue_icon.png", ICON_AND_CHARGES)

var POWER_FAMILY_GAIN_SOULS = PowerFamily.new("+(CURRENT_CHARGES)(SOULS)", [5, 7, 9, 11, 13, 15], PowerType.PAYOFF_GAIN_SOULS, "res://assets/icons/soul_fragment_blue_icon.png", ICON_AND_CHARGES)
var POWER_FAMILY_GAIN_LIFE = PowerFamily.new("+(1_PLUS_2_PER_DENOM)(HEAL)", [1, 1, 1, 1, 1, 1], PowerType.POWER_NON_TARGETTING, "res://assets/icons/demeter_icon.png", ICON_AND_CHARGES)
var POWER_FAMILY_REFLIP = PowerFamily.new("Reflip a coin.", [2, 3, 4, 5, 6, 7], PowerType.POWER_TARGETTING, "res://assets/icons/zeus_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.REFLIP])
var POWER_FAMILY_FREEZE = PowerFamily.new("(FREEZE) a coin.", [1, 2, 3, 4, 5, 6], PowerType.POWER_TARGETTING, "res://assets/icons/poseidon_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.FREEZE])
var POWER_FAMILY_REFLIP_AND_NEIGHBORS = PowerFamily.new("Reflip a coin and its neighbors.", [1, 2, 3, 4, 5, 6], PowerType.POWER_TARGETTING, "res://assets/icons/hera_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.REFLIP, PowerFamily.Tag.POSITIONING])
var POWER_FAMILY_GAIN_ARROW = PowerFamily.new("+(1_PER_DENOM)(ARROW).", [1, 1, 1, 1, 1, 1], PowerType.POWER_NON_TARGETTING, "res://assets/icons/artemis_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.REFLIP])
var POWER_FAMILY_TURN_AND_BLURSE = PowerFamily.new("Turn a coin to its other face. Then, if it's (HEADS), (CURSE) it, if it's (TAILS) (BLESS) it.", [1, 2, 3, 4, 5, 6], PowerType.POWER_TARGETTING, "res://assets/icons/apollo_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.BLESS, PowerFamily.Tag.TURN, PowerFamily.Tag.CURSE])
var POWER_FAMILY_REFLIP_ALL = PowerFamily.new("Reflip all coins.", [1, 2, 3, 4, 5, 6], PowerType.POWER_NON_TARGETTING, "res://assets/icons/ares_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.REFLIP])
var POWER_FAMILY_REDUCE_PENALTY = PowerFamily.new("Reduce a coin's (LIFE) penalty for this round.", [2, 3, 4, 5, 6, 7], PowerType.POWER_TARGETTING, "res://assets/icons/athena_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.HEAL])
var POWER_FAMILY_UPGRADE_AND_IGNITE = PowerFamily.new("Upgrade (HEPHAESTUS_OPTIONS) and (IGNITE) it.", [1, 1, 1, 2, 3, 4], PowerType.POWER_TARGETTING, "res://assets/icons/hephaestus_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.UPGRADE, PowerFamily.Tag.IGNITE])
var POWER_FAMILY_COPY_FOR_TOSS = PowerFamily.new("Copy another coin's power for this toss.", [1, 1, 1, 1, 1, 1], PowerType.POWER_TARGETTING, "res://assets/icons/aphrodite_icon.png", ICON_AND_CHARGES)
var POWER_FAMILY_EXCHANGE = PowerFamily.new("Trade a coin for another of equal value.", [1, 2, 3, 4, 5, 6], PowerType.POWER_TARGETTING, "res://assets/icons/hermes_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.TRADE])
var POWER_FAMILY_MAKE_LUCKY = PowerFamily.new("Make a coin (LUCKY).", [1, 2, 3, 4, 5, 6], PowerType.POWER_TARGETTING, "res://assets/icons/hestia_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.LUCKY])
var POWER_FAMILY_GAIN_COIN = PowerFamily.new("Gain a random Obol.", [1, 2, 3, 4, 5, 6], PowerType.POWER_NON_TARGETTING, "res://assets/icons/dionysus_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.GAIN])
var POWER_FAMILY_DOWNGRADE_FOR_LIFE = PowerFamily.new("Downgrade a coin. If the coin was yours, +(HADES_SELF_GAIN)(HEAL); if the coin was a monster, -(HADES_MONSTER_COST)(LIFE).", [1, 1, 1, 1, 1, 1], PowerType.POWER_TARGETTING,"res://assets/icons/hades_icon.png", ICON_AND_CHARGES, [PowerFamily.Tag.DESTROY, PowerFamily.Tag.HEAL])

var POWER_FAMILY_ARROW_REFLIP = PowerFamily.new("Reflip a coin.", [0, 0, 0, 0, 0, 0], PowerType.POWER_TARGETTING, "res://assets/icons/arrow_icon.png", ONLY_SHOW_ICON)

var MONSTER_POWER_FAMILY_HELLHOUND = PowerFamily.new("(IGNITE) this coin.", [1, 1, 1, 1, 1, 1], PowerType.PAYOFF_IGNITE_SELF, "res://assets/icons/monster/hellhound_icon.png", ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_KOBALOS = PowerFamily.new("Make (CURRENT_CHARGES_COINS) (UNLUCKY).", [1, 1, 2, 2, 3, 3], PowerType.PAYOFF_UNLUCKY, "res://assets/icons/monster/kobalos_icon.png", ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_ARAE = PowerFamily.new("(CURSE) (CURRENT_CHARGES_COINS).", [1, 1, 2, 2, 3, 3], PowerType.PAYOFF_CURSE, "res://assets/icons/monster/arae_icon.png", ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_HARPY = PowerFamily.new("(BLANK) (CURRENT_CHARGES_COINS).", [1, 1, 2, 2, 3, 3], PowerType.PAYOFF_BLANK, "res://assets/icons/monster/harpy_icon.png", ONLY_SHOW_ICON)

var MONSTER_POWER_FAMILY_CENTAUR_HEADS = PowerFamily.new("Make (CURRENT_CHARGES_COINS) (LUCKY).", [1, 1, 1, 1, 1, 1], PowerType.PAYOFF_LUCKY, "res://assets/icons/monster/centaur_heads_icon.png", ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_CENTAUR_TAILS = PowerFamily.new("Make (CURRENT_CHARGES_COINS) (UNLUCKY).", [1, 1, 1, 1, 1, 1], PowerType.PAYOFF_UNLUCKY, "res://assets/icons/monster/centaur_tails_icon.png", ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_STYMPHALIAN_BIRDS = PowerFamily.new("+1(ARROW).", [1, 1, 1, 1, 1, 1], PowerType.PAYOFF_GAIN_ARROWS, "res://assets/icons/monster/stymphalian_birds_icon.png", ONLY_SHOW_ICON)

var MONSTER_POWER_FAMILY_CHIMERA = PowerFamily.new("(IGNITE) a coin.", [1, 1, 2, 2, 3, 3], PowerType.PAYOFF_IGNITE, "res://assets/icons/monster/chimera_icon.png", ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_SIREN = PowerFamily.new("(FREEZE) each (TAILS) coin.", [1, 1, 1, 1, 1, 1], PowerType.PAYOFF_FREEZE_TAILS, "res://assets/icons/monster/siren_icon.png", ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_SIREN_CURSE = PowerFamily.new("(CURSE) (CURRENT_CHARGES_COINS).", [2, 2, 2, 3, 3, 4], PowerType.PAYOFF_CURSE, "res://assets/icons/nemesis/curse_icon.png", ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_BASILISK = PowerFamily.new("Lose half your(LIFE).", [1, 1, 1, 1, 1, 1], PowerType.PAYOFF_HALVE_LIFE, "res://assets/icons/monster/basilisk_icon.png", ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_GORGON = PowerFamily.new("Turn (CURRENT_CHARGES_COINS) to (STONE).", [1, 1, 1, 1, 2, 2], PowerType.PAYOFF_STONE, "res://assets/icons/monster/gorgon_icon.png", ONLY_SHOW_ICON)

var NEMESIS_POWER_FAMILY_MEDUSA_STONE = PowerFamily.new("Turn (CURRENT_CHARGES_COINS) to (STONE).", [1, 1, 1, 1, 2, 2], PowerType.PAYOFF_STONE, "res://assets/icons/nemesis/medusa_icon.png", ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE = PowerFamily.new("(CURRENT_CHARGES_NUMERICAL_ADVERB), downgrade the most valuable coin.", [2, 2, 2, 2, 3, 3], PowerType.PAYOFF_DOWNGRADE_MOST_VALUABLE, "res://assets/icons/nemesis/downgrade_icon.png", ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_EURYALE_STONE = PowerFamily.new("Turn (CURRENT_CHARGES_COINS) to (STONE).", [1, 1, 1, 1, 1, 1], PowerType.PAYOFF_STONE, "res://assets/icons/nemesis/euryale_icon.png", ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY = PowerFamily.new("Make (CURRENT_CHARGES_COINS) (UNLUCKY).", [2, 2, 2, 2, 3, 3], PowerType.PAYOFF_UNLUCKY, "res://assets/icons/nemesis/unlucky_icon.png", ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_STHENO_STONE = PowerFamily.new("Turn (CURRENT_CHARGES) to (STONE)", [1, 1, 1, 1, 1, 1], PowerType.PAYOFF_STONE, "res://assets/icons/nemesis/stheno_icon.png", ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_STHENO_CURSE = PowerFamily.new("(CURSE) (CURRENT_CHARGES_COINS).", [2, 2, 2, 2, 3, 3], PowerType.PAYOFF_CURSE, "res://assets/icons/nemesis/curse_icon.png", ICON_AND_CHARGES)

var TRIAL_POWER_FAMILY_IRON = PowerFamily.new("When the trial begins, you gain 2 Obols of Thorns. (If not enough space, destroy the rightmost coin until there is.)", [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/iron_icon.png", ONLY_SHOW_ICON)
const MISFORTUNE_QUANTITY = 2
var TRIAL_POWER_FAMILY_MISFORTUNE = PowerFamily.new("After each payoff, two of your coins become (UNLUCKY).", [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/misfortune_icon.png", ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_PAIN = PowerFamily.new("Damage you take from (LIFE) penalties is tripled.", [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/pain_icon.png", ONLY_SHOW_ICON)
const BLOOD_COST = 1
var TRIAL_POWER_FAMILY_BLOOD = PowerFamily.new("Using a power costs %d(LIFE)." % BLOOD_COST, [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/blood_icon.png", ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_EQUIVALENCE = PowerFamily.new("After a coin lands on (HEADS), it becomes (UNLUCKY). After a coin lands on (TAILS), it becomes (LUCKY).", [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/equivalence_icon.png", ONLY_SHOW_ICON)

var TRIAL_POWER_FAMILY_FAMINE = PowerFamily.new("You do not replenish (HEAL) at the start of the round.", [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/famine_icon.png", ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_TORTURE = PowerFamily.new("After payoff, your highest value (HEADS) coin is downgraded.", [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/torture_icon.png", ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_LIMITATION = PowerFamily.new("Reduce any payoffs less than 10(SOULS) to 0.", [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/limitation_icon.png", ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_COLLAPSE = PowerFamily.new("After payoff, (CURSE) and (FREEZE) each coin on (TAILS).", [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/collapse_icon.png", ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_SAPPING = PowerFamily.new("Coins replenish only a single power charge each toss.", [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/sapping_icon.png", ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_OVERLOAD = PowerFamily.new("After payoff, you lose 1(LIFE) for each unspent power charge on a (HEADS) coin.", [0, 0, 0, 0, 0, 0], PowerType.PASSIVE, "res://assets/icons/trial/overload_icon.png", ONLY_SHOW_ICON)

var CHARON_POWER_DEATH = PowerFamily.new("(CHARON_DEATH) Die.", [0, 0, 0, 0, 0, 0], PowerType.CHARON, "res://assets/icons/charon_death_icon.png", ONLY_SHOW_ICON)
var CHARON_POWER_LIFE = PowerFamily.new("(CHARON_LIFE) Live. The round ends.", [0, 0, 0, 0, 0, 0], PowerType.CHARON, "res://assets/icons/charon_life_icon.png", ONLY_SHOW_ICON)

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
	tooltip = tooltip.replace("(IGNITED)", STATUS_FORMAT % ["red", "Ignited", "res://assets/icons/status/ignite_icon.png"])
	tooltip = tooltip.replace("(FREEZE)", STATUS_FORMAT % ["aqua", "Freeze", "res://assets/icons/status/freeze_icon.png"])
	tooltip = tooltip.replace("(FROZEN)", STATUS_FORMAT % ["aqua", "Frozen", "res://assets/icons/status/freeze_icon.png"])
	tooltip = tooltip.replace("(LUCKY)", STATUS_FORMAT % ["lawngreen", "Lucky", "res://assets/icons/status/lucky_icon.png"])
	tooltip = tooltip.replace("(LUCKYICON)", "[img=10x13]res://assets/icons/status/lucky_icon.png[/img]")
	tooltip = tooltip.replace("(UNLUCKY)", STATUS_FORMAT % ["orangered", "Unlucky", "res://assets/icons/status/unlucky_icon.png"])
	tooltip = tooltip.replace("(BLESS)", STATUS_FORMAT % ["palegoldenrod", "Bless", "res://assets/icons/status/bless_icon.png"])
	tooltip = tooltip.replace("(BLESSED)", STATUS_FORMAT % ["palegoldenrod", "Blessed", "res://assets/icons/status/bless_icon.png"])
	tooltip = tooltip.replace("(CURSE)", STATUS_FORMAT % ["mediumorchid", "Curse", "res://assets/icons/status/curse_icon.png"])
	tooltip = tooltip.replace("(CURSED)", STATUS_FORMAT % ["mediumorchid", "Cursed", "res://assets/icons/status/curse_icon.png"])
	tooltip = tooltip.replace("(BLANK)", STATUS_FORMAT % ["ghostwhite", "Blank", "res://assets/icons/status/blank_icon.png"])
	tooltip = tooltip.replace("(SUPERCHARGE)", STATUS_FORMAT % ["yellow", "Supercharge", "res://assets/icons/status/supercharge_icon.png"])
	tooltip = tooltip.replace("(STONE)", STATUS_FORMAT % ["slategray", "Stone", "res://assets/icons/status/stone_icon.png"])
	
	# used for the coin status indicator tooltips
	tooltip = tooltip.replace("(S_IGNITED)", STATUS_FORMAT % ["red", "Ignited", "res://assets/icons/status/ignite_icon.png"])
	tooltip = tooltip.replace("(S_FROZEN)", STATUS_FORMAT % ["aqua", "Frozen", "res://assets/icons/status/freeze_icon.png"])
	tooltip = tooltip.replace("(S_LUCKY)", STATUS_FORMAT % ["lawngreen", "Lucky", "res://assets/icons/status/lucky_icon.png"])
	tooltip = tooltip.replace("(S_SLIGHTLY_LUCKY)", STATUS_FORMAT % ["lawngreen", "Slightly Lucky", "res://assets/icons/status/slightly_lucky_icon.png"])
	tooltip = tooltip.replace("(S_QUITE_LUCKY)", STATUS_FORMAT % ["lawngreen", "Quite Lucky", "res://assets/icons/status/quite_lucky_icon.png"])
	tooltip = tooltip.replace("(S_INCREDIBLY_LUCKY)", STATUS_FORMAT % ["lawngreen", "Incredibly Lucky", "res://assets/icons/status/incredibly_lucky_icon.png"])
	tooltip = tooltip.replace("(S_UNLUCKY)", STATUS_FORMAT % ["orangered", "Unlucky", "res://assets/icons/status/unlucky_icon.png"])
	tooltip = tooltip.replace("(S_BLESSED)", STATUS_FORMAT % ["palegoldenrod", "Blessed", "res://assets/icons/status/bless_icon.png"])
	tooltip = tooltip.replace("(S_CURSED)", STATUS_FORMAT % ["mediumorchid", "Cursed", "res://assets/icons/status/curse_icon.png"])
	tooltip = tooltip.replace("(S_BLANKED)", STATUS_FORMAT % ["ghostwhite", "Blanked", "res://assets/icons/status/blank_icon.png"])
	tooltip = tooltip.replace("(S_SUPERCHARGED)", STATUS_FORMAT % ["yellow", "Supercharged", "res://assets/icons/status/supercharge_icon.png"])
	tooltip = tooltip.replace("(S_TURNED_TO_STONE)", STATUS_FORMAT % ["slategray", "Turned to Stone", "res://assets/icons/status/stone_icon.png"])
	
	tooltip = tooltip.replace("(POWERARROW)", "[img=12x13]res://assets/icons/ui/white_arrow.png[/img]")
	tooltip = tooltip.replace("(PASSIVE)", "[img=36x13]res://assets/icons/ui/passive.png[/img]")
	tooltip = tooltip.replace("(PAYOFF_SOULS)", "[img=32x13]res://assets/icons/ui/payoff_souls.png[/img]")
	tooltip = tooltip.replace("(PAYOFF_LIFE)", "[img=32x13]res://assets/icons/ui/payoff_life.png[/img]")
	tooltip = tooltip.replace("(PAYOFF_PURPLE)", "[img=32x13]res://assets/icons/ui/payoff_purple.png[/img]")
	tooltip = tooltip.replace("(POWER)", "[img=30x13]res://assets/icons/ui/power.png[/img]")
	
	tooltip = tooltip.replace("(TODO)", "[img=10x13]res://assets/icons/todo_icon.png[/img]")
	
	return tooltip

# todo - refactor this into Util
signal left_click_input

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

# filter an array and return an array containing only elements in keep
func array_keep(array: Array, keep: Array) -> Array:
	var ret = []
	for elem in array:
		if keep.has(elem):
			ret.append(elem)
	return ret

# fade modulate over time; awaitable
func fade_out(item: CanvasItem, time: float = 0.5) -> void:
	await create_tween().tween_property(item, "modulate:a", 0.0, time).finished
func fade_in(item: CanvasItem, time: float = 0.5) -> void:
	await create_tween().tween_property(item, "modulate:a", 1.0, time).finished

# choose x different random elements of arr
# if x > arr.size, arr will contain all elements (but randomized)
func choose_x(arr: Array, x: int) -> Array:
	arr.shuffle()
	var ret = []
	for i in arr.size():
		if i >= x:
			break
		ret.append(arr[i])
	return ret

func ordinal_suffix(i: int) -> String:
	var j = i % 10
	var k = i % 100
	if j == 1 and k != 11:
		return "st"
	elif j == 2 and k != 12:
		return "nd"
	elif j == 3 and k != 13:
		return "rd"
	return "th"

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

# helpers for moving something to a specific z index while remembering its previous z-indexdisplay_arrow
# mostly useful for tutorials and the like
var _z_map = {}
func temporary_set_z(node: CanvasItem, z: int) -> void:
	_z_map[node] = node.z_index
	node.z_index = z

func restore_z(node: CanvasItem) -> void:
	assert(_z_map.has(node))
	node.z_index = _z_map[node]
	_z_map.erase(node)

# todo - this should be in another file, PatronData I think?
class Patron:
	var god_name: String
	var token_name: String
	var _description: String
	var patron_enum: PatronEnum
	var power_family: PowerFamily
	var patron_statue: PackedScene
	var patron_token: PackedScene
	var _starting_coinpool: Array
	
	func _init(name: String, token: String, power_desc: String, ptrn_enum: PatronEnum, pwr_fmly: PowerFamily, statue: PackedScene, tkn: PackedScene, start_cpl: Array) -> void:
		self.god_name = name
		self.token_name = token
		self._description = power_desc
		self.patron_enum = ptrn_enum
		self.power_family = pwr_fmly
		self.patron_statue = statue
		self.patron_token = tkn
		self._starting_coinpool = start_cpl
	
	func get_description(show_full_charges: bool = false) -> String:
		var n_charges = get_uses_per_round() if show_full_charges else Global.patron_uses
		return Global.replace_placeholders("(POWER)[color=yellow]%d/%d[/color][img=10x13]%s[/img](POWERARROW)%s" % [n_charges, get_uses_per_round(), power_family.icon_path, _description])
	
	func get_uses_per_round() -> int:
		return power_family.uses_for_denom[0]
	
	func get_random_starting_coin_family() -> CoinFamily:
		return Global.choose_one(_starting_coinpool)

# placeholder powers... kinda a $HACK$
var PATRON_POWER_FAMILY_APHRODITE = PowerFamily.new("Aphrodite", [1, 1, 1, 1], PowerType.POWER_NON_TARGETTING, "res://assets/icons/aphrodite_patron_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_APOLLO = PowerFamily.new("Apollo", [3, 3, 3, 3], PowerType.POWER_TARGETTING, "res://assets/icons/apollo_patron_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_ARES = PowerFamily.new("Ares", [2, 2, 2, 2], PowerType.POWER_NON_TARGETTING, "res://assets/icons/ares_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_ARTEMIS = PowerFamily.new("Artemis", [2, 2, 2, 2], PowerType.POWER_NON_TARGETTING, "res://assets/icons/artemis_patron_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_ATHENA = PowerFamily.new("Athena", [2, 2, 2, 2], PowerType.POWER_TARGETTING, "res://assets/icons/athena_patron_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_DEMETER = PowerFamily.new("Demeter", [1, 1, 1, 1], PowerType.POWER_NON_TARGETTING, "res://assets/icons/demeter_patron_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_DIONYSUS = PowerFamily.new("Dionysus", [2, 2, 2, 2], PowerType.POWER_NON_TARGETTING, "res://assets/icons/dionysus_patron_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_HADES = PowerFamily.new("Hades", [1, 1, 1, 1], PowerType.POWER_TARGETTING, "res://assets/icons/hades_patron_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_HEPHAESTUS = PowerFamily.new("Hephaestus", [1, 1, 1, 1], PowerType.POWER_TARGETTING, "res://assets/icons/hephaestus_patron_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_HERA = PowerFamily.new("Hera", [2, 2, 2, 2], PowerType.POWER_TARGETTING, "res://assets/icons/hera_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_HERMES = PowerFamily.new("Hermes", [2, 2, 2, 2], PowerType.POWER_TARGETTING, "res://assets/icons/hermes_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_HESTIA = PowerFamily.new("Hestia", [3, 3, 3, 3], PowerType.POWER_TARGETTING, "res://assets/icons/hestia_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_POSEIDON = PowerFamily.new("Poseidon", [3, 3, 3, 3], PowerType.POWER_TARGETTING, "res://assets/icons/poseidon_icon.png", ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_ZEUS = PowerFamily.new("Zeus", [3, 3, 3, 3], PowerType.POWER_TARGETTING, "res://assets/icons/zeus_icon.png", ONLY_SHOW_ICON);

var PATRON_POWER_FAMILY_CHARON = PowerFamily.new("Charon", [3, 3, 3, 3], PowerType.POWER_TARGETTING, "res://assets/icons/charon_life_icon.png", ONLY_SHOW_ICON);

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
	Patron.new("[color=lightpink]Aphrodite[/color]", "[color=lightpink]Aphrodite's Heart[/color]", "Add 2 charges to each of your coins.\n(PASSIVE)At the start of each round, half of your coins become (BLESSED).", PatronEnum.APHRODITE, PATRON_POWER_FAMILY_APHRODITE, preload("res://components/patron_statues/aphrodite.tscn"), preload("res://components/patron_tokens/aphrodite.tscn"), [APHRODITE_FAMILY]),
	Patron.new("[color=orange]Apollo[/color]", "[color=orange]Apollo's Lyre[/color]", "Clear all statuses from a coin.\n(PASSIVE)Statuses are not cleared between rounds.", PatronEnum.APOLLO, PATRON_POWER_FAMILY_APOLLO, preload("res://components/patron_statues/apollo.tscn"), preload("res://components/patron_tokens/apollo.tscn"), [APOLLO_FAMILY]),
	Patron.new("[color=indianred]Ares[/color]", "[color=indianred]Ares's Spear[/color]", "Reflip all coins.\n(PASSIVE)Monster coins on (TAILS) cost half as many (SOULS) to destroy.", PatronEnum.ARES, PATRON_POWER_FAMILY_ARES, preload("res://components/patron_statues/ares.tscn"), preload("res://components/patron_tokens/ares.tscn"), [ARES_FAMILY]),
	Patron.new("[color=purple]Artemis[/color]", "[color=purple]Artemis's Bow[/color]", "Turn all coins to their other face.\n(PASSIVE)At the start of each round, +3(ARROW).", PatronEnum.ARTEMIS, PATRON_POWER_FAMILY_ARTEMIS, preload("res://components/patron_statues/artemis.tscn"), preload("res://components/patron_tokens/artemis.tscn"), [ARTEMIS_FAMILY]),
	Patron.new("[color=cyan]Athena[/color]", "[color=cyan]Athena's Aegis[/color]", "Permanently reduce a coin's (LIFE) penalty by 2(LIFE).\n(PASSIVE)You can see what face each coin will land on when flipped.", PatronEnum.ATHENA, PATRON_POWER_FAMILY_ATHENA, preload("res://components/patron_statues/athena.tscn"), preload("res://components/patron_tokens/athena.tscn"), [ATHENA_FAMILY]),
	Patron.new("[color=lightgreen]Demeter[/color]", "[color=lightgreen]Demeter's Wheat[/color]", "For each coin on (TAILS), +(HEAL) equal to its (LIFE) penalty.\n(PASSIVE)Whenever you heal (HEAL), also gain that many (SOULS).", PatronEnum.DEMETER, PATRON_POWER_FAMILY_DEMETER, preload("res://components/patron_statues/demeter.tscn"), preload("res://components/patron_tokens/demeter.tscn"), [DEMETER_FAMILY]),
	Patron.new("[color=plum]Dionysus[/color]", "[color=plum]Dionysus's Chalice[/color]", "???\n(PASSIVE)When you gain a new coin, make it (LUCKY).", PatronEnum.DIONYSUS, PATRON_POWER_FAMILY_DIONYSUS, preload("res://components/patron_statues/dionysus.tscn"), preload("res://components/patron_tokens/dionysus.tscn"), [DIONYSUS_FAMILY]),
	Patron.new("[color=slateblue]Hades[/color]", "[color=slateblue]Hades's Bident[/color]", "Destroy one of your coins. Gain (SOULS) and heal (LIFE) equal to %dx its value(COIN).\n(PASSIVE)Souls persist between rounds [color=gray](except before a Nemesis)[/color]." % HADES_PATRON_MULTIPLIER, PatronEnum.HADES, PATRON_POWER_FAMILY_HADES, preload("res://components/patron_statues/hades.tscn"), preload("res://components/patron_tokens/hades.tscn"), [HADES_FAMILY]),
	Patron.new("[color=sienna]Hephaestus[/color]", "[color=sienna]Hephaestus's Hammer[/color]", "Upgrade a coin and fully recharge it.\n(PASSIVE)Coins may be upgraded beyond Tetrobol [color=gray](to Pentobol and Drachma)[/color].", PatronEnum.HEPHAESTUS, PATRON_POWER_FAMILY_HEPHAESTUS, preload("res://components/patron_statues/hephaestus.tscn"), preload("res://components/patron_tokens/hephaestus.tscn"), [HEPHAESTUS_FAMILY]),
	Patron.new("[color=silver]Hera[/color]", "[color=silver]Hera's Lotus[/color]", "Reflip a coin and its neighbors.\n(PASSIVE)When you reflip a coin, it always lands on the other side.", PatronEnum.HERA, PATRON_POWER_FAMILY_HERA, preload("res://components/patron_statues/hera.tscn"), preload("res://components/patron_tokens/hera.tscn"), [HERA_FAMILY]),
	Patron.new("[color=lightskyblue]Hermes[/color]", "[color=lightskyblue]Herme's Caduceus[/color]", "Trade a coin for another of equal value.\n(PASSIVE)When you obtain a new coin during a round, it has a 20% chance to upgrade.", PatronEnum.HERMES, PATRON_POWER_FAMILY_HERMES, preload("res://components/patron_statues/hermes.tscn"), preload("res://components/patron_tokens/hermes.tscn"), [HERMES_FAMILY]),
	Patron.new("[color=sandybrown]Hestia[/color]", "[color=sandybrown]Hestia's Warmth[/color]", "Make a coin\n(LUCKY).\n(PASSIVE)(LUCKY) has a lesser effect, but may be applied up to 3 times to the same coin.", PatronEnum.HESTIA, PATRON_POWER_FAMILY_HESTIA, preload("res://components/patron_statues/hestia.tscn"), preload("res://components/patron_tokens/hestia.tscn"), [HESTIA_FAMILY]),
	Patron.new("[color=lightblue]Poseidon[/color]", "[color=lightblue]Poseidon's Trident[/color]", "(FREEZE) a coin.\n(PASSIVE)When you (FREEZE) a monster coin, also (BLANK) it.", PatronEnum.POSEIDON, PATRON_POWER_FAMILY_POSEIDON, preload("res://components/patron_statues/poseidon.tscn"), preload("res://components/patron_tokens/poseidon.tscn"), [POSEIDON_FAMILY]),
	Patron.new("[color=yellow]Zeus[/color]", "[color=yellow]Zeus's Thunderbolt[/color]", "Reflip a coin.\n(PASSIVE)When you use a power on a coin, (SUPERCHARGE) it.", PatronEnum.ZEUS, PATRON_POWER_FAMILY_ZEUS, preload("res://components/patron_statues/zeus.tscn"), preload("res://components/patron_tokens/zeus.tscn"), [ZEUS_FAMILY]),
]

@onready var CHARON_PATRON = Patron.new("[color=mediumorchid]Charon[/color]", "[color=mediumorchid]Charon's Oar[/color]", "Turn a coin to its other face and make it (LUCKY).\n(PASSIVE)After payoff, if every coin is on heads(HEADS), +5(SOULS).", PatronEnum.CHARON, PATRON_POWER_FAMILY_CHARON, preload("res://components/patron_statues/hades.tscn"), preload("res://components/patron_tokens/charon.tscn"), [HADES_FAMILY])


func statue_scene_for_patron_enum(enm: PatronEnum) -> PackedScene:
	if enm == PatronEnum.GODLESS:
		return _GODLESS_STATUE
	if enm == PatronEnum.CHARON:
		return CHARON_PATRON.patron_statue
	for possible_patron in PATRONS:
		if possible_patron.patron_enum == enm:
			return possible_patron.patron_statue
	assert(false, "Patron does not exist. (statue scene for patron enum)")
	return null

func patron_for_enum(enm: PatronEnum) -> Patron:
	if enm == PatronEnum.GODLESS:
		return choose_one(PATRONS)
	if enm == PatronEnum.CHARON:
		return CHARON_PATRON
	for possible_patron in PATRONS:
		if possible_patron.patron_enum == enm:
			return possible_patron
	assert(false, "Patron does not exist. (patron for enum)")
	return null

func is_patron_power(power_family: PowerFamily) -> bool:
	if power_family == PATRON_POWER_FAMILY_CHARON:
		return true
	for possible_patron in PATRONS:
		if possible_patron.power_family == power_family:
			return true
	return false

# todo - refactor this into a separate file probably; CoinInfo
enum Denomination {
	OBOL = 0, 
	DIOBOL = 1, 
	TRIOBOL = 2, 
	TETROBOL = 3,
	PENTOBOL = 4,
	DRACHMA = 5
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
		Denomination.PENTOBOL:
			return "Pentobol"
		Denomination.DRACHMA:
			return "Drachma"
	assert(false, "No matching case for denom...?")
	return "ERROR"

enum _SpriteStyle {
	PAYOFF, POWER, PASSIVE, NEMESIS, THORNS, CHARONS
}

class CoinFamily:
	var id: int
	
	var coin_name: String
	var subtitle: String
	var unlock_tip: String
	
	var base_price: int
	var heads_power_family: PowerFamily
	var tails_power_family: PowerFamily

	var appeasal_price_for_denom: Array
	
	var _sprite_style: _SpriteStyle
	
	func _init(ide: int, nme: String, 
			sub_title: String, unlk_tip: String, b_price: int,
			heads_pwr: PowerFamily, tails_pwr: PowerFamily,
			style: _SpriteStyle, app_price := [NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE]) -> void:
		id = ide
		coin_name = nme
		subtitle = sub_title
		unlock_tip = unlk_tip
		base_price = b_price
		heads_power_family = heads_pwr
		tails_power_family = tails_pwr
		appeasal_price_for_denom = app_price
		_sprite_style = style
		assert(appeasal_price_for_denom.size() == 6)
	
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

const NO_PRICE = 0
const CHEAP = 3
const STANDARD = 5
const PRICY = 7
const RICH = 10

const _UPGRADE_TO_DIOBOL = 20
const _UPGRADE_TO_TRIOBOL = 45
const _UPGRADE_TO_TETROBOL = 75
const _UPGRADE_TO_PENTOBOL = 115
const _UPGRADE_TO_DRACHMA = 160
func get_price_to_upgrade(denom: Denomination) -> int:
	match(denom):
		Denomination.OBOL:
			return _UPGRADE_TO_DIOBOL + (_GREEDY_DIOBOL_INCREASE if is_difficulty_active(Difficulty.GREEDY4) else 0)
		Denomination.DIOBOL:
			return _UPGRADE_TO_TRIOBOL + (_GREEDY_TRIOBOL_INCREASE if is_difficulty_active(Difficulty.GREEDY4) else 0)
		Denomination.TRIOBOL: 
			return _UPGRADE_TO_TETROBOL + (_GREEDY_TETROBOL_INCREASE if is_difficulty_active(Difficulty.GREEDY4) else 0)
		Denomination.TETROBOL:
			return _UPGRADE_TO_PENTOBOL + (_GREEDY_PENTOBOL_INCREASE if is_difficulty_active(Difficulty.GREEDY4) else 0)
		Denomination.PENTOBOL:
			return _UPGRADE_TO_DRACHMA + (_GREEDY_DRACHMA_INCREASE if is_difficulty_active(Difficulty.GREEDY4) else 0)
		Denomination.DRACHMA:
			return 0
	assert(false, "No matching case?")
	return 0

func get_cumulative_to_upgrade_to(denom: Denomination) -> int:
	match(denom):
		Denomination.OBOL:
			return 0
		Denomination.DIOBOL:
			return get_price_to_upgrade(Denomination.DIOBOL)
		Denomination.TRIOBOL: 
			return get_cumulative_to_upgrade_to(Denomination.DIOBOL) + get_price_to_upgrade(Denomination.TRIOBOL)
		Denomination.TETROBOL:
			return get_cumulative_to_upgrade_to(Denomination.TRIOBOL) + get_price_to_upgrade(Denomination.TETROBOL)
		Denomination.PENTOBOL:
			return get_cumulative_to_upgrade_to(Denomination.TETROBOL) + get_price_to_upgrade(Denomination.PENTOBOL)
		Denomination.DRACHMA:
			return get_cumulative_to_upgrade_to(Denomination.PENTOBOL) + get_price_to_upgrade(Denomination.DRACHMA)
	assert(false, "No matching case?")
	return 0

const NO_UNLOCK_TIP = ""

# Coin Families
# stores a list of all player coins (coins that can be bought in shop)
@onready var _ALL_PLAYER_COINS = [GENERIC_FAMILY, 
	ZEUS_FAMILY, HERA_FAMILY, POSEIDON_FAMILY, DEMETER_FAMILY, APOLLO_FAMILY, ARTEMIS_FAMILY,
	ARES_FAMILY, ATHENA_FAMILY, HEPHAESTUS_FAMILY, APHRODITE_FAMILY, HERMES_FAMILY, HESTIA_FAMILY, DIONYSUS_FAMILY, HADES_FAMILY]

# payoff coins
var GENERIC_FAMILY = CoinFamily.new(0, "(DENOM)", "[color=gray]Common Currency[/color]", NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_GAIN_SOULS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.PAYOFF)

# power coins
var ZEUS_FAMILY = CoinFamily.new(1, "(DENOM) of Zeus", "[color=yellow]Lighting Strikes[/color]", NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_REFLIP, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)

var HERA_FAMILY = CoinFamily.new(2, "(DENOM) of Hera", "[color=silver]Envious Wrath[/color]", NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_REFLIP_AND_NEIGHBORS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)

var POSEIDON_FAMILY = CoinFamily.new(3, "(DENOM) of Poseidon", "[color=lightblue]Wave of Ice[/color]", NO_UNLOCK_TIP,\
	RICH, POWER_FAMILY_FREEZE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var DEMETER_FAMILY = CoinFamily.new(4, "(DENOM) of Demeter", "[color=lightgreen]Grow Ever Stronger[/color]", NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_GAIN_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var APOLLO_FAMILY = CoinFamily.new(5, "(DENOM) of Apollo", "[color=orange]Harmonic, Melodic[/color]", "(BLESS)(POWERARROW)This coin will land on (HEADS) next flip.\n(CURSE)(POWERARROW)This coin will land on (TAILS) next flip.",\
	STANDARD, POWER_FAMILY_TURN_AND_BLURSE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var ARTEMIS_FAMILY = CoinFamily.new(6, "(DENOM) of Artemis", "[color=purple]Arrows of Night[/color]", "(ARROW)(POWERARROW)Can be used to reflip coins.\nPersists between tosses and rounds.",\
	PRICY, POWER_FAMILY_GAIN_ARROW, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var ARES_FAMILY = CoinFamily.new(7, "(DENOM) of Ares", "[color=indianred]Chaos of War[/color]", NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_REFLIP_ALL, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var ATHENA_FAMILY = CoinFamily.new(8, "(DENOM) of Athena", "[color=cyan]Phalanx Strategy[/color]", NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_REDUCE_PENALTY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var HEPHAESTUS_FAMILY = CoinFamily.new(9, "(DENOM) of Hephaestus", "[color=sienna]Forged With Fire[/color]", "(IGNITE)(POWERARROW)You lose 3 (LIFE) each payoff.",\
	RICH, POWER_FAMILY_UPGRADE_AND_IGNITE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var APHRODITE_FAMILY = CoinFamily.new(10, "(DENOM) of Aphrodite", "[color=lightpink]Two Lovers, United[/color]", NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_COPY_FOR_TOSS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var HERMES_FAMILY = CoinFamily.new(11, "(DENOM) of Hermes", "[color=lightskyblue]From Lands Distant[/color]", NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_EXCHANGE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var HESTIA_FAMILY = CoinFamily.new(12, "(DENOM) of Hestia", "[color=sandybrown]Weary Bones Rest[/color]", NO_UNLOCK_TIP,\
	STANDARD,  POWER_FAMILY_MAKE_LUCKY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var DIONYSUS_FAMILY = CoinFamily.new(13, "(DENOM) of Dionysus", "[color=plum]Wanton Revelry[/color]", NO_UNLOCK_TIP,\
	CHEAP, POWER_FAMILY_GAIN_COIN, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
const HADES_SELF_GAIN = [7, 9, 11, 13, 15, 18]
const HADES_MONSTER_COST = [7, 5, 3, 1, 0, 0]
var HADES_FAMILY = CoinFamily.new(14, "(DENOM) of Hades", "[color=slateblue]Beyond the Pale[/color]", NO_UNLOCK_TIP,\
	CHEAP, POWER_FAMILY_DOWNGRADE_FOR_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)

# monsters
const NOT_APPEASEABLE_PRICE = -888
const STANDARD_APPEASE = [6, 10, 15, 21, 28, 35]
const ELITE_APPEASE = [25, 30, 35, 40, 45, 50]
const NEMESIS_MEDUSA_APPEASE = [35, 44, 52, 60, 68, 77]

# stores a list of all monster coins and trial coins
@warning_ignore("unused_private_class_variable")
@onready var _ALL_MONSTER_AND_TRIAL_COINS = [MONSTER_FAMILY, 
	MONSTER_HELLHOUND_FAMILY, MONSTER_KOBALOS_FAMILY, MONSTER_ARAE_FAMILY, MONSTER_HARPY_FAMILY, MONSTER_CENTAUR_FAMILY, MONSTER_STYMPHALIAN_BIRDS_FAMILY,
	MONSTER_SIREN_FAMILY, MONSTER_BASILISK_FAMILY, MONSTER_CHIMERA_FAMILY,
	MEDUSA_FAMILY, EURYALE_FAMILY, STHENO_FAMILY, 
	TRIAL_IRON_FAMILY, TRIAL_MISFORTUNE_FAMILY, TRIAL_PAIN_FAMILY, TRIAL_BLOOD_FAMILY, TRIAL_EQUIVALENCE_FAMILY,
	TRIAL_FAMINE_FAMILY, TRIAL_TORTURE_FAMILY, TRIAL_LIMITATION_FAMILY, TRIAL_COLLAPSE_FAMILY, TRIAL_SAPPING_FAMILY, TRIAL_OVERLOAD_FAMILY]

# standard monsters
var MONSTER_FAMILY = CoinFamily.new(1000, "[color=gray]Monster[/color]", "[color=purple]It Bars the Path[/color]", NO_UNLOCK_TIP, NO_PRICE, POWER_FAMILY_LOSE_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_HELLHOUND_FAMILY = CoinFamily.new(1001, "[color=gray]Hellhound[/color]", "[color=purple]Infernal Pursurer[/color]", NO_UNLOCK_TIP, NO_PRICE, MONSTER_POWER_FAMILY_HELLHOUND, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_KOBALOS_FAMILY = CoinFamily.new(1002, "[color=gray]Kobalos[/color]", "[color=purple]Obstreperous Scamp[/color]", NO_UNLOCK_TIP, NO_PRICE, MONSTER_POWER_FAMILY_KOBALOS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_ARAE_FAMILY = CoinFamily.new(1003, "[color=gray]Arae[/color]", "[color=purple]Encumber With Guilt[/color]", NO_UNLOCK_TIP, NO_PRICE, MONSTER_POWER_FAMILY_ARAE, POWER_FAMILY_LOSE_ZERO_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_HARPY_FAMILY = CoinFamily.new(1004, "[color=gray]Harpy[/color]", "[color=purple]Shrieking Wind[/color]", NO_UNLOCK_TIP, NO_PRICE, MONSTER_POWER_FAMILY_HARPY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
# neutral monsters
var MONSTER_CENTAUR_FAMILY = CoinFamily.new(1005, "[color=gray]Centaur[/color]", "[color=purple]Are the Stars Right?[/color]", NO_UNLOCK_TIP, NO_PRICE, MONSTER_POWER_FAMILY_CENTAUR_HEADS, MONSTER_POWER_FAMILY_CENTAUR_TAILS, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
var MONSTER_STYMPHALIAN_BIRDS_FAMILY = CoinFamily.new(1006, "[color=gray]Stymphalian Birds[/color]", "[color=purple]Piercing Quills[/color]", NO_UNLOCK_TIP, NO_PRICE, MONSTER_POWER_FAMILY_STYMPHALIAN_BIRDS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, STANDARD_APPEASE)
# elite monsters
var MONSTER_SIREN_FAMILY = CoinFamily.new(1007, "[color=gray]Siren[/color]", "[color=purple]Lure into Blue[/color]", NO_UNLOCK_TIP, NO_PRICE, MONSTER_POWER_FAMILY_SIREN, MONSTER_POWER_FAMILY_SIREN_CURSE, _SpriteStyle.NEMESIS, ELITE_APPEASE)
var MONSTER_BASILISK_FAMILY = CoinFamily.new(1008, "[color=gray]Basilisk[/color]", "[color=purple]Gaze of Death[/color]", NO_UNLOCK_TIP, NO_PRICE, MONSTER_POWER_FAMILY_BASILISK, POWER_FAMILY_LOSE_ZERO_LIFE, _SpriteStyle.NEMESIS, ELITE_APPEASE)
var MONSTER_GORGON_FAMILY = CoinFamily.new(1009, "[color=gray]Gorgon[/color]", "[color=purple]Petrifying Beauty[/color]", NO_UNLOCK_TIP, NO_PRICE, MONSTER_POWER_FAMILY_GORGON, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, ELITE_APPEASE)
var MONSTER_CHIMERA_FAMILY = CoinFamily.new(1010, "[color=gray]Chimera[/color]", "[color=purple]Great Blaze[/color]", NO_UNLOCK_TIP, NO_PRICE, MONSTER_POWER_FAMILY_CHIMERA, POWER_FAMILY_LOSE_LIFE_DOUBLED, _SpriteStyle.NEMESIS, ELITE_APPEASE)

# nemesis
var MEDUSA_FAMILY = CoinFamily.new(2000, "[color=greenyellow]Medusa[/color]", "[color=purple]Mortal Sister[/color]", NO_UNLOCK_TIP, NO_PRICE, NEMESIS_POWER_FAMILY_MEDUSA_STONE, NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE, _SpriteStyle.NEMESIS, NEMESIS_MEDUSA_APPEASE)
var EURYALE_FAMILY = CoinFamily.new(2001, "[color=mediumaquamarine]Euryale[/color]", "[color=purple]Lamentful Cry[/color]", NO_UNLOCK_TIP, NO_PRICE, NEMESIS_POWER_FAMILY_EURYALE_STONE, NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY, _SpriteStyle.NEMESIS, NEMESIS_MEDUSA_APPEASE)
var STHENO_FAMILY = CoinFamily.new(2002, "[color=rosybrown]Stheno[/color]", "[color=purple]Huntress of Man[/color]", NO_UNLOCK_TIP, NO_PRICE, NEMESIS_POWER_FAMILY_STHENO_STONE, NEMESIS_POWER_FAMILY_STHENO_CURSE, _SpriteStyle.NEMESIS, NEMESIS_MEDUSA_APPEASE)

# trials
var TRIAL_IRON_FAMILY = CoinFamily.new(3000, "[color=darkgray]Trial of Iron[/color]", "[color=lightgray]Weighted Down[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_IRON, TRIAL_POWER_FAMILY_IRON, _SpriteStyle.PASSIVE)
var THORNS_FAMILY = CoinFamily.new(9000, "(DENOM) of Thorns", "[color=darkgray]Metallic Barb[/color]\nCannot pay tolls.", NO_UNLOCK_TIP, NO_PRICE, POWER_FAMILY_LOSE_SOULS_THORNS, POWER_FAMILY_LOSE_LIFE_THORNS, _SpriteStyle.THORNS)
var TRIAL_MISFORTUNE_FAMILY = CoinFamily.new(3001, "[color=purple]Trial of Misfortune[/color]", "[color=lightgray]Against the Odds[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_MISFORTUNE, TRIAL_POWER_FAMILY_MISFORTUNE, _SpriteStyle.PASSIVE)
var TRIAL_PAIN_FAMILY = CoinFamily.new(3003, "[color=tomato]Trial of Pain[/color]", "[color=lightgray]Pulse Amplifier[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_PAIN, TRIAL_POWER_FAMILY_PAIN, _SpriteStyle.PASSIVE)
var TRIAL_BLOOD_FAMILY = CoinFamily.new(3004, "[color=crimson]Trial of Blood[/color]", "[color=lightgray]Paid in Crimson[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_BLOOD, TRIAL_POWER_FAMILY_BLOOD, _SpriteStyle.PASSIVE)
var TRIAL_EQUIVALENCE_FAMILY = CoinFamily.new(3005, "[color=gold]Trial of Equivalence[/color]", "[color=lightgray]Fair, in a Way[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_EQUIVALENCE, TRIAL_POWER_FAMILY_EQUIVALENCE, _SpriteStyle.PASSIVE)
var TRIAL_FAMINE_FAMILY = CoinFamily.new(3006, "[color=burlywood]Trial of Famine[/color]", "[color=lightgray]Endless Hunger[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_FAMINE, TRIAL_POWER_FAMILY_FAMINE, _SpriteStyle.PASSIVE)
var TRIAL_TORTURE_FAMILY = CoinFamily.new(3007, "[color=darkred]Trial of Torture[/color]", "[color=lightgray]Boiling Veins[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_TORTURE, TRIAL_POWER_FAMILY_TORTURE, _SpriteStyle.PASSIVE)
var TRIAL_LIMITATION_FAMILY = CoinFamily.new(3008, "[color=lightgray]Trial of Limitation[/color]", "[color=lightgray]Less is Less[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_LIMITATION, TRIAL_POWER_FAMILY_LIMITATION, _SpriteStyle.PASSIVE)
var TRIAL_COLLAPSE_FAMILY = CoinFamily.new(3009, "[color=moccasin]Trial of Collapse[/color]", "[color=lightgray]Falling Down[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_COLLAPSE, TRIAL_POWER_FAMILY_COLLAPSE, _SpriteStyle.PASSIVE)
var TRIAL_SAPPING_FAMILY = CoinFamily.new(3010, "[color=paleturquoise]Trial of Sapping[/color]", "[color=lightgray]Unnatural Fatigue[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_SAPPING, TRIAL_POWER_FAMILY_SAPPING, _SpriteStyle.PASSIVE)
var TRIAL_OVERLOAD_FAMILY = CoinFamily.new(3011, "[color=steelblue]Trial of Overload[/color]", "[color=lightgray]Energy Untethered[/color]", NO_UNLOCK_TIP, NO_PRICE, TRIAL_POWER_FAMILY_OVERLOAD, TRIAL_POWER_FAMILY_OVERLOAD, _SpriteStyle.PASSIVE)

var CHARON_OBOL_FAMILY = CoinFamily.new(10000, "[color=magenta]Charon's Obol[/color]", "Last Chance", NO_UNLOCK_TIP, NO_PRICE, CHARON_POWER_LIFE, CHARON_POWER_DEATH, _SpriteStyle.CHARONS)


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

func get_payoff_coinpool() -> Array:
	var payoffs = []
	for coin in _COINPOOL:
		if coin.heads_power_family.is_payoff():
			payoffs.append(coin)
	payoffs.shuffle()
	return payoffs

func get_power_coinpool() -> Array:
	var powers = []
	for coin in _COINPOOL:
		if coin.heads_power_family.is_power():
			powers.append(coin)
	powers.shuffle()
	return powers

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
	if patron and patron.power_family == passivePower:
		return true
	
	for row in COIN_ROWS:
		for coin in row.get_children():
			if coin.is_passive() and coin.get_active_power_family() == passivePower:
				return true
	
	return false

const _SAVE_PATH = "user://save.charonsobol"
const _SETTINGS = "settings"
const _VARIABLES = "variables"
const _SAVE_COIN_KEY = "coin"
const _SAVE_CHAR_KEY = "character"
const _CHAR_UNLOCKED = "character_unlocked"
const _CHAR_HIGHEST_DIFFICULTY = "character_highest_difficulty"
var _save_dict = {
	_SETTINGS : {
		SETTING_WINDOW_MODE : 0,
		SETTING_SPEEDRUN_MODE : false,
		SETTING_MASTER_VOLUME : 50,
		SETTING_MUSIC_VOLUME : 50,
		SETTING_SFX_VOLUME : 50
	},
	_VARIABLES : {
		"hello" : "world"
	},
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
		HEPHAESTUS_FAMILY.id : false, 
		APHRODITE_FAMILY.id : true,
		HERMES_FAMILY.id : true,
		HESTIA_FAMILY.id : true,
		DIONYSUS_FAMILY.id : true,
		HADES_FAMILY.id : false
	},
	_SAVE_CHAR_KEY : {
		CHARACTERS[Character.LADY].id : {
			_CHAR_UNLOCKED : true,
			_CHAR_HIGHEST_DIFFICULTY : Difficulty.INDIFFERENT1
		},
		CHARACTERS[Character.ELEUSINIAN].id : {
			_CHAR_UNLOCKED : false,
			_CHAR_HIGHEST_DIFFICULTY : Difficulty.INDIFFERENT1
		},
		CHARACTERS[Character.MERCHANT].id : {
			_CHAR_UNLOCKED : false,
			_CHAR_HIGHEST_DIFFICULTY : Difficulty.INDIFFERENT1
		}
	}
}

func unlock_coin(coin: CoinFamily) -> void:
	_save_dict[_SAVE_COIN_KEY][coin.id] = true
	Global.write_save()

func unlock_character(chara: Character) -> void:
	_save_dict[_SAVE_CHAR_KEY][CHARACTERS[chara].id][_CHAR_UNLOCKED] = true
	Global.write_save()

func unlock_difficulty(chara: Character, new_difficulty: Difficulty) -> void:
	# if we somehow unlock a lower difficulty, don't permit
	if get_highest_difficulty_unlocked_for(chara) > new_difficulty:
		assert(false, "don't do this")
		return
	_save_dict[_SAVE_CHAR_KEY][CHARACTERS[chara].id][_CHAR_HIGHEST_DIFFICULTY] = new_difficulty
	Global.write_save()

func unlock_all() -> void:
	for family in _ALL_PLAYER_COINS:
		unlock_coin(family)
	for chara in Character.values():
		unlock_character(chara)
		unlock_difficulty(chara, Difficulty.BEATEN_ALL_DIFFICULTIES)

func change_setting(setting: String, value: Variant) -> void:
	_save_dict[_SETTINGS][setting] = value
	Global.write_save()

func set_variable(variable: String, value: Variant) -> void:
	_save_dict[_VARIABLES][variable] = value
	Global.write_save()

func is_coin_unlocked(coin: CoinFamily) -> bool:
	#if not _save_dict[_SAVE_COIN_KEY].has(coin.id):
	#	return false
	return _save_dict[_SAVE_COIN_KEY][coin.id]

func is_character_unlocked(chara: Character) -> bool:
	#if not _save_dict[_SAVE_CHAR_KEY].has(CHARACTERS[chara].id):
	#	return false
	return _save_dict[_SAVE_CHAR_KEY][CHARACTERS[chara].id][_CHAR_UNLOCKED]

func get_highest_difficulty_unlocked_for(chara: Character) -> Difficulty:
	return _save_dict[_SAVE_CHAR_KEY][CHARACTERS[chara].id][_CHAR_HIGHEST_DIFFICULTY]

const SETTING_WINDOW_MODE = "window_mode"
const SETTING_SPEEDRUN_MODE = "speedrun_mode"
const SETTING_MASTER_VOLUME = "master_volume"
const SETTING_MUSIC_VOLUME = "music_volume"
const SETTING_SFX_VOLUME = "sfx_volume"
func get_setting(setting: String) -> Variant:
	return _save_dict[_SETTINGS][setting]

func get_variable(variable: String) -> Variant:
	return _save_dict[_VARIABLES][variable]

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

# recursively iterate over all keys in dict and dictionaries those keys may correspond to. 
# for each of those non-dictionary keys which exists in dict_to_overwrite, replace the value with the one from dict.
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
