extends Control

@onready var _SPRITE = $Sprite
@onready var _TRAIL_PARTICLES = $FancyTrail
#@onready var _FX = $Sprite/FX

func _ready():
	# randomize appearance
	_SPRITE.frame = Global.RNG.randi_range(0, 4)
	
	#_FX.start_glowing(Color.RED)
	_TRAIL_PARTICLES.emitting = false

func start_trail_particles():
	_TRAIL_PARTICLES.emitting = true

func stop_trail_particles():
	_TRAIL_PARTICLES.emitting = false
