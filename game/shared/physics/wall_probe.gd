class_name WallProbe
extends PhysicsQueryProfile


func _init() -> void:
	profile_id = &"player.contact.wall_probe"
	probe_direction = Vector3.RIGHT
	probe_distance_m = 0.8
	sweep_distance_cap_m = 0.8
	thickness_m = 0.12
	support_max_distance_m = 0.0
	ground_min_normal_y = 0.7
	wall_max_abs_normal_y = 0.2
	continuity_angle_degrees = 25.0
	continuity_distance_m = 0.2
	continuity_loss_steps = 2
	candidate_limit = 16
	report_limit = 8
	scan_limit = 32
