extends Node

signal _projectile_finished

var _call_id_counter := 0
var _active_calls := {}

func _ready() -> void:
	_projectile_finished.connect(_on_projectile_finished)

func fire_projectiles(shooter, targets: Array, callback: Callable, params: Projectile.ProjectileParams = Projectile.ProjectileParams.new()) -> void:
	# lazy hack but it'll be fine for now...
	if shooter is Coin:
		shooter = shooter.get_projectile_shooter()
	assert(shooter.has_method("fire_projectile"))
	
	if targets.is_empty():
		return

	_call_id_counter += 1
	var call_id := _call_id_counter
	_active_calls[call_id] = targets.size()

	for target in targets:
		_fire_await_callback(shooter, target, callback, params, call_id)

	# Wait until all projectiles for this call are finished
	while _active_calls.has(call_id) and _active_calls[call_id] > 0:
		await get_tree().process_frame

	# Clean up
	_active_calls.erase(call_id)

func _fire_await_callback(shooter: ProjectileShooter, target: Coin, callback: Callable, params: Projectile.ProjectileParams, call_id: int) -> void:
	await shooter.fire_projectile(target.get_projectile_target_position(), params)
	target.on_projectile_hit()
	callback.call(target)
	emit_signal("_projectile_finished", call_id)

func _on_projectile_finished(call_id: int) -> void:
	if not _active_calls.has(call_id):
		return
	_active_calls[call_id] -= 1
	if _active_calls[call_id] <= 0:
		_active_calls.erase(call_id)
