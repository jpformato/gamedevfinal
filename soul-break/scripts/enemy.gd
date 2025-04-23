extends CharacterBody2D


var animated_sprite
var width
var height
var MAX_HEALTH = 200
var health = MAX_HEALTH
var strength = 5
var attacks
var fireball = load("res://scenes/fire_ball.tscn")
var damage_scene = load("res://scenes/damage_label.tscn")
var player_reference
var health_label

func _ready() -> void:
	animated_sprite = $AnimatedSprite2D
	var texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	width = texture.get_width() * (scale.x-1)
	height = texture.get_height() * (scale.y-1)
	attacks = [
		Callable(self, "fireballs"),  # Makes functions callable like a variable
		#Callable(self, "stab"),
	]
	
func attack() -> void:
	var numAttacks = attacks.size()
	if numAttacks < 1:
		return
	
	var attack = randi_range(0, numAttacks-1)
	await attacks[attack].call()
	animated_sprite.play("Idle")

func take_damage(damage: int) -> void:
	health = max(health - damage, 0)
	var damage_label = damage_scene.instantiate()
	damage_label.text = str(damage)
	damage_label.position = position + Vector2(40, -height)
	damage_label.z_index = 5
	get_tree().current_scene.add_child(damage_label)
	if health <= 0:
		print("dead")
		#enemy_animator.play("death")

func set_up_health_bar() -> void:
	health_label.max_value = MAX_HEALTH

func fireballs() -> void:
	player_reference.state = "counter"
	animated_sprite.play("Fireballs")
	await get_tree().create_timer(2).timeout
	
	var count = randi_range(3, 4)
	for i in range(count):
		var battle = $"."
		if randi_range(1,2) == 1:
			var fireball1 = fireball.instantiate()
			fireball1.add_to_group("fireballs")
			
			fireball1.spawnPos = Vector2(position.x - width, player_reference.position.y)
			fireball1.targetPos = player_reference.position
			fireball1.speed = 1000
			
			# Add fireball to scene
			battle.add_child.call_deferred(fireball1)
			await fireball1.tree_exited
			
		else:
			var fireball1 = fireball.instantiate()
			var fireball2 = fireball.instantiate()
			fireball1.add_to_group("fireballs")
			fireball2.add_to_group("fireballs")
			
			# Set that the fireballs are doubles which changes their layer
			fireball1.is_double = true
			fireball2.is_double = true
			
		
			fireball1.spawnPos = Vector2(position.x - 80, player_reference.position.y - 150)
			fireball1.targetPos = player_reference.position
			
			fireball2.spawnPos = Vector2(position.x - 80, player_reference.position.y + 150)
			fireball2.targetPos = player_reference.position

			# Add fireballs to scene
			battle.add_child.call_deferred(fireball1)
			battle.add_child.call_deferred(fireball2)
			
			# Wait for both fireballs to exit (they exit at the same time)
			await fireball1.tree_exited	
	
# Second Attack, not used because counter was not set up = Auto lose
func stab() -> void:
	await get_tree().create_timer(2).timeout
	var prev_position = position
	var damage = strength * 2
	position = player_reference.position + Vector2(width*2, 0)
	
	await get_tree().create_timer(2).timeout
	
	player_reference.take_damage(damage)
	position = prev_position
