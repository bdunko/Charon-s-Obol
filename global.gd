extends Node

const SOUL_UP_PAYOFF_FORMAT = "[center][color=#a6fcdb]+%d[/color][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img][/center]"
const LIFE_UP_PAYOFF_FORMAT = "[center][color=#9cdb43]+%d[/color][img=10x13]res://assets/icons/soul_fragment_red_heal_icon.png[/img][/center]"
const SOUL_DOWN_PAYOFF_FORMAT = "[center][color=#df3e23]-%d[/color][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img][/center]"
const LIFE_DOWN_PAYOFF_FORMAT = "[center][color=#e12f3b]-%d[/color][img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img][/center]"
const ARROW_UP_PAYOFF_FORMAT = "[center]+%d[img=10x13]res://assets/icons/arrow_icon.png[/img][/center]"

var DEBUG_CHECK_DIRTY_TOOLTIPS = true #verify that un-dirty tooltips are indeed unchanged; turn this off in release for better performance
var DEBUG_CONSOLE = true # utility flag for debugging mode
var DEBUG_DONT_FORCE_FIRST_TOSS = true # don't require the first toss each round
var DEBUG_SKIP_INTRO = true # skip charon's trial intro
var DEBUG_SKIP_LAST_CHANCE_FLIP = false # skip the last chance flip

var _coin_row
@warning_ignore("unused_private_class_variable")
var _shop_row # this is used...
var _enemy_row
var _patron_token
var _game

signal state_changed
signal round_changed
signal souls_count_changed
signal life_count_changed
signal arrow_count_changed
signal active_coin_power_coin_changed
signal active_coin_power_family_changed
signal toll_coins_changed
signal tosses_this_round_changed
signal payoffs_this_round_changed
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
signal flame_boost_changed
signal ignite_damage_changed

signal passive_triggered

signal info_view_toggled
var info_view_active = false:
	set(val):
		var prev = info_view_active
		info_view_active = val
		if prev != val:
			emit_signal("info_view_toggled")

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
var TUTORIAL_NO_UPGRADE = [Global.TutorialState.ROUND1_SHOP_AFTER_BUYING_COIN,  Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN, Global.TutorialState.ROUND2_INTRO, Global.TutorialState.ROUND2_SHOP_BEFORE_UPGRADE]
var tutorial_warned_zeus_reflip := false
var tutorial_pointed_out_patron_passive := false
var tutorial_patron_passive_active := false
var tutorial_pointed_out_can_destroy_monster := false

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
		"The standard game.\nSurvive Trials, Tollgates, and the Nemesis.",
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
	BOARDING, BEFORE_FLIP, AFTER_FLIP, SHOP, VOYAGE, TOLLGATE, GAME_OVER, CHARON_OBOL_FLIP, INACTIVE
}

func reroll_cost() -> int:
	return min((shop_rerolls) * (shop_rerolls), shop_rerolls * 5)

var shop_rerolls: int:
	set(val):
		shop_rerolls = val
		assert(shop_rerolls >= 0)
		emit_signal("rerolls_changed")

var souls: int = 0:
	set(val):
		var start = souls
		souls = val
		assert(souls >= 0)
		emit_signal("souls_count_changed", souls - start)

func earn_souls(soul_amt: int) -> void:
	assert(soul_amt >= 0)
	if soul_amt == 0:
		return
	Global.souls += soul_amt
	Global.souls_earned_this_round += soul_amt

func heal_life(heal_amt: int) -> void:
	assert(heal_amt >= 0)
	if heal_amt == 0:
		return
	Global.lives += heal_amt
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_DEMETER):
		earn_souls(heal_amt)
		Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_DEMETER)
		LabelSpawner.spawn_label(Global.SOUL_UP_PAYOFF_FORMAT % heal_amt, _patron_token.get_label_origin(), _game)

func lose_souls(soul_amt: int) -> void: 
	assert(soul_amt >= 0)
	if soul_amt == 0:
		return
	Global.souls = max(0, Global.souls - soul_amt)
	Global.souls_earned_this_round -= soul_amt

var souls_earned_this_round: int = 0:
	set(val):
		souls_earned_this_round = val
		if souls_earned_this_round < 0:
			souls_earned_this_round = 0
		emit_signal("souls_earned_this_round_changed")

const FLAME_BOOST_LIMIT = 20.0
var flame_boost := 0.0:
	set(val):
		flame_boost = min(val, FLAME_BOOST_LIMIT)
		emit_signal("flame_boost_changed")

const ARROWS_LIMIT = 10
var arrows: int:
	set(val):
		arrows = val
		assert(arrows >= 0)
		emit_signal("arrow_count_changed")

var state := State.INACTIVE:
	set(val):
		state = val
		emit_signal("state_changed")

const FIRST_ROUND = 2
var round_count = 0:
	set(val):
		round_count = val
		emit_signal("round_changed")

var lives = 0:
	set(val):
		var start = lives
		lives = val
		emit_signal("life_count_changed", lives - start)

var payoffs_this_round: int:
	set(val):
		payoffs_this_round = val
		emit_signal("payoffs_this_round_changed")

var tosses_this_round: int:
	set(val):
		tosses_this_round = val
		emit_signal("tosses_this_round_changed")
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

const DEFAULT_IGNITE_DAMAGE = 3
var ignite_damage: int = DEFAULT_IGNITE_DAMAGE:
	set(val):
		ignite_damage = val
		emit_signal("ignite_damage_changed")

const MALICE_ACTIVATION_THRESHOLD_AFTER_POWER := 100
const MALICE_ACTIVATION_THRESHOLD_AFTER_TOSS := 95
const MALICE_INCREASE_ON_POWER_USED := 2.0
const MALICE_INCREASE_ON_HEADS_PAYOFF := 5.0
const MALICE_INCREASE_ON_TOSS_FINISHED := 8.0
const MALICE_TRIAL_MULTIPLIER := 2.0
const MALICE_MULTIPLIER_END_ROUND := 0.45
var malice: float:
	set(val):
		if is_difficulty_active(Difficulty.HOSTILE2):
			malice = val
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
	
func calculate_toll_coin_value() -> int:
	var sum = 0
	for coin in toll_coins_offered:
		if coin.get_coin_family().has_tag(CoinFamily.Tag.NEGATIVE_TOLL_VALUE):
			sum -= coin.get_value()
		else:
			sum += coin.get_value()
	return sum

var active_coin_power_coin: Coin = null:
	set(val):
		active_coin_power_coin = val
		if active_coin_power_coin != null:
			active_coin_power_family = active_coin_power_coin.get_active_power_family()
		emit_signal("active_coin_power_coin_changed")

var active_coin_power_family: PF.PowerFamily:
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

# note - this trims off a pixel on the left since that's the format for our icons. Keep this in mind...
func set_custom_mouse_cursor_to_icon(icon_path: String) -> void:
	var img: Image = load(icon_path).get_image()
	assert(img is Image)
	# remove the leftmost y... this is a transparent column used for spacing the img; don't need for cursor
	img = img.get_region(Rect2(Vector2i(1, 0), img.get_size() - Vector2i(1, 0)))
	
	# for a 1920x1080 window, I like a scale factor of 5. Use the x size of the window to determine a reasonable scaling factor.
	var scale_factor = get_window().size.x * (5.0/1920.0)
	
	# now, if either dimension is above 256, we have to reduce it to 256 and scale down the other accordingly...
	var width = img.get_width() * scale_factor
	var height = img.get_height() * scale_factor
	if width > 255:
		var m = 255.0/width
		width *= m
		height *= m
	if height > 255:
		var m = 255.0/height
		width *= m
		height *= m
	
	assert(width <= 256)
	assert(height <= 256)
	
	# resize it up a bit... starts at 9x13; resize this by 5x or so
	img.resize(width, height, Image.INTERPOLATE_NEAREST)
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
			base_ante = tosses_this_round * 3
		AnteFormula.THREE_WITH_EXP:
			base_ante = tosses_this_round * 3
			add_exp = true
		AnteFormula.FOUR:
			base_ante = tosses_this_round * 4
		AnteFormula.FOUR_WITH_EXP:
			base_ante = tosses_this_round * 4
			add_exp = true
		AnteFormula.FIVE:
			base_ante = tosses_this_round * 5 
		AnteFormula.FIVE_WITH_EXP:
			base_ante = tosses_this_round * 5 
			add_exp = true
		AnteFormula.SIX:
			base_ante = tosses_this_round * 6
		AnteFormula.SIX_WITH_EXP:
			base_ante = tosses_this_round * 6
			add_exp = true
		AnteFormula.SEVEN:
			base_ante = tosses_this_round * 7
		AnteFormula.SEVEN_WITH_EXP:
			base_ante = tosses_this_round * 7
			add_exp = true
		_:
			assert(false, "Invalid ante formula...")
	
	const EXP_STARTS_AT = 7
	if add_exp and tosses_this_round >= EXP_STARTS_AT:
		base_ante += pow(2, tosses_this_round - 5)
	
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
	
	var trialDatas: Array
	
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
var _MONSTER_WAVE2 = MonsterWave.new(MonsterWave.WaveType.RANDOMIZED_STRENGTH_STANDARD_ONLY, 8, 2, 2, 1, [0, 1])
var _MONSTER_WAVE3 = MonsterWave.new(MonsterWave.WaveType.RANDOMIZED_STRENGTH_STANDARD_ONLY, 14, 2, 3, 2, [1, 2])
var _MONSTER_WAVE4 = MonsterWave.new(MonsterWave.WaveType.SPECIFIC_WAVE, 22, 0, 0, 0, [[Monster.new(Monster.Archetype.ELITE, Denomination.TRIOBOL)]])
var _MONSTER_WAVE5 = MonsterWave.new(MonsterWave.WaveType.RANDOMIZED_STRENGTH_STANDARD_ONLY, 28, 3, 5, 2, [0, 1])
var _MONSTER_WAVE6 = MonsterWave.new(MonsterWave.WaveType.SPECIFIC_WAVE, 36, 0, 0, 0, [[Monster.new(Monster.Archetype.ELITE, Denomination.TETROBOL), Monster.new(Monster.Archetype.ELITE, Denomination.TETROBOL)]])

var _MONSTER_WAVE_TUTORIAL1 = MonsterWave.new(MonsterWave.WaveType.SPECIFIC_WAVE, -1, 0, 0, 0, [[Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL)]])
var _MONSTER_WAVE_TUTORIAL2 = MonsterWave.new(MonsterWave.WaveType.SPECIFIC_WAVE, -1, 0, 0, 0, [[Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL), Monster.new(Monster.Archetype.STANDARD, Denomination.DIOBOL)]])


const STORE_UPGRADE_DISCOUNT = 0.5

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
const _SHOP_MULT5 = 3.5
const _SHOP_MULT6 = 4.0
const _SHOP_MULT7 = 4.5
const _SHOP_MULT8 = 5.0
const _SHOP_MULT9 = 5.5
const _SHOP_MULT10 = 6.0


# STANDARD (2 Gate - 2 Trial [12])
# NNN1GNN2GNNB
var _VOYAGE_STANDARD = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH, _MALICE_HIGH),
	
	
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT2, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT4, 0, 0, _MONSTER_WAVE2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TRIAL1, 100, _SHOP123, _SHOP_MULT5, 0, 60, _MONSTER_WAVE_NONE, _ANTE_MID, _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 5, 0, _MONSTER_WAVE_NONE, _ANTE_MID, _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT6,0, 0, _MONSTER_WAVE3, _ANTE_MID, _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP123, _SHOP_MULT7,0, 0, _MONSTER_WAVE4, _ANTE_MID, _MALICE_MID),
	Round.new(RoundType.TRIAL2, 100, _SHOP23, _SHOP_MULT8,0, 110, _MONSTER_WAVE_NONE, _ANTE_HIGH, _MALICE_HIGH),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 8, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH, _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP234, _SHOP_MULT9, 0, 0, _MONSTER_WAVE5, _ANTE_HIGH, _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT10,0, 0, _MONSTER_WAVE6, _ANTE_HIGH, _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH, _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH, _MALICE_HIGH)
]

# VARIANT (2 Gate - 2 Trial [12])
# NNNGNN1GNN2B
var _VOYAGE_VARIANT = [ 
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT2, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT4, 0, 0, _MONSTER_WAVE2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 4, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT5, 0, 0, _MONSTER_WAVE3, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT6, 0, 0, _MONSTER_WAVE4, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TRIAL1, 100, _SHOP23, _SHOP_MULT7, 0, 80, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 9, 0, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT8, 0, 0, _MONSTER_WAVE5, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT9, 0, 0, _MONSTER_WAVE6, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TRIAL2, 100, _SHOP34, _SHOP_MULT10,0 , 130, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH)
]
	
# BACKLOADED (2 Gate - 3 Trial [111])
# NNNN1GN1GN1B 
var _VOYAGE_BACKLOADED = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT2, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),	
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT4, 0, 0, _MONSTER_WAVE2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT5, 0, 0, _MONSTER_WAVE4, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TRIAL1, 100, _SHOP23, _SHOP_MULT6, 0, 70, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 6, 0, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT7, 0, 0, _MONSTER_WAVE5, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TRIAL1, 100, _SHOP34, _SHOP_MULT8, 0, 100, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 7, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT9, 0, 0, _MONSTER_WAVE6, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TRIAL1, 100, _SHOP34, _SHOP_MULT10, 0, 130, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT,0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT,0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH)
]

# PARTITION (1 Gate - 2 Trial [22])
# NNNN2GNNN2B
var _VOYAGE_PARTITION = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT2, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),	
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT4, 0, 0, _MONSTER_WAVE2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT5, 0, 0, _MONSTER_WAVE3, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TRIAL2, 100, _SHOP23, _SHOP_MULT6, 0, 60, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT,10, 0, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT7, 0, 0, _MONSTER_WAVE4, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT8, 0, 0, _MONSTER_WAVE5, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT9, 0, 0, _MONSTER_WAVE6, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TRIAL2, 100, _SHOP34, _SHOP_MULT10, 0, 120, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT, 0, 0,  _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH)
]

# FRONTLOAD - (1 Gate - 3 Trial [112])
# NN1NN1GNN2B
var _VOYAGE_FRONTLOAD = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT2, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TRIAL1, 100, _SHOP12, _SHOP_MULT4, 0, 40, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT5, 0, 0, _MONSTER_WAVE2, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT6, 0, 0, _MONSTER_WAVE3, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TRIAL1, 100, _SHOP23, _SHOP_MULT7, 0, 70, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 11, 0, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT8, 0, 0, _MONSTER_WAVE4, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100,_SHOP34, _SHOP_MULT9, 0, 0, _MONSTER_WAVE6, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TRIAL2, 100, _SHOP34, _SHOP_MULT10, 0, 120, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH)
]

# INTERSPERSED - (3 Gate - 2 Trial [12)
# NNGN1NGN2NGNB
var _VOYAGE_INTERSPERSED = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT2, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),	
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT3, 0, 0, _MONSTER_WAVE1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 2, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT4, 0, 0, _MONSTER_WAVE2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TRIAL1, 100, _SHOP23, _SHOP_MULT5, 0, 50, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT6, 0, 0, _MONSTER_WAVE3, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 5, 0, _MONSTER_WAVE_NONE, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT7, 0, 0, _MONSTER_WAVE4, _ANTE_MID,  _MALICE_MID),
	Round.new(RoundType.TRIAL2, 100, _SHOP34, _SHOP_MULT8, 0, 100, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT9, 0, 0, _MONSTER_WAVE5, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 8, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NORMAL, 100, _SHOP34, _SHOP_MULT10, 0, 0, _MONSTER_WAVE6, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.NEMESIS, 100, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH),
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_HIGH,  _MALICE_HIGH)
]

# TUTORIAL (2 Gate - 2 Trial [12])
# NNN1GNN2GNNB
var _VOYAGE_TUTORIAL = [
	Round.new(RoundType.BOARDING, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), 
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP1, _SHOP_MULT1, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP12, _SHOP_MULT2, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT2, 0, 0, _MONSTER_WAVE_TUTORIAL1, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.NORMAL, 100, _SHOP23, _SHOP_MULT3, 0, 0, _MONSTER_WAVE_TUTORIAL2, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TRIAL1, 100, _SHOP23, _SHOP_MULT3, 0, 70, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW),
	Round.new(RoundType.TOLLGATE, 0, _NOSHOP, _NOMULT, 8, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW), #8 is intentional to prevent possible bugs, don't increase
	Round.new(RoundType.END, 0, _NOSHOP, _NOMULT, 0, 0, _MONSTER_WAVE_NONE, _ANTE_LOW, _MALICE_LOW)
]

const NUM_STANDARD_MONSTERS = 4
const NUM_ELITE_MONSTERS = 2
@onready var NEUTRAL_MONSTERS = [MONSTER_CENTAUR_FAMILY, MONSTER_STYMPHALIAN_BIRDS_FAMILY, MONSTER_COLCHIAN_DRAGON_FAMILY, MONSTER_PHOENIX_FAMILY,\
	MONSTER_OREAD_FAMILY, MONSTER_HAMADRYAD_FAMILY, MONSTER_SATYR_FAMILY, MONSTER_RELIQUARY_FAMILY]
@onready var STANDARD_MONSTERS = [MONSTER_HELLHOUND_FAMILY, MONSTER_KOBALOS_FAMILY, MONSTER_ARAE_FAMILY, MONSTER_HARPY_FAMILY, MONSTER_TROJAN_HORSE_FAMILY,\
	MONSTER_EIDOLON_FAMILY, MONSTER_HYPERBOREAN_FAMILY, MONSTER_GADFLY_FAMILY, MONSTER_STRIX_FAMILY, MONSTER_EMPUSA_FAMILY, MONSTER_ERYMANTHIAN_BOAR_FAMILY,\
	MONSTER_SPARTOI_FAMILY]
@onready var ELITE_MONSTERS = [MONSTER_SIREN_FAMILY, MONSTER_CHIMERA_FAMILY, MONSTER_BASILISK_FAMILY, MONSTER_GORGON_FAMILY, MONSTER_KERES_FAMILY, MONSTER_TEUMESSIAN_FOX_FAMILY,\
	MONSTER_MANTICORE_FAMILY, MONSTER_FURIES_FAMILY, MONSTER_SPHINX_FAMILY, MONSTER_CYCLOPS_FAMILY]
var _neutral_monster_pool = []
var _standard_monster_pool = []
var _elite_monster_pool = []

func get_neutral_monster() -> CoinFamily:
	return Global.choose_one(_neutral_monster_pool)

func get_standard_monster() -> CoinFamily:
	if Global.RNG.randi_range(1, 1000) == 1:
		return MONSTER_AETERNAE_FAMILY
	return Global.choose_one(_standard_monster_pool)

func get_standard_monster_excluding(excluded: Array) -> CoinFamily:
	return Global.choose_one_excluding(_standard_monster_pool, excluded)

func get_elite_monster() -> CoinFamily:
	return Global.choose_one(_elite_monster_pool)

func get_standard_monster_pool() -> Array:
	return _standard_monster_pool

func get_elite_monster_pool() -> Array:
	return _elite_monster_pool

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
	VOYAGE = _VOYAGE_STANDARD.duplicate(true)
	
	var possible_trials_lv1 = LV1_TRIALS.duplicate(true)
	var possible_trials_lv2 = LV2_TRIALS.duplicate(true)
	var possible_nemesis = NEMESES.duplicate(true)
	
	# randomize trials & nemesis
	for rnd in VOYAGE:
		rnd.trialDatas.clear() # Godot does not deep copy these, so they need to be manually cleared
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
	if round_count >= VOYAGE.size():
		return []
	
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
					
					# if we absolutely cannot find anything in the desired range, start going up/down until we find SOMETHING possible
					var force = randomization_amount
					while possibilities.size() == 0: 
						force += 1
						possibilities += combination_sum(strength + force, values, min_monsters, max_monsters)
						possibilities += combination_sum(strength - force, values, min_monsters, max_monsters)
					
					# now choose a random combination and translate it into coin_data, rolling specific monster types
					var combination = Global.choose_one(possibilities)
					for val in combination:
						if strength_to_denom_standard.has(val):
							coin_data.append([Global.choose_one(_standard_monster_pool), strength_to_denom_standard[val]])
						else:
							assert(strength_to_denom_elite.has(val))
							coin_data.append([Global.choose_one(_elite_monster_pool), strength_to_denom_elite[val]])
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
	TrialData.new("[color=lightgreen]The Gorgon Sisters[/color]", [EURYALE_FAMILY, MEDUSA_FAMILY, STHENO_FAMILY], "Three sisters shunned by the heavens. Be rendered helpless by their petrifying gaze.", NEMESIS_POWER_FAMILY_MEDUSA_STONE.icon_path),
	TrialData.new("[color=crimson]Cerberus, the Gatekeeper[/color]", [CERBERUS_LEFT_FAMILY, CERBERUS_MIDDLE_FAMILY, CERBERUS_RIGHT_FAMILY], "The three-headed beast's flaming maws draw blood. A fight to the death, intensity rising.", "res://assets/icons/nemesis/cerberus_icon.png"),
	TrialData.new("[color=paleturquoise]Scylla and Charybdis[/color]", [SCYLLA_FAMILY, CHARYBDIS_FAMILY], "To the left or to the right? Half the crew cowers in fear, and scatters.", NEMESIS_POWER_FAMILY_SCYLLA_SHUFFLE.icon_path),
	TrialData.new("[color=springgreen]Echidna and Typhon[/color]", [ECHIDNA_FAMILY, TYPHON_FAMILY], "Born from the mother and father of all monsters, they swarm and grow.", NEMESIS_POWER_FAMILY_ECHIDNA_SPAWN_STRONG.icon_path),
	TrialData.new("[color=lightsteelblue]Escape the Minotaur[/color]", [MINOTAUR_FAMILY, LABYRINTH_PASSIVE_FAMILY, LABYRINTH_WALLS1_FAMILY, LABYRINTH_WALLS2_FAMILY, LABYRINTH_WALLS3_FAMILY, LABYRINTH_WALLS4_FAMILY], "An immortal pursuer stalks you in stygian dread. Seek a path to the light.", NEMESIS_POWER_FAMILY_MINOTAUR_SCALING_CURSE_UNLUCKY.icon_path)
]

# extra reference to this for use in tutorial
@onready var _PAIN_TRIAL = TrialData.new(TRIAL_PAIN_FAMILY.coin_name, [TRIAL_PAIN_FAMILY], TRIAL_POWER_FAMILY_PAIN.description, TRIAL_POWER_FAMILY_PAIN.icon_path)
@onready var LV1_TRIALS = [
	TrialData.new(TRIAL_IRON_FAMILY.coin_name, [TRIAL_IRON_FAMILY], TRIAL_POWER_FAMILY_IRON.description, TRIAL_POWER_FAMILY_IRON.icon_path),
	TrialData.new(TRIAL_MISFORTUNE_FAMILY.coin_name, [TRIAL_MISFORTUNE_FAMILY], TRIAL_POWER_FAMILY_MISFORTUNE.description, TRIAL_POWER_FAMILY_MISFORTUNE.icon_path),
	TrialData.new(TRIAL_EQUIVALENCE_FAMILY.coin_name, [TRIAL_EQUIVALENCE_FAMILY], TRIAL_POWER_FAMILY_EQUIVALENCE.description, TRIAL_POWER_FAMILY_EQUIVALENCE.icon_path),
	_PAIN_TRIAL,
	TrialData.new(TRIAL_BLOOD_FAMILY.coin_name, [TRIAL_BLOOD_FAMILY], TRIAL_POWER_FAMILY_BLOOD.description, TRIAL_POWER_FAMILY_BLOOD.icon_path),
	TrialData.new(TRIAL_LIMITATION_FAMILY.coin_name, [TRIAL_LIMITATION_FAMILY], TRIAL_POWER_FAMILY_LIMITATION.description, TRIAL_POWER_FAMILY_LIMITATION.icon_path),
	TrialData.new(TRIAL_SAPPING_FAMILY.coin_name, [TRIAL_SAPPING_FAMILY], TRIAL_POWER_FAMILY_SAPPING.description, TRIAL_POWER_FAMILY_SAPPING.icon_path),
	TrialData.new(TRIAL_TORMENT_FAMILY.coin_name, [TRIAL_TORMENT_FAMILY], TRIAL_POWER_FAMILY_TORMENT.description, TRIAL_POWER_FAMILY_TORMENT.icon_path),
	TrialData.new(TRIAL_MALAISE_FAMILY.coin_name, [TRIAL_MALAISE_FAMILY], TRIAL_POWER_FAMILY_MALAISE.description, TRIAL_POWER_FAMILY_MALAISE.icon_path),
	TrialData.new(TRIAL_VIVISEPULTURE_FAMILY.coin_name, [TRIAL_VIVISEPULTURE_FAMILY], TRIAL_POWER_FAMILY_VIVISEPULTURE.description, TRIAL_POWER_FAMILY_VIVISEPULTURE.icon_path),
	TrialData.new(TRIAL_IMMOLATION_FAMILY.coin_name, [TRIAL_IMMOLATION_FAMILY], TRIAL_POWER_FAMILY_IMMOLATION.description, TRIAL_POWER_FAMILY_IMMOLATION.icon_path),
	TrialData.new(TRIAL_VENGEANCE_FAMILY.coin_name, [TRIAL_VENGEANCE_FAMILY], TRIAL_POWER_FAMILY_VENGEANCE.description, TRIAL_POWER_FAMILY_VENGEANCE.icon_path),
]

@onready var LV2_TRIALS = [
	TrialData.new(TRIAL_FAMINE_FAMILY.coin_name, [TRIAL_FAMINE_FAMILY], TRIAL_POWER_FAMILY_FAMINE.description, TRIAL_POWER_FAMILY_FAMINE.icon_path),
	TrialData.new(TRIAL_TORTURE_FAMILY.coin_name, [TRIAL_TORTURE_FAMILY], TRIAL_POWER_FAMILY_TORTURE.description, TRIAL_POWER_FAMILY_TORTURE.icon_path),
	TrialData.new(TRIAL_COLLAPSE_FAMILY.coin_name, [TRIAL_COLLAPSE_FAMILY], TRIAL_POWER_FAMILY_COLLAPSE.description, TRIAL_POWER_FAMILY_COLLAPSE.icon_path),
	TrialData.new(TRIAL_OVERLOAD_FAMILY.coin_name, [TRIAL_OVERLOAD_FAMILY], TRIAL_POWER_FAMILY_OVERLOAD.description, TRIAL_POWER_FAMILY_OVERLOAD.icon_path),
	TrialData.new(TRIAL_PETRIFICATION_FAMILY.coin_name, [TRIAL_PETRIFICATION_FAMILY], TRIAL_POWER_FAMILY_PETRIFICATION.description, TRIAL_PETRIFICATION_FAMILY.icon_path),
	TrialData.new(TRIAL_SILENCE_FAMILY.coin_name, [TRIAL_SILENCE_FAMILY], TRIAL_POWER_FAMILY_SILENCE.description, TRIAL_POWER_FAMILY_SILENCE.icon_path),
	TrialData.new(TRIAL_POLARIZATION_FAMILY.coin_name, [TRIAL_POLARIZATION_FAMILY], TRIAL_POWER_FAMILY_POLARIZATION.description, TRIAL_POWER_FAMILY_POLARIZATION.icon_path),
	TrialData.new(TRIAL_SINGULARITY_FAMILY.coin_name, [TRIAL_SINGULARITY_FAMILY], TRIAL_POWER_FAMILY_SINGULARITY.description, TRIAL_POWER_FAMILY_SINGULARITY.icon_path),
	TrialData.new(TRIAL_GATING_FAMILY.coin_name, [TRIAL_GATING_FAMILY], TRIAL_POWER_FAMILY_GATING.description, TRIAL_POWER_FAMILY_GATING.icon_path),
	TrialData.new(TRIAL_FATE_FAMILY.coin_name, [TRIAL_FATE_FAMILY], TRIAL_POWER_FAMILY_FATE.description, TRIAL_POWER_FAMILY_FATE.icon_path),
	TrialData.new(TRIAL_ADVERSITY_FAMILY.coin_name, [TRIAL_ADVERSITY_FAMILY], TRIAL_POWER_FAMILY_ADVERSITY.description, TRIAL_POWER_FAMILY_ADVERSITY.icon_path),
	TrialData.new(TRIAL_VAINGLORY_FAMILY.coin_name, [TRIAL_VAINGLORY_FAMILY], TRIAL_POWER_FAMILY_VAINGLORY.description, TRIAL_POWER_FAMILY_VAINGLORY.icon_path),
	
]

const ONLY_SHOW_ICON = true
const ICON_AND_CHARGES = false
const INFINITE_CHARGES = -88888

var PARTICLE_COLOR_NONE = Color(0, 0, 0, 0)
var PARTICLE_COLOR_WHITE = Color.WHITE
var PARTICLE_COLOR_RED = Color("#df3e23")
var PARTICLE_COLOR_BLUE = Color("#a6fcdb")
var PARTICLE_COLOR_GREEN = Color("#9cdb43")
var PARTICLE_COLOR_YELLOW = Color("#fffc40")
var PARTICLE_COLOR_PURPLE = Color("#e86a73")
var PARTICLE_COLOR_BROWN = Color("#f4d29c")
var PARTICLE_COLOR_GRAY = Color("#b3b9d1")
var PARTICLE_COLOR_BLACK = Color.BLACK

var POWER_FAMILY_LOSE_LIFE = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE).", [2, 4, 7, 10, 14, 19], PF.PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)
var POWER_FAMILY_LOSE_LIFE_DOUBLED = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE).", [4, 8, 14, 20, 28, 38], PF.PowerType.PAYOFF_LOSE_LIFE,"res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)
var POWER_FAMILY_LOSE_LIFE_THORNS = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE).", [1, 2, 3, 4, 5, 6], PF.PowerType.PAYOFF_LOSE_LIFE,"res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)
var POWER_FAMILY_LOSE_ZERO_LIFE = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE).", [0, 0, 0, 0], PF.PowerType.PAYOFF_LOSE_LIFE,"res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)
var POWER_FAMILY_LOSE_LIFE_ACHILLES_HEEL = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE). Destroy this coin.", [10, 20, 30, 40], PF.PowerType.PAYOFF_LOSE_LIFE,"res://assets/icons/coin/achilles_tails_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)
var POWER_FAMILY_LOSE_LIFE_ONE = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE)", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_LOSE_LIFE,"res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)

var POWER_FAMILY_LOSE_SOULS_THORNS = PF.PayoffLoseSouls.new("-(MAX_CHARGES)(SOULS).", [1, 2, 3, 4, 5, 6], PF.PowerType.PAYOFF_LOSE_SOULS,"res://assets/icons/soul_fragment_blue_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)

var POWER_FAMILY_GAIN_SOULS = PF.PayoffGainSouls.new("+(SOULS_PAYOFF)(SOULS).", [5, 8, 11, 13, 15, 17], PF.PowerType.PAYOFF_GAIN_SOULS,"res://assets/icons/soul_fragment_blue_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)
var POWER_FAMILY_GAIN_SOULS_ACHILLES = PF.PayoffGainSouls.new("+(SOULS_PAYOFF)(SOULS).", [10, 14, 17, 20, 23, 26], PF.PowerType.PAYOFF_GAIN_SOULS,"res://assets/icons/coin/achilles_heads_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)
var POWER_FAMILY_GAIN_SOULS_HELIOS = PF.PayoffGainSouls.new("+(MAX_CHARGES)(SOULS) for each coin to the left of this.\n(BLESS) the coin to the left, then swap places with it.", [1, 2, 3, 4, 5, 6],\
	PF.PowerType.PAYOFF_GAIN_SOULS, "res://assets/icons/coin/helios_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)
var ICARUS_HEADS_MULTIPLIER = [1, 1, 2, 2, 3, 3]
var POWER_FAMILY_GAIN_SOULS_ICARUS = PF.PayoffGainSouls.new("+(MAX_CHARGES)(SOULS). +(ICARUS_PER_HEADS)(SOULS) for each of your (HEADS) coins. If all of your coins are on (HEADS), destroy this.", [2, 3, 4, 5, 6, 7],\
	PF.PowerType.PAYOFF_GAIN_SOULS, "res://assets/icons/coin/icarus_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)
var POWER_FAMILY_GAIN_SOULS_TANTALUS = PF.PowerFamily.new("If this face is showing, immediately +(MAX_CHARGES)(SOULS) and turn this coin over.", [3, 4, 5, 6, 7, 8],\
	 PF.PowerType.PASSIVE, "res://assets/icons/coin/tantalus_icon.png", PARTICLE_COLOR_BLUE, ONLY_SHOW_ICON)
var POWER_FAMILY_GAIN_SOULS_AENEAS = PF.PayoffGainSouls.new("+(SOULS_PAYOFF)(SOULS).", [3, 4, 5, 6, 7, 8],\
	 PF.PowerType.PAYOFF_GAIN_SOULS, "res://assets/icons/coin/aeneas_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)
var POWER_FAMILY_GAIN_SOULS_ORION = PF.PayoffGainSouls.new("+(SOULS_PAYOFF)(SOULS).", [4, 4, 4, 4, 4, 4],\
	 PF.PowerType.PAYOFF_GAIN_SOULS, "res://assets/icons/coin/orion_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)
var POWER_FAMILY_GAIN_ARROWS_ORION = PF.PayoffGainArrows.new("+(MAX_CHARGES)(ARROW).", [1, 2, 3, 4, 5, 6], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/arrow_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)
var CARPO_ROUND_MULTIPLIER = [1, 2, 3, 4, 5, 6]
var POWER_FAMILY_GAIN_SOULS_CARPO = PF.PayoffGainSouls.new("+(SOULS_PAYOFF)(SOULS). Increases by (CARPO_PER_PAYOFF)(SOULS) after each payoff [color=gray](Resets when the round ends)[/color].", [2, 2, 2, 2, 2, 2], PF.PowerType.PAYOFF_GAIN_SOULS, "res://assets/icons/coin/carpo_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)
var TELEMACHUS_TOSSES_TO_TRANSFORM = 20 #20 years - length of time Odyseeus is away
var POWER_FAMILY_GAIN_SOULS_TELEMACHUS = PF.PayoffGainSouls.new("+(MAX_CHARGES)(SOULS). In (TELEMACHUS_TOSSES_REMAINING) more payoffs, transform into a random power Drachma and eternally (CONSECRATE).", \
	[1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_GAIN_SOULS, "res://assets/icons/coin/telemachus_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES)
var POWER_FAMILY_GAIN_SOULS_PLUTUS = PF.PayoffGainSouls.new("+(SOULS_PAYOFF)(SOULS).", [6, 9, 12, 15, 18, 21], PF.PowerType.PAYOFF_GAIN_SOULS,"res://assets/icons/soul_fragment_blue_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)
var POWER_FAMILY_LOSE_LIFE_PLUTUS = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE).", [6, 9, 12, 15, 18, 21], PF.PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)
const PROMETHEUS_MULTIPLIER = [1, 2, 3, 4, 5, 6]
var POWER_FAMILY_STOKE_FLAME = PF.PayoffStokeFlame.new("Stoke the flame. [color=gray](For the rest of the voyage, ALL coins permanently land on (HEADS) +(PROMETHEUS_MULTIPLIER)%% more often, up to +%d%%.)[/color]" % FLAME_BOOST_LIMIT, [1, 1, 1, 1, 1, 1],\
	PF.PowerType.PAYOFF_STOKE_FLAME, "res://assets/icons/coin/prometheus_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES, [PF.PowerFamily.Tag.LUCKY])
var POWER_FAMILY_DO_NOTHING = PF.PayoffDoNothing.new("Nothing interesting happens.", [0, 0, 0, 0, 0, 0], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/coin/nothing_icon.png", PARTICLE_COLOR_NONE, ONLY_SHOW_ICON)

const DEMETER_GAIN = [3, 5, 7, 9, 11, 13]
var POWER_FAMILY_GAIN_LIFE = PF.GainLife.new("+(DEMETER_GAIN)(HEAL)", [1, 1, 1, 1, 1, 1], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/demeter_icon.png", PARTICLE_COLOR_GREEN, ICON_AND_CHARGES, [PF.PowerFamily.Tag.HEAL])
var POWER_FAMILY_REFLIP = PF.Reflip.new("Reflip a coin.", [2, 3, 4, 5, 6, 7], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/zeus_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES, [PF.PowerFamily.Tag.REFLIP])
var POWER_FAMILY_FREEZE = PF.Freeze.new("(FREEZE) a coin.", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/poseidon_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.FREEZE])
var POWER_FAMILY_REFLIP_AND_NEIGHBORS = PF.ReflipAndNeighbors.new("Reflip a coin and its neighbors.", [1, 2, 3, 4, 5, 6],\
	PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/hera_icon.png", PARTICLE_COLOR_WHITE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.REFLIP, PF.PowerFamily.Tag.POSITIONING])
var POWER_FAMILY_GAIN_ARROW = PF.GainArrow.new("+(1_PER_DENOM)(ARROW).", [1, 1, 1, 1, 1, 1], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/artemis_icon.png", PARTICLE_COLOR_PURPLE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.REFLIP])
var POWER_FAMILY_TURN_AND_BLURSE = PF.TurnAndBlurse.new("Turn a coin to its other face. Then, if it's (HEADS), (CURSE) it, if it's (TAILS), (BLESS) it.", [1, 2, 3, 4, 5, 6],\
	PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/apollo_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES, [PF.PowerFamily.Tag.BLESS, PF.PowerFamily.Tag.TURN, PF.PowerFamily.Tag.CURSE])
var POWER_FAMILY_REFLIP_ALL = PF.ReflipAll.new("Reflip all coins.", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/ares_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES, [PF.PowerFamily.Tag.REFLIP])
var POWER_FAMILY_REDUCE_PENALTY = PF.ReducePenalty.new("Reduce a coin's penalty by 2(LIFE) for this round.", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/athena_icon.png", PARTICLE_COLOR_GREEN, ICON_AND_CHARGES, [PF.PowerFamily.Tag.HEAL, PF.PowerFamily.Tag.ANTIMONSTER])
var POWER_FAMILY_PRIME_AND_IGNITE = PF.PrimeAndIgnite.new("(IGNITE) and (PRIME) one of your coins.", [1, 2, 3, 4, 5, 6],\
	PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/hephaestus_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES, [PF.PowerFamily.Tag.UPGRADE, PF.PowerFamily.Tag.IGNITE])
var POWER_FAMILY_COPY_FOR_TOSS = PF.CopyPowerForToss.new("Choose one of your coins. Copy its power for this toss.", [1, 1, 1, 1, 1, 1], PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/aphrodite_icon.png", PARTICLE_COLOR_WHITE, ICON_AND_CHARGES)
var POWER_FAMILY_EXCHANGE = PF.Exchange.new("Trade a coin for another of equal value.", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/hermes_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES, [PF.PowerFamily.Tag.TRADE])
var POWER_FAMILY_MAKE_LUCKY = PF.MakeLucky.new("Make a coin (LUCKY).", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/hestia_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES, [PF.PowerFamily.Tag.LUCKY])
var POWER_FAMILY_GAIN_COIN = PF.GainCoin.new("Gain a random Obol.", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/dionysus_icon.png", PARTICLE_COLOR_PURPLE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.GAIN])
var POWER_FAMILY_DOWNGRADE_FOR_LIFE = PF.DowngradeForLife.new("Downgrade a coin. If the coin was yours, +(HADES_SELF_GAIN)(HEAL); if the coin was a monster, -(HADES_MONSTER_COST)(LIFE).", [1, 1, 1, 1, 1, 1],\
	PF.PowerType.POWER_TARGETTING_ANY_COIN,"res://assets/icons/coin/hades_icon.png", PARTICLE_COLOR_PURPLE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.DESTROY, PF.PowerFamily.Tag.HEAL])

var POWER_FAMILY_STONE = PF.Stone.new("Turn one of your coins to or from (STONE).", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/perseus_icon.png", PARTICLE_COLOR_GRAY, ICON_AND_CHARGES, [PF.PowerFamily.Tag.STONE])
var POWER_FAMILY_BLANK_TAILS = PF.BlankTails.new("Choose a (TAILS) coin; (BLANK) it. [color=gray](Does not work on the Nemesis.)[/color]", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/hypnos_icon.png", PARTICLE_COLOR_WHITE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.ANTIMONSTER, PF.PowerFamily.Tag.BLANK])
var POWER_FAMILY_CONSECRATE_AND_DOOM = PF.ConsecrateDoom.new("(CONSECRATE) and (DOOM) a coin. [color=gray](It always lands on (HEADS), but is destroyed at the end of the round.)[/color]", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/nike_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES, [PF.PowerFamily.Tag.GAIN, PF.PowerFamily.Tag.CONSECRATE, PF.PowerFamily.Tag.DOOM])
const TRIPTOLEMUS_HARVEST = [5, 8, 11, 14, 17, 20]
var POWER_FAMILY_BURY_HARVEST = PF.BuryHarvest.new("(BURY) one of your coins for 3 tosses. When it's exhumed, +(TRIPTOLEMUS_HARVEST)(SOULS) and +(TRIPTOLEMUS_HARVEST)(HEAL).", [1, 1, 1, 1, 1, 1],\
	PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/triptolemus_icon.png", PARTICLE_COLOR_GREEN, ICON_AND_CHARGES, [PF.PowerFamily.Tag.BURY, PF.PowerFamily.Tag.HEAL])
var POWER_FAMILY_BURY_TURN_TAILS = PF.BuryTurnOtherTails.new("(BURY) one of your coins for 1 toss. Immediately turn one of your (TAILS) coins to (HEADS) at random.", [1, 2, 3, 4, 5, 6],\
	PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/antigone_icon.png", PARTICLE_COLOR_BROWN, ICON_AND_CHARGES, [PF.PowerFamily.Tag.BURY, PF.PowerFamily.Tag.TURN])
var POWER_FAMILY_TURN_TAILS_FREEZE_REDUCE_PENALTY = PF.TurnTailsFreezeReducePenalty.new("Turn a coin to (TAILS) and (FREEZE) it. If the coin is yours, reduce its penalty to 0(LIFE) this round.", [1, 2, 3, 4, 5, 6],\
	PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/chione_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.FREEZE, PF.PowerFamily.Tag.ANTIMONSTER])
var POWER_FAMILY_IGNITE_CHARGE_LUCKY = PF.IgniteChargeLucky.new("Make a coin (LUCKY), (CHARGE), and (IGNITE) it.", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/hecate_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES, [PF.PowerFamily.Tag.LUCKY, PF.PowerFamily.Tag.CHARGE, PF.PowerFamily.Tag.IGNITE])
const PHAETHON_REWARD_SOULS = [5, 10, 15, 20, 25, 30]
const PHAETHON_REWARD_ARROWS = [2, 3, 4, 5, 6, 7]
const PHAETHON_REWARD_LIFE = [5, 10, 15, 20, 25, 30]
var POWER_FAMILY_DESTROY_FOR_REWARD = PF.DestroySelfForReward.new("Destroy this for +(PHAETHON_SOULS)(SOULS), +(PHAETHON_LIFE)(HEAL), and +(PHAETHON_ARROWS)(ARROW). Fully recharge your patron token.", [1, 1, 1, 1, 1, 1],\
	PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/phaethon_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES)
var POWER_FAMILY_INFINITE_TURN_HUNGER = PF.InfiniteTurnHunger.new("Turn a coin and -(ERYSICHTHON_COST)(LIFE). [color=gray](Permanently increases by 1(LIFE) each use. Resets when upgraded.)[/color]", [INFINITE_CHARGES, INFINITE_CHARGES, INFINITE_CHARGES, INFINITE_CHARGES, INFINITE_CHARGES, INFINITE_CHARGES],\
	PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/erysichthon_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES, [PF.PowerFamily.Tag.TURN])
var POWER_FAMILY_TURN_SELF = PF.TurnSelf.new("Turn this coin over.", [1, 1, 1, 1, 1, 1],\
	PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/turn_icon.png", PARTICLE_COLOR_WHITE, ICON_AND_CHARGES)
var POWER_FAMILY_CLONE_PERMANENTLY = PF.ClonePermanently.new("Choose one of your coins of the same denomination as this; permanently transform into that type of coin.", [1, 1, 1, 1, 1, 1], PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/dolos_icon.png", PARTICLE_COLOR_WHITE, ICON_AND_CHARGES)
var POWER_FAMILY_FLIP_AND_TAG = PF.FlipAndTag.new("Reflip a coin. Also reflip each other coin this power has been used on this toss.", [2, 3, 4, 5, 6, 7], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/eris_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES, [PF.PowerFamily.Tag.REFLIP])
var POWER_FAMILY_REFLIP_LEFT_ALTERNATING = PF.ReflipLeftAlternating.new("Reflip all coins to the [color=yellow]left[/color] of this [color=gray](alternates [color=yellow]direction[/color] each use)[/color].", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/aeolus_left_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.REFLIP, PF.PowerFamily.Tag.POSITIONING])
var POWER_FAMILY_REFLIP_RIGHT_ALTERNATING = PF.ReflipRightAlternating.new("Reflip all coins to the [color=yellow]right[/color] of this [color=gray](alternates direction each use)[/color].", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/aeolus_right_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.REFLIP, PF.PowerFamily.Tag.POSITIONING])
var POWER_FAMILY_SWAP_REFLIP_NEIGHBORS = PF.SwapReflipNeighbors.new("Choose one of your coins. Swap positions with it, then reflip each neighboring coin.", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/boreas_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.REFLIP, PF.PowerFamily.Tag.POSITIONING])
var POWER_FAMILY_PERMANENTLY_COPY_FACE_AND_DESTROY = PF.CopyPowerPermanentlyAndDestroy.new("Choose a coin. Permanently copy its power to this face, then destroy it.", [1, 1, 1, 1, 1, 1, 1], PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/daedalus_icon.png", PARTICLE_COLOR_WHITE, ICON_AND_CHARGES)
var POWER_FAMILY_GAIN_PLUTUS_COIN = PF.GainPlutusCoin.new("Gain an Obol with \"(HEADS)+6(SOULS)/(TAILS)-6(LIFE)\" and flip it. It is (FLEETING). [color=gray](After payoff, it is destroyed.)[/color]", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/plutus_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES, [PF.PowerFamily.Tag.GAIN])
var POWER_FAMILY_GAIN_GOLDEN_COIN = PF.GainGoldenCoin.new("Gain a golden (THIS_DENOMINATION)! [color=gray](Golden coins do nothing on both faces.)[/color]", [1, 1, 1, 1, 1, 1], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/midas_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES, [PF.PowerFamily.Tag.GAIN])
var POWER_FAMILY_TURN_ALL = PF.TurnAll.new("Turn each coin to its other face.", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/dike_icon.png", PARTICLE_COLOR_WHITE, ICON_AND_CHARGES, [PF.PowerFamily.Tag.TURN])
var POWER_FAMILY_IGNITE_OR_BLESS_OR_SACRIFICE = PF.IgniteThenBlessThenSacrifice.new("(IGNITE) one of your coins. If you can't, (BLESS) it. If you can't, destroy it and downgrade a random monster twice.", [1, 2, 3, 4, 5, 6],\
	PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/sarpedon_icon.png", PARTICLE_COLOR_YELLOW, ICON_AND_CHARGES, [PF.PowerFamily.Tag.IGNITE, PF.PowerFamily.Tag.BLESS, PF.PowerFamily.Tag.DESTROY])
var POWER_FAMILY_TRANSFORM_AND_LOCK = PF.PowerFamily.new("Becomes a random power each toss. When used, this face permanently becomes that power.", [0, 0, 0, 0, 0, 0],\
	PF.PowerType.PASSIVE, "res://assets/icons/coin/proteus_icon.png", PARTICLE_COLOR_BLUE, ONLY_SHOW_ICON)

#var POWER_FAMILY_GOLDEN_FLEECE = PF.PowerFamily.new("Gain a wisp of Golden Fleece! [color=gray](For each wisp, coins in the shop cost -1(SOULS).)[/color]", [1, 2, 3, 4, 5, 6], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/jason_icon.png", ICON_AND_CHARGES)

var POWER_FAMILY_ARROW_REFLIP = PF.Reflip.new("Reflip a coin.", [0, 0, 0, 0, 0, 0], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/arrow_icon.png", PARTICLE_COLOR_WHITE, ONLY_SHOW_ICON)

# standard
var MONSTER_POWER_FAMILY_HELLHOUND = PF.PayoffIgniteSelf.new("(IGNITE) this coin.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/hellhound_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_KOBALOS = PF.PayoffUnlucky.new("Make (CURRENT_CHARGES_COINS) (UNLUCKY).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/kobalos_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_ARAE = PF.PayoffCurse.new("(CURSE) (CURRENT_CHARGES_COINS).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/arae_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_HARPY = PF.PayoffBlank.new("(BLANK) (CURRENT_CHARGES_COINS).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/harpy_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)

var MONSTER_POWER_FAMILY_TROJAN_HORSE_DESTROY = PF.PayoffTrojanHorse.new("Destroy this coin. Spawn (CURRENT_CHARGES) monsters.", [2, 2, 2, 3, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/trojan_horse_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_EIDOLON_UNLUCKY_SELF = PF.PayoffAllMonsterUnlucky.new("All monsters become (UNLUCKY).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/eidolon_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_HYPERBOREAN_FREEZE = PF.PayoffFreeze.new("(FREEZE) (CURRENT_CHARGES_COINS).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/hyperborean_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_HYPERBOREAN_LOSE_SOULS = PF.PayoffLoseSouls.new("-(CURRENT_CHARGES)(SOULS).", [3, 4, 5, 6, 7, 8], PF.PowerType.PAYOFF_LOSE_SOULS, "res://assets/icons/soul_fragment_blue_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var GADFLY_THORNS_DENOM = [Denomination.OBOL, Denomination.OBOL, Denomination.DIOBOL, Denomination.DIOBOL, Denomination.TRIOBOL, Denomination.TRIOBOL]
var MONSTER_POWER_FAMILY_GADFLY_THORNS = PF.PayoffGainThornsGadfly.new("Gain an (GADFLY_DENOM) of Thorns.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/gadfly_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var GADFLY_INCREASE = [1, 2, 3, 4, 5, 6]
var MONSTER_POWER_FAMILY_GADFLY_LOSE_LIFE_SCALING = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE). Increase this penalty by (GADFLY_INCREASE)(LIFE).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)
var STRIX_INCREASE = [2, 3, 4, 5, 6, 7]
var MONSTER_POWER_FAMILY_STRIX_INCREASE_PENALTY = PF.PayoffIncreaseAllPlayerPenalty.new("Increase the (LIFE) penalty of each of your coins by (STRIX_INCREASE)(LIFE) for this round.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/strix_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var LAMIA_BURY = [2, 2, 3, 3, 4, 4]
var MONSTER_POWER_FAMILY_LAMIA_BURY = PF.PayoffBury.new("(BURY) 2 coins for (LAMIA_BURY) payoffs.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/lamia_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_LAMIA_LOSE_SOULS = PF.PayoffLoseSouls.new("-(CURRENT_CHARGES)(SOULS).", [3, 4, 5, 6, 7, 8], PF.PowerType.PAYOFF_LOSE_SOULS, "res://assets/icons/soul_fragment_blue_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var BOAR_BURY = [1, 1, 1, 1, 1, 1]
var MONSTER_POWER_FAMILY_ERYMANTHIAN_BOAR_BURY = PF.PayoffBurySelf.new("Turn this coin over and (BURY) it for (BOAR_BURY) payoff.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/erymanthian_boar_icon.png", PARTICLE_COLOR_BROWN, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_SPARTOI_UPGRADE_SELF = PF.PayoffUpgradeSelf.new("Upgrade this coin.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/spartoi_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)

# encounters
var MONSTER_POWER_FAMILY_CENTAUR_HEADS = PF.PayoffLucky.new("Make (CURRENT_CHARGES_COINS) (LUCKY).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/monster/centaur_heads_icon.png", PARTICLE_COLOR_GREEN, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_CENTAUR_TAILS = PF.PayoffUnlucky.new("Make (CURRENT_CHARGES_COINS) (UNLUCKY).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/centaur_tails_icon.png", PARTICLE_COLOR_RED, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_STYMPHALIAN_BIRDS = PF.PayoffGainArrows.new("+1(ARROW).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/monster/stymphalian_birds_icon.png", PARTICLE_COLOR_WHITE, ONLY_SHOW_ICON)

var MONSTER_POWER_FAMILY_COLCHIAN_DRAGON_GAIN_SOULS = PF.PayoffGainSouls.new("+(CURRENT_CHARGES)(SOULS).", [5, 7, 9, 11, 13, 15], PF.PowerType.PAYOFF_GAIN_SOULS, "res://assets/icons/monster/colchian_dragon_icon.png", PARTICLE_COLOR_BLUE, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_PHOENIX_HEAL = PF.PayoffGainLife.new("+(CURRENT_CHARGES)(HEAL).", [4, 5, 6, 7, 8, 9], PF.PowerType.PAYOFF_GAIN_LIFE, "res://assets/icons/soul_fragment_red_heal_icon.png", PARTICLE_COLOR_GREEN, ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_PHOENIX_IGNITE_SELF = PF.PayoffIgniteSelf.new("(IGNITE) this coin.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/phoenix_icon.png", PARTICLE_COLOR_RED, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_OREAD_LUCKY = PF.PayoffLucky.new("Make a coin (LUCKY).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/monster/oread_icon.png", PARTICLE_COLOR_GREEN, ONLY_SHOW_ICON)
const OREAD_BURY = [3, 3, 3, 3, 3, 3]
var MONSTER_POWER_FAMILY_OREAD_BURY = PF.PayoffBury.new("(BURY) a coin for (OREAD_BURY) payoffs.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/bury_icon.png", PARTICLE_COLOR_BROWN, ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_EMPUSA_TRANSFORM = PF.PayoffTransform.new("Transform a coin into a random coin of the same denomination and type.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/empusa_icon.png", PARTICLE_COLOR_WHITE, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_EMPUSA_LOSE_SOULS = PF.PayoffLoseSouls.new("-(CURRENT_CHARGES)(SOULS).", [3, 4, 5, 6, 7, 8], PF.PowerType.PAYOFF_LOSE_SOULS, "res://assets/icons/soul_fragment_blue_icon.png", PARTICLE_COLOR_BLUE, ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_HAMADYRAD_BLESS = PF.PayoffBless.new("(BLESS) (CURRENT_CHARGES_COINS).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/monster/hamadryad_icon.png", PARTICLE_COLOR_GREEN, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_HAMADYRAD_HEAL = PF.PayoffGainLife.new("+(CURRENT_CHARGES)(HEAL).", [2, 3, 4, 5, 6, 7], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/soul_fragment_red_heal_icon.png", PARTICLE_COLOR_GREEN, ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_MELIAE_CURSE = PF.PayoffCurse.new("(CURSE) (CURRENT_CHARGES_COINS).", [2, 2, 2, 2, 2, 2], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/meliae_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_SATYR_GAIN = PF.PayoffGainObol.new("Gain a random Obol.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/monster/satyr_icon.png", PARTICLE_COLOR_PURPLE, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_SATYR_BLANK = PF.PayoffBlank.new("(BLANK) (CURRENT_CHARGES_COINS).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/blank_icon.png", PARTICLE_COLOR_WHITE, ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_RELIQUARY_DECREASE_COST = PF.PayoffDecreaseCost.new("Decrease the cost to destroy this.", [4, 6, 8, 10, 13, 15], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/monster/reliquary_icon.png", PARTICLE_COLOR_BLUE, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_RELIQUARY_INCREASE_COST = PF.PayoffIncreaseCost.new("Increase the cost to destroy this.", [2, 4, 6, 8, 10, 12], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/reliquary_icon_increase.png", PARTICLE_COLOR_RED, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_AETERNAE_HEADS = PF.PayoffDestroySelf.new("WEELLDKI EJTNEM FOEEANDARXL!", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/aeternae_icon_heads.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_AETERNAE_TAILS = PF.PayoffDestroySelf.new("HWTINRTROSOPIUS OFTWSTOEHADO BONE!", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/aeternae_icon_tails.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)

# elites
var MONSTER_POWER_FAMILY_CHIMERA = PF.PayoffIgnite.new("(IGNITE) (CURRENT_CHARGES_COINS).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/chimera_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_SIREN = PF.PayoffFreezeTails.new("(FREEZE) each (TAILS) coin.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/siren_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_SIREN_CURSE = PF.PayoffCurse.new("(CURSE) (CURRENT_CHARGES_COINS).", [2, 2, 2, 3, 3, 4], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/curse_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_BASILISK = PF.PayoffHalveLife.new("Lose half your(LIFE).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/basilisk_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_GORGON = PF.PayoffStone.new("Turn (CURRENT_CHARGES_COINS) to (STONE).", [1, 1, 1, 1, 2, 2], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/gorgon_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_GORGON_UNLUCKY = PF.PayoffUnlucky.new("Make (CURRENT_CHARGES_COINS) (UNLUCKY).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/unlucky_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
const KERES_INCREASE = [3, 4, 5, 6, 7, 8]
var MONSTER_POWER_FAMILY_KERES_PENALTY = PF.PayoffIncreasePenaltyPermanently.new("Permanently increase the (LIFE) penalty of a coin by (KERES_INCREASE)(LIFE).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/keres_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_KERES_DESECRATE = PF.PayoffDesecrate.new("(DESECRATE) (CURRENT_CHARGES_COINS).", [1, 1, 1, 2, 2, 2], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/desecrate_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_TEUMESSIAN_FOX_BLANK_LESS = PF.PayoffBlank.new("(BLANK) (CURRENT_CHARGES_COINS).", [1, 1, 1, 1, 2, 2], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/blank_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_TEUMESSIAN_FOX_BLANK_MORE = PF.PayoffBlank.new("(BLANK) (CURRENT_CHARGES_COINS).", [2, 2, 3, 3, 4, 4], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/teumessian_fox_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_MANTICORE_CURSE_UNLUCKY_SELF = PF.PayoffCurseUnluckySelf.new("This coin becomes (UNLUCKY) and (CURSED).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/manticore_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_MANTICORE_DOWNGRADE = PF.PayoffDowngrade.new("Downgrade a coin (CURRENT_CHARGES_NUMERICAL_ADVERB_LOWERCASE).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/downgrade_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_FURIES_CURSE = PF.PayoffCurse.new("(CURSE) (CURRENT_CHARGES_COINS).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/furies_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_FURIES_UNLUCKY = PF.PayoffUnlucky.new("Make (CURRENT_CHARGES_COINS) (UNLUCKY).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/unlucky_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var MONSTER_POWER_FAMILY_SPHINX_DOOMED = PF.PayoffDoomRightmost.new("Make the rightmost eligible coin (DOOMED).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/sphinx_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
const SPHINX_THORNS_DENOM = [Denomination.DIOBOL, Denomination.DIOBOL, Denomination.TRIOBOL, Denomination.TRIOBOL, Denomination.TETROBOL, Denomination.TETROBOL]
var MONSTER_POWER_FAMILY_SPHINX_THORNS = PF.PayoffGainThornsSphinx.new("Gain an (SPHINX_DENOM) of Thorns.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/coin/thorns_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var MONSTER_POWER_FAMILY_CYCLOPS_DOWNGRADE = PF.PayoffDowngradeAndPrime.new("Downgrade and (PRIME) (CURRENT_CHARGES_COINS).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/cyclops_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
const CYCLOPS_BURY = [4, 4, 5, 5, 6, 6]
var MONSTER_POWER_FAMILY_CYCLOPS_BURY = PF.PayoffBury.new("(BURY) a coin for (CYCLOPS_BURY) payoffs.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/monster/bury_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)

# medusa
var NEMESIS_POWER_FAMILY_MEDUSA_STONE = PF.PayoffStone.new("Turn (CURRENT_CHARGES_COINS) to (STONE).", [1, 1, 1, 1, 2, 2], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/medusa_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE = PF.PayoffDowngradeMostValuable.new("(CURRENT_CHARGES_NUMERICAL_ADVERB), downgrade the most valuable coin.", [2, 2, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/downgrade_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_EURYALE_STONE = PF.PayoffStone.new("Turn (CURRENT_CHARGES_COINS) to (STONE).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/euryale_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY = PF.PayoffUnlucky.new("Make (CURRENT_CHARGES_COINS) (UNLUCKY).", [2, 2, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/unlucky_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_STHENO_STONE = PF.PayoffStone.new("Turn (CURRENT_CHARGES) to (STONE)", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/stheno_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_STHENO_CURSE = PF.PayoffCurse.new("(CURSE) (CURRENT_CHARGES_COINS).", [2, 2, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/curse_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)

# echidna & typhon
const ECHIDNA_SPAWN_DENOM = [Denomination.OBOL, Denomination.OBOL, Denomination.DIOBOL, Denomination.DIOBOL, Denomination.TRIOBOL, Denomination.TRIOBOL]
var NEMESIS_POWER_FAMILY_ECHIDNA_SPAWN_STRONG = PF.PayoffSpawnStrong.new("Birth a monster (ECHIDNA_SPAWN_DENOM).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/echidna_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_ECHIDNA_SPAWN_FLEETING = PF.PayoffSpawnFleeting.new("Birth (CURRENT_CHARGES) monster Obols with (FLEETING).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/echidna_eggs_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_TYPHON_UPGRADE_MONSTERS = PF.PayoffUpgradeMonsters.new("Upgrade all monsters (except Echidna and Typhon).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/typhon_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_TYPHON_BLESS_MONSTERS = PF.PayoffBlessMonsters.new("(BLESS) all monsters.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/bless_monster_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_TYPHON_ENRAGED = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE)", [5, 7, 8, 10, 12, 15], PF.PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)

# scylla & charybdis
var NEMESIS_POWER_FAMILY_SCYLLA_SHUFFLE = PF.PayoffShuffle.new("Shuffle the position of each of your coins. Reset this coin's (LIFE) penalty.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/scylla_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
const SCYLLA_INCREASE = [1, 2, 3, 4, 5, 6]
var NEMESIS_POWER_FAMILY_SCYLLA_DAMAGE = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE). Increase this penalty by (SCYLLA_INCREASE)(LIFE) permanently.", [4, 4, 4, 4, 4, 4], PF.PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_CHARYBDIS_LEFT = PF.PayoffBlankLeftHalf.new("(BLANK) the left half of your coins.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/charbydis_left_icon.png", PARTICLE_COLOR_WHITE, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_CHARYBDIS_RIGHT = PF.PayoffBlankRightHalf.new("(BLANK) the right half of your coins.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/charbydis_right_icon.png", PARTICLE_COLOR_WHITE, ONLY_SHOW_ICON)

# cerberus
var NEMESIS_POWER_FAMILY_CERBERUS_LEFT_IGNITE_SELF = PF.PayoffPermanentlyIgniteMonster.new("Permanently (IGNITE) (CURRENT_CHARGES) of Cerberus's heads.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/cerberus_left_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_CERBERUS_LEFT_IGNITE = PF.PayoffIgnite.new("(IGNITE) (CURRENT_CHARGES_COINS).", [1, 1, 2, 2, 3, 3], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/ignite_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
const CERBERUS_INCREASE_IGNITE = [1, 1, 2, 2, 3, 3]
var NEMESIS_POWER_FAMILY_CERBERUS_MIDDLE_EMPOWER_IGNITE = PF.PayoffAmplifyIgnite.new("Increase (IGNITE) damage by (CERBERUS_INCREASE_IGNITE) this round.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/cerberus_middle_ignite_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
const CERBERUS_INCREASE = [1, 2, 2, 3, 3, 4]
var NEMESIS_POWER_FAMILY_CERBERUS_MIDDLE_EMPOWER_PENALTY = PF.PayoffIncreaseAllPenaltyPermanently.new("Permanently increase the (LIFE) penalty of all coins by (CERBERUS_INCREASE)(LIFE).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/cerberus_middle_penalty_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_CERBERUS_RIGHT_DESECRATE = PF.PayoffDesecrate.new("(DESECRATE) your cheapest coin. [color=gray](It will always lands on (TAILS).)[/color]", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER,  "res://assets/icons/nemesis/cerberus_right_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_CERBERUS_RIGHT_DAMAGE = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE).", [5, 6, 8, 10, 12, 13], PF.PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)

# minotaur
var NEMESIS_POWER_FAMILY_MINOTAUR_SCALING_CURSE_UNLUCKY = PF.PayoffCurseUnluckyScaling.new("A coin becomes (CURSED) or (UNLUCKY). Double this face's charges.", [1, 1, 1, 1, 2, 2], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/minotaur_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_MINOTAUR_SCALING_DAMAGE = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE). Double this (LIFE) penalty.", [1, 2, 3, 4, 5, 6], PF.PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_RED, ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_LOST_IN_THE_LABYRINTH = PF.PowerFamily.new("When a Labyrinth Wall is destroyed, spawn a new one. Destroy (CURRENT_CHARGES) more to escape!", [12, 13, 14, 15, 17, 21], PF.PowerType.PASSIVE, "res://assets/icons/nemesis/lost_in_the_labyrinth_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_LABYRINTH_WALL1_ESCAPE = PF.PayoffAWayOut.new("You walk towards the light. Destroy this coin.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/nemesis/a_way_out_unlucky_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_LABYRINTH_WALL2_ESCAPE = PF.PayoffAWayOut.new("You walk towards the light. Destroy this coin.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/nemesis/a_way_out_frozen_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_LABYRINTH_WALL3_ESCAPE = PF.PayoffAWayOut.new("You walk towards the light. Destroy this coin.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/nemesis/a_way_out_muddy_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_LABYRINTH_WALL4_ESCAPE = PF.PayoffAWayOut.new("You walk towards the light. Destroy this coin.", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_SOMETHING_POSITIVE, "res://assets/icons/nemesis/a_way_out_damage_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON)
var NEMESIS_POWER_FAMILY_LABYRINTH_WALL_UNLUCKY = PF.PayoffUnluckySelf.new("This coin becomes (UNLUCKY)", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/unlucky_self_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_LABYRINTH_WALL_FREEZE = PF.PayoffFreezeSelf.new("This coin becomes (FROZEN).", [1, 1, 1, 1, 1, 1], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/freeze_self_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_LABYRINTH_WALL_BURY = PF.PayoffBurySelf.new("(BURY) this coin for (CURRENT_CHARGES_PAYOFFS).", [1, 1, 1, 1, 2, 2], PF.PowerType.PAYOFF_MONSTER, "res://assets/icons/nemesis/bury_self_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)
var NEMESIS_POWER_FAMILY_LABYRINTH_WALL_DAMAGE = PF.PayoffLoseLife.new("-(CURRENT_CHARGES)(LIFE).", [5, 7, 8, 10, 12, 15], PF.PowerType.PAYOFF_LOSE_LIFE, "res://assets/icons/soul_fragment_red_icon.png", PARTICLE_COLOR_BLACK, ICON_AND_CHARGES)

var TRIAL_POWER_FAMILY_IRON = PF.PowerFamily.new("When the trial begins, you gain 2 Obols of Thorns. (If there isn't enough space, destroy the rightmost coin until there is.)", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/iron_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
const MISFORTUNE_QUANTITY = 2
var TRIAL_POWER_FAMILY_MISFORTUNE = PF.PowerFamily.new("After each payoff, two of your coins become (UNLUCKY).", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/misfortune_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_PAIN = PF.PowerFamily.new("Damage you take from (LIFE) penalties is tripled.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/pain_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
const BLOOD_COST = 1
var TRIAL_POWER_FAMILY_BLOOD = PF.PowerFamily.new("Using a power costs %d(LIFE)." % BLOOD_COST, [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/blood_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_EQUIVALENCE = PF.PowerFamily.new("After a coin lands on (HEADS), it becomes (UNLUCKY). After a coin lands on (TAILS), it becomes (LUCKY).", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/equivalence_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_TORMENT = PF.PowerFamily.new("You cannot use the same (POWER) twice in a row.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/torment_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_MALAISE = PF.PowerFamily.new("When you use a power, all your coins lose a charge.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/malaise_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_VIVISEPULTURE = PF.PowerFamily.new("When the trial begins, your two leftmost coins are (BURIED) for 20 payoffs.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/vivisepulture_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_IMMOLATION = PF.PowerFamily.new("After you use a coin's power, that coin (IGNITES).", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/immolation_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_VENGEANCE = PF.PowerFamily.new("After payoff, (CURSE) your highest value (HEADS) coin.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/vengeance_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)

var TRIAL_POWER_FAMILY_FAMINE = PF.PowerFamily.new("You do not replenish (HEAL) at the start of the round.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/famine_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_TORTURE = PF.PowerFamily.new("After payoff, your highest value (HEADS) coin is downgraded.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/torture_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_LIMITATION = PF.PowerFamily.new("Payoffs less than 10(SOULS) become 0.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/limitation_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_COLLAPSE = PF.PowerFamily.new("After payoff, (DESECRATE) each coin on (TAILS).", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/collapse_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_SAPPING = PF.PowerFamily.new("Coins replenish only a single power charge each toss.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/sapping_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_OVERLOAD = PF.PowerFamily.new("After payoff, you lose 1(LIFE) for each unspent power charge on a (HEADS) coin.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/overload_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_PETRIFICATION = PF.PowerFamily.new("When the trial begins, all power coins are turned to (STONE).", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/petrification_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_SILENCE = PF.PowerFamily.new("After each payoff, (BURY) the leftmost possible coin for 10 payoffs.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/silence_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_POLARIZATION = PF.PowerFamily.new("Payoff coins land on (TAILS) +40% more often.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/polarization_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_SINGULARITY = PF.PowerFamily.new("Power coins have only a single charge.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/singularity_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_GATING = PF.PowerFamily.new("Payoffs greater than 10(SOULS) become 1(SOULS).", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/gating_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_FATE = PF.PowerFamily.new("Coins cannot be reflipped.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/fate_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_ADVERSITY = PF.PowerFamily.new("When the trial begins, spawn 3 powerful monsters.", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/adversity_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var TRIAL_POWER_FAMILY_VAINGLORY = PF.PowerFamily.new("After a coin lands on (HEADS), it becomes (CURSED).", [0, 0, 0, 0, 0, 0], PF.PowerType.PASSIVE, "res://assets/icons/trial/vainglory_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)

var CHARON_POWER_DEATH = PF.PowerFamily.new("(CHARON_DEATH) Die.", [0, 0, 0, 0, 0, 0], PF.PowerType.CHARON, "res://assets/icons/coin/charon_death_icon.png", PARTICLE_COLOR_BLACK, ONLY_SHOW_ICON)
var CHARON_POWER_LIFE = PF.PowerFamily.new("(CHARON_LIFE) Live. The round ends.", [0, 0, 0, 0, 0, 0], PF.PowerType.CHARON, "res://assets/icons/coin/charon_life_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON)

const _IGNITE_COLOR = "red"
const _FREEZE_COLOR = "aqua"
const _LUCKY_COLOR = "lawngreen"
const _UNLUCKY_COLOR = "orangered"
const _BLESS_COLOR = "palegoldenrod"
const _CURSE_COLOR = "mediumorchid"
const _BLANK_COLOR = "ghostwhite"
const _CHARGE_COLOR = "yellow"
const _STONE_COLOR = "slategray"
const _DOOMED_COLOR = "lightsteelblue"
const _CONSECRATE_COLOR = "lightyellow"
const _DESECRATE_COLOR = "fuchsia"
const _BURY_COLOR = "peru"
const _FLEETING_COLOR = "ghostwhite"
const _PRIME_COLOR = "orange"

const STATUS_FORMAT = "[color=%s]%s[/color][img=10x13]%s[/img]"

# handle some outside since they are used by multiple replacements
const _REPLACE_HEADS = "[img=12x13]res://assets/icons/heads_icon.png[/img]"
const _REPLACE_TAILS = "[img=12x13]res://assets/icons/tails_icon.png[/img]"
const _REPLACE_LIFE = "[img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img]"
var _REPLACE_MAP = {
	"(IGNITE)" : STATUS_FORMAT % [_IGNITE_COLOR, "Ignite", "res://assets/icons/status/ignite_icon.png"],
	"(IGNITED)" : STATUS_FORMAT % [_IGNITE_COLOR, "Ignited", "res://assets/icons/status/ignite_icon.png"],
	"(IGNITES)" : STATUS_FORMAT % [_IGNITE_COLOR, "Ignites", "res://assets/icons/status/ignite_icon.png"], 
	"(FREEZE)" : STATUS_FORMAT % [_FREEZE_COLOR, "Freeze", "res://assets/icons/status/freeze_icon.png"],
	"(FROZEN)" : STATUS_FORMAT % [_FREEZE_COLOR, "Frozen", "res://assets/icons/status/freeze_icon.png"],
	"(LUCKY)" : STATUS_FORMAT % [_LUCKY_COLOR, "Lucky", "res://assets/icons/status/lucky_icon.png"],
	
	"(UNLUCKY)" : STATUS_FORMAT % [_UNLUCKY_COLOR, "Unlucky", "res://assets/icons/status/unlucky_icon.png"],
	"(BLESS)" : STATUS_FORMAT % [_BLESS_COLOR, "Bless", "res://assets/icons/status/bless_icon.png"],
	"(BLESSED)" : STATUS_FORMAT % [_BLESS_COLOR, "Blessed", "res://assets/icons/status/bless_icon.png"],
	"(CURSE)" : STATUS_FORMAT % [_CURSE_COLOR, "Curse", "res://assets/icons/status/curse_icon.png"],
	"(CURSED)" : STATUS_FORMAT % [_CURSE_COLOR, "Cursed", "res://assets/icons/status/curse_icon.png"],
	"(BLANK)" : STATUS_FORMAT % [_BLANK_COLOR, "Blank", "res://assets/icons/status/blank_icon.png"],
	"(CHARGE)" : STATUS_FORMAT % [_CHARGE_COLOR, "Charge", "res://assets/icons/status/charge_icon.png"],
	"(SUPERCHARGE)" : STATUS_FORMAT % [_CHARGE_COLOR, "Supercharge", "res://assets/icons/status/supercharge_icon.png"],
	"(STONE)" : STATUS_FORMAT % [_STONE_COLOR, "Stone", "res://assets/icons/status/stone_icon.png"],
	"(DOOMED)" : STATUS_FORMAT % [_DOOMED_COLOR, "Doomed", "res://assets/icons/status/doomed_icon.png"],
	"(DOOM)" : STATUS_FORMAT % [_DOOMED_COLOR, "Doom", "res://assets/icons/status/doomed_icon.png"],
	"(CONSECRATE)" : STATUS_FORMAT % [_CONSECRATE_COLOR, "Consecrate", "res://assets/icons/status/consecrate_icon.png"],
	"(DESECRATE)" : STATUS_FORMAT % [_DESECRATE_COLOR, "Desecrate", "res://assets/icons/status/desecrate_icon.png"],
	"(BURY)" : STATUS_FORMAT % [_BURY_COLOR, "Bury", "res://assets/icons/status/bury_icon.png"],
	"(BURIED)" : STATUS_FORMAT % [_BURY_COLOR, "Buried", "res://assets/icons/status/bury_icon.png"],
	"(FLEETING)" : STATUS_FORMAT % [_FLEETING_COLOR, "Fleeting", "res://assets/icons/status/fleeting_icon.png"],
	"(PRIME)" : STATUS_FORMAT % [_PRIME_COLOR, "Prime", "res://assets/icons/status/primed_icon.png"],
	
	"(S_IGNITED)" : STATUS_FORMAT % [_IGNITE_COLOR, "Ignited", "res://assets/icons/status/ignite_icon.png"],
	"(D_IGNITED)" : "Each payoff, -3%s." % _REPLACE_LIFE,
	"(S_FROZEN)" : STATUS_FORMAT % [_FREEZE_COLOR, "Frozen", "res://assets/icons/status/freeze_icon.png"],
	"(D_FROZEN)" : "The next time this would be flipped, it thaws out instead. Does not recharge.",
	"(S_LUCKY)" : STATUS_FORMAT % [_LUCKY_COLOR, "Lucky", "res://assets/icons/status/lucky_icon.png"],
	"(D_LUCKY)" : "+%d%% chance to land on %s." % [Coin.LUCKY_MODIFIER, _REPLACE_HEADS],
	"(S_SLIGHTLY_LUCKY)" : STATUS_FORMAT % [_LUCKY_COLOR, "Slightly Lucky", "res://assets/icons/status/slightly_lucky_icon.png"],
	"(D_SLIGHTLY_LUCKY)" : "+%d%% chance to land on %s. Stacks." % [Coin.SLIGHTLY_LUCKY_MODIFIER, _REPLACE_HEADS],
	"(S_QUITE_LUCKY)" : STATUS_FORMAT % [_LUCKY_COLOR, "Quite Lucky", "res://assets/icons/status/quite_lucky_icon.png"],
	"(D_QUITE_LUCKY)" : "+%d%% chance to land on %s. Stacks." % [Coin.QUITE_LUCKY_MODIFIER, _REPLACE_HEADS],
	"(S_INCREDIBLY_LUCKY)" : STATUS_FORMAT % [_LUCKY_COLOR, "Incredibly Lucky", "res://assets/icons/status/incredibly_lucky_icon.png"],
	"(D_INCREDIBLY_LUCKY)" : "+%d%% chance to land on %s." % [Coin.INCREDIBLY_LUCKY_MODIFIER, _REPLACE_HEADS],
	"(S_UNLUCKY)" : STATUS_FORMAT % [_UNLUCKY_COLOR, "Unlucky", "res://assets/icons/status/unlucky_icon.png"],
	"(D_UNLUCKY)" : "+%d%% chance to land on %s." % [Coin.LUCKY_MODIFIER, _REPLACE_TAILS],
	"(S_BLESSED)" : STATUS_FORMAT % [_BLESS_COLOR, "Blessed", "res://assets/icons/status/bless_icon.png"],
	"(D_BLESSED)" : "The next time this is flipped, it will land on %s." % _REPLACE_HEADS,
	"(S_CURSED)" : STATUS_FORMAT % [_CURSE_COLOR, "Cursed", "res://assets/icons/status/curse_icon.png"],
	"(D_CURSED)" : "The next time this is flipped, it will land on %s." % _REPLACE_TAILS,
	"(S_BLANKED)" : STATUS_FORMAT % [_BLANK_COLOR, "Blanked", "res://assets/icons/status/blank_icon.png"],
	"(D_BLANKED)" : "Until the end of a toss, this has no effects.",
	"(S_CHARGED)" : STATUS_FORMAT % [_CHARGE_COLOR, "Charged", "res://assets/icons/status/charge_icon.png"],
	"(D_CHARGED)" : "The next time this lands on %s, reflip it. Stacks." % _REPLACE_TAILS,
	"(S_SUPERCHARGED)" : STATUS_FORMAT % [_CHARGE_COLOR, "Supercharged", "res://assets/icons/status/supercharge_icon.png"],
	"(D_SUPERCHARGED)" : "The next two times this lands on %s, reflip it." % _REPLACE_TAILS,
	"(S_TURNED_TO_STONE)" : STATUS_FORMAT % [_STONE_COLOR, "Turned to Stone", "res://assets/icons/status/stone_icon.png"],
	"(D_TURNED_TO_STONE)" : "Cannot be flipped, does not pay off, and does not recharge.",
	"(S_CONSECRATED)" : STATUS_FORMAT % [_CONSECRATE_COLOR, "Consecrated", "res://assets/icons/status/consecrate_icon.png"],
	"(D_CONSECRATED)" : "Always lands on %s." % _REPLACE_HEADS,
	"(S_DESECRATED)" : STATUS_FORMAT % [_DESECRATE_COLOR, "Desecrated", "res://assets/icons/status/desecrate_icon.png"],
	"(D_DESECRATED)" : "Always lands on %s." % _REPLACE_TAILS,
	"(S_DOOMED)" : STATUS_FORMAT % [_DOOMED_COLOR, "Doomed", "res://assets/icons/status/doomed_icon.png"],
	"(D_DOOMED)" : "Destroyed when the round ends.",
	"(S_BURIED)" : STATUS_FORMAT % [_BURY_COLOR, "Buried", "res://assets/icons/status/bury_icon.png"],
	"(D_BURIED)" : "Cannot be interacted with, does not pay off, and does not recharge.\nAutomatically exhumed in a certain number of tosses.",
	"(S_FLEETING)" : STATUS_FORMAT % [_FLEETING_COLOR, "Fleeting", "res://assets/icons/status/fleeting_icon.png"],
	"(D_FLEETING)" : "Destroyed during payoff.",
	"(S_PRIMED)" : STATUS_FORMAT % [_PRIME_COLOR, "Primed", "res://assets/icons/status/primed_icon.png"],
	"(D_PRIMED)" : "At the end of the round, automatically upgrades.",
	
	"(HEADS)" : _REPLACE_HEADS,
	"(TAILS)" : _REPLACE_TAILS,
	"(COIN)" : "[img=12x13]res://assets/icons/coin_icon.png[/img]",
	"(VALUE)" : "[img=12x13]res://assets/icons/value_icon.png[/img]",
	"(ARROW)" : "[img=10x13]res://assets/icons/arrow_icon.png[/img]",
	"(LIFE)" : _REPLACE_LIFE,
	"(HEAL)" : "[img=10x13]res://assets/icons/soul_fragment_red_heal_icon.png[/img]",
	"(SOULS)" : "[img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]",
	"(LUCKYICON)" : "[img=10x13]res://assets/icons/status/lucky_icon.png[/img]",
	
	"(CHARON_DEATH)" : "[img=10x13]res://assets/icons/coin/charon_death_icon.png[/img]",
	"(CHARON_LIFE)" : "[img=10x13]res://assets/icons/coin/charon_life_icon.png[/img]",
	
	"(POWERARROW)" : "[img=12x13]res://assets/icons/ui/white_arrow.png[/img]",
	"(PASSIVE)" : "[img=36x13]res://assets/icons/ui/passive.png[/img]",
	"(PAYOFF_SOULS)" : "[img=32x13]res://assets/icons/ui/payoff_souls.png[/img]",
	"(PAYOFF_LIFE)" : "[img=32x13]res://assets/icons/ui/payoff_life.png[/img]",
	"(PAYOFF_FLAME)" : "[img=32x13]res://assets/icons/ui/payoff_flame.png[/img]",
	"(PAYOFF_OTHER)" : "[img=32x13]res://assets/icons/ui/payoff_other.png[/img]",
	"(PAYOFF_PURPLE)" : "[img=32x13]res://assets/icons/ui/payoff_purple.png[/img]",
	"(POWER)" : "[img=30x13]res://assets/icons/ui/power.png[/img]",
	"(POWER_PATRON)" : "[img=30x13]res://assets/icons/ui/power_patron.png[/img]",
	
	"(TODO)" : "[img=10x13]res://assets/icons/todo_icon.png[/img]",
}

func fast_placeholder_replace(s: String, paren_map: Dictionary) -> String:
	var returned = PackedStringArray()
	var active_placeholder = PackedStringArray()
	
	for c in s:
		if active_placeholder.is_empty():
			# start a new paren
			if c == "(":
				active_placeholder.append(c)
			# extend the string
			else:
				returned.append(c)
		else:
			if c == "(": # starting a new paren while we already have one
				# discard the active paren and add existing to str
				returned.append("".join(active_placeholder))
				active_placeholder.clear()
			
			active_placeholder.append(c)
			
			if c == ")": # closing paren
				var joined = "".join(active_placeholder)
				# if this can be replaced, replace it
				if paren_map.has(joined):
					returned.append(paren_map[joined])
				# this wasn't a match, just hint text. So insert it directly.
				else:
					returned.append(joined)
				active_placeholder.clear() # either way, this is the end of a paren
	
	# add any remaining active_placeholder...  only happens if we don't close a paren lol
	returned.append("".join(active_placeholder))
	
	return "".join(returned)

func replace_placeholders(tooltip: String) -> String:
	# update these two dynamic replacement in the map
	_REPLACE_MAP["(FLAME_INCREASE)"] = str("%.1d" % Global.flame_boost)
	_REPLACE_MAP["(IGNITE_INCREASE)"] = str(Global.ignite_damage - Global.DEFAULT_IGNITE_DAMAGE)
	
	return fast_placeholder_replace(tooltip, _REPLACE_MAP)

var _SUBTOOLTIP_MAP = {
	"(LUCKY)" : "(S_LUCKY)\n(D_LUCKY)",
	"(UNLUCKY)" : "(S_UNLUCKY)\n(D_UNLUCKY)",
	"(IGNITE)" : "(S_IGNITED)\n(D_IGNITED)",
	"(IGNITED)" : "(S_IGNITED)\n(D_LUCKY)",
	"(IGNITES)" : "(S_IGNITED)\n(D_LUCKY)",
	"(FREEZE)" : "(S_FROZEN)\n(D_FROZEN)",
	"(FROZEN)" : "(S_FROZEN)\n(D_FROZEN)",
	"(BLESS)" : "(S_BLESSED)\n(D_BLESSED)",
	"(BLESSED)" : "(S_BLESSED)\n(D_BLESSED)",
	"(CURSE)" : "(S_CURSED)\n(D_CURSED)",
	"(CURSED)" : "(S_CURSED)\n(D_CURSED)",
	"(BLANK)" : "(S_BLANKED)\n(D_BLANKED)",
	"(CHARGE)" : "(S_CHARGED)\n(D_CHARGED)",
	"(SUPERCHARGE)" : "(S_SUPERCHARGED)\n(D_SUPERCHARGED)",
	"(STONE)" : "(S_TURNED_TO_STONE)\n(D_TURNED_TO_STONE)",
	"(DOOMED)" : "(S_DOOMED)\n(D_DOOMED)",
	"(DOOM)" : "(S_DOOMED)\n(D_DOOMED)",
	"(CONSECRATE)" : "(S_CONSECRATED)\n(D_CONSECRATED)",
	"(DESECRATE)" : "(S_DESECRATED)\n(D_DESECRATED)",
	"(BURY)" : "(S_BURIED)\n(D_BURIED)",
	"(BURIED)" : "(S_BURIED)\n(D_BURIED)",
	"(FLEETING)" : "(S_FLEETING)\n(D_FLEETING)",
	"(PRIME)" : "(S_PRIMED)\n(D_PRIMED)",
}
var _CACHED_SUBTOOLTIPS = {}
func add_subtooltips_for(tooltip: String, props: UITooltip.Properties) -> UITooltip.Properties:
	for key in _SUBTOOLTIP_MAP.keys():
		if tooltip.contains(key):
			if not _CACHED_SUBTOOLTIPS.has(key):
				_SUBTOOLTIP_MAP[key] = Global.replace_placeholders(Global.replace_placeholders(_SUBTOOLTIP_MAP[key]))
				_CACHED_SUBTOOLTIPS[key] = true
			props.sub(_SUBTOOLTIP_MAP[key], UITooltip.Direction.BELOW)
	
	return props

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
	if DEBUG_CONSOLE and Input.is_key_pressed(KEY_SPACE):
		breakpoint
	if DEBUG_CONSOLE and Input.is_key_pressed(_SCREENSHOT_KEY):
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
	
	info_view_active = Input.is_physical_key_pressed(KEY_CTRL)

@onready var CALLABLE_NOOP = Callable(self, "noop")
func noop(opt = null, opt2 = null, opt3 = null, opt4 = null, opt5 = null, opt6 = null, opt7 = null, opt8 = null) -> void:
	pass

# Randomly return one element of the array
func choose_one(arr: Array):
	if arr.size() == 0:
		return null
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

func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)

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

# returns a uniformly random point in the circle generated from center with radius.
# if force_integer, the point will have integer coordinates.
func get_random_point_in_circle(center: Vector2, radius: float, force_integer: bool = false) -> Vector2:
	var point = Vector2.ZERO
	
	while true:
		var angle = randf_range(0.0, TAU)
		var r = radius * sqrt(randf())
		point = center + Vector2(r * cos(angle), r * sin(angle))

		if not force_integer:
			break

		point = point.round()
		if point.distance_to(center) <= radius:
			break
	
	return point

# Returns a uniformly random point within an ellipse defined by 'center' and 'radii' (x = horizontal, y = vertical).
# If 'force_integer' is true, the point will be rounded to integer coordinates while staying within the ellipse.
func get_random_point_in_ellipse(center: Vector2, radii: Vector2, force_integer: bool = false) -> Vector2:
	var point = Vector2.ZERO

	while true:
		var angle = randf_range(0.0, TAU)
		var r = sqrt(randf())  # unit radius for uniform sampling
		point = Vector2(
			r * radii.x * cos(angle),
			r * radii.y * sin(angle)
		) + center

		if not force_integer:
			break

		point = point.round()
		
		# Check if the integer-rounded point is still within the ellipse
		var rel = point - center
		var ellipse_check = pow(rel.x / radii.x, 2) + pow(rel.y / radii.y, 2)
		if ellipse_check <= 1.0:
			break
	
	return point

func get_random_point_in_rectangle(center: Vector2, size: Vector2, force_integer: bool = false) -> Vector2:
	var half_size = size * 0.5
	var point = Vector2(
		randf_range(center.x - half_size.x, center.x + half_size.x),
		randf_range(center.y - half_size.y, center.y + half_size.y)
	)
	
	if force_integer:
		point = point.round()
		
	return point

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
func create_timer(key: String, wait_time: float, one_shot: bool = false) -> Timer:
	if _timers.has(key):
		_timers[key].wait_time = wait_time
		_timers[key].one_shot = one_shot
		_timers[key].start()
		return _timers[key]
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = one_shot
	_timers[key] = timer
	add_child(timer)
	_timers[key].start()
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
	var power_family: PF.PowerFamily
	var patron_statue: PackedScene
	var patron_token: PackedScene
	var _starting_coinpool: Array
	
	func _init(name: String, token: String, power_desc: String, ptrn_enum: PatronEnum, pwr_fmly: PF.PowerFamily, statue: PackedScene, tkn: PackedScene, start_cpl: Array) -> void:
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
		return "(POWER_PATRON)[color=yellow]%d/%d[/color][img=10x13]%s[/img](POWERARROW)%s" % [n_charges, get_uses_per_round(), power_family.icon_path, _description]
	
	func get_uses_per_round() -> int:
		return power_family.get_uses_for_denom(Global.Denomination.OBOL)
	
	func get_random_starting_coin_family() -> CoinFamily:
		return Global.choose_one(_starting_coinpool)
	
	func get_icon_path() -> String:
		return power_family.icon_path

# placeholder powers... kinda a $HACK$
var PATRON_POWER_FAMILY_APHRODITE = PF.PatronAphrodite.new("Aphrodite", [2, 2, 2, 2, 2, 2], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/patron/aphrodite_patron_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_APOLLO = PF.PatronApollo.new("Apollo", [3, 3, 3, 3, 3, 3], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/patron/apollo_patron_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_ARES = PF.ReflipAll.new("Ares", [2, 2, 2, 2, 2, 2], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/coin/ares_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_ARTEMIS = PF.PatronArtemis.new("Artemis", [2, 2, 2, 2, 2, 2], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/patron/artemis_patron_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_ATHENA = PF.PatronAthena.new("Athena", [2, 2, 2, 2, 2, 2], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/patron/athena_patron_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_DEMETER = PF.PatronDemeter.new("Demeter", [1, 1, 1, 1, 1, 1], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/patron/demeter_patron_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_DIONYSUS = PF.PatronDionysus.new("Dionysus", [2, 2, 2, 2, 2, 2], PF.PowerType.POWER_NON_TARGETTING, "res://assets/icons/patron/dionysus_patron_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_HADES = PF.PatronHades.new("Hades", [1, 1, 1, 1, 1, 1], PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/patron/hades_patron_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_HEPHAESTUS = PF.PatronHephaestus.new("Hephaestus", [1, 1, 1, 1, 1, 1], PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/patron/hephaestus_patron_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_HERA = PF.ReflipAndNeighbors.new("Hera", [2, 2, 2, 2, 2, 2], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/hera_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_HERMES = PF.Exchange.new("Hermes", [2, 2, 2, 2, 2, 2], PF.PowerType.POWER_TARGETTING_PLAYER_COIN, "res://assets/icons/coin/hermes_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_HESTIA = PF.MakeLucky.new("Hestia", [3, 3, 3, 3, 3, 3], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/hestia_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_POSEIDON = PF.Freeze.new("Poseidon", [3, 3, 3, 3, 3, 3], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/poseidon_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);
var PATRON_POWER_FAMILY_ZEUS = PF.Reflip.new("Zeus", [3, 3, 3, 3, 3, 3], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/zeus_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);

var PATRON_POWER_FAMILY_CHARON = PF.PatronCharon.new("Charon", [3, 3, 3, 3, 3, 3], PF.PowerType.POWER_TARGETTING_ANY_COIN, "res://assets/icons/coin/charon_life_icon.png", PARTICLE_COLOR_YELLOW, ONLY_SHOW_ICON);

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
	Patron.new("[color=purple]Artemis[/color]", "[color=purple]Artemis's Bow[/color]", "Turn all coins to their other face.\n(PASSIVE)When a monster is destroyed, +2(ARROW).", PatronEnum.ARTEMIS, PATRON_POWER_FAMILY_ARTEMIS, preload("res://components/patron_statues/artemis.tscn"), preload("res://components/patron_tokens/artemis.tscn"), [ARTEMIS_FAMILY]),
	Patron.new("[color=cyan]Athena[/color]", "[color=cyan]Athena's Aegis[/color]", "Permanently reduce a coin's (LIFE) penalty by 2(LIFE).\n(PASSIVE)You can see what face each coin will land on when flipped.", PatronEnum.ATHENA, PATRON_POWER_FAMILY_ATHENA, preload("res://components/patron_statues/athena.tscn"), preload("res://components/patron_tokens/athena.tscn"), [ATHENA_FAMILY]),
	Patron.new("[color=lightgreen]Demeter[/color]", "[color=lightgreen]Demeter's Wheat[/color]", "For each coin showing a (LIFE) penalty, +(HEAL) equal to its (LIFE) penalty.\n(PASSIVE)Whenever you heal (HEAL), also gain that many (SOULS).", PatronEnum.DEMETER, PATRON_POWER_FAMILY_DEMETER, preload("res://components/patron_statues/demeter.tscn"), preload("res://components/patron_tokens/demeter.tscn"), [DEMETER_FAMILY]),
	Patron.new("[color=plum]Dionysus[/color]", "[color=plum]Dionysus's Chalice[/color]", "???\n(PASSIVE)When you gain a new coin, make it (LUCKY).", PatronEnum.DIONYSUS, PATRON_POWER_FAMILY_DIONYSUS, preload("res://components/patron_statues/dionysus.tscn"), preload("res://components/patron_tokens/dionysus.tscn"), [DIONYSUS_FAMILY]),
	Patron.new("[color=slateblue]Hades[/color]", "[color=slateblue]Hades's Bident[/color]", "Destroy one of your coins. Gain (SOULS) and heal (LIFE) equal to %dx its value(VALUE).\n(PASSIVE)Souls persist between rounds [color=gray](except before a Nemesis)[/color]." % HADES_PATRON_MULTIPLIER, PatronEnum.HADES, PATRON_POWER_FAMILY_HADES, preload("res://components/patron_statues/hades.tscn"), preload("res://components/patron_tokens/hades.tscn"), [HADES_FAMILY]),
	Patron.new("[color=sienna]Hephaestus[/color]", "[color=sienna]Hephaestus's Hammer[/color]", "Upgrade a coin and fully recharge it.\n(PASSIVE)Coins may be upgraded beyond Tetrobol [color=gray](to Pentobol and Drachma)[/color].", PatronEnum.HEPHAESTUS, PATRON_POWER_FAMILY_HEPHAESTUS, preload("res://components/patron_statues/hephaestus.tscn"), preload("res://components/patron_tokens/hephaestus.tscn"), [HEPHAESTUS_FAMILY]),
	Patron.new("[color=silver]Hera[/color]", "[color=silver]Hera's Lotus[/color]", "Reflip a coin and its neighbors.\n(PASSIVE)When you reflip a coin, it always lands on the other side.", PatronEnum.HERA, PATRON_POWER_FAMILY_HERA, preload("res://components/patron_statues/hera.tscn"), preload("res://components/patron_tokens/hera.tscn"), [HERA_FAMILY]),
	Patron.new("[color=lightskyblue]Hermes[/color]", "[color=lightskyblue]Hermes's Caduceus[/color]", "Trade a coin for another of equal value.\n(PASSIVE)When you obtain a new coin during a round, it has a 20% chance to upgrade.", PatronEnum.HERMES, PATRON_POWER_FAMILY_HERMES, preload("res://components/patron_statues/hermes.tscn"), preload("res://components/patron_tokens/hermes.tscn"), [HERMES_FAMILY]),
	Patron.new("[color=sandybrown]Hestia[/color]", "[color=sandybrown]Hestia's Warmth[/color]", "Make a coin\n(LUCKY).\n(PASSIVE)(LUCKY) may be applied up to 3 times to the same coin.", PatronEnum.HESTIA, PATRON_POWER_FAMILY_HESTIA, preload("res://components/patron_statues/hestia.tscn"), preload("res://components/patron_tokens/hestia.tscn"), [HESTIA_FAMILY]),
	Patron.new("[color=lightblue]Poseidon[/color]", "[color=lightblue]Poseidon's Trident[/color]", "(FREEZE) a coin.\n(PASSIVE)When you (FREEZE) a monster coin, also (BLANK) it.", PatronEnum.POSEIDON, PATRON_POWER_FAMILY_POSEIDON, preload("res://components/patron_statues/poseidon.tscn"), preload("res://components/patron_tokens/poseidon.tscn"), [POSEIDON_FAMILY]),
	Patron.new("[color=yellow]Zeus[/color]", "[color=yellow]Zeus's Thunderbolt[/color]", "Reflip a coin.\n(PASSIVE)When you use a power on a coin, (CHARGE) it.", PatronEnum.ZEUS, PATRON_POWER_FAMILY_ZEUS, preload("res://components/patron_statues/zeus.tscn"), preload("res://components/patron_tokens/zeus.tscn"), [ZEUS_FAMILY]),
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

func is_patron_power(power_family: PF.PowerFamily) -> bool:
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
	PAYOFF, POWER, PASSIVE, NEMESIS, THORNS, CHARONS, GOLDEN, GOLDEN_NUMERAL, LABYRINTH
}

class CoinFamily:
	enum Tag {
		NEMESIS, #is a nemesis coin; used to exclude certain abilities such as Hypnos
		NO_TOLL, #unused; can't be offered at toll
		NEGATIVE_TOLL_VALUE, #thorns; toll value is negative
		CANNOT_GET_FROM_TRANSFORM_OR_GAIN, #thorns, telemachus, dolos - cannot be obtained by random generation
		NO_UPGRADE, #thorns, telemachus
		AUTO_UPGRADE_END_OF_ROUND, #phaethon
		LABYRINTH_WALL, #labyrinth
		CANT_TARGET, #charybdis
		NO_FLIP, #trials
		REBORN_ON_DESTROY, #phoenix
		GAIN_COIN_ON_DESTROY, #reliquary
		MELIAE_ON_MONSTER_DESTROYED, #hamadryad
		ENRAGE_ON_ECHIDNA_DESTROYED, #typhon
	}
	
	var id: int
	var coin_type: CoinType
	
	var coin_name: String
	var subtitle: String
	var unlock_tip: String
	var icon_path: String
	
	var base_price: int
	var heads_power_family: PF.PowerFamily
	var tails_power_family: PF.PowerFamily

	var appeasal_price_for_denom: Array
	
	var _sprite_style: _SpriteStyle
	
	var tags: Array
	
	func _init(ide: int, typ: CoinType, nme: String, 
			sub_title: String, icn_path: String, unlk_tip: String, b_price: int,
			heads_pwr: PF.PowerFamily, tails_pwr: PF.PowerFamily,
			style: _SpriteStyle, tgs := [], app_price := [NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE, NOT_APPEASEABLE_PRICE]) -> void:
		id = ide
		coin_type = typ
		coin_name = nme
		subtitle = sub_title
		unlock_tip = unlk_tip
		icon_path = icn_path
		base_price = b_price
		heads_power_family = heads_pwr
		tails_power_family = tails_pwr
		appeasal_price_for_denom = app_price
		for tg in tgs:
			assert(tg is Tag)
		tags = tgs
		_sprite_style = style
		assert(FileAccess.file_exists(icon_path))
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
			_SpriteStyle.GOLDEN:
				return "golden"
			_SpriteStyle.GOLDEN_NUMERAL:
				return "golden_numeral"
			_SpriteStyle.LABYRINTH:
				return "labyrinth"
		breakpoint
		return ""
	
	func has_tag(tag: Tag) -> bool:
		return tags.has(tag)

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
const _TUTORIAL_UPGRADE_TO_DIOBOL = 10
const _TUTORIAL_UPGRADE_TO_TRIOBOL = 20
const _TUTORIAL_UPGRADE_TO_TETROBOL = 40
const _TUTORIAL_UPGRADE_TO_PENTOBOL = 70
const _TUTORIAL_UPGRADE_TO_DRACHMA = 100
func get_price_to_upgrade(denom: Denomination) -> int:
	match(denom):
		Denomination.OBOL:
			return _UPGRADE_TO_DIOBOL + (_GREEDY_DIOBOL_INCREASE if is_difficulty_active(Difficulty.GREEDY4) else 0) if tutorialState == TutorialState.INACTIVE else _TUTORIAL_UPGRADE_TO_DIOBOL
		Denomination.DIOBOL:
			return _UPGRADE_TO_TRIOBOL + (_GREEDY_TRIOBOL_INCREASE if is_difficulty_active(Difficulty.GREEDY4) else 0) if tutorialState == TutorialState.INACTIVE else _TUTORIAL_UPGRADE_TO_TRIOBOL
		Denomination.TRIOBOL: 
			return _UPGRADE_TO_TETROBOL + (_GREEDY_TETROBOL_INCREASE if is_difficulty_active(Difficulty.GREEDY4) else 0) if tutorialState == TutorialState.INACTIVE else _TUTORIAL_UPGRADE_TO_TETROBOL
		Denomination.TETROBOL:
			return _UPGRADE_TO_PENTOBOL + (_GREEDY_PENTOBOL_INCREASE if is_difficulty_active(Difficulty.GREEDY4) else 0) if tutorialState == TutorialState.INACTIVE else _TUTORIAL_UPGRADE_TO_PENTOBOL
		Denomination.PENTOBOL:
			return _UPGRADE_TO_DRACHMA + (_GREEDY_DRACHMA_INCREASE if is_difficulty_active(Difficulty.GREEDY4) else 0) if tutorialState == TutorialState.INACTIVE else _TUTORIAL_UPGRADE_TO_DRACHMA
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

enum CoinType {
	TRIAL, PAYOFF, POWER, MONSTER
}

# Coin Families
# stores a list of all player coins (coins that can be bought in shop)
@onready var _ALL_PLAYER_COINS = [
		GENERIC_FAMILY, 
		HELIOS_FAMILY, ICARUS_FAMILY, ACHILLES_FAMILY, TANTALUS_FAMILY, AENEAS_FAMILY, ORION_FAMILY, CARPO_FAMILY, TELEMACHUS_FAMILY, PROMETHEUS_FAMILY,
	
		ZEUS_FAMILY, HERA_FAMILY, POSEIDON_FAMILY, DEMETER_FAMILY, APOLLO_FAMILY, ARTEMIS_FAMILY,
		ARES_FAMILY, ATHENA_FAMILY, HEPHAESTUS_FAMILY, APHRODITE_FAMILY, HERMES_FAMILY, HESTIA_FAMILY, DIONYSUS_FAMILY, HADES_FAMILY,
		
		PERSEUS_FAMILY, HYPNOS_FAMILY, NIKE_FAMILY, TRIPTOLEMUS_FAMILY, ANTIGONE_FAMILY, CHIONE_FAMILY, HECATE_FAMILY, 
		PHAETHON_FAMILY, ERYSICHTHON_FAMILY, DOLOS_FAMILY, ERIS_FAMILY, AEOLUS_FAMILY, BOREAS_FAMILY, DAEDALUS_FAMILY,
		PLUTUS_FAMILY, MIDAS_FAMILY, DIKE_FAMILY, SARPEDON_FAMILY, PROTEUS_FAMILY,
		# JASON_FAMILY
	]

@onready var _TUTORIAL_COINPOOL = [
	GENERIC_FAMILY,
	ZEUS_FAMILY, HERA_FAMILY, DEMETER_FAMILY, ARES_FAMILY, ATHENA_FAMILY, APHRODITE_FAMILY, HERMES_FAMILY, HESTIA_FAMILY, DIONYSUS_FAMILY,
]

@onready var _ALL_PLAYER_POWERS = [
	POWER_FAMILY_REFLIP, POWER_FAMILY_GAIN_LIFE, POWER_FAMILY_FREEZE, POWER_FAMILY_REFLIP_AND_NEIGHBORS, POWER_FAMILY_GAIN_ARROW,
	POWER_FAMILY_TURN_AND_BLURSE, POWER_FAMILY_REFLIP_ALL, POWER_FAMILY_REDUCE_PENALTY, POWER_FAMILY_PRIME_AND_IGNITE, POWER_FAMILY_COPY_FOR_TOSS,
	POWER_FAMILY_EXCHANGE, POWER_FAMILY_MAKE_LUCKY, POWER_FAMILY_GAIN_COIN, POWER_FAMILY_DOWNGRADE_FOR_LIFE, POWER_FAMILY_STONE,
	POWER_FAMILY_BLANK_TAILS, POWER_FAMILY_CONSECRATE_AND_DOOM, POWER_FAMILY_BURY_HARVEST, POWER_FAMILY_BURY_TURN_TAILS,
	POWER_FAMILY_TURN_TAILS_FREEZE_REDUCE_PENALTY, POWER_FAMILY_IGNITE_CHARGE_LUCKY, POWER_FAMILY_DESTROY_FOR_REWARD,
	POWER_FAMILY_INFINITE_TURN_HUNGER, POWER_FAMILY_TURN_SELF, POWER_FAMILY_CLONE_PERMANENTLY, POWER_FAMILY_FLIP_AND_TAG, 
	POWER_FAMILY_REFLIP_LEFT_ALTERNATING, POWER_FAMILY_SWAP_REFLIP_NEIGHBORS, POWER_FAMILY_PERMANENTLY_COPY_FACE_AND_DESTROY, POWER_FAMILY_GAIN_PLUTUS_COIN,
	POWER_FAMILY_GAIN_GOLDEN_COIN, POWER_FAMILY_TURN_ALL, POWER_FAMILY_IGNITE_OR_BLESS_OR_SACRIFICE, POWER_FAMILY_TRANSFORM_AND_LOCK
]

# payoff coins
var GENERIC_FAMILY = CoinFamily.new(1, CoinType.PAYOFF, "(DENOM)", "[color=gray]Common Currency[/color]", "res://assets/icons/coin/generic_icon.png", NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_GAIN_SOULS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.PAYOFF)

var HELIOS_FAMILY = CoinFamily.new(2, CoinType.PAYOFF, "Helios's (DENOM)", "[color=gray]Sunrises and Sets[/color]", "res://assets/icons/coin/helios_icon.png", NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_GAIN_SOULS_HELIOS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.PAYOFF)
var ICARUS_FAMILY = CoinFamily.new(3, CoinType.PAYOFF, "Icarus's (DENOM)", "[color=gray]Waxen Wings Melting[/color]", "res://assets/icons/coin/icarus_icon.png", NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_GAIN_SOULS_ICARUS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.PAYOFF)
var ACHILLES_FAMILY = CoinFamily.new(4, CoinType.PAYOFF, "Achilles's (DENOM)", "[color=gray]Held by the Heel[/color]", "res://assets/icons/coin/achilles_tails_icon.png", NO_UNLOCK_TIP,\
	RICH, POWER_FAMILY_GAIN_SOULS_ACHILLES, POWER_FAMILY_LOSE_LIFE_ACHILLES_HEEL, _SpriteStyle.PAYOFF)
var TANTALUS_FAMILY = CoinFamily.new(5, CoinType.PAYOFF, "Tantalus's (DENOM)", "[color=gray]Distant Fruit, Forbidden Water[/color]", "res://assets/icons/coin/tantalus_icon.png", NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_GAIN_SOULS_TANTALUS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.PAYOFF)
var AENEAS_FAMILY = CoinFamily.new(6, CoinType.PAYOFF, "Aeneas's (DENOM)", "[color=gray]Wasn't Built in a Day[/color]", "res://assets/icons/coin/aeneas_icon.png", NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_GAIN_SOULS_AENEAS, POWER_FAMILY_GAIN_SOULS_AENEAS, _SpriteStyle.PAYOFF)
var ORION_FAMILY = CoinFamily.new(7, CoinType.PAYOFF, "Orion's (DENOM)", "[color=gray]Hunting the Stars[/color]", "res://assets/icons/coin/orion_icon.png", NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_GAIN_SOULS_ORION, POWER_FAMILY_GAIN_ARROWS_ORION, _SpriteStyle.PAYOFF)
var CARPO_FAMILY = CoinFamily.new(8, CoinType.PAYOFF, "Carpo's (DENOM)", "[color=gray]Limitless Harvest[/color]", "res://assets/icons/coin/carpo_icon.png", NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_GAIN_SOULS_CARPO, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.PAYOFF)
var TELEMACHUS_FAMILY = CoinFamily.new(9, CoinType.PAYOFF, "Telemachus's (DENOM)", "[color=gray]Chasing His Footsteps[/color]", "res://assets/icons/coin/telemachus_icon.png", NO_UNLOCK_TIP,\
	CHEAP, POWER_FAMILY_GAIN_SOULS_TELEMACHUS, POWER_FAMILY_LOSE_LIFE_ONE, _SpriteStyle.PAYOFF, [CoinFamily.Tag.NO_UPGRADE, CoinFamily.Tag.CANNOT_GET_FROM_TRANSFORM_OR_GAIN])
var PROMETHEUS_FAMILY = CoinFamily.new(10, CoinType.PAYOFF, "(DENOM) of Prometheus", "[color=orangered]The First Flame[/color]", POWER_FAMILY_STOKE_FLAME.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_STOKE_FLAME, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.PAYOFF)

# power coins
var ZEUS_FAMILY = CoinFamily.new(1000, CoinType.POWER, "(DENOM) of Zeus", "[color=yellow]Lighting Strikes[/color]", POWER_FAMILY_REFLIP.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_REFLIP, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)

var HERA_FAMILY = CoinFamily.new(1001, CoinType.POWER, "(DENOM) of Hera", "[color=silver]Envious Wrath[/color]", POWER_FAMILY_REFLIP_AND_NEIGHBORS.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_REFLIP_AND_NEIGHBORS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)

var POSEIDON_FAMILY = CoinFamily.new(1002, CoinType.POWER, "(DENOM) of Poseidon", "[color=lightblue]Wave of Ice[/color]", POWER_FAMILY_FREEZE.icon_path, NO_UNLOCK_TIP,\
	RICH, POWER_FAMILY_FREEZE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var DEMETER_FAMILY = CoinFamily.new(1003, CoinType.POWER, "(DENOM) of Demeter", "[color=lightgreen]Grow Ever Stronger[/color]", POWER_FAMILY_GAIN_LIFE.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_GAIN_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var APOLLO_FAMILY = CoinFamily.new(1004, CoinType.POWER, "(DENOM) of Apollo", "[color=orange]Harmonic, Melodic[/color]", POWER_FAMILY_TURN_AND_BLURSE.icon_path,\
	"(BLESS)(POWERARROW)This coin will land on (HEADS) next flip.\n(CURSE)(POWERARROW)This coin will land on (TAILS) next flip.",\
	STANDARD, POWER_FAMILY_TURN_AND_BLURSE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var ARTEMIS_FAMILY = CoinFamily.new(1005, CoinType.POWER, "(DENOM) of Artemis", "[color=purple]Arrows of Night[/color]", POWER_FAMILY_GAIN_ARROW.icon_path,\
	"(ARROW)(POWERARROW)Can be used to reflip coins.\nPersists between tosses and rounds.",\
	PRICY, POWER_FAMILY_GAIN_ARROW, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var ARES_FAMILY = CoinFamily.new(1006, CoinType.POWER, "(DENOM) of Ares", "[color=indianred]Chaos of War[/color]", POWER_FAMILY_REFLIP_ALL.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_REFLIP_ALL, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var ATHENA_FAMILY = CoinFamily.new(1007, CoinType.POWER, "(DENOM) of Athena", "[color=cyan]Phalanx Strategy[/color]", POWER_FAMILY_REDUCE_PENALTY.icon_path, NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_REDUCE_PENALTY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var HEPHAESTUS_FAMILY = CoinFamily.new(1008, CoinType.POWER, "(DENOM) of Hephaestus", "[color=sienna]Forged With Fire[/color]", POWER_FAMILY_PRIME_AND_IGNITE.icon_path, \
	"(IGNITE)(POWERARROW)You lose 3 (LIFE) each payoff.",\
	RICH, POWER_FAMILY_PRIME_AND_IGNITE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var APHRODITE_FAMILY = CoinFamily.new(1009, CoinType.POWER, "(DENOM) of Aphrodite", "[color=lightpink]Two Lovers, United[/color]", POWER_FAMILY_COPY_FOR_TOSS.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_COPY_FOR_TOSS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var HERMES_FAMILY = CoinFamily.new(1010, CoinType.POWER, "(DENOM) of Hermes", "[color=lightskyblue]From Lands Distant[/color]", POWER_FAMILY_EXCHANGE.icon_path, NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_EXCHANGE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var HESTIA_FAMILY = CoinFamily.new(1011, CoinType.POWER, "(DENOM) of Hestia", "[color=sandybrown]Weary Bones Rest[/color]", POWER_FAMILY_MAKE_LUCKY.icon_path, NO_UNLOCK_TIP,\
	STANDARD,  POWER_FAMILY_MAKE_LUCKY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
var DIONYSUS_FAMILY = CoinFamily.new(1012, CoinType.POWER, "(DENOM) of Dionysus", "[color=plum]Wanton Revelry[/color]", POWER_FAMILY_GAIN_COIN.icon_path, NO_UNLOCK_TIP,\
	CHEAP, POWER_FAMILY_GAIN_COIN, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
	
const HADES_SELF_GAIN = [7, 9, 11, 13, 15, 18]
const HADES_MONSTER_COST = [7, 5, 3, 1, 0, 0]
var HADES_FAMILY = CoinFamily.new(1013, CoinType.POWER, "(DENOM) of Hades", "[color=slateblue]Beyond the Pale[/color]", POWER_FAMILY_DOWNGRADE_FOR_LIFE.icon_path, NO_UNLOCK_TIP,\
	CHEAP, POWER_FAMILY_DOWNGRADE_FOR_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)

var PERSEUS_FAMILY = CoinFamily.new(1014, CoinType.POWER, "(DENOM) of Perseus", "[color=lightslategray]Gorgon's Gaze, Mirrored[/color]", POWER_FAMILY_STONE.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_STONE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HYPNOS_FAMILY = CoinFamily.new(1015, CoinType.POWER, "(DENOM) of Hypnos", "[color=crimson]Bed of Poppies[/color]", POWER_FAMILY_BLANK_TAILS.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_BLANK_TAILS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var NIKE_FAMILY = CoinFamily.new(1016, CoinType.POWER, "(DENOM) of Nike", "[color=lawngreen]Victory Above All[/color]", POWER_FAMILY_CONSECRATE_AND_DOOM.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_CONSECRATE_AND_DOOM, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var TRIPTOLEMUS_FAMILY = CoinFamily.new(1017, CoinType.POWER, "(DENOM) of Triptolemus", "[color=olivedrab]Sow the Earth[/color]", POWER_FAMILY_BURY_HARVEST.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_BURY_HARVEST, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var ANTIGONE_FAMILY = CoinFamily.new(1018, CoinType.POWER, "(DENOM) of Antigone", "[color=sienna]Bury Thy Brother[/color]", POWER_FAMILY_BURY_TURN_TAILS.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_BURY_TURN_TAILS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var CHIONE_FAMILY = CoinFamily.new(1019, CoinType.POWER, "(DENOM) of Chione", "[color=powderblue]Embracing Cold[/color]", POWER_FAMILY_TURN_TAILS_FREEZE_REDUCE_PENALTY.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_TURN_TAILS_FREEZE_REDUCE_PENALTY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var HECATE_FAMILY = CoinFamily.new(1020, CoinType.POWER, "(DENOM) of Hecate", "[color=plum]The Key to Magick[/color]", POWER_FAMILY_IGNITE_CHARGE_LUCKY.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_IGNITE_CHARGE_LUCKY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
# extra space for - 1021
var PHAETHON_FAMILY = CoinFamily.new(1022, CoinType.POWER, "(DENOM) of Phaethon", "[color=orange]The Son's Hubris[/color]", POWER_FAMILY_DESTROY_FOR_REWARD.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_DESTROY_FOR_REWARD, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER, [CoinFamily.Tag.AUTO_UPGRADE_END_OF_ROUND])
var ERYSICHTHON_FAMILY = CoinFamily.new(1023, CoinType.POWER, "(DENOM) of Erysichthon", "[color=palegoldenrod]Faustian Hunger[/color]", POWER_FAMILY_INFINITE_TURN_HUNGER.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_INFINITE_TURN_HUNGER, POWER_FAMILY_TURN_SELF, _SpriteStyle.POWER)
var DOLOS_FAMILY = CoinFamily.new(1024, CoinType.POWER, "(DENOM) of Dolos", "[color=alicewhite]Behind Prosopon[/color]", POWER_FAMILY_CLONE_PERMANENTLY.icon_path, NO_UNLOCK_TIP,\
	PRICY, POWER_FAMILY_CLONE_PERMANENTLY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER, [CoinFamily.Tag.CANNOT_GET_FROM_TRANSFORM_OR_GAIN])
var ERIS_FAMILY = CoinFamily.new(1025, CoinType.POWER, "(DENOM) of Eris", "[color=gold]For the Fairest[/color]", POWER_FAMILY_FLIP_AND_TAG.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_FLIP_AND_TAG, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var AEOLUS_FAMILY = CoinFamily.new(1026, CoinType.POWER, "(DENOM) of Aeolus", "[color=skyblue]The Winds Shall Obey[/color]", POWER_FAMILY_REFLIP_LEFT_ALTERNATING.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_REFLIP_LEFT_ALTERNATING, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var BOREAS_FAMILY = CoinFamily.new(1027, CoinType.POWER, "(DENOM) of Boreas", "[color=powderblue]Northern Hail[/color]", POWER_FAMILY_SWAP_REFLIP_NEIGHBORS.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_SWAP_REFLIP_NEIGHBORS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var DAEDALUS_FAMILY = CoinFamily.new(1028, CoinType.POWER, "(DENOM) of Daedalus", "[color=peru]Automaton Inventor[/color]", POWER_FAMILY_PERMANENTLY_COPY_FACE_AND_DESTROY.icon_path, NO_UNLOCK_TIP,\
	RICH, POWER_FAMILY_PERMANENTLY_COPY_FACE_AND_DESTROY, POWER_FAMILY_PERMANENTLY_COPY_FACE_AND_DESTROY, _SpriteStyle.POWER)
var PLUTUS_FAMILY = CoinFamily.new(1029, CoinType.POWER, "(DENOM) of Plutus", "[color=palegoldenrod]Greed is Blind[/color]", POWER_FAMILY_GAIN_PLUTUS_COIN.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_GAIN_PLUTUS_COIN, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var MIDAS_FAMILY = CoinFamily.new(1030, CoinType.POWER, "(DENOM) of Midas", "[color=gold]All that Glitters[/color]", POWER_FAMILY_GAIN_GOLDEN_COIN.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_GAIN_GOLDEN_COIN, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var DIKE_FAMILY = CoinFamily.new(1031, CoinType.POWER, "(DENOM) of Dike", "[color=cornsilk]Fair and Balanced[/color]", POWER_FAMILY_TURN_ALL.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_TURN_ALL, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
#var JASON_FAMILY = CoinFamily.new(1032, CoinType.POWER, "(DENOM) of Jason", "[color=rosybrown]Roving Argonaut[/color]", POWER_FAMILY_GOLDEN_FLEECE.icon_path, NO_UNLOCK_TIP,\
#	STANDARD, POWER_FAMILY_GOLDEN_FLEECE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var SARPEDON_FAMILY = CoinFamily.new(1033, CoinType.POWER, "(DENOM) of Sarpedon", "[color=papayawhip]Cleansing Pyre[/color]", POWER_FAMILY_IGNITE_OR_BLESS_OR_SACRIFICE.icon_path, NO_UNLOCK_TIP,\
	STANDARD, POWER_FAMILY_IGNITE_OR_BLESS_OR_SACRIFICE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)
var PROTEUS_FAMILY = CoinFamily.new(1034, CoinType.POWER, "(DENOM) of Proteus", "[color=cornflowerblue]Water Shifts Shape[/color]", POWER_FAMILY_TRANSFORM_AND_LOCK.icon_path, NO_UNLOCK_TIP,\
	CHEAP, POWER_FAMILY_TRANSFORM_AND_LOCK, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.POWER)

var GENERATED_PLUTUS_FAMILY = CoinFamily.new(11000, CoinType.PAYOFF, "(DENOM), Gifted from Plutus", "[color=palegoldenrod]Greed is Good[/color]", POWER_FAMILY_GAIN_PLUTUS_COIN.icon_path, NO_UNLOCK_TIP,\
	RICH, POWER_FAMILY_GAIN_SOULS_PLUTUS, POWER_FAMILY_LOSE_LIFE_PLUTUS, _SpriteStyle.GOLDEN)
var GENERATED_GOLDEN_FAMILY = CoinFamily.new(11001, CoinType.PAYOFF, "Golden (DENOM)", "[color=gold]Boon or Bane?[/color]", POWER_FAMILY_GAIN_GOLDEN_COIN.icon_path, NO_UNLOCK_TIP,\
	RICH, POWER_FAMILY_DO_NOTHING, POWER_FAMILY_DO_NOTHING, _SpriteStyle.GOLDEN_NUMERAL)

# monsters
const NOT_APPEASEABLE_PRICE = -888
const STANDARD_APPEASE = [10, 15, 20, 25, 30, 35]
const ELITE_APPEASE = [35, 40, 45, 50, 55, 60]
const PHOENIX_APPEASE = [4, 6, 8, 10, 12, 14]
const RELIQUARY_APPEASE = [10,\
	int((10 + _UPGRADE_TO_DIOBOL) / 2.0),\
	int((10 + _UPGRADE_TO_DIOBOL + _UPGRADE_TO_TRIOBOL) / 2.0),\
	int((10 + _UPGRADE_TO_DIOBOL + _UPGRADE_TO_TRIOBOL + _UPGRADE_TO_TETROBOL) / 2.0),\
	int((10 + _UPGRADE_TO_DIOBOL + _UPGRADE_TO_TRIOBOL + _UPGRADE_TO_TETROBOL + _UPGRADE_TO_PENTOBOL) / 2.0),\
	int((10 + _UPGRADE_TO_DIOBOL + _UPGRADE_TO_TRIOBOL + _UPGRADE_TO_TETROBOL + _UPGRADE_TO_PENTOBOL + _UPGRADE_TO_DRACHMA) /2.0),\
	]
const AETERNAE_APPEASE = [888, 888, 888, 888, 888, 888]
const NEMESIS_MEDUSA_APPEASE = [38, 47, 55, 63, 71, 80]
const NEMESIS_ECHIDNA_APPEASE = [50, 62, 75, 85, 96, 106]
const NEMESIS_TYPHON_APPEASE = [36, 46, 56, 66, 76, 86]
const NEMESIS_LABYRINTH_APPEASE = [20, 30, 40, 50, 60, 70]
const NEMESIS_SCYLLA_APPEASE = [42, 50, 58, 66, 76, 86]
const NEMESIS_CHARYBDIS_APPEASE = [86, 96, 106, 116, 126, 136]
const NEMESIS_CERBERUS_APPEASE = [50, 60, 70, 80, 90, 100]

# stores a list of all monster coins and trial coins
@warning_ignore("unused_private_class_variable")
@onready var _ALL_MONSTER_AND_TRIAL_COINS = [
	MONSTER_HELLHOUND_FAMILY, MONSTER_KOBALOS_FAMILY, MONSTER_ARAE_FAMILY, MONSTER_HARPY_FAMILY, 
	MONSTER_TROJAN_HORSE_FAMILY, MONSTER_EIDOLON_FAMILY,MONSTER_HYPERBOREAN_FAMILY, MONSTER_GADFLY_FAMILY,
	MONSTER_STRIX_FAMILY, MONSTER_ERYMANTHIAN_BOAR_FAMILY, MONSTER_SPARTOI_FAMILY, MONSTER_EMPUSA_FAMILY,
	
	MONSTER_CENTAUR_FAMILY, MONSTER_STYMPHALIAN_BIRDS_FAMILY, MONSTER_COLCHIAN_DRAGON_FAMILY,
	MONSTER_PHOENIX_FAMILY, MONSTER_OREAD_FAMILY, MONSTER_HAMADRYAD_FAMILY,
	MONSTER_SATYR_FAMILY, MONSTER_RELIQUARY_FAMILY, MONSTER_AETERNAE_FAMILY,
	
	MONSTER_SIREN_FAMILY, MONSTER_BASILISK_FAMILY, MONSTER_CHIMERA_FAMILY, MONSTER_GORGON_FAMILY,
	MONSTER_KERES_FAMILY, MONSTER_TEUMESSIAN_FOX_FAMILY, MONSTER_MANTICORE_FAMILY, MONSTER_FURIES_FAMILY,
	MONSTER_SPHINX_FAMILY, MONSTER_CYCLOPS_FAMILY,
	
	MEDUSA_FAMILY, EURYALE_FAMILY, STHENO_FAMILY, 
	ECHIDNA_FAMILY, TYPHON_FAMILY, 
	CERBERUS_LEFT_FAMILY, CERBERUS_RIGHT_FAMILY, CERBERUS_MIDDLE_FAMILY,
	SCYLLA_FAMILY, CHARYBDIS_FAMILY,
	MINOTAUR_FAMILY, LABYRINTH_PASSIVE_FAMILY, LABYRINTH_WALLS1_FAMILY, LABYRINTH_WALLS2_FAMILY, LABYRINTH_WALLS3_FAMILY, LABYRINTH_WALLS4_FAMILY,
	
	TRIAL_IRON_FAMILY, TRIAL_MISFORTUNE_FAMILY, TRIAL_PAIN_FAMILY, TRIAL_BLOOD_FAMILY, TRIAL_EQUIVALENCE_FAMILY, TRIAL_TORMENT_FAMILY, 
	TRIAL_MALAISE_FAMILY, TRIAL_VIVISEPULTURE_FAMILY, TRIAL_IMMOLATION_FAMILY, TRIAL_VENGEANCE_FAMILY,
	
	TRIAL_FAMINE_FAMILY, TRIAL_TORTURE_FAMILY, TRIAL_LIMITATION_FAMILY, TRIAL_COLLAPSE_FAMILY, TRIAL_SAPPING_FAMILY, TRIAL_OVERLOAD_FAMILY,
	TRIAL_PETRIFICATION_FAMILY, TRIAL_SILENCE_FAMILY, TRIAL_POLARIZATION_FAMILY, TRIAL_SINGULARITY_FAMILY, TRIAL_GATING_FAMILY, TRIAL_FATE_FAMILY,
	TRIAL_ADVERSITY_FAMILY, TRIAL_VAINGLORY_FAMILY
]

# standard monsters
var MONSTER_FAMILY = CoinFamily.new(2000, CoinType.MONSTER, "[color=gray]Monster[/color]", "[color=purple]It Bars the Path[/color]", "res://assets/icons/coin/generic_icon.png", NO_UNLOCK_TIP,\
	NO_PRICE, POWER_FAMILY_LOSE_LIFE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_HELLHOUND_FAMILY = CoinFamily.new(2001, CoinType.MONSTER, "[color=gray]Hellhound's (DENOM)[/color]", "[color=purple]Infernal Pursurer[/color]", MONSTER_POWER_FAMILY_HELLHOUND.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_HELLHOUND, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_KOBALOS_FAMILY = CoinFamily.new(2002, CoinType.MONSTER, "[color=gray]Kobalos's (DENOM)[/color]", "[color=purple]Obstreperous Scamp[/color]", MONSTER_POWER_FAMILY_KOBALOS.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_KOBALOS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_ARAE_FAMILY = CoinFamily.new(2003, CoinType.MONSTER, "[color=gray]Arae's (DENOM)[/color]", "[color=purple]Encumber With Guilt[/color]", MONSTER_POWER_FAMILY_ARAE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_ARAE, POWER_FAMILY_LOSE_ZERO_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_HARPY_FAMILY = CoinFamily.new(2004, CoinType.MONSTER, "[color=gray]Harpy's (DENOM)[/color]", "[color=purple]Shrieking Wind[/color]", MONSTER_POWER_FAMILY_HARPY.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_HARPY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)

var MONSTER_TROJAN_HORSE_FAMILY = CoinFamily.new(2005, CoinType.MONSTER, "[color=gray]Trojan Horse's (DENOM)[/color]", "[color=purple]A Gift?[/color]", MONSTER_POWER_FAMILY_TROJAN_HORSE_DESTROY.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_TROJAN_HORSE_DESTROY, POWER_FAMILY_LOSE_ZERO_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_EIDOLON_FAMILY = CoinFamily.new(2006, CoinType.MONSTER, "[color=gray]Eidolon's (DENOM)[/color]", "[color=purple]Wailing Regrets[/color]", MONSTER_POWER_FAMILY_EIDOLON_UNLUCKY_SELF.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_EIDOLON_UNLUCKY_SELF, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_HYPERBOREAN_FAMILY = CoinFamily.new(2007, CoinType.MONSTER, "[color=gray]Hyperborean's (DENOM)[/color]", "[color=purple]Beyond the Ice[/color]", MONSTER_POWER_FAMILY_HYPERBOREAN_FREEZE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_HYPERBOREAN_FREEZE, MONSTER_POWER_FAMILY_HYPERBOREAN_LOSE_SOULS, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_GADFLY_FAMILY = CoinFamily.new(2008, CoinType.MONSTER, "[color=gray]Gadfly's (DENOM)[/color]", "[color=purple]Obnoxious Pest[/color]", MONSTER_POWER_FAMILY_GADFLY_THORNS.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_GADFLY_THORNS, MONSTER_POWER_FAMILY_GADFLY_LOSE_LIFE_SCALING, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_STRIX_FAMILY = CoinFamily.new(2009, CoinType.MONSTER, "[color=gray]Strix's (DENOM)[/color]", "[color=purple]Sordid and Silent[/color]", MONSTER_POWER_FAMILY_STRIX_INCREASE_PENALTY.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_STRIX_INCREASE_PENALTY, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
#var MONSTER_LAMIA_FAMILY = CoinFamily.new(2010, CoinType.MONSTER, "[color=gray]Lamia's (DENOM)[/color]", "[color=purple]Zealous Lover[/color]", MONSTER_POWER_FAMILY_LAMIA_BURY.icon_path, NO_UNLOCK_TIP,\
#	NO_PRICE, MONSTER_POWER_FAMILY_LAMIA_BURY, MONSTER_POWER_FAMILY_LAMIA_LOSE_SOULS, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_ERYMANTHIAN_BOAR_FAMILY = CoinFamily.new(2011, CoinType.MONSTER, "[color=gray]Erymanthian Boar's (DENOM)[/color]", "[color=purple]Raging Tusks[/color]", MONSTER_POWER_FAMILY_ERYMANTHIAN_BOAR_BURY.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_ERYMANTHIAN_BOAR_BURY, POWER_FAMILY_LOSE_LIFE_DOUBLED, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_SPARTOI_FAMILY = CoinFamily.new(2012, CoinType.MONSTER, "[color=gray]Spartoi's (DENOM)[/color]", "[color=purple]Born from the Dragon[/color]", MONSTER_POWER_FAMILY_SPARTOI_UPGRADE_SELF.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_SPARTOI_UPGRADE_SELF, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_EMPUSA_FAMILY = CoinFamily.new(2505, CoinType.MONSTER, "[color=gray]Empusa's (DENOM)[/color]", "[color=purple]Zealous Shifter[/color]", MONSTER_POWER_FAMILY_EMPUSA_TRANSFORM.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_EMPUSA_TRANSFORM, MONSTER_POWER_FAMILY_EMPUSA_LOSE_SOULS, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)

# neutral monsters
var MONSTER_CENTAUR_FAMILY = CoinFamily.new(2500, CoinType.MONSTER, "[color=gray]Centaur's (DENOM)[/color]", "[color=purple]Are the Stars Right?[/color]", "res://assets/icons/monster/centaur_icon.png", NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_CENTAUR_HEADS, MONSTER_POWER_FAMILY_CENTAUR_TAILS, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_STYMPHALIAN_BIRDS_FAMILY = CoinFamily.new(2501, CoinType.MONSTER, "[color=gray]Stymphalian Bird's (DENOM)[/color]", "[color=purple]Piercing Quills[/color]", MONSTER_POWER_FAMILY_STYMPHALIAN_BIRDS.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_STYMPHALIAN_BIRDS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_COLCHIAN_DRAGON_FAMILY = CoinFamily.new(2502, CoinType.MONSTER, "[color=gray]Colchian Dragon's (DENOM)[/color]", "[color=purple]Guardian of Fleece[/color]", MONSTER_POWER_FAMILY_COLCHIAN_DRAGON_GAIN_SOULS.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_COLCHIAN_DRAGON_GAIN_SOULS, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_PHOENIX_FAMILY = CoinFamily.new(2503, CoinType.MONSTER, "[color=gray]Phoenix's (DENOM)[/color]", "[color=purple]Ashes to Ashes[/color]", MONSTER_POWER_FAMILY_PHOENIX_HEAL.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_PHOENIX_HEAL, MONSTER_POWER_FAMILY_PHOENIX_IGNITE_SELF, _SpriteStyle.NEMESIS, [CoinFamily.Tag.REBORN_ON_DESTROY], PHOENIX_APPEASE)
var MONSTER_OREAD_FAMILY = CoinFamily.new(2504, CoinType.MONSTER, "[color=gray]Oread's (DENOM)[/color]", "[color=purple]Mountain Daughter[/color]", MONSTER_POWER_FAMILY_OREAD_BURY.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_OREAD_LUCKY, MONSTER_POWER_FAMILY_OREAD_BURY, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_HAMADRYAD_FAMILY = CoinFamily.new(2506, CoinType.MONSTER, "[color=gray]Hamadryad's (DENOM)[/color]", "[color=purple]Rooted Guardian[/color]", MONSTER_POWER_FAMILY_HAMADYRAD_BLESS.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_HAMADYRAD_BLESS, MONSTER_POWER_FAMILY_HAMADYRAD_HEAL, _SpriteStyle.NEMESIS, [CoinFamily.Tag.MELIAE_ON_MONSTER_DESTROYED], STANDARD_APPEASE)
var MONSTER_MELIAE_FAMILY = CoinFamily.new(2507, CoinType.MONSTER, "[color=gray]Meliae's (DENOM)[/color]", "[color=purple]Nature's Wrath[/color]", MONSTER_POWER_FAMILY_MELIAE_CURSE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_MELIAE_CURSE, POWER_FAMILY_LOSE_LIFE, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_SATYR_FAMILY = CoinFamily.new(2508, CoinType.MONSTER, "[color=gray]Satyr's (DENOM)[/color]", "[color=purple]Dancing Drunkard[/color]", MONSTER_POWER_FAMILY_SATYR_GAIN.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_SATYR_GAIN, MONSTER_POWER_FAMILY_SATYR_BLANK, _SpriteStyle.NEMESIS, [], STANDARD_APPEASE)
var MONSTER_RELIQUARY_FAMILY = CoinFamily.new(2509, CoinType.MONSTER, "[color=gray]Reliquary (DENOM)[/color]", "[color=purple]A Lucky Find?[/color]", MONSTER_POWER_FAMILY_RELIQUARY_DECREASE_COST.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_RELIQUARY_DECREASE_COST, MONSTER_POWER_FAMILY_RELIQUARY_INCREASE_COST, _SpriteStyle.NEMESIS, [CoinFamily.Tag.GAIN_COIN_ON_DESTROY], RELIQUARY_APPEASE)
var MONSTER_AETERNAE_FAMILY = CoinFamily.new(2510, CoinType.MONSTER, "[color=gray]AETERNAE'S (DENOM)[/color]", "[color=purple]ENGAICGTMBNEII[/color]", MONSTER_POWER_FAMILY_AETERNAE_HEADS.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_AETERNAE_HEADS, MONSTER_POWER_FAMILY_AETERNAE_TAILS, _SpriteStyle.NEMESIS, [], AETERNAE_APPEASE)


# elite monsters
var MONSTER_SIREN_FAMILY = CoinFamily.new(2502, CoinType.MONSTER, "[color=gray]Siren's (DENOM)[/color]", "[color=purple]Lure into Blue[/color]", MONSTER_POWER_FAMILY_SIREN.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_SIREN, MONSTER_POWER_FAMILY_SIREN_CURSE, _SpriteStyle.NEMESIS, [], ELITE_APPEASE)
var MONSTER_BASILISK_FAMILY = CoinFamily.new(2503, CoinType.MONSTER, "[color=gray]Basilisk's (DENOM)[/color]", "[color=purple]Gaze of Death[/color]", MONSTER_POWER_FAMILY_BASILISK.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_BASILISK, POWER_FAMILY_LOSE_ZERO_LIFE, _SpriteStyle.NEMESIS, [], ELITE_APPEASE)
var MONSTER_GORGON_FAMILY = CoinFamily.new(2504, CoinType.MONSTER, "[color=gray]Gorgon's (DENOM)[/color]", "[color=purple]Petrifying Beauty[/color]", MONSTER_POWER_FAMILY_GORGON.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_GORGON, MONSTER_POWER_FAMILY_GORGON_UNLUCKY, _SpriteStyle.NEMESIS, [], ELITE_APPEASE)
var MONSTER_CHIMERA_FAMILY = CoinFamily.new(2505, CoinType.MONSTER, "[color=gray]Chimera's (DENOM)[/color]", "[color=purple]Great Blaze[/color]", MONSTER_POWER_FAMILY_CHIMERA.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_CHIMERA, POWER_FAMILY_LOSE_LIFE_DOUBLED, _SpriteStyle.NEMESIS, [], ELITE_APPEASE)

var MONSTER_KERES_FAMILY = CoinFamily.new(2506, CoinType.MONSTER, "[color=gray]Keres's (DENOM)[/color]", "[color=purple]Death Comes Swiftly[/color]", MONSTER_POWER_FAMILY_KERES_PENALTY.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_KERES_PENALTY, MONSTER_POWER_FAMILY_KERES_DESECRATE, _SpriteStyle.NEMESIS, [], ELITE_APPEASE)
var MONSTER_TEUMESSIAN_FOX_FAMILY = CoinFamily.new(2507, CoinType.MONSTER, "[color=gray]Teumessian Fox's (DENOM)[/color]", "[color=purple]Uncatchable Quarry[/color]", MONSTER_POWER_FAMILY_TEUMESSIAN_FOX_BLANK_MORE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_TEUMESSIAN_FOX_BLANK_MORE, MONSTER_POWER_FAMILY_TEUMESSIAN_FOX_BLANK_LESS, _SpriteStyle.NEMESIS, [])
var MONSTER_MANTICORE_FAMILY = CoinFamily.new(2508, CoinType.MONSTER, "[color=gray]Manticore's (DENOM)[/color]", "[color=purple]Venomous Stinger[/color]", MONSTER_POWER_FAMILY_MANTICORE_CURSE_UNLUCKY_SELF.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_MANTICORE_CURSE_UNLUCKY_SELF, MONSTER_POWER_FAMILY_MANTICORE_DOWNGRADE, _SpriteStyle.NEMESIS, [], ELITE_APPEASE)
var MONSTER_FURIES_FAMILY = CoinFamily.new(2509, CoinType.MONSTER, "[color=gray]Furies's (DENOM)[/color]", "[color=purple]Vengeance on the Betrayer[/color]", MONSTER_POWER_FAMILY_FURIES_CURSE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_FURIES_CURSE, MONSTER_POWER_FAMILY_FURIES_UNLUCKY, _SpriteStyle.NEMESIS, [], ELITE_APPEASE)
var MONSTER_SPHINX_FAMILY = CoinFamily.new(2510, CoinType.MONSTER, "[color=gray]Sphinx's (DENOM)[/color]", "[color=purple]Presenting a Riddle[/color]", MONSTER_POWER_FAMILY_SPHINX_DOOMED.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_SPHINX_DOOMED, MONSTER_POWER_FAMILY_SPHINX_THORNS, _SpriteStyle.NEMESIS, [], ELITE_APPEASE)
var MONSTER_CYCLOPS_FAMILY = CoinFamily.new(2511, CoinType.MONSTER, "[color=gray]Cyclops's (DENOM)[/color]", "[color=purple]One-eyed Smith[/color]", MONSTER_POWER_FAMILY_CYCLOPS_DOWNGRADE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, MONSTER_POWER_FAMILY_CYCLOPS_DOWNGRADE, MONSTER_POWER_FAMILY_CYCLOPS_BURY, _SpriteStyle.NEMESIS, [], ELITE_APPEASE)

# nemesis
var MEDUSA_FAMILY = CoinFamily.new(3000, CoinType.MONSTER, "[color=greenyellow]Medusa's (DENOM)[/color]", "[color=purple]Mortal Sister[/color]", NEMESIS_POWER_FAMILY_MEDUSA_STONE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_MEDUSA_STONE, NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE, _SpriteStyle.NEMESIS, [CoinFamily.Tag.NEMESIS], NEMESIS_MEDUSA_APPEASE)
var EURYALE_FAMILY = CoinFamily.new(3001, CoinType.MONSTER, "[color=mediumaquamarine]Euryale's (DENOM)[/color]", "[color=purple]Lamentful Cry[/color]", NEMESIS_POWER_FAMILY_EURYALE_STONE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_EURYALE_STONE, NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY, _SpriteStyle.NEMESIS, [CoinFamily.Tag.NEMESIS], NEMESIS_MEDUSA_APPEASE)
var STHENO_FAMILY = CoinFamily.new(3002, CoinType.MONSTER, "[color=rosybrown]Stheno's (DENOM)[/color]", "[color=purple]Huntress of Man[/color]", NEMESIS_POWER_FAMILY_STHENO_STONE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_STHENO_STONE, NEMESIS_POWER_FAMILY_STHENO_CURSE, _SpriteStyle.NEMESIS, [CoinFamily.Tag.NEMESIS], NEMESIS_MEDUSA_APPEASE)

var ECHIDNA_FAMILY = CoinFamily.new(3010, CoinType.MONSTER, "[color=chartreuse]Echidna's (DENOM)[/color]", "[color=purple]Mother of Monstrosities[/color]", NEMESIS_POWER_FAMILY_ECHIDNA_SPAWN_STRONG.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_ECHIDNA_SPAWN_STRONG, NEMESIS_POWER_FAMILY_ECHIDNA_SPAWN_FLEETING, _SpriteStyle.NEMESIS, [CoinFamily.Tag.NEMESIS], NEMESIS_ECHIDNA_APPEASE)
var TYPHON_FAMILY = CoinFamily.new(3011, CoinType.MONSTER, "[color=palevioletred]Typhon's (DENOM)[/color]", "[color=purple]Father of Fiends[/color]", NEMESIS_POWER_FAMILY_TYPHON_UPGRADE_MONSTERS.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_TYPHON_UPGRADE_MONSTERS, NEMESIS_POWER_FAMILY_TYPHON_BLESS_MONSTERS, _SpriteStyle.NEMESIS, [CoinFamily.Tag.ENRAGE_ON_ECHIDNA_DESTROYED, CoinFamily.Tag.NEMESIS], NEMESIS_TYPHON_APPEASE)
var TYPHON_ENRAGED_FAMILY = CoinFamily.new(3012, CoinType.MONSTER, "[color=palevioletred]Typhon's (DENOM)[/color]", "[color=purple]Hatred Outlives the Hateful[/color]", NEMESIS_POWER_FAMILY_TYPHON_UPGRADE_MONSTERS.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_TYPHON_ENRAGED, NEMESIS_POWER_FAMILY_TYPHON_ENRAGED, _SpriteStyle.NEMESIS, [CoinFamily.Tag.NEMESIS], NEMESIS_TYPHON_APPEASE)

var CERBERUS_LEFT_FAMILY = CoinFamily.new(3020, CoinType.MONSTER, "[color=ornage]Cerberus's Left (DENOM)[/color]", "[color=purple]Blazing Bites that Burn[/color]", NEMESIS_POWER_FAMILY_CERBERUS_LEFT_IGNITE_SELF.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_CERBERUS_LEFT_IGNITE_SELF, NEMESIS_POWER_FAMILY_CERBERUS_LEFT_IGNITE, _SpriteStyle.NEMESIS, [CoinFamily.Tag.NEMESIS], NEMESIS_CERBERUS_APPEASE)
var CERBERUS_MIDDLE_FAMILY = CoinFamily.new(3021, CoinType.MONSTER, "[color=violet]Cerberus's Middle (DENOM)[/color]", "[color=purple]Hellish Howls that Haunt[/color]", NEMESIS_POWER_FAMILY_CERBERUS_MIDDLE_EMPOWER_IGNITE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_CERBERUS_MIDDLE_EMPOWER_IGNITE, NEMESIS_POWER_FAMILY_CERBERUS_MIDDLE_EMPOWER_PENALTY, _SpriteStyle.NEMESIS, [CoinFamily.Tag.NEMESIS], NEMESIS_CERBERUS_APPEASE)
var CERBERUS_RIGHT_FAMILY = CoinFamily.new(3022, CoinType.MONSTER, "[color=crimson]Cerberus's Right (DENOM)[/color]", "[color=purple]Cruel Claws that Catch[/color]", NEMESIS_POWER_FAMILY_CERBERUS_RIGHT_DESECRATE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_CERBERUS_RIGHT_DESECRATE, NEMESIS_POWER_FAMILY_CERBERUS_RIGHT_DAMAGE, _SpriteStyle.NEMESIS, [CoinFamily.Tag.NEMESIS], NEMESIS_CERBERUS_APPEASE)

var SCYLLA_FAMILY = CoinFamily.new(3030, CoinType.MONSTER, "[color=palegreen]Scylla's (DENOM)[/color]", "[color=purple]Between a Rock...[/color]", NEMESIS_POWER_FAMILY_SCYLLA_SHUFFLE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_SCYLLA_SHUFFLE, NEMESIS_POWER_FAMILY_SCYLLA_DAMAGE, _SpriteStyle.NEMESIS, [CoinFamily.Tag.NEMESIS], NEMESIS_SCYLLA_APPEASE)
var CHARYBDIS_FAMILY = CoinFamily.new(3031, CoinType.MONSTER, "[color=aqua]Charybdis's (DENOM)[/color]", "[color=purple]...and a Hard Place[/color]", NEMESIS_POWER_FAMILY_CHARYBDIS_LEFT.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_CHARYBDIS_LEFT, NEMESIS_POWER_FAMILY_CHARYBDIS_RIGHT, _SpriteStyle.NEMESIS, [CoinFamily.Tag.CANT_TARGET, CoinFamily.Tag.NEMESIS], NEMESIS_CHARYBDIS_APPEASE)

var MINOTAUR_FAMILY = CoinFamily.new(3040, CoinType.MONSTER, "[color=chocolate]The Minotaur's (DENOM)[/color]", "[color=purple]Unrelenting Beast[/color]", NEMESIS_POWER_FAMILY_MINOTAUR_SCALING_CURSE_UNLUCKY.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_MINOTAUR_SCALING_CURSE_UNLUCKY, NEMESIS_POWER_FAMILY_MINOTAUR_SCALING_DAMAGE, _SpriteStyle.NEMESIS, [CoinFamily.Tag.NEMESIS])
var LABYRINTH_PASSIVE_FAMILY = CoinFamily.new(3041, CoinType.TRIAL, "[color=white]Lost in the Labyrinth[/color]", "[color=lightsteelblue]Seek a Way Out![/color]", NEMESIS_POWER_FAMILY_LOST_IN_THE_LABYRINTH.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_LOST_IN_THE_LABYRINTH, NEMESIS_POWER_FAMILY_LOST_IN_THE_LABYRINTH, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var LABYRINTH_WALLS1_FAMILY = CoinFamily.new(3042, CoinType.MONSTER, "[color=lightsteelblue]Dark Labyrinth (DENOM)[/color]", "[color=purple]One Wrong Turn[/color]", NEMESIS_POWER_FAMILY_LABYRINTH_WALL1_ESCAPE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_LABYRINTH_WALL1_ESCAPE, NEMESIS_POWER_FAMILY_LABYRINTH_WALL_UNLUCKY, _SpriteStyle.LABYRINTH, [CoinFamily.Tag.LABYRINTH_WALL], NEMESIS_LABYRINTH_APPEASE)
var LABYRINTH_WALLS2_FAMILY = CoinFamily.new(3043, CoinType.MONSTER, "[color=lightsteelblue]Cold Labyrinth (DENOM)[/color]", "[color=purple]Bone Cold Corridor[/color]", NEMESIS_POWER_FAMILY_LABYRINTH_WALL2_ESCAPE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_LABYRINTH_WALL2_ESCAPE, NEMESIS_POWER_FAMILY_LABYRINTH_WALL_FREEZE, _SpriteStyle.LABYRINTH, [CoinFamily.Tag.LABYRINTH_WALL], NEMESIS_LABYRINTH_APPEASE)
var LABYRINTH_WALLS3_FAMILY = CoinFamily.new(3044, CoinType.MONSTER, "[color=lightsteelblue]Muddy Labyrinth (DENOM)[/color]", "[color=purple]Quagmire Underfoot[/color]", NEMESIS_POWER_FAMILY_LABYRINTH_WALL3_ESCAPE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_LABYRINTH_WALL3_ESCAPE, NEMESIS_POWER_FAMILY_LABYRINTH_WALL_BURY, _SpriteStyle.LABYRINTH, [CoinFamily.Tag.LABYRINTH_WALL], NEMESIS_LABYRINTH_APPEASE)
var LABYRINTH_WALLS4_FAMILY = CoinFamily.new(3045, CoinType.MONSTER, "[color=lightsteelblue]Broken Labyrinth (DENOM)[/color]", "[color=purple]Crumbling Masonry Collapses[/color]", NEMESIS_POWER_FAMILY_LABYRINTH_WALL4_ESCAPE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, NEMESIS_POWER_FAMILY_LABYRINTH_WALL4_ESCAPE, NEMESIS_POWER_FAMILY_LABYRINTH_WALL_DAMAGE, _SpriteStyle.LABYRINTH, [CoinFamily.Tag.LABYRINTH_WALL], NEMESIS_LABYRINTH_APPEASE)

# trials
#l v1
var TRIAL_IRON_FAMILY = CoinFamily.new(4000, CoinType.TRIAL, "[color=darkgray]Trial of Iron[/color]", "[color=lightgray]Weighted Down[/color]", TRIAL_POWER_FAMILY_IRON.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_IRON, TRIAL_POWER_FAMILY_IRON, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_MISFORTUNE_FAMILY = CoinFamily.new(4001, CoinType.TRIAL, "[color=purple]Trial of Misfortune[/color]", "[color=lightgray]Against the Odds[/color]", TRIAL_POWER_FAMILY_MISFORTUNE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_MISFORTUNE, TRIAL_POWER_FAMILY_MISFORTUNE, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_PAIN_FAMILY = CoinFamily.new(4002, CoinType.TRIAL, "[color=tomato]Trial of Pain[/color]", "[color=lightgray]Pulse Amplifier[/color]", TRIAL_POWER_FAMILY_PAIN.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_PAIN, TRIAL_POWER_FAMILY_PAIN, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_BLOOD_FAMILY = CoinFamily.new(4003, CoinType.TRIAL, "[color=crimson]Trial of Blood[/color]", "[color=lightgray]Paid in Crimson[/color]", TRIAL_POWER_FAMILY_BLOOD.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_BLOOD, TRIAL_POWER_FAMILY_BLOOD, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_EQUIVALENCE_FAMILY = CoinFamily.new(4004, CoinType.TRIAL, "[color=gold]Trial of Equivalence[/color]", "[color=lightgray]Fair, in a Way[/color]", TRIAL_POWER_FAMILY_EQUIVALENCE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_EQUIVALENCE, TRIAL_POWER_FAMILY_EQUIVALENCE, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])

var TRIAL_TORMENT_FAMILY = CoinFamily.new(4005, CoinType.TRIAL, "[color=floralwhite]Trial of Torment[/color]", "[color=lightgray]Vary or Die[/color]", TRIAL_POWER_FAMILY_TORMENT.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_TORMENT, TRIAL_POWER_FAMILY_TORMENT, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_MALAISE_FAMILY = CoinFamily.new(4006, CoinType.TRIAL, "[color=silver]Trial of Malaise[/color]", "[color=lightgray]Unnatural Fatigue[/color]", TRIAL_POWER_FAMILY_MALAISE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_MALAISE, TRIAL_POWER_FAMILY_MALAISE, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_VIVISEPULTURE_FAMILY = CoinFamily.new(4007, CoinType.TRIAL, "[color=peru]Trial of Vivisepulture[/color]", "[color=lightgray]Buried Alive[/color]", TRIAL_POWER_FAMILY_VIVISEPULTURE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_VIVISEPULTURE, TRIAL_POWER_FAMILY_VIVISEPULTURE, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_IMMOLATION_FAMILY = CoinFamily.new(4008, CoinType.TRIAL, "[color=orangered]Trial of Immolation[/color]", "[color=lightgray]Burn Bright and Fast[/color]", TRIAL_POWER_FAMILY_IMMOLATION.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_IMMOLATION, TRIAL_POWER_FAMILY_IMMOLATION, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_VENGEANCE_FAMILY = CoinFamily.new(4009, CoinType.TRIAL, "[color=plum]Trial of Vengeance[/color]", "[color=lightgray]Wronging a Right[/color]", TRIAL_POWER_FAMILY_VENGEANCE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_VENGEANCE, TRIAL_POWER_FAMILY_VENGEANCE, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_LIMITATION_FAMILY = CoinFamily.new(4510, CoinType.TRIAL, "[color=lightgray]Trial of Limitation[/color]", "[color=lightgray]Less is Less[/color]", TRIAL_POWER_FAMILY_LIMITATION.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_LIMITATION, TRIAL_POWER_FAMILY_LIMITATION, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_SAPPING_FAMILY = CoinFamily.new(4511, CoinType.TRIAL, "[color=paleturquoise]Trial of Sapping[/color]", "[color=lightgray]Energy Drain[/color]", TRIAL_POWER_FAMILY_SAPPING.icon_path, NO_UNLOCK_TIP, \
	NO_PRICE, TRIAL_POWER_FAMILY_SAPPING, TRIAL_POWER_FAMILY_SAPPING, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])


# lv2
var TRIAL_FAMINE_FAMILY = CoinFamily.new(4500, CoinType.TRIAL, "[color=burlywood]Trial of Famine[/color]", "[color=lightgray]Endless Hunger[/color]", TRIAL_POWER_FAMILY_FAMINE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_FAMINE, TRIAL_POWER_FAMILY_FAMINE, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_TORTURE_FAMILY = CoinFamily.new(4501, CoinType.TRIAL, "[color=darkred]Trial of Torture[/color]", "[color=lightgray]Boiling Veins[/color]", TRIAL_POWER_FAMILY_TORTURE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_TORTURE, TRIAL_POWER_FAMILY_TORTURE, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_COLLAPSE_FAMILY = CoinFamily.new(4502, CoinType.TRIAL, "[color=moccasin]Trial of Collapse[/color]", "[color=lightgray]Falling Down[/color]", TRIAL_POWER_FAMILY_COLLAPSE.icon_path, NO_UNLOCK_TIP, \
	NO_PRICE, TRIAL_POWER_FAMILY_COLLAPSE, TRIAL_POWER_FAMILY_COLLAPSE, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_OVERLOAD_FAMILY = CoinFamily.new(4503, CoinType.TRIAL, "[color=steelblue]Trial of Overload[/color]", "[color=lightgray]Energy Untethered[/color]", TRIAL_POWER_FAMILY_OVERLOAD.icon_path, NO_UNLOCK_TIP, \
	NO_PRICE, TRIAL_POWER_FAMILY_OVERLOAD, TRIAL_POWER_FAMILY_OVERLOAD, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_PETRIFICATION_FAMILY = CoinFamily.new(4504, CoinType.TRIAL, "[color=burlywood]Trial of Petrification[/color]", "[color=lightgray]Gorgon's Curse[/color]", TRIAL_POWER_FAMILY_PETRIFICATION.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_PETRIFICATION, TRIAL_POWER_FAMILY_PETRIFICATION, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_SILENCE_FAMILY = CoinFamily.new(4505, CoinType.TRIAL, "[color=burlywood]Trial of Silence[/color]", "[color=lightgray]With a Whimper[/color]", TRIAL_POWER_FAMILY_SILENCE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_SILENCE, TRIAL_POWER_FAMILY_SILENCE, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_POLARIZATION_FAMILY = CoinFamily.new(4506, CoinType.TRIAL, "[color=burlywood]Trial of Polarization[/color]", "[color=lightgray]Imbalanced Scales[/color]", TRIAL_POWER_FAMILY_POLARIZATION.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_POLARIZATION, TRIAL_POWER_FAMILY_POLARIZATION, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_SINGULARITY_FAMILY = CoinFamily.new(4507, CoinType.TRIAL, "[color=burlywood]Trial of Singularity[/color]", "[color=lightgray]All is One[/color]", TRIAL_POWER_FAMILY_SINGULARITY.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_SINGULARITY, TRIAL_POWER_FAMILY_SINGULARITY, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_GATING_FAMILY = CoinFamily.new(4508, CoinType.TRIAL, "[color=burlywood]Trial of Gating[/color]", "[color=lightgray]Behind Tall Walls[/color]", TRIAL_POWER_FAMILY_GATING.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_GATING, TRIAL_POWER_FAMILY_GATING, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_FATE_FAMILY = CoinFamily.new(4509, CoinType.TRIAL, "[color=burlywood]Trial of Fate[/color]", "[color=lightgray]Will of the Moirai[/color]", TRIAL_POWER_FAMILY_FATE.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_FATE, TRIAL_POWER_FAMILY_FATE, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_ADVERSITY_FAMILY = CoinFamily.new(4510, CoinType.TRIAL, "[color=burlywood]Trial of Adversity[/color]", "[color=lightgray]Looming Shadows[/color]", TRIAL_POWER_FAMILY_ADVERSITY.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_ADVERSITY, TRIAL_POWER_FAMILY_ADVERSITY, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])
var TRIAL_VAINGLORY_FAMILY = CoinFamily.new(4512, CoinType.TRIAL, "[color=burlywood]Trial of Vainglory[/color]", "[color=lightgray]Insidious Pride[/color]", TRIAL_POWER_FAMILY_VAINGLORY.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, TRIAL_POWER_FAMILY_VAINGLORY, TRIAL_POWER_FAMILY_VAINGLORY, _SpriteStyle.PASSIVE, [CoinFamily.Tag.NO_FLIP])

var THORNS_FAMILY = CoinFamily.new(9000, CoinType.PAYOFF, "(DENOM) of Thorns", "[color=darkgray]Metallic Barb[/color]\nCannot pay tolls.", "res://assets/icons/coin/thorns_icon.png", NO_UNLOCK_TIP,\
	NO_PRICE, POWER_FAMILY_LOSE_SOULS_THORNS, POWER_FAMILY_LOSE_LIFE_THORNS, _SpriteStyle.THORNS, [CoinFamily.Tag.NO_UPGRADE, CoinFamily.Tag.CANNOT_GET_FROM_TRANSFORM_OR_GAIN, CoinFamily.Tag.NEGATIVE_TOLL_VALUE])

var CHARON_OBOL_FAMILY = CoinFamily.new(10000, CoinType.PAYOFF, "[color=magenta]Charon's Obol[/color]", "Last Chance", CHARON_POWER_DEATH.icon_path, NO_UNLOCK_TIP,\
	NO_PRICE, CHARON_POWER_LIFE, CHARON_POWER_DEATH, _SpriteStyle.CHARONS)


# stores the active pool of coins for this run
# updated via generate_coinpool at the start of each run
var _COINPOOL = []

func generate_coinpool() -> void:
	_COINPOOL.clear()
	
	# coinpool may vary based on character
	match get_character():
		Character.LADY:
			_COINPOOL = _TUTORIAL_COINPOOL
		_:
			for coin_family in _ALL_PLAYER_COINS:
				if is_coin_unlocked(coin_family):
					_COINPOOL.append(coin_family)
	
	assert(_COINPOOL.size() != 0)
	assert(get_payoff_coinpool().size() != 0)
	assert(get_power_coinpool().size() != 0)
	
	#for coin in _COINPOOL:
	#	print(coin.coin_name)

func get_payoff_coinpool() -> Array:
	var payoffs = []
	for coin_family in _COINPOOL:
		if coin_family.coin_type == CoinType.PAYOFF:
			# exception - no telemachus after round 3
			if coin_family == TELEMACHUS_FAMILY and round_count > FIRST_ROUND + 2:
				continue
			payoffs.append(coin_family)
	payoffs.shuffle()
	return payoffs

func get_power_coinpool() -> Array:
	var powers = []
	for coin_family in _COINPOOL:
		if coin_family.coin_type == CoinType.POWER:
			powers.append(coin_family)
	powers.shuffle()
	return powers

func random_coin_family() -> CoinFamily:
	var roll = choose_one(_COINPOOL)
	if roll.has_tag(CoinFamily.Tag.CANNOT_GET_FROM_TRANSFORM_OR_GAIN):
		return random_coin_family()
	return choose_one(_COINPOOL)

func random_coin_family_excluding(excluded: Array) -> CoinFamily:
	var roll = random_coin_family()
	if roll in excluded:
		return random_coin_family_excluding(excluded)
	return roll

func random_power_coin_family() -> CoinFamily:
	var coin_family = random_coin_family()
	if coin_family.coin_type == CoinType.POWER :
		return coin_family
	return random_power_coin_family()

func random_power_coin_family_excluding(excluded: Array) -> CoinFamily:
	var roll = random_power_coin_family()
	if roll in excluded:
		return random_power_coin_family_excluding(excluded)
	return roll

func random_payoff_coin_family() -> CoinFamily:
	var coin_family = random_coin_family()
	if coin_family.coin_type == CoinType.PAYOFF:
		return coin_family
	return random_payoff_coin_family()

func random_payoff_coin_family_excluding(excluded: Array) -> CoinFamily:
	var roll = random_payoff_coin_family()
	if roll in excluded:
		return random_payoff_coin_family_excluding(excluded)
	return roll

func random_shop_denomination_for_round() -> Denomination:
	return choose_one(_current_round_shop_denoms())

func random_power_family() -> PF.PowerFamily:
	# for now, this can return any power, we may need to tweak this later
	# build a power pool similar to coinpool...
	return choose_one(_ALL_PLAYER_POWERS)

func random_power_family_excluding(excluded: Array) -> PF.PowerFamily:
	var power_family = random_power_family()
	if power_family in excluded:
		return random_power_family_excluding(excluded)
	return power_family

func is_passive_active(passivePower: PF.PowerFamily) -> bool:
	if not _coin_row or not _enemy_row:
		return false
	
	if patron and patron.power_family == passivePower:
		return true
	
	for row in [_coin_row, _enemy_row]:
		for coin in row.get_children():
			if coin.is_trial_coin() and coin.get_active_power_family() == passivePower:
				return true
	
	return false

func find_passive_coin(passivePower: PF.PowerFamily) -> Coin:
	for row in [_coin_row, _enemy_row]:
		for coin in row.get_children():
			if coin.is_trial_coin() and coin.get_active_power_family() == passivePower:
				return coin
	
	return null

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
		HADES_FAMILY.id : false,
		
		HELIOS_FAMILY.id : false,
		ICARUS_FAMILY.id : false,
		ACHILLES_FAMILY.id : false,
		TANTALUS_FAMILY.id : false,
		AENEAS_FAMILY.id : false,
		ORION_FAMILY.id : false,
		CARPO_FAMILY.id : false,
		TELEMACHUS_FAMILY.id : false,
		PERSEUS_FAMILY.id : false,
		HYPNOS_FAMILY.id : false,
		NIKE_FAMILY.id : false,
		TRIPTOLEMUS_FAMILY.id : false,
		ANTIGONE_FAMILY.id : false,
		CHIONE_FAMILY.id : false,
		HECATE_FAMILY.id : false,
		PROMETHEUS_FAMILY.id : false,
		PHAETHON_FAMILY.id : false,
		ERYSICHTHON_FAMILY.id : false,
		DOLOS_FAMILY.id : false,
		ERIS_FAMILY.id : false,
		AEOLUS_FAMILY.id : false,
		BOREAS_FAMILY.id : false,
		DAEDALUS_FAMILY.id : false,
		PLUTUS_FAMILY.id : false,
		MIDAS_FAMILY.id : false,
		DIKE_FAMILY.id : false,
		#JASON_FAMILY.id : false,
		SARPEDON_FAMILY.id : false,
		PROTEUS_FAMILY.id : false
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
	
	# more sanity - make sure no ids are duplicated
	# this is n^2 but I don't really care that much
	for coin in _ALL_PLAYER_COINS:
		for coin2 in _ALL_PLAYER_COINS:
			if coin != coin2:
				assert(coin.id != coin2.id, "shared id %d" % coin.id)
	
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
