extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var damage_scene = load("res://scenes/damage_label.tscn")
var burn_scene = load("res://scenes/burn_label.tscn")
var healing_scene = load("res://scenes/healing_label.tscn")
var healing_particles
var width
var height
var max_health = 30
var health
var strength = 5
var state
var charge_count = 0
var burn = false
var enemy_reference
var start_position
var health_label
var hitbox
var front_counter_collider
var wide_counter_collider
var pause = false

func _ready():
	var texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	width = texture.get_width() * (scale.x-1)
	height = texture.get_height() * (scale.y-1)
	health = max_health
	state = "idle"
	start_position = position
	hitbox = $Hitbox
	front_counter_collider = $FrontCounter/CollisionShape2D
	wide_counter_collider = $WideCounter/CollisionShape2D
	healing_particles = $HealingParticles

func take_damage(damage):
	if health > 0:
		health = max(health - damage, 0)
		health_label.text = "HP: %d/%d" % [health, max_health]
		var damage_label = damage_scene.instantiate()
		damage_label.text = str(damage)
		damage_label.position = start_position + Vector2(-20, -40)
		damage_label.z_index = 5
		get_tree().current_scene.add_child(damage_label)
		
func burn_player():
	print("burnt")
	if !burn:
		burn = true
		var burn_tween = burn_scene.instantiate()
		burn_tween.position = start_position + Vector2(-35, -height - 20)
		burn_tween.z_index = 5
		get_tree().current_scene.add_child(burn_tween)
	
func is_burnt():
	if burn:
		take_damage(max_health / 10)
		if randi_range(1,3) == 1:
			burn == false

func heal(num):
	var healing_label = healing_scene.instantiate()
	healing_label.position = start_position + Vector2(-30, -40)
	healing_label.z_index = 5
	if health+num > max_health:
		healing_label.text = str(max_health-health)
		health = max_health
	else:
		healing_label.text = str(num)
		health += num
	
	get_tree().current_scene.add_child(healing_label)
	healing_particles.emitting = true
	await get_tree().create_timer(1.0).timeout
	health_label.text = "HP: %d/%d" % [health, max_health]

func return_to_start():
	position = start_position
	animated_sprite.play("idle")
	
func _input(event: InputEvent) -> void:
	if pause:
		return
		
	if state == "slash" and event.is_action_pressed("swing"):
		charge_count += 1
	elif state == "counter" and event.is_action_pressed("swing"):
		pause = true
		await front_counter()
		await get_tree().create_timer(0.3).timeout
		pause = false
	elif state == "counter" and event.is_action_pressed("wide_swing"):
		pause = true
		await wide_counter()
		await get_tree().create_timer(0.3).timeout
		pause = false
		
func charge_slash() -> int:
	animated_sprite.stop()
	position = enemy_reference.position - Vector2(enemy_reference.width, 0)
	state = "slash"
	# animated_sprite.play("charge_slash")
	await get_tree().create_timer(4).timeout
	
	# Min of 5, Max of 30, clicks for charge
	var multiplier = min(charge_count, 30)
	multiplier = max(multiplier, 5)
	var damage = floor(multiplier * 0.3 * strength)
	
	charge_count = 0
	state = "idle"
	return damage


func front_counter():
	front_counter_collider.disabled = false
	await get_tree().create_timer(0.2).timeout
	front_counter_collider.disabled = true
	
func wide_counter():
	await get_tree().create_timer(0.4).timeout
	wide_counter_collider.disabled = false
	await get_tree().create_timer(0.2).timeout
	wide_counter_collider.disabled = true


func _on_front_counter_body_entered(body: Node2D) -> void:
	if body.is_in_group("fireballs"):
		body.blocked()


func _on_wide_counter_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.is_in_group("fireballs"):
		body.blocked()
