extends CharacterBody2D


var animated_sprite
var width
var height
var health = 100
var strength = 10

func _ready():
	animated_sprite = $AnimatedSprite2D
	var texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	width = texture.get_width() * (scale.x-1)
	height = texture.get_height() * (scale.y-1)

func take_damage(damage):
	print(damage)
	health -= damage
