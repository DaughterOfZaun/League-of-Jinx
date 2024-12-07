class_name BluePillSpell extends Spell

var particle: Particle
func channeling_start() -> void:
	particle = Particle.create(preload("TeleportHome.tscn")).bind(host).target(host).more_flags(false)
	host.buffs.add(host, BluePillBuff.new(false), 1, 1, 7.9)

func channeling_success_stop() -> void:
	attacker.teleport(host.team, Enums.SpawnType.SPAWN_LOCATION)
	(host as Champion).set_camera_position(host.position_3d)
	Particle.create(preload("teleportarrive.tscn")).bind(host).target(host).more_flags(false)

func channeling_cancel_stop() -> void:
	particle.remove()
