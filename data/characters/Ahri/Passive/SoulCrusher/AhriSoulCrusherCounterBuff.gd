class_name AhriSoulCrusherCounterBuff extends Buff

var metadata := BuffMetadata.from({
    buff_name = "AhriSoulCrusherCounter",
    buff_texture_name = "Ahri_SoulEater2.dds",
    persists_through_death = true,
})
func on_activate() -> void:
    if host.buffs.count(AhriSoulCrusherCounterBuff, host) >= 9:
        attacker.buffs.add(attacker, AhriSoulCrusherBuff.new(), 1, 1, 25000, Enums.BuffAddType.REPLACE_EXISTING, Enums.BuffType.COMBAT_ENCHANCER)
        host.buffs.remove_stacks(AhriSoulCrusherCounterBuff, 0, host)
        host.buffs.remove_by_script(AhriIdleParticleBuff, host)
