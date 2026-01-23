---
description: Execute the Power Trio planning phase only. Use proactively when creating a plan for a new feature.
disable-model-invocation: false
user-invocable: true
context: fork
agent: orchestrator
---

Execute Phase 1: Planning with the Power Trio committee.

---

## Configuration

Key parameters for this phase:

- `MAX_PLANNING_ITERATIONS`:
- `MAX_BLOCKS_PER_AGENT`

---

You are orchestrating **Phase 1: Planning**. This phase uses three agents to create a consensus-approved plan through deliberation and iterative refinement.

## Task

Plan the following: **$ARGUMENTS**

If no arguments provided, ask the user what they want to plan.

## Committee Members

| Agent                  | Role                                     |
| ---------------------- | ---------------------------------------- |
| `power-trio:planner`   | Creates and refines the plan             |
| `power-trio:architect` | Technical expertise and feasibility      |
| `power-trio:critic`    | Challenges assumptions, identifies risks |

## Orchestration Protocol

### Execution Constraints

**Issue-Scoped Iteration for Performance + Loop Reduction:**

1. **Only re-invoke agents who blocked** - not the full committee
2. Provide each blocking agent **only their concern and relevant revised sections**
3. **Unit of iteration is the unresolved issue**, not the entire plan
4. **Architect conditional re-engagement**: Only re-invoke if revisions affect architecture, tech choice, or system boundaries
5. **Open questions threshold**: Phase 1 may complete with up to `MAX_OPEN_QUESTIONS` explicitly accepted open questions
6. **Loop termination bias**: Prefer APPROVE + documented risk over BLOCK + iteration when close to consensus
7. Phase 1 is expected to converge in **1-3 iterations**

### Setup

First, create the output directory:

```
Bash(command="mkdir -p .power-trio")
```

### Step 1: Initial Plan Creation

Invoke the planner to create the initial plan:

```
Task(subagent_type="power-trio:planner", prompt="Create an implementation plan for the following task. Read relevant files to understand the codebase context first.\n\nTask: [USER REQUEST]\n\nInclude: Goals, Constraints, Implementation Steps, Success Criteria, Risks, and Open Questions.")
```

### Step 2: Architect Review

Invoke architect to provide input on best practices:

```
Task(subagent_type="power-trio:architect", prompt="Review this plan for technical soundness. Read relevant files to verify feasibility.\n\nPlan:\n[PLANNER OUTPUT]\n\nProvide your assessment and end with VOTE: APPROVE or VOTE: BLOCK with REASON.")
```

### Step 3: Critic Review

Invoke critic to challenge assumptions and identify risks:

```
Task(subagent_type="power-trio:critic", prompt="Critically analyze this plan. Challenge assumptions and identify risks.\n\nPlan:\n[PLANNER OUTPUT]\n\nProvide your analysis and end with VOTE: APPROVE or VOTE: BLOCK with REASON.")
```

### Step 4: Vote Collection

Parse the outputs from all three agents. Look for the vote block at the end:

- `VOTE: APPROVE` - Agent approves the plan
- `VOTE: BLOCK` followed by `REASON:` - Agent blocks with specific reason

**Track block counts per agent** (initialize to 0 for each).

### Step 5: Consensus Check

**Consensus is reached when ALL of these are true:**

1. All three agents vote APPROVE
2. The plan has ≤ `MAX_OPEN_QUESTIONS` unresolved questions
   - **Prefer 0 open questions**
   - Accept up to `MAX_OPEN_QUESTIONS` ONLY if:
     - They are documented under Risks or Open Questions
     - They do not block Phase 2 testability
     - They are acknowledged by all committee members
   - **Phase 1 is a risk-triage gate, not a proof of completeness**

If consensus reached, proceed to Step 7 (Artifact Creation).

### Step 6: Iteration (if no consensus)

**Issue-Scoped Iteration Protocol:**

For each BLOCK vote:

1. **Increment that agent's block count**

2. **Check for escalation**: If an agent has blocked `MAX_BLOCKS_PER_AGENT` times on the same general issue:
   - Convert their concern to a documented risk
   - Treat as non-blocking APPROVE with noted risk
   - Announce: "Escalating [agent]'s concern to documented risk after MAX_BLOCKS_PER_AGENT blocks"

3. **Request incremental revision from planner**:

   ```
   Task(subagent_type="power-trio:planner", prompt="Apply MINIMAL, TARGETED revisions to address these concerns:\n\n[LIST BLOCKING CONCERNS WITH AGENT NAMES]\n\nDo NOT rewrite the entire plan. Preserve unchanged sections verbatim. Mark where each concern is addressed.\n\nBlocking concerns:\n[BLOCKING CONCERNS]\n\nCurrent plan:\n[CURRENT PLAN]")
   ```

4. **Issue-scoped re-invocation** (only invoke blocking agents):
   - **For each blocking agent**, provide ONLY:
     - Their original concern
     - The specific revised sections relevant to that concern
   - **Do NOT** ask agents to re-review unrelated parts
   - **Special case for Architect**: Only re-invoke if revisions affect architecture, tech choice, or system boundaries. If changes are localized and non-architectural, skip re-invocation and carry forward previous APPROVE vote.

   ```
   Task(subagent_type="power-trio:[blocking-agent]", prompt="Review ONLY the revised sections addressing your concern.\n\nYour original concern: [THEIR CONCERN]\n\nRevised sections:\n[ONLY THE CHANGED SECTIONS]\n\nHas your concern been addressed? Vote APPROVE or BLOCK with REASON.\n\nDo NOT re-review unrelated parts of the plan.")
   ```

5. **Loop Termination Bias**:
   - When close to consensus: **Prefer documenting residual uncertainty as an accepted risk**
   - Prefer **APPROVE + risk** over **BLOCK + iteration**
   - Use BLOCK only when proceeding would clearly cause failure
   - Remember: Phase 1 is expected to converge quickly (see `MAX_PLANNING_ITERATIONS`)
   - Long, exhaustive analyses are a smell - **concision is a quality signal**

6. **Loop back to Step 4** (Vote Collection)

**Maximum iterations: `MAX_PLANNING_ITERATIONS`**. If no consensus after max iterations, output current state with unresolved concerns and ask user for guidance.

### Step 7: Artifact Creation

When consensus is reached, create the plan.report.md artifact.

**Write to file using Write tool:**

```markdown
# Plan Report

## Task

[Original user request]

## Goals

- Primary: [from planner]
- Secondary: [from planner]

## Constraints

[from planner]

## Implementation Steps

[numbered steps from planner]

## Success Criteria

[checkboxes from planner]

## Risks

[combined from all agents]

## Iterations

[X] iterations to reach consensus

## Open Questions

None

---

Generated by Power Trio Phase 1: Planning
```

```
Write(file_path=".power-trio/plan.report.md", content="[ARTIFACT CONTENT]")
```

### Step 8: Output Summary

Announce completion:

```
Phase 1: Planning COMPLETE

Consensus reached in [X] iterations.

Plan approved by all committee members:
- Planner: APPROVE
- Architect: APPROVE
- Critic: APPROVE

Artifact: .power-trio/plan.report.md

```

## State Tracking

Throughout orchestration, maintain:

```
iteration: 0
block_counts: {planner: 0, architect: 0, critic: 0}
current_plan: ""
votes: {planner: null, architect: null, critic: null}
blocking_reasons: []
```

## Error Handling

- If an agent fails to respond: retry once, then ask user
- If an agent output doesn't contain a vote: ask agent to clarify
- If max iterations reached: output current state with all unresolved concerns
