extends Object
class_name QuakeMovement

const FORWARD_SPEED := 400.0
const SIDE_SPEED = 200.0

const MAX_SPEED := 400.0
const STOP_SPEED := 100.0
const FRICTION := 10.0
const ACCELERATE := 5.5

static func apply_friction(cur_vel: Vector3, delta: float) -> Vector3:
	var speed := Plane.PLANE_XZ.project(cur_vel).length()
	if speed < 1:
		return Vector3(0, cur_vel.y, 0)
	
	var control := STOP_SPEED if speed < STOP_SPEED else speed
	var newspeed := speed - delta * control * FRICTION
	
	if newspeed < 0:
		newspeed = 0
	newspeed /= speed
	
	return cur_vel * newspeed

static func accelerate(cur_vel: Vector3, wishdir: Vector3, wishspeed: float, delta: float) -> Vector3:
	var currentspeed := cur_vel.dot(wishdir)
	var addspeed := wishspeed - currentspeed
	
	if addspeed <= 0:
		return cur_vel
		
	var accelspeed := ACCELERATE * wishspeed * delta
	if accelspeed > addspeed:
		accelspeed = addspeed
	
	return cur_vel + accelspeed * wishdir
	
static func air_accelerate(cur_vel: Vector3, wishveloc: Vector3, wishspeed: float, delta: float) -> Vector3:
	return cur_vel

static func move(cur_vel: Vector3, wishdir: Vector3, onground: bool, delta: float) -> Vector3:
	var wishvel := Vector3(
		wishdir.x * FORWARD_SPEED,
		0,
		wishdir.z * SIDE_SPEED
	)
	var wishspeed := wishvel.length()
	
	if wishspeed > MAX_SPEED:
		wishvel *= MAX_SPEED / wishspeed
		wishspeed = MAX_SPEED
		
	var new_vel := cur_vel
	if onground:
		new_vel = apply_friction(new_vel, delta)
		new_vel = accelerate(new_vel, wishdir, wishspeed, delta)
	else:
		new_vel = air_accelerate(new_vel, wishdir, wishspeed, delta)
	
	return new_vel
