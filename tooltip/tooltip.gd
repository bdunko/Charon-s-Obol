class_name UITooltip
extends MarginContainer

enum _TooltipSystemState {
	SHOW_ALL, HIDE_ALL, HIDE_AUTO
}
static var _SYSTEM_STATE: _TooltipSystemState = _TooltipSystemState.SHOW_ALL
static var _TOOLTIP_SCENE = preload("res://tooltip/tooltip.tscn")
static var _TOOLTIP_COMPONENT_SCENE = preload("res://tooltip/tooltip_component.tscn")
static var _ALL_TOOLTIPS: Array[UITooltip] = []

const _FORCE_MOVE_OFF_OF_MOUSE = false

# because we are rendering the game in a different viewport from the tooltips, we need to scale
# all coordinates from the game into global coordinates.
# ex: game is 320x180; object located at 100x100 and size 10x10
# base viewport resolution is 640x360, 2x as large
# in 'global' (base viewport) coords, the game object is at 200x200 and size 20x20.
const _SCALE_FACTOR = 2

# Maximum width of a tooltip.
const _MAXIMUM_WIDTH = 180
# Additional buffer added to longest line when using a tooltip with width below the maximum.
const _BUFFER = 28

const _FORMAT := "[center]%s[/center]"

@onready var _MAIN_TOOLTIP = $Grid/MainTooltip

enum Direction {
	LEFT, RIGHT, ABOVE, BELOW, CENTERED
}

enum Style {
	CLEAR, OPAQUE
}

var source # must be either Control, Area2D, or MouseWatcher
var manual_control: bool
var manual_mouse_position: Vector2
var properties: Properties

const DEFAULT_OFFSET = 12
const DEFAULT_DIRECTION = Direction.BELOW
const NO_ANCHOR = Vector2(-18888, -18888)
class Properties:
	var _style: Style = Style.OPAQUE
	var _direction: Direction = DEFAULT_DIRECTION
	var _anchor: Vector2 = NO_ANCHOR
	var _offset: int = DEFAULT_OFFSET
	var _subtooltips = []
	
	func _init() -> void:
		pass
	
	func style(tt_style: Style) -> Properties:
		_style = tt_style
		return self
	
	func direction(tt_direction: Direction) -> Properties:
		_direction = tt_direction
		return self
	
	func anchor(tt_anchor: Vector2) -> Properties:
		_anchor = tt_anchor * _SCALE_FACTOR
		return self
	
	func offset(tt_offset: int) -> Properties:
		_offset = tt_offset
		return self
	
	func sub(text, direction = DEFAULT_SUBTOOLTIP_DIRECTION) -> Properties:
		_subtooltips.append(SubTooltip.new(text, direction))
		return self

const DEFAULT_SUBTOOLTIP_DIRECTION = Direction.BELOW
class SubTooltip:
	var _direction: Direction
	var _text: String
	
	func _init(text: String, direction: Direction) -> void:
		assert(direction == Direction.BELOW or direction == Direction.RIGHT, "We don't support other directions.")
		_text = text
		_direction = direction

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
static func create(src, text: String, global_mouse_position: Vector2, scene_root: Node, props: Properties = Properties.new()) -> void:
	assert(src is Control or src is Area2D or src is MouseWatcher)
	
	global_mouse_position *= _SCALE_FACTOR
	
	# if there is already a tooltip for this control, update that tooltip's text instead
	for tooltip in _ALL_TOOLTIPS:
		if tooltip.source == src:
			tooltip._MAIN_TOOLTIP.set_text(_FORMAT % text)
			return
	
	var disconnect_source = func(ttip: UITooltip):
		assert(ttip.source != null)
		ttip.source.mouse_exited.disconnect(ttip.destroy_tooltip)
		ttip.source.tree_exited.disconnect(ttip.destroy_tooltip)
	
	var connect_source = func(ttip: UITooltip):
		assert(ttip.source != null)
		ttip.source.mouse_exited.connect(ttip.destroy_tooltip) # add a connect destroying this when mouse exits parent
		ttip.source.tree_exiting.connect(ttip.destroy_tooltip)# destroy tooltip when parent exits tree (ie parent is deleted)
	
	# if there is already a tooltip with identical text, change its source to this new control but don't generate a new one
	for tooltip in _ALL_TOOLTIPS:
		var label = tooltip.get_label()
		if label.text == text:
			# redo connects
			disconnect_source.call(tooltip)
			tooltip.source = src
			connect_source.call(tooltip)
			return
	
	var tooltip: UITooltip = _create(src, text, global_mouse_position, scene_root, props)
	connect_source.call(tooltip)

# NOTE - Tooltips created in this way must be manually deleted with destroy_tooltip.
static func create_manual(text: String, controlled_mouse_position, scene_root: Node, props: Properties = Properties.new()) -> UITooltip:
	var tooltip: UITooltip = _create(null, text, controlled_mouse_position, scene_root, props, true)
	return tooltip

static func _create_sub_tooltip(text: String, dir: Direction):
	var subtooltip = _TOOLTIP_COMPONENT_SCENE.instantiate()
	subtooltip.set_text(_FORMAT % text)
	subtooltip.subtooltip_style(dir)
	return subtooltip

static func _create(src, text: String, mouse_position: Vector2, scene_root: Node, props: Properties, is_manual: bool = false, ) -> UITooltip:
	var tooltip: UITooltip = _TOOLTIP_SCENE.instantiate()
	assert(tooltip.get_child_count())
	
	tooltip.source = src
	tooltip.properties = props
	tooltip.manual_control = is_manual
	tooltip.manual_mouse_position = mouse_position
	
	# Step 1 - Calculate tooltip width.
	# Replace img tag with XXX to help space them (this only works because most of our images are pretty small.
	var text_no_tags = text
	while text_no_tags.find("[img") != -1:
		var img_start = text_no_tags.find("[img")
		var img_end = text_no_tags.find("[/img]")
		text_no_tags = text_no_tags.erase(text_no_tags.find("[img"), img_end - img_start + 6)
		text_no_tags = text_no_tags.insert(img_start, "XXX")
	# now also strip out all other bbcode
	text_no_tags = Global.strip_bbcode(text_no_tags)
	
	# find the longest line.
	var font = tooltip.get_theme().get_default_font()
	var font_size = tooltip.get_theme().get_default_font_size()
	var longest_line_size = -1
	for line in text_no_tags.split("\n"):
		var line_size = tooltip.get_theme().get_default_font().get_string_size(line).x
		if line_size > longest_line_size:
			longest_line_size = line_size
	
	# TODO REFACTOR THIS - call func son _MAIN_TOOLTIP instead
	var label = tooltip.find_child("TooltipText")
	label.custom_minimum_size.x = min(_MAXIMUM_WIDTH, longest_line_size + _BUFFER)
	label.text = _FORMAT % text
	
	scene_root.add_child(tooltip)
	_ALL_TOOLTIPS.append(tooltip)
	
	# create subtooltips
	for subtooltip in props._subtooltips:
		print("Making stt!")
		print(subtooltip._text)
		
		var stt = _create_sub_tooltip(subtooltip._text, subtooltip._direction)
		stt.find_child("TooltipText").custom_minimum_size.x = label.custom_minimum_size.x
		
		match subtooltip._direction:
			Direction.BELOW:
				tooltip.find_child("SubtooltipsBelow").add_child(stt)
			Direction.RIGHT:
				tooltip.find_child("SubtooltipsRight").add_child(stt)
				stt.find_child("TooltipText").custom_minimum_size.y = label.size.y
			_:
				assert(false)
	
	# set position after adding to scene, otherwise it doesn't always work
	tooltip._update_position(mouse_position)
	
	tooltip._force_position_onto_screen() # force position before performing scale...
	
	# pivot offset controls where we scale from
	tooltip.pivot_offset = tooltip.size/2.0
	tooltip.scale = Vector2(0.2, 0.2)
	tooltip.create_tween().tween_property(tooltip, "scale", Vector2(1.0, 1.0), 0.1)
	
	tooltip.modulate.a = 0.0
	tooltip.create_tween().tween_property(tooltip, "modulate:a", 0.95 if tooltip.properties._style == Style.CLEAR else 1.0, 0.1)
	
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
		if not Rect2(source.global_position * _SCALE_FACTOR, source.size * _SCALE_FACTOR).has_point(mouse_position):
			destroy_tooltip() # if the source has moved away from mouse, destroy the tooltip
	
	# hack - for some reason sometimes tooltips can get stuck on screen...
	# THIS SHOULD NOT HAPPEN!!!!
	#if source != null and source is MouseWatcher:
	#	if not source.is_over():
	#		hide()
	#		destroy_tooltip()
	
	# $HACK$? - I guess we don't need this Area2D case - dunno, seems to work without it...
	#elif source is Area2D:
	#	var area = source as Area2D
	#	area.get_size
	
	_update_position(mouse_position)
	pivot_offset = size/2.0
	_force_position_onto_screen()

func _update_position(mouse_position: Vector2) -> void:
	var real_size = _get_real_rect().size
	var base_pos = mouse_position if properties._anchor == NO_ANCHOR else properties._anchor
	match properties._direction:
		Direction.BELOW:
			position = base_pos + Vector2(0, properties._offset)
			position.x -= real_size.x / 2.0 # center horizontally 
		Direction.ABOVE:
			position = base_pos + Vector2(0, -properties._offset)
			position.y -= real_size.y # shift up by tooltip height
			position.x -= real_size.x / 2.0 # center horizontally 
		Direction.LEFT:
			position = base_pos + Vector2(-properties._offset, 0)
			position.x -= real_size.x # shift left by tooltip width
			position.y -= real_size.y / 2.0 # center vertically 
		Direction.RIGHT:
			position = base_pos + Vector2(properties._offset, 0)
			position.y -= real_size.y / 2.0 # center vertically 
		Direction.CENTERED:
			position = base_pos
			position.y -= real_size.y / 2.0 # center vertically 
			position.x -= real_size.x / 2.0 # center horizontally 
		_:
			assert(false, "Probably gave an int for dir on accident.")

# $HACK$ - get_rect() is wrong because size is wrong... (reports far too large of a y for some reason)
func _get_real_rect():
	var real_rect = find_child("MainTooltip").get_rect()
	real_rect.position = position
	return real_rect

# force the tooltip to be within the screen boundaries and not overlapping the mouse
func _force_position_onto_screen():
	# update position based on mouse position and screen position
	var mouse_position = get_global_mouse_position() if not manual_control else manual_mouse_position
	var viewport_rect = get_viewport_rect()

	#$HACK$ - idk why but Tooltip and Grid's y size is way larger than it should be, but this is right
	var real_size = find_child("MainTooltip").size
	real_size.x += find_child("SubtooltipsRight").size.x
	real_size.y += find_child("SubtooltipsBelow").size.y
	
	
	# if we are off the right of the screen, move left until that's no longer the case.
	if position.x + real_size.x > viewport_rect.size.x:
		position.x = viewport_rect.size.x - real_size.x
	
	if position.x < 0:
		position.x = 0
	
	# if we are off the bottom of the screen, move up until that's no longer the case.
	if position.y + real_size.y > viewport_rect.size.y:
		position.y = viewport_rect.size.y - real_size.y
		
	if position.y < 0:
		position.y = 0
	
#	# but now we might be overlapping the mouse, so move up until we aren't
#	if _FORCE_MOVE_OFF_OF_MOUSE:
#		var shifted := false
#		var hit_top := false
#		while _get_real_rect().has_point(mouse_position):
#			shifted = true
#			position.y -= 1
#			if position.y <= 0:
#				position.y = 0
#				hit_top = true
#				break
#
#		if shifted and not hit_top: # if we had to shift back up, go a bit more to match the same offset as normal
#			position.y = max(0, position.y - properties._offset) # clamp at 0 so we can't end up offscreen again

func destroy_tooltip():
	var fade_out = create_tween()
	if fade_out:
		fade_out.tween_property(self, "modulate:a", 0.0, 0.05)
		_ALL_TOOLTIPS.erase(self)
		await fade_out.finished
	assert(is_instance_valid(self), "This tooltip has already been destroyed?")
	queue_free()
