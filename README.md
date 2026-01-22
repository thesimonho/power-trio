# Power Trio

> Good things come in threes: meals a day, wishes, and the John Mayer Trio.

A committee of agents for planning, building, and refining.

---

## Overview

Power Trio is a three-phase AI agent workflow system designed to deliver code that's fast to generate but maintains human-quality standards. Each phase operates as a committee of three specialized agents who iterate toward consensus before passing work to the next phase.

The core insight: programming can happen faster with AI agents than humans, but the criticism of AI-generated code is "slop"—fast output that lacks quality. Power Trio addresses this by separating speed (Phase 2) from quality assurance (Phase 3), with clear planning upfront (Phase 1).

**This is a constraint pipeline, not just a reasoning pipeline.** Each phase narrows degrees of freedom, removes ambiguity, and converts opinions into enforceable rules.

---

## Why Power Trio? (vs. Sequential Prompting)

Advanced users might ask: "Why can't I just do Plan → Code → Review with good prompts?"

Power Trio enables what sequential prompting cannot:

1. **Parallel disagreement surfaces issues earlier** - Multiple agents with different concerns challenge each other in real-time, rather than sequential review catching issues after the fact

2. **Hard role constraints prevent "model collapse"** - Agents can't drift into agreeable slop because their enforcement mechanisms are explicit and bounded

3. **Forced delegation loops prevent patchy fixes** - Phase 3 cannot hack in quick fixes; they must delegate back to Phase 2's full committee with proper TDD and review

4. **Repeated committee patterns reduce prompt fiddling** - The structure is consistent and predictable, not dependent on crafting perfect sequential prompts

---

## The Three Phases

### Phase 1: Planning

**Goal:** Reach consensus on what to build and how to build it

**Committee:**

- **Planner** - Creates the initial plan and approach
- **Architect** - Provides domain expertise and answers technical questions
- **Critic** - Challenges assumptions, identifies risks, stress-tests the approach

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
- Each agent has maximum 3 blocks available before they must escalate to "non-blocking concern"
- Phase completes only when all agents APPROVE (zero BLOCKs remain)
- All open questions must be resolved

**Dynamic:**

Planner drafts the approach, Architect provides expertise on technical decisions, and Critic identifies risks and gaps. They iterate until all concerns are addressed and the approach is sound. The Critic's challenges force the Planner to address edge cases early, while the Architect ensures technical feasibility.

**Why This Committee Split Works:**

- Planner optimizes for clear direction and completeness
- Architect grounds decisions in domain reality and best practices
- Critic prevents poorly-thought-out plans from reaching implementation
- This mirrors effective design reviews: proposal, expertise, and challenge

---

### Phase 2: Building

**Goal:** Implement the plan quickly without sacrificing long-term code quality

**Committee:**

- **Engineer** - Implements the solution, optimizes for speed of correct implementation
- **Test Author** - Defines correctness through tests, ensures TDD discipline
- **Senior Engineer** - Enforces maintainability and readability standards (clean code advocate)

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

- Can block based on: unclear naming, overly large functions, poor separation of concerns, missing documentation, high cognitive load
- Can require refactors even when tests pass
- Cannot introduce new features or demand speculative abstractions
- All feedback framed as: "This will be hard to understand, modify, or test later because X"
- **Enforcement mechanism:** Clean code standards and human readability

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
- Each agent has maximum 3 blocks available before they must escalate to "non-blocking concern"
- All blocks must be resolved before proceeding

**Dynamic:**

Engineer implements while Test Author ensures proper testing discipline and Senior Engineer prevents "slop" at the code level. Test Author writes tests first, Engineer makes them pass, and Senior Engineer reviews for maintainability. They iterate until the implementation is both correct and maintainable. The Senior Engineer's ability to block on readability creates necessary tension against pure speed.

**Why This Committee Split Works:**

- Engineer optimizes for momentum and getting code working
- Test Author turns correctness into something objective and enforceable
- Senior Engineer protects against "technically correct but unreadable" output
- This mirrors high-functioning human teams: tests catch bugs, senior engineers catch future pain
- Trying to eliminate taste entirely leads to worse systems; this formalizes where taste is allowed

---

### Phase 3: Refining

**Goal:** Ensure production-readiness and validate the solution solves the original problem

**Phase 3 is optional** - automatically triggered when risk heuristics are met.

**Activation Triggers:**

Phase 3 activates if any of the following are true:

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

**Committee:**

- **Security Specialist** - Identifies security vulnerabilities and risks
- **Performance Specialist** - Identifies performance issues and optimization opportunities
- **Product Manager** - Validates solution solves the user's problem and balances specialist concerns against shipping pragmatism

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

- Security and Performance specialists identify concerns
- Product Manager classifies each as BLOCKING or DEFERRED
- Each agent has maximum 3 blocks available before they must escalate to "non-blocking concern"
- All BLOCKING issues must be resolved
- Phase completes only when Product Manager outputs: `APPROVED TO SHIP`

**Dynamic:**

Security and Performance specialists identify concerns and improvements. Product Manager challenges whether each concern is blocking: "Do we _really_ need all that for v1? What's the minimum to ship?" Committee reaches consensus on what's essential vs. nice-to-have. Essential improvements are sent back to Phase 2 committee for implementation with full rigor (tests first, code review, etc.). Loop between Phase 2 and Phase 3 continues until Phase 3 reaches consensus the code is ready to ship.

**Why This Committee Split Works:**

- Security and Performance specialists prevent production disasters from different angles
- Product Manager prevents over-engineering and perfectionism paralysis
- The tension between "make it perfect" and "ship it" produces pragmatic quality
- Product Manager's business lens balances technical concerns with user needs
- This mirrors real product teams: specialists identify risks, PM decides what blocks release

---

## Key Design Principles

### Committee Consensus Over Individual Authority

No single agent can push through a decision—each phase requires explicit consensus from all three committee members using `APPROVE` / `BLOCK` protocol. Each agent has a maximum of 3 blocks available before they must escalate concerns to "non-blocking." This prevents both "slop" from rushing and "analysis paralysis" from perfectionism.

### Distinct Phase Concerns

Each phase has a clear gating question:

- **Phase 1:** Is this the right technical approach?
- **Phase 2:** Is this implementation correct and maintainable?
- **Phase 3:** Is this production-ready AND does it solve the original problem?

### Anti-Slop at Multiple Levels

Quality is protected at each phase:

- Phase 1: Critic prevents poorly-thought-out plans
- Phase 2: Senior Engineer prevents poorly-written code
- Phase 3: Specialists prevent production issues, Product Manager prevents over-engineering

### Phases as Contracts

Each phase produces a structured artifact that serves as input to the next phase:

- `plan.report` → consumed by Phase 2
- `implementation.report` → consumed by Phase 3 (triggers risk heuristics)
- `release.report` → final shipping decision

These are contracts, not documentation for users.

### Iterative Loops with Hard Constraints

Phase 2 and Phase 3 loop until consensus is reached. Phase 3 cannot hack in fixes—they must delegate back to Phase 2's full committee to implement changes with the same rigor.

---

## When Not to Use Power Trio

**Skip Power Trio for:**

- Quick exploratory scripts or prototypes
- Trivial file changes (< 5 files, < 300 LOC)
- Non-production code or one-off utilities
- When you need extreme speed over quality

**Power Trio works best for:**

- Production systems and APIs
- Security or performance-critical code
- Multi-file features with integration concerns
- Code that will be maintained long-term

---

## Example Flow

1. **User request:** "Build an API endpoint for user authentication"

2. **Phase 1 (Planning):**
   - Planner: "Use JWT tokens with refresh token rotation"
   - Architect: "Consider rate limiting and account lockout policies"
   - Critic: `BLOCK` - "What about password reset flow? How do we handle token revocation?"
   - → Iterate until consensus, output `plan.report` with zero open questions
   - → All agents output `APPROVE`

3. **Phase 2 (Building):**
   - Test Author: "Write tests for auth success, invalid credentials, rate limiting"
   - Engineer: Implements endpoint with tests passing
   - Senior Engineer: `BLOCK` - "This 200-line function needs to be broken up. Extract token generation logic."
   - → Iterate until code is clean and tested
   - → Outputs `implementation.report`
   - → All agents output `APPROVE`

4. **Phase 3 (Refining) - Triggered** (touches auth, a sensitive surface area):
   - Security Specialist: "Need input validation, password complexity rules, and audit logging" → classified by PM
   - Performance Specialist: "Add caching for user lookups, implement connection pooling" → classified by PM
   - Product Manager: "Input validation is `BLOCKING`. Audit logging is `DEFERRED` for v2. Caching is `DEFERRED`—not a resource leak, just an optimization."
   - → Reach consensus on blocking items only
   - → Send `BLOCKING` items back to Phase 2 to implement agreed changes
   - → Loop until Product Manager outputs `APPROVED TO SHIP`
   - → Output `release.report` with blocking issues = 0
