extends Node2D

@onready var GAME_SCENE = $Game
@onready var MAIN_MENU_SCENE = $MainMenu
@onready var GOD_SELECTION_SCENE = $GodSelection

func _ready() -> void:
	assert(GAME_SCENE)
	assert(MAIN_MENU_SCENE)
	assert(GOD_SELECTION_SCENE)
	
func _on_main_menu_start_game():
	# bit of a $HACK$ to prevent double clicking on the start button
	if not TransitionPlayer.is_playing():
		await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_OUT)
		MAIN_MENU_SCENE.hide()
		await Global.delay(0.3)
		TransitionPlayer.play(TransitionPlayer.Effect.LABEL_FADE_IN)
		await Global.any_input
		await TransitionPlayer.play(TransitionPlayer.Effect.LABEL_FADE_OUT)
		await Global.delay(0.3)
		GOD_SELECTION_SCENE.on_start_god_selection()
		GOD_SELECTION_SCENE.show()
		await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_IN)

func _on_game_game_ended(victory: bool):
	if victory:
		TransitionPlayer.set_color(Color.WHITE)
	await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_OUT)
	await Global.delay(2.0)
	GAME_SCENE.hide()
	UITooltip.clear_tooltips() # fixes a small visual bug if you end with a tooltip up
	# if we won, show the victory screen
	if victory:
		GOD_SELECTION_SCENE.show()
		GOD_SELECTION_SCENE.on_victory()
	# otherwise go straight back to main menu
	else:
		MAIN_MENU_SCENE.show()
	await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_IN)
	TransitionPlayer.reset_color()

func _on_god_selection_patron_selected():
	TransitionPlayer.set_color(Color("793a80"))
	await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_OUT)
	await Global.delay(1.0)
	GOD_SELECTION_SCENE.hide()
	GAME_SCENE.on_start()
	GAME_SCENE.show()
	await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_IN)
	TransitionPlayer.reset_color()

func _on_god_selection_exited():
	await TransitionPlayer.play(TransitionPlayer.Effect.SLOW_FADE_OUT)
	await Global.delay(1.0)
	GOD_SELECTION_SCENE.hide()
	MAIN_MENU_SCENE.show()
	await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_IN)
