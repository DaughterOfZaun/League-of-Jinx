class_name UnitData
extends Data


#@export var AssetCategory := "obj"

@export_group("Info")
@export var ChampionId: int
@export var Name: String
@export var Description: String
@export var FriendlyTooltip: String
@export var EnemyTooltip: String
@export var Lore: Array[String]
@export var Tips: Array[String]
@export var Classification: ClassificationEnum
enum ClassificationEnum {
	Arcane, Deadly, Strong, Hunter
}
@export var Roles: RolesEnum
enum RolesEnum {
	ATTACKER, BRAWLER, MAGE, TANK, SUPPORT
}
@export var SearchTags: SearchTagsEnum #TODO: flags? string?
enum SearchTagsEnum {
	support,
	ranged,
	assassin,
	stealth,
	melee,
	carry,
	fighter,
	jungler,
	recommended,
	heal,
	pusher,
	farmer,
	tough,
	stun,
	haste,
	mage,
	root,
	nuke,
	tank,
	snare,
	disabler,
	slow,
	teleport,
	flee,
}
@export_subgroup("Ranks")
@export var MagicRank: int
@export var AttackRank: int
@export var DefenseRank: int
@export var DifficultyRank: int
@export_subgroup("")
@export_subgroup("Flags")
@export var BotEnabled: bool
@export var BotEnabledMM: bool
@export var CS_easy: bool
@export var CS_hard: bool
@export var CS_medium: bool
@export var SR_easy: bool
@export var SR_medium: bool
@export_subgroup("")
@export_group("")

@export_group("Ranges")
@export var AttackRange: float
@export var ChasingAttackRangePercent: float
@export var AcquisitionRange: float
@export var ExperienceRadius: float
@export var GameplayCollisionRadius: float
@export var PathfindingCollisionRadius: float
@export var PerceptionBubbleRadius: float
@export var SelectionRadius: float
@export var SelectionHeight: float
@export_group("")

@export_group("Stats")
@export_subgroup("Armor")
@export var Armor: float
@export var ArmorPerLevel: float
@export var ArmorMaterial: ArmorMaterialEnum
enum ArmorMaterialEnum {
	Flesh, Stone, Metal, Wood
}
@export var HitFxScale: float #TODO: Move?

@export var SpellBlock: float
@export var SpellBlockPerLevel: float

@export var BaseDodge: float
@export var LevelDodge: float

@export_subgroup("Attack")
@export var AttackSpeed: float
@export var AttackSpeedPerLevel: float

@export var BaseDamage: float
@export var DamagePerLevel: float

@export var BaseCritChance: float
@export var CritDamageBonus: float
@export var CritPerLevel: float

@export var BaseAbilityPower: float
@export var AbilityPowerIncPerLevel := 0
@export var BaseSpellEffectiveness: float # 0 or 1.0
@export var LevelSpellEffectiveness: float
@export_subgroup("")

@export_subgroup("Health")
@export var BaseHP: float
@export var HPPerLevel: float
@export var HPRegenPerLevel: float
@export var BaseFactorHPRegen: float
@export var BaseStaticHPRegen: float
@export_subgroup("")

@export_subgroup("Mana")
@export var BaseMP: float
@export var MPPerLevel: float
@export var MPRegenPerLevel: float
@export var BaseFactorMPRegen: float
@export var BaseStaticMPRegen: float
@export_subgroup("")

@export_subgroup("PAR")
@export var PARType: PARTypeEnum
enum PARTypeEnum {
	Shield, Energy, Other
}
@export var PARNameString: String

@export var PARColor: Color
@export var PARFadeColor: Color

@export var PARIncrements: float
@export var PARMaxSegments: int

@export var PARDisplayThroughDeath: bool
@export var PARHasRegenText: bool
@export_subgroup("")

@export var MoveSpeed: float

@export_group("")

@export_group("Attacks")
@export_subgroup("Base")
@export var WeaponMaterial: Array[String]
@export var BaseAttack_Probability: float
@export var AttackDelayCastOffsetPercent: float
@export var AttackDelayOffsetPercent: float
@export var DelayCastOffsetPercent: float
@export var DelayTotalTimePercent: float
@export_subgroup("")
@export_subgroup("Crit")
@export var CritAttack: String
@export var CriticalAttack: String
@export var CritAttack_AttackCastDelayOffsetPercent: float
@export var CritAttack_AttackDelayOffsetPercent: float
@export_subgroup("")
@export_subgroup("Extra")
@export var ExtraAttack: Array[String]
@export var ExtraAttack_Probability: Array[float]
@export_subgroup("")
@export var PostAttackMoveDelay: float
@export_group("")

@export_group("Passive")
@export var Passive: Array[int] #?
@export var PassiveDesc: Array[String]
@export var PassiveEffect: Array[Array] #[float]
@export var PassiveIcon: Array[String]
@export var PassiveLevel: Array[Array] #[int]
@export var PassiveLuaName: Array[String]
@export var PassiveName: Array[String]
@export var PassiveNumEffects: Array[int]
@export var PassLevDesc: Array[Array] #String
@export_group("")

@export_group("Spells")
@export var Spell: Array[String]
@export var SpellDesc: Array[String]
@export var SpellDisplayName: Array[String]
@export var SpellsUpLevels: Array[Array] #[int]
@export var MaxLevels: Vector4i
@export var ExtraSpell: Array[String]
@export_group("")

@export_group("Death")
@export var GlobalExpGivenOnDeath: float
@export var GlobalGoldGivenOnDeath: float
@export var GoldGivenOnDeath: float
@export var SoulGivenOnDeath: float
@export var ExpGivenOnDeath: float
@export_group("")

@export_group("Flags")
@export var IsMelee: bool
@export var NeverRender: bool
@export var NoAutoAttack: bool
@export var NoHealthBar: bool
@export var PlatformEnabled: bool
@export var ServerOnly: bool
@export var ShouldFaceTarget: bool
@export_group("")

#region Import
@export_group("Import")
@export_file("*.ini") var import_path: String
@export var import: bool:
	set(value):
		if value && !import:
			import = true
			var ini = ini_load(import_path)
			set_from_ini_section(ini["Data"])
			import = false
@export_group("")

func set_from_ini_entry(key_array: Array, value: String):
	match key_array:
		["AfterEffectName"]: pass
