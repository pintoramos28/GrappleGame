# Pinned import check

Command (pinned Godot 4.7.2 console, operator-local):
`--headless --path . --import --quit-after 120` -> exit 0. Raw log:
`pinned-import.log` beside this file.

Registered the four new global classes (`GrappleAttachment`,
`GrappleAttachmentDiagnosticSnapshot`, `GrappleController`, `GrappleEndReason`)
and re-registered the extended motor types with no script errors; generated
`.gd.uid` sidecars for all new scripts
(`game/player/abilities/grapple/grapple_{attachment,attachment_diagnostic_snapshot,controller,end_reason}.gd.uid`,
`tests/player/grapple/test_grapple_boundary_{contract,integration}.gd.uid`).
Warnings limited to the pre-existing exit-time leak noise
(`1 RID allocations ... leaked at exit`, `1 resources still in use at exit`),
identical in kind to the Story 1.6 import record.

`rtk git diff --check` -> exit 0 (no whitespace errors).
