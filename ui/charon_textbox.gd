extends BoxContainer

@onready var _TEXTBOX: Textbox = $Textbox

func _ready():
	assert(_TEXTBOX)
	Global.state_changed.connect(_on_state_changed)

func _on_state_changed() -> void:
	match(Global.state):
		Global.State.BEFORE_FLIP:
			_TEXTBOX.set_text("Flip...?")
		Global.State.AFTER_FLIP:
			_TEXTBOX.set_text("Payoff...")
		Global.State.SHOP:
			_TEXTBOX.set_text("New coins...?")
		Global.State.GAME_OVER:
			var victory = Global.coin_value >= Global.GOAL_COIN_VALUE
			_TEXTBOX.set_text("What? You win? How??" if victory else "Your soul is mine!")
