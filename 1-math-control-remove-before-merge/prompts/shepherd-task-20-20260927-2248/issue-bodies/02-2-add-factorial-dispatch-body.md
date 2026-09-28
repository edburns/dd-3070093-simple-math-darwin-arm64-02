## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`
- `### 2. Add factorial and operation dispatch`

The resolved repository-validation decision is concrete: acceptance is defined by `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`; `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that repository-owned runner. Do not replace, bypass, or weaken either path.

The resolved behavior contract is concrete: direct CLI execution writes exactly one result line to stdout in the form `Fibonacci(N) = value` or `Factorial(N) = value`; functions return numeric values without incidental output; inputs are non-negative integers; task 2 starts only after task 1 is merged; and the implementation and test files remain the repository-root `math-tool.ps1` and `math-tool.Tests.ps1`.

No spike subdirectories or additional spike findings exist in the campaign resources. Implement from the plan's resolved contracts and the repository's production dependencies; do not introduce or transplant research code.

## Branch and execution order

Use `experiment/shepherd-control` from remote `origin` as the base branch for the pull request.

This is implementation subsection 2 of 2. The tasks are assigned, completed, and merged serially in plan order. Do not begin work until this issue is assigned and task 1 has been merged into the base branch. Start from the merged task 1 implementation and preserve its accepted Fibonacci behavior and tests.

## Implement

Extend repository-root `math-tool.ps1` with:

- A pure `Get-Factorial` function that returns the numeric factorial value and emits no status, progress, formatting, or other incidental output.
- An `Operation` parameter that dispatches between `fibonacci` and `factorial` while retaining the existing non-negative-integer `N` parameter.
- A default of `fibonacci` for `Operation`, preserving the task 1 invocation that supplies only `N`.
- Direct CLI output of exactly `Fibonacci(N) = value` for the Fibonacci operation or `Factorial(N) = value` for the factorial operation, followed only by the normal line terminator.
- Clear parameter validation so unsupported operations and negative inputs terminate with an error rather than producing success-shaped output.
- Dot-source behavior that exposes both pure functions without running CLI dispatch.

Use the conventional definition `Factorial(0) = 1`, `Factorial(1) = 1`, and for larger non-negative integers the product from 1 through `N`.

Extend repository-root `math-tool.Tests.ps1` to cover:

- Direct unit calls to `Get-Factorial` for `N=0`, `N=1`, and at least one small representative value greater than 1.
- Numeric return type and absence of incidental success-stream output from `Get-Factorial`.
- Isolated child-`pwsh` process coverage for factorial CLI output, comparing complete stdout so extra output, labels, or lines fail.
- Explicit dispatch coverage for both `fibonacci` and `factorial`.
- Regression coverage proving the merged task 1 Fibonacci unit behavior and exact CLI output remain unchanged, including invocation without `Operation`.
- Rejection of an unsupported operation and a negative input without a success-shaped result.

Keep the interface, implementation, and tests objective and small. Extend the existing production tests rather than adding a parallel test harness.

## Completion gates

- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero for the combined regression suite.
- The pinned pull-request workflow using Pester 5.7.1 passes.
- Unit tests prove `Get-Factorial 0` and `Get-Factorial 1` return numeric `1`, and a representative input returns the correct numeric value without incidental output.
- Isolated CLI tests prove factorial stdout is exactly one `Factorial(N) = value` line.
- Explicit and default Fibonacci dispatch both preserve the task 1 numeric results and exact `Fibonacci(N) = value` output.
- Dot-sourcing `math-tool.ps1` emits no CLI result and exposes both functions.
- Unsupported operations and negative inputs cannot produce success-shaped output.
- Changes remain limited to `math-tool.ps1` and `math-tool.Tests.ps1` unless a directly necessary repository-owned test fix is required and justified in the pull request.

## Out of scope

- Additional mathematical operations or alternate factorial/Fibonacci interfaces.
- Replacing or bypassing `eng/test-math-tool.ps1`, the existing workflow, or pinned Pester 5.7.1.
- New modules, packages, workflows, dependencies, UI, persistence, networking, or unrelated refactors.
- Reading, copying, or adapting spike source code.
