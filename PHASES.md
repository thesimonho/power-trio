## The Three Phases (in detail)

### Phase 1: Plan

**Authority Boundaries:**

_Planner:_

- Creates initial technical approach and implementation strategy
- Translates requirements into concrete plan
- Cannot unilaterally approve plan without committee consensus

_Architect:_

- Advises on patterns, technologies, and architectural decisions
- Provides domain expertise and answers technical questions
- Cannot override plan structure, only inform it

_Critic:_

- Challenges assumptions and identifies risks
- Stress-tests approach for edge cases and failure modes
- Cannot propose alternative plans, only identify problems with current plan
- **Enforcement mechanism:** Blocking unresolved risks and unanswered questions

**Artifact:** `plan.report`

```
- Goals
- Non-goals
- Constraints
- Risks accepted
- Open questions (must be empty to pass)
```

**Consensus Rules:**

- Each agent must explicitly output: `APPROVE` or `BLOCK (with reason)`
- Each agent has maximum `MAX_BLOCKS_PER_AGENT` blocks available before they must escalate to "non-blocking concern"
- Phase completes only when all agents APPROVE (zero BLOCKs remain)
- Open questions must be ≤ `MAX_OPEN_QUESTIONS` (prefer 0, accept minimal count if documented as risk and doesn't block Phase 2 testability)

**Performance Constraints (Loop Reduction):**

- **Critic**: Maximum `MAX_BLOCKS_PER_AGENT` blocking issues per iteration; issues testable in Phase 2 should not block Phase 1
- **Planner**: Incremental revision only - minimal targeted changes, preserve unchanged sections verbatim
- **Architect**: Conditional re-engagement - only re-review if revisions affect architecture, tech choice, or system boundaries
- **Orchestrator**: Issue-scoped iteration - re-invoke only blocking agents with only their concern and relevant revised sections
- **Expected convergence**: 1-3 iterations (max: `MAX_PLAN_ITERATIONS`)

**Dynamic:**

Planner drafts the approach, Architect provides expertise on technical decisions, and Critic identifies risks and gaps. They iterate until all concerns are addressed and the approach is sound. The Critic's challenges force the Planner to address edge cases early, while the Architect ensures technical feasibility. Performance constraints ensure fast convergence by reducing token usage and preventing perfectionist deadlocks.

---

### Phase 2: Build

**Authority Boundaries:**

_Engineer:_

- Writes all production code
- Performs refactors required to satisfy tests or quality review
- May suggest plan deviations (requires committee approval)
- Cannot dismiss test failures or quality objections
- **Enforcement mechanism:** Working, tested implementation

_Test Author:_

- Owns all test code
- Determines expected behavior, edge cases, regression coverage
- Cannot suggest implementation details
- Cannot require tests for behavior not in Phase 1 plan (unless deviation approved)
- **Enforcement mechanism:** Failing tests

_Senior Engineer:_

Test Review Authority (before implementation):

- Can block on: missing tests for plan.report requirements, tests that always pass without implementation, missing edge cases explicitly mentioned in plan.report
- Cannot block on: test structure preferences, granularity, or testing approach unless plan specifies it
- Enforcement mechanism: "These tests don't enforce the plan"

Implementation Review Authority (after implementation):

- Can block based on: unclear naming, overly large functions, poor separation of concerns, missing documentation, high cognitive load
- Can require refactors of both tests and implementation when they're coupled or unclear
- Cannot change test assertions or expected behavior (Test Author's domain)
- Cannot introduce new features or demand speculative abstractions
- All feedback framed as: "This will be hard to understand, modify, or test later because X"
- Enforcement mechanism: Clean code standards and human readability

**Artifact:** `implementation.report`

```
- Files changed
- Test coverage summary
- Notable refactors required by clean-code review
- Deviations from Phase 1 plan (explicitly acknowledged)
- Known limitations
```

**Consensus Rules:**

- All tests must pass (Test Author approves)
- Code meets maintainability standards (Senior Engineer approves)
- Implementation satisfies Phase 1 plan (Engineer confirms, committee concurs)
- Each agent outputs: `APPROVE` or `BLOCK (with specific reason)`
- Each agent has maximum `MAX_BLOCKS_PER_AGENT` blocks available before they must escalate to "non-blocking concern"
- All blocks must be resolved before proceeding

**Execution Constraints (TDD Efficiency + Loop Control):**

- **Senior Engineer**: Maximum `MAX_BLOCKS_PER_AGENT` blocking issues per iteration; blocks only for concrete failures, not style/polish
- **Test Review**: Tests sufficient if they cover success criteria and representative edge cases (not exhaustive)
- **Implementation Review**: Block only if code is hard to understand, overly complex, or error-prone
- **Engineer**: Incremental fixes only - minimal targeted changes, no unrelated refactoring
- **Orchestrator**: Issue-scoped iteration - re-invoke only blocking agents with targeted context
- **Test Failures**: Require explicit root cause diagnosis, avoid blind retries
- **Deviations**: Surface once, do not repeatedly block on same deviation
- **Loop Termination**: Bias toward approval with noted limitations when close to consensus
- **Expected convergence**: Test review `EXPECTED_TEST_CONVERGENCE` iterations, implementation `EXPECTED_IMPL_CONVERGENCE` iterations

**Dynamic:**

Test Author writes tests first, Senior Engineer reviews tests to ensure they enforce plan requirements and would actually fail appropriately. Engineer implements to pass the validated tests. Senior Engineer then reviews both tests and implementation together for maintainability - can require refactoring of either or both. They iterate until the implementation is both correct and maintainable. The Senior Engineer's two review moments (test validity, then code quality) prevent both "pointless tests" and "technically correct but unreadable" output.

---

### Phase 3: Review

**Activation Triggers:**

Phase 3 automatically activates if any of the following are true:

_Change Size:_

- Files changed ≥ 5-10
- Lines of code delta ≥ 300-500

_Surface Area - touches any of:_

- Authentication / identity
- Payments / billing
- Permissions / access control
- Cryptography / secrets
- Database migrations / schemas
- Concurrency / async primitives

_Risk Signals:_

- New external dependencies added
- New public API endpoints
- Changes to existing security-sensitive code paths

_Manual Override:_

- User can force Phase 3 on or off

**Optimization Strategy:**

Phase 3 is optimized for speed and bounded output:

1. **Step 0: Risk Triage** - Fast pre-filtering before invoking specialists
2. **Conditional Specialist Invocation** - Skip specialists if risk = "NONE"
3. **Narrow File Scope** - Max 5 files per specialist, prioritized by risk

**Authority Boundaries:**

_Security Specialist:_

- Can only raise: concrete exploit scenarios, unsafe primitives
- No abstract "best practices" allowed
- Must provide specific vulnerability description
- **Enforcement mechanism:** Demonstrable security risks

_Performance Specialist:_

- Can only raise: asymptotic issues, resource leaks, contention risks
- No micro-optimizations allowed
- Must show measurable performance impact
- **Enforcement mechanism:** Demonstrable performance problems

_Product Manager:_

- Sole authority to classify findings as: `BLOCKING` or `DEFERRED`
- Must justify deferrals explicitly with business rationale
- Validates requirements from Phase 1 are met
- Cannot add new features or requirements not in original plan
- **Enforcement mechanism:** Shipping decision authority

**Artifact:** `release.report`

```
- Blocking issues (must be zero to ship)
- Deferred issues (with rationale)
- Approval verdict
```

**Consensus Rules:**

- Risk triage determines which specialists to invoke
- Security and Performance specialists identify concerns
- Product Manager classifies each as BLOCKING or DEFERRED
- Each agent has maximum 3 blocks available before they must escalate to "non-blocking concern"
- All BLOCKING issues must be resolved
- Phase completes only when Product Manager outputs: `APPROVED TO SHIP`

**Performance Constraints:**

- **Risk Triage**: Fast assessment, skip specialists if risk = "NONE"
- **File Scope**: Maximum `MAX_FILES_PER_SPECIALIST` files per specialist

**Dynamic:**

Risk triage first assesses security and performance risk levels. Specialists are invoked conditionally based on risk. Each specialist reviews a limited, prioritized subset of files and produces bounded output. Product Manager challenges whether each concern is blocking: "Do we _really_ need all that for v1? What's the minimum to ship?" Committee reaches consensus on what's essential vs. nice-to-have. Essential improvements are sent back to Phase 2 committee for implementation with full rigor (tests first, code review, etc.). Loop between Phase 2 and Phase 3 continues until Phase 3 reaches consensus the code is ready to ship.
