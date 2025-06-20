class_name DebugConsole
extends LineEdit

signal debug_console_opened
signal debug_console_closed

var active
const SUCCESS_COLOR = Color.GREEN
const FAIL_COLOR = Color.RED
const DEFAULT_COLOR = Color.WHITE

var main_scene: Main = null
var last_command = null

func _ready():
	active = false
	self.visible = false
	self.set("theme_override_colors/font_color", DEFAULT_COLOR)
	main_scene = get_tree().get_root().get_node("Main")
	assert(main_scene != null)

func _input(_event):
	if Global.DEBUG_CONSOLE:
		if Input.is_action_just_released("open_debug_console"):
			_toggle()

func _toggle():
	self.text = ""
	active = not active
	self.visible = active
	if active:
		emit_signal("debug_console_opened")
		self.grab_focus()
	else:
		emit_signal("debug_console_closed")

func _on_debug_console_closed() -> void:
	assert(get_tree().paused == true)
	get_tree().paused = false

func _on_debug_console_opened() -> void:
	assert(get_tree().paused == false)
	get_tree().paused = true

# this param is 'txt' on purpose; because 'text' is already a field of the LineEdit
func _on_text_submitted(txt):
	assert(active)
	assert(main_scene)
	
	var game = main_scene.GAME_SCENE
	var coin_row = game._COIN_ROW
	var enemy_coin_row = game._ENEMY_COIN_ROW
	var main_menu = main_scene.MAIN_MENU_SCENE
	var god_selection = main_scene.GOD_SELECTION_SCENE
	
	assert(game)
	assert(main_menu)
	assert(god_selection)
	assert(coin_row)
	
	# souls (#)				<- gain # souls
	# life (#)				<- gain # life
	# arrows (#)			<- gain # arrows
	# kill					<- kill self
	# clear					<- destroys all of your coins but leftmost
	# clearm				<- destroys monsters
	# patron "NAME"			<- set patron to NAME
	# monster "NAME"		<- spawn monster NAME (Tetrobol)
	# monster "NAME" (#)	<- spawn monster NAME (Tetrobol)
	# coin "NAME"			<- gain coin NAME (Tetrobol)
	# coin "NAME" (#) 		<- gain coin with denom (1-4) and NAME
	
	var args = txt.to_lower().split(" ")
	var cmd = args[0]
	print("Debug Command: " + str(args))
	
	var success = true
	
	# close the application immediately
	if cmd == "exit" or cmd == "quit" or cmd == "q":
		get_tree().quit()
	# print hello world :)
	elif cmd == "helloworld" or cmd == "hello":
		print("Hello World!") 
	# cause an immediate breakpoint
	elif cmd == "break" or cmd == "breakpoint" or cmd == "b" or cmd == "brk":
		breakpoint
	elif cmd == "soul" or cmd == "souls":
		if not args.size() == 2:
			success = false
		else:
			var amt = int(args[1])
			Global.lose_souls(amt) if amt < 0 else Global.earn_souls(amt)
	elif cmd == "life" or cmd == "lives" or cmd == "live":
		if not args.size() == 2:
			success = false
		else:
			var amt = int(args[1])
			if amt > 0:
				Global.heal_life(amt)
			else:
				Global.lives += amt
	elif cmd == "arrows" or cmd == "arrow":
		if not args.size() == 2:
			success = false
		else:
			Global.arrows += int(args[1])
	elif cmd == "malice":
		if not args.size() == 2:
			success = false
		else:
			Global.malice = max(0, int(args[1]))
	elif cmd == "kill":
		Global.lives = -1
	elif cmd == "clear" or cmd == "wipe" or cmd == "destroy" or cmd == "clearall" or cmd == "destroyall":
		while coin_row.get_child_count() != 1: 
			game.destroy_coin(coin_row.get_rightmost_to_leftmost()[0])
	elif cmd == "clearm" or cmd == "clearmonsters" or cmd == "clearmon" or cmd == "clearmn":
		while enemy_coin_row.get_child_count() != 0:
			game.destroy_coin(enemy_coin_row.get_leftmost_to_rightmost()[0])
	elif cmd == "patron" or cmd == "token":
		if not args.size() == 2:
			success = false
		else:
			var found = false
			for patron in Global.PatronEnum.keys():
				if patron.to_lower().contains(args[1].to_lower()):
					Global.patron = Global.patron_for_enum(Global.PatronEnum[patron])
					game._make_patron_token()
					Global.patron_uses = Global.patron.get_uses_per_round()
					found = true
					break
			success = found
	elif cmd == "monster" or cmd == "spawnmonster" or cmd == "spawn" or cmd == "enemy" or cmd == "spawnenemy" or cmd == "trial" or cmd == "nemesis":
		if not (args.size() == 2 or args.size() == 3):
			success = false
		else:
			var denom = Global.Denomination.PENTOBOL #this gets -1'd to tetrobol - ugly but w/e
			if args.size() == 3:
				denom = clamp(int(args[2]), 1, 6)
			
			# search all monsters and trials...
			var found = false
			if "cerberus".contains(args[1].to_lower()):
				game.spawn_enemy(Global.CERBERUS_LEFT_FAMILY, denom-1)
				game.spawn_enemy(Global.CERBERUS_MIDDLE_FAMILY, denom-1)
				game.spawn_enemy(Global.CERBERUS_RIGHT_FAMILY, denom-1)
				found = true
			else:
				for monster_or_trial in Global._ALL_MONSTER_AND_TRIAL_COINS:
					var coin_name = monster_or_trial.coin_name.to_lower()
					# strip [color=###]
					coin_name = coin_name.get_slice("]", 1)
					
					if coin_name.contains(args[1].to_lower()):
						game.spawn_enemy(monster_or_trial, denom-1)
						found = true
						break
			success = found
	elif cmd == "coin" or cmd == "gain" or cmd == "gaincoin" or cmd == "give" or cmd == "givecoin" or cmd == "get" or cmd == "getcoin":
		if not (args.size() == 2 or args.size() == 3):
			success = false
		elif coin_row.get_child_count() == Global.COIN_LIMIT:
			success = false
		else: 
			var denom = Global.Denomination.TETROBOL #this gets -1'd to tetrobol - ugly but w/e
			if args.size() == 3:
				denom = clamp(int(args[2]), 1, 6)
			# special case thorns
			if args[1].to_lower() == "thorn" or args[1].to_lower() == "thorns":
				game.make_and_gain_coin(Global.THORNS_FAMILY, denom-1, game._PLAYER_NEW_COIN_POSITION)
			elif args[1].to_lower() == "common" or args[1].to_lower() == "obol" or args[1].to_lower() == "generic" or args[1].to_lower() == "money" or args[1].to_lower() == "coin":
				game.make_and_gain_coin(Global.GENERIC_FAMILY, denom-1, game._PLAYER_NEW_COIN_POSITION)
			else:
				# search all coins...
				var made = false
				for coin in Global._ALL_PLAYER_COINS:
					var coin_name = coin.coin_name.to_lower()
					coin_name = coin_name.replace("(denom)", "").replace("of", "").replace(" ", "")
					if coin_name.begins_with(args[1].to_lower()):
						game.make_and_gain_coin(coin, denom-1, game._PLAYER_NEW_COIN_POSITION)
						made = true
						break
				success = made
	elif cmd == "setup":
		# clear everything
		while coin_row.get_child_count() != 1: 
			game.destroy_coin(coin_row.get_rightmost_to_leftmost()[0])
		game.make_and_gain_coin(Global.ZEUS_FAMILY, Global.Denomination.DRACHMA, game._PLAYER_NEW_COIN_POSITION)
		game.make_and_gain_coin(Global.ZEUS_FAMILY, Global.Denomination.DRACHMA, game._PLAYER_NEW_COIN_POSITION)
		game.make_and_gain_coin(Global.ZEUS_FAMILY, Global.Denomination.DRACHMA, game._PLAYER_NEW_COIN_POSITION)
		game.make_and_gain_coin(Global.ZEUS_FAMILY, Global.Denomination.DRACHMA, game._PLAYER_NEW_COIN_POSITION)
		game.make_and_gain_coin(Global.ZEUS_FAMILY, Global.Denomination.DRACHMA, game._PLAYER_NEW_COIN_POSITION)
		game.make_and_gain_coin(Global.HEPHAESTUS_FAMILY, Global.Denomination.DRACHMA, game._PLAYER_NEW_COIN_POSITION)
		game.make_and_gain_coin(Global.HERMES_FAMILY, Global.Denomination.DRACHMA, game._PLAYER_NEW_COIN_POSITION)
		game.make_and_gain_coin(Global.HADES_FAMILY, Global.Denomination.DRACHMA, game._PLAYER_NEW_COIN_POSITION)

	# repeat the previous command
	elif last_command != null and (cmd == "r" or cmd == "repeat"):
		_on_text_submitted(last_command)
	else:
		success = false
	
	if cmd != "r" and cmd != "repeat":
		self.last_command = txt
	self.set("theme_override_colors/font_color", SUCCESS_COLOR if success else FAIL_COLOR)
	self.clear()
