extends Node2D

var total_enemies = 1
var attack_button
var heal_button
var player
var enemy
var player_animator
var enemy_animator
signal action_picked
var timing_started = false
var fireball = load("res://scenes/fire_ball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set paths
	attack_button = $Attack
	heal_button = $Heal
	player = $Character
	enemy = $Enemy
	player_animator = $Character/AnimatedSprite2D
	enemy_animator = $Enemy/AnimatedSprite2D
	
	randomize()
	hide_actions()
	player_turn()	


func _process(delta):
	if timing_started:
		print("started")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func player_turn() -> void:
	show_actions()
	await action_picked
	enemy_turn()

# Player Attacks
func _on_attack_pressed() -> void:
	hide_actions()
	player_animator.stop()
	var player_position = player.position
	player.position = enemy.position - Vector2(enemy.width, 0)
	var damage = await player.charge_slash()
	
	enemy_animator.play("Hit")
	enemy.take_damage(damage)
	
	await get_tree().create_timer(0.4).timeout
	player.position = player_position
	player_animator.play("idle")
	if enemy.health <= 0:
		print("dead")
		#enemy_animator.play("death")
	
	emit_signal("action_picked")

# Enemy Turn
func enemy_turn():
	await get_tree().create_timer(2).timeout
	
	var count = randi_range(3, 4)
	for i in range(count):
		await fireballs()
		
	player_turn()
		
# Shoot fireballs at player
func fireballs():
	var battle = $"."
	var fireball1 = fireball.instantiate()
	var fireball2 = fireball.instantiate()
	
	fireball1.spawnPos = enemy.position - Vector2(enemy.width, -player.position.y - 250)
	fireball1.targetPos = player.position
	
	fireball2.spawnPos = enemy.position - Vector2(enemy.width, -player.position.y + 250)
	fireball2.targetPos = player.position

	battle.add_child.call_deferred(fireball1)
	battle.add_child.call_deferred(fireball2)

	# Wait for both fireballs to exit
	await wait_for_fireballs(fireball1, fireball2)

# Wait for the fireballs to collide
func wait_for_fireballs(fb1, fb2):
	await fb1.tree_exited
	await fb2.tree_exited
	
func hide_actions():
	attack_button.hide()
	heal_button.hide()
	
func show_actions():
	attack_button.show()
	heal_button.show()
