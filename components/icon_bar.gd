class_name IconBar
extends HBoxContainer

const MAX_ICONS_VISIBLE := 3
const _ICON_BAR_TIMER_KEY := "ICON_BAR_TIMER"
const _PAGE_TIME := 2.0

var _paging_enabled = true
var _page := 0

var _active_icons := []
var _ICONS := []

func _ready():
	for child in get_children():
		_ICONS.append(child)
	
	for child in get_children():
		if child is TooltipEmitter:
			child.tooltip_created.connect(disable_paging)
			child.tooltip_removed.connect(enable_paging)
	
	var timer = Global.create_timer(_ICON_BAR_TIMER_KEY, _PAGE_TIME)
	timer.timeout.connect(_on_timeout)

func activate_icon(icon) -> void:
	_active_icons.append(icon)
	_page = 0
	update_page()

func deactivate_icon(icon) -> void:
	_active_icons.erase(icon)
	icon.hide()

func update_icon(icon, is_active: bool) -> void:
	activate_icon(icon) if is_active else deactivate_icon(icon)

func disable_paging() -> void:
	_paging_enabled = false

func enable_paging() -> void:
	_paging_enabled = true

func _on_timeout() -> void:
	# if paging has been disabled, just exit
	if not _paging_enabled:
		return
	
	# move to the next page if necessary
	var n_pages = ceil(_active_icons.size() / float(MAX_ICONS_VISIBLE))
	if n_pages == 0:
		return # no icons to show at all
	
	_page = 0 if _page == n_pages - 1 else _page + 1
	
	update_page()
	
func update_page() -> void:
	var active_icon_index = 0
	for i in range(0, _ICONS.size()):
		if _ICONS[i] in _active_icons:
			if active_icon_index < _page * MAX_ICONS_VISIBLE or active_icon_index > _page * MAX_ICONS_VISIBLE + (MAX_ICONS_VISIBLE-1):
				_ICONS[i].hide()
			else:
				_ICONS[i].show()
			active_icon_index += 1
