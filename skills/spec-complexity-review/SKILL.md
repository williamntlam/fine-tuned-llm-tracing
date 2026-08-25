---
name: spec-complexity-review
description: "Review feature specifications for unjustified complexity. Use when a spec proposes substantial architecture, abstractions, integrations, or process beyond the demonstrated need."
---

# Specification Complexity Review

Use this skill when drafting or reviewing a feature specification that may add
meaningful complexity. Complexity is not a defect by itself: treat it as
overengineering only when its cost lacks a clear justification tied to the
problem being solved.

For each material addition—such as a new component, abstraction layer,
framework, integration, data store, workflow, or configuration surface—make
the justification inspectable:

- State the concrete requirement, constraint, or evidence that calls for it.
- Explain why the smallest credible alternative does not meet that need.
- Name the added operational, maintenance, and learning costs where they are
  material to the decision.
- Prefer a reversible or deferred step when the need is uncertain or belongs to
  a future scale rather than the current scope.

Do not invent a rationale to defend a preferred design. When a justification
cannot be stated, recommend removing, simplifying, or explicitly deferring the
addition, and record any decision that needs stakeholder input as an open
question.

Keep specifications outcome-oriented: acceptance criteria should verify the
user or experiment need, not merely that a chosen implementation exists. Add a
brief complexity-and-justification section only when the proposed complexity
is material; avoid boilerplate for straightforward work.

Use alongside `feature-spec` when creating or updating a feature specification.
