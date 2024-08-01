import { promises as fs } from 'fs'
import { argv } from 'process'

const makeid = (length: number) => {
    let result = '';
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    for (let counter = 0; counter < length; counter++)
        result += characters[(Math.random() * characters.length) | 0];
    return result;
}

type Ctr<T> = new () => T

class BoxedArray<T extends Values> {
    ctr: Ctr<T>
    value: T[]
    changed = false
    constructor(ctr: Ctr<T>, value: T[] = []){
        this.ctr = ctr as Ctr<T>
        this.value = value
    }
    get(i: number): T {
        this.changed = true
        let a = this.value
        while(i >= a.length)
            a.push(new this.ctr())
        return a[i]
    }
    stringify(): string {
        return `[${this.value.map((v: T) => v.stringify()).join(', ')}]`
    }
}

let res: Texture2D[] = []    
class Texture2D {
    id: string | undefined
    value: string
    changed = false
    constructor(value: string = ''){ this.value = value }
    set(from: string): void {
        this.changed = true
        this.value = BoxedString.parse(from)
    }
    stringify(): string {
        if(this.value === '')
            return 'null'
        if(this.id === undefined){
            this.id = `${res.length + 1}_${makeid(5)}`
            res.push(this)
        }
        return `ExtResource("${this.id}")`
    }
}

class BoxedString {
    value: string
    changed = false
    constructor(value: string = ''){ this.value = value }
    set(from: string): void {
        this.changed = true
        this.value = BoxedString.parse(from)
    }
    static parse(from: string): string {
        return from.replace(/^"(.*)"$/, '$1')
    }
    stringify(): string {
        return `"${this.value}"`
    }
}

class BoxedInteger {
    value: number
    changed = false
    constructor(value: number = 0){ this.value = value }
    set(from: string): void {
        this.changed = true
        this.value = BoxedInteger.parse(from)
    }
    static parse(from: string): number {
        let ret = parseFloat(from)
        if(isNaN(ret) || ret % 1 > 0)
            throw new Error(`Expected int, got "${from}"`)
        return ret
    }
    stringify(): string {
        return `${this.value}`
    }
}

class BoxedFloat {
    value: number
    changed = false
    constructor(value: number = 0){ this.value = value }
    set(from: string): void {
        this.changed = true
        this.value = BoxedFloat.parse(from)
    }
    static parse(from: string): number {
        let ret = parseFloat(from)
        if(isNaN(ret))
            throw new Error(`Expected float, got "${from}"`)
        return ret
    }
    stringify(): string {
        return `${this.value}`
    }
}

class Vector3 {
    value: number[]
    changed = false
    static get ZERO(){ return new Vector3([0, 0, 0]) }
    constructor(value: number[] = [0, 0, 0]){ this.value = value }
    set(from: string): void {
        this.changed = true
        this.value = Vector3.parse(from)
    }
    static parse(from: string): number[] {
        let v = from.split(' ').map(v => parseFloat(v))
        if(v.length != 3 || v.some(d => isNaN(d)))
            throw new Error(`Expected Vector3, got "${from}"`)
        return v
    }
    stringify(){
        return `Vector3(${this.value[0]}, ${this.value[1]}, ${this.value[2]})`
    }
}

class BoxedBoolean {
    value: boolean
    changed = false
    constructor(value: boolean = false){ this.value = value }
    set(from: string): void {
        this.changed = true
        this.value = BoxedBoolean.parse(from)
    }
    static parse(from: string): boolean {
        let ret: boolean
        from = from.toLowerCase()
        if(["true", "yes"].includes(from))
            ret = true
        else if(["false", "no"].includes(from))
            ret = false
        else {
            let i = BoxedInteger.parse(from)
            if(i == 0 || i == 1) ret = !!i;
            else throw new Error(`Expected bool, got "${from}"`);
        }
        return ret
    }
    stringify(): string {
        return this.value ? 'true' : 'false'
    }
}

type Values = BoxedArray<Values>|Texture2D|BoxedString|BoxedInteger|BoxedFloat|Vector3|BoxedBoolean

class Output {
    
    [key: string]: Values

    inventory_icon = new BoxedArray(Texture2D)
    spell_name = new BoxedString()
    display_name = new BoxedString()
    alternate_name = new BoxedString()
    description = new BoxedString()
    level_desc = new BoxedArray(BoxedString)

    dynamic_tooltip = new BoxedString()
    dynamic_extended = new BoxedString()
    float_statics_decimals = new BoxedArray(BoxedInteger)
    float_vars_decimals = new BoxedArray(BoxedInteger)
    effect_level_amount = new BoxedArray(function(){ return new BoxedArray(BoxedFloat) } as unknown as Ctr<BoxedArray<BoxedFloat>>)

    cast_time = new BoxedFloat()
    override_cast_time = new BoxedFloat()
    channel_duration = new BoxedFloat()
    channel_duration_by_level = new BoxedArray(BoxedFloat)
    mana_cost = new BoxedFloat()
    mana_cost_by_level = new BoxedArray(BoxedFloat)

    cooldown = new BoxedFloat()
    cooldown_by_level = new BoxedArray(BoxedFloat)
    auto_cooldown_by_level = new BoxedArray(BoxedFloat)
    subject_to_global_cooldown = new BoxedBoolean()
    triggers_global_cooldown = new BoxedBoolean()

    cast_frame = new BoxedFloat()
    animation_name = new BoxedString()
    animation_loop_name = new BoxedString()
    animation_winddown_name = new BoxedString()
    use_animator_framerate = new BoxedBoolean()

    targetting_type = new BoxedInteger //Enums.TargetingType.TARGET()
    selection_preference = new BoxedInteger //Enums.SpellSelectPref.NONE()
    cast_target_additional_units_radius = new BoxedFloat()
    location_targetting_width = new BoxedFloat()
    location_targetting_width_by_level = new BoxedArray(BoxedFloat)
    location_targetting_length = new BoxedFloat()
    location_targetting_length_by_level = new BoxedArray(BoxedFloat)
    use_minimap_targeting = new BoxedBoolean()
    cast_cone_angle = new BoxedFloat()
    cast_cone_distance = new BoxedFloat()
    lock_cone_to_player = new BoxedBoolean()
    cast_radius_primary = new BoxedFloat()
    cast_radius_texture = new Texture2D()
    cast_radius_secondary = new BoxedFloat()
    cast_radius_secondary_texture = new Texture2D()
    cast_range = new BoxedFloat()
    cast_range_by_level = new BoxedArray(BoxedFloat)
    cast_range_display_override = new BoxedInteger()
    cast_range_display_override_by_level = new BoxedArray(BoxedFloat)
    cast_range_use_bounding_boxes = new BoxedBoolean()
    cast_range_use_map_scaling = new BoxedBoolean()
    cast_range_indicator_texture = new Texture2D()
    flags = new BoxedInteger //Enums.SpellFlags.DEFAULT()

    have_after_effect = new BoxedBoolean()
    after_effect_name = new BoxedString()

    have_hit_bone = new BoxedBoolean()
    hit_bone_name = new BoxedString()

    have_hit_effect = new BoxedBoolean()
    hit_effect_name = new BoxedString()

    have_point_effect = new BoxedBoolean()
    point_effect_name = new BoxedString()

    particle_start_offset = new Vector3()
    sound_cast_name = new BoxedString()
    sound_hit_name = new BoxedString()

    spell_fx_override_skins = new BoxedArray(BoxedString)
    spell_vo_override_skins = new BoxedArray(BoxedString)

    cast_type = new BoxedInteger //Enums.CastType.INSTANT()
    override_force_spell_cancel = new BoxedBoolean()
    override_force_spell_animation = new BoxedBoolean()
    delay_cast_offset_percent = new BoxedFloat()
    delay_total_time_percent = new BoxedFloat()
    always_snap_facing = new BoxedBoolean()
    spell_reveals_champion = new BoxedBoolean()
    can_cast_while_disabled = new BoxedBoolean()
    cannot_be_suppressed = new BoxedBoolean()
    can_only_cast_while_dead = new BoxedBoolean()
    cant_cancel_while_channeling = new BoxedBoolean()
    cant_cancel_while_winding_up = new BoxedBoolean()
    cant_cast_while_rooted = new BoxedBoolean()
    is_disabled_while_dead = new BoxedBoolean()
    is_toggle_spell = new BoxedBoolean()
    missile_accel = new BoxedFloat()
    missile_bone_name = new BoxedString()
    missile_effect = new BoxedString()
    missile_fixed_travel_time = new BoxedFloat()
    missile_gravity = new BoxedFloat()
    missile_lifetime = new BoxedFloat()
    missile_max_speed = new BoxedFloat()
    missile_min_speed = new BoxedFloat()
    missile_perception_bubble_radius = new BoxedFloat()
    missile_perception_bubble_reveals_stealth = new BoxedBoolean()
    missile_speed = new BoxedFloat()
    missile_target_height_augment = new BoxedFloat()
    missile_update_distance_interval = new BoxedFloat()
    line_missile_bounces = new BoxedBoolean()
    line_missile_bounce_radius = new BoxedFloat()
    line_missile_collision_from_start_point = new BoxedBoolean()
    line_missile_delay_destroy_at_end_seconds = new BoxedBoolean()
    line_missile_ends_at_target_point = new BoxedBoolean()
    line_missile_target_height_augment = new BoxedFloat()
    line_missile_time_pulse_between_collision_spell_hits = new BoxedBoolean()
    line_missile_track_units = new BoxedBoolean()
    line_width = new BoxedFloat()
    line_drag_length = new BoxedFloat()
    circle_missile_angular_velocity = new BoxedFloat()
    circle_missile_radial_velocity = new BoxedFloat()
    chain_missile_can_hit_caster = new BoxedBoolean()
    chain_missile_can_hit_enemies = new BoxedBoolean()
    chain_missile_can_hit_friends = new BoxedBoolean()
    chain_missile_can_hit_same_target = new BoxedBoolean()
    chain_missile_can_hit_same_target_consecutively = new BoxedBoolean()
    chain_missile_maximum_hits = new BoxedInteger()
    chain_missile_maximum_hits_by_level = new BoxedArray(BoxedInteger)

    apply_attack_damage = new BoxedBoolean()
    auto_target_damage = new BoxedFloat()
    auto_target_damage_by_level = new BoxedArray(BoxedFloat)
    physical_damage_ratio = new BoxedFloat()
    spell_damage_ratio = new BoxedFloat()
    death_recap_priority = new BoxedFloat()

    casting_breaks_stealth = new BoxedBoolean()
    doesnt_break_shields = new BoxedBoolean()
    is_damaging_spell = new BoxedBoolean()
    not_single_target_spell = new BoxedBoolean()
    triggers_spell_casts = new BoxedBoolean()
    doesnt_trigger_spell_casts = new BoxedBoolean()

    ranks = new BoxedInteger()
    version = new BoxedInteger()
    belongs_to_avatar = new BoxedBoolean()
    platform_enabled = new BoxedBoolean()
    coefficient = new BoxedArray(BoxedFloat)
    x = new BoxedArray(BoxedFloat)
}

var out = new Output()

class Converter {
    set AfterEffectName(value: string){ out.after_effect_name.set(value) }
    set AlternateName(value: string){ out.alternate_name.set(value) }
    set AlwaysSnapFacing(value: string){ out.always_snap_facing.set(value) }
    set AnimationLoopName(value: string){ out.animation_loop_name.set(value) }
    set AnimationName(value: string){ out.animation_name.set(value) }
    set AnimationWinddownName(value: string){ out.animation_winddown_name.set(value) }
    set ApplyAttackDamage(value: string){ out.apply_attack_damage.set(value) }
    set BelongsToAvatar(value: string){ out.belongs_to_avatar.set(value) }
    set BounceRadius(value: string){ out.line_missile_bounce_radius.set(value) }
    set CanCastWhileDisabled(value: string){ out.can_cast_while_disabled.set(value) }
    set CannotBeSuppressed(value: string){ out.cannot_be_suppressed.set(value) }
    set CanOnlyCastWhileDead(value: string){ out.can_only_cast_while_dead.set(value) }
    set CantCancelWhileChanneling(value: string){ out.cant_cancel_while_channeling.set(value) }
    set CantCancelWhileWindingUp(value: string){ out.cant_cancel_while_winding_up.set(value) }
    set CantCastWhileRooted(value: string){ out.cant_cast_while_rooted.set(value) }
    set CastConeAngle(value: string){ out.cast_cone_angle.set(value) }
    set CastConeDistance(value: string){ out.cast_cone_distance.set(value) }
    set CastFrame(value: string){ out.cast_frame.set(value) }
    set CastRadius(value: string){ out.cast_radius_primary.set(value) }
    set CastRadiusSecondary(value: string){ out.cast_radius_secondary.set(value) }
    set CastRadiusSecondaryTexture(value: string){ out.cast_radius_secondary_texture.set(value) }
    set CastRadiusTexture(value: string){ out.cast_radius_texture.set(value) }
    set CastRange(value: string){ out.cast_range.set(value) }
    set CastRange1(value: string){ out.cast_range_by_level.get(1 - 1).set(value) }
    set CastRange2(value: string){ out.cast_range_by_level.get(2 - 1).set(value) }
    set CastRange3(value: string){ out.cast_range_by_level.get(3 - 1).set(value) }
    set CastRange4(value: string){ out.cast_range_by_level.get(4 - 1).set(value) }
    set CastRange5(value: string){ out.cast_range_by_level.get(5 - 1).set(value) }
    set CastRange6(value: string){ out.cast_range_by_level.get(6 - 1).set(value) }
    set CastRangeDisplayOverride(value: string){ out.cast_range_display_override.set(value) }
    set CastRangeDisplayOverride1(value: string){ out.cast_range_display_override_by_level.get(1 - 1).set(value) }
    set CastRangeDisplayOverride2(value: string){ out.cast_range_display_override_by_level.get(2 - 1).set(value) }
    set CastRangeDisplayOverride3(value: string){ out.cast_range_display_override_by_level.get(3 - 1).set(value) }
    set CastRangeDisplayOverride4(value: string){ out.cast_range_display_override_by_level.get(4 - 1).set(value) }
    set CastRangeDisplayOverride5(value: string){ out.cast_range_display_override_by_level.get(5 - 1).set(value) }
    set CastRangeUseBoundingBoxes(value: string){ out.cast_range_use_bounding_boxes.set(value) }
    set CastRangeUseMapScaling(value: string){ out.cast_range_use_map_scaling.set(value) }
    set CastTargetAdditionalUnitsRadius(value: string){ out.cast_target_additional_units_radius.set(value) }
    set CastType(value: string){ out.cast_type.set(value) }
    set ChannelDuration(value: string){ out.channel_duration.set(value) }
    set ChannelDuration1(value: string){ out.channel_duration_by_level.get(1 - 1).set(value) }
    set ChannelDuration2(value: string){ out.channel_duration_by_level.get(2 - 1).set(value) }
    set ChannelDuration3(value: string){ out.channel_duration_by_level.get(3 - 1).set(value) }
    set ChannelDuration4(value: string){ out.channel_duration_by_level.get(4 - 1).set(value) }
    set ChannelDuration5(value: string){ out.channel_duration_by_level.get(5 - 1).set(value) }
    set ChannelDuration6(value: string){ out.channel_duration_by_level.get(6 - 1).set(value) }
    set CircleMissileAngularVelocity(value: string){ out.circle_missile_angular_velocity.set(value) }
    set CircleMissileRadialVelocity(value: string){ out.circle_missile_radial_velocity.set(value) }
    set Coefficient(value: string){ out.coefficient.get(0).set(value) }
    set Coefficient2(value: string){ out.coefficient.get(2 - 1).set(value) }
    set Cooldown(value: string){ out.cooldown.set(value) }
    set Cooldown1(value: string){ out.cooldown_by_level.get(1 - 1).set(value) }
    set Cooldown2(value: string){ out.cooldown_by_level.get(2 - 1).set(value) }
    set Cooldown3(value: string){ out.cooldown_by_level.get(3 - 1).set(value) }
    set Cooldown4(value: string){ out.cooldown_by_level.get(4 - 1).set(value) }
    set Cooldown5(value: string){ out.cooldown_by_level.get(5 - 1).set(value) }
    set Cooldown6(value: string){ out.cooldown_by_level.get(6 - 1).set(value) }
    set DeathRecapPriority(value: string){ out.death_recap_priority.set(value) }
    set DelayCastOffsetPercent(value: string){ out.delay_cast_offset_percent.set(value) }
    set DelayTotalTimePercent(value: string){ out.delay_total_time_percent.set(value) }
    set Description(value: string){ out.description.set(value) }
    set DisplayName(value: string){ out.display_name.set(value) }
    set DynamicExtended(value: string){ out.dynamic_extended.set(value) }
    set DynamicTooltip(value: string){ out.dynamic_tooltip.set(value) }
    set Effect1Level0Amount(value: string){ out.effect_level_amount.get(1 - 1).get(0).set(value) }
    set Effect1Level1Amount(value: string){ out.effect_level_amount.get(1 - 1).get(1).set(value) }
    set Effect1Level2Amount(value: string){ out.effect_level_amount.get(1 - 1).get(2).set(value) }
    set Effect1Level3Amount(value: string){ out.effect_level_amount.get(1 - 1).get(3).set(value) }
    set Effect1Level4Amount(value: string){ out.effect_level_amount.get(1 - 1).get(4).set(value) }
    set Effect1Level5Amount(value: string){ out.effect_level_amount.get(1 - 1).get(5).set(value) }
    set Effect1Level6Amount(value: string){ out.effect_level_amount.get(1 - 1).get(6).set(value) }
    set Effect2Level0Amount(value: string){ out.effect_level_amount.get(2 - 1).get(0).set(value) }
    set Effect2Level1Amount(value: string){ out.effect_level_amount.get(2 - 1).get(1).set(value) }
    set Effect2Level2Amount(value: string){ out.effect_level_amount.get(2 - 1).get(2).set(value) }
    set Effect2Level3Amount(value: string){ out.effect_level_amount.get(2 - 1).get(3).set(value) }
    set Effect2Level4Amount(value: string){ out.effect_level_amount.get(2 - 1).get(4).set(value) }
    set Effect2Level5Amount(value: string){ out.effect_level_amount.get(2 - 1).get(5).set(value) }
    set Effect2Level6Amount(value: string){ out.effect_level_amount.get(2 - 1).get(6).set(value) }
    set Effect3Level0Amount(value: string){ out.effect_level_amount.get(3 - 1).get(0).set(value) }
    set Effect3Level1Amount(value: string){ out.effect_level_amount.get(3 - 1).get(1).set(value) }
    set Effect3Level2Amount(value: string){ out.effect_level_amount.get(3 - 1).get(2).set(value) }
    set Effect3Level3Amount(value: string){ out.effect_level_amount.get(3 - 1).get(3).set(value) }
    set Effect3Level4Amount(value: string){ out.effect_level_amount.get(3 - 1).get(4).set(value) }
    set Effect3Level5Amount(value: string){ out.effect_level_amount.get(3 - 1).get(5).set(value) }
    set Effect3Level6Amount(value: string){ out.effect_level_amount.get(3 - 1).get(6).set(value) }
    set Effect4Level0Amount(value: string){ out.effect_level_amount.get(4 - 1).get(0).set(value) }
    set Effect4Level1Amount(value: string){ out.effect_level_amount.get(4 - 1).get(1).set(value) }
    set Effect4Level2Amount(value: string){ out.effect_level_amount.get(4 - 1).get(2).set(value) }
    set Effect4Level3Amount(value: string){ out.effect_level_amount.get(4 - 1).get(3).set(value) }
    set Effect4Level4Amount(value: string){ out.effect_level_amount.get(4 - 1).get(4).set(value) }
    set Effect4Level5Amount(value: string){ out.effect_level_amount.get(4 - 1).get(5).set(value) }
    set Effect4Level6Amount(value: string){ out.effect_level_amount.get(4 - 1).get(6).set(value) }
    set Effect5Level0Amount(value: string){ out.effect_level_amount.get(5 - 1).get(0).set(value) }
    set Effect5Level1Amount(value: string){ out.effect_level_amount.get(5 - 1).get(1).set(value) }
    set Effect5Level2Amount(value: string){ out.effect_level_amount.get(5 - 1).get(2).set(value) }
    set Effect5Level3Amount(value: string){ out.effect_level_amount.get(5 - 1).get(3).set(value) }
    set Effect5Level4Amount(value: string){ out.effect_level_amount.get(5 - 1).get(4).set(value) }
    set Effect5Level5Amount(value: string){ out.effect_level_amount.get(5 - 1).get(5).set(value) }
    set Effect5Level6Amount(value: string){ out.effect_level_amount.get(5 - 1).get(6).set(value) }
    set Effect6Level1Amount(value: string){ out.effect_level_amount.get(6 - 1).get(1).set(value) }
    set Effect6Level2Amount(value: string){ out.effect_level_amount.get(6 - 1).get(2).set(value) }
    set Effect6Level3Amount(value: string){ out.effect_level_amount.get(6 - 1).get(3).set(value) }
    set Effect6Level4Amount(value: string){ out.effect_level_amount.get(6 - 1).get(4).set(value) }
    set Effect6Level5Amount(value: string){ out.effect_level_amount.get(6 - 1).get(5).set(value) }
    set Flags(value: string){ out.flags.set(value) }
    set FloatStaticsDecimals1(value: string){ out.float_statics_decimals.get(1 - 1).set(value) }
    set FloatStaticsDecimals2(value: string){ out.float_statics_decimals.get(2 - 1).set(value) }
    set FloatStaticsDecimals3(value: string){ out.float_statics_decimals.get(3 - 1).set(value) }
    set FloatStaticsDecimals4(value: string){ out.float_statics_decimals.get(4 - 1).set(value) }
    set FloatStaticsDecimals5(value: string){ out.float_statics_decimals.get(5 - 1).set(value) }
    set FloatStaticsDecimals6(value: string){ out.float_statics_decimals.get(6 - 1).set(value) }
    set FloatVarsDecimals1(value: string){ out.float_vars_decimals.get(1 - 1).set(value) }
    set FloatVarsDecimals2(value: string){ out.float_vars_decimals.get(2 - 1).set(value) }
    set FloatVarsDecimals3(value: string){ out.float_vars_decimals.get(3 - 1).set(value) }
    set FloatVarsDecimals4(value: string){ out.float_vars_decimals.get(4 - 1).set(value) }
    set FloatVarsDecimals5(value: string){ out.float_vars_decimals.get(5 - 1).set(value) }
    set FloatVarsDecimals6(value: string){ out.float_vars_decimals.get(6 - 1).set(value) }
    set HaveAfterEffect(value: string){ out.have_after_effect.set(value) }
    set HaveHitBone(value: string){ out.have_hit_bone.set(value) }
    set HaveHitEffect(value: string){ out.have_hit_effect.set(value) }
    set HavePointEffect(value: string){ out.have_point_effect.set(value) }
    set HitBoneName(value: string){ out.hit_bone_name.set(value) }
    set HitEffectName(value: string){ out.hit_effect_name.set(value) }
    set InventoryIcon(value: string){ out.inventory_icon.get(0).set(value) }
    set InventoryIcon1(value: string){ out.inventory_icon.get(1).set(value) }
    set InventoryIcon2(value: string){ out.inventory_icon.get(2).set(value) }
    set IsDisabledWhileDead(value: string){ out.is_disabled_while_dead.set(value) }
    set IsToggleSpell(value: string){ out.is_toggle_spell.set(value) }
    set Level1Desc(value: string){ out.level_desc.get(1 - 1).set(value) }
    set Level2Desc(value: string){ out.level_desc.get(2 - 1).set(value) }
    set Level3Desc(value: string){ out.level_desc.get(3 - 1).set(value) }
    set Level4Desc(value: string){ out.level_desc.get(4 - 1).set(value) }
    set Level5Desc(value: string){ out.level_desc.get(5 - 1).set(value) }
    set Level6Desc(value: string){ out.level_desc.get(6 - 1).set(value) }
    set LineDragLength(value: string){ out.line_drag_length.set(value) }
    set LineMissileBounces(value: string){ out.line_missile_bounces.set(value) }
    set LineMissileCollisionFromStartPoint(value: string){ out.line_missile_collision_from_start_point.set(value) }
    set LineMissileDelayDestroyAtEndSeconds(value: string){ out.line_missile_delay_destroy_at_end_seconds.set(value) }
    set LineMissileEndsAtTargetPoint(value: string){ out.line_missile_ends_at_target_point.set(value) }
    set LineMissileTargetHeightAugment(value: string){ out.line_missile_target_height_augment.set(value) }
    set LineMissileTimePulseBetweenCollisionSpellHits(value: string){ out.line_missile_time_pulse_between_collision_spell_hits.set(value) }
    set LineMissileTrackUnits(value: string){ out.line_missile_track_units.set(value) }
    set LineWidth(value: string){ out.line_width.set(value) }
    set LocationTargettingLength1(value: string){ out.location_targetting_length_by_level.get(1 - 1).set(value) }
    set LocationTargettingLength2(value: string){ out.location_targetting_length_by_level.get(2 - 1).set(value) }
    set LocationTargettingLength3(value: string){ out.location_targetting_length_by_level.get(3 - 1).set(value) }
    set LocationTargettingLength4(value: string){ out.location_targetting_length_by_level.get(4 - 1).set(value) }
    set LocationTargettingLength5(value: string){ out.location_targetting_length_by_level.get(5 - 1).set(value) }
    set LocationTargettingLength6(value: string){ out.location_targetting_length_by_level.get(6 - 1).set(value) }
    set LocationTargettingWidth1(value: string){ out.location_targetting_width_by_level.get(1 - 1).set(value) }
    set LocationTargettingWidth2(value: string){ out.location_targetting_width_by_level.get(2 - 1).set(value) }
    set LocationTargettingWidth3(value: string){ out.location_targetting_width_by_level.get(3 - 1).set(value) }
    set LocationTargettingWidth4(value: string){ out.location_targetting_width_by_level.get(4 - 1).set(value) }
    set LocationTargettingWidth5(value: string){ out.location_targetting_width_by_level.get(5 - 1).set(value) }
    set LocationTargettingWidth6(value: string){ out.location_targetting_width_by_level.get(6 - 1).set(value) }
    set LockConeToPlayer(value: string){ out.lock_cone_to_player.set(value) }
    set LuaOnMissileUpdateDistanceInterval(value: string){ out.missile_update_distance_interval.set(value) }
    set ManaCost(value: string){ out.mana_cost.set(value) }
    set ManaCost1(value: string){ out.mana_cost_by_level.get(1 - 1).set(value) }
    set ManaCost2(value: string){ out.mana_cost_by_level.get(2 - 1).set(value) }
    set ManaCost3(value: string){ out.mana_cost_by_level.get(3 - 1).set(value) }
    set ManaCost4(value: string){ out.mana_cost_by_level.get(4 - 1).set(value) }
    set ManaCost5(value: string){ out.mana_cost_by_level.get(5 - 1).set(value) }
    set ManaCost6(value: string){ out.mana_cost_by_level.get(6 - 1).set(value) }
    set MissileAccel(value: string){ out.missile_accel.set(value) }
    set MissileBoneName(value: string){ out.missile_bone_name.set(value) }
    set MissileEffect(value: string){ out.missile_effect.set(value) }
    set MissileFixedTravelTime(value: string){ out.missile_fixed_travel_time.set(value) }
    set MissileGravity(value: string){ out.missile_gravity.set(value) }
    set MissileLifetime(value: string){ out.missile_lifetime.set(value) }
    set MissileMaxSpeed(value: string){ out.missile_max_speed.set(value) }
    set MissileMinSpeed(value: string){ out.missile_min_speed.set(value) }
    set MissilePerceptionBubbleRadius(value: string){ out.missile_perception_bubble_radius.set(value) }
    set MissilePerceptionBubbleRevealsStealth(value: string){ out.missile_perception_bubble_reveals_stealth.set(value) }
    set MissileSpeed(value: string){ out.missile_speed.set(value) }
    set MissileTargetHeightAugment(value: string){ out.missile_target_height_augment.set(value) }
    set Name(value: string){ out.spell_name.set(value) }
    set OverrideCastTime(value: string){ out.override_cast_time.set(value) }
    set OverrideForceSpellAnimation(value: string){ out.override_force_spell_animation.set(value) }
    set OverrideForceSpellCancel(value: string){ out.override_force_spell_cancel.set(value) }
    set ParticleStartOffset(value: string){ out.particle_start_offset.set(value) }
    set PlatformEnabled(value: string){ out.platform_enabled.set(value) }
    set PointEffectName(value: string){ out.point_effect_name.set(value) }
    set RangeIndicatorTextureName(value: string){ out.cast_range_indicator_texture.set(value) }
    set Ranks(value: string){ out.ranks.set(value) }
    set SelectionPreference(value: string){
        let options = ["none", "foe", "friend"]
        let res = options.indexOf(BoxedString.parse(value).toLowerCase())
        if(res === -1)
            throw new Error(`Expected one of [${options.map(o => `"${o}"`).join(', ')}], got "${value}"`)
        out.selection_preference.value = res
        out.selection_preference.changed = true
    }
    set Sound_CastName(value: string){ out.sound_cast_name.set(value) }
    set Sound_HitName(value: string){ out.sound_hit_name.set(value) }
    set SpellRevealsChampion(value: string){ out.spell_reveals_champion.set(value) }
    set StartCooldown(value: string){ out.cooldown.set(value) }
    set SubjectToGlobalCooldown(value: string){ out.subject_to_global_cooldown.set(value) }
    set TargettingType(value: string){ out.targetting_type.set(value) }
    //set TextFlags(value: string){ out.text_flags.set(value) }
    set TriggersGlobalCooldown(value: string){ out.triggers_global_cooldown.set(value) }
    set UseAnimatorFramerate(value: string){ out.use_animator_framerate.set(value) }
    set UseMinimapTargeting(value: string){ out.use_minimap_targeting.set(value) }
    set Version(value: string){ out.version.set(value) }
    set x1(value: string){ out.x.get(1 - 1).set(value) }
    set x2(value: string){ out.x.get(2 - 1).set(value) }
    set x3(value: string){ out.x.get(3 - 1).set(value) }
    set x4(value: string){ out.x.get(4 - 1).set(value) }
    set x5(value: string){ out.x.get(5 - 1).set(value) }
}

let c = new Converter()

let ini = await fs.readFile(argv[2], 'utf8')
//let cs = fs.readFile(argv[3]) //TODO:
let leftover = ini.replace(/^(\w+)=(.*)$/gm, (m: string, key: string, value: string) => {
    if(key in c) (c as any)[key] = value
    return ''
}).replace(/^(\[SpellData\])?\n/gm, '')
if(leftover.length > 0)
    console.log(leftover.split('\n').map(l => '#' + l).join('\n'))

let body = ''
let script_id = `0_${makeid(5)}`
body += `[node name="Spell" type="Node"]\n`
body += `script = ExtResource("${script_id}")\n`
for(let [key, value] of Object.entries(out)){
    if(!value.changed) continue
    body += `${key} = ${value.stringify()}\n`
}

let result = ''
result += `[gd_scene load_steps=3 format=3]\n`
result += `\n`
result += `[ext_resource id="${script_id}" type="Script" path="res://Spells/Spell.gd"]\n`
for(let r of res){
    result += `[ext_resource id="${r.id}" type="Texture2D" path="res://${r.value}"]\n`
}
result += `\n`
result += body

console.log(result)