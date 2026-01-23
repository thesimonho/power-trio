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
| `MAX_PLANNING_ITERATIONS` | 3     | Maximum rounds of plan revision before escalating to user (expected convergence: 1-3 iters) |
| `MAX_BLOCKS_PER_AGENT`    | 3     | Blocks before escalating concern to documented risk                                         |
| `MAX_OPEN_QUESTIONS`      | 2     | Maximum accepted open questions at completion (prefer 0, accept 1-2 if documented as risk)  |

### Phase 2: Building

| Parameter                   | Value | Description                                                 |
| --------------------------- | ----- | ----------------------------------------------------------- |
| `MAX_TEST_ITERATIONS`       | 2     | Maximum rounds of test revision                             |
| `MAX_IMPL_ITERATIONS`       | 3     | Maximum rounds of implementation revision                   |
| `MAX_TEST_FIX_ATTEMPTS`     | 2     | Maximum attempts to fix failing tests                       |
| `MAX_BLOCKS_PER_AGENT`      | 3     | Blocks before escalating concern to documented risk         |
| `EXPECTED_TEST_CONVERGENCE` | 2     | Expected maximum test iterations for normal cases           |
| `EXPECTED_IMPL_CONVERGENCE` | 3     | Expected maximum implementation iterations for normal cases |

### Phase 3: Reviewing

| Parameter          | Value | Description                                       |
| ------------------ | ----- | ------------------------------------------------- |
| `MAX_PHASE2_LOOPS` | 2     | Maximum Phase 2↔3 loops before escalating to user |

---

## Phase 3 Trigger Thresholds

| Parameter                 | Value | Description                             |
| ------------------------- | ----- | --------------------------------------- |
| `FILES_CHANGED_THRESHOLD` | 5     | Trigger Phase 3 if files changed ≥ this |
| `LOC_CHANGED_THRESHOLD`   | 300   | Trigger Phase 3 if LOC changed ≥ this   |

---

## Phase 3 Optimization Parameters

### Risk Triage Thresholds

| Parameter     | Value    | Description                                      |
| ------------- | -------- | ------------------------------------------------ |
| `RISK_NONE`   | "NONE"   | No risk detected - skip specialist               |
| `RISK_LOW`    | "LOW"    | Low risk - run specialist with minimal scope     |
| `RISK_MEDIUM` | "MEDIUM" | Medium risk - run specialist with standard scope |
| `RISK_HIGH`   | "HIGH"   | High risk - run specialist with full scope       |

### File Scope Limits

| Parameter                  | Value | Description                              |
| -------------------------- | ----- | ---------------------------------------- |
| `MAX_FILES_PER_SPECIALIST` | 5     | Maximum files to pass to each specialist |

### Specialist Output Hard Caps

| Severity                | Max Count | Description                              |
| ----------------------- | --------- | ---------------------------------------- |
| `MAX_CRITICAL_FINDINGS` | 2         | Maximum CRITICAL findings per specialist |
| `MAX_HIGH_FINDINGS`     | 1         | Maximum HIGH findings per specialist     |
| `MAX_MEDIUM_FINDINGS`   | 1         | Maximum MEDIUM findings per specialist   |
| `MAX_LOW_FINDINGS`      | 1         | Maximum LOW findings per specialist      |

### Security Specialist Model Selection

| Condition       | Model  | Description                          |
| --------------- | ------ | ------------------------------------ |
| Default         | sonnet | Standard security review model       |
| High-risk areas | opus   | Escalate to opus for sensitive areas |

**High-risk areas triggering opus:**

- Authentication / authorization
- Cryptography
- Secrets management
- Multi-tenant or trust boundaries
