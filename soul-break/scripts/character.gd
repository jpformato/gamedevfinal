extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var width
var height
var max_health = 30
var health
var strength = 5
var state
var charge_count = 0

func _ready():
	var texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	width = texture.get_width() * (scale.x-1)
	height = texture.get_height() * (scale.y-1)
	health = max_health
	state = "idle"

func take_damage(damage):
	if health > 0:
		health -= damage

func heal(num):
	if health+num > max_health:
		health = max_health
	else:
		health += num
		
func _unhandled_input(event: InputEvent) -> void:
	if state == "slash" and event.is_action_pressed("swing"):
		charge_count += 1
		
func charge_slash() -> int:
	state = "slash"
	# animated_sprite.play("charge_slash")
	await get_tree().create_timer(4).timeout
	var total = min(charge_count, 30)
	var damage = floor(total * 0.3 * strength)
	charge_count = 0
	return damage
