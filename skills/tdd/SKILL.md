# Test-Driven Development (TDD)

## Overview

This skill enforces write-tests-first methodology for all code changes. TDD is a disciplined approach to software development that emphasizes writing tests before implementation code.

## The TDD Process: Red-Green-Refactor

### 1. Red - Write a Failing Test

- Write a test that defines the desired behavior
- Run the test and watch it fail (this confirms the test is actually testing something)
- The failure message should clearly indicate what's missing

### 2. Green - Make It Pass

- Write the minimum code necessary to make the test pass
- Don't worry about perfection - just make it work
- Run the test and verify it passes

### 3. Refactor - Improve the Code

- Clean up the implementation without changing behavior
- Remove duplication
- Improve naming and structure
- Run tests to ensure behavior is preserved

---

## Best Practices

### DO

✅ **Write tests first, always**

- Never write implementation code before the test
- Exception: exploratory spikes (throw away after learning)

✅ **Write one test at a time**

- Focus on a single behavior per test
- Complete the Red-Green-Refactor cycle before moving on

✅ **Keep tests focused and isolated**

- Each test should verify one specific behavior
- Tests should not depend on each other
- Use setup/teardown to ensure clean state

✅ **Use descriptive test names**

- Name should describe the behavior being tested
- Format: `test_<scenario>_<expected_behavior>`
- Examples:
  - `test_empty_cart_returns_zero_total`
  - `test_invalid_email_raises_validation_error`

✅ **Follow the AAA pattern**

- **Arrange**: Set up test data and preconditions
- **Act**: Execute the code under test
- **Assert**: Verify the expected outcome

✅ **Test behavior, not implementation**

- Focus on what the code does, not how it does it
- This allows refactoring without breaking tests

✅ **Aim for 80%+ code coverage**

- All critical paths should be tested
- Edge cases and error conditions must be covered

✅ **Write tests at the appropriate level**

- Unit tests: Fast, isolated, test individual functions/methods
- Integration tests: Test component interactions
- E2E tests: Test complete user workflows (use sparingly)

✅ **Keep tests fast**

- Fast tests encourage running them frequently
- Mock external dependencies (databases, APIs, file systems)
- Use in-memory implementations when possible

✅ **Make tests deterministic**

- Tests should always produce the same result
- Avoid relying on current time, random values, or external state
- Use test doubles (mocks, stubs, fakes) for non-deterministic dependencies

✅ **Test edge cases and error conditions**

- Empty collections
- Null/undefined values
- Boundary values (min, max, zero, negative)
- Invalid input
- Error scenarios

### DON'T

❌ **Don't write implementation before tests**

- This defeats the purpose of TDD
- You lose the design feedback that TDD provides

❌ **Don't write multiple tests before implementation**

- Stick to one Red-Green-Refactor cycle at a time
- Exception: Can write multiple test stubs with `skip` to capture ideas

❌ **Don't test implementation details**

- Avoid testing private methods directly
- Don't assert on internal state unless necessary
- Tests should not break when you refactor

❌ **Don't write tests that are too broad**

- Each test should have a single reason to fail
- If a test fails, it should be immediately obvious what broke

❌ **Don't ignore failing tests**

- Every test should pass all the time
- Fix or remove broken tests immediately
- Never commit failing tests

❌ **Don't write tests that depend on execution order**

- Tests must be able to run in any order
- Tests must be able to run in isolation

❌ **Don't mock everything**

- Over-mocking makes tests brittle
- Test with real objects when practical
- Mock at architectural boundaries (I/O, external services)

❌ **Don't duplicate production logic in tests**

- Tests should verify behavior, not replicate implementation
- If you copy-paste production code into tests, you're testing nothing

❌ **Don't skip the refactor step**

- Refactoring is critical for maintaining clean code
- Tests give you confidence to refactor safely

❌ **Don't write slow tests**

- Slow tests won't get run frequently
- Mock external dependencies
- Use test databases that can be quickly reset

---

## What is a Good Test?

### Characteristics of Good Tests

1. **Fast**
   - Runs in milliseconds
   - No real I/O operations
   - No sleeps or arbitrary waits

2. **Isolated**
   - Does not depend on other tests
   - Does not depend on external state
   - Sets up its own preconditions
   - Cleans up after itself

3. **Repeatable**
   - Produces same result every time
   - Not affected by time, randomness, or environment

4. **Self-Validating**
   - Has clear pass/fail outcome
   - No manual inspection required
   - Assertions are explicit and meaningful

5. **Timely**
   - Written before the production code (TDD)
   - Tests current behavior, not outdated functionality

6. **Readable**
   - Clear test name describing the scenario
   - Easy to understand what's being tested
   - Clear failure messages

7. **Maintainable**
   - Uses test helpers/fixtures to reduce duplication
   - Not brittle - doesn't break with minor refactoring
   - Focused on behavior, not implementation

---

## What is a Bad Test?

### Anti-Patterns

1. **Testing Implementation Details**

   ```typescript
   // BAD: Tests how it works, not what it does
   test("uses Array.reduce to calculate total", () => {
     const cart = new ShoppingCart();
     const reduceSpy = jest.spyOn(Array.prototype, "reduce");
     cart.getTotal();
     expect(reduceSpy).toHaveBeenCalled();
   });
   ```

2. **Tests That Are Too Broad**

   ```typescript
   // BAD: Tests everything at once
   test("shopping cart works correctly", () => {
     const cart = new ShoppingCart();
     cart.addItem(item1);
     cart.addItem(item2);
     cart.removeItem(item1.id);
     cart.applyDiscount(10);
     const total = cart.getTotal();
     expect(total).toBe(45.0);
     expect(cart.items.length).toBe(1);
   });
   ```

3. **Tests with No Assertions**

   ```typescript
   // BAD: Doesn't actually verify anything
   test("processes order", () => {
     const order = new Order();
     order.process(); // What are we testing?
   });
   ```

4. **Tests That Depend on Order**

   ```typescript
   // BAD: Test2 depends on Test1 running first
   let sharedCart;

   test("test1: adds item to cart", () => {
     sharedCart = new ShoppingCart();
     sharedCart.addItem(item);
   });

   test("test2: calculates total", () => {
     expect(sharedCart.getTotal()).toBe(10.0);
   });
   ```

5. **Slow Tests**

   ```typescript
   // BAD: Actually talks to a real database
   test("saves user to database", async () => {
     const db = await connectToDatabase();
     const user = await db.users.create({ name: "Test" });
     expect(user.id).toBeDefined();
   });
   ```

6. **Non-Deterministic Tests**

   ```typescript
   // BAD: Uses current time, will fail in the future
   test("user is adult", () => {
     const user = new User({ birthDate: "2000-01-01" });
     expect(user.isAdult()).toBe(true); // Will fail in 2000 years!
   });
   ```

7. **Overly Complex Tests**

   ```typescript
   // BAD: Too much logic in the test itself
   test("processes multiple scenarios", () => {
     const scenarios = getTestScenarios();
     for (const scenario of scenarios) {
       if (scenario.type === "discount") {
         // complex logic here
       } else if (scenario.type === "tax") {
         // more complex logic
       }
     }
     expect(results).toMatchComplexCondition();
   });
   ```

---

## When to Use TDD

### Always Use TDD For

- ✅ New features
- ✅ Bug fixes (write a failing test that reproduces the bug first)
- ✅ Refactoring (tests ensure behavior is preserved)
- ✅ Business logic and algorithms
- ✅ Data transformations
- ✅ Utility functions

### Consider Alternatives For

- 🤔 UI/visual design (use after initial design is established)
- 🤔 Exploratory programming (spike then throw away and TDD the real version)
- 🤔 Proof of concepts (but TDD the real implementation)
- 🤔 Configuration/glue code (if trivial)

---

## Testing Patterns

### Test Doubles

**Mock**: Verifies behavior (that a method was called)

```typescript
const logger = jest.fn();
service.process(logger);
expect(logger).toHaveBeenCalledWith("Processing...");
```

**Stub**: Provides canned responses

```typescript
const userRepo = {
  findById: () => ({ id: 1, name: "Test User" }),
};
```

**Fake**: Working implementation (simpler than real thing)

```typescript
class FakeDatabase {
  private data = new Map();
  save(key, value) {
    this.data.set(key, value);
  }
  get(key) {
    return this.data.get(key);
  }
}
```

### Parameterized Tests

Test multiple scenarios with the same logic:

```typescript
describe("isValidEmail", () => {
  test.each([
    ["valid@example.com", true],
    ["invalid@", false],
    ["@invalid.com", false],
    ["user@domain.co.uk", true],
  ])("returns %s for %s", (email, expected) => {
    expect(isValidEmail(email)).toBe(expected);
  });
});
```

---

## Coverage Guidelines

- **80%+ overall coverage** is the target
- **100% coverage of:**
  - Business logic
  - Algorithms
  - Security-critical code
  - Error handling paths

- **Lower priority for coverage:**
  - Simple getters/setters
  - Framework boilerplate
  - Configuration code

**Coverage is a metric, not a goal.** Focus on testing important behaviors, not achieving a percentage.

---

## Common Pitfalls

1. **Writing tests after code** - This is not TDD
2. **Skipping failing tests** - Fix them or remove them
3. **Not running tests frequently** - Run after every change
4. **Testing too much at once** - Keep tests focused
5. **Not refactoring** - Tests enable safe refactoring, use them
6. **Mocking too much** - Creates brittle tests
7. **Not testing edge cases** - Most bugs hide in edge cases
8. **Writing slow tests** - Kills the TDD rhythm

---

## TDD Workflow Checklist

For every feature or bug fix:

1. ☐ Write a failing test that describes the desired behavior
2. ☐ Run the test and verify it fails (RED)
3. ☐ Write the minimum code to make the test pass
4. ☐ Run the test and verify it passes (GREEN)
5. ☐ Refactor the code while keeping tests green (REFACTOR)
6. ☐ Run all tests to ensure nothing broke
7. ☐ Commit with both test and implementation
