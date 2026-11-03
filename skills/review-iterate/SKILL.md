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

4.  gpush loop. Repeat the following as many times as necessary.

    a. Execute the gpush skill. If the work ends in a push or a PR (step 1), run
    it to push from the first round; use `--dry-run` only when the work ends at
    a local pass. Read the exit code from the tool result.

    b. If gpush exits zero, continue to the next step. Otherwise, read the
    failures from its output. If anything requires a decision by the user, break
    the gpush loop and return to step 1 (remembering prior decisions). If you or
    the user edited files or committed while it ran, check with the user before
    acting on its failures.

    c. Pass only the AI review findings (`claude code review`,
    `claude security review`) to the review-findings skill, and act on its
    classes as 5e says. Fix the class, not the instance: fix each finding
    together with its siblings. If an AI review exits 2 or 3 (tooling failed, no
    verdict), retry once, then surface it. Fix every other failing check
    (linters, tests) directly: `gpush fix` first for formatting and lint,
    `gpush run <name>` to re-run one check. Never edit `gpushrc.yml` to weaken a
    check. Leave failures that predate this work, but report them.

    d. Make the fixes on your own. If your code is correct and the instructions
    in the gpush output should not be followed, document the reasons in the
    commit message. Before every gpush round, fold each fix into the unpushed
    commit it belongs to (amend, or a fixup commit and autosquash rebase). Never
    rewrite pushed commits: a fix to one is a new commit. Collect every finding
    from a pass, fix them all, run the affected spec files, then commit and run
    gpush once: one gpush and one review per round, not one per finding. gpush
    runs on committed work only.

5.  PR loop, if part of the initial instructions.

    a. Make a draft PR if one does not already exist.

    b. Before each review, bring the PR description up to date: decisions the
    user made, findings skipped and why (5d, 5e), stalemated findings (Rules),
    and possible follow-ups with why each is out of scope. Put the same notes in
    the commit message (amend while unpushed, else in the next fix commit): the
    gpush review sees commit messages but never the PR description.

    c. Review the PR with the review-findings skill (`PR <number>`).

    d. Reject fixes that add undue complexity to address issues that cannot or
    likely will not arise; make sure such cases are reported well instead.
    Record each finding you disagree with, or the user has decided against, as
    5b says.

    e. Act on each finding by its review-findings class:
    - **critical** and **bug**: fix it, subject to 5d and the stalemate rule.
    - **nit**: fix it when cheap (a few lines, no design change); otherwise
      record it (5b).
    - **future**: leave it; list it in the PR description as a possible
      follow-up, with its reason.

    A review counts as clean when only unfixed nits and future findings remain.
    The PR is ready when it improves the codebase overall and breaks nothing
    that works on the base branch.

    f. If the review raises issues that should be fixed, fix them and return to
    step 4. If it is clean, continue to the next step.

6.  Merge, if part of the initial instructions.

    a. If the PR has conflicts with its base, merge the base in and return to
    step 4.

    b. If the PR loop ended with findings skipped as nits (step 5e), it is not
    merged automatically: explain to the user which findings you skipped and
    why, give them your recommendation, and merge only once they approve.

    c. Run the merge-pr skill. If it stops on failing CI checks that can be
    fixed, fix them and return to step 4.

7.  Inform the user that you have finished, and report the assumptions you made
    and anything still needing their attention. If the reviews found future
    findings that warrant attention, propose one or more follow-up PRs.

## Rules

- A finding raised again after you recorded it costs a whole cycle every time it
  returns. If it is cheap to fix (a few lines, no design change), fix it rather
  than record it again. Only a finding that is costly, wrong, or contrary to a
  user decision becomes **stalemated** when it survives two passes despite your
  justification, or when a pass only reverses what the previous one asked for.
  The gpush claude review is non-deterministic and may not honour a
  justification. Stop arguing a stalemated finding: record it with your
  reasoning (5b) and keep looping on everything else. A pass that finds new real
  defects is progress, not a stall; fix them. Leave the loop only when nothing
  is left but stalemates and nits, then surface the stalemates to the user.

- Aim for the first full review to come back clean.

- If the fixes keep widening the scope beyond the task agreed in step 1, that is
  a decision for the user (step 4b). Ask, after fixing the defects that are
  inside the agreed scope.

- As part of step 3, you may run targeted tests (eg rspec or jest), but do not
  run the entire test suite. Instead, move on to the gpush loop; the gpush
  command will run tests.
