# DebugSoundTester
# ----------------
# This tool is designed to speed up iteration and testing of sound effects in-game.
# It allows you to:
#   - Load organized groups of sounds from disk
#   - Cycle through them using hotkeys
#   - Play the current sound manually at any time
#   - Intercept and override specific SFX.Effect-based sound playback via the Audio manager

# 📁 SOUND FILE STRUCTURE
# Debug sound files should be placed in subfolders under: `res://assets/audio/debug`
# Each subfolder becomes a *sound group*, containing one or more audio files:
#
#   Example:
#     res://assets/audio/debug/
#       ├── CoinFlipped/
#       │     ├── coin1.wav
#       │     ├── coin2.wav
#       ├── UIError/
#       │     ├── error_click.wav
#       │     ├── error_click2.wav
#
# All .wav, .ogg, or .mp3 files are automatically loaded at startup into their respective groups.

# 🧠 OVERRIDE LOGIC
# The DebugSoundTester will override Audio.play_sfx(effect) if:
#   1. The system is ENABLED (`const ENABLED = true`), and
#   2. The effect is listed in the `target_effects` array, OR
#   3. The name of the current sound group matches (case-insensitive substring) the effect.name

# 🧪 Example: 
#   To override only the SFX.CoinFlipped effect during testing, either:
#     - Add it to `target_effects`, OR
#     - Name the folder containing your debug sounds "CoinFlipped"

# This script is intended for developer use only and should not be shipped in release builds.

extends Node

@onready var player = $AudioStreamPlayer
@onready var label = $FeedbackLabel
@onready var help_label = $HelpLabel

const ENABLED = true

const ROOT_DIR := "res://assets/audio/debug"
const LABEL_DISPLAY_DURATION := 1.2
const FADE_DURATION := 0.2

var target_effects: Array[SFX.Effect] = []

var sound_groups: Dictionary = {}    # group_name -> Array[AudioStream]
var group_names: Array[String] = []  # ordered list of group names
var current_group_index := 0
var current_index := 0

var label_tween: Tween = null
var help_tween: Tween = null

func _ready():
	# Example: override only the coin flip effect
	target_effects = []
	# Optional: print what we're overriding
	for effect in target_effects:
		print("Overriding SFX.Effect: ", effect.name)

	load_all_sound_groups()
	label.visible = false
	help_label.visible = false
	label.modulate.a = 0.0
	help_label.modulate.a = 0.0
	show_help()
	print("DebugSoundTester loaded groups: ", group_names)


func _input(event):
	if event.is_action_pressed("debug_play_sound"):
		play_current()
	elif event.is_action_pressed("debug_next_sound"):
		cycle_sound(1)
	elif event.is_action_pressed("debug_prev_sound"):
		cycle_sound(-1)
	elif event.is_action_pressed("debug_next_group"):
		cycle_group(1)
	elif event.is_action_pressed("debug_prev_group"):
		cycle_group(-1)



func load_all_sound_groups():
	var root_dir = DirAccess.open(ROOT_DIR)
	if not root_dir:
		push_error("Could not open root sound directory: " + ROOT_DIR)
		return

	group_names.clear()
	sound_groups.clear()

	for group_name in root_dir.get_directories():
		var group_path = ROOT_DIR + "/" + group_name
		var dir = DirAccess.open(group_path)
		if not dir:
			continue
		var sounds := []
		for file in dir.get_files():
			if file.get_extension().to_lower() in ["ogg", "wav", "mp3"]:
				var path = group_path + "/" + file
				var stream = load(path)
				if stream:
					sounds.append(stream)
		if sounds.size() > 0:
			sound_groups[group_name] = sounds
			group_names.append(group_name)

	if group_names.size() == 0:
		push_warning("No sound groups found in " + ROOT_DIR)

func get_current_group_name() -> String:
	return group_names[current_group_index] if current_group_index < group_names.size() else ""

func get_current_group_sounds() -> Array:
	return sound_groups.get(get_current_group_name(), [])

func play_current():
	var sounds = get_current_group_sounds()
	if sounds.size() == 0:
		push_warning("No sounds loaded in current group.")
		return
	player.stream = sounds[current_index]
	player.play()

	var filename = player.stream.resource_path.get_file()
	show_label("Playing: %s [%d/%d]" % [
		filename, current_index + 1, sounds.size()
	])


func cycle_sound(direction := 1):
	var sounds = get_current_group_sounds()
	if sounds.size() == 0:
		return
	current_index = (current_index + direction + sounds.size()) % sounds.size()

	var filename = sounds[current_index].resource_path.get_file()
	show_label("Switched: %s [%d/%d]" % [
		filename, current_index + 1, sounds.size()
	])

func cycle_group(direction := 1):
	if group_names.is_empty():
		return
	current_group_index = (current_group_index + direction + group_names.size()) % group_names.size()
	current_index = 0
	show_label("Switched to group: %s" % get_current_group_name())

func show_label(text: String):
	if label.text == text and label.visible:
		return  # Don't re-tween if the label is already showing the same text

	label.text = text
	label.visible = true
	label.modulate.a = 0.0

	if label_tween and label_tween.is_running():
		label_tween.kill()

	label_tween = create_tween()
	label_tween.tween_property(label, "modulate:a", 1.0, FADE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	label_tween.tween_interval(LABEL_DISPLAY_DURATION)
	label_tween.tween_property(label, "modulate:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	label_tween.tween_callback(Callable(self, "_hide_label"))


func _hide_label():
	label.visible = false

func show_help():
	help_label.visible = true
	help_label.modulate.a = 0.0

	if help_tween and help_tween.is_running():
		help_tween.kill()

	help_tween = create_tween()
	help_tween.tween_property(help_label, "modulate:a", 1.0, FADE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	help_tween.tween_interval(4.0)
	help_tween.tween_property(help_label, "modulate:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	help_tween.tween_callback(Callable(self, "_hide_help"))

func _hide_help():
	help_label.visible = false

# Useful API for hooking into audio manager:
func should_override(effect: SFX.Effect) -> bool:
	return ENABLED and (
		target_effects.has(effect)
		or get_current_group_name().to_lower() in effect.name.to_lower()
	)


func get_current_stream() -> AudioStream:
	var sounds = get_current_group_sounds()
	return sounds[current_index] if current_index < sounds.size() else null
