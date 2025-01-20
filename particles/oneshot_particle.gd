class_name OneshotParticle
extends GPUParticles2D

signal finished

func _ready() -> void:
	# if we exit tree, free ourselves
	tree_exited.connect(queue_free)
	
	# start emitting immediately when added to tree
	emitting = true
	
	# wait for lifetime, then free self if we're still in tree
	await Global.delay(lifetime)
	if is_inside_tree():
		queue_free()
