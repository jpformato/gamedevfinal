extends CharacterBody2D


const SPEED = 750.0
var spawnPos : Vector2
var targetPos : Vector2
var animator
var connected
var is_double = false
var is_stopped = false

func _ready():
	global_position = spawnPos
	global_rotation = 0
	animator = $AnimatedSprite2D
	connected = false
	if is_double:
		collision_layer = 8
		collision_mask = 2

func _physics_process(delta: float) -> void:
	if is_stopped:
		return
		
	var direction = (targetPos - spawnPos).normalized()
	var motion = direction * SPEED * delta
	
	# Check for collisions
	var collision = move_and_collide(motion)
	
	if collision:
		is_stopped = true
		_on_fireball_collided(collision)

func _on_fireball_collided(collision):
	var hit = collision.get_collider()
	$CollisionShape2D.disabled = true
	if hit.name == "Character":
		animator.play("Explode")
		if randi_range(1,3) == 1:
				hit.burn_player()
		hit.take_damage(5)
		if !connected:
			connected = true
			animator.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
func _on_animation_finished():
	queue_free()
	
func blocked():
	is_stopped = true
	await get_tree().create_timer(0.3).timeout
	queue_free()
	#animator.play("blocked")
	#if !connected:
		#connected = true
		#animator.connect("animation_finished", Callable(self, "_on_animation_finished"))
