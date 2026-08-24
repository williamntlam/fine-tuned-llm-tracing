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

- Use a layered package at `src/tracing_diagnosis/`: `domain`,
  `application`, `infrastructure`, `interfaces`, and narrowly scoped `shared`.
- Keep domain rules framework-free. `domain` and `application` cannot import
  `infrastructure` or `interfaces`; dependency wiring belongs in entrypoint
  composition roots.
- Define external needs as small ports in domain/application and provide their
  concrete adapters in infrastructure.
- Model workflows as named application use cases; HTTP, CLI, and job entrypoints
  only translate inputs, compose dependencies, and invoke use cases.
- Use provider-neutral inference and fine-tuning ports, implemented by adapters
  for the OpenAI API and Hugging Face Qwen models. Application use cases depend
  only on the ports; SDK imports, credentials, request translation, local GPU
  setup, job polling, and provider response formats remain in infrastructure.
- Fine-tuning adapters normalize the shared lifecycle—submit, inspect status,
  and retrieve the model/artifact reference—without claiming equal parameters
  or capabilities. Provider-specific tuning settings are validated at the
  configuration/adapter boundary.
- Apply factories only to configured dependency selection and strategies only
  to genuinely interchangeable behavior. Avoid global clients, a DI container,
  and interfaces for one-off logic.
- Keep the scaffold framework-unopinionated: standard Python typing and
  dataclasses are sufficient unless a concrete boundary demonstrates a need for
  another validation or serialization library. No web framework, ORM, or model
  SDK is selected by this specification; Pyright is the selected static checker.
- Make domain entities, use-case commands/results, port inputs/results,
  settings, and persisted/transport schemas named typed contracts. Public code
  is fully annotated; `Any` and untyped mappings may exist only briefly at an
  external adapter/interface boundary before translation to a named type.
- Use an ignored local `.env` for development secrets and commit only
  `.env.example` with empty `OPENAI_API_KEY=` and optional `HF_TOKEN=` values.
  The Hugging Face token is unnecessary for an already local open-weight model,
  but may be needed for gated artifact access. CI and production inject secrets
  through their approved environment mechanism.

## Target codebase directories

This is a planned scaffold; it does not yet exist in the repository.

```text
src/tracing_diagnosis/
├── domain/                 # Incident/diagnosis types and suitable ports
├── application/
│   ├── ports/              # Inference and fine-tuning contracts
│   └── use_cases/          # Generate, train, evaluate, diagnose workflows
├── infrastructure/
│   ├── adapters/           # Files, in-memory, OpenAI, and Qwen implementations
│   ├── decorators/         # Telemetry, retry, and redaction wrappers
│   └── factories.py        # Configured dependency construction
├── interfaces/             # CLI, HTTP, and job composition roots
└── shared/                 # Typed settings and generic errors

tests/{unit,integration,e2e}/  # Test tiers
configs/                       # Versioned, non-secret runtime config
scripts/                       # Reproducible developer commands
docs/{architecture,development}.md
pyproject.toml
.env.example                   # Empty provider-secret template
.env                           # Local only; Git-ignored
.gitignore
```

The complete tree, including representative first-slice module names, is in
[spec.md](spec.md#target-repository-layout). Generated data, checkpoints,
logs, and experiment runs remain outside `src/` and version control.

## Fine-tuning context

Future work targets SFT, DPO, and RFT for hosted OpenAI models, plus SFT, DPO,
and a local reinforcement method for open-weight Qwen. This is architecture
context only, not an implementation commitment in this specification. Provider
and method remain typed configuration values; OpenAI RFT and a local method
such as GRPO must not be treated as equivalent. A follow-up fine-tuning spec
must define the per-provider/method capability matrix, training data shape,
grader/reward requirements, runtime, artifacts, and evaluation evidence.

## Pattern decisions

**Implement now:** Adapter for provider integration; Factory Method for adapter
selection; Command-shaped use-case requests; Strategy for grading, sampling,
and training algorithms; and Decorator around provider ports for telemetry,
retries, rate limits, redaction, and optionally caching. Decorators must remain
composable and must not alter application-use-case contracts.

**Avoid/defer:** Abstract Factory, Builder, Prototype, Singleton, Bridge,
Composite, Facade, Flyweight, Proxy, Chain of Responsibility, Mediator,
Memento, Observer, State, Template Method, and Visitor. Use typed immutable
configuration, explicit application services, a persisted fine-tuning status
enum with transition validation, composition, and native Python iteration
instead. Reconsidering a deferred pattern requires a future specification
amendment.

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
- Ports cover model inference, fine-tuning, storage, tracking, and telemetry.
  OpenAI API and Hugging Face Qwen adapters implement the model ports and are
  selected at the composition root through configuration.
- Python packaging, test, and lint tools remain an implementation-time decision,
  selected for reproducible ML/GPU and CI support. Pyright must be configured
  in `pyproject.toml` with `typeCheckingMode = "strict"`, include `src/` and
  `tests/`, and pass locally and in CI.

## Delivery and verification

1. Select and record the Python toolchain, then create the directory scaffold.
2. Add a vertical slice: domain type, inference/fine-tuning ports, use case,
   in-memory adapter, OpenAI API and Hugging Face Qwen adapters, and a
   composition root.
3. Add offline unit tests, architecture/developer documentation, exclusions,
   and canonical local/CI commands.

- [ ] Layered package, test tiers, `scripts/`, and `configs/` exist.
- [ ] Dependency direction is documented and honoured.
- [ ] A unit test runs a use case with an in-memory fake and no network, GPU,
  credentials, or external service.
- [ ] The composition root switches fake and concrete adapters without changing
  use-case code.
- [ ] Configuration switches inference and fine-tuning use cases between
  OpenAI API and Hugging Face Qwen adapters without changing application code.
- [ ] Offline contract tests confirm both adapters produce normalized inference
  results and fine-tuning lifecycle results without live provider calls.
- [ ] Composable decorators cover telemetry, retry, and redaction behavior with
  fake ports and leave application-use-case contracts unchanged.
- [ ] Documentation explains extension conventions; secrets and generated
  artifacts are excluded and their local locations are documented.
- [ ] Architecture documentation records the implemented and deferred patterns.
- [ ] Core contracts are explicitly typed, and Pyright strict mode passes for
  `src/` and `tests` without errors.
- [ ] `.env.example` has empty `OPENAI_API_KEY` and optional `HF_TOKEN`
  placeholders; `.env` is ignored and contains no committed secrets.

## Risks and open questions

- Tooling must be chosen deliberately for reproducible GPU/ML dependencies and
  CI rather than by convention alone.
- Keep the domain/application boundary lightweight for simple transformations.
- Extract training into a separate deployable package only when runtime needs
  actually diverge.
- Add automated import-boundary enforcement only if it fits the selected
  toolchain cleanly.
