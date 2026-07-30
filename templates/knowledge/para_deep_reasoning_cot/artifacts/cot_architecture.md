# Deep Reasoning (CoT) Architecture & Memory System

> **System KI:** `para_deep_reasoning_cot`
> **Version:** `1.9.6.1`
> **Owner:** `para`

## Executive Summary

The Deep Reasoning Chain-of-Thought (CoT) system establishes a standardized 4-phase reasoning protocol, a 5-dimension quality scoring matrix, and a 3-tier session context memory model across PARA Workspace and `para-graph` MCP server (`v0.17.7+`).

## 1. The 4-Phase CoT Execution Cycle

1. **Phase 1: Deep Problem Decomposition (`<thought>`)**
   - Break complex technical problems into explicit sub-components.
   - Map domain constraints, API interfaces, and system edge-cases.
2. **Phase 2: Multidimensional Hypothesis Testing**
   - Evaluate trade-offs across 5D dimensions: Correctness, Scalability, Safety, Maintainability, Performance.
   - Score alternative technical choices (1-5 scale per dimension).
3. **Phase 3: Convergent Plan Synthesis**
   - Select the optimal technical path.
   - Establish explicit harness guards and verification checkpoints.
4. **Phase 4: Structured Execution & Memory Push**
   - Execute code changes or system configurations.
   - Persist critical architectural decisions into `para-graph` memory via `memory_push` (`kind: "cot-decision"`).

## 2. 3-Tier Memory & CoT Persistence Model

| Tier | Component | Lifecycle | Purpose |
|:---|:---|:---|:---|
| **Tier 1** | Runtime Reasoning (`language.thinking`) | Session ephemeral | High-density thinking steps in user's preferred language. |
| **Tier 2** | Session Memory (`session.md`) | Session compacted | JIT context recovery compiling rules, contract, and active plan phase. |
| **Tier 3** | Code-Knowledge Graph (`para-graph`) | Durable project store | Persistent CoT metadata (`CotMetadata`) and decision nodes (`kind: "cot-decision"`). |

## 3. Tool Routing & MCP Graph Integration

- **Tool Routing Priority:** `MCP (Domain-Specific) > Native API > Bash` (per `.agents/rules/tool-routing.md`).
- **Graph Reasoning Tools:**
  - `graph_impact_analysis`: Traverses upstream/downstream dependencies before major structural edits.
  - `graph_context_bundle`: Retrieves complete entity context, callsites, and specs in 1 tool call.
  - `memory_push`: Persists CoT decision nodes with structured `CotMetadata` (depth, scoring, triggers).
