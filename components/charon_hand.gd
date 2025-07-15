class_name CharonHand
extends Node2D

enum ColorStyle {
	PURPLE, GREEN, RED
}

enum HandType {
	LEFT, RIGHT
}

@export var HAND_TYPE: HandType = HandType.LEFT

@onready var _SPRITE: AnimatedSprite2D = $Sprite
@onready var _FX: FX = $Sprite/FX
@onready var _SPRITE_BASE_Y = $Sprite.position.y
@onready var _MOUSE: MouseWatcher = $Mouse
@onready var _POINTING_OFFSET: Vector2 = $PointingOffset.position
@onready var _movementTween: Global.ManagedTween = Global.ManagedTween.new(self, "position")

@onready var _BASE_POSITION = position
@onready var _RETRACTED_POSITION = position - Vector2(0, 25)
@onready var _OFFSCREEN_POSITION = position - Vector2(0, 80)
@onready var _FORWARD_POSITION = position + Vector2(0, 10)
@onready var _SLAM_POSITION = position + Vector2(0, 40)
@onready var _SLAM_PARTICLES = $SlamParticles

const MOVEMENT_SPEED = 100
const _ANIM_NORMAL = "normal"
const _ANIM_POINTING = "pointing"

var _lock := false
var _hovering := true

const _HIGHLIGHT_PURPLE_COLOR = Color("#fad6b8")
const _HIGHLIGHT_GREEN_COLOR = Color("#cdf7e2")
const _HIGHLIGHT_RED_COLOR = Color("#f9a31b")

var _current_color = ColorStyle.PURPLE:
	set(val):
		_current_color = val
		match(_current_color):
			ColorStyle.PURPLE:
				_FX.tween_uniform(FX.Uniform.VEC3_REPLACE_WITH_COLOR1, _HIGHLIGHT_PURPLE_COLOR, 0.5)
			ColorStyle.GREEN:
				_FX.tween_uniform(FX.Uniform.VEC3_REPLACE_WITH_COLOR1, _HIGHLIGHT_GREEN_COLOR, 0.5)
			ColorStyle.RED:
				_FX.tween_uniform(FX.Uniform.VEC3_REPLACE_WITH_COLOR1, _HIGHLIGHT_RED_COLOR, 0.5)

func _ready():
	assert(_SPRITE)
	assert(_BASE_POSITION)
	assert(_MOUSE)
	assert(_POINTING_OFFSET)
	assert(_SLAM_PARTICLES)
	
	_MOUSE.mouse_entered.connect(_on_mouse_entered)
	_MOUSE.mouse_exited.connect(_on_mouse_exited)
	
	_SPRITE.flip_h = HAND_TYPE == HandType.RIGHT
	
	set_appearance(Appearance.NORMAL)
	
func recolor(style: ColorStyle):
	_current_color = style

func disable_hovering() -> void:
	_hovering = false

func enable_hovering() -> void:
	_hovering = true

func point_at(point: Vector2) -> void:
	if _lock:
		return
	
	_SPRITE.play(_ANIM_POINTING)
	var target = point - _POINTING_OFFSET
	Audio.play_sfx(SFX.CharonTalk)
	await _movementTween.tween(target, clamp(position.distance_to(target) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

func unpoint() -> void:
	if _lock:
		return
	set_appearance(Appearance.NORMAL)
	move_to_default_position()

func slam() -> void:
	if _lock:
		return
	set_appearance(Appearance.NORMAL)
	await _movementTween.tween(position + Vector2(0, -15), 0.1, Tween.TRANS_QUART)
	await _movementTween.tween(_SLAM_POSITION, 0.1, Tween.TRANS_QUART)
	Audio.play_sfx(SFX.CharonMaliceSlam)
	for child in _SLAM_PARTICLES.get_children():
		child.emitting = true
	await _movementTween.tween(_SLAM_POSITION - Vector2(0, 10), 0.05, Tween.TRANS_QUART)

func move_to_default_position() -> void:
	if _lock:
		return
	Audio.play_sfx(SFX.CharonTalk)
	await _movementTween.tween(_BASE_POSITION, clamp(position.distance_to(_BASE_POSITION) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

func move_to_forward_position() -> void:
	if _lock:
		return
	Audio.play_sfx(SFX.CharonTalk)
	await _movementTween.tween(_FORWARD_POSITION, clamp(position.distance_to(_BASE_POSITION) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

func move_to_retracted_position() -> void:
	if _lock:
		return
	Audio.play_sfx(SFX.CharonTalk)
	await _movementTween.tween(_RETRACTED_POSITION, clamp(position.distance_to(_RETRACTED_POSITION) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

func move_offscreen(instant: bool = false) -> void:
	if _lock:
		return
	
	var target = _OFFSCREEN_POSITION
	
	if instant:
		_movementTween.kill()
		position = target
	else:
		Audio.play_sfx(SFX.CharonTalk)
		await _movementTween.tween(target, clamp(position.distance_to(target) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

enum Appearance {
	NORMAL, POINTING
}
func set_appearance(appearance: Appearance) -> void:
	match appearance:
		Appearance.NORMAL:
			_SPRITE.play(_ANIM_NORMAL)
		Appearance.POINTING:
			_SPRITE.play(_ANIM_POINTING)

func activate_malice_glow() -> void:
	_FX.start_glowing(Color("#793a80"), 5, 1, 0.6)

func activate_malice_glow_intense() -> void:
	_FX.start_glowing(Color("#bc4a9b"), 25, 1, 0.9)

func deactivate_malice_glow() -> void:
	_FX.stop_glowing()

func activate_malice_active_tint() -> void:
	_FX.start_flashing(Color("#bc4a9b"))

func deactivate_malice_active_tint() -> void:
	_FX.stop_flashing()

func _on_mouse_entered() -> void:
	#UITooltip.create(_MOUSE, "This is Charon's hand!", get_global_mouse_position(), get_tree().root)
	pass

func _on_mouse_exited() -> void:
	pass

func _process(_delta) -> void:
	if _hovering:
		# constant 'up and down' oscillation
		_SPRITE.position.y = _SPRITE_BASE_Y + (2 * sin(Time.get_ticks_msec()/1000.0 * 2.0))

func lock() -> void:
	_lock = true

func unlock() -> void:
	_lock = false
