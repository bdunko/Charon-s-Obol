class_name ProjectileShooter
extends Node2D

# this generally shouldn't be called directly; use ProjectileManager instead.
@onready var PROJECTILE = preload("res://components/projectile.tscn")
func fire_projectile(target_position: Vector2, params: Projectile.ProjectileParams = Projectile.ProjectileParams.new()) -> void:
	var projectile = PROJECTILE.instantiate()
	add_child(projectile) 
	await projectile.launch(global_position, target_position, params)
