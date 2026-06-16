extends CharacterBody3D

@export_group("Attack Timing")
## Time between enemy attacks while a target remains in range.
@export var attack_cooldown_time := 1.25
## Duration that the enemy attack hitbox remains active.
@export var attack_active_time := 0.2

@onready var health: CombatHealth = $Health
@onready var attack_hitbox: CombatHitbox3D = $AttackHitbox
@onready var attack_range: Area3D = $AttackRange

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var attack_cooldown := 0.0
var target: Node3D


func _ready() -> void:
	add_to_group("enemies")
	health.damaged.connect(_on_health_damaged)
	health.died.connect(_on_died)
	attack_range.body_entered.connect(_on_attack_range_body_entered)
	attack_range.body_exited.connect(_on_attack_range_body_exited)


func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

	if not is_instance_valid(target):
		return

	_face_target()
	if attack_cooldown <= 0.0:
		attack_hitbox.activate_for(attack_active_time)
		attack_cooldown = attack_cooldown_time


func _face_target() -> void:
	var look_position := target.global_position
	look_position.y = global_position.y
	if global_position.distance_squared_to(look_position) > 0.01:
		look_at(look_position, Vector3.UP)


func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = body


func _on_attack_range_body_exited(body: Node3D) -> void:
	if body == target:
		target = null


func _on_health_damaged(damage_instance: DamageInstance) -> void:
	print(
		"%s took %.1f %s damage. HP: %.1f/%.1f" % [
			name,
			damage_instance.final_damage,
			damage_instance.get_largest_damage_type(),
			health.current_health,
			health.max_health,
		]
	)


func _on_died(_damage_instance: DamageInstance) -> void:
	queue_free()
