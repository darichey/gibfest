extends Object
class_name BasicMovement

const AUTO_HOP: bool = true
const WALK_SPEED: float = 6.5
const JUMP_SPEED: float = 4.5
static var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

static func get_next_gravity_velocity(cur_vel: Vector3, onground: bool, delta: float) -> Vector3:
	if onground:
		return Vector3.ZERO
	else:
		return Vector3.UP * (cur_vel.y - gravity * delta)

static func should_jump(onground: bool) -> bool:
	if AUTO_HOP:
		return Input.is_action_pressed("move_jump") and onground
	else:
		return Input.is_action_just_pressed("move_jump") and onground

static func get_next_jump_velocity(onground: bool, delta: float) -> Vector3:
	if should_jump(onground):
		return Vector3.UP * JUMP_SPEED
	else:
		return Vector3.ZERO

static func get_next_walk_velocity(cur_vel: Vector3, wishdir: Vector3, delta: float) -> Vector3:
	if wishdir == Vector3.ZERO:
		return Vector3(
			move_toward(cur_vel.x, 0, WALK_SPEED),
			0,
			move_toward(cur_vel.z, 0, WALK_SPEED)
		)
	else:
		return wishdir * WALK_SPEED

static func move(cur_vel: Vector3, wishvel: Vector3, onground: bool, delta: float) -> Vector3:
	var wishdir := wishvel.normalized()
	
	var gravity := get_next_gravity_velocity(cur_vel, onground, delta)
	var jump := get_next_jump_velocity(onground, delta)
	var walk := get_next_walk_velocity(cur_vel, wishdir, delta)
	
	return gravity + jump + walk
