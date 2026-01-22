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

Key parameters for this phase:

- `MAX_TEST_ITERATIONS`
- `MAX_IMPL_ITERATIONS`
- `MAX_TEST_FIX_ATTEMPTS`
- `MAX_BLOCKS_PER_AGENT`

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
3. Have test-author revise:

   ```
   Task(subagent_type="power-trio:test-author", prompt="Revise tests to address this concern:\n\n[SENIOR ENGINEER'S CONCERN]\n\nPrevious tests:\n[CURRENT TESTS]\n\nUpdate the tests and provide the revised specification.")
   ```

4. Loop back to Step 1.2

**Maximum test iterations: `MAX_TEST_ITERATIONS`**

---

## STAGE 2: Implementation

### Step 2.1: Implement Code

Once tests are approved, invoke engineer:

```
Task(subagent_type="power-trio:engineer", prompt="Implement code to make these approved tests pass. Follow the plan exactly.\n\nPlan:\n[PLAN.REPORT CONTENT]\n\nApproved Tests:\n[APPROVED TESTS]\n\nWrite the implementation and run the tests.")
```

### Step 2.2: Verify Tests Pass

The engineer should run tests. If they report failures, have them fix:

```
Task(subagent_type="power-trio:engineer", prompt="Tests are failing. Fix the implementation.\n\nTest failures:\n[FAILURE OUTPUT]\n\nCurrent implementation:\n[ENGINEER'S CODE]\n\nFix the code and run tests again.")
```

Loop until tests pass (max `MAX_TEST_FIX_ATTEMPTS` attempts).

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
3. Have engineer fix:

   ```
   Task(subagent_type="power-trio:engineer", prompt="Address this code review feedback:\n\n[SENIOR ENGINEER'S CONCERN]\n\nCurrent implementation:\n[CURRENT CODE]\n\nFix the issues and run tests to ensure nothing broke.")
   ```

4. Loop back to Step 2.3

**Maximum implementation iterations: `MAX_IMPL_ITERATIONS`**

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
Recommend running Phase 3: Refining (/trio-refine)

[Otherwise:]
Ready to ship or run Phase 3 for additional review.
```

## Error Handling

- If tests never pass after `MAX_TEST_FIX_ATTEMPTS` attempts: stop and report blocker to user
- If agent fails to respond: retry once, then ask user
- If no plan.report found: ask user for requirements
