class_name Map1_CreateLevelProps extends CreateLevelProps

func create_level_props() -> void:
	create_child_turret("Turret_T1_R_03", "OrderTurretNormal", Enums.Team.ORDER, 3, 0)
	create_child_turret("Turret_T1_R_02", "OrderTurretNormal2", Enums.Team.ORDER, 2, 0)
	create_child_turret("Turret_T1_C_07", "OrderTurretDragon", Enums.Team.ORDER, 1, 0)
	create_child_turret("Turret_T2_R_03", "ChaosTurretWorm", Enums.Team.CHAOS, 3, 0)
	create_child_turret("Turret_T2_R_02", "ChaosTurretWorm2", Enums.Team.CHAOS, 2, 0)
	create_child_turret("Turret_T2_R_01", "ChaosTurretGiant", Enums.Team.CHAOS, 1, 0)
	create_child_turret("Turret_T1_C_05", "OrderTurretNormal", Enums.Team.ORDER, 3, 1)
	create_child_turret("Turret_T1_C_04", "OrderTurretNormal2", Enums.Team.ORDER, 2, 1)
	create_child_turret("Turret_T1_C_03", "OrderTurretDragon", Enums.Team.ORDER, 1, 1)
	create_child_turret("Turret_T1_C_01", "OrderTurretAngel", Enums.Team.ORDER, 5, 1)
	create_child_turret("Turret_T1_C_02", "OrderTurretAngel", Enums.Team.ORDER, 4, 1)
	create_child_turret("Turret_T2_C_05", "ChaosTurretWorm", Enums.Team.CHAOS, 3, 1)
	create_child_turret("Turret_T2_C_04", "ChaosTurretWorm2", Enums.Team.CHAOS, 2, 1)
	create_child_turret("Turret_T2_C_03", "ChaosTurretGiant", Enums.Team.CHAOS, 1, 1)
	create_child_turret("Turret_T2_C_01", "ChaosTurretNormal", Enums.Team.CHAOS, 5, 1)
	create_child_turret("Turret_T2_C_02", "ChaosTurretNormal", Enums.Team.CHAOS, 4, 1)
	create_child_turret("Turret_OrderTurretShrine", "OrderTurretShrine", Enums.Team.ORDER, 0, 1)
	create_child_turret("Turret_ChaosTurretShrine", "ChaosTurretShrine", Enums.Team.CHAOS, 0, 1)
	create_child_turret("Turret_T1_L_03", "OrderTurretNormal", Enums.Team.ORDER, 3, 2)
	create_child_turret("Turret_T1_L_02", "OrderTurretNormal2", Enums.Team.ORDER, 2, 2)
	create_child_turret("Turret_T1_C_06", "OrderTurretDragon", Enums.Team.ORDER, 1, 2)
	create_child_turret("Turret_T2_L_03", "ChaosTurretWorm", Enums.Team.CHAOS, 3, 2)
	create_child_turret("Turret_T2_L_02", "ChaosTurretWorm2", Enums.Team.CHAOS, 2, 2)
	create_child_turret("Turret_T2_L_01", "ChaosTurretGiant", Enums.Team.CHAOS, 1, 2)
