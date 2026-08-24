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
  for configurable model or provider construction, and strategy objects for
  interchangeable grading or training approaches.
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
- Use strategies for replaceable algorithms such as deterministic versus
  LLM-judge grading, sampling, or training methods. Do not create interfaces
  for one-off logic.
- Add top-level directories for `tests/`, `scripts/`, and `configs/`.
  Organize tests as `tests/unit/`, `tests/integration/`, and `tests/e2e/`,
  mirroring the package where helpful.
- Add package and test configuration using a single supported Python project
  configuration file. The implementation task will select the dependency and
  test tools appropriate to the first runnable component.
- Include a short architecture document and a root-level development command
  reference when the scaffold is implemented.

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
| `infrastructure` | File, OpenAI/open-weight model, tracking, and telemetry integrations. | Adapter, factory |
| `interfaces` | FastAPI routes, CLI commands, scheduled/training job entrypoints. | Controller/command, composition root |
| `shared` | Typed configuration, error types, and strictly generic helpers. | Options/settings |

## Interfaces and data contracts

- Domain types should own canonical incident input and diagnosis result
  contracts. Transport schemas (for example, HTTP request/response models) must
  translate at the interface boundary instead of becoming domain entities.
- Dataset serialization formats, model-prompt formats, and evaluator report
  schemas require their own future specifications before becoming stable public
  contracts.
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
- [ ] Test commands run the unit-test tier without requiring network access,
  credentials, a GPU, or external services.
- [ ] The architecture and developer documentation explain the package map,
  dependency direction, configuration, and how to add a new adapter or use
  case.
- [ ] Generated artifacts and secrets are excluded through version-control
  configuration and documented local paths.

## Implementation plan

1. Select the Python packaging, dependency, linting, typing, and testing tools
   based on the first planned executable component; record the decision.
2. Add the package, test, script, and configuration directory skeleton with
   minimal `__init__` files only where needed by the selected tooling.
3. Define a small vertical slice: one domain type, one port, one application
   use case, an in-memory adapter, and a composition root.
4. Add unit tests demonstrating port substitution and enforcing the dependency
   direction where feasible.
5. Add architecture and developer documentation, artifact exclusions, and
   canonical local/CI validation commands.
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
- a review of the documented package map and dependency direction; and
- `git diff --check`.
