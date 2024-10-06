class_name Hero
extends AI

var FEAR_WANDER_DISTANCE := 500

func on_init() -> bool:
	clear_target_pos_in_pos()
	set_state(Enums.AIState.IDLE)
	init_timer(timer_distance_scan, 0.2, true)
	init_timer(timer_check_attack, 0.2, true)
	init_timer(timer_feared, 1, true)
	stop_timer(timer_feared)
	return false

func on_order(order_type: Enums.OrderType, position: Vector3, target: Unit) -> bool:
	if get_state() in [
		Enums.AIState.HALTED,
		Enums.AIState.TAUNTED,
		Enums.AIState.FEARED,
		Enums.AIState.CHARMED,
	]: return false

	match order_type:
		Enums.OrderType.TAUNT:
			set_state_and_close_to_target(Enums.AIState.HARDATTACK, target)
			clear_target_pos_in_pos()
			return true
		Enums.OrderType.ATTACK_TO:
			set_state_and_close_to_target(Enums.AIState.HARDATTACK, target)
			assign_target_pos_in_pos(position)
			if target_in_attack_range():
				turn_on_auto_attack(get_target())
			else:
				turn_off_auto_attack(Enums.ReasonToTurnOffAA.MOVING)
			return true
		Enums.OrderType.ATTACK_MOVE:
			target = find_target_in_ac_r()
			if target != null:
				set_state_and_close_to_target(Enums.AIState.SOFTATTACK, target)
			else:
				set_state_and_move_in_pos(Enums.AIState.ATTACKMOVE, position)
				assign_target_pos_in_pos(position)
			return true
		Enums.OrderType.MOVE_TO:
			set_state_and_move_in_pos(Enums.AIState.MOVE, position)
			assign_target_pos_in_pos(position)
			return true
	timer_check_attack()
	return false

func on_target_lost(reason: Enums.ReasonForTargetLoss, lost_target: Unit) -> void:
	#var state := get_state()
	if state == Enums.AIState.HALTED:
		return
	if state != Enums.AIState.ATTACK_GOING_TO_LAST_KNOWN_LOCATION:
		if (
			reason == Enums.ReasonForTargetLoss.LOST_VISIBILITY and
			state != Enums.AIState.SOFTATTACK and
			lost_target != null
		):
			set_state_and_close_to_target(Enums.AIState.ATTACK_GOING_TO_LAST_KNOWN_LOCATION, lost_target)
		else:
			timer_check_attack()

func on_taunt_begin() -> void:
	if get_state() == Enums.AIState.HALTED: return

	var taunt_target := get_taunt_target()
	if taunt_target != null:
		set_state_and_close_to_target(Enums.AIState.TAUNTED, taunt_target)

func on_taunt_end() -> void:
	if get_state() == Enums.AIState.HALTED: return

	var taunt_target := get_taunt_target()
	if taunt_target != null:
		set_state_and_close_to_target(Enums.AIState.SOFTATTACK, taunt_target)
	else:
		net_set_state(Enums.AIState.IDLE)
		timer_distance_scan()
		timer_check_attack()

func on_fear_begin() -> void:
	if get_state() == Enums.AIState.HALTED: return

	var wander_point := make_wander_point(get_fear_leash_point(), FEAR_WANDER_DISTANCE)
	set_state_and_move(Enums.AIState.FEARED, wander_point)
	turn_off_auto_attack(Enums.ReasonToTurnOffAA.MOVING)
	reset_and_start_timer(timer_feared)

func on_fear_end() -> void:
	if get_state() == Enums.AIState.HALTED: return

	stop_timer(timer_feared)
	net_set_state(Enums.AIState.IDLE)
	timer_distance_scan()
	timer_check_attack()

func timer_feared() -> Variant: # -> bool?
	if get_state() == Enums.AIState.HALTED: return null

	var wander_point := make_wander_point(get_fear_leash_point(), FEAR_WANDER_DISTANCE)
	set_state_and_move(Enums.AIState.FEARED, wander_point)
	return null

func on_charm_begin() -> void:
	if get_state() == Enums.AIState.HALTED: return

	net_set_state(Enums.AIState.CHARMED)
	turn_off_auto_attack(Enums.ReasonToTurnOffAA.IMMEDIATELY)
	timer_check_attack()

func on_charm_end() -> void:
	if get_state() == Enums.AIState.HALTED: return

	net_set_state(Enums.AIState.IDLE)
	timer_distance_scan()
	timer_check_attack()

func on_stop_move() -> void:
	if get_state() == Enums.AIState.HALTED: return

	clear_target_pos_in_pos()

func timer_check_attack() -> Variant: # -> bool?
	#var state := get_state()
	if state == Enums.AIState.HALTED: return null

	if state in [
		Enums.AIState.SOFTATTACK,
		Enums.AIState.HARDATTACK,
		Enums.AIState.TAUNTED,
		Enums.AIState.CHARMED
	]:
		if is_target_lost() or get_target() == null:
			if !last_auto_attack_finished():
				init_timer(timer_check_attack, 0.1, true)
				return false
			var target := find_target_in_ac_r()
			if target != null:
				if state == Enums.AIState.CHARMED:
					set_state_and_close_to_target(Enums.AIState.CHARMED, target)
				elif can_see_me(target):
					set_state_and_close_to_target(Enums.AIState.SOFTATTACK, target)
				#return true
			else:
				if state == Enums.AIState.CHARMED:
					spell_buff_remove_type(me, Enums.BuffType.TAUNT)
				net_set_state(Enums.AIState.STANDING)
				#return true
			return true
		if target_in_attack_range():
			turn_on_auto_attack(get_target())
			return true
		if !target_in_cancel_attack_range():
			turn_off_auto_attack(Enums.ReasonToTurnOffAA.MOVING)
	elif is_moving():
		return false
	init_timer(timer_check_attack, 0.1, true)
	return null

func timer_distance_scan() -> Variant: # -> bool?
	match get_state():
		Enums.AIState.HALTED, Enums.AIState.HARDIDLE:
			return null
		Enums.AIState.STANDING, Enums.AIState.IDLE:
			var target := get_target_or_find_target_in_ac_r()
			if target != null and can_see_me(target):
				set_state_and_close_to_target(Enums.AIState.SOFTATTACK, target)
				return true
		Enums.AIState.MOVE: if is_movement_stopped():
			var target := get_target_or_find_target_in_ac_r()
			if target != null and can_see_me(target):
				set_state_and_close_to_target(Enums.AIState.SOFTATTACK, target)
				turn_on_auto_attack(target)
				return true
			net_set_state(Enums.AIState.IDLE)
			return false
		Enums.AIState.ATTACKMOVE:
			var target := get_target_or_find_target_in_ac_r()
			if target != null:
				set_state_and_close_to_target(Enums.AIState.SOFTATTACK, target)
				return true
			if distance_between_object_and_target_pos_sq(me) <= 100:
				net_set_state(Enums.AIState.STANDING)
				clear_target_pos_in_pos()
				return true
		Enums.AIState.ATTACK_GOING_TO_LAST_KNOWN_LOCATION:
			var target := get_lost_target_if_visible()
			if target != null:
				set_state_and_close_to_target(Enums.AIState.HARDATTACK, target)
	return null

func timer_flee() -> void:
	if get_state() == Enums.AIState.HALTED: return

	var wander_point := make_flee_point()
	set_state_and_move(Enums.AIState.FLEEING, wander_point)

func on_AI_command() -> void:
	if get_state() == Enums.AIState.HALTED: return

func on_reached_destination_for_going_to_last_location() -> void:
	if get_state() == Enums.AIState.HALTED: return

	net_set_state(Enums.AIState.IDLE)
	timer_distance_scan()
	timer_check_attack()

func halt_AI() -> void:
	stop_timer(timer_distance_scan)
	stop_timer(timer_check_attack)
	stop_timer(timer_feared)
	turn_off_auto_attack(Enums.ReasonToTurnOffAA.IMMEDIATELY)
	net_set_state(Enums.AIState.HALTED)
