extends Label

@onready var player: CharacterBody3D = $"../.."

func _process(delta: float) -> void:
	var xz_speed = Plane.PLANE_XZ.project(player.velocity).length()
	self.text = "Speed: %.2f" % xz_speed
