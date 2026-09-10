from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


ARTIFACTS_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ARTIFACTS_DIR))

import resolve_artifacts as resolver  # noqa: E402


class ResolverUnitTests(unittest.TestCase):
    def test_requirement_normalization_and_epic_map(self) -> None:
        self.assertEqual(resolver.canonical_requirement_id("ux_dr-12"), "UX-DR12")
        self.assertEqual(resolver.canonical_requirement_id("nfr-7"), "NFR7")
        self.assertEqual(
            resolver.epic_fr_coverage("FR2: Epic 1 - Move.\nFR10: Epic 3 - Aim.\n"),
            {1: ["FR2"], 3: ["FR10"]},
        )

    def test_frontmatter_update_preserves_body(self) -> None:
        source = "---\nstatus: 'draft'\nold: true\n---\n\n# Body\n"
        result = resolver.update_frontmatter(
            source,
            {"status": "complete", "version": "1.0"},
            {"old"},
        )
        self.assertEqual(resolver.frontmatter_scalar(result, "status"), "complete")
        self.assertEqual(resolver.frontmatter_scalar(result, "version"), "1.0")
        self.assertIsNone(resolver.frontmatter_scalar(result, "old"))
        self.assertTrue(result.endswith("# Body\n"))

    def test_mirror_rewrites_links_and_detects_body_edits(self) -> None:
        with tempfile.TemporaryDirectory() as temp_name:
            root = Path(temp_name)
            contract = root / resolver.CONTRACT_PATH
            contract.parent.mkdir(parents=True)
            contract.write_text(
                """
schema_version = 1
final_statuses = ["complete"]

[artifacts.gdd]
artifact_id = "test.gdd"
canonical = "_bmad-output/planning-artifacts/gdd.md"
document_type = "gdd"
required = true
depends_on = []
compatibility_mirrors = ["_bmad-output/gdd-current.md"]
legacy_candidates = []
""".strip()
                + "\n",
                encoding="utf-8",
            )
            source_file = (
                root / "_bmad-output/planning-artifacts/sources/info.md"
            )
            source_file.parent.mkdir(parents=True)
            source_file.write_text("# Source\n", encoding="utf-8")
            canonical = root / "_bmad-output/planning-artifacts/gdd.md"
            canonical.write_text(
                """---
artifact_id: 'test.gdd'
document_type: 'gdd'
artifact_role: 'canonical'
status: 'complete'
---

# Test

[Source](sources/info.md)
""",
                encoding="utf-8",
            )

            [mirror] = resolver.make_mirror(root, "gdd")
            mirror_text = mirror.read_text(encoding="utf-8")
            self.assertIn(
                "(planning-artifacts/sources/info.md)",
                mirror_text,
            )
            record = resolver.metadata_record(
                root,
                "gdd",
                resolver.load_contract(root)["artifacts"]["gdd"],
            )
            self.assertTrue(record["mirrors"][0]["current"])

            mirror.write_text(mirror_text + "Edited outside publication.\n", encoding="utf-8")
            stale_record = resolver.metadata_record(
                root,
                "gdd",
                resolver.load_contract(root)["artifacts"]["gdd"],
            )
            self.assertFalse(stale_record["mirrors"][0]["current"])
            self.assertIn("compatibility mirror is stale", stale_record["errors"][0])

    def test_story_scoped_nonfinal_policy_is_fail_closed(self) -> None:
        with tempfile.TemporaryDirectory() as temp_name:
            root = Path(temp_name)
            gdd = root / "gdd.md"
            gdd.write_text(
                """---
status: 'needs-decisions'
implementation_scope_ready: 'M0 implementation-start only; no milestone is acceptance-ready'
---
""",
                encoding="utf-8",
            )
            consumer_spec = {
                "nonfinal_story_scopes": {
                    "gdd": {
                        "allowed_statuses": ["needs-decisions"],
                        "allowed_epics": [1],
                        "frontmatter_field": "implementation_scope_ready",
                        "allowed_values": [
                            "M0 implementation-start only; no milestone is acceptance-ready"
                        ],
                    }
                }
            }
            record = {
                "path": "gdd.md",
                "status": "needs-decisions",
            }

            self.assertTrue(
                resolver.story_scoped_nonfinal_allowed(
                    root, consumer_spec, "gdd", record, "1.1"
                )
            )
            self.assertFalse(
                resolver.story_scoped_nonfinal_allowed(
                    root, consumer_spec, "gdd", record, "2.1"
                )
            )
            self.assertFalse(
                resolver.story_scoped_nonfinal_allowed(
                    root, consumer_spec, "gdd", record, None
                )
            )

            record["status"] = "draft"
            self.assertFalse(
                resolver.story_scoped_nonfinal_allowed(
                    root, consumer_spec, "gdd", record, "1.1"
                )
            )
            record["status"] = "needs-decisions"
            gdd.write_text(
                "---\nstatus: 'needs-decisions'\n---\n",
                encoding="utf-8",
            )
            self.assertFalse(
                resolver.story_scoped_nonfinal_allowed(
                    root, consumer_spec, "gdd", record, "1.1"
                )
            )


if __name__ == "__main__":
    unittest.main()
