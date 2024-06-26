extends CharacterBody3D

@export var mouse_sensitivity: float = 0.002
@export var debug: bool = false

var debug_wishdir: Vector3 = Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if not debug:
			$Head.rotate_x(-event.relative.y * mouse_sensitivity)
			$Head.rotation.x = clampf($Head.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func _physics_process(delta: float) -> void:
	var fmove := Input.get_axis("move_back", "move_forward")
	var smove := Input.get_axis("move_left", "move_right")

	var forward := -transform.basis.z
	var right := transform.basis.x
	
	velocity = QuakeMovement.move(self, velocity, fmove, smove, forward, right, is_on_floor(), delta)
	
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
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("activate_debug"):
		toggle_debug()
