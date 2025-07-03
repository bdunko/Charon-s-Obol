extends Node2D

@onready var VIGNETTE_FX = $Vignette/FX

func _ready():
	assert(VIGNETTE_FX)

func _on_slight_button_pressed():
	VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.SLIGHT, 0.33)

func _on_moderate_button_pressed():
	VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.MODERATE, 0.33)

func _on_heavy_button_pressed():
	VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.HEAVY, 0.25)

func _on_severe_button_pressed():
	VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.SEVERE, 0.25)

func _on_pulsate_button_pressed():
	VIGNETTE_FX.start_vignette_pulsate(FX.VignetteSeverity.PULSATE)

func _on_pulsate_strong_button_pressed():
	VIGNETTE_FX.start_vignette_pulsate(FX.VignetteSeverity.PULSATE_STRONG)

func _on_pulsate_insane_button_pressed():
	VIGNETTE_FX.start_vignette_pulsate(FX.VignetteSeverity.PULSATE_INSANE)

func _on_pulsate_stop_button_pressed():
	VIGNETTE_FX.stop_vignette_pulsate()
