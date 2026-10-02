"""Read-only baseline identity comparison; run from the project root."""
import json
from pathlib import Path
import re

ROOT = Path("_bmad-output/implementation-artifacts/evidence/wall-stick-attachment")


def result(name):
    text = re.sub(r"\x1b\[[0-9;]*m", "", (ROOT / name).read_text(encoding="utf-8-sig"))
    summary = text.rsplit("= Run Summary", 1)[1]
    suite = ""
    failures = []
    for line in summary.splitlines():
        if line.startswith("res://tests/"):
            suite = line.strip()
        elif line.startswith("- test_"):
            failures.append(f"{suite}::{line[2:].strip()}")
    counts = {}
    for field in ["Tests", "Passing Tests", "Failing Tests", "Asserts", "Time"]:
        counts[field] = re.search(rf"^{field}\s+(\S+)", summary, re.MULTILINE)[1]
    return {"log": name, "counts": counts, "failing_test_identities": sorted(failures)}


baseline = result("baseline-gut.log")
previous = result("full-gut-complete.log")
full = result("review-hardening-full-verified.log")
old_focused = result("focused-gut-complete.log")
focused = result("review-hardening-focused-verified.log")
checks = {
    "same_nine_baseline_failures": baseline["failing_test_identities"] == previous["failing_test_identities"] == full["failing_test_identities"] and len(full["failing_test_identities"]) == 9,
    "same_two_focused_failures": old_focused["failing_test_identities"] == focused["failing_test_identities"] and len(focused["failing_test_identities"]) == 2,
    "five_added_tests_all_pass": int(full["counts"]["Tests"]) - int(previous["counts"]["Tests"]) == int(full["counts"]["Passing Tests"]) - int(previous["counts"]["Passing Tests"]) == 5,
}
print(json.dumps({"checks": checks, "all_checks_passed": all(checks.values()), "baseline": baseline, "previous_implementation": previous, "focused": focused, "full": full}, indent=2))
raise SystemExit(0 if all(checks.values()) else 1)
