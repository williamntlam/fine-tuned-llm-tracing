# Feature specification workflow

Feature specifications make an implementation request durable, reviewable, and
easy for a future contributor or Codex task to resume. They live in `specs/`;
the Markdown file is the source of detailed human context, while YAML provides
a small structured index of the same work.

## Create a specification

1. Find the largest existing numeric prefix in `specs/` and use the next
   unused three-digit number.
2. Copy `specs/000-feature-name/` to
   `specs/<number>-<feature-name>/`, using lowercase kebab-case for the name.
3. Rename the values in `spec.md` and `spec.yaml`; set YAML `id`, `title`, and
   `status: draft`.
4. Fill in the problem, goals, non-goals, requirements, interfaces, acceptance
   criteria, plan, risks, and verification approach before substantial
   implementation begins.

For example, the first real specification might be:

```text
specs/001-synthetic-incident-generator/
├── spec.md
└── spec.yaml
```

## Keep the two files aligned

`spec.md` holds the detail needed to build and review the feature. `spec.yaml`
holds a concise summary and must mirror the specification's identifier, title,
status, links, scope, interfaces, dependencies, acceptance criteria, and
verification notes. Do not store secrets or generated experiment output in
either file.

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

Use the `feature-spec` skill for this workflow; its entrypoint is
`skills/feature-spec/SKILL.md`.
