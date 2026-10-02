"""Read-only identity/case comparison; a passing comparator is NOT a green GUT run."""
from pathlib import Path
import json
import re

HERE = Path(__file__).resolve().parent
ANSI = re.compile(r"\x1b\[[0-9;]*m")


def text(path):
    raw = path.read_bytes()
    encoding = "utf-16" if raw.startswith((b"\xff\xfe", b"\xfe\xff")) else "utf-8-sig"
    return ANSI.sub("", raw.decode(encoding))


def gut(stem):
    stdout = text(HERE / (stem + ".stdout.log"))
    stderr = text(HERE / (stem + ".stderr.log"))
    summary = stdout.split("= Run Summary", 1)[-1]
    suite = ""
    failures = []
    for line in summary.splitlines():
        if line.startswith("res://tests/") and line.endswith(".gd"):
            suite = line.strip()
        elif line.startswith("- test_") and suite:
            failures.append(suite + "::" + line[2:].strip())
    rows = [line for line in stdout.splitlines() if line.startswith("[reanchor-hardening] ")]
    cases = [(re.search(r'"case": "([^"]+)"', line).group(1),
              int(re.search(r'"rate": (\d+)', line).group(1))) for line in rows]
    return {
        "stem": stem,
        "counts": {key: re.search(r"^" + re.escape(key) + r"\s+(.+)$", summary, re.M).group(1).strip()
                   for key in ("Tests", "Passing Tests", "Failing Tests", "Asserts", "Time")},
        "exit_code": int(text(HERE / (stem + ".exitcode.txt")).strip()),
        "failing_test_identities": sorted(set(failures)),
        "hardening_case_records": len(rows), "hardening_unique_case_rates": len(set(cases)),
        "all_hardening_case_records_pass": bool(rows) and all('"passed": true' in line for line in rows),
        "parse_load_compile_diagnostics": re.findall(r"(?:SCRIPT ERROR|ERROR): (?:Parse Error|Compile Error|Failed to load script).*", stderr),
        "teardown_60hz_observed": bool(re.search(r"\[reanchor-hardening-teardown\] saved_rate=60 restored_rate=60 actual_delta_seconds=0\.01666", stdout)),
    }, set(cases), stdout


baseline, _, _ = gut("baseline-gut")
full, full_cases, full_text = gut("hardening-gut-settled")
player, player_cases, _ = gut("hardening-player-gut-settled")
live = json.loads((HERE / "mcp-hardening-final-live-cases.json").read_text())
existing = json.loads((HERE / "mcp-hardening-final-existing-live.json").read_text())
entry = json.loads((HERE / "mcp-hardening-native-entry.json").read_text())
closeout = json.loads((HERE / "mcp-hardening-closeout.json").read_text())
live_cases = {(row["case"], row["rate"]) for row in live["cases"]}
groups = re.findall(r"^func (test_[^(]+)\(", (HERE.parents[3] / "tests/player/grapple/test_wall_stick_reanchor_hardening.gd").read_text(), re.M)
new_test_paths = ("test_wall_stick_reanchor.gd::", "test_grapple_active_visuals.gd::", "test_wall_stick_reanchor_hardening.gd::")
checks = {
    "full_same_nine_baseline_failing_identities": len(baseline["failing_test_identities"]) == 9 and full["failing_test_identities"] == baseline["failing_test_identities"],
    "player_same_six_baseline_failing_identities": len(player["failing_test_identities"]) == 6 and player["failing_test_identities"] == [p for p in baseline["failing_test_identities"] if p.startswith("res://tests/player/")],
    "both_gut_gates_honestly_red": full["exit_code"] == player["exit_code"] == 1,
    "no_failed_feature_or_hardening_test": not any(any(path in failure for path in new_test_paths) for failure in full["failing_test_identities"] + player["failing_test_identities"]),
    "all_13_hardening_groups_executed": len(groups) == 13 and all("* " + name in full_text for name in groups),
    "both_gut_runs_100_passing_unique_hardening_cases": all(result["hardening_case_records"] == result["hardening_unique_case_rates"] == 100 and result["all_hardening_case_records_pass"] for result in (full, player)),
    "no_final_gut_parse_load_compile_errors": not full["parse_load_compile_diagnostics"] and not player["parse_load_compile_diagnostics"],
    "both_gut_teardowns_settled_at_60hz": full["teardown_60hz_observed"] and player["teardown_60hz_observed"],
    "mcp_100_current_hardening_cases_pass": len(live["cases"]) == len(live_cases) == 100 and all(row["passed"] for row in live["cases"]),
    "same_hardening_case_ids_exercised_in_both_gates": full_cases == player_cases == live_cases,
    "mcp_six_original_policy_rate_cases_pass": len(existing["cases"]) == 6 and all(row["passed"] for row in existing["cases"]),
    "mcp_ten_native_entry_cases_pass": len(entry["cases"]) == 10 and all(row["passed"] for row in entry["cases"]),
    "fresh_mcp_native_closeout_six_pass": len(closeout["native_cases"]) == 6 and all(row["passed"] for row in closeout["native_cases"]),
    "final_mcp_game_and_editor_logs_clean": closeout["logs"]["dropped_count"] == 0 and all(row["level"] == "info" for row in closeout["logs"]["lines"]) and not closeout["editor_since_cursor_5"]["lines"],
    "final_mcp_inputs_released_rate_60": closeout["physics_rate_restored"] == 60 and not closeout["right_mouse_pressed_after_cleanup"] and not any(closeout["inputs"]["actions"].values()),
    "final_editor_ready_original_scene": closeout["final_state"]["readiness"] == "ready" and not closeout["final_state"]["is_playing"] and closeout["final_state"]["current_scene"] == "res://game/levels/content/traversal_validation/traversal_validation_route.tscn",
}
print(json.dumps({"checks": checks, "all_checks_passed": all(checks.values()),
                  "canonical_regression_gate_green": False, "full_gut": full, "player_gut": player,
                  "mcp_session_id": live["session_id"], "mcp_hardening_run_id": live["run_id"],
                  "mcp_closeout_run_id": closeout["run_id"], "hardening_test_groups": groups}, indent=2))
raise SystemExit(0 if all(checks.values()) else 1)
