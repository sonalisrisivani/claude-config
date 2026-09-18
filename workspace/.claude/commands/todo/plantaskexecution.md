# Plan Task Execution

When invoked:
1. Read `tasks/task-log.jsonl` to find the most recent pending task (or ask the user which task to plan if multiple are pending).
2. Break the task into clear, actionable implementation steps.
3. For each step, note:
   - What needs to happen
   - Which files/tools will be involved
   - Any dependencies or prerequisites
4. Write the full execution plan as a formatted markdown report into `tasks/plans/<task-id>-plan.md`.
5. After writing, confirm: "📋 Plan saved to `tasks/plans/<task-id>-plan.md`" and show a short summary of the steps.
6. Ask the user if they want to start executing the plan right away.
