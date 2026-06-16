class_name CombatHitbox3D
extends Area3D

signal hit_landed(hurtbox: CombatHurtbox3D, damage_instance: DamageInstance)

@export_group("Damage")
## Attack data used when this hitbox overlaps a hurtbox.
@export var attack_data: AttackData
## Team name used to prevent friendly fire against matching hurtboxes.
@export var owner_team := "neutral"
## Optional node path used as the damage source; defaults to this node's parent.
@export var source_path: NodePath
## If enabled, this hitbox starts monitoring as soon as it enters the scene.
@export var start_active := false

var _already_hit: Array[CombatHurtbox3D] = []
var _activation_id := 0


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monitoring = start_active


func activate() -> void:
	_activation_id += 1
	_already_hit.clear()
	monitoring = true


func activate_for(duration: float) -> void:
	activate()
	if duration > 0.0:
		_deactivate_after(duration, _activation_id)


func deactivate() -> void:
	monitoring = false


func cancel() -> void:
	_activation_id += 1
	_already_hit.clear()
	deactivate()


func _deactivate_after(duration: float, activation_id: int) -> void:
	await get_tree().create_timer(duration).timeout
	if activation_id == _activation_id:
		deactivate()


func _on_area_entered(area: Area3D) -> void:
	var hurtbox := area as CombatHurtbox3D
	if hurtbox == null:
		return

	if hurtbox in _already_hit:
		return

	if hurtbox.team == owner_team:
		return

	var source := get_source()
	if hurtbox.get_combatant() == source:
		return

	_already_hit.append(hurtbox)
	var damage_instance := hurtbox.receive_attack(attack_data, source, self)
	hit_landed.emit(hurtbox, damage_instance)


func get_source() -> Node:
	if not source_path.is_empty():
		var source := get_node_or_null(source_path)
		if source:
			return source

	return get_parent()
