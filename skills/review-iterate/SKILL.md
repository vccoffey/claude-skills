---
name: review-iterate
description: refine a commit or PR until good.
disable-model-invocation: true
---

# Review Iterate

Take a task from a shared understanding of what to build through to a commit
that passes every pre-push check. Interview first, implement autonomously, then
loop gpush and fix what it reports until it passes. If the user asked for it,
push, then loop a code review of the PR until it is clean, and merge if asked.

## Workflow

1.  Depending when this skill was invoked, this step may or may not be already
    complete. Reach a shared understanding of the task with
    /questions-one-at-a-time, including whether the work ends at a local pass
    only (gpush `--dry-run`), a push, or a reviewed and merged PR.

2.  Determine that you have everything needed to complete your task.
    - Permission to make and amend git commits, and any ruby gems and npm
      packages installed.
    - If browser testing will be part of the task, that your branch is or can be
      checked out in the main checkout and that the server is running.

3.  Complete the task. Prefer mattpocock-skills:tdd as your methodology, but you
    may also use in-browser testing or another workflow as appropriate. Decide
    the rest yourself.
    - Follow the repo's own instructions (CLAUDE.md, AGENTS.md, memory).
    - Check the local development database, if there is one. It is probably a
      copy of production data, and code should be built for real data, not
      hypothetical data.
    - When you think you are complete, make one or more git commits with a
      detailed explanation of the code changes and their purpose. Document
      anything unusual in the git commit message.

4.  Local loop. Repeat the following as many times as necessary.

    a. Execute the gpush skill, with `--dry-run` unless the work ends in a push,
    and read the exit code from the tool result.

    b. If gpush exits zero, continue to the next step. Otherwise, read the
    failures from its output. If anything requires a decision by the user, break
    the local loop and return to step 1 (remembering prior decisions).

    c. Handle each failure as the gpush skill's "When a check fails" section
    says.

    d. Make the fixes on your own. If your code is correct and the instructions
    in the gpush output should not be followed, document the reasons in the
    commit message. While the branch is unpushed, amend the commit with every
    fix; once it has been pushed, add each fix as a new commit. Commit before
    every pass: gpush runs on committed work only.

5.  PR loop, if part of the initial instructions.

    a. Make a draft PR if one does not already exist.

    b. Before each review, bring the PR description up to date: decisions the
    user made, findings skipped and why (5d, 5e), stalemated findings (Rules),
    and possible follow-ups with why each is out of scope. Put the same notes in
    the commit message (amend while unpushed, else in the next fix commit): the
    gpush review sees commit messages but never the PR description.

    c. Review the PR with the code-review skill (`PR <number>`). Use the default
    effort unless instructed otherwise.

    d. Reject fixes that add undue complexity to address issues that cannot or
    likely will not arise; make sure such cases are reported well instead.
    Record each finding you disagree with, or the user has decided against, as
    5b says.

    e. A review counts as clean when it returns only edge-case nits, or issues
    already on the base branch that aren't straightforward to fix. Never treat
    these as nits: data loss or corruption, a crash or error page on input a
    user can produce in normal use, a security issue, or a deploy-time breakage.
    A crash only deliberately crafted input reaches, with no data at risk, falls
    under 5d when only signed-in users can send that input; on a page the public
    can reach, treat it as a security issue. The PR is ready when it improves
    the codebase overall and breaks nothing that works on the base branch.

    f. If the review raises issues that should be fixed, fix them and return to
    step 4. If it is clean, continue to the next step.

6.  PR Processing, if part of the initial instructions.

    a. If the PR is a draft, mark it ready for review.

    b. If the PR has conflicts with its base, merge the base in and return to
    step 4.

    c. If the PR loop ended with findings skipped as nits (step 5e), it is not
    merged automatically: explain to the user which findings you skipped and
    why, give them your recommendation, and merge only once they approve.

    d. Wait for any CI checks on the PR (`gh pr checks <number> --watch`). If
    they pass, or there are none,
    `gh pr merge <number> --squash --delete-branch`, subject to 6c. If tests
    fail, and they can be fixed, fix them and return to step 4.

7.  Inform the user that you have finished, and report the assumptions you made
    and anything still needing their attention. If any issues were discovered
    that were out of scope for this PR but warrant attention, propose one or
    more follow-up PRs.

## Rules

- A finding is **stalemated** when it survives two passes despite your
  justification, or when a pass only reverses what the previous one asked for.
  The gpush claude review is non-deterministic and may not honour a
  justification. Stop arguing a stalemated finding: record it with your
  reasoning (5b) and keep looping on everything else. A pass that finds new real
  defects is progress, not a stall; fix them. Leave the loop only when nothing
  is left but stalemates and nits, then surface the stalemates to the user.

- If the fixes keep widening the scope beyond the task agreed in step 1, that is
  a decision for the user (step 4b). Ask, after fixing the defects that are
  inside the agreed scope.

- As part of step 3, you may run targeted tests (eg rspec or jest), but do not
  run the entire test suite. Instead, move on to the local loop; the gpush
  command will run tests.

- Merge only where the user's instructions allow it. A repo whose PRs need an
  approving review first is merged by its people, not by this skill.
