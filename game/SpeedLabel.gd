extends Label

@onready var player = $"../.."

func _process(delta: float) -> void:
	var xz_speed = Plane.PLANE_XZ.project(player.velocity).length()
	text = "Speed: %.2f" % xz_speed
