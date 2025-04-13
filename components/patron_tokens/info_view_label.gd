extends RichTextLabel

func _ready():
	Global.patron_uses_changed.connect(_on_info_view_toggled)
	Global.patron_changed.connect(_on_info_view_toggled)
	Global.info_view_toggled.connect(_on_info_view_toggled)

const _FORMAT = "[center][color=#fffc40]%d[img=10x13]%s[/img][/color][/center]"
func _on_info_view_toggled() -> void:
	if not Global.patron:
		return
	
	if Global.info_view_active:
		text = _FORMAT % [Global.patron_uses, Global.patron.get_icon_path()]
		show()
	else:
		hide()
