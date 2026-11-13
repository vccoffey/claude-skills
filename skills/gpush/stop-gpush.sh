#!/bin/bash
# Interrupt the gpush that one run-gpush.sh started, with SIGINT as Ctrl-C
# would. Takes that run-gpush.sh's pid, which it prints as its first line, and
# follows only its own child processes, so no other gpush can be hit.
set -u
wrapper=${1:?usage: stop-gpush.sh <run-gpush.sh pid>}

if ! ps -o command= -p "$wrapper" | grep -q 'run-gpush\.sh'; then
  echo "$wrapper is not a running run-gpush.sh" >&2
  exit 1
fi

gpush=$(pgrep -P "$wrapper" -f 'bin/gpush') || {
  echo "run-gpush.sh $wrapper has no gpush running" >&2
  exit 1
}
ruby=$(pgrep -P "$gpush" -f 'gpush\.rb') || {
  echo "gpush $gpush has no gpush.rb running" >&2
  exit 1
}

kill -INT "$ruby" && echo "SIGINT sent to gpush.rb $ruby (run-gpush.sh $wrapper)"
