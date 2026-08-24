# Scalable codebase structure

## Summary

Establish a Python-first repository structure for the AI Incident Diagnosis
Model Lab that keeps domain logic independent of transport, storage, model
providers, and experiment tooling. The structure must support the planned
dataset, training, evaluation, serving, and observability work without
requiring a monolithic application package.

## Problem

The repository currently contains project documentation and agent workflows,
but no implementation boundary. Adding generators, training jobs, evaluators,
serving APIs, and experiment tracking directly at the repository root would
quickly couple unrelated concerns and make components difficult to test,
replace, or run independently.

The codebase needs a small, explicit architecture that works for a learning
project today and can grow into separately runnable workloads later.

## Goals

- Create a conventional Python package layout with clear ownership boundaries.
- Separate domain rules and use cases from external frameworks, databases,
  model SDKs, telemetry backends, and HTTP/CLI entrypoints.
- Make dataset generation, training, evaluation, inference, and observability
  independently runnable and testable.
- Use a small set of explicit design patterns where they reduce coupling:
  dependency inversion (ports and adapters), application use cases, factories
  for configured dependency construction, and strategy objects for
  interchangeable graders or training approaches.
- Provide a test layout and configuration conventions that support unit,
  integration, and end-to-end checks.

## Non-goals

- Implementing the dataset generator, training loop, serving API, or an
  experiment tracker.
- Introducing microservices, a plugin framework, event sourcing, CQRS, or a
  dependency-injection container before a concrete need exists.
- Choosing a production database, cloud provider, model provider, or CI
  service.
- Migrating any existing implementation code; none exists yet.

## Requirements

### Functional requirements

- Add a `src/incident_diagnosis/` Python package with the following layers:

  ```text
  src/incident_diagnosis/
  ├── domain/           # Entities, value objects, domain policies, ports
  ├── application/      # Use cases and orchestration of domain ports
  ├── infrastructure/   # Concrete adapters: files, model SDKs, tracking, telemetry
  ├── interfaces/       # HTTP, CLI, and job entrypoints
  └── shared/           # Narrow cross-cutting utilities and typed settings
  ```

- Keep `domain/` framework-free and prohibit imports from `infrastructure/`
  and `interfaces/` into either `domain/` or `application/`.
- Define external dependencies as small protocol/abstract interfaces (ports) in
  `domain/` or `application/`; put implementations (adapters) in
  `infrastructure/`.
- Express an operation such as generating incidents, training a model,
  evaluating a run, or diagnosing an incident as a named application use case.
  Entry points construct dependencies and invoke the use case; they do not
  contain business or orchestration logic.
- Use factories at the composition boundary to choose configured model clients,
  storage adapters, or experiment trackers. Avoid global client singletons.
- Define provider-neutral inference and fine-tuning ports in the application
  layer. Implement them with adapters for the OpenAI API and Hugging Face Qwen
  models. Application use cases must depend on these ports, never on an OpenAI
  SDK, `transformers`, or a provider-specific training API.
- The inference adapter normalizes diagnosis/model-generation requests and
  results. The fine-tuning adapter normalizes the shared fine-tuning lifecycle:
  submit a training request, inspect run status, and retrieve the resulting
  model or artifact reference.
- Do not pretend that provider capabilities or parameters are identical.
  Validate provider-specific settings at the adapter/configuration boundary and
  expose capability limits clearly. OpenAI API job submission and local Qwen
  training may have different runtimes, artifact formats, and supported tuning
  methods while sharing the same application-level intent.
- Select the configured adapter at a composition root through a factory. Keep
  provider credentials, request translation, SDK imports, GPU/runtime setup,
  and job polling inside infrastructure implementations.
- Use strategies for other genuinely replaceable algorithms such as
  deterministic versus LLM-judge grading, sampling, or training methods. Do
  not create interfaces for one-off logic.
- Add top-level directories for `tests/`, `scripts/`, and `configs/`.
  Organize tests as `tests/unit/`, `tests/integration/`, and `tests/e2e/`,
  mirroring the package where helpful.
- Add package and test configuration using a single supported Python project
  configuration file. The implementation task will select the dependency and
  test tools appropriate to the first runnable component.
- Include a short architecture document and a root-level development command
  reference when the scaffold is implemented.
- Document the pattern decision matrix below with the scaffold. Decorators are
  part of the initial structure; every other deferred pattern requires a future
  specification amendment before it is introduced.

### Non-functional requirements

- New modules must have a single clear responsibility and avoid circular
  imports across layers.
- A unit test of a use case must be able to supply fake ports without requiring
  network access, a GPU, a model API key, or a telemetry backend.
- Dependency wiring must be visible at a composition root (CLI command, API
  startup, or job bootstrap), not hidden in module import side effects.
- The scaffold must be suitable for local development and CI; generated data,
  checkpoints, and run artifacts must remain outside source packages and be
  excluded from version control unless deliberately curated.

## Proposed package map

| Area | Responsibility | Primary pattern |
| --- | --- | --- |
| `domain` | Incident concepts, diagnosis result, validation rules, and ports. | Entity/value object, port |
| `application` | Workflow-specific use cases and request/result DTOs. | Application service/use case |
| `infrastructure` | File, OpenAI API and Hugging Face Qwen model/training integrations, tracking, and telemetry. | Adapter, factory, decorator, strategy implementation |
| `interfaces` | FastAPI routes, CLI commands, scheduled/training job entrypoints. | Controller/command, composition root |
| `shared` | Typed configuration, error types, and strictly generic helpers. | Options/settings |

## Pattern decision matrix

| Pattern | Decision | Application in this project |
| --- | --- | --- |
| Factory Method | Implement | Select configured providers and infrastructure adapters at composition roots. |
| Abstract Factory | Avoid/defer | A Factory Method is sufficient for the initial provider adapters. |
| Builder | Avoid/defer | Use typed immutable configuration models before adding a builder layer. |
| Prototype | Avoid/defer | Prefer versioned config and dataset templates; clone runtime objects only if safe duplication has a real use case. |
| Singleton | Avoid/defer | Do not use global SDK clients, configuration, or registries; make lifetimes explicit at the composition root. |
| Adapter | Implement | Normalize OpenAI API and Hugging Face Qwen inference and fine-tuning interactions behind provider-neutral ports. |
| Bridge | Avoid/defer | The provider abstraction and its implementations have one current axis of variation. |
| Composite | Avoid/defer | Distributed topologies are usually graphs and should not be forced into a tree. |
| Decorator | Implement | Wrap provider ports for telemetry, retries, rate limits, redaction, and, when justified, caching without changing adapters. |
| Facade | Avoid/defer | Application use cases remain the public orchestration surface. |
| Flyweight | Avoid/defer | Consider only for measured memory pressure from repeated immutable labels or topology metadata. |
| Proxy | Avoid/defer | Use a decorator where wrapping behavior is needed; no proxy requirement exists. |
| Chain of Responsibility | Avoid/defer | Keep validation and processing explicit in use cases until a pipeline is demonstrably needed. |
| Command | Implement | Represent user-initiated application actions such as generate, train, evaluate, and diagnose as use-case request commands. |
| Iterator | Native language feature | Use Python iteration/generators for datasets; do not add a custom pattern layer unless traversal is itself a domain abstraction. |
| Mediator | Avoid/defer | Use focused application services before adding a coordination hub. |
| Memento | Avoid/defer | Preserve reproducibility with immutable, versioned configuration and experiment artifacts rather than in-memory state snapshots. |
| Observer | Avoid/defer | Call tracking and telemetry explicitly from use cases until an event contract is required. |
| State | Avoid/defer | Persist a fine-tuning status enum and validate transitions; do not add State objects initially. |
| Strategy | Implement | Exchange grading approaches, sampling policies, and training algorithms such as SFT, LoRA, QLoRA, or DPO. |
| Template Method | Avoid/defer | Prefer composition and strategies over inheritance-based workflow skeletons. |
| Visitor | Avoid/defer | Consider only when stable domain objects need multiple unrelated operations; avoid it for ordinary transformations. |

## Interfaces and data contracts

- Domain types should own canonical incident input and diagnosis result
  contracts. Transport schemas (for example, HTTP request/response models) must
  translate at the interface boundary instead of becoming domain entities.
- Dataset serialization formats, model-prompt formats, and evaluator report
  schemas require their own future specifications before becoming stable public
  contracts.
- Fine-tuning use cases use provider-neutral request, run-status, and artifact
  reference types. Adapter-specific configuration may extend those requests at
  the configuration boundary but cannot leak into application use cases.
- Configuration must be typed and validated at startup. Secrets are supplied
  through the environment or an approved secret mechanism and never committed.

## Acceptance criteria

- [ ] The repository contains the proposed `src/incident_diagnosis/` package
  layout, `tests/` tiers, `scripts/`, and `configs/` directories.
- [ ] A documented dependency-direction rule states that domain and application
  layers do not import infrastructure or interface layers.
- [ ] A minimal representative use case can run with an in-memory fake adapter
  in a unit test.
- [ ] A separate composition root can select that fake adapter versus a concrete
  infrastructure adapter without changing the use case.
- [ ] Inference and fine-tuning use cases can select either an OpenAI API
  adapter or a Hugging Face Qwen adapter through configuration without changing
  application-layer code.
- [ ] Offline contract tests prove that both provider adapters map the shared
  inference and fine-tuning lifecycle contracts to normalized application
  results, using fakes or recorded responses rather than live provider calls.
- [ ] Decorators can wrap either provider adapter without changing application
  use cases; unit tests cover telemetry, retry, and redaction behavior using
  fake ports.
- [ ] Test commands run the unit-test tier without requiring network access,
  credentials, a GPU, or external services.
- [ ] The architecture and developer documentation explain the package map,
  dependency direction, configuration, the pattern decision matrix, and how to
  add a new adapter or use case.
- [ ] Generated artifacts and secrets are excluded through version-control
  configuration and documented local paths.

## Implementation plan

1. Select the Python packaging, dependency, linting, typing, and testing tools
   based on the first planned executable component; record the decision.
2. Add the package, test, script, and configuration directory skeleton with
   minimal `__init__` files only where needed by the selected tooling.
3. Define a small vertical slice: one domain type, one port, one application
   use case, an in-memory adapter, OpenAI API and Hugging Face Qwen provider
   adapters for inference and fine-tuning, composable port decorators, and a
   composition root.
4. Add unit tests demonstrating port substitution and enforcing the dependency
   direction where feasible.
5. Add architecture and developer documentation, artifact exclusions, and
   canonical local/CI validation commands, including the pattern decision
   matrix and its explicit deferrals.
6. Update this specification with actual commands and verification evidence;
   mark it complete only after all criteria pass.

## Risks and open questions

- The packaging and dependency-tool choice is open. Candidate tools should be
  evaluated during implementation against reproducible GPU/ML dependency
  management and CI needs.
- The exact boundary between `domain` and `application` should remain light.
  Do not force deep domain modeling onto simple data transformations.
- Training workloads may eventually need a separate deployable package or job
  runner; start with shared application use cases and extract only when runtime
  needs diverge.
- A formal import-lint rule may be added after the initial package structure is
  established; it should not block the scaffold if the selected toolchain does
  not support it cleanly.

## Verification

The implementation specification must be verified with:

- the selected formatter, linter, and type checker;
- the full unit-test tier running offline;
- one test proving a use case accepts a fake port;
- configuration-level and offline contract tests proving inference and
  fine-tuning use cases can select OpenAI API and Hugging Face Qwen adapters
  without application-code changes;
- a review of the documented package map and dependency direction; and
- `git diff --check`.
