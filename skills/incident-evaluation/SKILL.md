---
name: incident-evaluation
description: "Create or modify incident-diagnosis evaluation, deterministic graders, benchmark reports, and experiment comparisons."
---

# Incident Evaluation

Evaluate models against held-out incidents with labels that are independent of
the model output.

- Specify the expected output contract and which fields are graded before
  changing an evaluator.
- Prefer deterministic graders for root cause, affected service, severity, and
  structured-output validity. Use an LLM judge only for qualitative criteria
  such as explanation quality, and report its model and prompt version.
- Report metrics by incident type and severity as well as an aggregate score;
  preserve the evaluated dataset version, model identifier, prompt, and
  evaluator version with each result.
- Keep baselines and candidate evaluations on the same split and rubric. Do
  not compare scores produced from different contracts without clearly
  labelling the comparison as non-equivalent.
- Treat evaluation outputs as experiment artifacts, not source data; avoid
  committing large raw outputs unless the repository explicitly calls for it.

When an output schema or label vocabulary changes, update the associated
dataset documentation and deterministic graders together.
