---
name: can-i-close
description: Check whether this chat can be closed, and close it if so — what this session still has running, and what open work would be lost with its context.
disable-model-invocation: true
---

# Can I close the chat?

## Scope: this session only

Report only what this session started, changed or was asked to do.

Leave out anything from another session:

- background tasks, agents, workflows or gpush runs you did not launch;
- worktrees, branches, commits or stashes this session did not make;
- uncommitted changes in files this session did not touch.

If you can't tell whether something is yours, leave it out. Don't mention
that you left anything out.

## Check before answering

Check the current state; don't rely on memory, because the user may have
changed things since:

1. Your background tasks: Bash jobs, agents, workflows and gpush runs you
   launched. Note which are still running.
2. Git, for repos this session worked in: `git status -sb` and the commits
   this session made. Note any that are unpushed, uncommitted, or on a
   local-only branch.
3. Browser tabs and worktrees you created: close the tabs and remove the
   worktrees (`git worktree remove`) before answering. Nothing else will ever
   remove a worktree made with `git worktree add`. Don't use `--force`: a
   worktree with uncommitted changes stays, and it means the chat isn't ready
   to close.
4. External runs you kicked off and are waiting on, such as CI on a PR you
   pushed. These carry on without the chat, so they aren't a reason to wait.

## Answer

Open with one line of verdict:

- "Nothing open — closing the chat."
- "Wait: <what is running, and roughly when it finishes>."
- "Not yet: <the open work>."

The verdict is "Nothing open" only if none of these hold:

- a background task you launched is still running;
- a repo or worktree this session worked in has uncommitted changes in files
  this session touched (the main checkout counts, not just worktrees); name
  the files and ask whether to commit or discard them;
- commits this session made are unpushed or on a local-only branch;
- the user hasn't answered a decision you asked for;
- work you were asked to do is half done, or lost and needing redoing.

Then list each open item in one short bullet, enough for the user to pick it
up in a new session without this chat. Also list, without letting them block
the close:

- follow-ups you raised but nobody acted on;
- external runs you are waiting on, such as CI on a PR you pushed.

Leave out completed work and anything a new session would find on its own.

Don't start new work, and don't offer to.

## Close the chat

If the verdict was "Nothing open", write the whole answer first. The screen
clears when the session ends, so also write the same answer, as plain text, to
a file in the scratchpad directory. Then end the session by running
`~/.claude/skills/can-i-close/close-session.sh <that file>` as the last thing
in the turn. It sends SIGTERM to this session's `claude` process, and the
shell prints the file before its next prompt, then deletes it.
SessionEnd hooks still run, and the transcript is already saved.

On a "Wait" or "Not yet" verdict, don't close, and don't run the script. The
user overrides with `/exit`.
