extends Textbox

var _base_text := ""
var _QUOTA_FORMAT = "%s (%d/%d[img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img])"

func _ready() -> void:
	super._ready()
	Global.state_changed.connect(_on_state_changed)
	Global.souls_earned_this_round_changed.connect(_on_souls_earned_this_round_changed)
	_base_text = get_text()

func _on_state_changed() -> void:
	if Global.state == Global.State.BEFORE_FLIP:
		show()
	else:
		hide()

func _on_souls_earned_this_round_changed() -> void:
	var quota = Global.current_round_quota()
	if quota != 0:
		set_text(_QUOTA_FORMAT % [_base_text, Global.souls_earned_this_round, quota])
	else:
		set_text(_base_text)
