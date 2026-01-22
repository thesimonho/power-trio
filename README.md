# Power Trio

<p align="center">
  <img src="https://github.com/user-attachments/assets/4fb6a29d-ac37-468d-8c0a-dfefc876136b" height="30%" width="30%" alt="logo">
</p>

<p align="center">
  A committee of agents for planning, building, and refining.
</p>

<p align="center" style="font-size: 0.9em; font-style: italic;">
  Good things come in threes: meals a day, wishes, and the John Mayer Trio.
</p>

## Overview

Power Trio is a three-phase AI agent workflow system designed to deliver code that's fast to generate but maintains human-quality standards. Each phase operates as a committee of three specialized agents who iterate toward consensus before passing work to the next phase.

The core insight: programming can happen faster with AI agents than humans, but the criticism of AI-generated code is "slop"—fast output that lacks quality. Power Trio addresses this by separating speed (Phase 2) from quality assurance (Phase 3), with clear planning upfront (Phase 1).

**This is a constraint pipeline, not a reasoning pipeline.** Each phase narrows degrees of freedom, removes ambiguity, and converts opinions into enforceable rules.

## Installation

### Claude Code

Add the marketplace:

```bash
/plugin marketplace add thesimonho/artificial-jellybeans
```

Then install the plugin:

```bash
/plugin install power-trio@thesimonho/artificial-jellybeans
```

## Why Power Trio? (vs. Sequential Prompting)

Advanced users might ask: "Why can't I just do Plan → Code → Review with good prompts?"

Power Trio enables what sequential prompting cannot:

1. **Parallel disagreement surfaces issues earlier** - Multiple agents with different concerns challenge each other in real-time, rather than sequential review catching issues after the fact

2. **Hard role constraints prevent "model collapse"** - Agents can't drift into agreeable slop because their enforcement mechanisms are explicit and bounded

3. **Forced delegation loops prevent patchy fixes** - Phase 3 cannot hack in quick fixes; they must delegate back to Phase 2's full committee with proper TDD and review

4. **Repeated committee patterns reduce prompt fiddling** - The structure is consistent and predictable, not dependent on crafting perfect sequential prompts

## The Three Phases

See [PHASES.md](PHASES.md) for the detailed description of each phase.

See [ORCHESTRATION.md](ORCHESTRATION.md) for the orchestration logic within and between each phase.

### Phase 1: Planning

**Goal:** Reach consensus on what to build and how to build it

**Committee:**

- **Planner** - Creates the initial plan and approach
- **Architect** - Provides domain expertise and answers technical questions
- **Critic** - Challenges assumptions, identifies risks, stress-tests the approach

**Why This Committee Split Works:**

- Planner optimizes for clear direction and completeness
- Architect grounds decisions in domain reality and best practices
- Critic prevents poorly-thought-out plans from reaching implementation
- This mirrors effective design reviews: proposal, expertise, and challenge

### Phase 2: Building

**Goal:** Implement the plan quickly without sacrificing long-term code quality

**Committee:**

- **Engineer** - Implements the solution, optimizes for speed of correct implementation
- **Test Author** - Defines correctness through tests, ensures TDD discipline
- **Senior Engineer** - Enforces maintainability and readability standards (clean code advocate)

**Why This Committee Split Works:**

- Engineer optimizes for momentum and getting code working
- Test Author turns correctness into something objective and enforceable
- Senior Engineer acts as quality gatekeeper at two critical moments: validates tests actually enforce the plan (prevents wasted implementation effort), then ensures the resulting code is maintainable (prevents slop)
- This mirrors high-functioning human teams: tests catch bugs, senior engineers catch both bad tests and future pain
- The dual review points (tests then implementation) catch different failure modes while preserving TDD discipline

### Phase 3: Refining

**Goal:** Ensure production-readiness and validate the solution solves the original problem

**Phase 3 is optional** - automatically triggered when risk heuristics are met.

**Committee:**

- **Security Specialist** - Identifies security vulnerabilities and risks
- **Performance Specialist** - Identifies performance issues and optimization opportunities
- **Product Manager** - Validates solution solves the user's problem and balances specialist concerns against shipping pragmatism

**Why This Committee Split Works:**

- Security and Performance specialists prevent production disasters from different angles
- Product Manager prevents over-engineering and perfectionism paralysis
- The tension between "make it perfect" and "ship it" produces pragmatic quality
- Product Manager's business lens balances technical concerns with user needs
- This mirrors real product teams: specialists identify risks, PM decides what blocks release

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
