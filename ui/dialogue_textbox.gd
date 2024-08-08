class_name DialogueTextbox
extends BoxContainer

const _SCENE = preload("res://ui/dialogue_textbox.tscn")
static func create() -> DialogueTextbox:
	var textbox = _SCENE.instantiate()
	return textbox

@onready var _TEXTBOX: Textbox = $Textbox

# todo - add styling options to this for more generic usage
# text color
# border color
# can do this with shader easily

func _ready():
	assert(_TEXTBOX)

func set_text(dialogue: String) -> void:
	_TEXTBOX.set_text(dialogue)

func fade_and_free() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.parallel().tween_property(self, "scale", Vector2(0, 0), 0.1)
	tween.tween_callback(self.queue_free)

# make it drift up and down a bit
var _time = 0
func _process(delta) -> void:
	_time += delta * 3
	position.y += (4 * delta * sin(_time))
