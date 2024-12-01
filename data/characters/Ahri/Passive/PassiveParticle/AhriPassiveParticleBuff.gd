class_name AhriPassiveParticleBuff extends Buff

var metadata := BuffMetadata.from({
    auto_buff_activate_attach_bone_name = [ "" ],
    auto_buff_activate_effect = [ "" ],
    buff_name = "AhriSoulCrusher",
    buff_texture_name = "Ahri_SoulEater.dds",
    persists_through_death = true,
})

var particle_alive: bool
var particle1: Particle
func on_activate() -> void:
    particle_alive = false
    if !host.status.is_dead:
        particle1 = Particle.create("Ahri_Passive.troy").fow(host.team, 10).bind(host, "BUFFBONE_GLB_WEAPON_1").target(host)
        particle_alive = true

func on_deactivate(expired: bool) -> void:
    particle1.remove()

func on_death(attacker: Unit) -> void:
    particle1.remove()
    particle_alive = false

func on_resurrect() -> void:
    if particle_alive:
        particle1.remove()
        particle_alive = false
    particle1 = Particle.create("Ahri_Passive.troy").bind(host, "BUFFBONE_GLB_WEAPON_1").target(host)
