class_name TooltipComponent
extends MarginContainer

const _STATUS_NINEPATCH_TEXTURE = preload("res://assets/ninepatch/status_9patch.png")
const _UPGRADE_NINEPATCH_TEXTURE = preload("res://assets/ninepatch/upgrade_9patch.png")

@onready var _NINE_PATCH = $NinePatchRect
@onready var _TEXT = $TextMargin/TooltipText
@onready var _ARROW_ADORNMENT = $ArrowAdornment

var _adornment

func _ready() -> void:
	assert(_TEXT)
	assert(_NINE_PATCH)
	assert(_ARROW_ADORNMENT)
	
	if _adornment == UITooltip.SubTooltip.Adornment.ARROW:
		_ARROW_ADORNMENT.show()
		_ARROW_ADORNMENT.position.y = (size.y / 2.0) - (_ARROW_ADORNMENT.get_rect().size.y / 2.0)

const BELOW_TOOLTIP_LR_MARGIN = 6

# this is a stupid hack but it's ok for now...
func subtooltip_style(direction: UITooltip.Direction, adornment: UITooltip.SubTooltip.Adornment) -> void:
	match direction:
		UITooltip.Direction.BELOW:
			self.set("theme_override_constants/margin_top", -1)
			# make it appear slightly smaller
			self.set("theme_override_constants/margin_left", BELOW_TOOLTIP_LR_MARGIN)
			self.set("theme_override_constants/margin_right", BELOW_TOOLTIP_LR_MARGIN)
			$NinePatchRect.texture = _STATUS_NINEPATCH_TEXTURE
		UITooltip.Direction.RIGHT:
			self.set("theme_override_constants/margin_left", -1)
			$NinePatchRect.texture = _UPGRADE_NINEPATCH_TEXTURE
		_:
			assert(false)
	_adornment = adornment

func get_label() -> RichTextLabel:
	return $TextMargin/TooltipText

func set_label_custom_minimum_size(cms: Vector2) -> void:
	$TextMargin/TooltipText.custom_minimum_size = cms
