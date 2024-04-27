extends Label

@onready var player = $"../.."

func _process(delta: float) -> void:
	var xz_velocity = player.get_xz_velocity()
	text = "Speed: %.2f" % (xz_velocity.length())
