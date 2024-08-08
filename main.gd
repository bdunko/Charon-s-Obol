extends Node2D

@onready var GAME_SCENE = $Game
@onready var MAIN_MENU_SCENE = $MainMenu
@onready var GOD_SELECTION_SCENE = $GodSelection

func _ready() -> void:
	assert(GAME_SCENE)
	assert(MAIN_MENU_SCENE)
	assert(GOD_SELECTION_SCENE)
	

func _on_main_menu_start_pressed():
	# todo - transition
	MAIN_MENU_SCENE.hide()
	GOD_SELECTION_SCENE.on_start_god_selection()
	GOD_SELECTION_SCENE.show()
	# todo - transition

func _on_game_game_ended(victory: bool):
	# todo - transition
	GAME_SCENE.hide()
	
	# if we won, show the victory screen
	if victory:
		GOD_SELECTION_SCENE.on_victory()
		GOD_SELECTION_SCENE.show()
	# otherwise go straight back to main menu
	else:
		MAIN_MENU_SCENE.show()
	# todo - transition

func _on_god_selection_patron_selected():
	# todo - transition
	GOD_SELECTION_SCENE.hide()
	GAME_SCENE.on_start()
	GAME_SCENE.show()
	# todo - transition

func _on_god_selection_exited():
	# todo - transition
	GOD_SELECTION_SCENE.hide()
	MAIN_MENU_SCENE.show()
	# todo - transition
