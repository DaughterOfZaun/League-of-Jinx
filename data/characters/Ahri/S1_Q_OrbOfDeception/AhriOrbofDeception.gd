class_name AhriOrbOfDeceptionSpell
extends Spell

func self_execute() -> void:
    var targetPos := spell.target_position
    host.face_direction(targetPos)
    targetPos = API.get_point_by_unit_facing_offset(owner, 900, 0)
    host.spells.extra[0].cast(null, targetPos, targetPos, level, true, true)

#var metadata := BuffMetadata.from({
#    auto_buff_activate_attach_bone_name = [ "root" ],
#    auto_buff_activate_effect = [ "Ahri_OrbofDeception.troy" ],
#})
