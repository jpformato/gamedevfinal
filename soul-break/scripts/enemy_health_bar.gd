extends TextureProgressBar

var enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy = $"../../Enemy"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = enemy.health
