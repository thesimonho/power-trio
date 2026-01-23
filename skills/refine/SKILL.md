---
description: Execute the Power Trio refining phase only. Use proactively when improving the security or performance of an existing implementation.
disable-model-invocation: false
user-invocable: true
context: fork
agent: orchestrator
---

Execute Phase 3: Refining with the Power Trio committee.

---

You are orchestrating **Phase 3: Refining**. This phase reviews the feature implementation for security and performance issues before shipping.

## Task

Review for release readiness: **$ARGUMENTS**

If no arguments provided, look for `.power-trio/implementation.report.md`. If that doesn't exist, ask the user what to review.

## Committee Members

| Agent                               | Role                                       |
| ----------------------------------- | ------------------------------------------ |
| `power-trio:security-specialist`    | Identifies security vulnerabilities        |
| `power-trio:performance-specialist` | Identifies performance issues              |
| `power-trio:product-manager`        | Classifies issues, makes shipping decision |

## Orchestration Protocol

### Setup

Read the implementation report, if available:

```
Read(file_path=".power-trio/implementation.report.md")
```

Extract the list of files changed from the report.

---

## Step 0: Risk Triage (Fast Pre-filtering)

**CRITICAL**: If theres an implementation report, run this step BEFORE invoking any specialists to avoid unnecessary work.

Analyze the changed files to assess risk levels:

```json
{
  "security_risk": "NONE" | "LOW" | "MEDIUM" | "HIGH",
  "performance_risk": "NONE" | "LOW" | "MEDIUM" | "HIGH",
  "reasoning": "1-2 sentences explaining the risk assessment"
}
```

**Security Risk Assessment:**

- **NONE**: No security-sensitive changes (documentation, tests, internal utilities)
- **LOW**: Minor changes to existing validated flows
- **MEDIUM**: New features with input handling, new API endpoints
- **HIGH**: Authentication, authorization, cryptography, secrets, multi-tenant boundaries

**Performance Risk Assessment:**

- **NONE**: No performance-sensitive changes (documentation, UI copy, config)
- **LOW**: Minor changes to non-critical paths
- **MEDIUM**: New features in user-facing paths, new database queries
- **HIGH**: Critical path changes, data structure changes, concurrency changes

**Rules:**

- If `security_risk == "NONE"`, **SKIP** the security specialist entirely
- If `performance_risk == "NONE"`, **SKIP** the performance specialist entirely
- If BOTH are "NONE", skip to Step 3 with empty findings

**File Scope Selection (if specialist needed):**

For each specialist that will run, select files based on risk level:

- Extract changed files from implementation report
- **Limit to `MAX_FILES_PER_SPECIALIST`** (defined in `skills/parameters/SKILL.md`)
- Prioritize files based on:
  - Security: Auth, API endpoints, data validation, secrets, crypto
  - Performance: Hot paths, database queries, loops, large data structures
- Pass only the selected files to the specialist (do NOT pass all changed files)

---

## Step 1: Conditional Specialist Review

**IMPORTANT**: Only invoke specialists if their risk is NOT "NONE" (as determined in Step 0), or if there's no implementation report.

**Model Selection:**

- Use `model: "sonnet"` by default
- Escalate to `model: "opus"` ONLY if changes touch:
  - Authentication / authorization
  - Cryptography
  - Secrets management
  - Multi-tenant or trust boundaries

**IMPORTANT**: Invoke needed specialists IN PARALLEL in a single message (skip if risk = "NONE")

**Security Specialist** (if needed):

```
Task(
  subagent_type="power-trio:security-specialist",
  prompt="Review this implementation for security vulnerabilities. Focus on concrete, exploitable issues.\n\nRisk Level: [security_risk]\n\nImplementation Report:\n[IMPLEMENTATION.REPORT CONTENT]\n\nRead and analyze ONLY these files (max [MAX_FILES_PER_SPECIALIST]):\n[SELECTED FILES FOR SECURITY]\n\nAdhere to output limits defined in skills/parameters/SKILL.md.\n\nProvide findings in the specified format with severity levels and JSON summary."
)
```

**Performance Specialist** (if needed):

```
Task(
  subagent_type="power-trio:performance-specialist",
  prompt="Review this implementation for performance issues. Focus on measurable impact.\n\nRisk Level: [performance_risk]\n\nImplementation Report:\n[IMPLEMENTATION.REPORT CONTENT]\n\nRead and analyze ONLY these files (max [MAX_FILES_PER_SPECIALIST]):\n[SELECTED FILES FOR PERFORMANCE]\n\nAdhere to output limits defined in skills/parameters/SKILL.md.\n\nProvide findings in the specified format with severity levels and JSON summary."
)
```

---

## Step 2: Issue Classification

Invoke product-manager with specialist reviews (or empty findings if skipped):

```
Task(subagent_type="power-trio:product-manager", prompt="Classify these findings as BLOCKING or DEFERRED and make the shipping decision.\n\nSecurity Review:\n[SECURITY-SPECIALIST OUTPUT]\n\nPerformance Review:\n[PERFORMANCE-SPECIALIST OUTPUT]\n\nImplementation Report:\n[IMPLEMENTATION.REPORT CONTENT]\n\nClassify each finding and provide your verdict in the specified format.")
```

---

## Step 3: Parse Verdict

Extract the verdict JSON from product-manager's output:

```json
{
  "verdict": "APPROVED_TO_SHIP" | "BLOCKED",
  "blocking_count": N,
  "deferred_count": N,
  "rationale": "..."
}
```

Also extract:

- `blocking_issues`: Array of issues that must be fixed
- `deferred_issues`: Array of issues tracked for follow-up

---

## Step 4: Handle Verdict

### If APPROVED_TO_SHIP

Create release.report.md artifact:

```
Write(file_path=".power-trio/release.report.md", content="[ARTIFACT]")
```

**Artifact format:**

```markdown
# Release Report

## Implementation Reviewed

[Reference to implementation.report]

## Security Review

### Findings

| Severity | Issue   | Classification | Rationale |
| -------- | ------- | -------------- | --------- |
| [sev]    | [issue] | DEFERRED       | [why]     |

### Summary

- Critical: [X] (Blocking: [Y], Deferred: [Z])
- High: [X] (Blocking: [Y], Deferred: [Z])
- Medium: [X] (Blocking: [Y], Deferred: [Z])
- Low: [X] (Blocking: [Y], Deferred: [Z])

## Performance Review

### Findings

| Severity | Issue   | Classification | Rationale |
| -------- | ------- | -------------- | --------- |
| [sev]    | [issue] | DEFERRED       | [why]     |

### Summary

- Critical: [X] (Blocking: [Y], Deferred: [Z])
- High: [X] (Blocking: [Y], Deferred: [Z])
- Medium: [X] (Blocking: [Y], Deferred: [Z])
- Low: [X] (Blocking: [Y], Deferred: [Z])

## Blocking Issues

None

## Deferred Issues

[List with follow-up timeline]

## Verdict

**APPROVED_TO_SHIP**

### Rationale

[Product Manager's explanation]

---

Generated by Power Trio: Refining
Security findings: [X]
Performance findings: [X]
Blocking: 0
Deferred: [X]
```

Output success:

```
Refining COMPLETE

Security findings: [X] (0 blocking, [X] deferred)
Performance findings: [X] (0 blocking, [X] deferred)

Artifact: .power-trio/release.report.md

The implementation is ready to ship.
```

### If BLOCKED

Create release.report.md with blocking status

**Artifact format:**

````markdown
# Release Report

## Implementation Reviewed

[Reference to implementation.report]

## Blocking Issues

```json
[
  {
    "source": "security",
    "severity": "CRITICAL",
    "issue": "...",
    "fix_required": "..."
  },
  {
    "source": "performance",
    "severity": "HIGH",
    "issue": "...",
    "fix_required": "..."
  }
]
```

## Verdict

**BLOCKED**

### Conditions for Approval

[List of specific fixes required]

---

Generated by Power Trio: Refining
````

Output blocking status:

```
Refining COMPLETE

VERDICT: BLOCKED

Blocking issues that must be fixed:

1. [Security/Performance]: [Issue] - [Fix required]
2. [Security/Performance]: [Issue] - [Fix required]

Artifact: .power-trio/release.report.md

Return to Phase 2 to address blocking issues, then re-run /power-trio:refine.

BLOCKING_ISSUES:

[blocking issues array for Phase 2 consumption]

```

---

## Output Format for Phase 2 Loop

When BLOCKED, the output must include a parseable section for the /power-trio command to detect and loop:

```

PHASE3_RESULT: BLOCKED
BLOCKING_ISSUES_JSON: [{"source": "...", "issue": "...", "fix_required": "..."}]

```

When APPROVED:

```

PHASE3_RESULT: APPROVED_TO_SHIP

```

## Error Handling

- If implementation.report not found: ask user for files to review
- If specialist fails to respond: retry once, then proceed with available data
- If product-manager output missing verdict: ask for clarification
