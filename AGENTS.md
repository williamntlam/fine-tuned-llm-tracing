# Codex Instructions

## Project

AI Incident Diagnosis Model Lab is a learning-focused LLM engineering project
for training and evaluating incident-diagnosis models from synthetic traces,
logs, metrics, topology, and incident metadata. Preserve deterministic,
inspectable experiments and ground-truth labels.

## Working conventions

- Read the relevant project documentation and any applicable local skill before
  changing code or data.
- Keep changes scoped to the user's request. Do not introduce a framework,
  external service, model, or dataset without a clear project need.
- Do not commit secrets, generated model weights, raw credentials, or large
  experiment artifacts. Prefer documented, reproducible generation steps.
- Validate the narrowest meaningful unit after a change and report the command
  and result.

## Documentation and skill upkeep

For every task, decide whether the implementation changes a user-facing
workflow, architecture, data contract, experiment procedure, or reusable
agent workflow.

- Update the relevant documentation in the same change when it would otherwise
  become stale or when the new behavior needs to be discoverable.
- Update an existing skill, or add a focused new one under `skills/`, when the
  task establishes reusable, non-obvious guidance for future Codex work.
- Do not create documentation or skills solely to satisfy this check; record
  only durable information that materially helps a future contributor or agent.

## Local skills

Project-specific skills live in `skills/<skill-name>/SKILL.md`. Use this index
to select a skill, then read only the matching entrypoint and any resource it
explicitly routes you to. Do not load every skill by default.

| Skill | Read when | Entrypoint |
| --- | --- | --- |
| Incident dataset | Creating or changing synthetic incidents, labels, schemas, generators, or dataset splits. | [`skills/incident-dataset/SKILL.md`](skills/incident-dataset/SKILL.md) |
| Incident evaluation | Creating or changing graders, benchmarks, evaluation reports, or experiment comparisons. | [`skills/incident-evaluation/SKILL.md`](skills/incident-evaluation/SKILL.md) |

Each skill must keep valid YAML frontmatter with a concise, discriminating
description. Add an index row whenever a new project skill is added.
