extends Node2D

var attack_button
var heal_button
var player
var enemy
var player_animator
var enemy_animator
var background
signal action_picked
var fireball = load("res://scenes/fire_ball.tscn")
var player_health
var ui
var enemy_health
var heals_remaining = 3
var manager
var music
var click_sound

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
	background = $Background
	background.modulate.a = 0.6 # Make more transparent so its duller
	music = $Music
	click_sound = $ClickSound
	
	# Start music and loop when finished
	music.play()
	music.connect("finished", Callable(self, "_on_music_finished"))
	
	# Set references
	enemy.player_reference = player
	player.enemy_reference = enemy
	
	# Set initial health
	heal_button.text = "Heal x" + str(heals_remaining)
	
	# Create Player Health Label
	player_health.text = "HP: %d/%d" % [player.health, player.max_health]
	player.health_label = player_health
	
	# Set up enemy health bar
	enemy.health_label = enemy_health
	enemy.set_up_health_bar()
	
	# Start Battle
	randomize()
	hide_actions()
	player_turn()	
	
# Trigger when music ends: replay the music
func _on_music_finished() -> void:
	music.play()

func player_turn() -> void:
	# Take burn damage at start of turn
	await player.is_burnt()
	
	# Show buttons and wait for one to be clicked
	show_actions()
	await action_picked
	
	# if enemy is dead end the game
	if enemy.health == 0:
		win()
	else:
		enemy_turn()

# Triggered on Attack pressed: Player attacks
func _on_attack_pressed() -> void:
	click_sound.play()
	hide_actions()
	
	# Call attack and wait for it to finish
	var damage = await player.charge_slash()
	enemy.take_damage(damage)
	
	# Wait for 0.4 sec and then return player to start position
	await get_tree().create_timer(0.4).timeout
	player.return_to_start()
	
	# Let player_turn() now that an action was picked
	emit_signal("action_picked")
	
# Triggered on Heal pressed: heal the player
func _on_heal_pressed() -> void:
	click_sound.play()
	
	# Can the player heal if not return
	if heals_remaining == 0 or player.health == player.max_health:
		return

	# Heal 10 hp, update button label
	player.heal(10)
	heals_remaining = max(heals_remaining-1, 0)
	heal_button.text = "Heal x" + str(heals_remaining)
	hide_actions()
	
	# Let player_turn() now that an action was picked
	emit_signal("action_picked")

func enemy_turn() -> void:
	# Wait for enemies attack and then wait another 2 sec
	await enemy.attack()
	await get_tree().create_timer(2).timeout
	
	# if player is dead end game
	if player.health == 0:
		game_over()
	else:
		player_turn()
	
# hide action buttons
func hide_actions() -> void:
	attack_button.hide()
	heal_button.hide()

# show action buttons
func show_actions() -> void:
	attack_button.show()
	heal_button.show()

func win() -> void:
	if manager:
		music.stop()
		manager.game_over(true)
	
func game_over() -> void:
	if manager:
		music.stop()
		manager.game_over(false)
