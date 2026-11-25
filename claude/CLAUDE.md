# Global rules (all projects)

## Commit discipline (applies while working, not only at ship time)

- Conventional Commits: `type(scope): imperative one-line subject`, lowercase scope named after the subsystem. Types: feat, fix, docs, test, refactor, chore, perf, build, ci.
- One commit per coherent, reviewable decision (a section of planned work, one complete refactor step). If the subject line needs an "and", split the commit.
- On an unpushed branch, fold fixes into the commit that introduced them (`--amend` or `fixup` + autosquash) instead of stacking "fix typo" or "address review" commits. History is for reviewers, not a diary.
- Branch names: `<type>/<kebab-case-description>`.
- No em-dashes or en-dashes in commit messages, PR or issue text, or any prose; restructure with commas, parentheses, or colons instead.

## Delegation policy (role-based routing)

Route by role, not by model name. Model names live only in each role's frontmatter; never override them with a model parameter when dispatching. To change tiers, change roles.

- `Explore`: read-only lookups anywhere - files, symbols, and sweeps in the repo; registries, external docs, past session logs, and dotfiles outside it.
- `too-te`: mechanical, fully-specified work (pattern edits, tests and docs that copy existing conventions, bulk edits, test runs, data extraction). Complete spec in one shot; it makes no design decisions.
- `sai-hu`: judgment-heavy implementation - ambiguous spec, costly errors, or a too-te stalled twice on the same task.
- Escalate one tier at a time, and only for judgment failures; missing context means supplying context, not escalating. Role agents are leaf agents: they never delegate further.
- Review and judge gates (adversarial review, final code review) follow their own model spec; fan-out cost defaults never downgrade them.
- The generic general-purpose agent inherits the main session's model; dispatch it only when no named role fits, and always pass an explicit model when you do. Fully-specified extraction and stats jobs go to too-te, not general-purpose.
- The orchestrator itself does single-point judgment only (architecture calls, final review); queries, writing, and mechanical audits always go down to a role.
