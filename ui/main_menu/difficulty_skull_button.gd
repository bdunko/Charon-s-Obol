class_name DifficultySkull
extends BoxContainer

@export var difficulty: Global.Difficulty

signal selected

@onready var _UNVANQUISHED_UNSELECTED: TextureButton = $Unvanquished/Unselected
@onready var _UNVANQUISHED_SELECTED: TextureButton = $Unvanquished/Selected
@onready var _VANQUISHED_UNSELECTED: TextureButton = $Vanquished/Unselected
@onready var _VANQUISHED_SELECTED: TextureButton = $Vanquished/Selected

#TODO - hook this up once we store vanquished status somewhere per character
var _vanquished: bool = false
var _selected: bool = false

func _ready():
	#assert(_SKULL)
	#assert(_VANQUISHED)
	_UNVANQUISHED_UNSELECTED.pressed.connect(select)
	_VANQUISHED_SELECTED.pressed.connect(select)

func _update_button_visibility() -> void:
	_UNVANQUISHED_UNSELECTED.visible = not _vanquished and not _selected
	_UNVANQUISHED_SELECTED.visible = not _vanquished and _selected
	_VANQUISHED_UNSELECTED.visible = _vanquished and not _selected
	_VANQUISHED_SELECTED.visible = _vanquished and _selected	

func select() -> void:
	emit_signal("selected", self, difficulty)
	_selected = true
	_update_button_visibility()

func unselect() -> void:
	_selected = false
	_update_button_visibility()
