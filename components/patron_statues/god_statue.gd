class_name PatronStatue
extends Control

@export var patron_enum: Global.PatronEnum

@onready var _SPRITE: Sprite2D = $Sprite2D
@onready var _MOUSE: MouseWatcher = $MouseWatcher
@onready var _FX: FX = $Sprite2D/FX

signal clicked

var _disabled = false
var _show_tooltip = true:
	set(val):
		_show_tooltip = val
		if not _show_tooltip:
			clear_tooltip()

var _tooltip = null

func _ready():
	assert(patron_enum != Global.PatronEnum.NONE)
	assert(_MOUSE)
	assert(_FX)
	
	_MOUSE.clicked.connect(_on_mouse_clicked)
	_MOUSE.mouse_entered.connect(_on_mouse_entered)
	_MOUSE.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_clicked():
	if not _disabled:
		Audio.play_sfx(SFX.PatronStatueClicked)
		_FX.start_glowing_solid(Color.GOLD, 2.0, FX.DEFAULT_GLOW_THICKNESS, false)
		emit_signal("clicked", self) 

func _on_mouse_entered():
	var patron = Global.patron_for_enum(patron_enum)
	var nme = patron.god_name if patron_enum != Global.PatronEnum.GODLESS else "an [color=gray]Unknown God[/color]"
	var desc = patron.get_description(true) if patron_enum != Global.PatronEnum.GODLESS else "???"
	
	if not _disabled:
		_FX.start_glowing_solid(Color.AZURE, 2)
		Audio.play_sfx(SFX.PatronStatueHovered)
	if _show_tooltip and _tooltip == null:
		var anchor = get_global_rect().position + _SPRITE.get_rect().get_center()
		var offset = get_global_rect().position.y + _SPRITE.get_rect().size.y / 2.0 + 31
		var props = UITooltip.Properties.new().anchor(anchor).direction(UITooltip.Direction.BELOW).offset(offset)
		var tt_text = "Altar to %s\n%s" % [nme, desc]
		props = Global.add_subtooltips_for(tt_text, props)
		_tooltip = UITooltip.create_manual(Global.replace_placeholders(tt_text), get_global_mouse_position(), get_tree().root, props)

func apply_spectral_fx() -> void:
	_FX.start_glowing_solid(Color.GOLD, 2, FX.DEFAULT_GLOW_THICKNESS, false)
	_FX.tint(Color.AQUA, 0.8)
	_FX.start_flickering(2.0, 0.3, 0.8)

func clear_fx() -> void:
	_FX.stop_glowing()
	_FX.clear_tint()
	_FX.stop_flickering()

func disable() -> void:
	_disabled = true
	_show_tooltip = false

func clear_tooltip() -> void:
	if _tooltip:
		_tooltip.destroy_tooltip()
		_tooltip = null

func disable_except_tooltip() -> void:
	_disabled = true
	_show_tooltip = true

func _on_mouse_exited():
	if not _disabled:
		_FX.stop_glowing()
		clear_tooltip()
