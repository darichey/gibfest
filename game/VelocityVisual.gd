extends Control

@onready var player = $"../.."
@onready var camera = $"../../Head/Camera3D"

func _draw() -> void:
	if player.debug:
		var color = Color(0, 1, 0)
		var start = camera.unproject_position(player.global_transform.origin)
		var end = camera.unproject_position(player.global_transform.origin + player.get_xz_velocity())
		draw_line(start, end, color, 4)

func _process(delta: float) -> void:
	queue_redraw()
