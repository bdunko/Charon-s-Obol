extends Node2D

signal start_pressed

func _on_start_button_pressed():
	emit_signal("start_pressed")

func _on_quit_button_pressed():
	get_tree().quit()
