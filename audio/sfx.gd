# SFX
# Provides a list of sound effects. Basically a data node.
extends Node

class Effect:
	var name
	var resource
	var max_instances
	
	func _init(nme: String, res: Array, maxinstances: int) -> void:
		name = nme
		resource = res
		max_instances = maxinstances
	
	func get_resource() -> Resource:
		return Global.choose_one(resource)

var MajorButton = Effect.new("Major Button", [preload("res://assets/audio/sounds/SFX MajorButton.wav")], 2)
var MajorButton2 = Effect.new("Major Button 2",[preload("res://assets/audio/sounds/SFX MajorButton2.wav")], 2)
var MinorButton = Effect.new("Minor Button", [preload("res://assets/audio/sounds/SFX MinorButton.wav")], 2)

var OpenMap = Effect.new("Open Map", [preload("res://assets/audio/sounds/OpenMap.wav")], 1)
var CloseMap = Effect.new("Page Turn", [preload("res://assets/audio/sounds/CloseMap.wav")], 1)

var PowerSelected = Effect.new("Power Selected", [preload("res://assets/audio/sounds/SFX PowerSelected.wav")], 1)
var PowerUnselected = Effect.new("Power Unselected", [preload("res://assets/audio/sounds/SFX PowerUnselected.wav")], 1)

var CoinToss = Effect.new("Coin Toss", [preload("res://assets/audio/sounds/SFX CoinToss.wav")], 1)
var CoinTurn = Effect.new("Coin Turn", [preload("res://assets/audio/sounds/SFX CoinTurn.wav")], 1)
var CoinLanding = Effect.new("Coin Landing", [preload("res://assets/audio/sounds/SFX CoinLanding.wav")], 1)

var PayoffGainSouls = Effect.new("Payoff Gain Souls", [preload("res://assets/audio/sounds/SFX PayoffGainSouls20.wav"),
									preload("res://assets/audio/sounds/SFX PayoffGainSouls22.wav"),
									preload("res://assets/audio/sounds/SFX PayoffGainSouls24.wav"),
									preload("res://assets/audio/sounds/SFX PayoffGainSouls26.wav"),
									preload("res://assets/audio/sounds/SFX PayoffGainSouls28.wav")], 5)

var PayoffMonster = Effect.new("Payoff Monster", [preload("res://assets/audio/sounds/SFX PayoffMonster.wav")], 3)
var StatusApplied = Effect.new("Status Applied", [preload("res://assets/audio/sounds/SFX StatusApplied.wav")], 3)
var LoseLife = Effect.new("Lose Life", [preload("res://assets/audio/sounds/SFX LoseLife.wav")], 3)

var PurchaseCoin = Effect.new("Purchase Coin", [preload("res://assets/audio/sounds/SFX PurchaseCoin.wav")], 1)
var Upgrade = Effect.new("Upgrade", [preload("res://assets/audio/sounds/SFX Upgrade.wav")], 3)

var WaterDrop = Effect.new("Water Drop", [preload("res://assets/audio/sounds/SFX WaterDrop.wav")], 1)
var WaterDropNoReverb = Effect.new("Water Drop (No Reverb)", [preload("res://assets/audio/sounds/SFX WaterDropNoReverb.wav")], 1)

var CharonMaliceSlam = Effect.new("Charon Malice Slam", [preload("res://assets/audio/sounds/SFX CharonMaliceSlam.wav")], 1)
var CharonTalk = Effect.new("Charon Talk", [preload("res://assets/audio/sounds/SFX CharonTalk.wav")], 1)
