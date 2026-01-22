# Trio Command

Execute the complete Power Trio workflow: Plan → Build → Refine.

---

## Configuration

**See [PARAMETERS.md](../PARAMETERS.md) for all configurable values.**

Key parameters:

- Phase 1: `MAX_PLANNING_ITERATIONS`, `MAX_BLOCKS_PER_AGENT`
- Phase 2: `MAX_TEST_ITERATIONS`, `MAX_IMPL_ITERATIONS`, `MAX_TEST_FIX_ATTEMPTS`
- Phase 3: `MAX_PHASE2_LOOPS`
- Triggers: `FILES_CHANGED_THRESHOLD`, `LOC_CHANGED_THRESHOLD`

---

You are orchestrating the **complete Power Trio workflow**. This combines all three phases with intelligent Phase 3 triggering and Phase 2↔3 looping for blocking issues.

## Task

Execute full workflow for: **$ARGUMENTS**

If no arguments provided, ask the user what they want to build.

## Workflow Overview

```
Phase 1: Planning ──→ Phase 2: Building ──→ [Phase 3: Refining]
    │                      │                        │
    ▼                      ▼                        ▼
plan.report.md      implementation.report.md   release.report.md
                           │                        │
                           └────────────────────────┘
                              (loop if BLOCKED)
```

## Orchestration Protocol

### Setup

Create output directory:

```
Bash(command="mkdir -p .power-trio")
```

Initialize state:

```
phase: 1
phase2_loops: 0
blocking_issues: []
```

## Create a TODO list to keep user informed of progress

---

## PHASE 1: Planning

Execute the trio-plan workflow inline:

1. Invoke `power-trio:planner` to create initial plan
2. Invoke `power-trio:architect` to provide domain expertise and feedback on the plan
3. Invoke `power-trio:critic` to challenge assumptions and identify risks
4. Collect votes, iterate until consensus (max `MAX_PLANNING_ITERATIONS` iterations)
5. Write `.power-trio/plan.report.md`

**See trio-plan.md for detailed orchestration steps.**

After Phase 1 completes, announce:

```
PHASE 1 COMPLETE: Planning

Consensus reached. Plan approved by all committee members.
Artifact: .power-trio/plan.report.md

Proceeding to Phase 2: Building...
```

---

## PHASE 2: Building

Execute the trio-build workflow inline:

1. Invoke `power-trio:test-author` to write tests
2. Invoke `power-trio:senior-engineer` to review tests
3. Iterate tests until approved (max `MAX_TEST_ITERATIONS` iterations)
4. Invoke `power-trio:engineer` to implement
5. Run tests, fix until passing (max `MAX_TEST_FIX_ATTEMPTS` attempts)
6. Invoke `power-trio:senior-engineer` to review implementation
7. Iterate implementation until approved (max `MAX_IMPL_ITERATIONS` iterations)
8. Write `.power-trio/implementation.report.md`

**If this is a Phase 2↔3 loop iteration**, include blocking issues in the engineer prompt:

```
Task(subagent_type="power-trio:engineer", prompt="Fix these blocking issues from Phase 3 review, then ensure all tests still pass:\n\nBlocking Issues:\n[BLOCKING_ISSUES_JSON]\n\nCurrent Implementation:\n[FILES]\n\nFix each issue and run tests.")
```

**See trio-build.md for detailed orchestration steps.**

After Phase 2 completes, announce:

```
PHASE 2 COMPLETE: Building

TDD workflow completed. Implementation approved.
Artifact: .power-trio/implementation.report.md

Evaluating Phase 3 triggers...
```

---

## PHASE 3 TRIGGER EVALUATION

Read the implementation report and evaluate triggers:

```
Read(file_path=".power-trio/implementation.report.md")
```

**Phase 3 is TRIGGERED if ANY of these conditions are true:**

### 1. Scale Triggers (from PARAMETERS.md)

- Files changed ≥ `FILES_CHANGED_THRESHOLD`
- Lines of code changed ≥ `LOC_CHANGED_THRESHOLD`

### 2. Sensitive Area Triggers (from implementation.report)

- Authentication: Yes
- Payments: Yes
- Cryptography: Yes
- User data: Yes
- Public API: Yes

### 3. Dependency Triggers

- New external dependencies added
- New public API endpoints created

### 4. User Override

- User explicitly requested refinement phase
- User passed `--refine` flag

**Phase 3 is SKIPPED if ALL of these are true:**

- Files changed < `FILES_CHANGED_THRESHOLD` AND LOC < `LOC_CHANGED_THRESHOLD`
- No sensitive areas touched
- No new external exposure
- User explicitly skipped with `--no-refine`

Announce decision:

```
Phase 3 Evaluation:
- Files changed: [X] (threshold: FILES_CHANGED_THRESHOLD)
- LOC changed: [X] (threshold: LOC_CHANGED_THRESHOLD)
- Sensitive areas: [list or None]
- New dependencies: [list or None]

DECISION: [TRIGGERED | SKIPPED] - [reason]
```

If SKIPPED, proceed to Final Output.

---

## PHASE 3: Refining (if triggered)

Execute the trio-refine workflow inline:

1. Invoke `power-trio:security-specialist` and `power-trio:performance-specialist` IN PARALLEL
2. Invoke `power-trio:product-manager` to classify and decide
3. Write `.power-trio/release.report.md`

**See trio-refine.md for detailed orchestration steps.**

Parse the verdict from product-manager output.

---

## PHASE 2↔3 LOOP

**If Phase 3 verdict is BLOCKED:**

1. Increment `phase2_loops`
2. Check loop limit:
   - If `phase2_loops >= MAX_PHASE2_LOOPS`:
     - Stop and escalate to user with unresolved issues
     - Ask user whether to ship anyway, fix manually, or abort
3. Extract blocking issues JSON
4. Announce:

   ```
   Phase 3 returned BLOCKED with [X] blocking issues.

   Looping back to Phase 2 to address:
   [List blocking issues]

   Phase 2↔3 loop iteration: [N]/MAX_PHASE2_LOOPS
   ```

5. Return to PHASE 2 with `blocking_issues` populated

**If Phase 3 verdict is APPROVED_TO_SHIP:**

Proceed to Final Output.

---

## FINAL OUTPUT

When workflow completes successfully:

```markdown
# Power Trio COMPLETE

## Task

[Original user request]

## Phases Executed

- [x] Phase 1: Planning - Consensus in [X] iterations
- [x] Phase 2: Building - Approved in [X] iterations
- [x/skipped] Phase 3: Refining - [APPROVED_TO_SHIP | Skipped: reason]

## Phase 2↔3 Loops

[0 | X loops to resolve blocking issues]

## Artifacts

- `.power-trio/plan.report.md`
- `.power-trio/implementation.report.md`
- `.power-trio/release.report.md` (if Phase 3 ran)

## Files Changed

[Summary from implementation.report]

## Result

**SHIPPED**

The implementation is complete and approved.
```

---

## ERROR STATES

### Max Phase 2↔3 Loops Exceeded

```
Power Trio BLOCKED

Phase 2↔3 loop limit (MAX_PHASE2_LOOPS) exceeded.

Unresolved blocking issues:
[List issues]

Options:
1. Fix issues manually and run /trio-refine
2. Ship anyway (not recommended): [risks]
3. Abort and revisit requirements

Please advise how to proceed.
```

### Phase 1 No Consensus

```
Power Trio BLOCKED at Phase 1

Unable to reach planning consensus after MAX_PLANNING_ITERATIONS iterations.

Unresolved concerns:
[List concerns by agent]

Please provide guidance to resolve these concerns.
```

### Phase 2 Build Failure

```
Power Trio BLOCKED at Phase 2

Unable to get tests passing after MAX_TEST_FIX_ATTEMPTS attempts.

Failing tests:
[List failures]

Please investigate and fix manually, then run /trio-build.
```

---

## State Summary

Throughout orchestration, track:

```yaml
phase: 1 | 2 | 3
phase1_iterations: 0
phase2_test_iterations: 0
phase2_impl_iterations: 0
phase2_loops: 0
phase3_triggered: false
blocking_issues: []
final_verdict: null
```

Report state transitions to keep user informed of progress.
