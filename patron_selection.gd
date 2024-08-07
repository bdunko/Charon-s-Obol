extends Node2D

signal patron_selected

var _GODLESS_STATUE = preload("res://components/patron_statues/godless.tscn")

@onready var _STATUE_POSITION_LEFT = $PatronStatues/Left.position
@onready var _STATUE_POSITION_MIDDLE = $PatronStatues/Middle.position
@onready var _STATUE_POSITION_RIGHT = $PatronStatues/Right.position
@onready var _PATRON_STATUES = $PatronStatues
@onready var _SHIP_PATH_FOLLOW = $PeacefulBG/ShipPath/Follow

func _ready() -> void:
	assert(_STATUE_POSITION_LEFT)
	assert(_STATUE_POSITION_MIDDLE)
	assert(_STATUE_POSITION_RIGHT)
	assert(_PATRON_STATUES)
	assert(_SHIP_PATH_FOLLOW)
	
	var tween = create_tween().set_loops()
	tween.tween_property(_SHIP_PATH_FOLLOW, "progress_ratio", 1, 30).set_delay(2)
	tween.tween_property(_SHIP_PATH_FOLLOW, "progress_ratio", 0, 30).set_delay(5)

func _on_statue_clicked(statue: PatronStatue):
	Global.patron = Global.patron_for_enum(statue.patron_enum)
	emit_signal("patron_selected")

func _add_statue(statue_scene: PackedScene, statue_position: Vector2) -> void:
	var statue: PatronStatue = statue_scene.instantiate()
	statue.position = statue_position
	statue.clicked.connect(_on_statue_clicked)
	_PATRON_STATUES.add_child(statue)

func on_start() -> void:
	# delete the 3 existing god statues
	for statue in _PATRON_STATUES.get_children():
		statue.queue_free()
		statue.get_parent().remove_child(statue)
	
	# create the 3 new statues; third cannot equal first
	var first_patron = Global.choose_one(Global.PATRONS)
	_add_statue(first_patron.patron_statue, _STATUE_POSITION_LEFT)
	_add_statue(_GODLESS_STATUE, _STATUE_POSITION_MIDDLE)
	_add_statue(Global.choose_one_excluding(Global.PATRONS, [first_patron]).patron_statue, _STATUE_POSITION_RIGHT)
	

