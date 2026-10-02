"""Read-only final evidence/preservation checks; red regression stays red."""
from pathlib import Path
import json
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
gut = json.loads((HERE / "parent-final-gut-comparison.json").read_text())
live = json.loads((HERE / "mcp-parent-final-validation.json").read_text())
readback = json.loads((HERE / "mcp-parent-final-readback.json").read_text())
mcp_ids = {(row["case"], row["rate"]) for row in live["hardening"]["cases"]}
gut_ids = []
for group in ("focused", "player", "full"):
    rows = (HERE / (gut[group]["stem"] + ".stdout.log")).read_text(encoding="utf-8-sig").splitlines()
    gut_ids.append({(re.search(r'"case": "([^"]+)"', row).group(1),
                    int(re.search(r'"rate": (\d+)', row).group(1)))
                   for row in rows if row.startswith("[reanchor-hardening] ")})
preservation_run = subprocess.run(["rtk", "proxy", "python", str(HERE / "verify-hardening-preservation.py")], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
preservation = json.loads(preservation_run.stdout)
whitespace = subprocess.run(["rtk", "git", "diff", "--check"], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
feature_failures = [identity for identity in gut["player"]["failing_test_identities"] + gut["full"]["failing_test_identities"] if any(path in identity for path in ("test_wall_stick_reanchor.gd::", "test_wall_stick_reanchor_hardening.gd::", "test_grapple_active_visuals.gd::"))]
foreign = [row for row in live["hardening"]["details"] if row["case"] == "foreign_motor"]
checks = {
    "hundred_identical_case_rate_ids_in_three_gut_gates_and_mcp": len(mcp_ids) == 100 and all(ids == mcp_ids for ids in gut_ids),
    "all_current_mcp_hardening_cases_pass": live["hardening"]["passed"] == live["hardening"]["total"] == 100 and all(row["passed"] for row in live["hardening"]["cases"]),
    "all_six_original_mcp_scenarios_pass": len(live["policies"]) == 6 and all(row["passed"] for row in live["policies"]),
    "both_foreign_matching_step_success_controls_pass": len(foreign) == 2 and all(row["passed"] and all(row["extra"].values()) for row in foreign),
    "no_failed_feature_or_hardening_test": not feature_failures,
    "fresh_game_log_without_errors_or_drops": live["logs"]["dropped_count"] == 0 and all(row["level"] == "info" for row in live["logs"]["lines"]),
    "no_new_editor_logger_entries": not live["editor_since_cursor_5"]["lines"],
    "inputs_released_and_60hz_restored": live["cleanup"]["result"]["physics_hz"] == 60 and not live["cleanup"]["result"]["right_mouse_pressed"] and not any(live["inputs"]["actions"].values()),
    "original_editor_scene_ready_stopped": live["state"]["readiness"] == "ready" and not live["state"]["is_playing"] and live["state"]["current_scene"] == readback["current_scene"],
    "all_preservation_checks_pass": preservation_run.returncode == 0 and preservation["all_checks_passed"],
    "whitespace_clean": whitespace.returncode == 0,
}
print(json.dumps({"targeted_evidence_and_preservation_all_pass": all(checks.values()),
                  "checks": checks, "gut_comparison_all_checks_passed": gut["all_checks_passed"],
                  "gut_comparison_failed_checks": [key for key, value in gut["checks"].items() if not value],
                  "canonical_regression_gate_green": False, "preservation": preservation,
                  "whitespace_exit_code": whitespace.returncode,
                  "mcp_session_id": live["session_id"], "mcp_run_id": live["logs"]["run_id"]}, indent=2))
# Keep the failed comprehensive comparison observable despite targeted success.
raise SystemExit(0 if all(checks.values()) and gut["all_checks_passed"] else 1)
