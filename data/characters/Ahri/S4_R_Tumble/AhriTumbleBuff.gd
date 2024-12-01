class_name AhriTumbleBuff extends Buff

var metadata := BuffMetadata.from({
    auto_buff_activate_effect = [ "" ],
    buff_name = "AhriTumble",
    buff_texture_name = "Ahri_SpiritRush.dds",
    persists_through_death = true,
})
var effect0: Array[float] = [ 90, 80, 70, 0, 0 ]
func on_deactivate(expired: bool) -> void:
    if host.buffs.count(AhriTumbleBuff) == 0:
        var level := host.spells.r.level
        var new_cd := effect0[level - 1]
        var new_cooldown := (1 + host.stats.get_cooldown_percent()) * new_cd
        host.spells.r.set_cooldown(new_cooldown, true)
        host.spells.r.set_cost_inc(0, Enums.PARType.MANA)
