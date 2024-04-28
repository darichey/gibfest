extends CharacterBody3D

@export var auto_hop: bool = true
@export var walk_speed: float = 6.5
@export var jump_speed: float = 4.5
@export var mouse_sensitivity: float = 0.002
@export var debug: bool = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func get_next_gravity_velocity(delta: float) -> Vector3:
	if not is_on_floor():
		return Vector3.UP * (velocity.y - gravity * delta)
	else:
		return Vector3.ZERO

func should_jump() -> bool:
	if auto_hop:
		return Input.is_action_pressed("move_jump") and is_on_floor()
	else:
		return Input.is_action_just_pressed("move_jump") and is_on_floor()

func get_next_jump_velocity() -> Vector3:
	if should_jump():
		return Vector3.UP * jump_speed
	else:
		return Vector3.ZERO

func get_next_walk_velocity() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction == Vector3.ZERO:
		return Vector3(
			move_toward(velocity.x, 0, walk_speed),
			0,
			move_toward(velocity.z, 0, walk_speed)
		)
	else:
		return direction * walk_speed

func get_next_velocity(delta: float) -> Vector3:
	var gravity := get_next_gravity_velocity(delta)
	var jump := get_next_jump_velocity()
	var walk := get_next_walk_velocity()
	return gravity + jump + walk

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if not debug:
			$Head.rotate_x(-event.relative.y * mouse_sensitivity)
			$Head.rotation.x = clampf($Head.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func _physics_process(delta: float) -> void:
	velocity = get_next_velocity(delta)
	move_and_slide()
	
func toggle_debug() -> void:
	if debug:
		$Head.position.y = 0.75
		$Head.rotation.x = 0
		debug = false
	else:
		$Head.position.y = 10
		$Head.rotation.x = deg_to_rad(-90)
		debug = true
		
func get_xz_velocity() -> Vector3:
	var xz_plane := Plane(Vector3(0, 1, 0))
	return xz_plane.project(velocity)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("activate_debug"):
		toggle_debug()
