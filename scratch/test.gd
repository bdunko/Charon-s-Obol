extends Control

@onready var watcher = $MouseWatcher
@onready var poly = $VisualPoly

func _ready():
	tween()

func tween() -> void:
	var t = create_tween()
	t.tween_property(self, "position", Vector2(140, 80), 3.0)
	t.tween_property(self, "position", Vector2(0, 0), 3.0)
	t.tween_callback(tween)

func _on_mouse_watcher_mouse_entered():
	poly.color = Color.RED

func _on_mouse_watcher_mouse_exited():
	poly.color = Color.BLUE
