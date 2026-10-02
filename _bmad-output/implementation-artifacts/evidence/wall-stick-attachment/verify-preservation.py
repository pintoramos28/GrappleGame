"""Read-only, reproducible preservation checks; run from the project root."""
import hashlib
import json
from pathlib import Path
import re
import subprocess


def head_text(path):
    return subprocess.check_output(
        ["rtk", "proxy", "git", "show", f"HEAD:{path}"], encoding="utf-8"
    ).replace("\r\n", "\n")


def function_body(source, name):
    lines = source.splitlines()
    start = next(i for i, line in enumerate(lines)
                 if re.match(rf"^(?:static )?func {re.escape(name)}\(", line))
    end = start
    while not lines[end].endswith(":"):
        end += 1
    end += 1
    while end < len(lines) and (not lines[end] or lines[end][0].isspace()):
        end += 1
    return "\n".join(lines[start:end]).rstrip()


controller_path = "scripts/player_controller.gd"
before = head_text(controller_path)
after = Path(controller_path).read_text(encoding="utf-8")
checks = {}
for name in ["_can_start_wall_run", "_update_wall_run_state",
             "_update_wall_run_relationship", "_set_wall_run",
             "_get_wall_run_direction", "_has_wall_run_input_for_direction",
             "_has_outward_wall_speed", "_clear_wall_run", "submit_wall_jump",
             "has_valid_wall_jump_relationship", "_is_runnable_wall_frame"]:
    checks[f"controller.{name}.equals_head"] = (
        function_body(before, name) == function_body(after, name)
    )
for path in ["scripts/player_wall_run_state.gd", "scripts/player_airborne_state.gd"]:
    checks[f"{path}.equals_head"] = head_text(path) == Path(path).read_text(encoding="utf-8")
provider_path = "game/player/locomotion/contact/player_contact_provider.gd"
checks["legacy_wall_selection.equals_head"] = (
    function_body(head_text(provider_path), "select_wall_candidate")
    == function_body(Path(provider_path).read_text(encoding="utf-8"), "select_wall_candidate")
)
route_path = "game/levels/content/traversal_validation/traversal_validation_route.tscn"
checks["route.equals_head_except_stick_guide"] = (
    Path(route_path).read_text(encoding="utf-8").replace(
        "HOLD FORWARD + GRAPPLE NEAR WALL  /  stick", "HOLD GRAPPLE NEAR WALL  /  stick"
    ) == head_text(route_path)
)
scene = Path("scenes/player.tscn").read_text(encoding="utf-8")
for field, value in {"max_air_speed": "2.0", "air_acceleration": "2.0",
                     "ground_deceleration": "50.0", "air_deceleration": "5.0",
                     "wall_run_max_entry_speed": "100.0",
                     "wall_run_min_horizontal_speed": "3.0",
                     "wall_run_acceleration": "4.0", "wall_run_gravity_scale": "0.0",
                     "wall_check_distance": "0.2", "grapple_gravity_scale": "0.0"}.items():
    checks[f"recorded_scene_value.{field}"] = f"\n{field} = {value}\n" in scene
checks["recorded_grapple_acceleration_60"] = "pull_initial_acceleration_mps2 = 60.0" in Path(
    "game/player/abilities/grapple/definitions/grapple_definition.tres"
).read_text(encoding="utf-8")
spec = Path("_bmad-output/implementation-artifacts/spec-wall-stick-attachment.md").read_text(encoding="utf-8")
frozen = spec[spec.index("<frozen-after-approval"):spec.index("</frozen-after-approval>") + len("</frozen-after-approval>")]
approval_hash = hashlib.sha256(frozen.encode("utf-8")).hexdigest()
checks["approval_hash_matches"] = approval_hash == "a5f7213f35fd07e64e5582ba99b73139432ecc5e51a55f54d9e9bea1c6324c27"
print(json.dumps({"checks": checks, "all_checks_passed": all(checks.values()),
                  "frozen_approval_sha256": approval_hash}, indent=2))
raise SystemExit(0 if all(checks.values()) else 1)
