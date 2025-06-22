class_name AnimatedLabel
extends Control

@export var font: FontFile
@export var start_color = Color.FUCHSIA
@export var end_color = Color.BLACK
@export var time: float = 0.25

# determines whether the label fades out the old label as it fade in the new one
# if false, the label immediately changes
@export var fade_old: bool = false

@onready var _CURRENT_LABEL = $Label
@onready var _label_size = _CURRENT_LABEL.size

func set_text(txt: String) -> void:
	if _CURRENT_LABEL.text == txt: #no animation if not changing
		return
	
	# keep ref to old label
	var old_label = _CURRENT_LABEL
	
	# make the new label; set up its coloring
	var new_label = RichTextLabel.new()
	add_child(new_label)
	new_label.text = txt
	new_label.size = _label_size
	new_label.scroll_active = false
	new_label.bbcode_enabled = true
	new_label.use_parent_material = true
	if font:
		new_label.add_theme_font_override("normal_font", font)
	new_label.add_theme_color_override("default_color", start_color)
	var new_tween = create_tween()
	new_tween.tween_property(new_label, "theme_override_colors/default_color", end_color, time)
	_CURRENT_LABEL = new_label
	
	if fade_old:
		# fade out old label and delete
		var old_tween = create_tween()
		old_label.add_theme_color_override("default_color", Color(end_color, 0.5))
		old_tween.tween_property(old_label, "theme_override_colors/default_color:a", 0.0, time)
		await old_tween.finished
	old_label.queue_free()
