extends CharacterBody3D

const AUTO_HOP := true
const WALK_SPEED := 6.5
const JUMP_SPEED := 4.5
const MOUSE_SENSITIVITY := 0.002

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func get_next_gravity_velocity(delta: float) -> Vector3:
	if not is_on_floor():
		return Vector3.UP * (velocity.y - gravity * delta)
	else:
		return Vector3.ZERO

func should_jump() -> bool:
	if AUTO_HOP:
		return Input.is_action_pressed("move_jump") and is_on_floor()
	else:
		return Input.is_action_just_pressed("move_jump") and is_on_floor()

func get_next_jump_velocity() -> Vector3:
	if should_jump():
		return Vector3.UP * JUMP_SPEED
	else:
		return Vector3.ZERO

func get_next_walk_velocity() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction == Vector3.ZERO:
		return Vector3(
			move_toward(velocity.x, 0, WALK_SPEED),
			0,
			move_toward(velocity.z, 0, WALK_SPEED)
		)
	else:
		return direction * WALK_SPEED

func get_next_velocity(delta: float) -> Vector3:
	var gravity := get_next_gravity_velocity(delta)
	var jump := get_next_jump_velocity()
	var walk := get_next_walk_velocity()
	return gravity + jump + walk

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		$Head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		$Head.rotation.x = clampf($Head.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func _physics_process(delta: float) -> void:
	velocity = get_next_velocity(delta)
	move_and_slide()
