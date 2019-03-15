extends Particles

func _physics_process(delta):
	$OmniLight.light_energy -= delta * 10
	$OmniLight.light_energy = max(0, $OmniLight.light_energy)
	$OmniLight.omni_range += delta * 10
	
	

func stop_emitting():
	emitting = false