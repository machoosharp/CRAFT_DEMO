extends DirectionalLight3D

@export var cur: float
@export var t: float
@onready var sky: WorldEnvironment = $"../WorldEnvironment"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	var day_speed = 30.0

	var ticks = Time.get_ticks_msec() * 0.1

	var y = ( int( ticks ) ) / day_speed
	cur = y - 180
	t = ( int(y+30) % int(360.0) )

	if t >= 0:
		var fuh = t / 30
		fuh = clampf(fuh, 0.0, 1.0)
		
		var uhf = (t - 360)/30
		uhf = clampf(uhf, 0.0, 1.0)
		
		sky.environment.background_energy_multiplier = fuh

	rotation.x = deg_to_rad( cur )
