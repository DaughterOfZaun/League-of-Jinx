class_name AhriSoulCrusherBuff extends Buff

var metadata := BuffMetadata.from({
    auto_buff_activate_attach_bone_name = [ "" ],
    auto_buff_activate_effect = [ "" ],
    buff_name = "AhriSoulCrusher",
    buff_texture_name = "Ahri_SoulEater.dds",
    persists_through_death = true,
})
func on_activate() -> void:
    host.buffs.add(host, AhriPassiveParticleBuff.new())
func on_deactivate(expired: bool) -> void:
    host.buffs.add(host, AhriIdleParticleBuff.new())
    host.buffs.remove_by_script(AhriPassiveParticleBuff, host)
