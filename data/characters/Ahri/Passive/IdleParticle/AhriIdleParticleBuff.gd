class_name AhriIdleParticleBuff extends Buff

var metadata := BuffMetadata.from({
	auto_buff_activate_attach_bone_name = [ "" ],
	auto_buff_activate_effect = [ "" ],
	persists_through_death = true,
})
var particle: Particle
func on_activate() -> void:
	particle = Particle.create(preload("Ahri_Orb.tscn")).bind(host, "BUFFBONE_GLB_WEAPON_1").target(host)
func on_deactivate(expired: bool) -> void:
	particle.remove()
