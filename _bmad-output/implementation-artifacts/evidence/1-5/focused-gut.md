# Focused GUT results

All commands were run serially from the repository root using the pinned
Godot console executable:

```text
C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe
```

| Suite | Scripts | Tests | Passing | Assertions | Exit |
|---|---:|---:|---:|---:|---:|
| `res://tests/player/input` | 3 | 21 | 21 | 677 | 0 |
| `res://tests/player/motor` | 3 | 36 | 36 | 2320 | 0 |
| `res://tests/player/contact` | 1 | 7 | 7 | 73 | 0 |

The expected negative-path invariant messages (non-monotonic steps, invalid
body/profile composition, duplicate commits/submissions, and overflow) were
reported as GUT `ExpectedError` matches. They are not unexpected failures.
The runs also retain the project's existing ObjectDB/resource-at-exit noise;
it did not change the pass result.
