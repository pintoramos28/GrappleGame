class_name GroundProbe
extends PhysicsQueryProfile


func _init() -> void:
	profile_id = &"player.contact.ground_probe"
	probe_direction = Vector3.DOWN
	probe_distance_m = 0.3
	sweep_distance_cap_m = 0.35
	thickness_m = 0.08
	support_max_distance_m = 0.18
	ground_min_normal_y = 0.7
	wall_max_abs_normal_y = 0.2
	candidate_limit = 16
	report_limit = 8
	scan_limit = 32
