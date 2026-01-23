---
description: Execute the Power Trio building phase only. Use proactively when implementing a feature.
disable-model-invocation: false
user-invocable: true
context: fork
agent: orchestrator
---

Execute Phase 2: Building with the Power Trio committee using Test-Driven Development.

---

## Configuration

Key parameters for this phase (see parameters skill):

- `MAX_TEST_ITERATIONS` - Maximum rounds of test revision
- `MAX_IMPL_ITERATIONS` - Maximum rounds of implementation revision
- `MAX_TEST_FIX_ATTEMPTS` - Maximum attempts to fix failing tests
- `MAX_BLOCKS_PER_AGENT` - Maximum blocks per agent before escalation
- `EXPECTED_TEST_CONVERGENCE` - Expected maximum test iterations
- `EXPECTED_IMPL_CONVERGENCE` - Expected maximum implementation iterations

---

You are orchestrating **Phase 2: Building**. This phase enforces TDD: tests are written and approved BEFORE implementation begins.

## Task

Build the implementation based on: **$ARGUMENTS**

If no arguments provided, look for `.power-trio/plan.report.md`. If that doesn't exist, ask the user what to build.

## Committee Members

| Agent                        | Role                                    |
| ---------------------------- | --------------------------------------- |
| `power-trio:test-author`     | Writes tests first, defines correctness |
| `power-trio:engineer`        | Implements code to pass tests           |
| `power-trio:senior-engineer` | Reviews tests and code for quality      |

## Orchestration Protocol

### Setup

Read the plan if available:

```
Read(file_path=".power-trio/plan.report.md")
```

Initialize state:

```
stage: "TEST_CREATION"
test_iterations: 0
impl_iterations: 0
block_counts: {test_author: 0, engineer: 0, senior_engineer: 0}
```

## Execution Constraints (TDD Efficiency + Loop Control)

1. **Issue-Scoped Iteration (Orchestrator)**
   - Re-invoke only the agent(s) responsible for the block
   - Provide only: the blocking concern and relevant code
   - Do NOT re-run full reviews unless required by the fix

2. **Loop Termination Bias**
   - When close to consensus: prefer APPROVE with noted limitations over another BLOCK
   - Prefer documenting cleanup as future task
   - Assume Phase 3 exists to catch production-level concerns

3. **Expected Convergence Envelope**
   - Test creation + review: `EXPECTED_TEST_CONVERGENCE` iterations
   - Implementation + review: `EXPECTED_IMPL_CONVERGENCE` iterations
   - Long loops indicate over-blocking or over-scoping

---

## STAGE 1: Test Creation and Review

Important: only invoke the test creation and review steps if there is already an existing testing framework in place.

### Step 1.1: Create Tests

Invoke test-author to write tests FIRST (before any implementation):

```
Task(subagent_type="power-trio:test-author", prompt="Based on this plan, write tests that define correctness. Tests should cover all success criteria, edge cases, and error cases. Write tests that will FAIL initially (no implementation exists yet).\n\nPlan:\n[PLAN.REPORT CONTENT]\n\nCreate test files and provide the test specification.")
```

### Step 1.2: Review Tests

Invoke senior-engineer to review the tests:

```
Task(subagent_type="power-trio:senior-engineer", prompt="Review these tests for completeness and correctness (STAGE: TEST_REVIEW). Do they properly specify the expected behavior from the plan?\n\nPlan:\n[PLAN.REPORT CONTENT]\n\nTests:\n[TEST-AUTHOR OUTPUT]\n\nReview and vote APPROVE or BLOCK with REASON.")
```

### Step 1.3: Test Iteration

Parse senior-engineer's vote:

**If APPROVE**: Proceed to Stage 2 (Implementation)

**If BLOCK**:

1. Increment `block_counts.senior_engineer`
2. Check escalation (`MAX_BLOCKS_PER_AGENT` blocks → convert to documented concern)
3. **Issue-scoped iteration** - Have test-author revise with only the specific concern:

   ```
   Task(subagent_type="power-trio:test-author", prompt="Revise tests to address this specific concern:\n\n[SENIOR ENGINEER'S BLOCKING CONCERN - max MAX_BLOCKING_ISSUES_PER_ITERATION_SE issues]\n\nMake minimal, targeted changes. Do NOT refactor unrelated tests.\n\nCurrent tests:\n[ONLY THE AFFECTED TEST(S)]\n\nUpdate the tests and provide the revised specification.")
   ```

4. Loop back to Step 1.2 (re-invoke only senior-engineer with targeted context)

**Maximum test iterations: `MAX_TEST_ITERATIONS`**
**Expected convergence: `EXPECTED_TEST_CONVERGENCE` iterations**

---

## STAGE 2: Implementation

### Step 2.1: Implement Code

Once tests are approved, invoke engineer:

```
Task(subagent_type="power-trio:engineer", prompt="Implement code to make these approved tests pass. Follow the plan exactly.\n\nPlan:\n[PLAN.REPORT CONTENT]\n\nApproved Tests:\n[APPROVED TESTS]\n\nWrite the implementation and run the tests.")
```

### Step 2.2: Verify Tests Pass

The engineer should run tests. If they report failures, require diagnosis:

```
Task(subagent_type="power-trio:engineer", prompt="Tests are failing. Before fixing, diagnose the root cause.\n\nTest failures:\n[FAILURE OUTPUT]\n\nCurrent implementation:\n[ENGINEER'S CODE]\n\nExplicitly state:\n1. Root cause of the failure\n2. Whether this indicates: bug in implementation, flaw in test, or mismatch with plan\n3. Your fix approach\n\nThen fix the code and run tests again. Avoid blind retries - each attempt must add new understanding.")
```

Loop until tests pass (max `MAX_TEST_FIX_ATTEMPTS` attempts).

**If tests never pass after `MAX_TEST_FIX_ATTEMPTS`**: stop and report blocker to user.

### Step 2.3: Code Review

Once tests pass, invoke senior-engineer for implementation review:

```
Task(subagent_type="power-trio:senior-engineer", prompt="Review this implementation for code quality (STAGE: IMPLEMENTATION_REVIEW). Tests are passing.\n\nPlan:\n[PLAN.REPORT CONTENT]\n\nTests:\n[APPROVED TESTS]\n\nImplementation:\n[ENGINEER OUTPUT]\n\nVerify tests pass legitimately and review code quality. Vote APPROVE or BLOCK with REASON.")
```

### Step 2.4: Implementation Iteration

Parse senior-engineer's vote:

**If APPROVE**: Proceed to Artifact Creation

**If BLOCK**:

1. Increment `block_counts.senior_engineer`
2. Check escalation (`MAX_BLOCKS_PER_AGENT` blocks → convert to documented concern)
3. **Issue-scoped iteration** - Have engineer fix with only the specific concern:

   ```
   Task(subagent_type="power-trio:engineer", prompt="Address this specific code review feedback:\n\n[SENIOR ENGINEER'S BLOCKING CONCERN - max MAX_BLOCKING_ISSUES_PER_ITERATION_SE issues]\n\nMake minimal, targeted changes. Do NOT refactor unrelated code.\n\nCurrent implementation:\n[ONLY THE AFFECTED CODE]\n\nFix the issues surgically and run tests to ensure nothing broke.")
   ```

4. Loop back to Step 2.3 (re-invoke only senior-engineer with targeted context)

**If deviation from plan**: Surface once as documented deviation. Do not repeatedly block.

**Loop termination bias**: When close to consensus, prefer APPROVE with noted limitations.

**Maximum implementation iterations: `MAX_IMPL_ITERATIONS`**
**Expected convergence: `EXPECTED_IMPL_CONVERGENCE` iterations**

---

## STAGE 3: Artifact Creation

When implementation is approved, create implementation.report.md:

```
Write(file_path=".power-trio/implementation.report.md", content="[ARTIFACT]")
```

**Artifact format:**

```markdown
# Implementation Report

## Task

[From plan.report]

## Files Changed

| File         | Change Type | Description |
| ------------ | ----------- | ----------- |
| path/to/file | Added       | Description |

## Lines of Code

- Added: [X]
- Modified: [X]
- Deleted: [X]
- Total: [X]

## Test Results

- Test files: [list]
- Test cases: [X] total
- Passing: [X]
- Command: `[test command]`

## Deviations from Plan

[None or list with justification]

## Dependencies

- New dependencies: [list or None]
- External APIs: [list or None]

## Sensitive Areas Touched

- Authentication: Yes/No
- Payments: Yes/No
- Cryptography: Yes/No
- User data: Yes/No
- Public API: Yes/No

## Committee Approval

- Test Author: Tests approved
- Engineer: Implementation complete
- Senior Engineer: APPROVE

## Iterations

- Test iterations: [X]
- Implementation iterations: [X]

---

Generated by Power Trio Phase 2: Building
```

---

## Output Summary

Announce completion:

```
Phase 2: Building COMPLETE

TDD workflow completed:
- Test iterations: [X]
- Implementation iterations: [X]

All tests passing. Code approved by Senior Engineer.

Artifact: .power-trio/implementation.report.md

Files changed: [X]
Lines of code: [X]
Sensitive areas: [list if any]

[If sensitive areas or significant changes:]
Recommend running Phase 3: Refining (/power-trio:refine)

[Otherwise:]
Ready to ship or run Phase 3 for additional review.
```

## Error Handling

- If tests never pass after `MAX_TEST_FIX_ATTEMPTS` attempts: stop and report blocker to user
- If agent fails to respond: retry once, then ask user
- If no plan.report found: ask user for requirements
