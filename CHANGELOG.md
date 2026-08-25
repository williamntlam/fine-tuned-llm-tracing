# Change history

This file is the concise, human-readable record of changes delivered to this
repository. It complements Git history: use Git for individual commits and
this file to quickly understand what changed in each GitHub push.

## Update convention

- Whenever a task makes a meaningful repository change, update this file in
  the same change. Add a newest-first entry under a heading formatted as
  `YYYY-MM-DD HH:MM TZ — brief delivery name`, using the local Toronto time;
  refresh the timestamp immediately before the default-branch push when
  needed. Run `bash scripts/install-git-hooks.sh` once per clone to activate
  the validator that enforces the default-branch requirement.
- Describe the user-visible or contributor-relevant result, the principal
  files or areas changed, and any verification performed. Do not list every
  formatting-only edit.
- Keep entries factual, concise, and free of secrets, credentials, generated
  artifacts, or raw experiment data.
- If several commits ship together, record one entry for that push. If a push
  contains no meaningful repository change, an entry is not required.

## 2026-08-25 08:51 EDT — specification complexity review skill

- Added `skills/spec-complexity-review` for checking that material complexity
  in feature specifications has a clear, inspectable justification rather than
  treating complexity itself as a defect.
- Indexed the skill in `AGENTS.md` and `skills/README.md` for future spec work.
- Verification: skill frontmatter and repository diff checks passed.

## 2026-08-24 11:23 EDT — repository change-history convention

- Added this root-level change history so contributors can see the latest
  delivered work without inspecting the full Git log.
- Documented the requirement to add a timestamped summary with every
  meaningful repository change in `AGENTS.md`.
- Added an installable pre-push validator that blocks a default-branch push
  unless it includes a `CHANGELOG.md` update.
- Expanded specification 001's implemented-pattern guidance with each
  pattern's application, purpose, and practical value.
- Verification: shell syntax checks passed for the installer and hook; the
  hook's expected blocking path was exercised without a push; `git diff
  --check` passed for the affected tracked files.
