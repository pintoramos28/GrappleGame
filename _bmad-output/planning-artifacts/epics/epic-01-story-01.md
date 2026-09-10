---
artifact_schema: 1
artifact_id: 'grapplegame.story.1.1'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 1
story: 1
---

# Story 1.1: Verify and Protect the Playable Traversal Baseline

As a game developer,
I want a verified and repeatable record of the current traversal build,
So that I can distinguish pre-existing behavior from regressions introduced during architecture migration.

**Acceptance Criteria:**

**Given** the existing repository checkout before Epic 1 migration begins
**When** the development environment is inspected
**Then** the resolved Godot executable reports Godot 4.7.2-stable
**And** the available Git and `uv` versions, repository revision, working-tree state, and vendored dependency versions are recorded without installing or upgrading anything.

**Given** Godot 4.7.2-stable cannot be resolved or a required runtime dependency cannot load
**When** baseline verification is attempted
**Then** no scene, Resource, import, or project configuration is intentionally resaved with another engine version
**And** the problem is recorded for separately scoped remediation before migration work begins.

**Given** the project is inspected before launch
**When** the current engine and launch configuration is recorded
**Then** `res://main.tscn`, Forward+, Jolt Physics, fixed 60 Hz physics, and interpolation settings are identified as the baseline
**And** Story 1.1 does not change those settings or move the launch path.

**Given** the pinned editor has completed its initial imports
**When** the current `res://main.tscn` is opened and run
**Then** the project reaches its current playable state with a controllable player
**And** all pre-existing import, parse, missing-resource, scene-load, runtime error, and relevant warning output is captured separately from later migration results.

**Given** the current playable build
**When** the traversal smoke procedure is performed
**Then** the observed result of ground movement, air steering, jumping, grapple acquisition, grapple hold, grapple release, wall running, wall sticking, wall jumping, and ordinary mistake recovery is recorded as pass, fail, or not currently exercisable
**And** any failed or unavailable behavior needed by the next migration story receives separately scoped remediation rather than being repaired inside Story 1.1.

**Given** an existing scene is needed to exercise traversal during baseline capture
**When** `scenes/tree_grapple_tutorial.tscn` or another current scene is used
**Then** it serves only as disposable test content for observing the underlying traversal behavior
**And** its layout, lesson sequence, script behavior, identifiers, and continued existence are not treated as requirements for later stories.

**Given** the baseline run and traversal smoke procedure are complete
**When** the evidence is documented under the project's implementation artifacts
**Then** the record includes the date, repository revision and starting working-tree state, engine and dependency versions, exact launch procedure, scene used, actions exercised, observed results, relevant logs, and known pre-existing issues
**And** it makes no unsupported claim that automated tests passed because the project does not yet have an established `tests/` suite.

**Given** the baseline evidence has been recorded
**When** the working-tree diff is reviewed
**Then** no gameplay script, scene, Resource, UID, project setting, input binding, add-on, or tutorial content has been intentionally changed by this story
**And** the resulting evidence is sufficient for another developer or agent to repeat the same launch and smoke procedure.
