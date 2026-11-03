---
name: monday-pr-body
description:
  Title and opening section of a PR in a repo whose stories are tracked in
  monday. Use when creating a PR, or writing or editing a PR title or body, in
  such a repo.
---

# Title

- Put every monday story id in the title, e.g.
  `Show the alert banner on the page background [ABC-123]`.
- Prefix `[dev-only]` when nothing in the PR is for the tester to test. A PR
  whose monday story has testing steps is never `[dev-only]`. Unsure → ask the
  user.

# Body: opening section

The body opens with this section, for the tester and release planner. Plain
language: no file, component, CSS or code names, no merge risk. Any other
PR-body format (e.g. the `pr` skill's Summary / Evidence / Merge Danger) follows
after a `---`.

```markdown
## Testing & Release

- [<story id>: <monday item name, verbatim>](<monday item URL>)

<One short paragraph summarizing the user-facing change across the whole PR. The
monday story holds the detail; don't repeat it.>

---
```

- One bullet per story.
- No monday story → `No monday story.` in place of the list.
- `[dev-only]` → the paragraph is `Developer-only change; nothing to test.`
- Ships to users but nothing visible changes → say so in one line and name what
  to spot-check.
- Take the item name and URL from monday, through the monday MCP for that repo's
  org; never guess or reword them.
- Link each story here only; don't repeat it elsewhere in the body.
