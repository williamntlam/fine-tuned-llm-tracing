# Feature specification workflow

Feature specifications make an implementation request durable, reviewable, and
easy for a future contributor or Codex task to resume. They live in `specs/`;
the Markdown file is the source of detailed human context, while YAML provides
a small structured index of the same work. `artifacts.md` is the compact review
brief that presents the important decisions without requiring a reviewer to
read both source files in full.

## Create a specification

1. Find the largest existing numeric prefix in `specs/` and use the next
   unused three-digit number.
2. Copy `specs/000-feature-name/` to
   `specs/<number>-<feature-name>/`, using lowercase kebab-case for the name.
3. Rename the values in `spec.md`, `spec.yaml`, and `artifacts.md`; set YAML
   `id`, `title`, and `status: draft`.
4. Fill in the problem, goals, non-goals, requirements, interfaces, acceptance
   criteria, plan, risks, and verification approach before substantial
   implementation begins.

For example, the first real specification might be:

```text
specs/001-synthetic-incident-generator/
├── spec.md
├── spec.yaml
└── artifacts.md
```

## Keep the three files aligned

`spec.md` holds the detail needed to build and review the feature. `spec.yaml`
holds a concise summary and must mirror the specification's identifier, title,
status, links, scope, interfaces, dependencies, acceptance criteria, and
verification notes.

`artifacts.md` is the fastest complete review surface. It must concisely cover
the intended outcome, consequential decisions, in/out of scope boundaries,
interfaces and dependencies, delivery and verification, risks, and open
questions. It must be shorter than `spec.md`, but must not omit a decision that
could change implementation, review, or rollout. Link to `spec.md` for
supporting detail rather than duplicating it. Do not store secrets or generated
experiment output in any spec file.

Use these statuses:

| Status | Meaning |
| --- | --- |
| `draft` | Scope is being shaped; implementation should not assume unresolved details. |
| `approved` | Requirements and acceptance criteria are ready for implementation. |
| `in_progress` | Implementation is underway. |
| `complete` | Acceptance criteria have been verified. |
| `superseded` | A later specification replaces this work. |

## During implementation

Update the specification in the same change whenever implementation changes a
requirement, interface, dependency, acceptance criterion, or verification
method. Link the issue or pull request when available. When work is complete,
record the verification command or result and set the YAML status to `complete`.
Update `artifacts.md` in that same change whenever any core decision, scope,
dependency, risk, or verification status changes.

Use the `feature-spec` skill for this workflow; its entrypoint is
`skills/feature-spec/SKILL.md`.
