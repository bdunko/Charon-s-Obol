class_name DialogueSystem
extends Node2D

const _DEFAULT_TEXT_COLOR = Color.WHITE
@export var text_color = _DEFAULT_TEXT_COLOR:
	set(val):
		text_color = val
		if _current_textbox:
			_current_textbox.text_color = val

const _DEFAULT_BACKGROUND_COLOR = Color("#141013")
@export var background_color = _DEFAULT_BACKGROUND_COLOR:
	set(val):
		background_color = val
		if _current_textbox:
			_current_textbox.background_color = val

const _DEFAULT_BORDER_COLOR = Color("#feffff")
@export var border_color = _DEFAULT_BORDER_COLOR:
	set(val):
		border_color = val
		if _current_textbox:
			_current_textbox.border_color = val

@export var textbox_float: bool = false

@onready var _INITIAL_POSITION = position
@export var ANIMATION_OFFSET = Vector2(0, -20)
var _current_textbox = null

func _ready() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
 
func show_dialogue_and_wait(dialogue: String) -> void:
	show_dialogue(dialogue)
	await Global.any_input
	await Global.delay(0.04) #small delay after

func show_dialogue(dialogue: String) -> void:
	# remove the previous dialogue
	clear_dialogue()
	
	_current_textbox = Textbox.create(text_color, background_color, border_color, textbox_float)
	add_child(_current_textbox)
	_current_textbox.set_text(dialogue)
	
	# center the textbox horizontally
	_current_textbox.position.y = _INITIAL_POSITION.y + ANIMATION_OFFSET.y
	_current_textbox.modulate.a = 0.0
	
	# move the dialogue in from the top
	var tween = create_tween()
	tween.tween_property(_current_textbox, "position:y", _INITIAL_POSITION.y, 0.2)
	tween.parallel().tween_property(_current_textbox, "modulate:a", 1.0, 0.2)
	
	_current_textbox.position.x = int((320.0/2.0) - (_current_textbox.size.x/2.0))
	
func clear_dialogue() -> void:
	if _current_textbox:
		_current_textbox.fade_and_free()
		_current_textbox = null

func instant_clear_dialogue() -> void:
	if _current_textbox:
		_current_textbox.hide()
		clear_dialogue()
