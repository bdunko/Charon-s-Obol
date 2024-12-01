class_name CharonHand
extends Node2D

enum HandType {
	LEFT, RIGHT
}

@export var HAND_TYPE: HandType = HandType.LEFT

@onready var _SPRITE: AnimatedSprite2D = $Sprite
@onready var _BASE_POSITION = position
@onready var _MOUSE: MouseWatcher = $Mouse
@onready var _POINTING_OFFSET: Vector2 = $PointingOffset.position
@onready var _movementTween := InterruptableTween.new(self, "position")

# helper class for managing a tween which may be interrupted by another tween on the same property
class InterruptableTween:
	var _object: Object
	var _property: NodePath
	var _tween: Tween = null
	
	func _init(obj: Object, prop: NodePath):
		_object = obj
		_property = prop
	
	func tween(final_val: Variant, duration: float, trans := Tween.TransitionType.TRANS_LINEAR, easing := Tween.EaseType.EASE_IN_OUT):
		if _tween:
			_tween.kill()
		_tween = _object.create_tween()
		_tween.tween_property(_object, _property, final_val, duration).set_trans(trans).set_ease(easing)

func _ready():
	assert(_SPRITE)
	assert(_BASE_POSITION)
	assert(_MOUSE)
	assert(_POINTING_OFFSET)
	
	_MOUSE.mouse_entered.connect(_on_mouse_entered)
	_MOUSE.mouse_exited.connect(_on_mouse_exited)
	
	_SPRITE.flip_h = HAND_TYPE == HandType.RIGHT

func point_at(point: Vector2) -> void:
	_movementTween.tween(point - _POINTING_OFFSET, 0.5)

func reset_position() -> void:
	_movementTween.tween(_BASE_POSITION, 0.5)

func _on_mouse_entered() -> void:
	UITooltip.create(_MOUSE, "This is Charon's hand!", get_global_mouse_position(), get_tree().root)

func _on_mouse_exited() -> void:
	pass
