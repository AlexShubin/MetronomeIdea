# Project Notes

## Tuist

- To regenerate the Xcode project, run: `mise run generate`
- Always run `mise run generate` after structural changes to the project (adding/removing targets, files, dependencies in Project.swift)

## Code Style

- Always add file headers to new Swift files following the existing pattern:
  ```
  //
  //  FileName.swift
  //  TargetName
  //
  //  Created by Alex Shubin on DD.MM.YY.
  //  Copyright © YYYY Alex Shubin. All rights reserved.
  //
  ```
- Avoid using `any` with protocol types when it's not required. Prefer `let sut: MetronomeViewModelType` over `let sut: any MetronomeViewModelType`.

## Testing

- Never use `Task.sleep` in tests. Design production code to be testable without timing dependencies — use `async` APIs that tests can `await` directly, or `withCheckedContinuation` + `withObservationTracking` for stream-based state propagation.
- Always declare the SUT using the protocol type (e.g., `let sut: MetronomeViewModelType`), not the concrete type. Tests should exercise the object through its public interface only.

