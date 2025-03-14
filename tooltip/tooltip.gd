class_name UITooltip
extends MarginContainer

static var _TOOLTIP_SCENE = preload("res://tooltip/tooltip.tscn")


enum _TooltipSystemState {
	SHOW_ALL, HIDE_ALL, HIDE_AUTO
}

static var _SYSTEM_STATE: _TooltipSystemState = _TooltipSystemState.SHOW_ALL
static var _ALL_TOOLTIPS: Array[UITooltip] = []

# offset of the tooltip from the mouse
const _TOOLTIP_OFFSET := Vector2(-_MAX_WIDTH_THRESHOLD/2.0, 15)

# maximum width of a tooltip - note that tooltips can exceed this,
# but this is around where they will cap.
const _MAX_WIDTH_THRESHOLD := 180

const _FORMAT := "[center]%s[/center]"

enum Style {
	CLEAR, OPAQUE
}

var source # must be either Control, Area2D, or MouseWatcher
var style: Style
var manual_control: bool
var manual_mouse_position: Vector2

func get_label() -> RichTextLabel:
	var label = find_child("TooltipText")
	assert(label)
	return label

static func enable_all_tooltips():
	_SYSTEM_STATE = _TooltipSystemState.SHOW_ALL
	for tooltip in _ALL_TOOLTIPS:
		tooltip.visible = true

static func disable_all_tooltips():
	_SYSTEM_STATE = _TooltipSystemState.HIDE_ALL
	for tooltip in _ALL_TOOLTIPS:
		tooltip.visible = false

static func disable_automatic_tooltips():
	_SYSTEM_STATE = _TooltipSystemState.HIDE_AUTO
	for tooltip in _ALL_TOOLTIPS:
		tooltip.visible = tooltip.manual_control

static func clear_tooltips():
	for tooltip in _ALL_TOOLTIPS:
		tooltip.destroy_tooltip()
	_ALL_TOOLTIPS.clear()

static func clear_tooltip_for(src):
	for tooltip in _ALL_TOOLTIPS:
		if tooltip.source == src:
			tooltip.destroy_tooltip()
			_ALL_TOOLTIPS.erase(tooltip)

# call as: UITooltip.create(self, "tooltip txt", get_global_mouse_position(), get_tree().root)
# unfortunately this is a static function so it cannot call the last two parameters itself
# NOTE - Tooltips created by this function are automatically destroyed.
static func create(src, text: String, global_mouse_position: Vector2, scene_root: Node, tooltip_style: Style = Style.CLEAR) -> void:
	assert(src is Control or src is Area2D or src is MouseWatcher)
	
	# if there is already a tooltip for this control, update that tooltip's text instead
	for tooltip in _ALL_TOOLTIPS:
		if tooltip.source == src:
			tooltip.find_child("TooltipText").text = _FORMAT % text
			return
	
	var disconnect_source = func(tooltip: UITooltip):
		assert(tooltip.source != null)
		tooltip.source.mouse_exited.disconnect(tooltip.destroy_tooltip)
		tooltip.source.tree_exited.disconnect(tooltip.destroy_tooltip)
	
	var connect_source = func(tooltip: UITooltip):
		assert(tooltip.source != null)
		tooltip.source.mouse_exited.connect(tooltip.destroy_tooltip) # add a connect destroying this when mouse exits parent
		tooltip.source.tree_exiting.connect(tooltip.destroy_tooltip)# destroy tooltip when parent exits tree (ie parent is deleted)
	
	# if there is already a tooltip with identical text, change its source to this new control but don't generate a new one
	for tooltip in _ALL_TOOLTIPS:
		var label = tooltip.get_label()
		if label.text == text:
			# redo connects
			disconnect_source.call(tooltip)
			tooltip.source = src
			connect_source.call(tooltip)
			return
	
	var tooltip: UITooltip = _create(src, text, global_mouse_position, scene_root, tooltip_style)
	connect_source.call(tooltip)

static func create_manual(text: String, controlled_mouse_position, scene_root: Node, tooltip_style: Style = Style.CLEAR) -> UITooltip:
	var tooltip: UITooltip = _create(null, text, controlled_mouse_position, scene_root, tooltip_style, true)
	return tooltip

# call as UITooltip.create(self, "tooltip txt", get_global_mouse_position(), get_tree().root)
# NOTE - Tooltips created in this way must be manually deleted with destroy_tooltip.
static func _create(src, text: String, mouse_position: Vector2, scene_root: Node, tooltip_style: Style = Style.CLEAR, is_manual: bool = false) -> UITooltip:
	var tooltip: UITooltip = _TOOLTIP_SCENE.instantiate()
	assert(tooltip.get_child_count())
	
	tooltip.source = src
	tooltip.style = tooltip_style
	tooltip.manual_control = is_manual
	tooltip.manual_mouse_position = mouse_position
	
	var label = tooltip.get_label()
	
	# replace img tags with a single letter to help space them 
	# (for now, only works with small images)
	var text_no_tags = text
	while text_no_tags.find("[img]") != -1:
		var img_start = text_no_tags.find("[img]")
		var img_end = text_no_tags.find("[/img]")
		text_no_tags = text_no_tags.erase(text_no_tags.find("[img]"), img_end - img_start + 6)
		text_no_tags = text_no_tags.insert(img_start, "XX")
	
	# note - tags like bold will not work yet; need smarter handling RIGHT HERE if desired
	# see https://github.com/godotengine/godot-proposals/issues/5056 comments for a handler
	
	var font = tooltip.get_theme().get_default_font()
	var font_size = tooltip.get_theme().get_default_font_size()
	
	# the text does not contain \n, automatically break the text and format a nice tooltip.
	if not text_no_tags.contains("\n"):
		# calculate a reasonable tooltip size
		# basically, add words one at a time until we exceed the threshold. that's the length we want.
		# this fanciness guarantees that the first line in the tooltip is the longest, which looks nice
		var words = text_no_tags.split(" ", false)
		var first_line = ""
		for word in words:
			var text_length := font.get_string_size(first_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			if text_length > _MAX_WIDTH_THRESHOLD:
				break
			first_line += word + " "

		label.custom_minimum_size.x = font.get_string_size(first_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
#	# otherwise set the tooltip size based on the longest line
#	else:
#		var longest_line_size = -1
#		for line in text_no_tags.split("\n"):
#			var line_size = tooltip.get_theme().get_default_font().get_string_size(line).x
#			if line_size > longest_line_size:
#				longest_line_size = line_size
#		label.custom_minimum_size.x = longest_line_size
		
	label.text = _FORMAT % text
	
	tooltip.position = mouse_position + _TOOLTIP_OFFSET
	scene_root.add_child(tooltip)
	
	_ALL_TOOLTIPS.append(tooltip)
	
	tooltip._force_position_onto_screen() # force position before performing scale...
	
	# pivot offset controls where we scale from
	tooltip.pivot_offset = tooltip.size/2.0
	tooltip.scale = Vector2(0.2, 0.2)
	tooltip.create_tween().tween_property(tooltip, "scale", Vector2(1.0, 1.0), 0.1)
	
	tooltip.modulate.a = 0.0
	tooltip.create_tween().tween_property(tooltip, "modulate:a", 0.95 if tooltip.style == Style.CLEAR else 1.0, 0.1)
	
	# set initial visibility based on if tooltips are enabled
	tooltip.visible = true if _SYSTEM_STATE == _TooltipSystemState.SHOW_ALL or (_SYSTEM_STATE == _TooltipSystemState.HIDE_AUTO and tooltip.manual_control) else false
	
	return tooltip

func _process(_delta):
	if not manual_control and not is_instance_valid(source):
		destroy_tooltip()
		return
	
	# problem - this code doesn't handle rotations at all, like at all.
	
	# HINT - common problem if tooltip appears but immediately vanishes; check size of the control carefully!
	var mouse_position = get_global_mouse_position() if not manual_control else manual_mouse_position
	if source != null and source is Control:
		if not Rect2(source.global_position, source.size).has_point(mouse_position):
			destroy_tooltip() # if the source has moved away from mouse, destroy the tooltip
	# $HACK$? - I guess we don't need this Area2D case - dunno, seems to work without it...
	#elif source is Area2D:
	#	var area = source as Area2D
	#	area.get_size
	position = Vector2(int(mouse_position.x), int(mouse_position.y)) + _TOOLTIP_OFFSET
	pivot_offset = size/2.0
	_force_position_onto_screen()

# $HACK$ - get_rect() is wrong because size is wrong...
func _get_real_rect():
	var real_rect = find_child("Layer").get_rect()
	real_rect.position = position
	return real_rect

# force the tooltip to be within the screen boundaries and not overlapping the mouse
func _force_position_onto_screen():
	# update position based on mouse position and screen position
	var mouse_position = get_global_mouse_position() if not manual_control else manual_mouse_position
	var viewport_rect = get_viewport_rect()

	#$HACK$ - idk why but Tooltip's y size is way larger than it should be, but this is right
	var real_size = find_child("Layer").size
	
	# if we are off the right of the screen, move left until that's no longer the case.
	while position.x + real_size.x > viewport_rect.size.x:
		position.x -= 1
		
	# if we are off the left of the screen, move right until that's no longer the case.
	while position.x < 0:
		position.x += 1
	
	# if we are off the bottom of the screen, move up until that's no longer the case.
	while position.y + real_size.y > viewport_rect.size.y:
		position.y -= 1
		
	# if we are off the top of the screen, move down until that's no longer the case.
	while position.y < 0:
		position.y += 1
	
#	# but now we might be overlapping the mouse, so move up until we aren't
	var shifted := false
	var hit_top := false
	while _get_real_rect().has_point(mouse_position):
		shifted = true
		position.y -= 1
		if position.y <= 0:
			hit_top = true
			break

	if shifted and not hit_top: # if we had to shift back up, go a bit more to match the same offset as normal
		position.y = max(0, position.y - _TOOLTIP_OFFSET.y) # clamp at 0 so we can't end up offscreen again

func destroy_tooltip():
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.05)
	_ALL_TOOLTIPS.erase(self)
	await fade_out.finished
	assert(is_instance_valid(self), "This tooltip has already been destroyed?")
	queue_free()
