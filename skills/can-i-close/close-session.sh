#!/bin/sh
# Ends the Claude Code session this shell runs under, by sending SIGTERM to the
# nearest ancestor process named "claude". Prints its pid and exits 1 if none.
# Given a message file, moves it to ~/.claude/close-message-<tty>, which the
# precmd hook in ~/.zshrc prints before the next prompt, since the TUI clears
# the screen on its way out.
pid=$$
while [ "$pid" -gt 1 ]; do
  if [ "$(ps -o comm= -p "$pid")" = "claude" ]; then
    [ "$1" = "--dry-run" ] && { echo "would end claude pid $pid"; exit 0; }
    if [ -n "$1" ]; then
      tty=$(ps -o tty= -p "$pid" | tr -d ' ')
      mv "$1" "$HOME/.claude/close-message-$tty"
    fi
    kill -TERM "$pid"
    exit 0
  fi
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
done
echo "no claude process above this shell" >&2
exit 1
