class_name AhriIdleParticleBuff extends Buff

var data: BuffData = preload('AhriIdleParticleBuff.tres')

var particle: Particle
func on_activate() -> void:
	particle = Particle.create(preload("Ahri_Orb.tscn")).bind(host, "BUFFBONE_GLB_WEAPON_1").target(host)
func on_deactivate(expired: bool) -> void:
	particle.remove()
