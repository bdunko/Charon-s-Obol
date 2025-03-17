extends RichTextLabel

@onready var _FX: FX = $FX
@onready var _TOOLTIP = $TooltipEmitter

func _ready():
	Global.ignite_damage_changed.connect(_on_ignite_changed)
	_FX.hide()

const _FORMAT = "[center][img=10x13]res://assets/icons/status/ignite_icon.png[/img]+%d[/center]"
const _TOOLTIP_STR = "(IGNITE) damage is increased\nby +(IGNITE_INCREASE)."
func _on_ignite_changed() -> void:
	text = _FORMAT % (Global.ignite_damage - Global.DEFAULT_IGNITE_DAMAGE)
	_TOOLTIP.set_tooltip(_TOOLTIP_STR) #need to reset here so (FLAME_INCREASE) updates
	
	var should_hide = Global.ignite_damage == Global.DEFAULT_IGNITE_DAMAGE
	if not should_hide: # take up space in layout
		show()
	await _FX.fade_out(0.5) if should_hide else await _FX.fade_in(0.5)
	if should_hide:
		hide()
