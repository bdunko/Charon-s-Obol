extends Node

signal _projectile_finished
signal all_projectiles_finished

var _instance_count = 0
var _busy = false

func _ready() -> void:
	_projectile_finished.connect(_on_projectile_finished)

func fire_projectiles(shooter: Coin, targets: Array, callback: Callable) -> void:
	if targets.is_empty():
		return
	if _busy:
		push_error("ProjectileManager is already busy!")
		return
	
	_busy = true
	assert(_instance_count == 0)

	for target in targets:
		_fire_await_callback(shooter, target, callback)
	
	await self.all_projectiles_finished
	_busy = false
	assert(_instance_count == 0)

func _fire_await_callback(shooter: Coin, target: Coin, callback: Callable) -> void:
	_instance_count += 1
	await shooter.fire_projectile(target.get_projectile_target_position())
	callback.call(target)
	emit_signal("_projectile_finished")

func _on_projectile_finished() -> void:
	assert(_instance_count > 0)
	_instance_count -= 1
	if _instance_count == 0:
		emit_signal("all_projectiles_finished")
	
