class_name CharonHand
extends Node2D

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
@onready var _RETRACTED_POSITION = position - Vector2(0, 30)
@onready var _OFFSCREEN_POSITION = position - Vector2(0, 80)

const _ANIM_NORMAL = "normal"
const _ANIM_POINTING = "pointing"

var _lock := false

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
	await _movementTween.tween(target, clamp(position.distance_to(target) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

func unpoint() -> void:
	if _lock:
		return
	set_appearance(Appearance.NORMAL)
	move_to_default_position()

func move_to_default_position() -> void:
	if _lock:
		return
	
	await _movementTween.tween(_BASE_POSITION, clamp(position.distance_to(_BASE_POSITION) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

func move_to_retracted_position() -> void:
	if _lock:
		return
	
	await _movementTween.tween(_RETRACTED_POSITION, clamp(position.distance_to(_RETRACTED_POSITION) / MOVEMENT_SPEED, 0.5, 0.8), Tween.TRANS_QUINT, Tween.EASE_OUT)

func move_offscreen(instant: bool = false) -> void:
	if _lock:
		return
	
	var target = _OFFSCREEN_POSITION
	
	if instant:
		_movementTween.kill()
		position = target
	else:
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
	print("normal")
	_FX.start_glowing(Color("#793a80"), 5, 1, 0.75)

func activate_malice_glow_intense() -> void:
	print("intense")
	_FX.start_glowing(Color("#bc4a9b"), 20, 1, 0.9)

func deactivate_malice_glow() -> void:
	_FX.stop_glowing()

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
