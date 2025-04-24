class_name TooltipComponent
extends MarginContainer

const _SUB_NINEPATCH_TEXTURE = preload("res://assets/ninepatch/sub_dialogue_9patch.png")
@onready var _NINE_PATCH = $NinePatchRect
@onready var _TEXT = $TextMargin/TooltipText

func _ready() -> void:
	assert(_TEXT)
	assert(_NINE_PATCH)

const BELOW_TOOLTIP_LR_MARGIN = 6

# this is a stupid hack but it's ok for now...
func subtooltip_style(direction: UITooltip.Direction) -> void:
	match direction:
		UITooltip.Direction.BELOW:
			self.set("theme_override_constants/margin_top", -1)
			# make it appear slightly smaller
			self.set("theme_override_constants/margin_left", BELOW_TOOLTIP_LR_MARGIN)
			self.set("theme_override_constants/margin_right", BELOW_TOOLTIP_LR_MARGIN)
			$NinePatchRect.texture = _SUB_NINEPATCH_TEXTURE
		UITooltip.Direction.RIGHT:
			self.set("theme_override_constants/margin_left", -1)
		_:
			assert(false)

func get_label() -> RichTextLabel:
	return $TextMargin/TooltipText
	
