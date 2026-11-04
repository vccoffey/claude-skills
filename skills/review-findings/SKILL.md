---
name: review-findings
description:
  Review a PR, branch or diff, or triage review findings handed in (gpush AI
  review output), into classified findings: critical, bug, nit, future. Use when reviewing code or acting on review findings.
---

# Review findings

Produce one verified, classified list of findings for a change. This skill only
reports: the caller decides what to fix, post or merge, so leave GitHub and the
working tree untouched.

## Inputs

- **Target**: anything `/code-review` accepts: a PR number, a branch, a path, or
  nothing for the current diff.
- **Findings** (optional): text handed in by the caller, such as gpush's AI
  review output (`claude code review`, `claude security review`).

## Steps

1.  **Gather.** Unless the findings handed in already come from a code review
    (gpush `claude code review`), invoke the `code-review` skill with arguments
    `high <target>`. Its output is the starting list for step 2; review the diff
    yourself only through steps 2–4, never in place of `code-review`. Security
    review findings alone don't count: run the review and add them to its
    findings.

2.  **Check.** For each finding, read the code it names and its surroundings.
    Keep it only if you can state how it goes wrong; drop the rest. Drop
    findings on ignored files. For a PR, also read its comments, review threads
    and commit messages. Where they differ from the description, the latest word
    from the author or a reviewer is the spec: drop findings it settles.

3.  **Siblings.** For each kept finding, search the change for the same problem
    elsewhere (the same check in another action, the same pattern in another
    model) and add each sibling as its own finding.

4.  **Trace.** For every behaviour the change alters, find each entry point that
    reaches the same code, data or state (callers, jobs, batch paths, other
    controllers, scripts) and check each one, not only the one the diff shows.
    Add what breaks as findings.

5.  **Classify.** Give every finding a class and a confidence, then report.

Done when every finding from step 1 is kept or dropped, every kept finding has
had its siblings searched, every changed behaviour is traced, and every
remaining finding has a class and a confidence.

## Classes

- **critical**: the change causes data loss or corruption, a security hole, a
  deploy-time breakage, or a crash or error page on input a user produces in
  normal use. A crash only deliberately crafted input reaches is critical on a
  page the public can reach, and a bug behind sign-in.
- **bug**: any other wrong behaviour the change introduces.
- **nit**: in scope and optional: style and naming, comment wording, duplication
  or "extract a helper", performance with no user-visible effect, test-style
  preferences.
- **future**: worth doing, but beyond this change: a problem already on the base
  branch, or a refactor or improvement bigger than the change should take on.
  Give the reason.

**Confidence** is `high`, `medium` or `low`: how sure you are the finding is
real, by your own judgement.

## Ignored files

Lockfiles (`package-lock.json`, `yarn.lock`, `Gemfile.lock` and the like),
generated schema dumps (`schema.rb`, `structure.sql`), built or vendored assets,
and other machine-generated files.

## Report

One markdown table, sorted critical, bug, nit, future:

| Class | Confidence | File:line | Finding | Failure scenario or reason |
| ----- | ---------- | --------- | ------- | -------------------------- |

The last column holds how it goes wrong for critical and bug, why it is optional
for a nit, and why it is out of scope for future. With no findings, say so in
one line instead of the table.
