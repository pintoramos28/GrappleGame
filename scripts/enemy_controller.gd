extends CharacterBody3D

@export_group("Attack Timing")
## Time between enemy attacks while a target remains in range.
@export var attack_cooldown_time := 1.25
## Duration that the enemy attack hitbox remains active.
@export var attack_active_time := 0.2

@onready var health: CombatHealth = $Health
@onready var attack_hitbox: CombatHitbox3D = $AttackHitbox
@onready var attack_visual: AttackArcVisual3D = $AttackVisual
@onready var attack_range: Area3D = $AttackRange
@onready var bt_player: BTPlayer = $BTPlayer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	add_to_group("enemies")
	_set_ai_blackboard_defaults()
	_configure_behavior_tree()
	bt_player.restart()
	health.damaged.connect(_on_health_damaged)
	health.died.connect(_on_died)
	attack_range.body_entered.connect(_on_attack_range_body_entered)
	attack_range.body_exited.connect(_on_attack_range_body_exited)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()


func _set_ai_blackboard_defaults() -> void:
	bt_player.blackboard.set_var(&"target", null)
	bt_player.blackboard.set_var(&"attack_hitbox", attack_hitbox)
	bt_player.blackboard.set_var(&"attack_visual", attack_visual)
	bt_player.blackboard.set_var(&"attack_active_time", attack_active_time)


func _configure_behavior_tree() -> void:
	if bt_player.behavior_tree == null:
		return

	var behavior_tree := bt_player.behavior_tree.clone()
	bt_player.behavior_tree = behavior_tree
	_set_attack_cooldown_duration(behavior_tree.get_root_task())


func _set_attack_cooldown_duration(task: BTTask) -> void:
	if task == null:
		return

	if task is BTCooldown and task.get_custom_name() == "Attack cooldown":
		task.duration = attack_cooldown_time

	for child_index in task.get_child_count():
		_set_attack_cooldown_duration(task.get_child(child_index))


func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		bt_player.blackboard.set_var(&"target", body)


func _on_attack_range_body_exited(body: Node3D) -> void:
	if body == bt_player.blackboard.get_var(&"target", null):
		bt_player.blackboard.set_var(&"target", null)


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
