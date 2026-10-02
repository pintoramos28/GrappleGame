"""Read-only checks against both approved snapshots; never capture/replace them.

Run from the project root through rtk proxy python. The three documentation
prefixes are append-only; old logs, images and recorded captures stay exact.
"""
from pathlib import Path
import base64
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[4]
TEMP = Path(r"C:/Users/pinto/AppData/Local/Temp/opencode")
SNAPSHOT = TEMP / "wall-stick-reanchor-baseline.json"
START = TEMP / "wall-stick-reanchor-hardening-start-hashes.json"
HEAD = "89ead0989f319a80007cb9835fea056c5ca8bf04"
FROZEN = "14e2d5fa5986b4f9dbebacd48b0e20c444724e582d8d3cc871f48d426a58504f"
SNAPSHOT_HASH = "675b800999be156f9f34b25a4749ad6ab981a5823d35782385f72872c5cfa14b"
ARTIFACTS = "_bmad-output/implementation-artifacts/"
EVIDENCE = ARTIFACTS + "evidence/wall-stick-grapple-reanchor/"
APPEND_ONLY = {
    EVIDENCE + "README.md": 14343,
    EVIDENCE + "review-triage.md": 4087,
    ARTIFACTS + "spec-wall-stick-grapple-reanchor.md": 14932,
}
LOCALIZED_EDITS = {
    "game/player/abilities/grapple/grapple_surface_binding.gd",
    "game/player/abilities/grapple/grapple_attachment.gd",
    "game/player/abilities/grapple/grapple_controller.gd",
    "game/player/locomotion/wall_stick/wall_stick_attachment.gd",
    "game/player/motor/player_motor.gd",
    "game/shared/contracts/grappleable_3d.gd",
    "tests/fixtures/wall_stick_motion_fixture.gd",
    "tests/fixtures/wall_stick_reanchor_fixture.gd",
    "tests/fixtures/wall_stick_review_cases.gd",
    "tests/player/grapple/test_wall_stick_reanchor.gd",
}


def sha(payload):
    return hashlib.sha256(payload).hexdigest()


def run(*args):
    return subprocess.run(["rtk", "proxy", *args], cwd=ROOT,
                          capture_output=True, text=True, encoding="utf-8")


baseline = json.loads(SNAPSHOT.read_text(encoding="utf-8"))
start = json.loads(START.read_text(encoding="utf-8"))
before = {p: base64.b64decode(value) for p, value in baseline["files"].items()}
missing = sorted(p for p in before if not (ROOT / p).is_file())
prior = [p for p in before if p.startswith(ARTIFACTS + "evidence/") or
         (p.startswith(ARTIFACTS + "spec-") and
          p != ARTIFACTS + "spec-wall-stick-grapple-reanchor.md")]
protected = [p for p in before if p == "project.godot" or
             (p.startswith(("game/", "scenes/", "resources/", "tests/")) and
              p.endswith((".tres", ".tscn")))]
prior_mismatches = sorted(p for p in prior if not (ROOT / p).is_file() or
                          (ROOT / p).read_bytes() != before[p])
protected_mismatches = sorted(p for p in protected if not (ROOT / p).is_file() or
                              (ROOT / p).read_bytes() != before[p])
changed = []
unexpected = []
for p, digest in start["sha256"].items():
    path = ROOT / p
    if not path.is_file():
        unexpected.append(p + " (missing)")
        continue
    payload = path.read_bytes()
    if p in APPEND_ONLY:
        if sha(payload[:APPEND_ONLY[p]]) != digest:
            unexpected.append(p + " (original prefix changed)")
    elif sha(payload) != digest:
        changed.append(p)
        if p not in LOCALIZED_EDITS:
            unexpected.append(p)
spec = (ROOT / (ARTIFACTS + "spec-wall-stick-grapple-reanchor.md")).read_text(encoding="utf-8")
frozen = spec[spec.index("<frozen-after-approval"):spec.index("</frozen-after-approval>") + len("</frozen-after-approval>")]
head = run("git", "rev-parse", "HEAD")
old = run("python", ARTIFACTS + "evidence/wall-stick-attachment/verify-preservation.py")
old_result = json.loads(old.stdout)
checks = {
    "immutable_437_file_snapshot_hash": sha(SNAPSHOT.read_bytes()) == SNAPSHOT_HASH,
    "head_unchanged": head.returncode == 0 and head.stdout.strip() == HEAD == baseline["head"] == start["head"],
    "frozen_intent_unchanged": sha(frozen.encode()) == FROZEN == baseline["approval_sha256"],
    "spec_remains_in_review": "\nstatus: 'in-review'\n" in spec,
    "all_437_snapshot_files_retained": len(before) == 437 and not missing,
    "all_prior_evidence_and_specs_byte_identical": not prior_mismatches,
    "all_protected_scene_resource_project_bytes_identical": not protected_mismatches,
    "hardening_start_preserved_outside_localized_edits_and_append_only_docs": not unexpected,
    "existing_27_check_preservation_gate": old.returncode == 0 and old_result["all_checks_passed"] and len(old_result["checks"]) == 27,
}
print(json.dumps({
    "checks": checks, "all_checks_passed": all(checks.values()),
    "snapshot_path": str(SNAPSHOT), "snapshot_files_checked": len(before),
    "baseline_snapshot_sha256": sha(SNAPSHOT.read_bytes()),
    "hardening_start_sha256": sha(START.read_bytes()),
    "current_head": head.stdout.strip(), "frozen_approval_sha256": sha(frozen.encode()),
    "hardening_start_files_checked": len(start["sha256"]),
    "all_prior_evidence_and_spec_files_checked": len(prior),
    "all_protected_scene_resource_project_files_checked": len(protected),
    "old_gate": old_result, "localized_existing_source_changes": sorted(changed),
    "append_only_prefix_bytes": APPEND_ONLY, "missing_snapshot_files": missing,
    "prior_mismatches": prior_mismatches, "protected_mismatches": protected_mismatches,
    "unexpected_hardening_changes": unexpected,
}, indent=2))
raise SystemExit(0 if all(checks.values()) else 1)
