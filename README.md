# Claude Code skills

Skills I use with [Claude Code](https://claude.com/claude-code), copied here
automatically from my own setup whenever I change them.

| Skill                     | What it does                                                                                                 |
| ------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `why-like-this`           | When you ask Claude why it did something, it traces the behaviour to the wording behind it and rewords that. |
| `review-iterate`          | Takes a task from an interview to a passing commit, then loops code review on the PR until it is clean.      |
| `review-findings`         | Reviews a change, or triages findings handed in, into checked findings classed critical, bug, nit or future. |
| `gpush`                   | Runs [gpush](https://github.com/nitidbit/gpush) (pre-push checks, then push) on your behalf.                 |
| `questions-one-at-a-time` | Interview mode: one question per message until you and Claude share an understanding.                        |
| `can-i-close`             | Checks whether a chat has anything still running or unsaved, and closes it if not.                           |

`review-iterate` uses `gpush`, `questions-one-at-a-time` and `review-findings`,
and also expects the `tdd` skill. `review-findings` expects the `code-review`
skill.

## Install

Clone this repo and link the skills you want into `~/.claude/skills`, so that
`git pull` keeps them up to date:

```sh
git clone https://github.com/vccoffey/claude-skills.git ~/dev/claude-skills
ln -s ~/dev/claude-skills/skills/why-like-this ~/.claude/skills/why-like-this
```

Or copy a skill's folder into `~/.claude/skills/` if you'd rather update by
hand. Each skill is a folder holding a `SKILL.md`, and some hold scripts it
runs; read them before you use them.
