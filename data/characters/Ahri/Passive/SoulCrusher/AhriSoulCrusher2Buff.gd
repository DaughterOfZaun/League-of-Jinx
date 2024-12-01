class_name AhriSoulCrusher2Buff extends Buff

var metadata := BuffMetadata.from({
    auto_buff_activate_effect = [
        "PotionofElusiveness_itm.troy",
        "PotionofBrilliance_itm.troy",
        "PotionofGiantStrength_itm.troy",
    ],
    buff_name = "AhriSoulCrusher",
    buff_texture_name = "3017_Egitai_Twinsoul.dds",
    persists_through_death = true,
})
func on_deactivate(expired: bool) -> void:
    vars.tumble_is_active = 0