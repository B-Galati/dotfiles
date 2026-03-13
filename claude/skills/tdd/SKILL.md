---
name: tdd
description: TDD workflow - Write a failing test, then implement Super Green
---

# Claude Code TDD: Red → Super Green

You are executing a **TDD** workflow - a two-step process that leverages AI synthesis capabilities to produce clean, production-ready code without an intermediate "quick and dirty" phase.

We will implement the behavior iteratively, one step at a time.
The user will guide you for each step.
Your role is to write failing tests and implement Super Green.
DO NOT try to implement all behavior at once.
DO NOT try to plan to write any code until STEP 2 is Reached.
Start by writing failing tests.

## The Claude Code TDD Philosophy

### Claude Code TDD (2 Steps)
```
Red → Super Green
```
AI synthesizes clean, architectural code directly - no crappy code phase needed.

## Key Concepts

### What is TRUE RED?

**Compilation errors are NOT RED** - they are part of design discovery ("Programming by Wishful Thinking"). When writing tests, you design the API you wish existed.

**TRUE RED = Behavior failure** once the wished-for API compiles and runs.

- ❌ NOT RED: `Class 'App\Domain\UseCase\Foo\Input' not found`
- ❌ NOT RED: `Method Bar::doSomething() does not exist`
- ✅ TRUE RED: `Failed asserting that 'actual' equals 'expected'`
- ✅ TRUE RED: `ExpectedException was not thrown`

### What is Super Green?

**Super Green** means implementing clean, production-ready code that:
- Follows all architectural patterns
- Requires no subsequent refactoring phase

---

## Workflow Execution

### STEP 1: RED Phase - Write the Failing Test

**Input Required:** $ARGUMENTS

1. **Analyze the Specification**
   - Understand what behavior is being specified
   - Identify the bounded context and use case
   - Determine test type: FunctionalTestCase vs UnitTestCase

2. **Ask Where to Write the Test**
   - Search for existing test files related to the behavior under test
   - Present the user with options:
     - Add the new test method to an existing test file (suggest the most relevant one(s))
     - Create a new test file (suggest a path following project conventions)
   - Wait for the user's answer before writing any test code

3. **Design the API via Programming by Wishful Thinking**
   - Write the test as if the ideal API already exists
   - Use expressive names that reveal intent
   - Follow Given/When/Then structure with comments
   - Use builders for test data setup
   - Use data providers for multiple scenarios when appropriate

4. **Write the Test File**
   - Use correct namespace mirroring source structure
   - Extend appropriate base class

5. **Reach TRUE RED**
   - Run the test
   - If compilation error → Create minimal stub classes to make it compile
   - Keep creating stubs until the test RUNS but FAILS on behavior
   - **Report when TRUE RED is achieved**

**RED Phase Report Format:**
```
══════════════════════════════════════════════════════════════
🔴 RED PHASE COMPLETE
══════════════════════════════════════════════════════════════

📝 Test File: <path>
🎯 Behavior Under Test: <description>
❌ Failure Message: <actual test failure>

🏗️ Stub Files Created (compilation only):
   - <list of minimal stubs>

══════════════════════════════════════════════════════════════
```

### ARCHITECTURAL GUIDANCE MOMENT

After RED, pause and ask:

```
🏛️ ARCHITECTURAL GUIDANCE (Optional)

Before I implement Super Green, do you want to provide any architectural guidance?

Examples:
- "Use a Strategy pattern for the different validation rules"
- "Implement this as an event-driven saga"
- "Avoid any state mutation - use pure functions"
- "Use the existing PaymentGateway interface"

Options:
1. Proceed with standard architectural approach
2. Provide guidance: [your input]
```

### STEP 2: SUPER GREEN Phase - Implement Production-Ready Code

With architectural guidance you know, implement the complete solution.

Then:
1. **Run Tests to Verify**
2. **Run Stack analysis tools**

**SUPER GREEN Phase Report Format:**
```
══════════════════════════════════════════════════════════════
🟢 SUPER GREEN COMPLETE
══════════════════════════════════════════════════════════════

📝 Test: <test file>
✅ Status: PASSING

🏗️ Architectural Decisions:
   - <key decision 1>
   - <key decision 2>

══════════════════════════════════════════════════════════════
```
