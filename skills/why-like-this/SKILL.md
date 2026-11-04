---
name: why-like-this
description: >-
  Trace a behaviour the user questions back to the instruction wording that
  produced it, and reword that instruction so the next run does what they meant.
  Use when the user asks why you did something ("why did you stop?", "by what
  instruction…?"), before saving a feedback memory, or when invoked as
  /why-like-this.
---

# Why like this

The user asking why is a misalignment report: something led you to act other
than they wanted. Answer it, then find the **lever**, the smallest change that
makes the next run do what they meant.

1. **Answer the why.** Lead with the motive: what you were trying to achieve or
   avoid, and the concern or assumption that drove the choice, such as "each
   pass found more paths to lock, and I wanted to ask about scope before going
   further". Give the motive you actually had, as your reasoning at the time
   shows it, even when a better one comes to mind now. Then the what: quote the
   text that let you act on it (a skill step, a CLAUDE.md or AGENTS.md line, a
   memory, a tool description), or say no text did and it was your own default,
   and say whether your action followed that text or departed from it. The gap
   may be between the text and a desire the user never wrote down, the question
   itself being the first time they voice it. A misreading or a breach counts
   too: wording that was easy to get wrong is a lever as well. State both as
   facts and stop there; the lever comes next.

2. **Name the gap.** State what the user wanted. If you cannot infer this from
   their question, ask. Then state how the motive and the wording led away from
   the user's desire. A motive the user shares but no text covers needs wording
   of its own; a motive they don't share needs the text it leaned on made
   clearer. Look for the usual causes:
   - a rule stated before its exception, so the rule wins;
   - a prohibition that names the unwanted behaviour instead of the wanted one;
   - a completion criterion vague enough to end early;
   - a branch the wording never covers, so a nearby rule gets stretched to it;
   - the same meaning in two places that disagree.

3. **Propose the lever.** Edit the one place that is the source of truth for
   that behaviour: reword before adding, phrase the target positively, and
   prefer a precise leading word over a sentence. A memory is a lever too;
   choose it only when no skill, CLAUDE.md or AGENTS.md line owns the behaviour.
   A hook or other setting (a permission rule, say) is a lever too; choose it
   when the harness can catch or prevent the slip mechanically, so enforcement
   doesn't rest on your memory of a rule. A breach needs a lever even when the
   rule is one you can't edit: find why the rule didn't bind in that moment (out
   of view, or outweighed by a motive) and put wording where that moment will
   see it, in CLAUDE.md, a skill, or a memory, or enforce it with a hook or
   setting. Show the proposed wording or config and say which cause from step 2
   it removes.

   Changing nothing is a proposal too, when the wording would cost more than the
   slip: say why the slip is unlikely to recur, or what the wording would cost,
   and let the user decide. That a rule already exists is not such a reason; a
   rule that didn't bind will fail again.

4. **Apply it once the user agrees.** Make the edit, leaving any commit or push
   to the user's word. Then go back to the work that raised the question and
   finish it as the new wording says.
