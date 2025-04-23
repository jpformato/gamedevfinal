extends Node2D

var music = load("res://assets/Music/ObservingTheStar.ogg")
var music_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_player = $AudioStreamPlayer2D
	music.loop = true
	music_player.stream = music
	music_player.volume_db = -5
	music_player.play()
