extends Control

@onready var watcher = $MouseWatcher
@onready var poly = $VisualPoly

func _ready():
	tween()
	
	# TEST
	var ar = [1, 2, 3]
	
	print(Global.choose_one_excluding(ar, [1]))
	print(Global.choose_one_excluding(ar, [1]))
	print(Global.choose_one_excluding(ar, [1]))
	print(Global.choose_one_excluding(ar, [1]))
	print(Global.choose_one_excluding(ar, [1]))
	print(Global.choose_one_excluding(ar, [1]))
	print(Global.choose_one_excluding(ar, [1]))
	print(Global.choose_one_excluding(ar, [1]))
	print(Global.choose_one_excluding(ar, [1]))
	print(Global.choose_one_excluding(ar, [1]))
	print(Global.choose_one_excluding(ar, [1]))

func tween() -> void:
	pass
	#var t = create_tween()
	#t.tween_property(self, "position", Vector2(140, 80), 3.0)
	#t.tween_property(self, "position", Vector2(0, 0), 3.0)
	#t.tween_callback(tween)

func _on_mouse_watcher_mouse_entered():
	poly.color = Color.RED

func _on_mouse_watcher_mouse_exited():
	poly.color = Color.BLUE

