---
name: feature-spec
description: "Create or update implementation-ready feature specifications in specs/. Use when scoping a feature or changing its requirements, acceptance criteria, or plan."
---

# Feature Spec

Create one folder per feature at `specs/<number>-<feature-name>/`. Start from
`specs/000-feature-name/`, replacing `000` with the next unused three-digit
number and using a lowercase kebab-case feature name.

Each feature folder contains:

- `spec.md` — the human-readable problem statement, requirements, acceptance
  criteria, and implementation plan.
- `spec.yaml` — the concise machine-readable summary used for discovery,
  status, ownership, and links.
- `artifacts.md` — a review brief that condenses the core decisions, scope,
  interfaces, acceptance criteria, plan, and risks from both spec files.

Keep all three files aligned. `artifacts.md` is not a changelog or a copy of
`spec.md`: it is the fastest complete review surface for the feature. Preserve
all decisions that affect implementation, review, risk, scope, or verification
while linking to `spec.md` for supporting detail. Use observable acceptance
criteria, identify affected interfaces or data contracts, and distinguish
requirements from open questions. Update the specification as implementation
decisions materially change it; do not mark it complete until its acceptance
criteria have been verified.

Read [`docs/specs.md`](../../docs/specs.md) for the full convention and the
template files for the current fields.
