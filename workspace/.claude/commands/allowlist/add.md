# Add Suggested Patterns to Allowlist

When invoked:
1. Check `.claude/allowlist-pending.jsonl` in the workspace root.
2. If the file doesn't exist or has no `"status": "pending"` entries, tell the user: "No pending allowlist suggestions. Run commands normally, and safe frequent ones will be buffered here."
3. If there are pending entries:
   - Display each pending pattern with its example command in a clean numbered list.
   - If an argument was provided (e.g., `/allowlist:add 1` or `/allowlist:add all`), apply only those selections.
   - If no argument was provided, ask the user to confirm which patterns they want to add (e.g. `all` or a number like `1`).
4. For confirmed patterns:
   - Read `.claude/settings.json` and append the new patterns to `.permissions.allow` (deduplicating against existing entries).
   - Update the status in `.claude/allowlist-pending.jsonl` to `"status": "added"`.
5. Reply with a short confirmation message listing the newly added patterns.
