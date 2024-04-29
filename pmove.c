const FRICTION = 4
const STOP_SPEED = 100
const MAX_SPEED = 320
const ACCELERATE = 10

// unit vectors with no y component
var forward: vec3
var right: vec3

var fmove: float
var smove: float
var cur_vel: vec3
var frametime: float
var onground: bool

void PM_Friction()
{
	float speed = vel.length();
	if (speed < 1)
	{
		vel[0] = 0;
		vel[1] = 0;
		return;
	}

	float control = speed < STOP_SPEED ? STOP_SPEED : speed;
	float drop = control*FRICTION*frametime;

// scale the velocity
	newspeed = speed - drop;
	if (newspeed < 0)
		newspeed = 0;
	newspeed /= speed;

    vel *= newspeed;
}

void PM_Accelerate(vec3 wishdir, float wishspeed)
{
	float currentspeed = cur_vel.dot(wishdir);

	float addspeed = wishspeed - currentspeed;
	if (addspeed <= 0)
		return;

	float accelspeed = min(ACCELERATE * wishspeed * frametime, addspeed);

    cur_vel += accelspeed * wishdir
}

void PM_AirAccelerate(vec3 wishdir, float wishspeed)
{
	float currentspeed = cur_vel.dot(wishdir);

	float addspeed = min(30, wishspeed) - currentspeed;
	if (addspeed <= 0)
		return;

	float accelspeed = min(ACCELERATE * wishspeed * frametime, addspeed);

    cur_vel += accelspeed * wishdir
}

void PM_AirMove()
{	
    vec3 wishvel = vec3(
        forward.x*fmove + right.x*smove,
        0,
        forward.z*fmove + right.z*smove,
    );
	
    vec3 wishdir = wishvel.normalized();
	float wishspeed = wishvel.length();

//
// clamp to server defined max speed
//
	if (wishspeed > MAX_SPEED)
	{
        wishvel *= MAX_SPEED / wishspeed
		wishspeed = MAX_SPEED;
	}

	if (onground)
	{
        PM_Friction();
		PM_Accelerate(wishdir, wishspeed);
	}
	else
	{	// not on ground, so little effect on velocity
		PM_AirAccelerate(wishdir, wishspeed);
	}

}
