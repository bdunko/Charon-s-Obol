class_name CharonHand
extends Node2D

enum HandType {
	LEFT, RIGHT
}

@export var HAND_TYPE: HandType = HandType.LEFT

@onready var _SPRITE: AnimatedSprite2D = $Sprite
@onready var _SPRITE_BASE_Y = $Sprite.position.y
@onready var _MOUSE: MouseWatcher = $Mouse
@onready var _POINTING_OFFSET: Vector2 = $PointingOffset.position
@onready var _movementTween := InterruptableTween.new(self, "position")

@onready var _BASE_POSITION = position
@onready var _RETRACTED_POSITION = position - Vector2(0, 30)
@onready var _OFFSCREEN_POSITION = position - Vector2(0, 80)

const _ANIM_NORMAL = "normal"
const _ANIM_POINTING = "pointing"

var _lock := false

# helper class for managing a tween which may be interrupted by another tween on the same property
class InterruptableTween:
	var _object: Object
	var _property: NodePath
	var _tween: Tween = null
	var _tween_final_val: Variant = null
	var _tween_duration: float = 0.0
	
	func _init(obj: Object, prop: NodePath):
		_object = obj
		_property = prop
	
	func tween(final_val: Variant, duration: float, trans := Tween.TransitionType.TRANS_LINEAR, easing := Tween.EaseType.EASE_IN_OUT):
		if _tween:
			if _tween_final_val == final_val and _tween_duration == duration:
				return
			_tween.kill()
		_tween = _object.create_tween()
		_tween.tween_property(_object, _property, final_val, duration).set_trans(trans).set_ease(easing)
		_tween_final_val = final_val
		_tween_duration = duration
	
	func kill() -> void:
		if _tween:
			_tween.kill()

func _ready():
	assert(_SPRITE)
	assert(_BASE_POSITION)
	assert(_MOUSE)
	assert(_POINTING_OFFSET)
	
	_MOUSE.mouse_entered.connect(_on_mouse_entered)
	_MOUSE.mouse_exited.connect(_on_mouse_exited)
	
	_SPRITE.flip_h = HAND_TYPE == HandType.RIGHT
	
	set_appearance(Appearance.NORMAL)

const MOVEMENT_SPEED = 100

func point_at(point: Vector2) -> void:
	if _lock:
		return
	
	_SPRITE.play(_ANIM_POINTING)
	var target = point - _POINTING_OFFSET
	_movementTween.tween(target, clamp(position.distance_to(target) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

func move_to_default_position() -> void:
	if _lock:
		return
	
	_movementTween.tween(_BASE_POSITION, clamp(position.distance_to(_BASE_POSITION) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

func move_to_retracted_position() -> void:
	if _lock:
		return
	
	_movementTween.tween(_RETRACTED_POSITION, clamp(position.distance_to(_RETRACTED_POSITION) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

func move_offscreen(instant: bool = false) -> void:
	if _lock:
		return
	
	var target = _OFFSCREEN_POSITION
	
	if instant:
		_movementTween.kill()
		position = target
	else:
		_movementTween.tween(target, clamp(position.distance_to(target) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

enum Appearance {
	NORMAL, POINTING
}
func set_appearance(appearance: Appearance) -> void:
	match appearance:
		Appearance.NORMAL:
			_SPRITE.play(_ANIM_NORMAL)
		Appearance.POINTING:
			_SPRITE.play(_ANIM_POINTING)

func _on_mouse_entered() -> void:
	#UITooltip.create(_MOUSE, "This is Charon's hand!", get_global_mouse_position(), get_tree().root)
	pass

func _on_mouse_exited() -> void:
	pass

func _process(_delta) -> void:
	# constant 'up and down' oscillation
	_SPRITE.position.y = _SPRITE_BASE_Y + (2 * sin(Time.get_ticks_msec()/1000.0 * 2.0))

func lock() -> void:
	_lock = true

func unlock() -> void:
	_lock = false
