class_name EnemyDefinition
extends Resource

enum EnemyKind { MELEE, RANGED }
enum ProjectilePathType { DIRECT, ARC }

@export_group("Identity")
@export var enemy_kind: EnemyKind = EnemyKind.MELEE

@export_group("Vision")
@export var vision_range := 12.0
@export_range(1.0, 360.0, 1.0) var vision_angle_degrees := 110.0
@export var lose_target_after_seconds := 1.5
@export var require_line_of_sight := true

@export_group("Movement")
@export var move_speed := 4.0
@export var acceleration := 14.0
@export var deceleration := 18.0
@export var stopping_distance := 0.25

@export_group("Ranged Positioning")
@export var ranged_min_distance := 5.0
@export var ranged_ideal_distance := 8.0
@export var ranged_max_distance := 11.0

@export_group("Attack")
@export var attack_data: AttackData
## Attacks per second. Recovery is lengthened when needed so attacks do not exceed this rate.
@export var attack_speed := 1.0
@export var attack_windup_time := 0.18
@export var attack_active_time := 0.2
@export var attack_recovery_time := 0.55
@export var attack_range := 2.0
@export var attack_damage := 10.0

@export_group("Ranged Attack")
@export var projectile_scene: PackedScene
@export var projectile_speed := 12.0
@export var projectile_lifetime := 4.0
@export var projectile_arc_height := 3.0
@export var projectile_path_type: ProjectilePathType = ProjectilePathType.DIRECT


func get_total_attack_interval() -> float:
	if attack_speed <= 0.0:
		return attack_windup_time + attack_active_time + attack_recovery_time

	return 1.0 / attack_speed


func get_recovery_time() -> float:
	var speed_limited_recovery := get_total_attack_interval() - attack_windup_time - attack_active_time
	return maxf(attack_recovery_time, speed_limited_recovery)
