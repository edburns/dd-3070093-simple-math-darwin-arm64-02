## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`

The resolved repository-validation decision is concrete: acceptance is defined by `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`; `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that repository-owned runner. Do not replace, bypass, or weaken either path.

The resolved behavior contract is concrete: direct CLI execution writes exactly one result line to stdout in the form `Fibonacci(N) = value`; functions return a numeric value without incidental output; inputs are non-negative integers; and the implementation and test files are the repository-root `math-tool.ps1` and `math-tool.Tests.ps1`.

No spike subdirectories or additional spike findings exist in the campaign resources. Implement from the plan's resolved contracts and the repository's production dependencies; do not introduce or transplant research code.

## Branch and execution order

Use `experiment/shepherd-control` from remote `origin` as the base branch for the pull request.

This is implementation subsection 1 of 2. The tasks are assigned, completed, and merged serially in plan order. Do not begin work until this issue is assigned. Task 2 must not begin until this task is merged into the base branch.

## Implement

Create repository-root `math-tool.ps1` with:

- A script parameter named `N` that accepts a non-negative integer.
- A pure `Get-Fibonacci` function that computes and returns the numeric Fibonacci value. It must not write status, progress, formatting, or other incidental output.
- Direct-execution behavior that invokes `Get-Fibonacci` and writes exactly `Fibonacci(N) = value` followed only by the normal line terminator.
- Dot-source behavior suitable for unit tests: importing the script must expose the function without emitting the direct-execution result line.

Use the conventional sequence `Fibonacci(0) = 0`, `Fibonacci(1) = 1`, and each later value as the sum of the prior two. Reject values outside the resolved non-negative-integer input contract through normal PowerShell parameter validation or a clear terminating error; do not silently coerce an invalid value into a valid one.

Create repository-root `math-tool.Tests.ps1` with:

- Dot-sourced Pester unit tests that call `Get-Fibonacci` directly.
- Unit coverage for `N=0`, `N=1`, and at least one small representative value greater than 1.
- Isolated child-`pwsh` process tests that invoke `math-tool.ps1` as a CLI, rather than accidentally exercising the dot-sourced test scope.
- CLI assertions covering the same edge and representative cases and comparing complete stdout so extra output, labels, or lines fail the test.
- An assertion that the function result is numeric and that calling it produces no additional success-stream output.

Keep the implementation deterministic, objective, and small. Use production script behavior in production tests; do not add alternate runners or dependencies.

## Completion gates

- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero.
- The pinned pull-request workflow using Pester 5.7.1 passes.
- Unit tests prove `Get-Fibonacci 0` returns numeric `0`, `Get-Fibonacci 1` returns numeric `1`, and a representative input returns the correct numeric value without incidental output.
- Isolated CLI tests prove the complete stdout for those inputs is exactly one `Fibonacci(N) = value` line.
- Dot-sourcing `math-tool.ps1` does not emit the CLI result line.
- Invalid negative input cannot produce a success-shaped Fibonacci result.
- Only `math-tool.ps1` and `math-tool.Tests.ps1` are changed unless a directly necessary repository-owned test fix is required and justified in the pull request.

## Out of scope

- Factorial, operation dispatch, or task 2 work.
- Replacing or bypassing `eng/test-math-tool.ps1`, the existing workflow, or pinned Pester 5.7.1.
- New modules, packages, workflows, dependencies, UI, persistence, networking, or unrelated refactors.
- Reading, copying, or adapting spike source code.
