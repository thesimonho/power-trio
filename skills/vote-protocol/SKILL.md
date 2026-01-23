---
user-invocable: false
---

# Vote Protocol

Reference documentation for the Power Trio voting system.

---

## Overview

The Power Trio uses a structured voting protocol to reach consensus. Each agent must end their response with an explicit vote that can be parsed by the orchestrating command.

## Vote Format

Agents must end their responses with:

```
---
VOTE: APPROVE
```

Or:

```
---
VOTE: BLOCK
REASON: [Specific reason for blocking]
```

## Vote Types

### APPROVE

Indicates the agent has no blocking concerns. The work can proceed to the next stage.

**When to APPROVE:**

- Plan is technically sound and addresses requirements
- Tests adequately cover the success criteria
- Implementation meets quality standards
- No security or performance issues warrant blocking

### BLOCK

Indicates the agent has concerns that must be addressed before proceeding.

**When to BLOCK:**

- Critical requirement is missing or incorrect
- Technical approach is fundamentally flawed
- Security vulnerability that could harm users
- Tests don't cover important scenarios
- Code has obvious bugs or quality issues

**A BLOCK must include:**

- Specific reason (not vague concerns)
- What needs to change to get an APPROVE

## Block Escalation Rule

To prevent infinite loops, each agent has a maximum number of blocks per issue category. Refer to Parameters skill for the number of blocks.

### How It Works

1. **First Block**: Concern is raised, revision requested
2. **Second Block**: Concern persists, another revision
3. **Third Block**: If concern still not addressed, it is **escalated**

### Escalation

When an agent has blocked too many times on the same general issue:

1. The concern is converted to a **documented risk**
2. The block becomes a **non-blocking APPROVE with noted risk**
3. The orchestrator announces the escalation
4. Work proceeds with the risk documented

### Example

```
Architect blocked X times on: "Missing rate limiting"

ESCALATION: Converting to documented risk.
- Risk: "API endpoints lack rate limiting"
- Mitigation: "To be addressed in follow-up work"
- Architect vote converted to: APPROVE (with documented risk)
```

## Consensus Requirements

### Phase 1: Plan

- All three agents (Planner, Architect, Critic) must APPROVE
- Plan must have no unresolved Open Questions

### Phase 2: Build

- Senior Engineer must APPROVE tests before implementation
- Senior Engineer must APPROVE implementation before completion

### Phase 3: Review

- Product Manager determines final verdict (APPROVED_TO_SHIP or BLOCKED)
- Security and Performance specialists provide findings, not votes

## Vote Parsing

Commands parse votes by looking for the pattern:

```
VOTE: (APPROVE|BLOCK)
```

If BLOCK, also extract:

```
REASON: (.+)
```

## Best Practices

### For Agents

1. Always include explicit vote at end of response
2. Be specific about blocking reasons
3. Suggest solutions when blocking
4. Don't block on preferences, only requirements
5. Acknowledge when concerns are addressed

### For Orchestrators

1. Track block counts per agent
2. Pass blocking reasons to the revising agent
3. Announce escalations clearly
4. Document all risks from escalated blocks
