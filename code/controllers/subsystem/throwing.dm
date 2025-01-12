#define MAX_THROWING_DIST 512 // 2 z-levels on default width
#define MAX_TICKS_TO_MAKE_UP 3 //how many missed ticks will we attempt to make up for this run.

SUBSYSTEM_DEF(throwing)
	name = "Throwing"

	priority = SS_PRIORITY_THROWING
	wait     = SS_WAIT_THROWING

	flags = SS_NO_INIT | SS_KEEP_TIMING | SS_TICKER

	var/list/currentrun
	var/list/processing

/datum/controller/subsystem/throwing/PreInit()
	processing = list()


/datum/controller/subsystem/throwing/stat_entry()
	..("P:[processing.len]")


/datum/controller/subsystem/throwing/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/atom/movable/AM = currentrun[currentrun.len]
		var/datum/thrownthing/TT = currentrun[AM]
		currentrun.len--
		if (!AM || !TT)
			processing -= AM
			if (MC_TICK_CHECK)
				return
			continue

		TT.tick()

		if (MC_TICK_CHECK)
			return

	currentrun = null

/datum/thrownthing
	var/atom/movable/thrownthing
	var/atom/target
	var/turf/target_turf
	var/init_dir
	var/maxrange
	var/speed
	var/mob/thrower
	var/diagonals_first
	var/dist_travelled = 0
	var/start_time
	var/dist_x
	var/dist_y
	var/dx
	var/dy
	var/pure_diagonal
	var/diagonal_error
	var/datum/callback/callback
	var/datum/callback/early_callback // used when you want to call something before throw_impact().

/datum/thrownthing/New(thrownthing, target, target_turf, init_dir, maxrange, speed, thrower, diagonals_first, datum/callback/callback, datum/callback/early_callback)
	src.thrownthing = thrownthing
	src.target = target
	src.target_turf = target_turf
	src.init_dir = init_dir
	src.maxrange = maxrange
	src.speed = speed
	src.thrower = thrower
	src.diagonals_first = diagonals_first
	src.callback = callback
	src.early_callback = early_callback

	if(ismob(thrownthing))
		var/mob/M = thrownthing
		ADD_TRAIT(M, TRAIT_ARIBORN, TRAIT_ARIBORN_THROWN)

	RegisterSignal(thrownthing, COMSIG_PARENT_QDELETING, PROC_REF(on_thrownthing_qdel))

/datum/thrownthing/Destroy()

	if(ismob(thrownthing))
		var/mob/M = thrownthing
		REMOVE_TRAIT(M, TRAIT_ARIBORN, TRAIT_ARIBORN_THROWN)

	SSthrowing.processing -= thrownthing
	SSthrowing.currentrun -= thrownthing
	thrownthing.throwing = null
	thrownthing = null
	target = null
	thrower = null
	target_turf = null
	if(callback)
		QDEL_NULL(callback) //It stores a reference to the thrownthing, its source. Let's clean that.
	if(early_callback)
		QDEL_NULL(early_callback)
	return ..()

///Defines the datum behavior on the thrownthing's qdeletion event.
/datum/thrownthing/proc/on_thrownthing_qdel(atom/movable/source, force)
	SIGNAL_HANDLER

	qdel(src)

/datum/thrownthing/proc/tick()
	var/atom/movable/AM = thrownthing
	if (!isturf(AM.loc) || !AM.throwing)
		finialize()
		return

	if (dist_travelled && hit_check()) //to catch sneaky things moving on our tile while we slept
		finialize()
		return

	var/atom/step

	//calculate how many tiles to move, making up for any missed ticks.
	var/tilestomove = CEIL(min(((((world.time + world.tick_lag) - start_time) * speed) - (dist_travelled ? dist_travelled : -1)), speed * MAX_TICKS_TO_MAKE_UP) * (world.tick_lag * SSthrowing.wait))
	while (tilestomove-- > 0)
		if ((dist_travelled >= maxrange || AM.loc == target_turf) && has_gravity(AM, AM.loc))
			finialize()
			return

		if (dist_travelled <= max(dist_x, dist_y)) //if we haven't reached the target yet we home in on it, otherwise we use the initial direction
			step = get_step(AM, get_dir(AM, target_turf))
		else
			step = get_step(AM, init_dir)

		if (!pure_diagonal && !diagonals_first) // not a purely diagonal trajectory and we don't want all diagonal moves to be done first
			if (diagonal_error >= 0 && max(dist_x,dist_y) - dist_travelled != 1) //we do a step forward unless we're right before the target
				step = get_step(AM, dx)
			diagonal_error += (diagonal_error < 0) ? dist_x/2 : -dist_y

		if (!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
			finialize()
			return

		AM.Move(step, get_dir(AM, step))

		if (!AM.throwing) // we hit something during our move
			finialize(hit = TRUE)
			return

		dist_travelled++

		if (dist_travelled > MAX_THROWING_DIST)
			finialize()
			return

/datum/thrownthing/proc/finialize(hit = FALSE, atom/movable/AM)
	set waitfor = 0
	//done throwing, either because it hit something or it finished moving
	if (QDELETED(thrownthing) || !thrownthing.throwing)
		return

	thrownthing.throwing = FALSE

	if(early_callback)
		early_callback.Invoke()

	if (!hit)
		for (var/thing in get_turf(thrownthing)) //looking for our target on the turf we land on.
			var/atom/A = thing
			if (A == target)
				hit = TRUE
				thrownthing.throw_impact(A, src)
				if(QDELETED(thrownthing)) //throw_impact can delete things, such as glasses smashing
					return //deletion should already be handled by on_thrownthing_qdel()
				break
		if (!hit)
			thrownthing.throw_impact(get_turf(thrownthing), src)  // we haven't hit something yet and we still must, let's hit the ground.
			if(QDELETED(thrownthing)) //throw_impact can delete things, such as glasses smashing
				return //deletion should already be handled by on_thrownthing_qdel()
			thrownthing.newtonian_move(init_dir)
	else
		thrownthing.newtonian_move(init_dir)

	if(AM)
		thrownthing.throw_impact(AM, src)
		if(QDELETED(thrownthing)) //throw_impact can delete things, such as glasses smashing
			return //deletion should already be handled by on_thrownthing_qdel()

	thrownthing.fly_speed = 0
	if (callback)
		callback.Invoke()

	qdel(src)

/datum/thrownthing/proc/hit_check()
	for (var/thing in get_turf(thrownthing))
		var/atom/movable/AM = thing
		if (AM == thrownthing)
			continue
		if (isliving(AM))
			var/mob/living/L = AM
			if (L.lying)
				continue
		if (AM.density && !AM.throwpass)
			finialize(null, AM)
			return TRUE
