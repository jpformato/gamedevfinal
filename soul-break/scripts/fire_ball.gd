extends CharacterBody2D


const SPEED = 750.0
var spawnPos : Vector2
var targetPos : Vector2
var animator
var connected

func _ready():
	global_position = spawnPos
	global_rotation = 0
	animator = $AnimatedSprite2D
	connected = false

func _physics_process(delta: float) -> void:
	var direction = (targetPos - spawnPos).normalized()
	var motion = direction * SPEED * delta
	
	# Check for collisions
	var collision = move_and_collide(motion)
	
	if collision:
		_on_fireball_collided(collision)

func _on_fireball_collided(collision):
	animator.play("Explode")
	if !connected:
		connected = true
		animator.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
func _on_animation_finished():
	queue_free()
