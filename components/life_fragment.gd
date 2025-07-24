extends Control

@onready var _SPRITE = $Sprite
@onready var _TRAIL_PARTICLES = $FancyTrail
#@onready var _FX = $Sprite/FX

static var _INSTANCES_EMITTING = 0

func _ready():
	# randomize appearance
	_SPRITE.frame = Global.RNG.randi_range(0, 4)
	
	#_FX.start_glowing(Color.RED)
	_TRAIL_PARTICLES.emitting = false

func start_trail_particles():
	_INSTANCES_EMITTING += 1
	
	if _INSTANCES_EMITTING <= 8 or _INSTANCES_EMITTING % 6 == 0:
		_TRAIL_PARTICLES.emitting = true

func stop_trail_particles():
	_INSTANCES_EMITTING -= 1
	_TRAIL_PARTICLES.emitting = false
	
