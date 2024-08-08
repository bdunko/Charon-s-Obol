extends Node2D

signal patron_selected
signal exited

var _GODLESS_STATUE = preload("res://components/patron_statues/godless.tscn")

@onready var _STATUE_POSITION_LEFT = $PatronStatues/Left.position
@onready var _STATUE_POSITION_MIDDLE = $PatronStatues/Middle.position
@onready var _STATUE_POSITION_RIGHT = $PatronStatues/Right.position
@onready var _PATRON_STATUES = $PatronStatues
@onready var _SHIP_PATH_FOLLOW = $PeacefulBG/ShipPath/Follow

@onready var _WITHERED_BG = $WitheredBG
@onready var _PEACEFUL_BG = $PeacefulBG
@onready var _RAIN = $Rain

@onready var _VICTORY_TEXTBOXES = $VictoryTextboxes

func _ready() -> void:
	assert(_STATUE_POSITION_LEFT)
	assert(_STATUE_POSITION_MIDDLE)
	assert(_STATUE_POSITION_RIGHT)
	assert(_PATRON_STATUES)
	assert(_SHIP_PATH_FOLLOW)
	assert(_WITHERED_BG)
	assert(_PEACEFUL_BG)
	assert(_RAIN)
	assert(_VICTORY_TEXTBOXES)
	
	var tween = create_tween().set_loops()
	tween.tween_property(_SHIP_PATH_FOLLOW, "progress_ratio", 1, 30).set_delay(2)
	tween.tween_property(_SHIP_PATH_FOLLOW, "progress_ratio", 0, 30).set_delay(5)

func _on_statue_clicked(statue: PatronStatue):
	Global.patron = Global.patron_for_enum(statue.patron_enum)
	for statu in _PATRON_STATUES.get_children(): #prevent clicking on statues and tooltips
		statu.disable()
	emit_signal("patron_selected")

func _add_statue(statue_scene: PackedScene, statue_position: Vector2) -> void:
	var statue: PatronStatue = statue_scene.instantiate()
	statue.position = statue_position
	statue.clicked.connect(_on_statue_clicked)
	_PATRON_STATUES.add_child(statue)

func _make_background_peaceful() -> void:
	_RAIN.hide()
	_WITHERED_BG.hide()
	_PEACEFUL_BG.show()

func _make_background_withered() -> void:
	_RAIN.show()
	_WITHERED_BG.show()
	_PEACEFUL_BG.hide()

func on_victory() -> void:
	_make_background_peaceful()
	_VICTORY_TEXTBOXES.make_visible()

func on_start_god_selection() -> void:
	_make_background_withered()
	
	# delete the 3 existing god statues
	for statue in _PATRON_STATUES.get_children():
		statue.queue_free()
		statue.get_parent().remove_child(statue)
	
	# create the 3 new statues; third cannot equal first
	var first_patron = Global.choose_one(Global.PATRONS)
	_add_statue(first_patron.patron_statue, _STATUE_POSITION_LEFT)
	_add_statue(_GODLESS_STATUE, _STATUE_POSITION_MIDDLE)
	_add_statue(Global.choose_one_excluding(Global.PATRONS, [first_patron]).patron_statue, _STATUE_POSITION_RIGHT)
	
	_VICTORY_TEXTBOXES.make_invisible()

func _on_victory_continue_button_clicked():
	emit_signal("exited")
