extends Node

# Preloaded particle effect scenes (these will be your GPUParticles2D effects)
@export var power_burst : PackedScene

# Function to spawn a particle effect at a specific location and handle cleanup
func spawn_effect(effect_scene: PackedScene, position: Vector2, color: Color, parent = self) -> void:
	# Instantiate the particle effect scene
	var particle_instance = effect_scene.instantiate() as GPUParticles2D

	# Set the position of the particle effect
	particle_instance.global_position = position

	# Set the particle system to start emitting
	particle_instance.emitting = true
	particle_instance.one_shot = true
	particle_instance.process_material.color = color

	# Add it to the singleton scene (this scene will automatically manage cleanup)
	parent.add_child(particle_instance)  # Add the particle instance as a child of this singleton node

	# Wait for the lifetime of the particle effect to finish, then free it
	await Global.delay(particle_instance.lifetime)  # Wait for the given lifetime
	particle_instance.queue_free()  # Cleanup the particle system after it finishes

func spawn_power_burst(position: Vector2, color: Color, parent) -> void:
	spawn_effect(power_burst, position, color, parent)

