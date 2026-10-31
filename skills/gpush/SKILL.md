---
name: gpush
description: Run gpush (runs pre-push checks, then git pushes iff they pass) on the user's behalf. Use when asked to run gpush.
---

# gpush

gpush runs a repo's own checks from `gpushrc.yml` — `pre_run`, then `parallel_run`, then the `post_run` sections — and
pushes only if everything passed. A repo has it if there is a `gpushrc.yml` or `gpushrc.yaml` at or above the working
directory.

## Running it

Run the following command, modified if the user requests different arguments (such as --dry-run)

```sh
~/.claude/skills/gpush/run-gpush.sh --no-spinner --set-upstream
```

`run-gpush.sh` passes its arguments to gpush. It keeps the Mac awake for the run with `caffeinate -ims` (idle, disk
and system sleep; the display may still sleep), and interrupts gpush with SIGINT if it is still running after an
hour, a second SIGINT 30s later if needed, so a hung run never keeps the machine awake indefinitely. A normal run
takes 10–15 minutes. Set `GPUSH_TIMEOUT` (seconds) for a longer limit. A timed-out run prints
`gpush still running after …s: interrupting it` and exits 1; report it as a hang, not a check failure.

- **Always `run_in_background: true`, and never pipe it** (`| tail`, `| grep`). A full run takes minutes and can exceed
  the foreground timeout. The background task already captures the full output, and a pipe masks gpush's exit code
  with the last command's (`gpush … | tail -60` reports 0 on tail).
- **`--no-spinner`** — the live spinner is noise in captured output.
- **Don't skip:** never use suggest --skip on your own. Follow the user's instructions, but do not store any memory of
  it beyond the session.
- **`-u` / `--set-upstream`** — pass it. gpush's prompts read single keypresses, so with no terminal it takes each
  question's default, and the one question with no default ("No remote branch set. Create branch on origin if tests
  pass?") aborts the run unless `-u` answers it ahead of time. It also means a branch with no remote branch yet
  gets created on origin, after the checks pass, with nothing asking first. If the user has not clearly asked for this
  branch to be pushed, confirm first or run `--dry-run`.
- **`--dry-run`** to run the checks without pushing. It also skips the `git fetch` and branch-state checks that precede
  the push. Use it when iterating on fixes, or when the user has not asked for a push.
- **Use `--dry-run` whenever the local branch has diverged from its remote** — after a rebase, squash, amend or reset.
  gpush cannot push it, so without `--dry-run` it runs the checks anyway and exits 2 (gpush 2.17.2+). `--dry-run` says
  what you mean and skips the branch-state checks entirely. The push then has to be done separately with
  `--force-with-lease`.
- **`-v` / `--verbose`** streams every command's output instead of printing it only on failure. Default is quieter and
  usually enough — the failing command's output is shown either way.
- **`--worktree`** may be added to the command optionally. Pass it when the repo's `gpushrc.yml` sets `worktree: true`, or when the user asks. If running in worktree mode, you can continue to edit files in the main directory and make new commits while gpush is running, but avoid running rspec until the gpush rspec has completed.

## Stopping a run

If a run has to be stopped, interrupt it gracefully with SIGINT, the same signal as Ctrl-C. Do **not** use TaskStop.
TaskStop sends SIGTERM and then force-kills, which skips `post_run` and can leave a worktree behind in `$TMPDIR`.

1. Find gpush's own process, the `ruby …/gpush.rb` under `run-gpush.sh`:
   `ps -o pid,lstart,command -p "$(pgrep -d, -f 'gpush\.rb')"`. Other sessions may be running gpush too. Pick the one
   you launched by its start time and arguments. If more than one could be yours, ask rather than guess. Never
   `pkill -f gpush`.
2. `kill -INT <pid>`. gpush interrupts each check, prints the summary with `《 Interruption detected 》`, runs `post_run`
   and `post_run_failure`, removes its worktree, and exits 1. The task's completion notification follows.
3. If it is still running ~30s later (a check ignoring SIGINT), send `kill -INT <pid>` once more. That force-quits and
   still removes the worktree.

## Exit codes

| code | meaning                                                                                      |
| :--- | :------------------------------------------------------------------------------------------- |
| 0    | every check passed — whether it pushed, ran `--dry-run`, or the user declined a prompt       |
| 1    | a check failed, the push was rejected, the git state was unusable, or the config was invalid |
| 2    | every check passed, but nothing was pushed: a detached HEAD, or a branch behind its remote   |

A failing check always exits 1; the individual command's own exit code is not passed through. Read the code from the
tool result rather than inferring success from the output.

## When a check fails

1. Read the failing command's name and output from the run — a failure prints them even without `-v`.
2. If nothing changed during the run that just finished, proceed with the next step. If you or the user edited files or
   committed while it ran, stop and check with the user.
3. In the chat, report the issues returned from gpush in a format that is visually digestible by a human.
4. Attempt to fix the reported issues, and then re-run gpush.
   - `gpush fix` runs the repo's `fix:` commands (typically `rubocop -a`, `prettier --write`). Cheap first move for
     formatting and lint failures.
   - `gpush run <name>` re-runs a single `parallel_run` entry by name, always verbose — much faster than a whole pass
     while iterating. Matching ignores spaces, dashes and case.
   - Do not edit `gpushrc.yml` to disable, skip or weaken a check to get a green run; if a check looks wrong, say so
     and leave it to the user.
   - Ignore failures that predate the current work and were not introduced by it — but report them.
   - `claude-review` failures are their own thing: exit 1 means it found blocking issues (act on them), 2 means its
     tooling or access failed, 3 means it produced no usable verdict. It is non-deterministic.
     - On exit 2 or 3, retry once, then surface the issue.
     - On exit 1, iterate several times to fix the issues reported. Continue if making progress. If the code is correct
       but the review is failing, try adding the explanation into the git commit message and re-running. If you are
       hitting the same issue repeatedly, stop and report to the user.

## gpush specs and Subcommands

`gpush --help` lists every flag. `gpush <subcommand> --help` documents each subcommand.
