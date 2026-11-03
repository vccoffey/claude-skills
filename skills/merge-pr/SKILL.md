---
name: merge-pr
description:
  Merge a pull request. Use whenever a PR is to be merged, whether asked
  directly or as the last step of another skill. Not for PRs opened by bots.
---

# Merge PR

- A PR opened by a bot (`gh pr view <n> --json author` shows `is_bot: true`,
  e.g. renovate, dependabot) is out of scope: follow that bot's own workflow, or
  ask the user if there is none.
- Merge only where the user's instructions allow it. A repo whose PRs need an
  approving review is merged only once the PR has one; until then, stop and say
  so.

## Steps

1. If the PR is a draft, mark it ready for review (`gh pr ready <n>`).
2. If it has conflicts with its base, stop. They are resolved by the caller or
   the user, then this skill starts again.
3. Wait for CI checks (`gh pr checks <n> --watch`). If any fail, stop and report
   them.
4. Merge with
   `gh pr merge <n> --squash --delete-branch --subject <s> --body <b>`, unless
   the user, the caller or the repo's instructions name another merge method for
   this PR. Word the subject and body tightly: what changed and why, with
   user-facing changes first and technical detail after. Leave out notes about
   how the PR was produced, such as review findings and whether they were fixed
   or skipped; those stay in the PR description.
5. Report what merged.
