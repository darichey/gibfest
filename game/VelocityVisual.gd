extends Control

@onready var player = $"../.."
@onready var camera = $"../../Head/Camera3D"

func draw_vector(from: Vector3, to: Vector3, color: Color) -> void:
	draw_line(
		camera.unproject_position(from),
		camera.unproject_position(to),
		color,
		4
	)

func _draw() -> void:
	draw_vector(
		player.global_transform.origin,
		player.global_transform.origin + player.get_xz_velocity(),
		Color.GREEN
	)

func _process(delta: float) -> void:
	queue_redraw()
