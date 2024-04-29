extends Control

@onready var player: CharacterBody3D = $"../.."
@onready var camera: Camera3D = $"../../Head/Camera3D"

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
		player.global_transform.origin + Plane.PLANE_XZ.project(player.velocity),
		Color.GREEN
	)
	draw_vector(
		player.global_transform.origin,
		player.global_transform.origin + player.debug_wishdir,
		Color.BLUE
	)

func _process(delta: float) -> void:
	queue_redraw()
