class_name DialogueSystem
extends Node2D

signal _pressed

@onready var _INITIAL_POSITION = position
@export var ANIMATION_OFFSET = Vector2(0, -20)
var _current_textbox = null

func _ready() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

var _is_depressed = false
func _input(_event: InputEvent) -> void:
	if Input.is_anything_pressed() and not _is_depressed:
		_is_depressed = true
		emit_signal("_pressed")
	else:
		_is_depressed = false
 
func show_dialogue_and_wait(dialogue: String) -> void:
	show_dialogue(dialogue)
	await _pressed
	await Global.delay(0.04) #small delay after

func show_dialogue(dialogue: String) -> void:
	# remove the previous dialogue
	clear_dialogue()
	
	_current_textbox = DialogueTextbox.create()
	add_child(_current_textbox)
	_current_textbox.set_text(dialogue)
	_current_textbox.position = _INITIAL_POSITION + ANIMATION_OFFSET
	_current_textbox.modulate.a = 0.0
	_current_textbox.scale = Vector2(0.2, 0.2)
	
	# move the dialogue in from the top
	var tween = create_tween()
	tween.tween_property(_current_textbox, "position", _INITIAL_POSITION, 0.2)
	tween.parallel().tween_property(_current_textbox, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(_current_textbox, "scale", Vector2(1.0, 1.0), 0.1)

func clear_dialogue() -> void:
	if _current_textbox:
		_current_textbox.fade_and_free()
		_current_textbox = null

func instant_clear_dialogue() -> void:
	if _current_textbox:
		_current_textbox.hide()
		clear_dialogue()
