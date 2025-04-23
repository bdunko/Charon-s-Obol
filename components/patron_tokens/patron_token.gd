class_name PatronToken
extends Control

signal clicked

@onready var FX: FX = $Sprite2D/FX
@onready var _MOUSE: MouseWatcher = $Mouse

#@onready var _START_POSITION = position
const _SPEED = 5000
const _RETURN_SPEED = 500
const _ROTATION_TIME = 0.15

var _disable_tooltip = false:
	set(val):
		_disable_tooltip = val
		if _disable_tooltip:
			UITooltip.clear_tooltip_for(self)

var _disable_interaction = false:
	set(val):
		_disable_interaction = val
		_update_effects()

var _can_activate = false:
	set(val):
		_can_activate = val
		_update_effects()

var _activated = false:
	set(val):
		_activated = val
		_update_effects()

func _ready():
	assert(FX)
	assert(_MOUSE)
	Global.state_changed.connect(_on_state_changed)
	Global.patron_uses_changed.connect(_on_patron_changed)
	Global.patron_used_this_toss_changed.connect(_on_patron_changed)
	Global.patron_used_this_toss_changed.connect(_on_use)
	Global.passive_triggered.connect(_on_passive_triggered)
	
	_MOUSE.clicked.connect(_on_mouse_clicked)
	_MOUSE.mouse_entered.connect(_on_mouse_entered)
	_MOUSE.mouse_exited.connect(_on_mouse_exited)

static var _PARTICLE_ICON_GROW_SCENE = preload("res://particles/icon_grow.tscn")
@onready var _POWER_ICON_GROW_POINT = $PowerIconGrowPoint
func play_power_used_effect(power: PF.PowerFamily) -> void:
	var particle: GPUParticles2D = _PARTICLE_ICON_GROW_SCENE.instantiate()
	particle.texture = load(power.icon_path)
	_POWER_ICON_GROW_POINT.add_child(particle)

func _on_use() -> void:
	if Global.patron_used_this_toss:
		FX.flash(Color.WHITE)

func _on_passive_triggered(passive: PF.PowerFamily) -> void:
	if Global.patron.power_family == passive:
		FX.flash(Color.GOLD)

func _update_effects() -> void:
	# if disabled, remove all effects
	if _disable_interaction:
		FX.stop_flashing()
		FX.stop_glowing()
		return
	
	# if we are activated, flash gold
	# if we can be activated, flash white
	# otherwise disable flash
	if _activated:
		FX.start_glowing(Color.GOLD, FX.FAST_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, 1.0, false)
	elif _can_activate:
		FX.start_glowing(Color.AZURE, FX.FAST_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, 1.0 if _MOUSE.is_over() else FX.FAST_GLOW_MINIMUM, false)
	else:
		FX.stop_glowing()

func disable_interaction() -> void:
	_disable_interaction = true
	_disable_tooltip = true

# used for the tutorial specifically...
func disable_interaction_enable_tooltip() -> void:
	_disable_interaction = true
	_disable_tooltip = false

func enable_interaction() -> void:
	_disable_interaction = false
	_disable_tooltip = false

func _on_mouse_clicked():
	if _disable_interaction:
		return
	
	emit_signal("clicked")

func _on_mouse_entered():
	if not _disable_tooltip:
		var props = UITooltip.Properties.new().anchor(get_global_rect().get_center()).offset(get_global_rect().size.y / 2.0 + 15).direction(UITooltip.Direction.ABOVE)
		var tooltip = "%s[img=10x13]%s[/img]\n%s" % [Global.patron.token_name, Global.patron.get_icon_path(), Global.patron.get_description()]
		props = Global.add_subtooltips_for(tooltip, props)
		UITooltip.create(self, tooltip, get_global_mouse_position(), get_tree().root, props)
	
	if _disable_interaction:
		return
	
	_update_effects()

func _on_mouse_exited():
	_update_effects()

func activate() -> void:
	#create_tween().tween_property(self, "rotation_degrees", 90, _ROTATION_TIME)
	FX.flash(Color.GOLD)
	Global.active_coin_power_family = Global.patron.power_family
	Global.active_coin_power_coin = null # if there is an active coin, unactivate it
	_activated = true

func deactivate() -> void:
	#create_tween().tween_property(self, "rotation_degrees", 0, _ROTATION_TIME)
	Global.active_coin_power_family = null
	_activated = false

func can_activate() -> bool:
	return _can_activate

func is_activated() -> bool:
	return _activated

func _on_patron_changed() -> void:
	_can_activate = Global.state == Global.State.AFTER_FLIP and Global.patron_uses != 0 and not Global.patron_used_this_toss

func _process(_delta) -> void:
	#var target = (get_global_mouse_position() - Vector2(size.x/2 + 8, 0)) if _activated else _START_POSITION
	#position = position.move_toward(target, (_SPEED if _activated else _RETURN_SPEED) * delta)
	pass

func _on_state_changed() -> void:
	_can_activate = Global.state == Global.State.AFTER_FLIP and Global.patron_uses != 0 and not Global.patron_used_this_toss
