class_name AhriSeduceBuff extends Buff

const data: BuffData = preload('AhriSeduceBuff.tres')

var slow_percent: float
var particle1: Particle
var particle2: Particle
var particle3: Particle
func _init(slow_percent: float = 0.0) -> void:
	self.slow_percent = slow_percent
func clone() -> Buff:
	return new(slow_percent)

func on_activate() -> void:
	#require_var(self.slow_percent)
	host.status.can_attack = false
	host.apply_assist_marker(attacker, 10)
	particle1 = Particle.create(preload("Ahri_Charm_buf.tscn")).bind(host, "head").target(host)
	particle2 = Particle.create(preload("Ahri_Charm_buf.tscn")).bind(host, "l_hand").target(host)
	particle3 = Particle.create(preload("Ahri_Charm_buf.tscn")).bind(host, "r_hand").target(host)
	if host is Champion:
		host.issue_order(Enums.OrderType.MOVE_TO, Vector3.INF, attacker)

func on_deactivate(expired: bool) -> void:
	host.status.can_attack = true
	host.stop_move()
	particle1.remove()
	particle2.remove()
	particle3.remove()

func on_update_stats() -> void:
	host.status.can_attack = false
	host.stats.movement_speed_percent_multiplicative_temp += slow_percent
	host.stats.attack_range_flat_temp -= 600
