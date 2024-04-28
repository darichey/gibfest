float FRICTION = ...;
float STOP_SPEED = ...;
float MAX_SPEED = ...;
float ACCELERATE = ...;

Vector3 SV_UserFriction(Vector3 cur_vel, float delta) {
	float speed = cur_vel.project(xz_plane).length();
	if (speed == 0)
		return;

	float control = speed < STOP_SPEED ? STOP_SPEED : speed;
	float newspeed = speed - host_frametime * control * FRICTION;
	
	if (newspeed < 0)
		newspeed = 0;
	newspeed /= speed;

	return cur_vel * newspeed;
}

Vector3 SV_Accelerate(Vector3 cur_vel, Vector3 wishdir, float wishspeed, float delta) {
	float currentspeed = cur_vel.dot(wishdir);
	float addspeed = wishspeed - currentspeed;
	if (addspeed <= 0)
		return;
	float accelspeed = ACCELERATE * wishspeed * delta;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

    return cur_vel + accelspeed * wishdir;
}

Vector3 SV_AirAccelerate(Vector3 cur_vel, Vector3 wishveloc, float wishspeed, float delta) {
    float wishspd = wishveloc.length()
    if (wishspd > 30)
		wishspd = 30;
    wishveloc = wishveloc.normalize()

	float currentspeed = cur_vel.dot(wishveloc);
	float addspeed = wishspd - currentspeed;
	if (addspeed <= 0)
		return;
	float accelspeed = ACCELERATE * wishspeed * delta;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

    return cur_vel + accelspeed * wishveloc;
}

Vector3 SV_AirMove(Vector3 cur_vel, float fmove, float smove, Vector3 forward, Vector3 right, Vector3 up, float delta, bool onground) {
    Vector3 wishvel = Vector3(
        forward.x * fmove + right.x * smove,
        0,
        forward.z * fmove + right.z * smove
    );

    Vector3 wishdir = wishvel.normalize();
    float wishspeed = wishvel.length();

	if (wishspeed > MAX_SPEED) {
        wishvel *= MAX_SPEED / wishspeed
		wishspeed = MAX_SPEED;
	}

    Vector3 new_vel = cur_vel;
    if (onground) {
		new_vel = SV_UserFriction(new_vel, delta);
		new_vel = SV_Accelerate(new_vel, wishdir, wishspeed, delta);
	} else {
		new_vel = SV_AirAccelerate(new_vel, wishdir, wishspeed, delta);
	}
    return new_vel;
}
