# Project-Local Create Story Agent Routing

This project uses named, project-scoped Codex custom agents for create-story delegation. These are repository artifacts under `.codex/agents/`; they are not personal agents under `~/.codex/agents/`, Workspace Agents, or global Codex agents.

## Named roles

| Agent name | Project custom-agent file | Default model | Reasoning | Use when |
|---|---|---|---|---|
| `story_foundation_analyst` | `.codex/agents/story_foundation_analyst.toml` | `gpt-5.6-luna` | `max` | Extracting requirements, acceptance criteria, dependencies, scope, and traceability |
| `architecture_guardrail_analyst` | `.codex/agents/architecture_guardrail_analyst.toml` | `gpt-5.6-luna` | `max` | Mapping affected files, current behavior, architecture constraints, and regression risks |
| `story_continuity_analyst` | `.codex/agents/story_continuity_analyst.toml` | `gpt-5.6-luna` | `max` | Reviewing predecessor stories, git history, tests, and toolchain continuity |
| `story_validation_agent` | `.codex/agents/story_validation_agent.toml` | `gpt-5.6-luna` | `max` | Performing the single fresh-context checklist validation pass |
| `story_adjudicator` | `.codex/agents/story_adjudicator.toml` | `gpt-5.6-sol` | `max` | Resolving one specific unresolved cross-artifact or architecture contradiction |

## Delegation rules

1. Use the exact named custom agent for each responsibility. In orchestration prompts, refer to the agents by these exact names. Do not replace them with generic subagent prompts when the custom agent is available.
2. Pass the bounded context pack, story key, and required output format to each role. Do not pass the parent conversation history or broad artifact globs by default.
3. The custom-agent TOML files supply the model, reasoning effort, and read-only sandbox. Do not override those values in the normal delegation prompt.
4. Analysis roles are read-only and return compact, evidence-backed findings. They do not edit the story, source files, or sprint status.
5. Run `story_validation_agent` once after the story draft is complete. Apply fixes in the parent orchestrator.
6. Do not run a second quickcheck after a passing validation. Run another validation only when the first pass reports blockers or the parent makes material corrective changes.
7. Invoke `story_adjudicator` only for a named unresolved contradiction. Do not use it as a default validator or general reviewer.
8. Keep all custom-agent files project-local. Never create or update a personal agent, Workspace Agent, global Codex agent, account-level agent, or global skill for this routing policy.

## Expected orchestration order

1. Resolve the deterministic bounded context pack.
2. Run `story_foundation_analyst`, `architecture_guardrail_analyst`, and `story_continuity_analyst` in parallel when all three are relevant.
3. Synthesize the story in the parent create-story orchestrator.
4. Run `story_validation_agent` in fresh context.
5. Apply only evidence-backed blockers and corrections.
6. Escalate a remaining contradiction to `story_adjudicator` only when necessary.
