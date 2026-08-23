# AI Incident Diagnosis Model Lab

## Project Overview

The **AI Incident Diagnosis Model Lab** is an end-to-end LLM engineering
and ML infrastructure project designed to explore how modern language
models can be specialized, evaluated, and deployed for
**distributed-system incident diagnosis**.

The system takes structured observability data---such as distributed
traces, logs, metrics, service dependencies, and incident metadata---and
asks a model to identify the most likely root cause of an incident.

A typical task looks like:

``` text
Distributed traces + logs + metrics
                ↓
               Model
                ↓
{
  "root_cause": "database_latency",
  "affected_service": "postgres",
  "severity": "high",
  "confidence": 0.91,
  "explanation": "The PostgreSQL span accounts for most request latency."
}
```

The main purpose of the project is **not simply to build an incident
chatbot**. It is to create a controlled environment for learning and
comparing modern model customization techniques:

-   Open-weight model inference
-   Supervised Fine-Tuning (SFT)
-   LoRA and QLoRA
-   Direct Preference Optimization (DPO)
-   Reinforcement-learning-based fine-tuning
-   Proprietary fine-tuning APIs
-   Deterministic graders
-   LLM-as-a-judge graders
-   Evaluation-driven model development
-   Experiment tracking
-   GPU training
-   Model serving
-   ML observability
-   Distributed training concepts

The final system acts as a miniature **model development platform**
where different models and fine-tuning strategies can be trained and
compared against the same benchmark.

------------------------------------------------------------------------

# 1. Why Build This Project?

Modern LLM applications are often built entirely through prompting:

``` text
Prompt
  ↓
LLM API
  ↓
Response
```

That approach hides most of the actual machine-learning lifecycle.

This project goes deeper:

``` text
Dataset
   ↓
Base Model
   ↓
Baseline Evaluation
   ↓
Fine-Tuning
   ↓
Evaluation
   ↓
Experiment Comparison
   ↓
Deployment
   ↓
Production Monitoring
```

By completing the project, I learn how a model goes from a generic
pretrained model to a specialized production model.

The observability domain is particularly useful because many
incident-diagnosis tasks have **verifiable ground truth**. If an
incident is synthetically generated with a known database bottleneck,
the model's diagnosis can be automatically compared against the known
cause.

That makes the project well suited for:

-   supervised learning,
-   preference learning,
-   reinforcement learning,
-   automated grading,
-   benchmarking,
-   and model evaluation.

------------------------------------------------------------------------

# 2. Core Problem

The model receives observability information describing a distributed
application.

Example:

``` json
{
  "request": "POST /checkout",
  "total_latency_ms": 4500,
  "spans": [
    {
      "service": "checkout-service",
      "latency_ms": 4500
    },
    {
      "service": "postgres",
      "latency_ms": 4200
    },
    {
      "service": "redis",
      "latency_ms": 30
    }
  ]
}
```

The expected model output could be:

``` json
{
  "root_cause": "database_latency",
  "affected_service": "postgres",
  "severity": "high",
  "confidence": 0.96,
  "explanation": "PostgreSQL accounts for approximately 93% of total request latency."
}
```

The model must learn to distinguish incidents such as:

-   database latency,
-   slow downstream services,
-   connection-pool exhaustion,
-   cache failures,
-   cache-miss storms,
-   retry storms,
-   request timeouts,
-   Kafka consumer lag,
-   queue backlogs,
-   network latency,
-   service saturation,
-   elevated error rates,
-   cascading failures,
-   and healthy traffic.

------------------------------------------------------------------------

# 3. High-Level Architecture

``` text
                   ┌─────────────────────┐
                   │ Incident Generator  │
                   └──────────┬──────────┘
                              │
                              ▼
                     Synthetic Dataset
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
           Training        Validation         Test
              │
              ▼
         Base Models
              │
      ┌───────┴────────┐
      │                │
      ▼                ▼
Open-Weight Model   Proprietary API Model
      │                │
      ▼                ▼
SFT / LoRA / DPO    SFT / RFT if supported
      │                │
      └───────┬────────┘
              ▼
          Evaluation
              │
       ┌──────┼─────────┐
       ▼      ▼         ▼
 Accuracy   Graders   LLM Judge
       │      │         │
       └──────┼─────────┘
              ▼
       Experiment Tracking
              │
              ▼
        Model Deployment
              │
              ▼
       Inference Service
              │
              ▼
          Monitoring
```

------------------------------------------------------------------------

# 4. Phase 1 --- Build the Incident Dataset

## Goal

Create a controlled dataset where every incident has a known root cause.

Instead of depending entirely on real production incidents, generate
synthetic incidents programmatically.

Each generated example contains:

``` text
Incident
├── traces
├── logs
├── metrics
├── topology
├── expected root cause
├── affected service
├── severity
└── explanation/reference information
```

Example:

``` json
{
  "incident_id": "incident_00142",
  "trace": {
    "checkout_service_ms": 4500,
    "postgres_ms": 4200,
    "redis_ms": 30
  },
  "expected": {
    "root_cause": "database_latency",
    "service": "postgres",
    "severity": "high"
  }
}
```

## Dataset Split

A typical split might be:

``` text
70% Training
15% Validation
15% Test
```

The test set must remain isolated from training.

## Concepts Learned

### Training Set

Examples used to update model parameters.

### Validation Set

Examples used during experimentation to detect problems such as
overfitting and compare configurations.

### Test Set

Held-out examples used for final evaluation.

### Data Leakage

Understanding why training examples or near-duplicates must not leak
into evaluation data.

### Synthetic Data Generation

Learning how controlled synthetic examples can provide scalable training
data and reliable ground truth.

### Dataset Versioning

Track versions such as:

``` text
traces-v1
traces-v2
traces-v3
```

so every experiment can be reproduced.

------------------------------------------------------------------------

# 5. Phase 2 --- Establish Baseline Evaluations

Before fine-tuning anything, evaluate the base models.

Example:

  -----------------------------------------------------------------------
  Model           Root Cause        Service       Severity  JSON Validity
                    Accuracy       Accuracy       Accuracy 
  ----------- -------------- -------------- -------------- --------------
  Open Model             68%            74%            71%            91%
  Base                                                     

  API Model              82%            89%            84%            99%
  Base                                                     
  -----------------------------------------------------------------------

The exact numbers are produced by the experiment; the values above are
illustrative.

This baseline answers:

> Did fine-tuning actually improve the model?

Without a baseline, training loss alone does not prove that the
resulting model is better.

## Concepts Learned

-   benchmarking,
-   evaluation datasets,
-   task-specific metrics,
-   regression testing for models,
-   model comparison,
-   reproducibility,
-   and evaluation-driven development.

------------------------------------------------------------------------

# 6. Phase 3 --- Open-Weight Model Inference

Select a manageable open-weight model and run it locally or on GPU
infrastructure.

A common software stack is:

``` text
Application
     ↓
Hugging Face Transformers
     ↓
PyTorch
     ↓
CUDA
     ↓
GPU
```

## Concepts Learned

### Open-Weight Models

Models whose trained parameters are available for local use under their
respective licenses.

### Tokenization

Understanding how text becomes token IDs before being processed by a
transformer.

### Inference

Running a forward pass without updating model parameters.

### Logits

The raw values produced by the model before conversion into token
probabilities.

### Softmax

Converts logits into a probability distribution.

### Sampling

Learn concepts such as:

-   temperature,
-   top-k,
-   top-p,
-   greedy decoding,
-   and deterministic evaluation.

------------------------------------------------------------------------

# 7. Phase 4 --- Supervised Fine-Tuning

The first fine-tuning experiment uses **Supervised Fine-Tuning (SFT)**.

Training examples have the structure:

``` text
INPUT
  ↓
DESIRED OUTPUT
```

Example:

``` text
Input:
POST /checkout = 4500ms
PostgreSQL = 4200ms
Redis = 30ms

Desired Output:
{
  "root_cause": "database_latency",
  "service": "postgres"
}
```

The training loop conceptually becomes:

``` text
Training Batch
      ↓
Forward Pass
      ↓
Token Predictions
      ↓
Cross-Entropy Loss
      ↓
Backpropagation
      ↓
Gradients
      ↓
Optimizer
      ↓
Parameter Update
```

## Concepts Learned

### Forward Pass

Data flows through the neural network to generate predictions.

### Cross-Entropy Loss

Measures how much probability the model assigned to the desired tokens.

For a correct token with probability (p):

``` text
Loss = -log(p)
```

Higher probability for the correct token produces lower loss.

### Backpropagation

Calculates how the loss changes with respect to each trainable
parameter.

Conceptually:

``` text
∂Loss / ∂Weight
```

### Gradient

Describes the direction and magnitude in which a parameter affects the
loss.

### Optimizer

Uses gradients to update model parameters.

A common optimizer is AdamW.

Conceptually:

``` text
new_weight = old_weight - learning_rate × gradient
```

### Learning Rate

Controls how aggressively parameters change during training.

### Epoch

One complete pass through the training dataset.

### Batch

A subset of training examples processed together.

### Gradient Accumulation

Accumulates gradients across several smaller batches before an optimizer
step, helping when GPU memory is limited.

------------------------------------------------------------------------

# 8. Phase 5 --- LoRA

Full fine-tuning modifies all trainable parameters in a model.

For a model with billions of parameters, this can require substantial
GPU memory.

**LoRA --- Low-Rank Adaptation --- reduces this requirement.**

Instead of changing the original weight matrix:

``` text
W
```

LoRA freezes it and learns a smaller update:

``` text
W' = W + ΔW
```

where:

``` text
ΔW = B × A
```

and A and B are relatively small matrices.

Conceptually:

``` text
Large Base Model
      │
      ├── Original Weights → FROZEN
      │
      └── LoRA Adapters → TRAINABLE
```

## Why LoRA Matters

It allows large models to be specialized while training only a small
fraction of the parameters.

Benefits can include:

-   lower GPU-memory requirements,
-   smaller training artifacts,
-   faster experiments,
-   easier storage of multiple specialized adapters,
-   and reduced training cost.

## Concepts Learned

-   parameter-efficient fine-tuning,
-   frozen parameters,
-   trainable parameters,
-   low-rank matrix decomposition,
-   adapter layers,
-   LoRA rank,
-   target modules,
-   and memory-efficient training.

------------------------------------------------------------------------

# 9. Phase 6 --- QLoRA

QLoRA combines:

``` text
Quantization
     +
LoRA
```

The base model is stored at lower numerical precision while LoRA
adapters remain trainable.

Conceptually:

``` text
Quantized Base Model
       ↓
     FROZEN

        +

LoRA Adapters
       ↓
    TRAINABLE
```

## Concepts Learned

### Quantization

Representing model parameters using fewer bits.

Examples include:

``` text
FP32
FP16 / BF16
INT8
4-bit
```

### GPU Memory Optimization

Understanding why parameter precision has a major impact on VRAM
consumption.

### Precision Tradeoffs

Exploring the relationship among:

-   memory,
-   speed,
-   numerical precision,
-   and model quality.

------------------------------------------------------------------------

# 10. Phase 7 --- Preference Dataset

Generate multiple responses to the same incident.

Example:

``` text
Incident
   │
   ├── Response A
   │
   └── Response B
```

An evaluator determines:

``` text
A > B
```

The resulting data looks conceptually like:

``` json
{
  "prompt": "...",
  "chosen": "PostgreSQL is the bottleneck because...",
  "rejected": "The system appears slow..."
}
```

This creates a **preference dataset**.

------------------------------------------------------------------------

# 11. Phase 8 --- Direct Preference Optimization

**DPO --- Direct Preference Optimization --- teaches the model to prefer
better responses over worse responses.**

Instead of:

``` text
Prompt → Exact Desired Response
```

the training signal becomes:

``` text
Prompt
  ↓
Chosen Response > Rejected Response
```

DPO is useful when there may be several reasonable responses but some
are clearly better than others.

## Concepts Learned

-   preference optimization,
-   chosen vs. rejected responses,
-   ranking behavior,
-   preference datasets,
-   alignment/post-training,
-   and reference-model concepts.

## SFT vs. DPO

``` text
SFT
"Produce responses like this."

DPO
"Prefer response A over response B."
```

------------------------------------------------------------------------

# 12. Phase 9 --- Build a Grading System

A major component of the project is a reusable grader.

Conceptually:

``` text
G(problem, response, reference) → reward
```

For example:

``` text
0.0 = completely incorrect
1.0 = excellent
```

A composite reward could be:

``` text
Reward =
    0.50 × root_cause_score
  + 0.20 × service_score
  + 0.10 × severity_score
  + 0.10 × evidence_score
  + 0.10 × format_score
```

------------------------------------------------------------------------

# 13. Deterministic Graders

Some properties can be evaluated programmatically.

Example:

``` python
def grade_root_cause(response, expected):
    return 1.0 if response["root_cause"] == expected["root_cause"] else 0.0
```

Other deterministic graders could check:

-   correct service,
-   correct incident category,
-   valid JSON,
-   schema compliance,
-   severity,
-   numeric calculations,
-   and required fields.

## Concepts Learned

-   deterministic evaluation,
-   exact-match metrics,
-   structured-output validation,
-   partial credit,
-   reward shaping,
-   and automated verification.

------------------------------------------------------------------------

# 14. LLM-as-a-Judge

Some properties are difficult to evaluate with deterministic code.

For example:

> Is the explanation well-supported by the supplied evidence?

A separate LLM can act as a judge:

``` text
Original Incident
       +
Reference Information
       +
Candidate Response
       +
Grading Rubric
       ↓
    Judge LLM
       ↓
      Score
```

Example rubric:

``` text
Root-cause reasoning:     40%
Evidence quality:         30%
Unsupported claims:       20%
Clarity:                  10%
```

## Concepts Learned

-   model-based evaluation,
-   evaluation rubrics,
-   judge-model bias,
-   evaluator reliability,
-   inter-grader agreement,
-   and combining deterministic and model-based graders.

------------------------------------------------------------------------

# 15. Composite Graders

Multiple graders can be combined:

``` text
                 Candidate Response
                        │
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
 Root Cause Grader   Schema Grader   LLM Judge
        │               │               │
       1.0             1.0             0.8
        │               │               │
        └───────────────┼───────────────┘
                        ↓
                  Final Reward
```

This teaches an important ML principle:

> The reward function defines what behavior the training process is
> encouraged to optimize.

------------------------------------------------------------------------

# 16. Reward Hacking

A poorly designed grader can accidentally reward undesirable behavior.

Suppose the grader only checks whether the correct service name appears.

A model could produce:

``` text
postgres postgres postgres postgres
```

and potentially receive a high reward despite producing a useless
answer.

This is **reward hacking**.

The project therefore explores:

-   robust reward design,
-   adversarial grader testing,
-   held-out evaluation,
-   grader gaming,
-   and proxy metrics vs. true objectives.

------------------------------------------------------------------------

# 17. Phase 10 --- Reinforcement Fine-Tuning

After building reliable graders, experiment with
reinforcement-learning-based model training.

Conceptually:

``` text
Prompt
  ↓
Model
  ↓
Candidate Response
  ↓
Grader
  ↓
Reward
  ↓
RL Training Algorithm
  ↓
Update Model
```

Unlike SFT:

``` text
Prompt → Correct Answer
```

reinforcement learning says:

``` text
Try something
      ↓
Receive reward
      ↓
Learn to maximize expected reward
```

## Concepts Learned

-   reinforcement learning,
-   policies,
-   actions,
-   rewards,
-   rollouts,
-   reward functions,
-   policy optimization,
-   exploration,
-   exploitation,
-   and RL-based LLM post-training.

Later experiments can investigate algorithms such as PPO or GRPO
depending on the selected framework.

------------------------------------------------------------------------

# 18. Phase 11 --- Proprietary API Fine-Tuning

Run a comparable experiment using a proprietary model provider that
supports fine-tuning.

The workflow is different:

``` text
Dataset
   ↓
Provider Fine-Tuning API
   ↓
Provider Training Infrastructure
   ↓
Fine-Tuned Model Identifier
   ↓
API Inference
```

The provider handles:

-   GPU infrastructure,
-   model weights,
-   backpropagation,
-   optimization,
-   checkpoints,
-   and model hosting.

I remain responsible for:

-   dataset quality,
-   task design,
-   grader design where applicable,
-   evaluation,
-   experiment comparison,
-   and production integration.

------------------------------------------------------------------------

# 19. Open-Weight vs. Proprietary Fine-Tuning

The project directly compares both approaches.

  Area                     Open-Weight   Proprietary API
  ------------------------ ------------- ---------------------
  Weight access            Yes           No
  Training loop control    High          Limited
  LoRA control             Yes           Provider-dependent
  Custom objectives        High          Provider-dependent
  Infrastructure           I manage it   Provider manages it
  Deployment               I manage it   Usually API
  Experiment flexibility   High          Platform-dependent
  Operational complexity   Higher        Lower

This provides practical experience deciding when a company should build
on an open-weight model versus a managed API.

------------------------------------------------------------------------

# 20. Phase 12 --- Experiment Tracking

Every training run should be treated as an experiment.

Example metadata:

``` text
Experiment ID:       exp-027
Base Model:          model-x
Dataset:             traces-v4
Training Method:     SFT
Parameter Method:    LoRA
LoRA Rank:           16
Learning Rate:       ...
Batch Size:          ...
Epochs:              3
Seed:                ...
```

Then store evaluation results:

``` text
Root Cause Accuracy: 89.2%
Service Accuracy:    94.1%
Severity Accuracy:   86.3%
JSON Validity:       99.8%
```

## Concepts Learned

-   experiment tracking,
-   hyperparameter management,
-   reproducibility,
-   checkpoint management,
-   dataset lineage,
-   model lineage,
-   and ML metadata.

------------------------------------------------------------------------

# 21. Model Leaderboard

Create a dashboard comparing experiments.

  Experiment   Model        Method                Root Cause Accuracy
  ------------ ------------ ------------------- ---------------------
  #1           Open Base    None                                  68%
  #2           Open Model   SFT + LoRA                            79%
  #3           Open Model   SFT + QLoRA                           81%
  #4           Open Model   SFT + DPO                             84%
  #5           API Model    Provider FT                           TBD
  #6           API Model    RFT, if supported                     TBD

This makes model development measurable rather than subjective.

------------------------------------------------------------------------

# 22. Phase 13 --- Model Serving

After training, deploy the best open-weight model behind an inference
service.

Possible architecture:

``` text
Client
   ↓
API Gateway
   ↓
Inference API
   ↓
Model Server
   ↓
GPU
```

Potential serving technologies can be evaluated later based on model
compatibility and project requirements.

## Concepts Learned

-   inference servers,
-   batching,
-   throughput,
-   latency,
-   GPU utilization,
-   model loading,
-   quantized inference,
-   concurrency,
-   and API design.

------------------------------------------------------------------------

# 23. Phase 14 --- ML Observability

Monitor the model itself.

Possible metrics:

``` text
Request latency
Tokens/sec
GPU utilization
GPU memory
Queue depth
Batch size
Error rate
Output validity
Root-cause accuracy
Reward score
Judge score
```

This creates a useful recursive aspect:

> An observability model is itself being observed.

## Concepts Learned

-   ML observability,
-   inference telemetry,
-   model quality monitoring,
-   drift,
-   latency monitoring,
-   GPU metrics,
-   and production evaluation.

------------------------------------------------------------------------

# 24. Phase 15 --- Distributed Training

After learning single-GPU fine-tuning, explore multi-GPU training.

``` text
                  Training Job
                       │
         ┌─────────────┼─────────────┐
         ↓             ↓             ↓
       GPU 0         GPU 1         GPU 2
         │             │             │
         └─────────────┼─────────────┘
                       ↓
                 Synchronization
```

At larger scale:

``` text
Node 1                       Node 2

GPU GPU GPU GPU              GPU GPU GPU GPU
 │   │   │   │                │   │   │   │
 └───┴───┴───┴────────────────┴───┴───┴───┘
                         ↓
                Distributed Training
```

Topics to investigate include:

-   PyTorch Distributed,
-   Distributed Data Parallel,
-   FSDP,
-   DeepSpeed,
-   data parallelism,
-   tensor parallelism,
-   pipeline parallelism,
-   gradient synchronization,
-   communication overhead,
-   NCCL,
-   and distributed checkpointing.

This phase moves the project from LLM application engineering toward
**ML infrastructure engineering**.

------------------------------------------------------------------------

# 25. Suggested Technology Stack

## Model Training

``` text
Python
PyTorch
Hugging Face Transformers
Hugging Face Datasets
PEFT
TRL
```

Optional higher-level training tooling:

``` text
Axolotl
```

## Fine-Tuning

``` text
SFT
LoRA
QLoRA
DPO
RL-based post-training
```

## Evaluation

``` text
Python
Pydantic / JSON Schema
Deterministic graders
LLM-as-a-judge
Custom evaluation harness
```

## Experiment Tracking

A dedicated experiment tracker can be selected during implementation, or
a lightweight internal system can initially store:

``` text
PostgreSQL
+
object storage
+
experiment metadata
```

## Backend

Possible choices:

``` text
FastAPI
or
another lightweight inference/control API
```

## Frontend

Possible stack:

``` text
React
TypeScript
```

## Infrastructure

As the project grows:

``` text
Docker
GPU runtime
Kubernetes
Object Storage
PostgreSQL
Prometheus
Grafana
```

------------------------------------------------------------------------

# 26. Important Concept: Objective vs. Parameter Strategy

One of the most important distinctions learned in this project is:

``` text
SFT / DPO / RL
```

answer:

> **What training signal tells the model how to improve?**

while:

``` text
Full Fine-Tuning / LoRA / QLoRA
```

answer:

> **Which parameters are being updated, and how are they represented?**

Therefore combinations are possible:

``` text
SFT + LoRA
SFT + QLoRA
DPO + LoRA
DPO + QLoRA
RL + LoRA
Full SFT
```

These terms are not all competing alternatives.

------------------------------------------------------------------------

# 27. Important Concept: Fine-Tuning Is Machine Learning

Fine-tuning is fundamentally ordinary neural-network training applied to
an already pretrained model.

``` text
Data
 ↓
Model
 ↓
Prediction
 ↓
Loss
 ↓
Backpropagation
 ↓
Gradients
 ↓
Optimizer
 ↓
Parameter Update
```

The major difference from training from scratch is the starting point:

``` text
Training From Scratch

Random Parameters
      ↓
Huge Dataset
      ↓
Training
      ↓
Model
```

versus:

``` text
Fine-Tuning

Pretrained Model
      ↓
Specialized Dataset
      ↓
Additional Training
      ↓
Specialized Model
```

Fine-tuning is therefore closely related to **transfer learning**.

------------------------------------------------------------------------

# 28. Important Concept: Fine-Tuning vs. RAG vs. Prompting

These solve different problems.

## Prompt Engineering

Changes the instructions supplied to the model.

``` text
Model weights: unchanged
Input prompt: changed
```

## RAG

Supplies external information at inference time.

``` text
Query
 ↓
Retrieve Knowledge
 ↓
Add Context
 ↓
LLM
```

Model weights remain unchanged.

## Fine-Tuning

Changes model behavior by training parameters.

``` text
Training Data
 ↓
Backpropagation
 ↓
Parameter Updates
```

A useful heuristic is:

``` text
Need better instructions?
        ↓
Prompt engineering

Need current/private knowledge?
        ↓
RAG / tools

Need specialized learned behavior?
        ↓
Fine-tuning

Need multi-step interaction with systems?
        ↓
Agent / compound system
```

Real systems frequently combine all four.

------------------------------------------------------------------------

# 29. Important Concept: Compound AI Systems

A production AI system does not have to rely on one model call.

Example:

``` text
Telemetry
    ↓
Filtering / Aggregation
    ↓
Anomaly Detection
    ↓
Specialized Model
    ↓
Retrieval
    ↓
Incident Agent
    ↓
Verification
    ↓
Final Diagnosis
```

The system may contain:

-   LLMs,
-   fine-tuned models,
-   traditional software,
-   databases,
-   retrieval systems,
-   deterministic algorithms,
-   statistical models,
-   tools,
-   APIs,
-   and multiple agents.

This teaches the distinction between **improving the model** and
**improving the system around the model**.

------------------------------------------------------------------------

# 30. Important Concept: Harness Engineering

Instead of modifying model weights, improve the environment surrounding
the model.

The harness can contain:

``` text
Prompts
Tools
Retrieval
Memory
Context selection
Subagents
Workflow logic
Verification
Retry strategies
```

Then evaluate each version:

``` text
Harness V1 → 64%
Harness V2 → 70%
Harness V3 → 76%
Harness V4 → 82%
```

This creates another optimization problem:

``` text
Model Optimization
        +
Harness Optimization
```

The project can eventually compare whether a performance improvement
came from:

-   better data,
-   better fine-tuning,
-   a better grader,
-   better prompting,
-   better retrieval,
-   or a better agent harness.

------------------------------------------------------------------------

# 31. Core ML Concepts Learned

By completing the project, I gain practical experience with:

### Neural Networks

-   parameters,
-   weights,
-   forward passes,
-   logits,
-   softmax,
-   loss functions,
-   gradients,
-   backpropagation,
-   optimizers,
-   learning rates,
-   batches,
-   epochs.

### Transformer / LLM Concepts

-   tokenization,
-   embeddings,
-   attention,
-   transformer layers,
-   autoregressive generation,
-   context windows,
-   next-token prediction,
-   decoding strategies.

### Fine-Tuning

-   SFT,
-   full fine-tuning,
-   LoRA,
-   QLoRA,
-   PEFT,
-   DPO,
-   preference data,
-   reinforcement learning,
-   reward functions.

### Evaluation

-   train/validation/test splits,
-   deterministic graders,
-   LLM-as-a-judge,
-   composite graders,
-   reward hacking,
-   held-out evaluation,
-   regression evaluation,
-   model benchmarking.

### ML Infrastructure

-   GPUs,
-   CUDA,
-   GPU memory,
-   quantization,
-   mixed precision,
-   distributed training,
-   model checkpoints,
-   model serving,
-   inference optimization,
-   experiment tracking.

------------------------------------------------------------------------

# 32. Engineering Concepts Learned

The project also develops general software and distributed-systems
skills.

### Data Engineering

-   synthetic dataset generation,
-   schema design,
-   dataset validation,
-   dataset versioning,
-   data pipelines.

### Backend Engineering

-   inference APIs,
-   asynchronous jobs,
-   training job management,
-   queues,
-   model registry concepts.

### Distributed Systems

-   distributed training,
-   GPU workers,
-   synchronization,
-   fault tolerance,
-   queues,
-   job orchestration.

### Observability

-   distributed tracing,
-   metrics,
-   logs,
-   service dependencies,
-   root-cause analysis,
-   telemetry pipelines.

### Infrastructure

-   containers,
-   GPU workloads,
-   Kubernetes,
-   monitoring,
-   artifact storage.

------------------------------------------------------------------------

# 33. Recommended Implementation Order

Avoid attempting every technique immediately.

## Milestone 1 --- Dataset

Build:

``` text
Synthetic Incident Generator
        ↓
Training / Validation / Test datasets
```

Learn:

-   dataset design,
-   ground truth,
-   schemas,
-   evaluation splits.

## Milestone 2 --- Baseline

Evaluate:

``` text
Open-weight base model
API base model
```

Learn:

-   inference,
-   prompting,
-   metrics,
-   evaluation.

## Milestone 3 --- First Fine-Tune

Implement:

``` text
SFT + LoRA
```

Learn:

-   PyTorch,
-   Transformers,
-   PEFT,
-   training loops,
-   loss,
-   gradients.

## Milestone 4 --- QLoRA

Compare:

``` text
LoRA
vs.
QLoRA
```

Learn:

-   quantization,
-   GPU memory optimization.

## Milestone 5 --- Preference Optimization

Implement:

``` text
SFT model
   ↓
Preference Dataset
   ↓
DPO
```

Learn:

-   preference learning,
-   alignment.

## Milestone 6 --- Graders

Build:

``` text
Deterministic Grader
+
LLM Judge
+
Composite Reward
```

Learn:

-   eval engineering,
-   reward design.

## Milestone 7 --- Reinforcement Fine-Tuning

Use the grader as a reward signal.

Learn:

-   rollouts,
-   rewards,
-   policy optimization,
-   RL post-training.

## Milestone 8 --- Proprietary Fine-Tuning

Repeat comparable experiments using a provider-supported fine-tuning
API.

Learn:

-   managed fine-tuning,
-   API model lifecycle,
-   open vs. proprietary tradeoffs.

## Milestone 9 --- Experiment Dashboard

Build:

``` text
Experiment Tracking
+
Leaderboard
+
Training Curves
+
Evaluation Reports
```

Learn:

-   model lifecycle management,
-   reproducibility.

## Milestone 10 --- Deployment

Deploy the best model.

Learn:

-   inference serving,
-   GPU deployment,
-   batching,
-   latency,
-   throughput.

## Milestone 11 --- Distributed Training

Scale beyond one GPU.

Learn:

-   PyTorch Distributed,
-   FSDP,
-   DeepSpeed,
-   communication overhead,
-   distributed ML systems.

------------------------------------------------------------------------

# 34. Example Final Experiment

A final comparison could look like:

``` text
Dataset: traces-v5
Test examples: 2,000

┌───────────────────────┬────────────┐
│ Model                 │ Accuracy   │
├───────────────────────┼────────────┤
│ Open Base             │ 68.4%      │
│ SFT + LoRA            │ 80.7%      │
│ SFT + QLoRA           │ 81.2%      │
│ SFT + DPO             │ 84.6%      │
│ RL Variant            │ 87.1%      │
│ API Base              │ 83.2%      │
│ API Fine-Tuned        │ 89.0%      │
└───────────────────────┴────────────┘
```

These numbers would be actual experiment results rather than
predetermined targets.

The goal is to explain **why** each result occurred.

Questions to investigate include:

-   Did SFT improve task accuracy?
-   Did LoRA perform similarly to full fine-tuning?
-   Did quantization affect quality?
-   Did DPO improve explanations without improving classification?
-   Did RL optimize the grader but hurt held-out performance?
-   Did the LLM judge agree with deterministic metrics?
-   Did a better harness outperform additional fine-tuning?
-   Was the proprietary model worth the additional API cost?
-   How did latency differ?
-   How much GPU memory did each approach require?

------------------------------------------------------------------------

# 35. What Success Looks Like

The project is successful when I can confidently explain and
demonstrate:

1.  How pretrained LLMs perform inference.
2.  How SFT changes model behavior.
3.  How cross-entropy loss and backpropagation train a model.
4.  Why LoRA reduces fine-tuning requirements.
5.  How QLoRA combines quantization with parameter-efficient training.
6.  How DPO learns from preferences.
7.  How reinforcement learning learns from rewards.
8.  How graders turn model behavior into measurable scores.
9.  Why reward hacking occurs.
10. How to evaluate a model correctly.
11. How open-weight fine-tuning differs from proprietary API
    fine-tuning.
12. How to track and reproduce ML experiments.
13. How to serve a fine-tuned model.
14. How GPU constraints affect training and inference.
15. How distributed training scales model development.
16. How fine-tuning differs from RAG and prompt engineering.
17. How compound AI systems combine models with traditional software.
18. How harness engineering can improve model performance without
    changing model weights.

------------------------------------------------------------------------

# 36. Final Perspective

This project progresses through several layers of AI engineering:

``` text
             LLM APPLICATION ENGINEERING
                       │
                       ▼
                 Model Inference
                       │
                       ▼
                  Evaluation
                       │
                       ▼
                  Fine-Tuning
                       │
                       ▼
                Post-Training
                       │
                       ▼
                 ML Engineering
                       │
                       ▼
               Model Deployment
                       │
                       ▼
              ML Infrastructure
                       │
                       ▼
             Distributed ML Systems
```

Rather than learning SFT, LoRA, DPO, RL, graders, model serving, and
distributed training as disconnected concepts, the **AI Incident
Diagnosis Model Lab** provides one coherent system in which each
technique solves a concrete problem.

The most important principle throughout the project is:

> **Do not fine-tune merely because fine-tuning is available. Measure
> the baseline, identify the failure mode, choose the appropriate
> intervention, and prove through held-out evaluation that the
> intervention improved the system.**

That principle applies equally to open-weight models, proprietary
models, agent systems, and production ML infrastructure.
