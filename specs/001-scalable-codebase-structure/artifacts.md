# Scalable codebase structure — review brief

| Field | Value |
| --- | --- |
| Spec ID | `001-scalable-codebase-structure` |
| Status | `draft` |
| Full specification | [spec.md](spec.md) |

## Intended outcome

Create a Python-first repository scaffold that can grow from a learning project
into independently runnable dataset, training, evaluation, inference, and
observability workloads without creating a monolith or prematurely adopting
microservices.

## Core decisions

- Use a layered package at `src/incident_diagnosis/`: `domain`,
  `application`, `infrastructure`, `interfaces`, and narrowly scoped `shared`.
- Keep domain rules framework-free. `domain` and `application` cannot import
  `infrastructure` or `interfaces`; dependency wiring belongs in entrypoint
  composition roots.
- Define external needs as small ports in domain/application and provide their
  concrete adapters in infrastructure.
- Model workflows as named application use cases; HTTP, CLI, and job entrypoints
  only translate inputs, compose dependencies, and invoke use cases.
- Apply factories only to configured dependency selection and strategies only
  to genuinely interchangeable algorithms. Avoid global clients, a DI container,
  and interfaces for one-off logic.

## Scope

**In:** the package and test structure, configuration and documentation
conventions, one vertical slice with a fake adapter, and artifact/secret
handling.

**Out:** implementation of the actual generator, training, serving, or
tracking workloads; provider/database/cloud/CI choices; microservices, plugins,
event sourcing, and CQRS.

## Interfaces and dependencies

- Canonical incident inputs and diagnosis results live in domain types.
- Transport schemas translate at the interface boundary and do not become domain
  entities.
- Ports cover model, storage, tracking, and telemetry dependencies; concrete
  adapters remain replaceable.
- Python packaging, test, lint, and typing tools remain an implementation-time
  decision, selected for reproducible ML/GPU and CI support.

## Delivery and verification

1. Select and record the Python toolchain, then create the directory scaffold.
2. Add a vertical slice: domain type, port, use case, in-memory adapter, and
   composition root.
3. Add offline unit tests, architecture/developer documentation, exclusions,
   and canonical local/CI commands.

- [ ] Layered package, test tiers, `scripts/`, and `configs/` exist.
- [ ] Dependency direction is documented and honoured.
- [ ] A unit test runs a use case with an in-memory fake and no network, GPU,
  credentials, or external service.
- [ ] The composition root switches fake and concrete adapters without changing
  use-case code.
- [ ] Documentation explains extension conventions; secrets and generated
  artifacts are excluded and their local locations are documented.

## Risks and open questions

- Tooling must be chosen deliberately for reproducible GPU/ML dependencies and
  CI rather than by convention alone.
- Keep the domain/application boundary lightweight for simple transformations.
- Extract training into a separate deployable package only when runtime needs
  actually diverge.
- Add automated import-boundary enforcement only if it fits the selected
  toolchain cleanly.
