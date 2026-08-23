---
name: incident-dataset
description: "Create or modify synthetic distributed-system incident datasets, labels, and splits. Use when changing incident-generation or training-data workflows."
---

# Incident Dataset

Preserve a known root cause for every generated incident so examples can be
used for supervised training and deterministic evaluation.

- Define the incident schema, label vocabulary, affected service, severity,
  and explanation before adding generation logic.
- Keep traces, logs, metrics, topology, and incident metadata consistent with
  the stated root cause. Do not leak the answer through an unrealistic field.
- Make generation reproducible: expose or record a seed, generator version,
  and configuration used for each dataset build.
- Maintain separate training, validation, and test splits with no duplicated
  incident templates or near-identical scenarios across split boundaries.
- Add edge cases and healthy traffic deliberately; avoid an artificially
  balanced dataset unless that is an explicit experiment choice.

When a data contract changes, update the dataset documentation and the
corresponding evaluator or graders in the same task.
