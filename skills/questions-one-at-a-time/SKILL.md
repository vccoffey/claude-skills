---
name: questions-one-at-a-time
description: >-
  Interview mode: put each question to the user singly and wait for the answer
  before asking the next. Use when the user says "one question at a time",
  "ask me one at a time", or invokes /questions-one-at-a-time.
---

# Questions one at a time

Interview the user relentlessly until you reach a shared understanding. Each
message carries exactly **one** question; then stop and wait for the answer.

## Explore, don't build

Until the interview is complete, the interview is the whole job. Explore
freely to sharpen questions or answer them yourself: read code, search, query
the local dev database if permitted. Ask the user only what exploration can't
settle. Writing code, running specs and other changes wait until the user
confirms the final summary.

## Each question

- Lead with the question in one bold line.
- Give your recommended answer, worded so "yes" accepts it.
- Add only the context needed to answer: options, trade-offs, what hangs on it.

```
❓ **<question>**

<context, choices>

➡️ <recommended answer>
```

## Settled or open

The current question stays **open** until the user's reply settles it. A reply
settles it only when it picks an answer: "yes" to your recommendation, a choice,
or their own decision.

A reply that thinks aloud, asks you something back, answers part of the
question, answers a neighbouring question, or says "maybe" / "probably" leaves
it open. Respond to what they said, record anything it did settle, then put the
open part to them again, narrowed to what is still undecided. Keep asking that
one question until it is settled or the user explicitly defers it ("skip",
"you decide", "later"); a deferred question goes in the final summary as
deferred, with your default.

Your recommendation is never the answer by silence. Nothing is silently assumed.

## Choosing the next question

Map the decisions as a **design tree**: every decision branches into the ones
that hang off it.

- The next question is one whose prerequisites are all settled; never ask a
  question whose answer depends on one still open.
- Of those, ask the one that unblocks the most others.
- After each settled answer, prune the branches it closed and add the ones it
  opened.

## Persistence

Active every response until every branch of the tree is settled or deferred,
or the user says "stop" or "ask them all". Then list each decision, marking
deferred ones, and confirm that list is the shared understanding before acting
on it. On "ask them all", put every remaining question in one message; the
summary and confirmation still apply.
