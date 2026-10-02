"""Pinned GUT evidence after the foreign-motor fixture correction.

Never overwrites old captures. Runs with no source/reload writes in parallel.
A baseline-parity comparison is not a green comprehensive regression gate.
"""
from pathlib import Path
import json
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
ENGINE = ROOT.parent / "Godot 4.7.2/Godot_v4.7.2-stable_win64_console.exe"
ANSI = re.compile(r"\x1b\[[0-9;]*m")


def text(path):
    raw = path.read_bytes()
    encoding = "utf-16" if raw.startswith((b"\xff\xfe", b"\xfe\xff")) else "utf-8-sig"
    return ANSI.sub("", raw.decode(encoding))


def result(stem):
    stdout = text(HERE / (stem + ".stdout.log"))
    stderr = text(HERE / (stem + ".stderr.log"))
    summary = stdout.split("= Run Summary", 1)[-1]
    suite, failures = "", []
    for line in summary.splitlines():
        if line.startswith("res://tests/") and line.endswith(".gd"):
            suite = line.strip()
        elif line.startswith("- test_") and suite:
            failures.append(suite + "::" + line[2:].strip())
    rows = [line for line in stdout.splitlines() if line.startswith("[reanchor-hardening] ")]
    ids = {(re.search(r'"case": "([^"]+)"', row).group(1),
            int(re.search(r'"rate": (\d+)', row).group(1))) for row in rows}
    counts = {}
    for key in ("Tests", "Passing Tests", "Failing Tests", "Asserts", "Time"):
        match = re.search(r"^" + key + r"\s+(.+)$", summary, re.M)
        if match:
            counts[key] = match.group(1).strip()
    return {"stem": stem, "counts": counts,
            "exit_code": int(text(HERE / (stem + ".exitcode.txt")).strip()),
            "failing_test_identities": sorted(set(failures)),
            "hardening_case_records": len(rows), "unique_hardening_cases": len(ids),
            "all_hardening_cases_pass": len(rows) == len(ids) == 100 and all('"passed": true' in row for row in rows),
            "foreign_controls_pass": all('"foreign_contiguous_commits": true' in row and '"foreign_completed_step_matches": true' in row for row in rows if '"case": "foreign_motor"' in row),
            "parse_load_compile_errors": re.findall(r"(?:SCRIPT ERROR|ERROR): (?:Parse Error|Compile Error|Failed to load script).*", stderr),
            "teardown_settled_60hz": bool(re.search(r"\[reanchor-hardening-teardown\] saved_rate=60 restored_rate=60 actual_delta_seconds=0\.01666", stdout))}


gates = [("parent-final-focused-gut", ["-gtest=res://tests/player/grapple/test_wall_stick_reanchor_hardening.gd"]),
         ("parent-final-player-gut", ["-gdir=res://tests/player", "-ginclude_subdirs"]),
         ("parent-final-gut", ["-gdir=res://tests", "-ginclude_subdirs"])]
for stem, selection in gates:
    command = ["rtk", "proxy", str(ENGINE), "--headless", "--path", ".", "-s", "res://addons/gut/gut_cmdln.gd", *selection, "-gexit"]
    with (HERE / (stem + ".stdout.log")).open("xb") as stdout, (HERE / (stem + ".stderr.log")).open("xb") as stderr:
        run = subprocess.run(command, cwd=ROOT, stdout=stdout, stderr=stderr)
    with (HERE / (stem + ".exitcode.txt")).open("x", encoding="utf-8") as output:
        output.write(str(run.returncode) + "\n")
    print(json.dumps({"command": command, "result": result(stem)}), flush=True)

baseline = result("baseline-gut")
focused, player, full = [result(stem) for stem, _ in gates]
checks = {
    "focused_13_groups_green": focused["exit_code"] == 0 and focused["counts"].get("Passing Tests") == focused["counts"].get("Tests") == "13",
    "player_same_six_baseline_failures": len(player["failing_test_identities"]) == 6 and player["failing_test_identities"] == [p for p in baseline["failing_test_identities"] if p.startswith("res://tests/player/")],
    "full_same_nine_baseline_failures": len(full["failing_test_identities"]) == 9 and full["failing_test_identities"] == baseline["failing_test_identities"],
    "comprehensive_gates_honestly_red": player["exit_code"] == full["exit_code"] == 1,
    "all_three_gates_100_passing_hardening_cases": all(r["all_hardening_cases_pass"] and r["foreign_controls_pass"] for r in (focused, player, full)),
    "no_fresh_parse_load_compile_errors": all(not r["parse_load_compile_errors"] for r in (focused, player, full)),
    "all_teardowns_settled_at_60hz": all(r["teardown_settled_60hz"] for r in (focused, player, full)),
}
report = {"all_checks_passed": all(checks.values()), "checks": checks,
          "canonical_regression_gate_green": False, "baseline": baseline,
          "focused": focused, "player": player, "full": full}
with (HERE / "parent-final-gut-comparison.json").open("x", encoding="utf-8") as output:
    json.dump(report, output, indent=2)
print(json.dumps(report, indent=2))
raise SystemExit(0 if all(checks.values()) else 1)
