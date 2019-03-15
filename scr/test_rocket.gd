extends KinematicBody

var explosion_prefab = preload('res://obj/fx/explosion.tscn')
onready var forward = -global_transform.basis.z
var max_velocity = 30
var velocity = 0
var acceleration = 2
var destroyed = false

func _ready():
	$death_timer.connect('timeout', self, 'queue_free')

func _physics_process(delta):
	if not destroyed:
		velocity += acceleration * delta
		velocity = min(velocity, max_velocity)
	
		var collision = move_and_collide(forward * velocity)
		if collision != null:
			destroyed = true
			$MeshInstance.hide()
			$CollisionShape.disabled = true
			$Particles.emitting = false
			var explosion = explosion_prefab.instance()
			explosion.global_transform.origin = global_transform.origin
			main.current_scene().add_child(explosion)
			explosion.restart()
