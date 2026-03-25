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

## Testing

- Never use `Task.sleep` in tests. Design production code to be testable without timing dependencies — e.g., expose synchronous methods like `applyState` or use `async` APIs that tests can `await` directly.
