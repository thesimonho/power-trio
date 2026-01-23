---
user-invocable: false
---

# Configuration and Parameter Values

Centralized configuration for the Power Trio workflow. Reference this file for consistent settings. These values must be adhered to.

---

## Iteration Limits

### Phase 1: Planning

| Parameter                 | Value | Description                                                                                 |
| ------------------------- | ----- | ------------------------------------------------------------------------------------------- |
| `MAX_PLANNING_ITERATIONS` | 5     | Maximum rounds of plan revision before escalating to user (expected convergence: 1-3 iters) |
| `MAX_BLOCKS_PER_AGENT`    | 3     | Blocks before escalating concern to documented risk                                         |
| `MAX_OPEN_QUESTIONS`      | 2     | Maximum accepted open questions at completion (prefer 0, accept 1-2 if documented as risk)  |

### Phase 2: Building

| Parameter               | Value | Description                                         |
| ----------------------- | ----- | --------------------------------------------------- |
| `MAX_TEST_ITERATIONS`   | 5     | Maximum rounds of test revision                     |
| `MAX_IMPL_ITERATIONS`   | 10    | Maximum rounds of implementation revision           |
| `MAX_TEST_FIX_ATTEMPTS` | 5     | Maximum attempts to fix failing tests               |
| `MAX_BLOCKS_PER_AGENT`  | 3     | Blocks before escalating concern to documented risk |

### Phase 3: Refining

| Parameter          | Value | Description                                       |
| ------------------ | ----- | ------------------------------------------------- |
| `MAX_PHASE2_LOOPS` | 3     | Maximum Phase 2↔3 loops before escalating to user |

---

## Phase 3 Trigger Thresholds

| Parameter                 | Value | Description                             |
| ------------------------- | ----- | --------------------------------------- |
| `FILES_CHANGED_THRESHOLD` | 5     | Trigger Phase 3 if files changed ≥ this |
| `LOC_CHANGED_THRESHOLD`   | 300   | Trigger Phase 3 if LOC changed ≥ this   |
