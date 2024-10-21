extends Level

const MAX_MINIONS_EVER = 180

const TEAM_ORDER = 100
const TEAM_CHAOS = 200

const ORDER_HQ = 1
const CHAOS_HQ = 2

const FRONT_TOWER = 3
const MIDDLE_TOWER = 2
const BACK_TOWER = 1

const HQ_TOWER2 = 4
const HQ_TOWER1 = 5

const RIGHT_LANE = 0
const CENTER_LANE = 1
const LEFT_LANE = 2

const INITIAL_TIME_TO_SPAWN = 90.0
var CASTER_MINION_SPAWN_FREQUENCY := 3
const INCREASE_CANNON_RATE_TIMER = 2090.0
const MINION_HEALTH_DENIAL_PERCENT = 0.0
const MELEE_EXP_GIVEN = 64.0
const MELEE_GOLD_GIVEN = 22.0
const ARCHER_EXP_GIVEN = 32.0
const ARCHER_GOLD_GIVEN = 16.0
const CASTER_EXP_GIVEN = 100.0
const CASTER_GOLD_GIVEN = 27.0
const SUPER_EXP_GIVEN = 100.0
const SUPER_GOLD_GIVEN = 27.0
const MELEE_HEALTH_UPGRADE = 20.0
const MELEE_DAMAGE_UPGRADE = 1.0
const MELEE_GOLD_UPGRADE = 0.5
const MELEE_EXP_UPGRADE = 5.0
const MELEE_ARMOR_UPGRADE = 2.0
const MELEE_MR_UPGRADE = 1.25
const ARCHER_HEALTH_UPGRADE = 15.0
const ARCHER_DAMAGE_UPGRADE = 2.0
const ARCHER_GOLD_UPGRADE = 0.5
const ARCHER_EXP_UPGRADE = 3.0
const ARCHER_ARMOR_UPGRADE = 1.25
const ARCHER_MR_UPGRADE = 2.0
const CASTER_HEALTH_UPGRADE = 27.0
const CASTER_DAMAGE_UPGRADE = 3.0
const CASTER_GOLD_UPGRADE = 1.0
const CASTER_EXP_UPGRADE = 7.0
const CASTER_ARMOR_UPGRADE = 3.0
const CASTER_MR_UPGRADE = 3.0
const SUPER_HEALTH_UPGRADE = 200.0
const SUPER_DAMAGE_UPGRADE = 10.0
const SUPER_GOLD_UPGRADE = 0.0
const SUPER_EXP_UPGRADE = 0.0
const SUPER_ARMOR_UPGRADE = 0.0
const SUPER_MR_UPGRADE = 0.0
const MAXIMUM_MELEE_GOLD_BONUS = 10.0
const MAXIMUM_ARCHER_GOLD_BONUS = 10.0
const MAXIMUM_CASTER_GOLD_BONUS = 20.0
const MAXIMUM_SUPER_GOLD_BONUS = 20.0
const UPGRADE_MINION_TIMER = 180.0
const MELEE_HEALTH_INHIBITOR = 100.0
const MELEE_DAMAGE_INHIBITOR = 10.0
const MELEE_GOLD_INHIBITOR = 0.0
const MELEE_EXP_INHIBITOR = 0.0
const ARCHER_HEALTH_INHIBITOR = 60.0
const ARCHER_DAMAGE_INHIBITOR = 18.0
const ARCHER_GOLD_INHIBITOR = 0.0
const ARCHER_EXP_INHIBITOR = 0.0
const CASTER_HEALTH_INHIBITOR = 200.0
const CASTER_DAMAGE_INHIBITOR = 25.0
const CASTER_GOLD_INHIBITOR = 0.0
const CASTER_EXP_INHIBITOR = 0.0
const SUPER_HEALTH_INHIBITOR = 0.0
const SUPER_DAMAGE_INHIBITOR = 0.0
const SUPER_GOLD_INHIBITOR = 0.0
const SUPER_EXP_INHIBITOR = 0.0
const EXP_GIVEN_RADIUS = 1250.0
const DISABLE_MINION_SPAWN_BASE_TIME = 300.0
const DISABLE_MINION_SPAWN_MAG_TIME = 0.0

var LAST_WAVE := -1
var SPECIAL_MINION_MODE := "none"
var HQTurretAttackable := false

var ChaosNames := NamesClass.new("Red")
var OrderNames := NamesClass.new("Blue")
class NamesClass:
	var MeleeMinionName: String
	var ArcherMinionName: String
	var CasterMinionName: String
	var SuperMinionName: String
	func _init(prefix: String) -> void:
		MeleeMinionName = prefix + "_Minion_Basic"
		ArcherMinionName = prefix + "_Minion_Wizard"
		CasterMinionName = prefix + "_Minion_MechCannon"
		SuperMinionName = prefix + "_Minion_MechMelee"

var SpawnTable := SpawnTableClass.new()
class SpawnTableClass:
	var WaveSpawnRate := 0
	var NumOfMeleeMinionsPerWave := 0
	var NumOfArcherMinionsPerWave := 0
	var NumOfCasterMinionsPerWave := 0
	var NumOfSuperMinionsPerWave := 0
	var SingleMinionSpawnDelay := 0.0
	var DidPowerGroup := false
	#var MeleeMinionName := 0
	#var ArcherMinionName := 0
	#var CasterMinionName := 0
	#var SuperMinionName := 0
	var ExpRadius := 0.0

var ChaosBarracksBonuses: Array[BarrackClass] = [
	BarrackClass.new(),
	BarrackClass.new(),
	BarrackClass.new(),
]
var OrderBarracksBonuses: Array[BarrackClass] = [
	BarrackClass.new(),
	BarrackClass.new(),
	BarrackClass.new(),
]
class BarrackClass:
	var IsDestroyed := false
	var MeleeMinionArmor := 0.0
	var MeleeMinionMagicResistance := 0.0
	var MeleeHPBonus := 0.0
	var MeleeDamageBonus := 0.0
	var MeleeGoldBonus := 0.0
	var MeleeExpBonus := 0.0
	var MeleeExpGiven := MELEE_EXP_GIVEN
	var MeleeGoldGiven := MELEE_GOLD_GIVEN
	var ArcherMinionArmor := 0.0
	var ArcherMinionMagicResistance := 0.0
	var ArcherHPBonus := 0.0
	var ArcherDamageBonus := 0.0
	var ArcherGoldBonus := 0.0
	var ArcherExpBonus := 0.0
	var ArcherExpGiven := ARCHER_EXP_GIVEN
	var ArcherGoldGiven := ARCHER_GOLD_GIVEN
	var CasterMinionArmor := 0.0
	var CasterMinionMagicResistance := 0.0
	var CasterHPBonus := 0.0
	var CasterDamageBonus := 0.0
	var CasterGoldBonus := 0.0
	var CasterExpBonus := 0.0
	var CasterExpGiven := CASTER_EXP_GIVEN
	var SuperMinionArmor := 0.0
	var SuperMinionMagicResistance := 0.0
	var SuperHPBonus := 0.0
	var SuperDamageBonus := 0.0
	var SuperGoldBonus := 0.0
	var SuperExpBonus := 0.0
	var SuperExpGiven := SUPER_EXP_GIVEN
	var NumOfSpawnDisables := 0.0
	var WillSpawnSuperMinion := 0.0
	var MeleeMinionName: String
	var RangedMinionName: String
	var CasterMinionName: String
	var ArcherMinionName: String
	var CasterGoldGiven := CASTER_GOLD_GIVEN
	var SuperMinionName: String
	var SuperGoldGiven := CASTER_GOLD_GIVEN

var NeutralMinionNames := [
	"Lizard",
	"Dragon",
	"Golem",
	"wolf",
	"Wraith",
]

class LaneBuildingTable:
	var Turret3 := true
	var Turret2 := true
	var Turret1 := true
	var Barracks := true

var OrderBuildingStatus := BuildingStatus.new()
var ChaosBuildingStatus := BuildingStatus.new()
class BuildingStatus:
	var HQTower2 := true
	var HQTower1 := true
	var HQ := true
	var _0 := LaneBuildingTable.new()
	var _1 := LaneBuildingTable.new()
	var _2 := LaneBuildingTable.new()

#var TotalNumberOfMinions := 0
var totalNumberOfChaosBarracks := 3
var totalNumberOfOrderBarracks := 3
func OnLevelInit() -> void:
	#for r3_2, r4_2 in pairs(OrderNames):
	#	PreloadCharacter(r4_2)
	#for r3_2, r4_2 in pairs(ChaosNames):
	#	PreloadCharacter(r4_2)
	PreloadCharacter("OrderTurretAngel")
	PreloadCharacter("OrderTurretDragon")
	PreloadCharacter("OrderTurretNormal2")
	PreloadCharacter("OrderTurretNormal")
	PreloadCharacter("ChaosTurretWorm")
	PreloadCharacter("ChaosTurretWorm2")
	PreloadCharacter("ChaosTurretGiant")
	PreloadCharacter("ChaosTurretNormal")
	PreloadSpell("RespawnClassic")
	PreloadSpell("SpellShieldMarker")
	#math.randomseed(os.time())
	LoadScriptIntoScript("NeutralMinionSpawn.lua")
	NeutralMinionInit()
	LoadScriptIntoScript("Data\\Scripts\\EndOfGame.lua")
	SpawnTable.WaveSpawnRate = 30000
	SpawnTable.NumOfMeleeMinionsPerWave = 3
	SpawnTable.NumOfArcherMinionsPerWave = 3
	SpawnTable.SingleMinionSpawnDelay = 800
	SpawnTable.DidPowerGroup = false
	InitTimer("UpgradeMinionTimer", UPGRADE_MINION_TIMER, true)
	InitTimer("IncreaseCannonMinionSpawnRate", INCREASE_CANNON_RATE_TIMER, false)
	InitTimer("AllowDamageOnBuildings", 10, false)

func OnPostLevelLoad() -> void:
	LoadScriptIntoScript("CreateLevelProps.lua")
	CreateLevelProps()

func OppositeTeam(team: int) -> int:
	if team == TEAM_CHAOS:
		return TEAM_ORDER
	else:
		return TEAM_CHAOS

func UpgradeMinionTimer() -> void:
	for lane in range(3):
		OrderBarracksBonuses[lane].MeleeHPBonus = OrderBarracksBonuses[lane].MeleeHPBonus + MELEE_HEALTH_UPGRADE
		OrderBarracksBonuses[lane].MeleeDamageBonus = OrderBarracksBonuses[lane].MeleeDamageBonus + MELEE_DAMAGE_UPGRADE
		OrderBarracksBonuses[lane].MeleeGoldBonus = OrderBarracksBonuses[lane].MeleeGoldBonus + MELEE_GOLD_UPGRADE
		OrderBarracksBonuses[lane].MeleeMinionArmor = OrderBarracksBonuses[lane].MeleeMinionArmor + MELEE_ARMOR_UPGRADE
		OrderBarracksBonuses[lane].MeleeMinionMagicResistance = OrderBarracksBonuses[lane].MeleeMinionMagicResistance + MELEE_MR_UPGRADE
		if MAXIMUM_MELEE_GOLD_BONUS < OrderBarracksBonuses[lane].MeleeGoldBonus:
			OrderBarracksBonuses[lane].MeleeGoldBonus = MAXIMUM_MELEE_GOLD_BONUS
		OrderBarracksBonuses[lane].MeleeExpBonus = OrderBarracksBonuses[lane].MeleeExpBonus + MELEE_EXP_UPGRADE
		OrderBarracksBonuses[lane].MeleeGoldGiven = OrderBarracksBonuses[lane].MeleeGoldBonus + MELEE_GOLD_GIVEN
		OrderBarracksBonuses[lane].MeleeExpGiven = OrderBarracksBonuses[lane].MeleeExpBonus + MELEE_EXP_GIVEN

		OrderBarracksBonuses[lane].ArcherHPBonus = OrderBarracksBonuses[lane].ArcherHPBonus + ARCHER_HEALTH_UPGRADE
		OrderBarracksBonuses[lane].ArcherDamageBonus = OrderBarracksBonuses[lane].ArcherDamageBonus + ARCHER_DAMAGE_UPGRADE
		OrderBarracksBonuses[lane].ArcherGoldBonus = OrderBarracksBonuses[lane].ArcherGoldBonus + ARCHER_GOLD_UPGRADE
		OrderBarracksBonuses[lane].ArcherMinionArmor = OrderBarracksBonuses[lane].ArcherMinionArmor + ARCHER_ARMOR_UPGRADE
		OrderBarracksBonuses[lane].ArcherMinionMagicResistance = OrderBarracksBonuses[lane].ArcherMinionMagicResistance + ARCHER_MR_UPGRADE
		if MAXIMUM_ARCHER_GOLD_BONUS < OrderBarracksBonuses[lane].ArcherGoldBonus:
			OrderBarracksBonuses[lane].ArcherGoldBonus = MAXIMUM_ARCHER_GOLD_BONUS
		OrderBarracksBonuses[lane].ArcherExpBonus = OrderBarracksBonuses[lane].ArcherExpBonus + ARCHER_EXP_UPGRADE
		OrderBarracksBonuses[lane].ArcherGoldGiven = OrderBarracksBonuses[lane].ArcherGoldBonus + ARCHER_GOLD_GIVEN
		OrderBarracksBonuses[lane].ArcherExpGiven = OrderBarracksBonuses[lane].ArcherExpBonus + ARCHER_EXP_GIVEN

		OrderBarracksBonuses[lane].CasterHPBonus = OrderBarracksBonuses[lane].CasterHPBonus + CASTER_HEALTH_UPGRADE
		OrderBarracksBonuses[lane].CasterDamageBonus = OrderBarracksBonuses[lane].CasterDamageBonus + CASTER_DAMAGE_UPGRADE
		OrderBarracksBonuses[lane].CasterGoldBonus = OrderBarracksBonuses[lane].CasterGoldBonus + CASTER_GOLD_UPGRADE
		OrderBarracksBonuses[lane].CasterMinionArmor = OrderBarracksBonuses[lane].CasterMinionArmor + CASTER_ARMOR_UPGRADE
		OrderBarracksBonuses[lane].CasterMinionMagicResistance = OrderBarracksBonuses[lane].CasterMinionMagicResistance + CASTER_MR_UPGRADE
		if MAXIMUM_CASTER_GOLD_BONUS < OrderBarracksBonuses[lane].CasterGoldBonus:
			OrderBarracksBonuses[lane].CasterGoldBonus = MAXIMUM_CASTER_GOLD_BONUS
		OrderBarracksBonuses[lane].CasterExpBonus = OrderBarracksBonuses[lane].CasterExpBonus + CASTER_EXP_UPGRADE
		OrderBarracksBonuses[lane].CasterGoldGiven = OrderBarracksBonuses[lane].CasterGoldBonus + CASTER_GOLD_GIVEN
		OrderBarracksBonuses[lane].CasterExpGiven = OrderBarracksBonuses[lane].CasterExpBonus + CASTER_EXP_GIVEN

		OrderBarracksBonuses[lane].SuperHPBonus = OrderBarracksBonuses[lane].SuperHPBonus + SUPER_HEALTH_UPGRADE
		OrderBarracksBonuses[lane].SuperDamageBonus = OrderBarracksBonuses[lane].SuperDamageBonus + SUPER_DAMAGE_UPGRADE
		OrderBarracksBonuses[lane].SuperGoldBonus = OrderBarracksBonuses[lane].SuperGoldBonus + SUPER_GOLD_UPGRADE
		OrderBarracksBonuses[lane].SuperMinionArmor = OrderBarracksBonuses[lane].SuperMinionArmor + SUPER_ARMOR_UPGRADE
		OrderBarracksBonuses[lane].SuperMinionMagicResistance = OrderBarracksBonuses[lane].SuperMinionMagicResistance + SUPER_MR_UPGRADE
		if MAXIMUM_SUPER_GOLD_BONUS < OrderBarracksBonuses[lane].SuperGoldBonus:
			OrderBarracksBonuses[lane].SuperGoldBonus = MAXIMUM_SUPER_GOLD_BONUS
		OrderBarracksBonuses[lane].SuperExpBonus = OrderBarracksBonuses[lane].SuperExpBonus + SUPER_EXP_UPGRADE
		OrderBarracksBonuses[lane].SuperGoldGiven = OrderBarracksBonuses[lane].SuperGoldBonus + SUPER_GOLD_GIVEN
		OrderBarracksBonuses[lane].SuperExpGiven = OrderBarracksBonuses[lane].SuperExpBonus + SUPER_EXP_GIVEN

		ChaosBarracksBonuses[lane].MeleeHPBonus = ChaosBarracksBonuses[lane].MeleeHPBonus + MELEE_HEALTH_UPGRADE
		ChaosBarracksBonuses[lane].MeleeDamageBonus = ChaosBarracksBonuses[lane].MeleeDamageBonus + MELEE_DAMAGE_UPGRADE
		ChaosBarracksBonuses[lane].MeleeGoldBonus = ChaosBarracksBonuses[lane].MeleeGoldBonus + MELEE_GOLD_UPGRADE
		ChaosBarracksBonuses[lane].MeleeMinionArmor = ChaosBarracksBonuses[lane].MeleeMinionArmor + MELEE_ARMOR_UPGRADE
		ChaosBarracksBonuses[lane].MeleeMinionMagicResistance = ChaosBarracksBonuses[lane].MeleeMinionMagicResistance + MELEE_MR_UPGRADE
		if MAXIMUM_MELEE_GOLD_BONUS < ChaosBarracksBonuses[lane].MeleeGoldBonus:
			ChaosBarracksBonuses[lane].MeleeGoldBonus = MAXIMUM_MELEE_GOLD_BONUS
		ChaosBarracksBonuses[lane].MeleeExpBonus = ChaosBarracksBonuses[lane].MeleeExpBonus + MELEE_EXP_UPGRADE
		ChaosBarracksBonuses[lane].MeleeGoldGiven = ChaosBarracksBonuses[lane].MeleeGoldBonus + MELEE_GOLD_GIVEN
		ChaosBarracksBonuses[lane].MeleeExpGiven = ChaosBarracksBonuses[lane].MeleeExpBonus + MELEE_EXP_GIVEN

		ChaosBarracksBonuses[lane].ArcherHPBonus = ChaosBarracksBonuses[lane].ArcherHPBonus + ARCHER_HEALTH_UPGRADE
		ChaosBarracksBonuses[lane].ArcherDamageBonus = ChaosBarracksBonuses[lane].ArcherDamageBonus + ARCHER_DAMAGE_UPGRADE
		ChaosBarracksBonuses[lane].ArcherGoldBonus = ChaosBarracksBonuses[lane].ArcherGoldBonus + ARCHER_GOLD_UPGRADE
		ChaosBarracksBonuses[lane].ArcherMinionArmor = ChaosBarracksBonuses[lane].ArcherMinionArmor + ARCHER_ARMOR_UPGRADE
		ChaosBarracksBonuses[lane].ArcherMinionMagicResistance = ChaosBarracksBonuses[lane].ArcherMinionMagicResistance + ARCHER_MR_UPGRADE
		if MAXIMUM_ARCHER_GOLD_BONUS < ChaosBarracksBonuses[lane].ArcherGoldBonus:
			ChaosBarracksBonuses[lane].ArcherGoldBonus = MAXIMUM_ARCHER_GOLD_BONUS
		ChaosBarracksBonuses[lane].ArcherExpBonus = ChaosBarracksBonuses[lane].ArcherExpBonus + ARCHER_EXP_UPGRADE
		ChaosBarracksBonuses[lane].ArcherGoldGiven = ChaosBarracksBonuses[lane].ArcherGoldBonus + ARCHER_GOLD_GIVEN
		ChaosBarracksBonuses[lane].ArcherExpGiven = ChaosBarracksBonuses[lane].ArcherExpBonus + ARCHER_EXP_GIVEN

		ChaosBarracksBonuses[lane].CasterHPBonus = ChaosBarracksBonuses[lane].CasterHPBonus + CASTER_HEALTH_UPGRADE
		ChaosBarracksBonuses[lane].CasterDamageBonus = ChaosBarracksBonuses[lane].CasterDamageBonus + CASTER_DAMAGE_UPGRADE
		ChaosBarracksBonuses[lane].CasterGoldBonus = ChaosBarracksBonuses[lane].CasterGoldBonus + CASTER_GOLD_UPGRADE
		ChaosBarracksBonuses[lane].CasterMinionArmor = ChaosBarracksBonuses[lane].CasterMinionArmor + CASTER_ARMOR_UPGRADE
		ChaosBarracksBonuses[lane].CasterMinionMagicResistance = ChaosBarracksBonuses[lane].CasterMinionMagicResistance + CASTER_MR_UPGRADE
		if MAXIMUM_CASTER_GOLD_BONUS < ChaosBarracksBonuses[lane].CasterGoldBonus:
			ChaosBarracksBonuses[lane].CasterGoldBonus = MAXIMUM_CASTER_GOLD_BONUS
		ChaosBarracksBonuses[lane].CasterExpBonus = ChaosBarracksBonuses[lane].CasterExpBonus + CASTER_EXP_UPGRADE
		ChaosBarracksBonuses[lane].CasterGoldGiven = ChaosBarracksBonuses[lane].CasterGoldBonus + CASTER_GOLD_GIVEN
		ChaosBarracksBonuses[lane].CasterExpGiven = ChaosBarracksBonuses[lane].CasterExpBonus + CASTER_EXP_GIVEN

		ChaosBarracksBonuses[lane].SuperHPBonus = ChaosBarracksBonuses[lane].SuperHPBonus + SUPER_HEALTH_UPGRADE
		ChaosBarracksBonuses[lane].SuperDamageBonus = ChaosBarracksBonuses[lane].SuperDamageBonus + SUPER_DAMAGE_UPGRADE
		ChaosBarracksBonuses[lane].SuperGoldBonus = ChaosBarracksBonuses[lane].SuperGoldBonus + SUPER_GOLD_UPGRADE
		ChaosBarracksBonuses[lane].SuperMinionArmor = ChaosBarracksBonuses[lane].SuperMinionArmor + SUPER_ARMOR_UPGRADE
		ChaosBarracksBonuses[lane].SuperMinionMagicResistance = ChaosBarracksBonuses[lane].SuperMinionMagicResistance + SUPER_MR_UPGRADE
		if MAXIMUM_SUPER_GOLD_BONUS < ChaosBarracksBonuses[lane].SuperGoldBonus:
			ChaosBarracksBonuses[lane].SuperGoldBonus = MAXIMUM_SUPER_GOLD_BONUS
		ChaosBarracksBonuses[lane].SuperExpBonus = ChaosBarracksBonuses[lane].SuperExpBonus + SUPER_EXP_UPGRADE
		ChaosBarracksBonuses[lane].SuperGoldGiven = ChaosBarracksBonuses[lane].SuperGoldBonus + SUPER_GOLD_GIVEN
		ChaosBarracksBonuses[lane].SuperExpGiven = ChaosBarracksBonuses[lane].SuperExpBonus + SUPER_EXP_GIVEN

func AllowDamageOnBuildings() -> void:
	for r3_6 in range(RIGHT_LANE, LEFT_LANE + 1, 1):
		for r7_6 in range(BACK_TOWER, HQ_TOWER1 + 1, 1):
			var orderTurret := GetTurret(TEAM_ORDER, r3_6, r7_6)
			if orderTurret != null:
				if r7_6 == FRONT_TOWER:
					orderTurret.status.invulnerable = false
					orderTurret.status.targetable = true
				else:
					orderTurret.status.invulnerable = true
					orderTurret.status.SetNotTargetableToTeam(true, TEAM_CHAOS)
			var chaosTurret := GetTurret(TEAM_CHAOS, r3_6, r7_6)
			if chaosTurret != null:
				if r7_6 == FRONT_TOWER:
					chaosTurret.status.invulnerable = false
					chaosTurret.status.targetable = true
				else:
					chaosTurret.status.invulnerable = true
					chaosTurret.status.SetNotTargetableToTeam(true, TEAM_ORDER)

func GetMinionSpawnInfo(lane: int, r1_7: int, r2_7: Variant, team: int, wave: int) -> Dictionary:
	var TableForBarrack := SpawnTable
	if TableForBarrack.DidPowerGroup:
		TableForBarrack.NumOfCasterMinionsPerWave = TableForBarrack.NumOfCasterMinionsPerWave - 1
		TableForBarrack.DidPowerGroup = false

	if r1_7 % CASTER_MINION_SPAWN_FREQUENCY == 0:
		TableForBarrack.NumOfCasterMinionsPerWave = TableForBarrack.NumOfCasterMinionsPerWave + 1
		TableForBarrack.DidPowerGroup = true

	var r5_7: BarrackClass
	if team == TEAM_ORDER:
		r5_7 = OrderBarracksBonuses[lane]
	else:
		r5_7 = ChaosBarracksBonuses[lane]

	TableForBarrack.ExpRadius = EXP_GIVEN_RADIUS
	var lNumOfMeleeMinionsPerWave := TableForBarrack.NumOfMeleeMinionsPerWave
	var lNumOfArcherMinionsPerWave := TableForBarrack.NumOfArcherMinionsPerWave
	var lNumOfCasterMinionsPerWave := TableForBarrack.NumOfCasterMinionsPerWave
	var lNumOfSuperMinionsPerWave := TableForBarrack.NumOfSuperMinionsPerWave
	if wave != LAST_WAVE:
		const BARRACKSCOUNT = 6
		var totalMinionsRemaining := MAX_MINIONS_EVER - GetTotalTeamMinionsSpawned()
		if totalMinionsRemaining <= BARRACKSCOUNT * 7:
			if totalMinionsRemaining <= 0:
				SPECIAL_MINION_MODE = "None"
			elif BARRACKSCOUNT * 3 <= totalMinionsRemaining:
				SPECIAL_MINION_MODE = "3Archers"
			elif BARRACKSCOUNT <= totalMinionsRemaining:
				SPECIAL_MINION_MODE = "SpecialPowerMinion"
			else:
				SPECIAL_MINION_MODE = "None"
		else:
			SPECIAL_MINION_MODE = ""

		LAST_WAVE = wave

	if SPECIAL_MINION_MODE == "3Archers":
		lNumOfMeleeMinionsPerWave = 0
		lNumOfArcherMinionsPerWave = 3
		lNumOfCasterMinionsPerWave = 0
		lNumOfSuperMinionsPerWave = 0
	elif SPECIAL_MINION_MODE == "SpecialPowerMinion":
		lNumOfMeleeMinionsPerWave = 0
		lNumOfArcherMinionsPerWave = 0
		lNumOfCasterMinionsPerWave = 0
		lNumOfSuperMinionsPerWave = 2
	elif SPECIAL_MINION_MODE == "None":
		lNumOfMeleeMinionsPerWave = 0
		lNumOfArcherMinionsPerWave = 0
		lNumOfCasterMinionsPerWave = 0
		lNumOfSuperMinionsPerWave = 0

	if r5_7.WillSpawnSuperMinion == 1:
		if team == TEAM_ORDER and totalNumberOfChaosBarracks == 0 or team == TEAM_CHAOS and totalNumberOfOrderBarracks == 0:
			lNumOfSuperMinionsPerWave = 2
		else:
			lNumOfSuperMinionsPerWave = 1

		lNumOfCasterMinionsPerWave = 0

	if team == TEAM_ORDER:
		r5_7.MeleeMinionName = OrderNames.MeleeMinionName
		r5_7.ArcherMinionName = OrderNames.ArcherMinionName
		r5_7.CasterMinionName = OrderNames.CasterMinionName
		r5_7.SuperMinionName = OrderNames.SuperMinionName
	else:
		r5_7.MeleeMinionName = ChaosNames.MeleeMinionName
		r5_7.ArcherMinionName = ChaosNames.ArcherMinionName
		r5_7.CasterMinionName = ChaosNames.CasterMinionName
		r5_7.SuperMinionName = ChaosNames.SuperMinionName

	var ReturnTable := {
		NumOfMeleeMinionsPerWave = lNumOfMeleeMinionsPerWave,
		NumOfArcherMinionsPerWave = lNumOfArcherMinionsPerWave,
		NumOfCasterMinionsPerWave = lNumOfCasterMinionsPerWave,
		NumOfSuperMinionsPerWave = lNumOfSuperMinionsPerWave,

		WaveSpawnRate = TableForBarrack.WaveSpawnRate,
		SingleMinionSpawnDelay = TableForBarrack.SingleMinionSpawnDelay,

		MeleeMinionName = r5_7.MeleeMinionName,
		ArcherMinionName = r5_7.ArcherMinionName,
		CasterMinionName = r5_7.CasterMinionName,
		SuperMinionName = r5_7.SuperMinionName,

		IsDestroyed = r5_7.IsDestroyed,

		MeleeMinionArmor = r5_7.MeleeMinionArmor,
		MeleeMinionMagicResistance = r5_7.MeleeMinionMagicResistance,
		MeleeHPBonus = r5_7.MeleeHPBonus,
		MeleeDamageBonus = r5_7.MeleeDamageBonus,
		MeleeExpGiven = r5_7.MeleeExpGiven,
		MeleeGoldGiven = r5_7.MeleeGoldGiven,

		ArcherMinionArmor = r5_7.ArcherMinionArmor,
		ArcherMinionMagicResistance = r5_7.ArcherMinionMagicResistance,
		ArcherHPBonus = r5_7.ArcherHPBonus,
		ArcherDamageBonus = r5_7.ArcherDamageBonus,
		ArcherExpGiven = r5_7.ArcherExpGiven,
		ArcherGoldGiven = r5_7.ArcherGoldGiven,

		CasterMinionArmor = r5_7.CasterMinionArmor,
		CasterMinionMagicResistance = r5_7.CasterMinionMagicResistance,
		CasterHPBonus = r5_7.CasterHPBonus,
		CasterDamageBonus = r5_7.CasterDamageBonus,
		CasterExpGiven = r5_7.CasterExpGiven,
		CasterGoldGiven = r5_7.CasterGoldGiven,

		SuperMinionArmor = r5_7.SuperMinionArmor,
		SuperMinionMagicResistance = r5_7.SuperMinionMagicResistance,
		SuperHPBonus = r5_7.SuperHPBonus,
		SuperDamageBonus = r5_7.SuperDamageBonus,
		SuperExpGiven = r5_7.SuperExpGiven,
		SuperGoldGiven = r5_7.SuperGoldGiven,

		ExperienceRadius = TableForBarrack.ExpRadius,
	}
	return ReturnTable #TODO:

func DeactivateCorrectStructure(team: int, lane: int, pos: int) -> void:
	var r3_8: BuildingStatus	# notice: implicit variable refs by block#[4, 6, 8, 10, 13]
	if team == TEAM_ORDER:
		r3_8 = OrderBuildingStatus
	else:
		r3_8 = ChaosBuildingStatus

	if pos == FRONT_TOWER:
		r3_8[lane].Turret3 = false
		var r4_8 := GetTurret(team, lane, MIDDLE_TOWER)
		SetInvulnerable(r4_8, false)
		SetTargetable(r4_8, true)
	elif pos == MIDDLE_TOWER:
		r3_8[lane].Turret2 = false
		var r4_8 := GetTurret(team, lane, BACK_TOWER)
		SetInvulnerable(r4_8, false)
		SetTargetable(r4_8, true)
	elif pos == BACK_TOWER:
		r3_8[lane].Turret1 = false
		var r4_8 := GetDampener(team, lane)
		SetInvulnerable(r4_8, false)
		SetTargetable(r4_8, true)
	elif pos == HQ_TOWER2:
		r3_8.HQTower2 = false
		if r3_8.HQTower1 == false:
			var r4_8 := GetHQ(team)
			SetInvulnerable(r4_8, false)
			SetTargetable(r4_8, true)

	elif pos == HQ_TOWER1:
		r3_8.HQTower1 = false
		if r3_8.HQTower2 == false:
			var r4_8 := GetHQ(team)
			SetInvulnerable(r4_8, false)
			SetTargetable(r4_8, true)

func GetLuaBarracks(team: int, lane: int) -> BarrackClass:
	var r2_9: BarrackClass	# notice: implicit variable refs by block#[3]
	if team == TEAM_ORDER:
		r2_9 = OrderBarracksBonuses[lane]
	else:
		r2_9 = ChaosBarracksBonuses[lane]
	return r2_9

func GetDisableMinionSpawnTime(lane: int, team: int) -> float:
	var barrack := GetLuaBarracks(team, lane)
	return DISABLE_MINION_SPAWN_BASE_TIME + DISABLE_MINION_SPAWN_MAG_TIME * barrack.NumOfSpawnDisables

func DisableBarracksSpawn(lane: int, team: int) -> void:
	var cLangBarracks := GetBarracks(team, lane)
	var luaBarrack := GetLuaBarracks(team, lane)
	SetDisableMinionSpawn(cLangBarracks, GetDisableMinionSpawnTime(lane, team))
	luaBarrack.NumOfSpawnDisables = luaBarrack.NumOfSpawnDisables + 1

var BonusesCounter := 0
func ApplyBarracksDestructionBonuses(team: int, barrack_lane: int) -> void:
	BonusesCounter = BonusesCounter + 1
	for lane in range(3):
		if team == TEAM_ORDER:
			OrderBarracksBonuses[lane].MeleeHPBonus = OrderBarracksBonuses[lane].MeleeHPBonus + MELEE_HEALTH_INHIBITOR
			OrderBarracksBonuses[lane].MeleeDamageBonus = OrderBarracksBonuses[lane].MeleeDamageBonus + MELEE_DAMAGE_INHIBITOR
			OrderBarracksBonuses[lane].ArcherHPBonus = OrderBarracksBonuses[lane].ArcherHPBonus + ARCHER_HEALTH_INHIBITOR
			OrderBarracksBonuses[lane].ArcherDamageBonus = OrderBarracksBonuses[lane].ArcherDamageBonus + ARCHER_DAMAGE_INHIBITOR
			OrderBarracksBonuses[lane].CasterHPBonus = OrderBarracksBonuses[lane].CasterHPBonus + CASTER_HEALTH_INHIBITOR
			OrderBarracksBonuses[lane].CasterDamageBonus = OrderBarracksBonuses[lane].CasterDamageBonus + CASTER_DAMAGE_INHIBITOR
			OrderBarracksBonuses[lane].SuperHPBonus = OrderBarracksBonuses[lane].SuperHPBonus + SUPER_HEALTH_INHIBITOR
			OrderBarracksBonuses[lane].SuperDamageBonus = OrderBarracksBonuses[lane].SuperDamageBonus + SUPER_DAMAGE_INHIBITOR
			OrderBarracksBonuses[lane].MeleeExpGiven = OrderBarracksBonuses[lane].MeleeExpGiven - MELEE_EXP_INHIBITOR
			OrderBarracksBonuses[lane].MeleeGoldGiven = OrderBarracksBonuses[lane].MeleeGoldGiven - MELEE_GOLD_INHIBITOR
			OrderBarracksBonuses[lane].ArcherExpGiven = OrderBarracksBonuses[lane].ArcherExpGiven - ARCHER_EXP_INHIBITOR
			OrderBarracksBonuses[lane].ArcherGoldGiven = OrderBarracksBonuses[lane].MeleeGoldGiven - ARCHER_GOLD_INHIBITOR
			OrderBarracksBonuses[lane].CasterExpGiven = OrderBarracksBonuses[lane].CasterExpGiven - CASTER_EXP_INHIBITOR
			OrderBarracksBonuses[lane].CasterGoldGiven = OrderBarracksBonuses[lane].MeleeGoldGiven - CASTER_EXP_INHIBITOR
			OrderBarracksBonuses[lane].SuperExpGiven = OrderBarracksBonuses[lane].SuperExpGiven - SUPER_EXP_INHIBITOR
			OrderBarracksBonuses[lane].SuperGoldGiven = OrderBarracksBonuses[lane].MeleeGoldGiven - SUPER_EXP_INHIBITOR
			if lane == barrack_lane:
				totalNumberOfChaosBarracks = totalNumberOfChaosBarracks - 1
				OrderBarracksBonuses[lane].WillSpawnSuperMinion = 1

		elif team == TEAM_CHAOS:
			ChaosBarracksBonuses[lane].MeleeHPBonus = ChaosBarracksBonuses[lane].MeleeHPBonus + MELEE_HEALTH_INHIBITOR
			ChaosBarracksBonuses[lane].MeleeDamageBonus = ChaosBarracksBonuses[lane].MeleeDamageBonus + MELEE_DAMAGE_INHIBITOR
			ChaosBarracksBonuses[lane].ArcherHPBonus = ChaosBarracksBonuses[lane].ArcherHPBonus + ARCHER_HEALTH_INHIBITOR
			ChaosBarracksBonuses[lane].ArcherDamageBonus = ChaosBarracksBonuses[lane].ArcherDamageBonus + ARCHER_DAMAGE_INHIBITOR
			ChaosBarracksBonuses[lane].CasterHPBonus = ChaosBarracksBonuses[lane].CasterHPBonus + CASTER_HEALTH_INHIBITOR
			ChaosBarracksBonuses[lane].CasterDamageBonus = ChaosBarracksBonuses[lane].CasterDamageBonus + CASTER_DAMAGE_INHIBITOR
			ChaosBarracksBonuses[lane].SuperHPBonus = ChaosBarracksBonuses[lane].SuperHPBonus + SUPER_HEALTH_INHIBITOR
			ChaosBarracksBonuses[lane].SuperDamageBonus = ChaosBarracksBonuses[lane].SuperDamageBonus + SUPER_DAMAGE_INHIBITOR
			ChaosBarracksBonuses[lane].MeleeExpGiven = ChaosBarracksBonuses[lane].MeleeExpGiven - MELEE_EXP_INHIBITOR
			ChaosBarracksBonuses[lane].MeleeGoldGiven = ChaosBarracksBonuses[lane].MeleeGoldGiven - MELEE_GOLD_INHIBITOR
			ChaosBarracksBonuses[lane].ArcherExpGiven = ChaosBarracksBonuses[lane].ArcherExpGiven - ARCHER_EXP_INHIBITOR
			ChaosBarracksBonuses[lane].ArcherGoldGiven = ChaosBarracksBonuses[lane].MeleeGoldGiven - ARCHER_GOLD_INHIBITOR
			ChaosBarracksBonuses[lane].CasterExpGiven = ChaosBarracksBonuses[lane].CasterExpGiven - CASTER_EXP_INHIBITOR
			ChaosBarracksBonuses[lane].CasterGoldGiven = ChaosBarracksBonuses[lane].MeleeGoldGiven - CASTER_EXP_INHIBITOR
			ChaosBarracksBonuses[lane].SuperExpGiven = ChaosBarracksBonuses[lane].SuperExpGiven - SUPER_EXP_INHIBITOR
			ChaosBarracksBonuses[lane].SuperGoldGiven = ChaosBarracksBonuses[lane].MeleeGoldGiven - SUPER_EXP_INHIBITOR
			if lane == barrack_lane:
				totalNumberOfOrderBarracks = totalNumberOfOrderBarracks - 1
				ChaosBarracksBonuses[lane].WillSpawnSuperMinion = 1

var ReductionCounter := 0
func ApplyBarracksRespawnReductions(team: int, barrack_lane: int) -> void:
	ReductionCounter = ReductionCounter + 1
	for lane in range(3):
		if team == TEAM_ORDER:
			OrderBarracksBonuses[lane].MeleeHPBonus = OrderBarracksBonuses[lane].MeleeHPBonus - MELEE_HEALTH_INHIBITOR
			OrderBarracksBonuses[lane].MeleeDamageBonus = OrderBarracksBonuses[lane].MeleeDamageBonus - MELEE_DAMAGE_INHIBITOR
			OrderBarracksBonuses[lane].ArcherHPBonus = OrderBarracksBonuses[lane].ArcherHPBonus - ARCHER_HEALTH_INHIBITOR
			OrderBarracksBonuses[lane].ArcherDamageBonus = OrderBarracksBonuses[lane].ArcherDamageBonus - ARCHER_DAMAGE_INHIBITOR
			OrderBarracksBonuses[lane].CasterHPBonus = OrderBarracksBonuses[lane].CasterHPBonus - CASTER_HEALTH_INHIBITOR
			OrderBarracksBonuses[lane].CasterDamageBonus = OrderBarracksBonuses[lane].CasterDamageBonus - CASTER_DAMAGE_INHIBITOR
			OrderBarracksBonuses[lane].SuperHPBonus = OrderBarracksBonuses[lane].SuperHPBonus - SUPER_HEALTH_INHIBITOR
			OrderBarracksBonuses[lane].SuperDamageBonus = OrderBarracksBonuses[lane].SuperDamageBonus - SUPER_DAMAGE_INHIBITOR
			OrderBarracksBonuses[lane].MeleeExpGiven = OrderBarracksBonuses[lane].MeleeExpGiven + MELEE_EXP_INHIBITOR
			OrderBarracksBonuses[lane].MeleeGoldGiven = OrderBarracksBonuses[lane].MeleeGoldGiven + MELEE_GOLD_INHIBITOR
			OrderBarracksBonuses[lane].ArcherExpGiven = OrderBarracksBonuses[lane].ArcherExpGiven + ARCHER_EXP_INHIBITOR
			OrderBarracksBonuses[lane].ArcherGoldGiven = OrderBarracksBonuses[lane].MeleeGoldGiven + ARCHER_GOLD_INHIBITOR
			OrderBarracksBonuses[lane].CasterExpGiven = OrderBarracksBonuses[lane].CasterExpGiven + CASTER_EXP_INHIBITOR
			OrderBarracksBonuses[lane].CasterGoldGiven = OrderBarracksBonuses[lane].MeleeGoldGiven + CASTER_EXP_INHIBITOR
			OrderBarracksBonuses[lane].SuperExpGiven = OrderBarracksBonuses[lane].SuperExpGiven + SUPER_EXP_INHIBITOR
			OrderBarracksBonuses[lane].SuperGoldGiven = OrderBarracksBonuses[lane].MeleeGoldGiven + SUPER_EXP_INHIBITOR
			if lane == barrack_lane:
				totalNumberOfChaosBarracks = totalNumberOfChaosBarracks + 1
				OrderBarracksBonuses[lane].WillSpawnSuperMinion = 0

			if totalNumberOfChaosBarracks == 3:
				HQ = GetHQ(TEAM_CHAOS)
				SetInvulnerable(HQ, true)
				SetTargetable(HQ, false)
				for r9_13 in range(RIGHT_LANE, LEFT_LANE + 1, 1):
					var r10_13 := GetTurret(TEAM_CHAOS, r9_13, HQ_TOWER1)
					var r11_13 := GetTurret(TEAM_CHAOS, r9_13, HQ_TOWER2)
					if r10_13 != Nil:
						SetInvulnerable(r10_13, true)
						SetTargetable(r10_13, false)

					if r11_13 != Nil:
						SetInvulnerable(r11_13, true)
						SetTargetable(r11_13, false)

		elif team == TEAM_CHAOS:
			ChaosBarracksBonuses[lane].MeleeHPBonus = ChaosBarracksBonuses[lane].MeleeHPBonus - MELEE_HEALTH_INHIBITOR
			ChaosBarracksBonuses[lane].MeleeDamageBonus = ChaosBarracksBonuses[lane].MeleeDamageBonus - MELEE_DAMAGE_INHIBITOR
			ChaosBarracksBonuses[lane].ArcherHPBonus = ChaosBarracksBonuses[lane].ArcherHPBonus - ARCHER_HEALTH_INHIBITOR
			ChaosBarracksBonuses[lane].ArcherDamageBonus = ChaosBarracksBonuses[lane].ArcherDamageBonus - ARCHER_DAMAGE_INHIBITOR
			ChaosBarracksBonuses[lane].CasterHPBonus = ChaosBarracksBonuses[lane].CasterHPBonus - CASTER_HEALTH_INHIBITOR
			ChaosBarracksBonuses[lane].CasterDamageBonus = ChaosBarracksBonuses[lane].CasterDamageBonus - CASTER_DAMAGE_INHIBITOR
			ChaosBarracksBonuses[lane].SuperHPBonus = ChaosBarracksBonuses[lane].SuperHPBonus - SUPER_HEALTH_INHIBITOR
			ChaosBarracksBonuses[lane].SuperDamageBonus = ChaosBarracksBonuses[lane].SuperDamageBonus - SUPER_DAMAGE_INHIBITOR
			ChaosBarracksBonuses[lane].MeleeExpGiven = ChaosBarracksBonuses[lane].MeleeExpGiven + MELEE_EXP_INHIBITOR
			ChaosBarracksBonuses[lane].MeleeGoldGiven = ChaosBarracksBonuses[lane].MeleeGoldGiven + MELEE_GOLD_INHIBITOR
			ChaosBarracksBonuses[lane].ArcherExpGiven = ChaosBarracksBonuses[lane].ArcherExpGiven + ARCHER_EXP_INHIBITOR
			ChaosBarracksBonuses[lane].ArcherGoldGiven = ChaosBarracksBonuses[lane].MeleeGoldGiven + ARCHER_GOLD_INHIBITOR
			ChaosBarracksBonuses[lane].CasterExpGiven = ChaosBarracksBonuses[lane].CasterExpGiven + CASTER_EXP_INHIBITOR
			ChaosBarracksBonuses[lane].CasterGoldGiven = ChaosBarracksBonuses[lane].MeleeGoldGiven + CASTER_EXP_INHIBITOR
			ChaosBarracksBonuses[lane].SuperExpGiven = ChaosBarracksBonuses[lane].SuperExpGiven + SUPER_EXP_INHIBITOR
			ChaosBarracksBonuses[lane].SuperGoldGiven = ChaosBarracksBonuses[lane].MeleeGoldGiven + SUPER_EXP_INHIBITOR
			if lane == barrack_lane:
				totalNumberOfOrderBarracks = totalNumberOfOrderBarracks + 1
				ChaosBarracksBonuses[lane].WillSpawnSuperMinion = 0

			if totalNumberOfOrderBarracks == 3:
				var r6_13 := GetHQ(TEAM_ORDER)
				SetInvulnerable(r6_13, true)
				SetTargetable(r6_13, false)
				for r10_13 in range(RIGHT_LANE, LEFT_LANE + 1, 1):
					var r11_13 := GetTurret(TEAM_ORDER, r10_13, HQ_TOWER1)
					var r12_13 := GetTurret(TEAM_ORDER, r10_13, HQ_TOWER2)
					if r11_13 != Nil:
						SetInvulnerable(r11_13, true)
						SetTargetable(r11_13, false)

					if r12_13 != Nil:
						SetInvulnerable(r12_13, true)
						SetTargetable(r12_13, false)

var ReactiveCounter := 0
func BarrackReactiveEvent(team: int, lane: int) -> void:
	ReactiveCounter = ReactiveCounter + 1
	var r2_14 := OppositeTeam(team)
	var dampener = GetDampener(team, lane)
	SetInvulnerable(dampener, false)
	SetTargetable(dampener, true)
	ApplyBarracksRespawnReductions(r2_14, lane)

var DisactivatedCounter := 0
func HandleDestroyedObject(r0_15: Unit):
	HQType = GetHQType(r0_15)
	if HQType == ORDER_HQ or HQType == CHAOS_HQ:
		if HQType == CHAOS_HQ:
			EndOfGameCeremony(TEAM_ORDER, r0_15)
		else:
			EndOfGameCeremony(TEAM_CHAOS, r0_15)
		return

	if IsDampener(r0_15):
		barrack = GetLinkedBarrack(r0_15)
		barrackTeam = GetTeamID(barrack)
		barrackLane = GetLane(r0_15)
		DisableBarracksSpawn(barrackLane, barrackTeam)
		SetDampenerState(r0_15, DampenerRegenerationState)
		SetInvulnerable(r0_15, true)
		SetTargetable(r0_15, false)
		DisactivatedCounter = DisactivatedCounter + 1
		var r1_15 := GetTurret(barrackTeam, 1, HQ_TOWER1)
		var r2_15 := GetTurret(barrackTeam, 1, HQ_TOWER2)
		if r1_15 != Nil:
			SetInvulnerable(r1_15, false)
			SetTargetable(r1_15, true)

		if r2_15 != Nil:
			SetInvulnerable(r2_15, false)
			SetTargetable(r2_15, true)

		if r1_15 == Nil and r2_15 == Nil:
			var r3_15 := GetHQ(barrackTeam)
			SetInvulnerable(r3_15, false)
			SetTargetable(r3_15, true)

		var r3_15 := null
		if barrackTeam == TEAM_CHAOS:
			r3_15 = TEAM_ORDER
		else:
			r3_15 = TEAM_CHAOS

		ApplyBarracksDestructionBonuses(r3_15, barrackLane)

	if IsTurretAI(r0_15):
		DeactivateCorrectStructure(GetTeamID(r0_15), GetObjectLaneId(r0_15), GetTurretPosition(r0_15))
		return

	var r1_15 := GetDampenerType(r0_15)
	if r1_15 > -1:
		var r2_15 := 0
		var r3_15 := TEAM_ORDER
		var r4_15 := TEAM_CHAOS
		var r5_15 := r1_15 % TEAM_CHAOS
		if RIGHT_LANE <= r5_15 and r5_15 <= LEFT_LANE:
			r2_15 = ChaosBarracksBonuses[r5_15 + 1]
			ChaosBuildingStatus[r5_15 + 1].Barracks = false
		else:
			r5_15 = r5_15 - TEAM_ORDER
			r3_15 = TEAM_CHAOS
			r4_15 = TEAM_ORDER
			r2_15 = OrderBarracksBonuses[r5_15 + 1]
			OrderBuildingStatus[r5_15 + 1].Barracks = false

	else:
		Log("Could not find Linking barracks!")

	return true

func IncreaseCannonMinionSpawnRate() -> void:
	CASTER_MINION_SPAWN_FREQUENCY = 2
