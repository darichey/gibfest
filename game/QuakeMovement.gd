extends Object
class_name QuakeMovement

#const MULTIPLIER = 1
#const sv_friction: float = 5.2 * MULTIPLIER
#const sv_accelerate: float = 5.6 * MULTIPLIER
#const sv_maxspeed: float = 320 * MULTIPLIER
#const sv_airaccelerate: float = 12 * MULTIPLIER
#const sv_maxairspeed: float = 320 * MULTIPLIER

const sv_friction: float = 4.0
const sv_accelerate: float = 100.0
const sv_maxspeed: float = 10.0
const sv_airaccelerate: float = 100.0
const sv_maxairspeed: float = 10.0

static func accelerate(accelDir: Vector3, prevVelocity: Vector3, accelerate: float, max_velocity: float, delta: float) -> Vector3:
	prevVelocity.y = 0
	var projVel = prevVelocity.dot(accelDir)
	var accelVel = clampf(max_velocity - projVel, 0, accelerate * delta)
	
	return prevVelocity + accelDir * accelVel

static func move_ground(accelDir: Vector3, prevVelocity: Vector3, delta: float) -> Vector3:
	prevVelocity.y = 0
	var speed = prevVelocity.length()

	if speed < 1:
		prevVelocity = Vector3.ZERO

	if speed != 0 and not Input.is_action_pressed("move_jump"):
		var drop = speed * sv_friction * delta
		prevVelocity *= maxf(speed - drop, 0) / speed
		
	return accelerate(accelDir, prevVelocity, sv_accelerate, sv_maxspeed, delta)
	
static func move_air(accelDir: Vector3, prevVelocity: Vector3, delta: float) -> Vector3:
	return accelerate(accelDir, prevVelocity, sv_airaccelerate, sv_maxairspeed, delta)

static func move(accelDir: Vector3, prevVelocity: Vector3, onground: bool, delta: float) -> Vector3:
	var vertical := move_vertical(prevVelocity, onground, delta)

	var horizonal: Vector3
	if onground:
		horizonal = move_ground(accelDir, prevVelocity, delta)
	else:
		horizonal = move_air(accelDir, prevVelocity, delta)
		
	return vertical + horizonal

##########
const AUTO_HOP: bool = true
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

static func get_next_jump_velocity(onground: bool) -> Vector3:
	if should_jump(onground):
		return Vector3.UP * JUMP_SPEED
	else:
		return Vector3.ZERO
		
static func move_vertical(cur_vel: Vector3, onground: bool, delta: float) -> Vector3:
	var gravity_vel := get_next_gravity_velocity(cur_vel, onground, delta)
	var jump_vel := get_next_jump_velocity(onground)
	return gravity_vel + jump_vel
