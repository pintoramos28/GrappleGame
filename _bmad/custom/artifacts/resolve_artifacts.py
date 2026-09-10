#!/usr/bin/env python3
"""Resolve, validate, publish, and shard GrappleGame's canonical artifacts.

This script is standard-library-only so workflow hooks can run it through uv
without downloading dependencies.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import sys
import tempfile
import tomllib
from urllib.parse import unquote, urlparse
from datetime import datetime
from pathlib import Path
from typing import Any


SCRIPT_PATH = Path(__file__).resolve()
DEFAULT_ROOT = SCRIPT_PATH.parents[3]
CONTRACT_PATH = Path("_bmad/custom/artifacts/artifact-contract.toml")
FRONTMATTER_BOUNDARY = "---"
REQUIREMENT_RE = re.compile(r"\b(?:UX-DR|NFR|FR|AR)[-_]?\d+\b", re.IGNORECASE)
MARKDOWN_LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")


def project_root(value: str | None) -> Path:
    return Path(value).resolve() if value else DEFAULT_ROOT


def load_contract(root: Path) -> dict[str, Any]:
    with (root / CONTRACT_PATH).open("rb") as handle:
        return tomllib.load(handle)


def canonical_requirement_id(value: str) -> str:
    value = value.upper().replace("_", "-")
    ux_match = re.fullmatch(r"UX-DR-?(\d+)", value)
    if ux_match:
        return f"UX-DR{ux_match.group(1)}"
    return value.replace("-", "")


def requirement_sort_key(item: str) -> tuple[str, int]:
    number = re.search(r"\d+$", item)
    return re.sub(r"\d+$", "", item), int(number.group(0)) if number else 0


def epic_fr_coverage(text: str) -> dict[int, list[str]]:
    """Extract the explicit `FRn: Epic m` primary-coverage map."""
    coverage: dict[int, list[str]] = {}
    for requirement, epic in re.findall(
        r"(?mi)^(FR\d+)\s*:\s*Epic\s+(\d+)\b", text
    ):
        coverage.setdefault(int(epic), []).append(
            canonical_requirement_id(requirement)
        )
    return {
        epic: sorted(set(requirements), key=requirement_sort_key)
        for epic, requirements in coverage.items()
    }


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def word_count_text(text: str) -> int:
    return len(re.findall(r"\S+", text))


def frontmatter_parts(text: str) -> tuple[list[str], str]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != FRONTMATTER_BOUNDARY:
        return [], text
    for index in range(1, len(lines)):
        if lines[index].strip() == FRONTMATTER_BOUNDARY:
            return lines[1:index], "\n".join(lines[index + 1 :]).lstrip("\n")
    return [], text


def frontmatter_scalar(text: str, key: str) -> str | None:
    lines, _ = frontmatter_parts(text)
    pattern = re.compile(rf"^{re.escape(key)}\s*:\s*(.*?)\s*$")
    for line in lines:
        if line[:1].isspace():
            continue
        match = pattern.match(line)
        if not match:
            continue
        value = match.group(1).strip()
        if value.lower() in {"null", "~", ""}:
            return None
        if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
            value = value[1:-1]
        return value
    return None


def yaml_scalar(value: str | int | bool) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


def update_frontmatter(
    text: str,
    updates: dict[str, str | int | bool],
    remove: set[str] | None = None,
) -> str:
    remove = remove or set()
    lines, body = frontmatter_parts(text)
    retained: list[str] = []
    replaced: set[str] = set()
    top_level_re = re.compile(r"^([A-Za-z_][A-Za-z0-9_-]*)\s*:")
    for line in lines:
        match = top_level_re.match(line) if not line[:1].isspace() else None
        key = match.group(1) if match else None
        if key in remove:
            continue
        if key in updates:
            retained.append(f"{key}: {yaml_scalar(updates[key])}")
            replaced.add(key)
            continue
        retained.append(line)
    for key, value in updates.items():
        if key not in replaced:
            retained.append(f"{key}: {yaml_scalar(value)}")
    frontmatter = "\n".join([FRONTMATTER_BOUNDARY, *retained, FRONTMATTER_BOUNDARY])
    return f"{frontmatter}\n\n{body.rstrip()}\n"


def write_text_atomic(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as handle:
            handle.write(text)
        os.replace(temp_name, path)
    except Exception:
        Path(temp_name).unlink(missing_ok=True)
        raise


def timestamp() -> str:
    return datetime.now().strftime("%Y-%m-%d-%H%M%S")


def archive_file(root: Path, path: Path, label: str) -> Path | None:
    if not path.exists():
        return None
    archive_dir = root / "_bmad-output/archive"
    archive_dir.mkdir(parents=True, exist_ok=True)
    destination = archive_dir / f"{label}-{timestamp()}{path.suffix}"
    counter = 1
    while destination.exists():
        destination = archive_dir / f"{label}-{timestamp()}-{counter}{path.suffix}"
        counter += 1
    shutil.move(str(path), str(destination))
    return destination


def relative(root: Path, path: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def local_markdown_link_errors(root: Path, path: Path, text: str) -> list[str]:
    errors: list[str] = []
    for raw_target in MARKDOWN_LINK_RE.findall(text):
        target = raw_target.strip()
        if target.startswith("<") and target.endswith(">"):
            target = target[1:-1]
        target = target.split("#", 1)[0].strip()
        if not target or urlparse(target).scheme:
            continue
        decoded = unquote(target)
        candidate = (path.parent / decoded).resolve()
        try:
            candidate.relative_to(root.resolve())
        except ValueError:
            errors.append(f"local Markdown link escapes project root: {target}")
            continue
        if not candidate.exists():
            errors.append(f"broken local Markdown link: {target}")
    return sorted(set(errors))


def metadata_record(root: Path, name: str, spec: dict[str, Any]) -> dict[str, Any]:
    path = root / spec["canonical"]
    record: dict[str, Any] = {
        "name": name,
        "artifact_id": spec["artifact_id"],
        "path": spec["canonical"],
        "required": bool(spec.get("required", False)),
        "exists": path.is_file(),
        "errors": [],
        "warnings": [],
    }
    if not path.is_file():
        if record["required"]:
            record["errors"].append("required canonical artifact is missing")
        return record

    text = path.read_text(encoding="utf-8")
    record.update(
        {
            "document_type": frontmatter_scalar(text, "document_type"),
            "status": frontmatter_scalar(text, "status"),
            "version": frontmatter_scalar(text, "version"),
            "updated": frontmatter_scalar(text, "updated"),
            "sha256": sha256(path),
            "bytes": path.stat().st_size,
            "words": word_count_text(text),
        }
    )
    expected_type = spec["document_type"]
    if record["document_type"] != expected_type:
        record["errors"].append(
            f"document_type is {record['document_type']!r}; expected {expected_type!r}"
        )
    record["errors"].extend(local_markdown_link_errors(root, path, text))

    for mirror_name in spec.get("compatibility_mirrors", []):
        mirror = root / mirror_name
        mirror_record: dict[str, Any] = {"path": mirror_name, "exists": mirror.is_file()}
        if mirror.is_file():
            mirror_text = mirror.read_text(encoding="utf-8")
            recorded_digest = frontmatter_scalar(mirror_text, "canonical_sha256")
            recorded_body_digest = frontmatter_scalar(
                mirror_text, "mirror_body_sha256"
            )
            _, mirror_body = frontmatter_parts(mirror_text)
            mirror_record["canonical_sha256"] = recorded_digest
            mirror_record["mirror_body_sha256"] = recorded_body_digest
            mirror_link_errors = local_markdown_link_errors(
                root, mirror, mirror_text
            )
            mirror_record["link_errors"] = mirror_link_errors
            mirror_record["current"] = (
                recorded_digest == record["sha256"]
                and recorded_body_digest == sha256_text(mirror_body)
                and frontmatter_scalar(mirror_text, "canonical_path")
                == spec["canonical"]
                and frontmatter_scalar(mirror_text, "artifact_role")
                == "compatibility-mirror"
                and not mirror_link_errors
            )
            if not mirror_record["current"]:
                record["errors"].append(f"compatibility mirror is stale: {mirror_name}")
        else:
            record["warnings"].append(f"compatibility mirror is absent: {mirror_name}")
        record.setdefault("mirrors", []).append(mirror_record)

    for legacy_name in spec.get("legacy_candidates", []):
        if (root / legacy_name).exists():
            record["errors"].append(f"unretired legacy candidate exists: {legacy_name}")

    if "manifest" in spec:
        manifest = root / spec["manifest"]
        record["manifest"] = {
            "path": spec["manifest"],
            "exists": manifest.is_file(),
            "sha256": sha256(manifest) if manifest.is_file() else None,
        }
        if not manifest.is_file():
            record["errors"].append("epic manifest is missing")
    return record


def dependency_errors(contract: dict[str, Any]) -> list[str]:
    artifacts = contract["artifacts"]
    errors: list[str] = []
    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(name: str, chain: list[str]) -> None:
        if name in visiting:
            errors.append("authority cycle: " + " -> ".join([*chain, name]))
            return
        if name in visited:
            return
        visiting.add(name)
        for dependency in artifacts[name].get("depends_on", []):
            if dependency not in artifacts:
                errors.append(f"{name} depends on unknown artifact {dependency}")
                continue
            visit(dependency, [*chain, name])
        visiting.remove(name)
        visited.add(name)

    for artifact_name in artifacts:
        visit(artifact_name, [])
    return errors


def find_duplicate_contexts(root: Path, canonical: Path) -> list[str]:
    duplicates: list[str] = []
    for path in root.rglob("project-context.md"):
        if ".git" in path.parts or path.resolve() == canonical.resolve():
            continue
        duplicates.append(relative(root, path))
    return sorted(duplicates)


def story_scoped_nonfinal_allowed(
    root: Path,
    consumer_spec: dict[str, Any],
    artifact_name: str,
    record: dict[str, Any],
    story_id: str | None,
) -> bool:
    """Allow a nonfinal artifact only for an explicitly scoped Story context."""
    if not story_id:
        return False
    match = re.fullmatch(r"(\d+)[.-](\d+)", story_id)
    if not match:
        return False
    policy = (
        consumer_spec.get("nonfinal_story_scopes", {}).get(artifact_name)
    )
    if not isinstance(policy, dict):
        return False
    if record.get("status") not in set(policy.get("allowed_statuses", [])):
        return False
    if int(match.group(1)) not in set(policy.get("allowed_epics", [])):
        return False
    field = policy.get("frontmatter_field")
    allowed_values = set(policy.get("allowed_values", []))
    if not isinstance(field, str) or not field or not allowed_values:
        return False
    artifact_path = root / record["path"]
    if not artifact_path.is_file():
        return False
    actual_value = frontmatter_scalar(
        artifact_path.read_text(encoding="utf-8"), field
    )
    return actual_value in allowed_values


def build_inventory(
    root: Path,
    consumer: str | None = None,
    story_id: str | None = None,
) -> dict[str, Any]:
    contract = load_contract(root)
    consumer_spec: dict[str, Any] = {}
    if consumer:
        consumer_spec = contract.get("consumers", {}).get(consumer)
        if consumer_spec is None:
            raise ValueError(f"unknown consumer: {consumer}")
        selected_names = list(
            dict.fromkeys(
                consumer_spec.get("required", []) + consumer_spec.get("optional", [])
            )
        )
    else:
        selected_names = list(contract["artifacts"].keys())

    records = {
        name: metadata_record(root, name, contract["artifacts"][name])
        for name in selected_names
    }
    final_statuses = set(contract.get("final_statuses", []))
    allow_nonfinal = set(consumer_spec.get("allow_nonfinal", []))
    for name, record in records.items():
        status = record.get("status")
        if record["exists"] and status not in final_statuses:
            message = (
                f"status is {status!r}; expected one of "
                + ", ".join(sorted(final_statuses))
            )
            if story_scoped_nonfinal_allowed(
                root, consumer_spec, name, record, story_id
            ):
                record["warnings"].append(
                    message + f"; permitted for scoped story {story_id}"
                )
            elif name in allow_nonfinal:
                record["warnings"].append(message)
            else:
                record["errors"].append(message)
    errors = dependency_errors(contract)
    context_spec = contract["artifacts"]["project_context"]
    duplicate_contexts = find_duplicate_contexts(
        root, root / context_spec["canonical"]
    )
    if duplicate_contexts:
        errors.append(
            "multiple project-context.md files: " + ", ".join(duplicate_contexts)
        )
    for record in records.values():
        errors.extend(
            f"{record['name']}: {message}" for message in record["errors"]
        )
    return {
        "schema_version": contract["schema_version"],
        "project_name": contract["project_name"],
        "consumer": consumer or "all",
        "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "artifacts": records,
        "errors": errors,
        "valid": not errors,
    }


def write_inventory(root: Path, inventory: dict[str, Any]) -> tuple[Path, Path]:
    output_dir = root / load_contract(root)["inventory_dir"]
    output_dir.mkdir(parents=True, exist_ok=True)
    safe_consumer = re.sub(
        r"[^a-z0-9-]+", "-", inventory["consumer"].lower()
    ).strip("-")
    json_path = output_dir / f"{safe_consumer}.json"
    md_path = output_dir / f"{safe_consumer}.md"
    write_text_atomic(
        json_path, json.dumps(inventory, indent=2, sort_keys=True) + "\n"
    )
    lines = [
        f"# Artifact Inventory: {inventory['consumer']}",
        "",
        f"Generated: {inventory['generated_at']}",
        "",
        "| Artifact | Status | Canonical path | SHA-256 |",
        "|---|---|---|---|",
    ]
    for name, record in inventory["artifacts"].items():
        status = record.get("status") or (
            "missing" if not record["exists"] else "unknown"
        )
        digest = record.get("sha256", "")
        lines.append(f"| {name} | {status} | {record['path']} | {digest} |")
    lines.extend(["", f"**Valid:** {str(inventory['valid']).lower()}"])
    if inventory["errors"]:
        lines.extend(["", "## Errors", ""])
        lines.extend(f"- {error}" for error in inventory["errors"])
    write_text_atomic(md_path, "\n".join(lines) + "\n")
    return json_path, md_path


def make_mirror(root: Path, artifact_name: str) -> list[Path]:
    contract = load_contract(root)
    spec = contract["artifacts"].get(artifact_name)
    if spec is None:
        raise ValueError(f"unknown artifact: {artifact_name}")
    canonical = root / spec["canonical"]
    if not canonical.is_file():
        raise FileNotFoundError(f"canonical artifact missing: {spec['canonical']}")
    canonical_text = canonical.read_text(encoding="utf-8")
    digest = sha256(canonical)
    outputs: list[Path] = []
    for mirror_name in spec.get("compatibility_mirrors", []):
        mirror = root / mirror_name
        mirror_text = update_frontmatter(
            canonical_text,
            {
                "document_type": f"{spec['document_type']}-compatibility-mirror",
                "artifact_role": "compatibility-mirror",
                "canonical_path": spec["canonical"],
                "canonical_sha256": digest,
            },
        )
        frontmatter, body = frontmatter_parts(mirror_text)
        if artifact_name == "gdd":
            for old, new in [
                ("(sources/", "(planning-artifacts/sources/"),
                ("(decision-log.md", "(planning-artifacts/decision-log.md"),
                ("(architecture.md", "(planning-artifacts/architecture.md"),
                ("(epics/", "(planning-artifacts/epics/"),
            ]:
                body = body.replace(old, new)
            mirror_text = "\n".join(
                [FRONTMATTER_BOUNDARY, *frontmatter, FRONTMATTER_BOUNDARY]
            ) + "\n\n" + body.rstrip() + "\n"
        _, mirror_body = frontmatter_parts(mirror_text)
        mirror_text = update_frontmatter(
            mirror_text,
            {"mirror_body_sha256": sha256_text(mirror_body)},
        )
        write_text_atomic(mirror, mirror_text)
        outputs.append(mirror)
    return outputs


def publish_artifact(root: Path, artifact_name: str, source_name: str) -> Path:
    contract = load_contract(root)
    spec = contract["artifacts"].get(artifact_name)
    if spec is None:
        raise ValueError(f"unknown artifact: {artifact_name}")
    source = (root / source_name).resolve()
    if not source.is_file():
        raise FileNotFoundError(f"publish source missing: {source_name}")
    destination = root / spec["canonical"]
    source_text = source.read_text(encoding="utf-8")
    source_link_errors = local_markdown_link_errors(root, source, source_text)
    if source_link_errors:
        raise ValueError(
            "publish source has invalid local links: "
            + "; ".join(source_link_errors)
        )
    mirror_names = {
        (root / name).resolve()
        for name in spec.get("compatibility_mirrors", [])
    }
    if source in mirror_names and destination.is_file():
        recorded_canonical = frontmatter_scalar(
            source_text, "canonical_sha256"
        )
        recorded_body = frontmatter_scalar(
            source_text, "mirror_body_sha256"
        )
        _, source_body = frontmatter_parts(source_text)
        canonical_changed = recorded_canonical != sha256(destination)
        mirror_changed = recorded_body != sha256_text(source_body)
        if canonical_changed and mirror_changed:
            raise ValueError(
                "canonical artifact and compatibility mirror both changed; "
                "reconcile explicitly before publication"
            )
        if canonical_changed:
            raise ValueError(
                "compatibility mirror is stale relative to canonical artifact"
            )
    source_status = frontmatter_scalar(source_text, "status")
    final_statuses = set(contract.get("final_statuses", []))
    if source_status not in final_statuses:
        raise ValueError(
            f"publish source status is {source_status!r}; expected one of "
            + ", ".join(sorted(final_statuses))
        )
    canonical_text = update_frontmatter(
        source_text,
        {
            "artifact_schema": contract["schema_version"],
            "artifact_id": spec["artifact_id"],
            "document_type": spec["document_type"],
            "artifact_role": "canonical",
            "path_base": "project-root",
            "status": source_status,
            "updated": datetime.now().date().isoformat(),
        },
        {"canonical_path", "canonical_sha256", "mirror_body_sha256"},
    )
    canonical_link_errors = local_markdown_link_errors(
        root, destination, canonical_text
    )
    if canonical_link_errors:
        raise ValueError(
            "published canonical location would have invalid local links: "
            + "; ".join(canonical_link_errors)
        )
    expected_digest = hashlib.sha256(canonical_text.encode("utf-8")).hexdigest()
    if destination.exists() and sha256(destination) != expected_digest:
        archive_file(root, destination, f"superseded-{artifact_name}")
    write_text_atomic(destination, canonical_text)
    make_mirror(root, artifact_name)
    return destination


def extract_requirements(text: str) -> list[str]:
    return sorted(
        {
            canonical_requirement_id(match.group(0))
            for match in REQUIREMENT_RE.finditer(text)
        },
        key=requirement_sort_key,
    )


def shard_frontmatter(
    document_type: str, artifact_id: str, source_digest: str, **extra: Any
) -> str:
    values: dict[str, Any] = {
        "artifact_schema": 1,
        "artifact_id": artifact_id,
        "document_type": document_type,
        "status": "complete",
        "path_base": "project-root",
        "updated": datetime.now().date().isoformat(),
        "source_sha256": source_digest,
    }
    values.update(extra)
    lines = [FRONTMATTER_BOUNDARY]
    for key, value in values.items():
        lines.append(f"{key}: {yaml_scalar(value)}")
    lines.append(FRONTMATTER_BOUNDARY)
    return "\n".join(lines) + "\n\n"


def validate_generated_package(
    package: Path, manifest: dict[str, Any], max_words: int
) -> list[str]:
    errors: list[str] = []
    for entry in manifest["files"]:
        path = package / entry["path"]
        if not path.is_file():
            errors.append(f"missing generated shard: {entry['path']}")
            continue
        if sha256(path) != entry["sha256"]:
            errors.append(f"digest mismatch after write: {entry['path']}")
        if entry["words"] > max_words:
            errors.append(
                f"word ceiling exceeded ({entry['words']} > {max_words}): "
                f"{entry['path']}"
            )
    return errors


def shard_epics(root: Path, source_name: str) -> Path:
    contract = load_contract(root)
    source = root / source_name
    if not source.is_file():
        raise FileNotFoundError(f"epics monolith missing: {source_name}")
    text = source.read_text(encoding="utf-8")
    source_digest = sha256(source)
    epic_matches = list(re.finditer(r"(?m)^## Epic (\d+):\s*(.+?)\s*$", text))
    if not epic_matches:
        raise ValueError("no Epic N sections found in epics monolith")

    requirements_start = text.find("## Requirements Inventory")
    epic_list_start = text.find("## Epic List")
    if (
        requirements_start < 0
        or epic_list_start < 0
        or epic_list_start <= requirements_start
    ):
        raise ValueError(
            "epics monolith lacks a bounded Requirements Inventory / Epic List preamble"
        )
    requirements_body = text[requirements_start:epic_list_start].rstrip() + "\n"
    primary_fr_coverage = epic_fr_coverage(requirements_body)

    destination = root / "_bmad-output/planning-artifacts/epics"
    temp_dir = destination.with_name(f".{destination.name}.tmp-{os.getpid()}")
    if temp_dir.exists():
        shutil.rmtree(temp_dir)
    temp_dir.mkdir(parents=True)

    files: list[dict[str, Any]] = []
    epics: list[dict[str, Any]] = []
    max_words = int(contract.get("max_epic_shard_words", 8000))

    requirements_path = temp_dir / "requirements.md"
    requirements_text = (
        shard_frontmatter(
            "requirements-catalog",
            "grapplegame.epics.requirements",
            source_digest,
        )
        + requirements_body
    )
    write_text_atomic(requirements_path, requirements_text)
    files.append(
        {
            "path": requirements_path.name,
            "kind": "requirements",
            "sha256": sha256(requirements_path),
            "words": word_count_text(requirements_text),
            "requirement_ids": extract_requirements(requirements_text),
        }
    )

    for epic_index, match in enumerate(epic_matches):
        epic_number = int(match.group(1))
        epic_title = match.group(2).strip()
        end = (
            epic_matches[epic_index + 1].start()
            if epic_index + 1 < len(epic_matches)
            else len(text)
        )
        epic_text = text[match.start() : end].rstrip() + "\n"
        story_matches = list(
            re.finditer(
                r"(?m)^### Story (\d+)\.(\d+):\s*(.+?)\s*$", epic_text
            )
        )
        first_story = story_matches[0].start() if story_matches else len(epic_text)
        overview_body = (
            epic_text[:first_story].replace("## Epic ", "# Epic ", 1).rstrip()
            + "\n"
        )
        epic_requirement_ids = primary_fr_coverage.get(epic_number, [])
        if epic_requirement_ids:
            overview_body = (
                overview_body.rstrip()
                + "\n\n**Primary functional requirements:** "
                + ", ".join(epic_requirement_ids)
                + "\n"
            )
        overview_name = f"epic-{epic_number:02d}-overview.md"
        overview_path = temp_dir / overview_name
        overview_text = (
            shard_frontmatter(
                "epic-overview",
                f"grapplegame.epics.{epic_number}",
                source_digest,
                epic=epic_number,
            )
            + overview_body
        )
        write_text_atomic(overview_path, overview_text)
        files.append(
            {
                "path": overview_name,
                "kind": "epic-overview",
                "epic": epic_number,
                "sha256": sha256(overview_path),
                "words": word_count_text(overview_text),
                "requirement_ids": extract_requirements(overview_text),
            }
        )

        epic_record: dict[str, Any] = {
            "id": str(epic_number),
            "title": epic_title,
            "overview": overview_name,
            "requirement_ids": epic_requirement_ids,
            "stories": [],
        }
        for story_index, story_match in enumerate(story_matches):
            story_epic = int(story_match.group(1))
            story_number = int(story_match.group(2))
            if story_epic != epic_number:
                raise ValueError(
                    f"story {story_epic}.{story_number} is under epic {epic_number}"
                )
            story_end = (
                story_matches[story_index + 1].start()
                if story_index + 1 < len(story_matches)
                else len(epic_text)
            )
            story_title = story_match.group(3).strip()
            story_body = (
                epic_text[story_match.start() : story_end]
                .replace("### Story ", "# Story ", 1)
                .rstrip()
                + "\n"
            )
            story_name = (
                f"epic-{epic_number:02d}-story-{story_number:02d}.md"
            )
            story_path = temp_dir / story_name
            story_text = (
                shard_frontmatter(
                    "epic-story",
                    f"grapplegame.story.{epic_number}.{story_number}",
                    source_digest,
                    epic=epic_number,
                    story=story_number,
                )
                + story_body
            )
            write_text_atomic(story_path, story_text)
            story_entry = {
                "id": f"{epic_number}.{story_number}",
                "title": story_title,
                "path": story_name,
                "sha256": sha256(story_path),
                "words": word_count_text(story_text),
                "requirement_ids": extract_requirements(story_text),
            }
            epic_record["stories"].append(story_entry)
            files.append({"kind": "story", "epic": epic_number, **story_entry})
        epics.append(epic_record)

    index_lines = [
        shard_frontmatter(
            "epics-index", "grapplegame.epics", source_digest
        ).rstrip(),
        "",
        "# testgame - Epic and Story Index",
        "",
        "This is the canonical bounded backlog index. Detailed story content is "
        "loaded selectively; do not concatenate every shard.",
        "",
        "- [Requirements inventory](requirements.md)",
        "- [Machine-readable manifest](manifest.json)",
    ]
    for epic in epics:
        index_lines.extend(
            [
                "",
                f"## Epic {epic['id']}: {epic['title']}",
                "",
                f"[Epic overview]({epic['overview']})",
            ]
        )
        for story in epic["stories"]:
            index_lines.extend(
                [
                    "",
                    f"### Story {story['id']}: {story['title']}",
                    "",
                    f"[Load this story shard]({story['path']})",
                ]
            )
    index_text = "\n".join(index_lines).rstrip() + "\n"
    index_path = temp_dir / "index.md"
    write_text_atomic(index_path, index_text)
    files.append(
        {
            "path": "index.md",
            "kind": "index",
            "sha256": sha256(index_path),
            "words": word_count_text(index_text),
            "requirement_ids": extract_requirements(index_text),
        }
    )

    all_requirement_ids = sorted(
        {
            item
            for entry in files
            for item in entry.get("requirement_ids", [])
        },
        key=requirement_sort_key,
    )
    input_documents = [
        "_bmad-output/planning-artifacts/gdd.md",
        "_bmad-output/planning-artifacts/architecture.md",
        "_bmad-output/planning-artifacts/decision-log.md",
    ]
    missing_inputs = [
        input_name
        for input_name in input_documents
        if not (root / input_name).is_file()
    ]
    if missing_inputs:
        shutil.rmtree(temp_dir)
        raise FileNotFoundError(
            "cannot publish epics without canonical inputs: "
            + ", ".join(missing_inputs)
        )

    manifest = {
        "artifact_schema": 1,
        "artifact_id": "grapplegame.epics",
        "document_type": "epics-manifest",
        "status": "complete",
        "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "source_path": source_name.replace("\\", "/"),
        "source_sha256": source_digest,
        "input_documents": input_documents,
        "input_revisions": {
            input_name: sha256(root / input_name)
            for input_name in input_documents
        },
        "requirement_ids": all_requirement_ids,
        "epics": epics,
        "files": files,
    }
    manifest_path = temp_dir / "manifest.json"
    write_text_atomic(
        manifest_path, json.dumps(manifest, indent=2, sort_keys=True) + "\n"
    )

    errors = validate_generated_package(temp_dir, manifest, max_words)
    if errors:
        shutil.rmtree(temp_dir)
        raise ValueError(
            "epic package validation failed: " + "; ".join(errors)
        )

    if destination.exists():
        archive_dir = (
            root
            / "_bmad-output/archive"
            / f"epics-package-{timestamp()}"
        )
        archive_dir.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(destination), str(archive_dir))
    os.replace(temp_dir, destination)
    archive_root = (root / "_bmad-output/archive").resolve()
    try:
        source.resolve().relative_to(archive_root)
        source_is_archived = True
    except ValueError:
        source_is_archived = False
    if not source_is_archived:
        archive_file(root, source, "epics-monolith")
    (root / "_bmad-output/.artifact-index/epics-producer.lock").unlink(
        missing_ok=True
    )
    return destination


def publish_ux(root: Path, source_name: str) -> Path:
    source = root / source_name
    design = source / "DESIGN.md"
    experience = source / "EXPERIENCE.md"
    if not design.is_file() or not experience.is_file():
        raise FileNotFoundError(
            "UX publication requires both DESIGN.md and EXPERIENCE.md"
        )
    destination = root / "_bmad-output/planning-artifacts/ux"
    temp_dir = destination.with_name(f".{destination.name}.tmp-{os.getpid()}")
    if temp_dir.exists():
        shutil.rmtree(temp_dir)
    shutil.copytree(source, temp_dir)
    index = shard_frontmatter(
        "ux-index", "grapplegame.ux", sha256(design)
    ) + "\n".join(
        [
            "# GrappleGame UX Package",
            "",
            "- [Visual design system](DESIGN.md)",
            "- [Experience, flows, and interaction model](EXPERIENCE.md)",
            "",
        ]
    )
    write_text_atomic(temp_dir / "index.md", index)
    if destination.exists():
        archive_dir = (
            root / "_bmad-output/archive" / f"ux-package-{timestamp()}"
        )
        archive_dir.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(destination), str(archive_dir))
    os.replace(temp_dir, destination)
    return destination


def validate_manifest(
    root: Path,
) -> tuple[dict[str, Any] | None, list[str]]:
    path = root / "_bmad-output/planning-artifacts/epics/manifest.json"
    if not path.is_file():
        return None, ["epic manifest is missing"]
    manifest = json.loads(path.read_text(encoding="utf-8"))
    errors = validate_generated_package(
        path.parent,
        manifest,
        int(load_contract(root).get("max_epic_shard_words", 8000)),
    )
    return manifest, errors


def readiness_report(
    root: Path,
) -> tuple[dict[str, Any], Path, Path]:
    inventory = build_inventory(
        root, "gds-check-implementation-readiness"
    )
    manifest, manifest_errors = validate_manifest(root)
    errors = list(inventory["errors"]) + manifest_errors
    warnings: list[str] = []

    contract = load_contract(root)
    gdd_path = root / contract["artifacts"]["gdd"]["canonical"]
    architecture_path = (
        root / contract["artifacts"]["architecture"]["canonical"]
    )
    decision_path = (
        root / contract["artifacts"]["decision_log"]["canonical"]
    )
    context_path = (
        root / contract["artifacts"]["project_context"]["canonical"]
    )
    gdd_text = gdd_path.read_text(encoding="utf-8") if gdd_path.is_file() else ""
    architecture_text = (
        architecture_path.read_text(encoding="utf-8")
        if architecture_path.is_file()
        else ""
    )
    decision_text = (
        decision_path.read_text(encoding="utf-8")
        if decision_path.is_file()
        else ""
    )
    context_text = (
        context_path.read_text(encoding="utf-8")
        if context_path.is_file()
        else ""
    )

    expected_gdd_digest = frontmatter_scalar(
        architecture_text, "gdd_sha256"
    )
    current_gdd_digest = sha256(gdd_path) if gdd_path.is_file() else None
    if expected_gdd_digest != current_gdd_digest:
        errors.append(
            "architecture is not stamped with the selected GDD revision"
        )
    expected_arch_decision_digest = frontmatter_scalar(
        architecture_text, "decision_log_sha256"
    )
    current_decision_digest = (
        sha256(decision_path) if decision_path.is_file() else None
    )
    if expected_arch_decision_digest != current_decision_digest:
        errors.append(
            "architecture is not stamped with the selected decision-log revision"
        )

    if manifest:
        manifest_revisions = manifest.get("input_revisions", {})
        for input_name in manifest.get("input_documents", []):
            input_path = root / input_name
            current_digest = sha256(input_path) if input_path.is_file() else None
            if manifest_revisions.get(input_name) != current_digest:
                errors.append(
                    "epic manifest has stale or missing input revision: "
                    + input_name
                )

    gdd_requirements = set(extract_requirements(gdd_text))
    gdd_frs = {item for item in gdd_requirements if item.startswith("FR")}
    gdd_nfrs = {item for item in gdd_requirements if item.startswith("NFR")}
    manifest_requirements = (
        set(manifest.get("requirement_ids", [])) if manifest else set()
    )
    validated_shards: list[dict[str, str]] = []
    if manifest:
        package = root / "_bmad-output/planning-artifacts/epics"
        for entry in manifest.get("files", []):
            shard_path = package / entry["path"]
            if (
                shard_path.is_file()
                and sha256(shard_path) == entry.get("sha256")
            ):
                validated_shards.append(
                    {
                        "path": entry["path"],
                        "sha256": entry["sha256"],
                    }
                )
    story_requirements: set[str] = set()
    epic_requirements: set[str] = set()
    untagged_story_count = 0
    if manifest:
        for epic in manifest.get("epics", []):
            epic_requirements.update(epic.get("requirement_ids", []))
            for story in epic.get("stories", []):
                requirement_ids = story.get("requirement_ids", [])
                story_requirements.update(requirement_ids)
                if not requirement_ids:
                    untagged_story_count += 1

    # The requirements catalog is copied from the monolith, so counting it as
    # delivery coverage would let an unassigned requirement pass readiness.
    # Functional coverage must come from an explicit epic or story mapping.
    delivery_requirements = epic_requirements | story_requirements
    missing_fr_delivery_coverage = sorted(
        gdd_frs - delivery_requirements,
        key=requirement_sort_key,
    )
    if missing_fr_delivery_coverage:
        errors.append(
            "GDD functional requirements absent from epic/story delivery mappings: "
            + ", ".join(missing_fr_delivery_coverage)
        )
    if untagged_story_count:
        warnings.append(
            f"{untagged_story_count} story shards have no explicit requirement IDs; "
            "functional coverage currently relies on primary epic mappings"
        )
    architecture_requirements = set(extract_requirements(architecture_text))
    missing_nfr_disposition = sorted(
        gdd_nfrs - architecture_requirements,
        key=requirement_sort_key,
    )
    if missing_nfr_disposition:
        errors.append(
            "GDD NFRs without architecture disposition: "
            + ", ".join(missing_nfr_disposition)
        )

    ux_required = (
        frontmatter_scalar(gdd_text, "ux_required") or "true"
    ).lower() == "true"
    ux_exists = (
        root / contract["artifacts"]["ux"]["canonical"]
    ).is_file()
    if ux_required and not ux_exists:
        errors.append(
            "UX is required by the GDD, but the canonical UX bundle is absent"
        )

    open_decisions = [
        {
            "id": match.group(1).strip(),
            "blocks_phase": match.group(2).strip(),
            "decision": match.group(3).strip(),
        }
        for match in re.finditer(
            r"(?mi)^\|\s*(OD-[^|]+)\|\s*Open\s*\|\s*([^|]+)\|\s*([^|]+)\|",
            decision_text,
        )
    ]
    blocking_open = [
        item["id"]
        for item in open_decisions
        if item["blocks_phase"].lower() == "implementation"
    ]
    if blocking_open:
        errors.append(
            "open implementation-blocking decisions: "
            + ", ".join(item.strip() for item in blocking_open)
        )
    if open_decisions:
        warnings.append(
            f"{len(open_decisions)} open decisions remain; apply their phase labels "
            "before starting the affected work"
        )

    expected_arch_digest = frontmatter_scalar(
        context_text, "architecture_sha256"
    )
    current_arch_digest = (
        sha256(architecture_path) if architecture_path.is_file() else None
    )
    if expected_arch_digest != current_arch_digest:
        errors.append(
            "project context is not stamped with the selected architecture revision"
        )
    expected_decision_digest = frontmatter_scalar(
        context_text, "decision_log_sha256"
    )
    if expected_decision_digest != current_decision_digest:
        errors.append(
            "project context is not stamped with the selected decision-log revision"
        )

    ux_requirement_ids = {
        item for item in manifest_requirements if item.startswith("UX-DR")
    }
    if ux_exists and not ux_requirement_ids:
        warnings.append(
            "UX bundle exists but no UX-DR identifiers are present in the epic manifest"
        )

    report = {
        "schema_version": 1,
        "generated_at": datetime.now().astimezone().isoformat(
            timespec="seconds"
        ),
        "ready": not errors,
        "implementation_scope_ready": frontmatter_scalar(
            gdd_text, "implementation_scope_ready"
        ),
        "inventory_valid": inventory["valid"],
        "artifact_revisions": {
            name: record.get("sha256")
            for name, record in inventory["artifacts"].items()
        },
        "lineage": {
            "architecture_gdd_sha256": expected_gdd_digest,
            "architecture_decision_log_sha256": (
                expected_arch_decision_digest
            ),
            "epic_input_revisions": (
                manifest.get("input_revisions", {}) if manifest else {}
            ),
            "project_context_architecture_sha256": expected_arch_digest,
            "project_context_decision_log_sha256": expected_decision_digest,
        },
        "epic_manifest_sha256": (
            sha256(root / contract["artifacts"]["epics"]["manifest"])
            if manifest
            else None
        ),
        "epic_shards": len(manifest.get("files", [])) if manifest else 0,
        "shard_validation": {
            "expected": len(manifest.get("files", [])) if manifest else 0,
            "validated": len(validated_shards),
            "digests": validated_shards,
        },
        "coverage": {
            "gdd_fr_count": len(gdd_frs),
            "gdd_nfr_count": len(gdd_nfrs),
            "manifest_requirement_count": len(manifest_requirements),
            "epic_requirement_count": len(epic_requirements),
            "story_requirement_count": len(story_requirements),
            "story_shards_without_requirement_ids": untagged_story_count,
            "missing_fr_delivery_coverage": missing_fr_delivery_coverage,
            "missing_nfr_architecture_disposition": (
                missing_nfr_disposition
            ),
            "ux_requirement_ids": sorted(ux_requirement_ids),
        },
        "errors": errors,
        "warnings": warnings,
        "open_decisions": open_decisions,
    }
    output_dir = root / contract["inventory_dir"]
    json_path = output_dir / "readiness.json"
    md_path = output_dir / "readiness.md"
    output_dir.mkdir(parents=True, exist_ok=True)
    write_text_atomic(
        json_path, json.dumps(report, indent=2, sort_keys=True) + "\n"
    )
    lines = [
        "# Extended Implementation Readiness Preflight",
        "",
        f"**Ready:** {'yes' if report['ready'] else 'no'}",
        "**Declared implementation scope ready:** "
        f"{report['implementation_scope_ready'] or 'none'}",
        f"**Epic shards validated:** {report['epic_shards']}",
        "**Shard digests processed:** "
        f"{report['shard_validation']['validated']}/"
        f"{report['shard_validation']['expected']}",
        f"**GDD functional requirements:** {len(gdd_frs)}",
        f"**GDD non-functional requirements:** {len(gdd_nfrs)}",
        f"**Manifest requirements:** {len(manifest_requirements)}",
        "",
        "## Errors",
        "",
    ]
    if errors:
        lines.extend(f"- {item}" for item in errors)
    else:
        lines.append("- None")
    lines.extend(["", "## Warnings", ""])
    if warnings:
        lines.extend(f"- {item}" for item in warnings)
    else:
        lines.append("- None")
    lines.extend(["", "## Open Decisions", ""])
    if open_decisions:
        lines.extend(
            [
                "| ID | Blocks phase | Decision required |",
                "|---|---|---|",
                *[
                    f"| {item['id']} | {item['blocks_phase']} | {item['decision']} |"
                    for item in open_decisions
                ],
            ]
        )
    else:
        lines.append("- None")
    write_text_atomic(md_path, "\n".join(lines) + "\n")
    return report, json_path, md_path


def context_pack(
    root: Path, story_id: str
) -> tuple[dict[str, Any], Path]:
    normalized = story_id.replace("-", ".")
    manifest, errors = validate_manifest(root)
    if errors or manifest is None:
        raise ValueError(
            "cannot build context pack: " + "; ".join(errors)
        )
    selected_story: dict[str, Any] | None = None
    selected_epic: dict[str, Any] | None = None
    for epic in manifest.get("epics", []):
        for story in epic.get("stories", []):
            if story["id"] == normalized:
                selected_story = story
                selected_epic = epic
                break
        if selected_story:
            break
    if selected_story is None or selected_epic is None:
        raise ValueError(f"story not found in epic manifest: {story_id}")
    inventory = build_inventory(root, "gds-create-story", normalized)
    if not inventory["valid"]:
        raise ValueError(
            "cannot build context pack from invalid planning inventory: "
            + "; ".join(inventory["errors"])
        )
    files = [
        "_bmad-output/planning-artifacts/epics/requirements.md",
        (
            "_bmad-output/planning-artifacts/epics/"
            + selected_epic["overview"]
        ),
        (
            "_bmad-output/planning-artifacts/epics/"
            + selected_story["path"]
        ),
        "_bmad-output/planning-artifacts/gdd.md",
        "_bmad-output/planning-artifacts/architecture.md",
        "_bmad-output/project-context.md",
    ]
    ux_index = root / "_bmad-output/planning-artifacts/ux/index.md"
    if ux_index.is_file():
        files.extend(
            [
                "_bmad-output/planning-artifacts/ux/index.md",
                "_bmad-output/planning-artifacts/ux/DESIGN.md",
                "_bmad-output/planning-artifacts/ux/EXPERIENCE.md",
            ]
        )
    pack = {
        "schema_version": 1,
        "story": normalized,
        "requirement_ids": sorted(
            set(selected_epic.get("requirement_ids", []))
            | set(selected_story.get("requirement_ids", [])),
            key=requirement_sort_key,
        ),
        "files": [
            {"path": name, "sha256": sha256(root / name)}
            for name in files
            if (root / name).is_file()
        ],
        "inventory_valid": inventory["valid"],
        "inventory_errors": inventory["errors"],
        "inventory_warnings": [
            f"{record['name']}: {message}"
            for record in inventory["artifacts"].values()
            for message in record["warnings"]
        ],
    }
    output = (
        root
        / "_bmad-output/.artifact-index"
        / f"context-{normalized.replace('.', '-')}.json"
    )
    write_text_atomic(
        output, json.dumps(pack, indent=2, sort_keys=True) + "\n"
    )
    return pack, output


def command_resolve(args: argparse.Namespace) -> int:
    root = project_root(args.project_root)
    inventory = build_inventory(root, args.consumer)
    json_path, md_path = write_inventory(root, inventory)
    print(
        json.dumps(
            {
                "valid": inventory["valid"],
                "json": relative(root, json_path),
                "markdown": relative(root, md_path),
                "errors": inventory["errors"],
            },
            indent=2,
        )
    )
    return 0 if inventory["valid"] else 1


def command_check(args: argparse.Namespace) -> int:
    root = project_root(args.project_root)
    inventory = build_inventory(root)
    manifest, manifest_errors = validate_manifest(root)
    inventory["errors"].extend(manifest_errors)
    inventory["valid"] = not inventory["errors"]
    json_path, md_path = write_inventory(root, inventory)
    print(
        json.dumps(
            {
                "valid": inventory["valid"],
                "json": relative(root, json_path),
                "markdown": relative(root, md_path),
                "errors": inventory["errors"],
                "manifest": bool(manifest),
            },
            indent=2,
        )
    )
    return 0 if inventory["valid"] else 1


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--project-root",
        help="Project root; defaults to the script's repository",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    resolve_parser = subparsers.add_parser("resolve")
    resolve_parser.add_argument("--consumer")
    resolve_parser.set_defaults(func=command_resolve)

    check_parser = subparsers.add_parser("check")
    check_parser.set_defaults(func=command_check)

    mirror_parser = subparsers.add_parser("mirror")
    mirror_parser.add_argument(
        "--artifact", required=True, choices=["gdd", "architecture"]
    )

    publish_parser = subparsers.add_parser("publish")
    publish_parser.add_argument(
        "--artifact", required=True, choices=["gdd", "architecture"]
    )
    publish_parser.add_argument("--source", required=True)

    shard_parser = subparsers.add_parser("shard-epics")
    shard_parser.add_argument(
        "--source",
        default="_bmad-output/planning-artifacts/epics.md",
    )

    ux_parser = subparsers.add_parser("publish-ux")
    ux_parser.add_argument("--source", required=True)

    subparsers.add_parser("readiness")

    context_parser = subparsers.add_parser("context-pack")
    context_parser.add_argument("--story", required=True)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    root = project_root(args.project_root)
    try:
        if args.command == "mirror":
            outputs = make_mirror(root, args.artifact)
            print(
                json.dumps(
                    {"mirrors": [relative(root, path) for path in outputs]},
                    indent=2,
                )
            )
            return 0
        if args.command == "publish":
            output = publish_artifact(
                root, args.artifact, args.source
            )
            print(
                json.dumps({"published": relative(root, output)}, indent=2)
            )
            return 0
        if args.command == "shard-epics":
            output = shard_epics(root, args.source)
            print(
                json.dumps({"published": relative(root, output)}, indent=2)
            )
            return 0
        if args.command == "publish-ux":
            output = publish_ux(root, args.source)
            print(
                json.dumps({"published": relative(root, output)}, indent=2)
            )
            return 0
        if args.command == "readiness":
            report, json_path, md_path = readiness_report(root)
            print(
                json.dumps(
                    {
                        "ready": report["ready"],
                        "json": relative(root, json_path),
                        "markdown": relative(root, md_path),
                        "errors": report["errors"],
                    },
                    indent=2,
                )
            )
            return 0 if report["ready"] else 2
        if args.command == "context-pack":
            pack, output = context_pack(root, args.story)
            print(
                json.dumps(
                    {
                        "story": pack["story"],
                        "output": relative(root, output),
                        "files": len(pack["files"]),
                    },
                    indent=2,
                )
            )
            return 0
        return args.func(args)
    except (
        FileNotFoundError,
        ValueError,
        OSError,
        json.JSONDecodeError,
    ) as error:
        print(json.dumps({"error": str(error)}, indent=2), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
