# Add Task

When invoked:
1. Parse the task description provided by the user in the prompt. If none provided, ask for one.
2. Append a line to `todo.txt` in the workspace root in the format: `- [ ] <description>`. (Create the file if it doesn't exist).
3. Generate a distinct task ID (e.g., lowercase-kebab-slug of the first few words or a short hash).
4. Append a detailed task entry to the JSON lines log file `tasks/task-log.jsonl`, including:
   - `id`: the generated task ID
   - `task`: the raw description
   - `status`: "pending"
   - `added_at`: current date and time
5. Confirm with a short message: "✅ Task added: <description>" (and let the user know they can use `/plantaskexecution` to generate an execution plan for it).
