class_name Main
extends Node2D

@onready var GAME_SCENE = $SubViewportContainer/SubViewport/Game
@onready var MAIN_MENU_SCENE = $SubViewportContainer/SubViewport/MainMenu
@onready var GOD_SELECTION_SCENE = $SubViewportContainer/SubViewport/GodSelection

func _ready() -> void:
	assert(GAME_SCENE)
	assert(MAIN_MENU_SCENE)
	assert(GOD_SELECTION_SCENE)
	
	Global.load_save() # load save file
	
	Audio.play_song(SoundDB.MAIN_MENU_BACKGROUND_SONG)
	
	if Global.is_character_unlocked(Global.Character.ELEUSINIAN):
		MAIN_MENU_SCENE.set_character(Global.Character.ELEUSINIAN)

func _on_main_menu_start_game():
	# bit of a $HACK$ to prevent double clicking on the start button
	if not TransitionPlayer.is_playing():
		await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_OUT)
		MAIN_MENU_SCENE.hide()
		await Global.delay(0.3)
		TransitionPlayer.set_text(Global.get_character_intro_text())
		TransitionPlayer.play(TransitionPlayer.Effect.LABEL_FADE_IN)
		await Global.left_click_input
		await TransitionPlayer.play(TransitionPlayer.Effect.LABEL_FADE_OUT)
		Audio.stop_song(SoundDB.MAIN_MENU_BACKGROUND_SONG)
		await Global.delay(0.3)
		if Global.is_character(Global.Character.LADY):
			# skip god selection during tutorial
			Global.patron = null
			_on_god_selection_patron_selected(true)
		else:
			GOD_SELECTION_SCENE.on_start_god_selection()
			GOD_SELECTION_SCENE.show()
			Audio.play_song(Songs.Thunderstorm)
			await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_IN)

func _on_game_game_ended(victory: bool):
	if victory:
		TransitionPlayer.set_color(Color.WHITE)
	await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_OUT)
	Audio.stop_song(Songs.HeavyWater)
	await Global.delay(2.0)
	GAME_SCENE.hide()
	UITooltip.clear_tooltips() # fixes a small visual bug if you end with a tooltip up
	
	# perform any coin unlock logic here based on the results of the game
	# queue any unlocks for the main menu
	if victory and Global.is_character(Global.Character.LADY):
		MAIN_MENU_SCENE.queue_unlocks([Global.APOLLO_FAMILY, Global.ARTEMIS_FAMILY, Global.HEPHAESTUS_FAMILY, Global.HADES_FAMILY, Global.Character.ELEUSINIAN])
	
	# if we beat a new highest difficulty, add the next difficulty unlock
	if victory and not Global.is_character(Global.Character.LADY):
		if Global.get_highest_difficulty_unlocked_for(Global.get_character()) == Global.difficulty:
			# we beat the highest difficulty we've unlocked, so unlock the next
			MAIN_MENU_SCENE.queue_unlocks(Global.UnlockedDifficulty.new(Global.get_character(), Global.difficulty + 1))
	
	# if we won, show the victory screen
	if victory:
		GOD_SELECTION_SCENE.show()
		GOD_SELECTION_SCENE.on_victory()
		Audio.play_song(Songs.VictoryBirds)
	# otherwise go straight back to main menu
	else:
		Audio.play_song(SoundDB.MAIN_MENU_BACKGROUND_SONG)
		MAIN_MENU_SCENE.show()
	await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_IN)
	TransitionPlayer.reset_color()

func _on_god_selection_patron_selected(lady: bool = false):
	if lady:
		await TransitionPlayer.play(TransitionPlayer.Effect.FADE_OUT)
	else:
		TransitionPlayer.set_color(Color("793a80"))
		await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_OUT)
		Audio.stop_song(Songs.Thunderstorm)
		await Global.delay(1.0)
	Audio.play_song(Songs.HeavyWater)
	GOD_SELECTION_SCENE.hide()
	GAME_SCENE.on_start()
	GAME_SCENE.show()
	await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_IN)
	TransitionPlayer.reset_color()

func _on_god_selection_exited():
	await TransitionPlayer.play(TransitionPlayer.Effect.SLOW_FADE_OUT)
	Audio.stop_song(Songs.VictoryBirds)
	await Global.delay(1.0)
	GOD_SELECTION_SCENE.hide()
	MAIN_MENU_SCENE.show()
	Audio.play_song(SoundDB.MAIN_MENU_BACKGROUND_SONG)
	await TransitionPlayer.play(TransitionPlayer.Effect.MODERATE_FADE_IN)
