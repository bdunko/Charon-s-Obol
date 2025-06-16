extends Node2D

enum Effect {
	NONE, 						# doesn't do anything
	
	QUICK_FADE_OUT, 			# a very fast fade out (0.06s)
	FADE_OUT, 					# fading out (0.15s)
	MODERATE_FADE_OUT,			# a moderately slow fade out
	SLOW_FADE_OUT,				# a slow fade out (2.0s)
	
	QUICK_FADE_IN,				# fade in faster (0.06s)
	FADE_IN,					# fade in (0.15s)
	MODERATE_FADE_IN,			# fade in moderately slow
	SLOW_FADE_IN,				# fade in slowly (2.0s)
	
	CUSTOM_FADE_IN,				# fade in with a custom timing
	CUSTOM_FADE_OUT,			# fade out with a custom timing
	
	LABEL_FADE_IN,				# fade in the label (0.4s)
	LABEL_FADE_OUT				# fade out the label (0.4s)
}

@onready var _LAYER = $Layer
@onready var _COLORBOX = $Layer/ColorBox
@onready var _INITIAL_COLOR = $Layer/ColorBox.color
@onready var _LABEL = $Layer/Label
@onready var _CLICK_LABEL = $Layer/ClickLabel
@onready var _CLICK_LABEL_TWEEN = Global.ManagedTween.new(_CLICK_LABEL, "modulate:a")

var _fade_out_started = false # ugly, but used for a bit of handling with the click label...
var _is_playing = false
var _custom_fade_in_time = 1.0
var _custom_fade_out_time = 1.0

func _ready() -> void:
	assert(_COLORBOX)
	assert(_LABEL)
	assert(_CLICK_LABEL)
	assert(_CLICK_LABEL_TWEEN)
	for child in _LAYER.get_children():
		child.hide()
	_COLORBOX.modulate.a = 0.0
	_LABEL.modulate.a = 0.0
	_CLICK_LABEL.modulate.a = 0.0

func set_fade_time(in_time: float, out_time: float) -> void:
	_custom_fade_in_time = in_time
	_custom_fade_out_time = out_time

func set_text(txt: String) -> void:
	_LABEL.text = "[center]%s[/center]" % txt

func set_color(clr: Color) -> void:
	_COLORBOX.color = clr

func reset_color() -> void:
	_COLORBOX.color = _INITIAL_COLOR

# play a transition effect
func play(effect: Effect) -> void:
	if effect == Effect.NONE:
		return
	
	_is_playing = true
	
	match effect:
		Effect.QUICK_FADE_OUT:
			await _fade_out(_COLORBOX, 0.06)
		Effect.FADE_OUT:
			await _fade_out(_COLORBOX, 0.15)
		Effect.SLOW_FADE_OUT:
			await _fade_out(_COLORBOX, 2.0)
		Effect.MODERATE_FADE_OUT:
			await _fade_out(_COLORBOX, 0.7)
		Effect.CUSTOM_FADE_OUT:
			await _fade_out(_COLORBOX, _custom_fade_out_time)
		
		Effect.FADE_IN:
			await _fade_in(_COLORBOX, 0.15)
		Effect.QUICK_FADE_IN:
			await _fade_in(_COLORBOX, 0.06)
		Effect.SLOW_FADE_IN:
			await _fade_in(_COLORBOX, 2.0)
		Effect.MODERATE_FADE_IN:
			await _fade_in(_COLORBOX, 0.7)
		Effect.CUSTOM_FADE_IN:
			await _fade_in(_COLORBOX, _custom_fade_in_time)
		
		Effect.LABEL_FADE_IN:
			_fade_out_started = false
			Audio.play_sfx(SFX.TransitionQuoteIn)
			await _fade_out(_LABEL, 0.4) #these functions are a bit misleadingly named
			await Global.delay(2.0)
			if not _fade_out_started:
				_CLICK_LABEL.show()
				_CLICK_LABEL_TWEEN.tween(1.0, 0.4)
				Audio.play_sfx(SFX.TransitionQuoteInTip)
		Effect.LABEL_FADE_OUT:
			_fade_out_started = true
			Audio.play_sfx(SFX.TransitionQuoteOut)
			_CLICK_LABEL_TWEEN.tween(0.0, 0.4)
			await _fade_in(_LABEL, 0.4)
			_CLICK_LABEL.hide()
		_:
			assert(false, "No match for enum.")
	
	_is_playing = false
	
# check whether an effect is playing
func is_playing() -> bool:
	return _is_playing

func _fade_out(elem: CanvasItem, fade_time: float) -> void:
	elem.modulate.a = 0.0
	
	elem.show() # show so the fade blocks mouse clicks
	_is_playing = true
	
	# perform the fade out 
	var tween = create_tween()
	tween.tween_property(elem, "modulate:a", 1.0, fade_time)
	await tween.finished

func _fade_in(elem: CanvasItem, fade_time: float) -> void:
	elem.modulate.a = 1.0
	
	# perform the fade out
	var tween = create_tween()
	tween.tween_property(elem, "modulate:a", 0.0, fade_time)
	await tween.finished
	
	elem.hide() #hide so the fade no longer blocks mouse clicks
