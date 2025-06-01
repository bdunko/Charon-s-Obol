# SFX
# Provides a list of sound effects. Basically a data node.
extends Node

class Effect:
	var resource
	var max_instances
	
	# if the sound is NOT interruptable:
	# 1) players of this sound cannot be stopped in the case that no players are available, even 
	#    if they are the oldest player.
	# 2) players of this sound do not stop when this sound attempts to be played while at its max_instances.
	var interruptable
	
	func _init(res: Array, maxinstances: int, can_interrupt: bool) -> void:
		resource = res
		max_instances = maxinstances
		interruptable = can_interrupt
	
	func get_resource() -> Resource:
		return Global.choose_one(resource)

var MajorButton = Effect.new([preload("res://assets/audio/sounds/SFX MajorButton.wav")], 2, true)
var MajorButton2 = Effect.new([preload("res://assets/audio/sounds/SFX MajorButton2.wav")], 2, true)
var MinorButton = Effect.new([preload("res://assets/audio/sounds/SFX MinorButton.wav")], 2, true)

var OpenMap = Effect.new([preload("res://assets/audio/sounds/SFX OpenMap.wav")], 1, true)
var PageTurn = Effect.new([preload("res://assets/audio/sounds/SFX PageTurn.wav")], 1, true)

var PowerSelected = Effect.new([preload("res://assets/audio/sounds/SFX PowerSelected.wav")], 1, true)
var PowerUnselected = Effect.new([preload("res://assets/audio/sounds/SFX PowerUnselected.wav")], 1, true)

var CoinToss = Effect.new([preload("res://assets/audio/sounds/SFX CoinToss.wav")], 1, true)
var CoinTurn = Effect.new([preload("res://assets/audio/sounds/SFX CoinTurn.wav")], 1, true)
var CoinLanding = Effect.new([preload("res://assets/audio/sounds/SFX CoinLanding.wav")], 1, true)

var PayoffGainSouls = Effect.new([preload("res://assets/audio/sounds/SFX PayoffGainSouls20.wav"),
									preload("res://assets/audio/sounds/SFX PayoffGainSouls22.wav"),
									preload("res://assets/audio/sounds/SFX PayoffGainSouls24.wav"),
									preload("res://assets/audio/sounds/SFX PayoffGainSouls26.wav"),
									preload("res://assets/audio/sounds/SFX PayoffGainSouls28.wav")], 5, true)

var PayoffMonster = Effect.new([preload("res://assets/audio/sounds/SFX PayoffMonster.wav")], 3, true)
var StatusApplied = Effect.new([preload("res://assets/audio/sounds/SFX StatusApplied.wav")], 3, true)
var LoseLife = Effect.new([preload("res://assets/audio/sounds/SFX LoseLife.wav")], 3, true)

var PurchaseCoin = Effect.new([preload("res://assets/audio/sounds/SFX PurchaseCoin.wav")], 1, true)
var Upgrade = Effect.new([preload("res://assets/audio/sounds/SFX Upgrade.wav")], 3, true)

var WaterDrop = Effect.new([preload("res://assets/audio/sounds/SFX WaterDrop.wav")], 1, true)
var WaterDropNoReverb = Effect.new([preload("res://assets/audio/sounds/SFX WaterDropNoReverb.wav")], 1, true)

var CharonMaliceSlam = Effect.new([preload("res://assets/audio/sounds/SFX CharonMaliceSlam.wav")], 1, true)
var CharonTalk = Effect.new([preload("res://assets/audio/sounds/SFX CharonTalk.wav")], 1, true)

# looping
var CharonMaliceCasting = Effect.new([preload("res://assets/audio/sounds/SFX CharonMaliceCastingAudio.wav")], 1, false)
var HeavyWater = Effect.new([preload("res://assets/audio/sounds/SFX HeavyWater.wav")], 1, false)
var Windstorm = Effect.new([preload("res://assets/audio/sounds/SFX Windstorm.wav")], 1, false)
var Windstorm2 = Effect.new([preload("res://assets/audio/sounds/SFX Windstorm2.wav")], 1, false)
var VictoryBirds = Effect.new([preload("res://assets/audio/sounds/SFX VictoryBirdsCombined.wav")], 1, false)
