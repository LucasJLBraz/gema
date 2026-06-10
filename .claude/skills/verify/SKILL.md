---
name: verify
description: Run flutter analyze and flutter test, then report any issues found. Use after making code changes to confirm correctness before committing.
---

Run the following checks in order and report results:

1. **Static analysis:** `flutter analyze`
   - List every error and warning with file path and line number.
   - If there are errors, stop and report — do not proceed to tests.

2. **Tests:** `flutter test`
   - Report pass/fail counts and any failing test names with their error messages.
   - If integration tests need the emulator and it is not running, note that and run only `flutter test test/` (unit + widget tests).

3. **Summary:** one-line verdict — "All checks passed" or "N issues found" with a prioritized fix list.
