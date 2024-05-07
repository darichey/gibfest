extends Object
class_name QuakeMovement

const MULTIPLIER = 0.01905
const FORWARD_SPEED = 200 * MULTIPLIER
const SIDE_SPEED = 350 * MULTIPLIER
const FRICTION = 4 * MULTIPLIER
const STOP_SPEED = 100 * MULTIPLIER
const MAX_SPEED = 320 * MULTIPLIER
const ACCELERATE = 10 * MULTIPLIER

static func SV_UserFriction(velocity):
	var speed = sqrt(velocity.x * velocity.x + velocity.z * velocity.z)
	if speed == 0:
		return velocity
	
	var control = STOP_SPEED if speed < STOP_SPEED else speed
	var newspeed = speed - control * FRICTION

	if newspeed < 0:
		newspeed = 0

	return velocity.normalized() * newspeed

static func SV_Accelerate(velocity, wishdir, wishspeed):
	var currentspeed = velocity.dot(wishdir)
	var addspeed = wishspeed - currentspeed
	if addspeed <= 0:
		return velocity
	var accelspeed = ACCELERATE * wishspeed
	if accelspeed > addspeed:
		accelspeed = addspeed

	return velocity + wishdir * accelspeed

static func SV_AirAccelerate(velocity, wishdir, wishspeed):
	if wishspeed > 30:
		wishspeed = 30
	return SV_Accelerate(velocity, wishdir, wishspeed)

static func SV_AirMove(player, velocity, fmove, smove, forward, right, onground):
	var wishvel = Vector3(
		forward.x * fmove + right.x * smove,
		0,
		forward.z * fmove + right.z * smove,
	)

	var wishspeed = wishvel.length()
	var wishdir = wishvel.normalized()
	
	player.debug_wishdir = wishdir

	if wishspeed > MAX_SPEED:
		wishvel *= MAX_SPEED / wishspeed
		wishspeed = MAX_SPEED

	var new_velocity = velocity
	if onground and not Input.is_action_pressed("move_jump"):
		new_velocity = SV_UserFriction(new_velocity)
		new_velocity = SV_Accelerate(new_velocity, wishdir, wishspeed)
	else:
		new_velocity = SV_AirAccelerate(new_velocity, wishdir, wishspeed)
	
	return new_velocity

static func move(player, velocity, fmove, smove, forward, right, onground, delta):
	var vertical := move_vertical(velocity, onground, delta)

	velocity.y = 0
	var horizonal = SV_AirMove(player, velocity, fmove * FORWARD_SPEED, smove * SIDE_SPEED, forward, right, onground)
		
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
