class_name DialogueSystem
extends Node2D

@export var talk_sfx: TalkSFX = TalkSFX.NONE
enum TalkSFX {
	NONE, CHARON, GOD
}

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

const _DEFAULT_FLASH_COLOR = Color("#e86a73")
@export var flash_color = _DEFAULT_FLASH_COLOR:
	set(val):
		flash_color = val
		if _current_textbox:
			_current_textbox.flash_color = val

@export var textbox_effects_while_waiting = false
@export var textbox_arrow_style = Textbox.ArrowStyle.PURPLE
@export var textbox_float: bool = false

@onready var _INITIAL_POSITION = position
@export var ANIMATION_OFFSET = Vector2(0, -20)
var _current_textbox = null
var _waiting = false

func _ready() -> void:
	var placeholder = find_child("Textbox")
	assert(placeholder)
	remove_child(placeholder)
	placeholder.queue_free()
 
func is_waiting() -> bool:
	return _waiting

const MINIMUM_DELAY = 0.01
func show_dialogue_and_wait(dialogue: String, minimum_delay: float = MINIMUM_DELAY, vocalize: bool = true) -> void:
	_waiting = true
	show_dialogue(dialogue, textbox_effects_while_waiting, vocalize)
	_current_textbox.show_arrow = false
	await Global.delay(minimum_delay)
	_current_textbox.show_arrow = true
	await Global.left_click_input
	await Global.delay(0.04 if Global.tutorialState == Global.TutorialState.INACTIVE else 0.12) #small delay after
	_waiting = false

func show_dialogue_unadvancable(dialogue: String, vocalize: bool = true) -> void:
	show_dialogue(dialogue, textbox_effects_while_waiting, vocalize)
	_current_textbox.show_arrow = false

func make_current_dialogue_advancable_and_wait() -> void:
	_waiting = true
	_current_textbox.show_arrow = true
	await Global.left_click_input
	await Global.delay(0.04 if Global.tutorialState == Global.TutorialState.INACTIVE else 0.12) #small delay after
	_waiting = false

func show_dialogue(dialogue: String, waiting: bool = false, vocalize: bool = true) -> void:
	# remove the previous dialogue
	clear_dialogue()
	
	# sugar
	var should_flash = waiting 
	var should_arrow = waiting
	
	_current_textbox = Textbox.create(text_color, background_color, border_color, flash_color, textbox_float, false, should_flash, should_arrow, textbox_arrow_style)
	add_child(_current_textbox)
	_current_textbox.set_text(dialogue)
	
	# center the textbox horizontally
	_current_textbox.position.y = _INITIAL_POSITION.y + ANIMATION_OFFSET.y
	_current_textbox.modulate.a = 0.0
	
	# move the dialogue in from the top
	var tween = create_tween()
	tween.tween_property(_current_textbox, "position:y", _INITIAL_POSITION.y, 0.2)
	tween.parallel().tween_property(_current_textbox, "modulate:a", 1.0, 0.2)
	
	if vocalize:
		if talk_sfx == TalkSFX.CHARON:
			Audio.play_sfx(SFX.CharonTalk)
		elif talk_sfx == TalkSFX.GOD:
			Audio.play_sfx(SFX.GodTalk)
	
	_current_textbox.position.x = int((get_viewport_rect().size.x/2.0) - (_current_textbox.size.x/2.0))

func clear_dialogue() -> void:
	if _current_textbox:
		_current_textbox.fade_and_free()
		_current_textbox = null

func instant_clear_dialogue() -> void:
	if _current_textbox:
		_current_textbox.hide()
		clear_dialogue()
