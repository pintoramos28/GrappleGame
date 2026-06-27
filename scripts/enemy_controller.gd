extends CharacterBody3D

@export var enemy_definition: EnemyDefinition

@onready var health: CombatHealth = $Health
@onready var attack_hitbox: CombatHitbox3D = $AttackHitbox
@onready var attack_visual: AttackArcVisual3D = $AttackVisual
@onready var vision: EnemyVision3D = $EnemyVision3D
@onready var movement: EnemyMovement3D = $EnemyMovement3D
@onready var projectile_spawn_point: Node3D = $ProjectileSpawnPoint
@onready var bt_player: BTPlayer = $BTPlayer
@onready var enemy_hsm: LimboHSM = $EnemyHSM
@onready var ready_state: LimboState = $EnemyHSM/ReadyState
@onready var attack_windup_state: LimboState = $EnemyHSM/AttackWindupState
@onready var attack_active_state: LimboState = $EnemyHSM/AttackActiveState
@onready var attack_recovery_state: LimboState = $EnemyHSM/AttackRecoveryState
@onready var dead_state: LimboState = $EnemyHSM/DeadState

const EVENT_ATTACK_STARTED := &"attack_started"
const EVENT_ATTACK_PHASE_FINISHED := &"attack_phase_finished"
const EVENT_ATTACK_CANCELLED := &"attack_cancelled"
const EVENT_DIED := &"died"

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_attacking := false
var is_dead := false


func _ready() -> void:
	add_to_group("enemies")
	_configure_from_definition()
	_configure_behavior_tree()
	_set_ai_blackboard_defaults()
	_init_enemy_state_machine()
	bt_player.restart()
	health.damaged.connect(_on_health_damaged)
	health.died.connect(_on_died)
	vision.target_spotted.connect(_on_vision_target_spotted)
	vision.target_lost.connect(_on_vision_target_lost)
	vision.target_visibility_changed.connect(_on_vision_visibility_changed)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif is_dead:
		stop_horizontal_movement(delta)

	_update_ai_blackboard_runtime_values()
	if enemy_hsm and enemy_hsm.is_active():
		enemy_hsm.update(delta)
	move_and_slide()


func _configure_from_definition() -> void:
	if enemy_definition == null:
		return

	vision.configure(enemy_definition)
	movement.configure(enemy_definition)
	if enemy_definition.attack_data:
		attack_hitbox.attack_data = enemy_definition.attack_data
	_configure_melee_hitbox_range()


func _configure_behavior_tree() -> void:
	if bt_player.behavior_tree == null:
		return

	bt_player.behavior_tree = bt_player.behavior_tree.clone()


func _configure_melee_hitbox_range() -> void:
	if attack_hitbox == null or enemy_definition == null or is_ranged_enemy():
		return

	attack_hitbox.position.z = -enemy_definition.attack_range * 0.5
	for child in attack_hitbox.get_children():
		var shape_node := child as CollisionShape3D
		if shape_node == null:
			continue

		var box := shape_node.shape as BoxShape3D
		if box == null:
			continue

		box = box.duplicate()
		box.size.z = enemy_definition.attack_range
		shape_node.shape = box


func _set_ai_blackboard_defaults() -> void:
	bt_player.blackboard.set_var(&"target", null)
	bt_player.blackboard.set_var(&"last_seen_position", Vector3.ZERO)
	bt_player.blackboard.set_var(&"enemy_definition", enemy_definition)
	bt_player.blackboard.set_var(&"vision", vision)
	bt_player.blackboard.set_var(&"movement", movement)
	bt_player.blackboard.set_var(&"attack_hitbox", attack_hitbox)
	bt_player.blackboard.set_var(&"attack_visual", attack_visual)
	bt_player.blackboard.set_var(&"is_attacking", false)
	bt_player.blackboard.set_var(&"has_line_of_sight", false)


func _update_ai_blackboard_runtime_values() -> void:
	if bt_player == null:
		return

	bt_player.blackboard.set_var(&"is_attacking", is_attacking)
	bt_player.blackboard.set_var(&"has_line_of_sight", vision.has_line_of_sight)
	bt_player.blackboard.set_var(&"last_seen_position", vision.last_seen_position)


func _init_enemy_state_machine() -> void:
	enemy_hsm.add_transition(ready_state, attack_windup_state, EVENT_ATTACK_STARTED)
	enemy_hsm.add_transition(attack_windup_state, attack_active_state, EVENT_ATTACK_PHASE_FINISHED)
	enemy_hsm.add_transition(attack_active_state, attack_recovery_state, EVENT_ATTACK_PHASE_FINISHED)
	enemy_hsm.add_transition(attack_recovery_state, ready_state, EVENT_ATTACK_PHASE_FINISHED)
	enemy_hsm.add_transition(enemy_hsm.ANYSTATE, ready_state, EVENT_ATTACK_CANCELLED)
	enemy_hsm.add_transition(enemy_hsm.ANYSTATE, dead_state, EVENT_DIED)
	enemy_hsm.initialize(self)
	enemy_hsm.set_active(true)
	enemy_hsm.set_process(false)
	enemy_hsm.set_physics_process(false)


func request_attack() -> bool:
	if is_dead or is_attacking:
		return false

	var target := get_target()
	if not is_instance_valid(target):
		return false

	enemy_hsm.dispatch(EVENT_ATTACK_STARTED)
	return true


func perform_attack_active_phase(active_time: float) -> void:
	var target := get_target()
	if is_instance_valid(target):
		face_target(target)

	if is_ranged_enemy():
		_fire_projectile(target)
		return

	if attack_visual:
		attack_visual.play(active_time)
	if attack_hitbox:
		attack_hitbox.activate()


func get_target() -> Node3D:
	return bt_player.blackboard.get_var(&"target", null) as Node3D


func face_target(target: Node3D) -> void:
	if not is_instance_valid(target):
		return

	var look_position := target.global_position
	look_position.y = global_position.y
	if global_position.distance_squared_to(look_position) > 0.01:
		look_at(look_position, Vector3.UP)


func is_ranged_enemy() -> bool:
	return (
		enemy_definition != null
		and enemy_definition.enemy_kind == EnemyDefinition.EnemyKind.RANGED
	)


func get_attack_range() -> float:
	return enemy_definition.attack_range if enemy_definition else 2.0


func get_attack_windup_time() -> float:
	return enemy_definition.attack_windup_time if enemy_definition else 0.18


func get_attack_active_time() -> float:
	return enemy_definition.attack_active_time if enemy_definition else 0.2


func get_attack_recovery_time() -> float:
	return enemy_definition.get_recovery_time() if enemy_definition else 0.55


func get_distance_to_target(target: Node3D) -> float:
	if not is_instance_valid(target):
		return INF

	var to_target := target.global_position - global_position
	to_target.y = 0.0
	return to_target.length()


func move_toward_target(target: Node3D, delta: float) -> bool:
	if not is_instance_valid(target):
		stop_horizontal_movement(delta)
		return false

	return movement.move_toward_position(target.global_position, delta)


func move_away_from_target(target: Node3D, delta: float) -> void:
	if not is_instance_valid(target):
		stop_horizontal_movement(delta)
		return

	movement.move_away_from_position(target.global_position, delta)


func stop_horizontal_movement(delta: float) -> void:
	movement.stop_horizontal_movement(delta)


func _fire_projectile(target: Node3D) -> void:
	if enemy_definition == null or enemy_definition.projectile_scene == null:
		return

	var projectile := enemy_definition.projectile_scene.instantiate() as Projectile3D
	if projectile == null:
		return

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_parent()

	parent.add_child(projectile)
	projectile.global_transform = projectile_spawn_point.global_transform

	var target_position := (
		target.global_position + Vector3.UP
		if is_instance_valid(target)
		else projectile.global_position - global_transform.basis.z * get_attack_range()
	)
	projectile.configure(
		enemy_definition.attack_data,
		self,
		"enemy",
		enemy_definition.projectile_speed,
		enemy_definition.projectile_lifetime,
		enemy_definition.projectile_path_type,
		enemy_definition.projectile_arc_height,
		target_position
	)


func _on_vision_target_spotted(target: Node3D) -> void:
	bt_player.blackboard.set_var(&"target", target)
	bt_player.blackboard.set_var(&"last_seen_position", vision.last_seen_position)
	bt_player.blackboard.set_var(&"has_line_of_sight", true)


func _on_vision_target_lost(target: Node3D) -> void:
	if target == bt_player.blackboard.get_var(&"target", null):
		bt_player.blackboard.set_var(&"target", null)
	bt_player.blackboard.set_var(&"has_line_of_sight", false)


func _on_vision_visibility_changed(_target: Node3D, can_see_target: bool) -> void:
	bt_player.blackboard.set_var(&"has_line_of_sight", can_see_target)


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
	is_dead = true
	enemy_hsm.dispatch(EVENT_DIED)
	queue_free()
