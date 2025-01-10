class_name TauntBuff extends Buff

func _init() -> void:
	type = Enums.BuffType.TAUNT
	add_type = Enums.BuffAddType.STACKS_AND_OVERLAPS

var part: Particle
func on_activate() -> void:
	host.stop_channeling(Enums.ChannelingStopCondition.CANCEL, Enums.ChannelingStopSource.STUNNED_OR_SILENCED_OR_TAUNTED)
	host.status.taunted = true
	if attacker is Champion:
		host.apply_assist_marker(attacker, 10)
	#TODO: var attackerName = attacker.skin_name # UNUSED
	var team_id := attacker.team
	#if host.buffs.count(GalioIdolOfDurandMarkerBuff, attacker) > 0:
	#	part = Particle.create(preload("galio_taunt_unit_indicator.tscn")).fow(team_id, 10).bind(host, "head").target(host)
	#if host.Buffs.count(ShenShadowDashCooldownBuff, attacker) > 0:
	#	part = Particle.create(preload("Global_Taunt_multi_unit.tscn")).fow(team_id, 10).bind(host, "head").target(host)
	#	Particle.create(preload("shen_shadowDash_unit_impact.tscn")).fow(team_id, 10).bind(host).target(host).more_flags(true)
	#if host.Buffs.count(PuncturingTauntArmorDebuffBuff, attacker) > 0:
	#	part = Particle.create(preload("global_taunt.tscn")).fow(team_id, 10).bind(host, "head").target(target)

func on_deactivate(expired: bool) -> void:
	host.status.taunted = false
	if part != null: part.remove()

func on_update_stats() -> void:
	if attacker.status.is_dead:
		remove_self()
	else:
		host.status.taunted = true
