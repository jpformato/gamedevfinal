extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size = get_size()
	pivot_offset = size / 2
	scale = Vector2(0.5,0.5)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.5)
	tween.tween_callback(self.queue_free).set_delay(0.6)
