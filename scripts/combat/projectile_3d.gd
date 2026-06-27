class_name Projectile3D
extends Area3D

@export var attack_data: AttackData
@export var owner_team := "neutral"
@export var speed := 12.0
@export var lifetime := 4.0
@export var path_type: EnemyDefinition.ProjectilePathType = EnemyDefinition.ProjectilePathType.DIRECT
@export var arc_height := 3.0

var source: Node
var _direction := Vector3.FORWARD
var _elapsed := 0.0
var _start_position := Vector3.ZERO
var _target_position := Vector3.ZERO
var _travel_time := 1.0
var _already_hit: Array[CombatHurtbox3D] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_start_position = global_position


func configure(
	new_attack_data: AttackData,
	new_source: Node,
	new_owner_team: String,
	new_speed: float,
	new_lifetime: float,
	new_path_type: EnemyDefinition.ProjectilePathType,
	new_arc_height: float,
	target_position: Vector3
) -> void:
	attack_data = new_attack_data
	source = new_source
	owner_team = new_owner_team
	speed = new_speed
	lifetime = new_lifetime
	path_type = new_path_type
	arc_height = new_arc_height
	_start_position = global_position
	_target_position = target_position

	var to_target := _target_position - _start_position
	if to_target.length_squared() > 0.001:
		_direction = to_target.normalized()
		look_at(_target_position, Vector3.UP)

	_travel_time = maxf(to_target.length() / maxf(speed, 0.1), 0.05)


func _physics_process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()
		return

	if path_type == EnemyDefinition.ProjectilePathType.ARC:
		_update_arc_path()
	else:
		global_position += _direction * speed * delta


func _update_arc_path() -> void:
	var progress := clampf(_elapsed / _travel_time, 0.0, 1.0)
	var arc_position := _start_position.lerp(_target_position, progress)
	arc_position.y += sin(progress * PI) * arc_height
	global_position = arc_position

	if progress >= 1.0:
		queue_free()


func _on_area_entered(area: Area3D) -> void:
	var hurtbox := area as CombatHurtbox3D
	if hurtbox == null:
		return
	if hurtbox in _already_hit:
		return
	if hurtbox.team == owner_team:
		return
	if hurtbox.get_combatant() == source:
		return

	_already_hit.append(hurtbox)
	hurtbox.receive_attack(attack_data, source, self)
	queue_free()
