class_name AhriIdleParticleBuff
extends Buff

var metadata := BuffMetadata.from({
    auto_buff_activate_attach_bone_name = [ "" ],
    auto_buff_activate_effect = [ "" ],
    persists_through_death = true,
})
var particle: Particle
func on_activate():
    particle = Particle.create("Ahri_Orb.troy").bind(owner, "BUFFBONE_GLB_WEAPON_1").target(owner)
func on_deactivate(expired: bool):
    particle.Remove()
