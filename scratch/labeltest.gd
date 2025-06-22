extends Node2D

@onready var LABEL: AnimatedLabel = $AnimatedLabel

func _on_a_button_pressed():
	print("A!")
	LABEL.set_text("[center]34892![/center]")

func _on_b_button_pressed():
	print("B!")
	LABEL.set_text("[center]12345[/center]")
