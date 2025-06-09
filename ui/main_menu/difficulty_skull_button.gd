class_name DifficultySkull
extends BoxContainer

@export var difficulty: Global.Difficulty

signal selected

@onready var _UNVANQUISHED_UNSELECTED: TextureButton = $Unvanquished/Unselected
@onready var _UNVANQUISHED_SELECTED: TextureButton = $Unvanquished/Selected
@onready var _VANQUISHED_UNSELECTED: TextureButton = $Vanquished/Unselected
@onready var _VANQUISHED_SELECTED: TextureButton = $Vanquished/Selected

var _vanquished: bool = false
var _selected: bool = false

func _ready():
	assert(_UNVANQUISHED_UNSELECTED)
	assert(_UNVANQUISHED_SELECTED)
	assert(_VANQUISHED_UNSELECTED)
	assert(_VANQUISHED_SELECTED)
	
	_UNVANQUISHED_UNSELECTED.pressed.connect(_on_click)
	_VANQUISHED_UNSELECTED.pressed.connect(_on_click)
	
	_VANQUISHED_SELECTED.mouse_entered.connect(_on_mouse_entered)
	_VANQUISHED_UNSELECTED.mouse_entered.connect(_on_mouse_entered)
	_UNVANQUISHED_SELECTED.mouse_entered.connect(_on_mouse_entered)
	_UNVANQUISHED_UNSELECTED.mouse_entered.connect(_on_mouse_entered)

func _update_button_visibility() -> void:
	_UNVANQUISHED_UNSELECTED.visible = not _vanquished and not _selected
	_UNVANQUISHED_SELECTED.visible = not _vanquished and _selected
	_VANQUISHED_UNSELECTED.visible = _vanquished and not _selected
	_VANQUISHED_SELECTED.visible = _vanquished and _selected

func set_vanquished(is_vanquished: bool) -> void:
	_vanquished = is_vanquished
	_update_button_visibility()

func _on_click() -> void:
	if not _selected:
		Audio.play_sfx(SFX.DifficultySkullClicked)
	select()

func select() -> void:
	emit_signal("selected", self, difficulty)
	_selected = true
	_update_button_visibility()

func unselect() -> void:
	_selected = false
	_update_button_visibility()

func _on_mouse_entered():
	var props = UITooltip.Properties.new().direction(UITooltip.Direction.ABOVE).offset(size.y).anchor(get_global_rect().get_center())
	UITooltip.create(self, Global.difficulty_tooltip_for(difficulty), get_global_mouse_position(), get_tree().root, props)
	Audio.play_sfx(SFX.Hovered)
