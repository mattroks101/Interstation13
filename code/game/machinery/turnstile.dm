/obj/machinery/turnstile
	name = "turnstile"
	desc = "A mechanical door that permits one-way access and prevents tailgating."
	icon = 'icons/obj/turnstile.dmi'
	icon_state = "turnstile_map"
	power_channel = ENVIRON
	density = FALSE
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 10, bio = 100, rad = 100, fire = 90, acid = 70)
	anchored = TRUE
	use_power = FALSE
	idle_power_usage = 2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = OPEN_DOOR_LAYER

/obj/machinery/turnstile/Initialize()
	. = ..()
	icon_state = "turnstile"
	update_icon()

/obj/machinery/turnstile/CanAtmosPass(turf/T)
	return TRUE

/obj/machinery/turnstile/bullet_act(obj/item/projectile/P, def_zone)
	return -1 //Pass through!

/obj/machinery/turnstile/update_icon()
	cut_overlays()
	..()
	if(!(stat & NOPOWER) && dir)
		switch(dir)
			if(NORTH)
				var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_n") //layer=src.layer+1
				I.pixel_y = 32
				set_light(l_range = 2, l_power = 1)
				add_overlay(I)
			if(SOUTH)
				var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_s") //layer=src.layer+1
				I.pixel_y = -32
				set_light(l_range = 2, l_power = 1)
				add_overlay(I)
			if(EAST)
				var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_e") //layer=src.layer+1
				I.pixel_x = 32
				set_light(l_range = 2, l_power = 1)
				add_overlay(I)
			if(WEST)
				var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_w") //layer=src.layer+1
				I.pixel_x = -32
				set_light(l_range = 2, l_power = 1)
				add_overlay(I)
	else
		set_light(0)

/obj/machinery/turnstile/CanPass(atom/movable/AM, turf/T)
	if(ismob(AM))
		var/mob/B = AM
		if(isliving(AM))
			var/mob/living/M = AM

			if(world.time - M.last_bumped <= 5)
				return FALSE
			M.last_bumped = world.time

			var/allowed_access = FALSE
			var/turf/behind = get_step(src, dir)

			if(B in behind.contents)
				if(B.pulledby && ismob(B.pulledby))
					allowed_access = allowed(B.pulledby) | allowed(B)
				else
					allowed_access = allowed(B)
			else
				to_chat(usr, "<span class='notice'>\the [src] resists your efforts.</span>")
				return FALSE

			if(allowed_access)
				flick("operate", src)
				playsound(src,'sound/items/ratchet.ogg',50,0,3)
				return TRUE
			else
				flick("deny", src)
				playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)
				return FALSE
	if(ispath(AM, /obj/item/))
		return TRUE
	else
		return FALSE

/obj/machinery/turnstile/CheckExit(atom/movable/AM as mob|obj, target)
	if(isliving(AM))
		var/mob/living/M = AM
		var/outdir = dir
		if(allowed(M))
			switch(dir)
				if(NORTH)
					outdir = SOUTH
				if(SOUTH)
					outdir = NORTH
				if(EAST)
					outdir = WEST
				if(WEST)
					outdir = EAST
		var/turf/outturf = get_step(src, outdir)
		var/canexit = (target == src.loc) | (target == outturf)

		if(!canexit && world.time - M.last_bumped <= 5)
			to_chat(usr, "<span class='notice'>\the [src] resists your efforts.</span>")
		M.last_bumped = world.time
		return canexit
	else
		return TRUE
