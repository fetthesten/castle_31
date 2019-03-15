extends Particles

var prev_range_value = 12
var range_value = 12
onready var random = RandomNumberGenerator.new()

func _ready():
	random.randomize()

func _physics_process(delta):
	$OmniLight.omni_range = lerp(prev_range_value, range_value, $Timer.time_left)
	
func new_range_value():
	prev_range_value = range_value
	range_value = random.randf_range(8, 15)
	$Timer.start(random.randf_range(0.3, 1))