# SFX
# Provides a list of sound effects. Basically a data node.
extends Node

class Effect:
	var resource
	var max_instances
	
	func _init(res: Resource, maxinstances: int) -> void:
		resource = res
		max_instances = maxinstances

var MajorButton = Effect.new(preload("res://assets/audio/sounds/SFX MajorButton.wav"), 2)
var MajorButton2 = Effect.new(preload("res://assets/audio/sounds/SFX MajorButton2.wav"), 2)
var MinorButton = Effect.new(preload("res://assets/audio/sounds/SFX MinorButton.wav"), 2)

var OpenMap = Effect.new(preload("res://assets/audio/sounds/SFX OpenMap.wav"), 1)
var PageTurn = Effect.new(preload("res://assets/audio/sounds/SFX PageTurn.wav"), 1)

var PowerSelected = Effect.new(preload("res://assets/audio/sounds/SFX PowerSelected.wav"), 1)
var PowerUnselected = Effect.new(preload("res://assets/audio/sounds/SFX PowerUnselected.wav"), 1)

var CoinToss = Effect.new(preload("res://assets/audio/sounds/SFX CoinToss.wav"), 3)
var CoinTurn = Effect.new(preload("res://assets/audio/sounds/SFX CoinTurn.wav"), 3)
var CoinLanding = Effect.new(preload("res://assets/audio/sounds/SFX CoinLanding.wav"), 3)
var CoinLanding2 = Effect.new(preload("res://assets/audio/sounds/SFX CoinLanding2.wav"), 3)
var CoinLanding3 = Effect.new(preload("res://assets/audio/sounds/SFX CoinLanding3.wav"), 3)

var PayoffGainSouls20 = Effect.new(preload("res://assets/audio/sounds/SFX PayoffGainSouls20.wav"), 3)
var PayoffGainSouls22 = Effect.new(preload("res://assets/audio/sounds/SFX PayoffGainSouls22.wav"), 3)
var PayoffGainSouls24 = Effect.new(preload("res://assets/audio/sounds/SFX PayoffGainSouls24.wav"), 3)
var PayoffGainSouls26 = Effect.new(preload("res://assets/audio/sounds/SFX PayoffGainSouls26.wav"), 3)
var PayoffGainSouls28 = Effect.new(preload("res://assets/audio/sounds/SFX PayoffGainSouls28.wav"), 3)
var PayoffMonster = Effect.new(preload("res://assets/audio/sounds/SFX PayoffMonster.wav"), 3)
var StatusApplied = Effect.new(preload("res://assets/audio/sounds/SFX StatusApplied.wav"), 3)
var LoseLife = Effect.new(preload("res://assets/audio/sounds/SFX LoseLife.wav"), 3)


var PurchaseCoin = Effect.new(preload("res://assets/audio/sounds/SFX PurchaseCoin.wav"), 1)
var Upgrade = Effect.new(preload("res://assets/audio/sounds/SFX Upgrade.wav"), 3)

var WaterDrop = Effect.new(preload("res://assets/audio/sounds/SFX WaterDrop.wav"), 1)
var WaterDropNoReverb = Effect.new(preload("res://assets/audio/sounds/SFX WaterDropNoReverb.wav"), 1)

var CharonMaliceSlam = Effect.new(preload("res://assets/audio/sounds/SFX MajorButton.wav"), 2)
var CharonTalk = Effect.new(preload("res://assets/audio/sounds/SFX CharonTalk.wav"), 2)

# looping
var CharonMaliceCasting = Effect.new(preload("res://assets/audio/sounds/SFX CharonMaliceCasting.wav"), 1)
var HeavyWater = Effect.new(preload("res://assets/audio/sounds/SFX MajorButton.wav"), 1)
var Windstorm2 = Effect.new(preload("res://assets/audio/sounds/SFX MajorButton.wav"), 1)
var Windstorm = Effect.new(preload("res://assets/audio/sounds/SFX MajorButton.wav"), 1)
var VictoryBirds = Effect.new(preload("res://assets/audio/sounds/SFX MajorButton.wav"), 1)
