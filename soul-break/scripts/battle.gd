extends Node2D

var attack_button
var heal_button
var player
var enemy
var player_animator
var enemy_animator
signal action_picked
var fireball = load("res://scenes/fire_ball.tscn")
var player_health
var ui
var enemy_health
var heals_remaining = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set paths
	attack_button = $UI/Attack
	heal_button = $UI/Heal
	player = $Character
	enemy = $Enemy
	player_animator = $Character/AnimatedSprite2D
	enemy_animator = $Enemy/AnimatedSprite2D
	ui = $UI
	player_health = $UI/PlayerHealth
	enemy_health = $UI/EnemyHealth
	
	# Set references
	enemy.player_reference = player
	player.enemy_reference = enemy
	
	heal_button.text = "Heal x" + str(heals_remaining)
	
	# Create Player Health Label
	player_health.text = "HP: %d/%d" % [player.health, player.max_health]
	player.health_label = player_health
	
	enemy.health_label = enemy_health
	enemy.set_up_health_bar()
	
	# Start Battle
	randomize()
	hide_actions()
	player_turn()	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func player_turn() -> void:
	await player.is_burnt()
	show_actions()
	await action_picked
	enemy_turn()

# Player Attacks
func _on_attack_pressed() -> void:
	hide_actions()
	var damage = await player.charge_slash()
	
	enemy_animator.play("Hit")
	enemy.take_damage(damage)
	
	await get_tree().create_timer(0.4).timeout
	player.return_to_start()
	
	emit_signal("action_picked")

# Enemy Turn
func enemy_turn():
	await enemy.attack()
	await get_tree().create_timer(2).timeout
	player_turn()
	
	
func hide_actions():
	attack_button.hide()
	heal_button.hide()
	
func show_actions():
	attack_button.show()
	heal_button.show()


func _on_heal_pressed() -> void:
	if heals_remaining == 0 or player.health == player.max_health:
		return
		
	player.heal(10)
	heals_remaining = max(heals_remaining-1, 0)
	heal_button.text = "Heal x" + str(heals_remaining)
	hide_actions()
	emit_signal("action_picked")
