#!/bin/bash
# gpush with the Mac kept awake while it runs (the display may still sleep),
# and a watchdog that interrupts it if it outlives GPUSH_TIMEOUT seconds
# (default 3600). Arguments go straight to gpush.
set -u
timeout=${GPUSH_TIMEOUT:-3600}

caffeinate -ims -w $$ &

# SIGINT, as Ctrl-C would: gpush stops its checks, runs post_run and removes
# its worktree. A second one force-quits a check that ignores the first.
(
  sleep "$timeout"
  wrapper=$(pgrep -P $$ -f 'bin/gpush') || exit 0
  ruby=$(pgrep -P "$wrapper" -f 'gpush\.rb') || exit 0
  echo "gpush still running after ${timeout}s: interrupting it" >&2
  kill -INT "$ruby"
  sleep 30
  kill -INT "$ruby" 2>/dev/null
) &
watchdog=$!
disown "$watchdog"

gpush "$@"
status=$?
sleeper=$(pgrep -P "$watchdog")
kill "$watchdog" $sleeper 2>/dev/null
exit $status
