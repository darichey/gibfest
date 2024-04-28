extends Object
class_name QuakeMovement

const MAX_GROUND_SPEED := 6
const MAX_AIR_SPEED := 0.6
const ACCELERATE := 10 * MAX_GROUND_SPEED
const FRICTION := ACCELERATE / 4

static func apply_friction(cur_vel: Vector2, delta: float) -> Vector2:
	var speed := cur_vel.length()
	if speed < 1:
		return Vector2.ZERO
	
	var drop := speed * FRICTION * delta
	return cur_vel * max(speed - drop, 0) / speed

static func accelerate(cur_vel: Vector2, wishdir: Vector2, max_speed: float, delta: float) -> Vector2:
	var current_speed := cur_vel.dot(wishdir)
	var add_speed := clampf(max_speed - current_speed, 0, ACCELERATE * delta)
	return cur_vel + add_speed * wishdir

static func move_horizontal(cur_vel: Vector2, wishdir: Vector2, onground: bool, delta: float) -> Vector2:
	var new_vel := cur_vel
	if onground:
		new_vel = apply_friction(new_vel, delta)
		new_vel = accelerate(new_vel, wishdir, MAX_GROUND_SPEED, delta)
	else:
		new_vel = accelerate(new_vel, wishdir, MAX_AIR_SPEED, delta)
	
	return new_vel
	
static func move_vertical(cur_speed: float, onground: bool, delta: float) -> float:
	return get_next_gravity_velocity(cur_speed, onground, delta) + get_next_jump_velocity(onground, delta)
	
static func move(cur_vel: Vector3, wishdir: Vector2, onground: bool, delta: float) -> Vector3:
	var cur_vel_xz = Plane.PLANE_XZ.project(cur_vel)
	
	var horizonal := move_horizontal(Vector2(cur_vel_xz.x, cur_vel_xz.z), wishdir, onground, delta)
	var vertical := move_vertical(cur_vel.y, onground, delta)
	
	return Vector3(
		horizonal.x,
		vertical,
		horizonal.y
	)
	
#########
const AUTO_HOP := true
const JUMP_SPEED := 4.5
static var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

static func get_next_gravity_velocity(cur_speed: float, onground: bool, delta: float) -> float:
	if onground:
		return 0
	else:
		return cur_speed - gravity * delta

static func should_jump(onground: bool) -> bool:
	if AUTO_HOP:
		return Input.is_action_pressed("move_jump") and onground
	else:
		return Input.is_action_just_pressed("move_jump") and onground

static func get_next_jump_velocity(onground: bool, delta: float) -> float:
	if should_jump(onground):
		return JUMP_SPEED
	else:
		return 0
