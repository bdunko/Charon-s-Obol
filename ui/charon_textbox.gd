class_name CharonTextbox
extends BoxContainer

@onready var _TEXTBOX: Textbox = $Textbox

func _ready():
	assert(_TEXTBOX)

func _on_state_changed() -> void:
	match(Global.state):
		Global.State.BEFORE_FLIP:
			show_dialogue("Flip...?")
		Global.State.AFTER_FLIP:
			show_dialogue("Payoff...")
		Global.State.SHOP:
			show_dialogue("Buy or sell...?")
		Global.State.GAME_OVER:
			var victory = Global.coin_value >= Global.goal_coin_value
			show_dialogue("What? You win? How??" if victory else "Your soul is mine!")

#func _input(_event: InputEvent) -> void:
#	if Input.is_anything_pressed():
#		print("pressed")
#	else:
#		print("unpressed!")

func show_dialogue(dialogue: String) -> void:
	show()
	_TEXTBOX.set_text(dialogue)
	await Global.delay(0.1)
	hide()
