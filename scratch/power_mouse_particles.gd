extends Sprite2D

func _ready():
	#Input.set_custom_mouse_cursor(load("res://assets/ui/cursor.png"), Input.CURSOR_ARROW)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	position = get_global_mouse_position()
