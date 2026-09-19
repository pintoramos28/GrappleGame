# Limitations and review boundary

- Story 1.5 is left in `review`, not `done`, because the project policy still
  requires human feel/visual approval. Story 1.4 remains in `review` for that
  same pending approval; no human approval is claimed here.
- The Godot AI MCP native test runner found no direct `McpTestSuite` files.
  Its result is recorded separately; the recursive pinned GUT result is the
  comprehensive test gate.
- The live MCP jump/grapple/wall cases used the existing test-input seam to
  create deterministic action edges. The scene, motor, provider, and HSM were
  otherwise live; this is not a claim of unassisted human input.
- The 60/120 proof is the passing deterministic motor comparison. The live
  MCP Jolt smoke ran at the shipping 60 Hz rate, not in a second 120 Hz editor
  session.
- Pinned headless import still reports missing local backup-named LimboAI and
  Terrain3D GDExtension DLLs plus shutdown leak noise. Both load processes
  exit successfully; dependency repair is outside this story.
- Earlier intermediate reload diagnostics remain in the MCP editor log
  history. They were corrected before the final clean symbol scan and run;
  there were zero new editor diagnostics after cursor 27.
