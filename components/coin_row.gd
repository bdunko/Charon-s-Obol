extends Control

func _on_child_entered_tree(_node):
	_update_coins()

func _on_child_exiting_tree(_node):
	# update 1 frame later once child is gone
	call_deferred("_update_coins")

func _update_coins() -> void:
	if get_child_count() == 0:
		return
	
	var coin_width = get_child(0).size.x
	var start = size.x / 2.0 + 2 #center
	start -= ((get_child_count() * coin_width/2.0))
	
	# position all the coins
	for i in get_child_count():
		var coin = get_child(i)
		coin.position.x = start + (i*coin_width)
		
