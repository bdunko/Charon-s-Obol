extends Node2D

signal patron_selected
signal exited

@onready var _STATUE_POSITION_LEFT = $PatronStatues/Left.position
@onready var _STATUE_POSITION_MIDDLE = $PatronStatues/Middle.position
@onready var _STATUE_POSITION_RIGHT = $PatronStatues/Right.position
@onready var _PATRON_STATUES = $PatronStatues
@onready var _SHIP_PATH_FOLLOW = $PeacefulBG/ShipPath/Follow

@onready var _WITHERED_BG = $WitheredBG
@onready var _WITHERED_BG_FX = $WitheredBG/FX
@onready var _PEACEFUL_BG = $PeacefulBG
@onready var _RAIN = $Rain

@onready var _VICTORY_TEXTBOXES = $VictoryTextboxes
@onready var _VICTORY_DIALOGUE = $VictoryDialogueSystem
@onready var _PATRON_DIALOGUE = $PatronDialogueSystem
@onready var _PLAYER_DIALOGUE = $PlayerDialogueSystem
@onready var _CAMERA = $Camera

@onready var _FOG = $Fog

func _ready() -> void:
	assert(_STATUE_POSITION_LEFT)
	assert(_STATUE_POSITION_MIDDLE)
	assert(_STATUE_POSITION_RIGHT)
	assert(_PATRON_STATUES)
	assert(_SHIP_PATH_FOLLOW)
	assert(_WITHERED_BG)
	assert(_PEACEFUL_BG)
	assert(_FOG)
	assert(_RAIN)
	assert(_VICTORY_DIALOGUE)
	assert(_PATRON_DIALOGUE)
	assert(_PLAYER_DIALOGUE)
	assert(_VICTORY_TEXTBOXES)
	assert(_CAMERA)
	
	var tween = create_tween().set_loops()
	tween.tween_property(_SHIP_PATH_FOLLOW, "progress_ratio", 1, 30).set_delay(2)
	tween.tween_property(_SHIP_PATH_FOLLOW, "progress_ratio", 0, 30).set_delay(5)

func _on_statue_clicked(statue: PatronStatue):
	Global.patron = Global.patron_for_enum(statue.patron_enum)
	
	# disable all statues except the clicked one; which becomes disabled but show tooltip
	# UNLESS it is Godless, which also becomes disabled
	for statu in _PATRON_STATUES.get_children(): #prevent clicking on statues and tooltips
		if statu != statue or statu.patron_enum == Global.PatronEnum.GODLESS:
			statu.disable()
		else:
			statue.disable_except_tooltip()
		
	# if the statue was the godless, fade in the 'correct' statue over it.
	if statue.patron_enum == Global.PatronEnum.GODLESS:
		# don't let it be the same patron as one of the two real statues if godless
		while Global.patron.patron_enum == _PATRON_STATUES.get_child(0).patron_enum or Global.patron.patron_enum == _PATRON_STATUES.get_child(2).patron_enum:
			Global.patron = Global.patron_for_enum(statue.patron_enum)
		
		var new_statue = _add_statue(Global.patron.patron_statue, statue.position)
		new_statue.apply_spectral_fx()
		new_statue.disable_except_tooltip()
		new_statue._on_mouse_entered() #manually call this after adding; to show tooltip...
		statue.clear_fx()
	
	Audio.seamless_swap_song(Songs.Thunderstorm, Songs.ThunderstormFiltered)
	
	_PLAYER_DIALOGUE.clear_dialogue()
	await _PATRON_DIALOGUE.show_dialogue_and_wait("You have made a wise decision.")
	await _PATRON_DIALOGUE.show_dialogue_and_wait("We will do great things together.")
	await _PATRON_DIALOGUE.show_dialogue_and_wait("And now...")
	await _PATRON_DIALOGUE.show_dialogue_and_wait("We walk into darkness.")
	_WITHERED_BG_FX.disable() # disable the checker shader - looks a bit funny otherwise when zooming
	for statu in _PATRON_STATUES.get_children():
		statu.clear_tooltip()
		statu.disable() # prevent re-hovering on statue to show tooltip AGAIN...
	await create_tween().tween_property(_CAMERA, "zoom", Vector2(45, 45), 1.2).finished
	create_tween().tween_property(_CAMERA, "zoom", Vector2(90, 90), 1.2)
	await Global.delay(0.25)
	_PATRON_DIALOGUE.instant_clear_dialogue()
	emit_signal("patron_selected")

func _add_statue(statue_scene: PackedScene, statue_position: Vector2) -> PatronStatue:
	var statue: PatronStatue = statue_scene.instantiate()
	statue.position = statue_position
	statue.clicked.connect(_on_statue_clicked)
	_PATRON_STATUES.add_child(statue)
	return statue

func _make_background_peaceful() -> void:
	_RAIN.hide()
	_FOG.hide()
	_WITHERED_BG.hide()
	_PEACEFUL_BG.show()

func _make_background_withered() -> void:
	_RAIN.show()
	_FOG.show()
	_WITHERED_BG.show()
	_WITHERED_BG_FX.enable() # make sure the shader is enabled - might be disabled after zooming
	_PEACEFUL_BG.hide()

func _enable_and_reset_camera() -> void:
	_CAMERA.make_current()
	_CAMERA.zoom = Vector2(1, 1)

func on_victory() -> void:
	_enable_and_reset_camera()
	
	_VICTORY_TEXTBOXES.make_invisible()
	
	if Global.is_character(Global.Character.LADY):
		_make_background_withered()
		for statue in _PATRON_STATUES.get_children():
			statue.hide()
	else:
		_make_background_peaceful()
		assert(_PATRON_STATUES.get_child_count() == 3 or _PATRON_STATUES.get_child_count() == 4, "Impossible # statues?")
		for i in range(0, _PATRON_STATUES.get_child_count()):
			var statue: PatronStatue = _PATRON_STATUES.get_child(i)
			
			# hide the godless statue IFF it was selected (the 'true' statue is the fourth and will be shown instead)
			if _PATRON_STATUES.get_child_count() == 4 and statue.patron_enum == Global.PatronEnum.GODLESS:
				statue.hide()
			
			statue.disable()
			statue.clear_fx()
	
	for line in Global.get_character_victory_dialogue():
		await _VICTORY_DIALOGUE.show_dialogue_and_wait(line)
	_VICTORY_DIALOGUE.show_dialogue(Global.get_character_victory_closing_line())
	
	_VICTORY_TEXTBOXES.make_visible()

func on_start_god_selection() -> void:
	_enable_and_reset_camera()
	_make_background_withered()
	
	# delete the 3 existing god statues
	for statue in _PATRON_STATUES.get_children():
		statue.queue_free()
		statue.get_parent().remove_child(statue)
	
	# create the 3 new statues; third cannot equal first
	var first_patron = Global.choose_one(Global.PATRONS)
	_add_statue(first_patron.patron_statue, _STATUE_POSITION_LEFT)
	_add_statue(Global.statue_scene_for_patron_enum(Global.PatronEnum.GODLESS), _STATUE_POSITION_MIDDLE)
	_add_statue(Global.choose_one_excluding(Global.PATRONS, [first_patron]).patron_statue, _STATUE_POSITION_RIGHT)
	
	_VICTORY_DIALOGUE.instant_clear_dialogue()
	_VICTORY_TEXTBOXES.make_invisible()
	
	_PLAYER_DIALOGUE.show_dialogue("One last prayer...")

func _on_victory_continue_button_clicked():
	emit_signal("exited")
