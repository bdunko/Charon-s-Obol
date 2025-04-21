class_name TooltipComponent
extends MarginContainer

@onready var _TEXT = $TextMargin/TooltipText

func _ready() -> void:
	assert(_TEXT)

func set_text(text: String) -> void:
	# $HACK$ hasn't been added to scene yet...
	$TextMargin/TooltipText.text = text

# this is a stupid hack but maybe it works idk
func subtooltip_style(direction: UITooltip.Direction) -> void:
	match direction:
		UITooltip.Direction.BELOW:
			self.set("theme_override_constants/margin_top", -1)
		UITooltip.Direction.RIGHT:
			self.set("theme_override_constants/margin_left", -1)
		_:
			assert(false)
	
