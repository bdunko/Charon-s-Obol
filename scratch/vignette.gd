extends Node2D

@onready var VIGNETTE_FX = $Vignette/FX

func _ready():
	assert(VIGNETTE_FX)

func _on_slight_button_pressed():
	VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.SLIGHT)

func _on_moderate_button_pressed():
	VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.MODERATE)

func _on_heavy_button_pressed():
	VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.HEAVY)

func _on_severe_button_pressed():
	VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.SEVERE)

func _on_pulsate_button_pressed():
	VIGNETTE_FX.start_vignette_pulsate(FX.VignettePulsateSeverity.MINOR)

func _on_pulsate_strong_button_pressed():
	VIGNETTE_FX.start_vignette_pulsate(FX.VignettePulsateSeverity.STRONG)

func _on_pulsate_insane_button_pressed():
	VIGNETTE_FX.start_vignette_pulsate(FX.VignettePulsateSeverity.INSANE)

func _on_pulsate_stop_button_pressed():
	VIGNETTE_FX.stop_vignette_pulsate()
