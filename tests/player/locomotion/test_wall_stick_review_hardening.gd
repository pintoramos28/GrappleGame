extends GutTest
const PLAYER := preload("res://scenes/player.tscn")
var _saved_rate: int

func before_all() -> void:
	_saved_rate = Engine.physics_ticks_per_second

func after_each() -> void:
	Engine.physics_ticks_per_second = _saved_rate

func test_engine_review_repros_at_both_rates() -> void:
	for rate in [60, 120]:
		for scenario in WallStickReviewCases.CASES:
			var report := await WallStickReviewCases.run(get_tree(), scenario, rate)
			assert_true(report.passed, "%s @ %d Hz: %s" % [scenario, rate, report])
			print("[wall-stick-review-hardening] ", report)

func test_missing_and_invalid_stick_definition_deactivate_composition() -> void:
	var invalid := WallStickDefinition.new()
	invalid.maximum_entry_speed_mps = -1.0
	for definition in [null, invalid]:
		var viewport := SubViewport.new()
		viewport.world_3d = World3D.new()
		get_tree().root.add_child(viewport)
		autofree(viewport)
		var player := PLAYER.instantiate() as CharacterBody3D
		player.set("capture_mouse_on_start", false)
		player.set("wall_stick_definition", definition)
		viewport.add_child(player)
		assert_push_error("requires a valid WallStickDefinition")
		assert_false(bool(player.get("_player_initialized")))
		assert_false(bool(player.get_node(^"PlayerInputSource").get("_enabled")))
		assert_false(player.get_node(^"MovementHSM").is_active())
		assert_false(player.get_node(^"AttackHSM").is_active())
		assert_false(bool(player.call("_try_start_wall_stick_from_contact", Vector2.ZERO, Vector3.ZERO, null, Vector3.ZERO)))
		await get_tree().physics_frame
		assert_eq(player.call("get_motion_step"), 0)

func test_geometry_listener_does_not_retain_a_released_attachment() -> void:
	var viewport := SubViewport.new()
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)
	var fixture := WallStickReviewCases.FIXTURE.instantiate() as WallStickMotionFixture
	viewport.add_child(fixture)
	for _i in range(6):
		await get_tree().physics_frame
	await get_tree().process_frame
	var attachment_ref: WeakRef = weakref(fixture.player.get("_wall_stick_attachment"))
	fixture.player.call("_clear_wall_stick")
	assert_null(attachment_ref.get_ref(), "Shape.changed holds only a weak listener; clear releases the attachment")
