# Clean Code

Code is read much more often than it is written. Optimize for the reader.

---

## Core Principles

### 1. Follow conventions

Follow the conventions of the programming language you're using, but also follow the conventions of the rest of the codebase (e.g. what docstring style do they use? do they prefer early returns in functions?)

Good code is code that is easily understood by the rest of the team, who read and write in a specific style - honor that style.

### 2. Docstrings - Always Document Your Code

Every function, class, module, and method must have a docstring explaining:

- **What** the code does (the behavior, not the implementation)
- **Why** it exists (the business or technical purpose)
- **Parameters** and their types
- **Return value** and its type
- **Exceptions/Errors** that can be raised
- **Examples** (when the behavior is non-obvious)

### 3. Comments - Explain WHY, Not WHAT

Code shows WHAT it does. Comments should explain WHY it does it that way.

---

## Small Functions

Write small, focused functions that do one thing well.

- **Ideal:** 1-10 lines of code
- **Acceptable:** 10-20 lines
- **Getting too long:** 20-50 lines
- **Definitely too long:** 50+ lines

## Good Function Names

- Names should clearly state what the function does and why you'd call it.
- For booleans, use verbs like `is`, `has`, `can`, `should` to make it clear they're booleans.

---

## Defensive Coding

Write code that assumes things will go wrong and handles it gracefully. Examples:

- Type narrowing and guards
- Validate external input
- Null checks before use

---

## Avoid Deep Nesting

Nested code is harder to understand. Keep nesting shallow. Achieve this by:

- Extracting helper functions
- Limiting nesting depth to 2-3 levels

---

## Single Responsibility Principle (SRP)

Every function, class, and module should have one reason to change.

- One Responsibility Per FunctioV
- One Responsibility Per Class

---

## DRY - Don't Repeat Yourself

- Don't duplicate code. Extract common patterns into reusable functions.
- Consolidate Similar Functions

---

## Additional Best Practices

- Error Messages Should Be Helpful
- Avoid Magic Numbers and Strings
- Keep Functions Predictable
- Use Enums for Known Sets of Values
- Avoid Flag Parameters

---

## Clean Code Checklist

Before submitting code, verify:

- ☐ **All functions/classes have docstrings** describing what, why, parameters, return, and exceptions
- ☐ **Comments explain WHY, not WHAT** - No comment just repeats the code
- ☐ **Functions are small** - Most are under 20 lines, none over 50
- ☐ **Function names are descriptive** - You can understand the intent from the name
- ☐ **Variables are clearly named** - No single letters except in tight scopes
- ☐ **No type errors** - All inputs are validated before use
- ☐ **No magic numbers or strings** - All constants are named
- ☐ **No code duplication** - Common patterns are extracted into reusable functions
- ☐ **Error messages are helpful** - Specific and actionable
- ☐ **Functions are predictable** - No surprising side effects
- ☐ **Maximum nesting is 2-3 levels** - Complex logic is extracted
- ☐ **Each class/function has one responsibility** - Only one reason to change
