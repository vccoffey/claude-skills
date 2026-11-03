---
name: gpush
description:
  Run gpush (runs pre-push checks, then git pushes iff they pass) on the user's
  behalf. Use when asked to run gpush.
---

# gpush

gpush runs a repo's own checks from `gpushrc.yml` — `pre_run`, then
`parallel_run`, then the `post_run` sections — and pushes only if everything
passed. A repo has it if there is a `gpushrc.yml` or `gpushrc.yaml` at or above
the working directory.

## Running it

Run the following command, modified if the user requests different arguments
(such as --dry-run)

```sh
~/.claude/skills/gpush/run-gpush.sh --no-spinner --set-upstream
```

`run-gpush.sh` passes its arguments to gpush. It keeps the Mac awake for the run
with `caffeinate -ims` (idle, disk and system sleep; the display may still
sleep), and interrupts gpush with SIGINT if it is still running after an hour, a
second SIGINT 30s later if needed, so a hung run never keeps the machine awake
indefinitely. Set `GPUSH_TIMEOUT` (seconds) for a longer limit. A timed-out run
prints `gpush still running after …s: interrupting it` and exits 1; report it as
a hang, not a check failure.

- **Always `run_in_background: true`; never pipe it** (`| tail`, `| grep`): a
  pipe reports the last command's exit code, not gpush's. The background task
  already keeps the full output.
- **`--no-spinner`** — the live spinner is noise in captured output.
- **Don't skip:** never use suggest --skip on your own. Follow the user's
  instructions, but do not store any memory of it beyond the session.
- **`-u` / `--set-upstream`** — pass it. gpush's prompts read single keypresses,
  so with no terminal it takes each question's default, and the one question
  with no default ("No remote branch set. Create branch on origin if tests
  pass?") aborts the run unless `-u` answers it ahead of time. It also means a
  branch with no remote branch yet gets created on origin, after the checks
  pass, with nothing asking first. If the user has not clearly asked for this
  branch to be pushed, confirm first or run `--dry-run`.
- **`--dry-run`** to run the checks without pushing. It also skips the
  `git fetch` and branch-state checks that precede the push. Use it when
  iterating on fixes, or when the user has not asked for a push.
- **Use `--dry-run` whenever the local branch has diverged from its remote** —
  after a rebase, squash, amend or reset. gpush cannot push it, so without
  `--dry-run` it runs the checks anyway and exits 2 (gpush 2.17.2+). `--dry-run`
  says what you mean and skips the branch-state checks entirely. The push then
  has to be done separately with `--force-with-lease`.
- **`-v` / `--verbose`** streams every command's output instead of printing it
  only on failure. Default is quieter and usually enough — the failing command's
  output is shown either way.
- **`--worktree`** may be added to the command optionally. Pass it when the
  repo's `gpushrc.yml` sets `worktree: true`, or when the user asks. If running
  in worktree mode, you can continue to edit files in the main directory and
  make new commits while gpush is running, but avoid running rspec until the
  gpush rspec has completed.

## Stopping a run

If a run has to be stopped, interrupt it gracefully with SIGINT, the same signal
as Ctrl-C. Do **not** use TaskStop. TaskStop sends SIGTERM and then force-kills,
which skips `post_run` and can leave a worktree behind in `$TMPDIR`.

1. Find gpush's own process, the `ruby …/gpush.rb` under `run-gpush.sh`:
   `ps -o pid,lstart,command -p "$(pgrep -d, -f 'gpush\.rb')"`. Other sessions
   may be running gpush too. Pick the one you launched by its start time and
   arguments. If more than one could be yours, ask rather than guess. Never
   `pkill -f gpush`.
2. `kill -INT <pid>`. gpush interrupts each check, prints the summary with
   `《 Interruption detected 》`, runs `post_run` and `post_run_failure`,
   removes its worktree, and exits 1. The task's completion notification
   follows.
3. If it is still running ~30s later (a check ignoring SIGINT), send
   `kill -INT <pid>` once more. That force-quits and still removes the worktree.

## Exit codes

| code | meaning                                                                                      |
| :--- | :------------------------------------------------------------------------------------------- |
| 0    | every check passed — whether it pushed, ran `--dry-run`, or the user declined a prompt       |
| 1    | a check failed, the push was rejected, the git state was unusable, or the config was invalid |
| 2    | every check passed, but nothing was pushed: a detached HEAD, or a branch behind its remote   |

A failing check always exits 1; the individual command's own exit code is not
passed through. Read the code from the tool result rather than inferring success
from the output. Each failing check's name and output are printed even without
`-v`.

## gpush specs and Subcommands

`gpush --help` lists every flag. `gpush <subcommand> --help` documents each
subcommand.
