# SFX
# Provides a list of sound effects. Basically a data node.
extends Node

static var RANDOM1 = RandomParams.new(0.75, 2.0)
static var RANDOM2 = RandomParams.new(1.0, 2.0)
static var RANDOM3 = RandomParams.new(1.25, 2.0)
static var RANDOM4 = RandomParams.new(1.5, 2.0)
static var RANDOM5 = RandomParams.new(2.0, 2.0)
static var RANDOM6 = RandomParams.new(2.5, 2.0)

class RandomParams:
	var pitch: float
	var volume_db: float
	
	func _init(rpitch: float = 1.0, rvolume_db: float = 0.0):
		pitch = rpitch
		volume_db = rvolume_db

class SFXParams:
	var _randomization: RandomParams = RandomParams.new()
	var _pitch: float = 1.0 # this is a 0.00001 to 16x multiplier of the pitch
	var _volume: float = 0.0 # this is an adjustment in db
	
	func random(randomization: RandomParams) -> SFXParams:
		_randomization = randomization
		return self
	
	func pitch(ptch: float) -> SFXParams:
		_pitch = ptch
		return self
	
	func volume(vlmn: float) -> SFXParams:
		_volume = vlmn
		return self

class Effect:
	var name
	var stream
	var max_instances
	
	var randomization
	var pitch_adjustment
	var volume_adjustment
	
	func _init(nme: String, raw_streams: Array, maxinstances: int, params: SFXParams = SFXParams.new()) -> void:
		name = nme
		
		randomization = params._randomization
		pitch_adjustment = params._pitch
		volume_adjustment = params._volume
		
		stream = AudioStreamRandomizer.new()
		stream.random_pitch = randomization.pitch
		stream.random_volume_offset_db = randomization.volume_db
		
		for s in raw_streams:
			stream.add_stream(-1, s)
		
		max_instances = maxinstances
	
	func get_stream() -> AudioStream:
		return stream
	
	func get_volume_adjustment() -> float:
		return volume_adjustment
	
	func get_pitch_adjustment() -> float:
		return pitch_adjustment


var DifficultySkullClicked = Effect.new("Difficulty Skull Clicked", [preload("res://assets/audio/sounds/water_ui/SFX Bubble6.wav")], 2,
	SFXParams.new().random(RANDOM1).volume(2.0))
var EmbarkButtonClicked = Effect.new("Embark Button Clicked", [preload("res://assets/audio/sounds/water_ui/SFX LongDrop.wav")], 1, 
	SFXParams.new().volume(8.0))
var SelectorArrowRightClicked = Effect.new("Selector Arrow Clicked", [preload("res://assets/audio/sounds/water_ui/SFX WaterBark.wav")], 1, 
	SFXParams.new().volume(-4.0).pitch(1.1))
var SelectorArrowLeftClicked = Effect.new("Selector Arrow Clicked", [preload("res://assets/audio/sounds/water_ui/SFX WaterBark.wav")], 1, 
	SFXParams.new().volume(-4.0).pitch(0.9))

var Hovered = Effect.new("Hovered", [preload("res://assets/audio/sounds/water_ui/SFX SploshClick2.wav")], 3,
	SFXParams.new().random(RANDOM1).volume(-26.0).pitch(0.3))

var PatronStatueHovered = Effect.new("Patron Statue Hovered", [preload("res://assets/audio/sounds/water_ui/SFX SploshClick2.wav")], 3,
	SFXParams.new().random(RANDOM1).volume(-16.0).pitch(0.3))
var PatronStatueClicked = Effect.new("Patron Statue Clicked", [preload("res://assets/audio/sounds/divine/SFX TwinkleTail.wav")], 1,
	SFXParams.new().pitch(1.0))
var GodTalk = Effect.new("God Talk", [preload("res://assets/audio/sounds/voices/SFX God1Frag1.wav"),
	preload("res://assets/audio/sounds/voices/SFX God1Frag2.wav"),
	preload("res://assets/audio/sounds/voices/SFX God1Frag3.wav"),
	preload("res://assets/audio/sounds/voices/SFX God1Frag4.wav"),
	preload("res://assets/audio/sounds/voices/SFX God1Frag5.wav"),
	preload("res://assets/audio/sounds/voices/SFX God1Frag6.wav"),
	preload("res://assets/audio/sounds/voices/SFX God1Frag7.wav")], 3,
	SFXParams.new().pitch(3.0).volume(-6.0).random(RandomParams.new(0.5, 2.0)))

var VictoryButtonClicked = Effect.new("Victory Button Clicked", [preload("res://assets/audio/sounds/divine/SFX WarmSwell.wav")], 1,
	SFXParams.new().pitch(1.8))

var TransitionQuoteIn = Effect.new("Transition Writing In", [preload("res://assets/audio/sounds/writing/SFX WriteCardboardScribble3.wav")], 1,
	SFXParams.new().pitch(1.3))
var TransitionQuoteInTip = Effect.new("Transition Writing In Tip", [preload("res://assets/audio/sounds/writing/SFX WriteCardboardScribble2.wav")], 1,
	SFXParams.new().volume(-6.0).pitch(1.7))
var TransitionQuoteOut = Effect.new("Transition Writing Out", [preload("res://assets/audio/sounds/writing/SFX WriteLine.wav")], 1,
	SFXParams.new().volume(-3.0).pitch(0.60))

# maybe make this watery. I do like my water.
#var TransitionZoomToCave = Effect.new("Transition Fade To Cave", [preload("res://assets/audio/sounds/transitions/SFX TransitionCrystal3.wav")], 1,
#	SFXParams.new().volume(0.0).pitch(1.1))
var TransitionZoomToCave = Effect.new("Transition Fade To Cave", [preload("res://assets/audio/sounds/water_ui/SFX AirRelease3.wav")], 1,
	SFXParams.new().volume(3.0).pitch(0.3))
var TransitionZoomToCaveLayer2 = Effect.new("Transition Fade To Cave (Layer2)", [preload("res://assets/audio/sounds/transitions/SFX TransitionCrystal3Shortened.wav")], 1,
	SFXParams.new().volume(0.0).pitch(1.0))


var MajorButton = Effect.new("Major Button", [preload("res://assets/audio/sounds/SFX MajorButton.wav")], 2)
var MajorButton2 = Effect.new("Major Button 2",[preload("res://assets/audio/sounds/SFX MajorButton2.wav")], 2)
var MinorButton = Effect.new("Minor Button", [preload("res://assets/audio/sounds/SFX MinorButton.wav")], 2, 
	SFXParams.new().random(RANDOM1))

var OpenMap = Effect.new("Open Map", [preload("res://assets/audio/sounds/OpenMap.wav")], 1)
var CloseMap = Effect.new("Page Turn", [preload("res://assets/audio/sounds/CloseMap.wav")], 1)

var PowerSelected = Effect.new("Power Selected", [preload("res://assets/audio/sounds/SFX PowerSelected.wav")], 1)
var PowerUnselected = Effect.new("Power Unselected", [preload("res://assets/audio/sounds/SFX PowerUnselected.wav")], 1)

var CoinToss = Effect.new("Coin Toss", [preload("res://assets/audio/sounds/SFX CoinToss.wav")], 1)
var CoinTurn = Effect.new("Coin Turn", [preload("res://assets/audio/sounds/SFX CoinTurn.wav")], 1)
var CoinLanding = Effect.new("Coin Landing", [preload("res://assets/audio/sounds/SFX CoinLanding.wav")], 1)

var PayoffGainSouls = Effect.new("Payoff Gain Souls", [preload("res://assets/audio/sounds/SFX PayoffGainSouls20.wav")], 5)

var PayoffMonster = Effect.new("Payoff Monster", [preload("res://assets/audio/sounds/SFX PayoffMonster.wav")], 3)
var StatusApplied = Effect.new("Status Applied", [preload("res://assets/audio/sounds/SFX StatusApplied.wav")], 3)
var LoseLife = Effect.new("Lose Life", [preload("res://assets/audio/sounds/SFX LoseLife.wav")], 3)

var PurchaseCoin = Effect.new("Purchase Coin", [preload("res://assets/audio/sounds/SFX PurchaseCoin.wav")], 1)
var Upgrade = Effect.new("Upgrade", [preload("res://assets/audio/sounds/SFX Upgrade.wav")], 3)

var CharonMaliceSlam = Effect.new("Charon Malice Slam", [preload("res://assets/audio/sounds/SFX CharonMaliceSlam.wav")], 1)
var CharonTalk = Effect.new("Charon Talk", [preload("res://assets/audio/sounds/SFX CharonTalk.wav")], 1)
