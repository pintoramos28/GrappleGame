"""Read-only comparison of the fresh baseline and a supplied final GUT log."""
from pathlib import Path
import json
import re
import sys

HERE = Path(__file__).resolve().parent
ANSI = re.compile(r"\x1b\[[0-9;]*m")


def load_result(stem):
    path = HERE / (stem + ".stdout.log")
    raw = path.read_bytes()
    encoding = "utf-16" if raw.startswith((b"\xff\xfe", b"\xfe\xff")) else "utf-8-sig"
    text = ANSI.sub("", raw.decode(encoding))
    summary = text.split("= Run Summary", 1)[-1]
    suite = ""
    failures = []
    for line in summary.splitlines():
        if line.startswith("res://tests/") and line.endswith(".gd"):
            suite = line.strip()
        elif line.startswith("- test_") and suite:
            failures.append(suite + "::" + line[2:].strip())
    counts = {}
    for key in ("Tests", "Passing Tests", "Failing Tests", "Asserts", "Time"):
        match = re.search(r"^" + re.escape(key) + r"\s+(.+)$", summary, re.MULTILINE)
        if match:
            counts[key] = match.group(1).strip()
    exit_path = HERE / (stem + ".exitcode.txt")
    exit_raw = exit_path.read_bytes()
    exit_encoding = "utf-16" if exit_raw.startswith((b"\xff\xfe", b"\xfe\xff")) else "utf-8-sig"
    return {"log": path.name, "counts": counts, "exit_code": int(exit_raw.decode(exit_encoding).strip()), "failing_test_identities": sorted(set(failures))}


baseline = load_result("baseline-gut")
final = load_result(sys.argv[1] if len(sys.argv) > 1 else "final-gut")
checks = {
    "same_nine_baseline_failing_identities": len(baseline["failing_test_identities"]) == 9 and baseline["failing_test_identities"] == final["failing_test_identities"],
    "counts_present": all(key in baseline["counts"] and key in final["counts"] for key in ("Tests", "Passing Tests", "Failing Tests", "Asserts")),
    "no_failed_new_test": not any("test_wall_stick_reanchor.gd::" in identity or "test_grapple_active_visuals.gd::" in identity for identity in final["failing_test_identities"]),
    "honest_nonzero_exit": baseline["exit_code"] == 1 and final["exit_code"] == 1,
}
print(json.dumps({"all_checks_passed": all(checks.values()), "checks": checks, "baseline": baseline, "final": final}, indent=2))
raise SystemExit(0 if all(checks.values()) else 1)
