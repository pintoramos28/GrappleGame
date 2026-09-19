# Recursive player GUT results

Command:

```text
rtk <pinned Godot 4.7.2 console> --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit
```

Observed summary:

- Scripts: 7
- Tests: 64
- Passing tests: 64
- Assertions: 3070
- Exit code: 0

The recursive run included the new contact contract, all input suites, all
motor/integration/semantic suites, the expected invariant diagnostics, and
the known shutdown ObjectDB/resource messages. It is the canonical
comprehensive regression gate; it is not the MCP-native test result.
