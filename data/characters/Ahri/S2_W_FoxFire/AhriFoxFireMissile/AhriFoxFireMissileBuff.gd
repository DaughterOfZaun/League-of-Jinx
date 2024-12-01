class_name AhriFoxFireMissileBuff extends Buff

var metadata := BuffMetadata.from({
    buff_name = "AhriFoxFire",
    buff_texture_name = "Ahri_FoxFire.dds",
})
func on_deactivate(expired: bool) -> void:
    if host.buffs.count(AhriFoxFireMissileBuff) <= 0:
        host.buffs.remove_by_script(AhriFoxFireBuff, host)
