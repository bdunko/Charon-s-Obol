extends Node2D

signal patron_selected

var _GODLESS_STATUE = preload("res://components/patrons/godless.tscn")
var _STATUES = [preload("res://components/patrons/zeus.tscn")]

@onready var _STATUE_POSITION_LEFT = $PatronStatues/Left.position
@onready var _STATUE_POSITION_MIDDLE = $PatronStatues/Middle.position
@onready var _STATUE_POSITION_RIGHT = $PatronStatues/Right.position
@onready var _PATRON_STATUES = $PatronStatues

func _ready() -> void:
	assert(_STATUE_POSITION_LEFT)
	assert(_STATUE_POSITION_MIDDLE)
	assert(_STATUE_POSITION_RIGHT)
	assert(_PATRON_STATUES)

func _on_statue_clicked(statue: PatronStatue):
	Global.patron = Global.patron_for_power(statue.patron_power)
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
	
	# create the 3 new statues
	_add_statue(Global.choose_one(_STATUES), _STATUE_POSITION_LEFT)
	_add_statue(_GODLESS_STATUE, _STATUE_POSITION_MIDDLE)
	_add_statue(Global.choose_one(_STATUES), _STATUE_POSITION_RIGHT)
	

