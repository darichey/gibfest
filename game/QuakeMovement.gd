extends Object
class_name QuakeMovement

### horizontal movement ###
const WALK_SPEED: float = 10
const FRICTION: float = 4
const STOP_SPEED: float = 100
const MAX_SPEED: float = 320
const ACCELERATE: float = 100

static func apply_friction(cur_vel: Vector3, delta: float) -> Vector3:
	var speed := cur_vel.length()
	if speed < 1:
		return Vector3.ZERO
	
	var drop := speed * FRICTION * delta
	return cur_vel * max(speed - drop, 0) / speed

static func accelerate(cur_vel: Vector3, wishdir: Vector3, max_speed: float, delta: float) -> Vector3:
	var currentspeed := cur_vel.dot(wishdir)
	var addspeed := WALK_SPEED - currentspeed
	if addspeed <= 0:
		return cur_vel
	var accelspeed := minf(ACCELERATE * WALK_SPEED * delta, addspeed)
	return cur_vel + accelspeed * wishdir

static func move_horizontal(cur_vel: Vector3, wishdir: Vector3, onground: bool, delta: float) -> Vector3:
	var cur_vel_xz = Plane.PLANE_XZ.project(cur_vel)
	var new_vel := cur_vel
	if onground:
		new_vel = apply_friction(new_vel, delta)
		new_vel = accelerate(new_vel, wishdir, MAX_SPEED, delta)
	else:
		new_vel = accelerate(new_vel, wishdir, MAX_SPEED, delta)
	
	return new_vel
	
### vertical movement ###
const AUTO_HOP := true
const JUMP_SPEED := 4.5
static var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

static func apply_gravity(cur_speed: float, onground: bool, delta: float) -> float:
	if onground:
		return 0
	else:
		return cur_speed - gravity * delta

static func should_jump(onground: bool) -> bool:
	if AUTO_HOP:
		return Input.is_action_pressed("move_jump") and onground
	else:
		return Input.is_action_just_pressed("move_jump") and onground

static func apply_jump(onground: bool, delta: float) -> float:
	if should_jump(onground):
		return JUMP_SPEED
	else:
		return 0
		
static func move_vertical(cur_speed: float, onground: bool, delta: float) -> float:
	return apply_gravity(cur_speed, onground, delta) + apply_jump(onground, delta)
		
### movement ###
static func move(cur_vel: Vector3, wishdir: Vector3, onground: bool, delta: float) -> Vector3:
	var horizonal := move_horizontal(cur_vel, wishdir, onground, delta)
	var vertical := move_vertical(cur_vel.y, onground, delta)
	
	return Vector3(
		horizonal.x,
		vertical,
		horizonal.z
	)
