class_name System
extends Effect

@export var visibility_radius: float

@export_group("Simulation")
@export var build_up_time: float
@export var simulate_every_frame: bool
@export var simulate_once_per_frame: bool
@export var simulate_while_off_screen: bool
@export_group("Voice And Sound")
@export var sound_on_create: String
@export var sound_persistent: String
@export var voice_over_on_create: String
@export var voice_over_persistent: String
@export var sounds_play_while_off_screen: bool
@export_group("Metadata")
@export var keep_orientation_after_spell_cast: bool
@export var persist_thru_death: bool

func set_from_ini(d: Dictionary):
    var key_array := []
    var value = ""
    match key_array:
        ["build-up-time"]: build_up_time = float_parse(value)
        ["group-vis"]: visibility_radius = float_parse(value)
        ["GroupPart", var i, "Importance"]: pass
        ["GroupPart", var i, "Type"]: pass
        ["GroupPart", var i]: pass
        ["KeepOrientationAfterSpellCast"]: keep_orientation_after_spell_cast = bool_parse(value)
        ["MaterialOverride", var i, "BlendMode"]: pass
        ["MaterialOverride", var i, "Priority"]: pass
        ["MaterialOverride", var i, "SubMesh"]: pass
        ["MaterialOverride", var i, "Texture"]: pass
        ["MaterialOverrideTransMap"]: pass
        ["PersistThruDeath"]: persist_thru_death = bool_parse(value)
        #1 ["SelfIllumination"]: self_illumination = float_parse(value) # bool?
        ["SimulateEveryFrame"]: simulate_every_frame = bool_parse(value)
        ["SimulateOncePerFrame"]: simulate_once_per_frame = bool_parse(value)
        ["SimulateWhileOffScreen"]: simulate_while_off_screen = bool_parse(value)
        ["SoundOnCreate"]: sound_on_create = string_parse(value)
        ["SoundPersistent"]: sound_persistent = string_parse(value)
        ["SoundsPlayWhileOffScreen"]: sounds_play_while_off_screen = bool_parse(value)
        ["VoiceOverOnCreate"]: voice_over_on_create = string_parse(value)
        ["VoiceOverPersistent"]: voice_over_persistent = string_parse(value)