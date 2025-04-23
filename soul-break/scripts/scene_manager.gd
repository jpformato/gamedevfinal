extends Node2D

var start_scene
var level_scene
var battle_scene = load("res://scenes/battle.tscn")
var game_over_scene
var current_battle
var state
var click_sound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_scene = $StartScreen
	game_over_scene = $GameOver
	click_sound = $ClickSound
	state = "start"
	
	
func _on_quit_pressed() -> void:
	click_sound.play()
	get_tree().quit()


func _on_start_pressed() -> void:
	click_sound.play()
	if state == "start":
		start_scene.music_player.stop()
		start_scene.visible = false
		current_battle = battle_scene.instantiate()
		add_child(current_battle)
		state = "battle"
		current_battle.manager = self
		
func game_over(won: bool):
	current_battle.queue_free()
	if won:
		start_scene.visible = true
		state = "start"
	else:
		game_over_scene.visible = true
		state = "over"


func _on_replay_pressed() -> void:
	click_sound.play()
	if state == "over":
		game_over_scene.visible = false
		current_battle = battle_scene.instantiate()
		add_child(current_battle)
		state = "battle"
		current_battle.manager = self


func _on_main_menu_pressed() -> void:
	click_sound.play()
	if state == "over":
		start_scene.music_player.play()
		game_over_scene.visible = false
		start_scene.visible = true
		state == "start"
