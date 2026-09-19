# MCP-native test discovery

Using session `testgame@e362124f09f388c2`,
`test_run(verbose=false)` returned:

```text
total: 0
load_errors: []
error: No test suites found in res://tests/
edited_scene: res://main.tscn
```

This is expected because the project's tests are GUT `GutTest` scripts under
`res://tests/player/**`, while the current MCP runner discovers only direct
`res://tests/test_*.gd` scripts extending `McpTestSuite`. The recursive GUT
suite was run through the pinned Godot CLI and is documented separately.
