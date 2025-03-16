extends RichTextLabel

@onready var _FX: FX = $FX
@onready var _TOOLTIP = $TooltipEmitter

func _ready():
	Global.flame_boost_changed.connect(_on_flame_changed)
	_FX.hide()

const _FORMAT = "[center][img=10x13]res://assets/icons/coin/prometheus_icon.png[/img]+%.1d%%[/center]"
const _TOOLTIP_STR = "All coins will land on (HEADS)\n+(FLAME_INCREASE)% more often."
func _on_flame_changed() -> void:
	text = _FORMAT % Global.flame_boost
	_TOOLTIP.set_tooltip(_TOOLTIP_STR) #need to reset here so (FLAME_INCREASE) updates
	
	var should_hide = Global.flame_boost <= 0.0 
	if not should_hide: # take up space in layout
		show()
	await _FX.fade_out(0.5) if should_hide else await _FX.fade_in(0.5)
	if should_hide: # hide so it does not occupy space in the layout
		hide() 
