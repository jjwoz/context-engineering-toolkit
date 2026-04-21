---
name: gamify
description: Intelligent PR decomposition — splits any oversized PR URL or current branch into reviewable chained PRs with Jira sub-tickets, using SDD agents (code-explorer, software-architect, business-analyst) for semantic classification and reflexion:critique judges for consensus validation. Fully autonomous after plan approval: implements gaps with sdd:developer, runs judge gates per split, commits, pushes, and opens PRs. Integrates with pr-pace velocity tracking.
---

# Gamify

Splits any PR or branch into smaller, reviewable, chained PRs to maintain PR velocity (target: 9–12 per 7-day window). Uses the SDD agent pipeline for intelligent semantic classification — not mechanical file grouping — so splits are conceptually coherent (e.g. Value Object + factory in one PR, tests in another).

Fully autonomous after plan approval: implements gaps, runs judge gates per split, commits, pushes, and opens PRs. Feeds pace state back into `pr-pace` after completion.

---

## Modes

| Mode | Input | When to use |
|---|---|---|
| **PR URL** | `https://github.{host}/org/repo/pull/{n}` | PR already open, want to retroactively split |
| **Branch** | current branch (no args) | Work in progress, not yet a PR |
| **Ambient** | triggered by `pr-pace` Step 3 | Auto-offered when size thresholds are crossed |

---

## Step 1 — Ingest diff

**PR URL mode:**
```bash
export GH_HOST=github.intuit.com  # or github.com for personal repos
PR_NUMBER=$(echo "$INPUT" | grep -oE '[0-9]+$')
gh pr diff $PR_NUMBER --name-only > /tmp/gamify-files.txt
gh pr diff $PR_NUMBER > /tmp/gamify-diff.txt
gh pr view $PR_NUMBER --json title,body,headRefName,baseRefName > /tmp/gamify-meta.json
```

**Branch mode:**
```bash
git diff origin/main --name-only > /tmp/gamify-files.txt
git diff origin/main > /tmp/gamify-diff.txt
```

Build a structured context block:
```
Files changed: {count}
Total lines changed: {additions + deletions}
File list:
{/tmp/gamify-files.txt contents}
```

If fewer than 3 files or fewer than 100 lines changed, print:
> "This diff is already small enough — no split needed."
and exit.

---

## Step 2 — Parallel classification (3 agents fire simultaneously)

Launch all three agents in parallel using the Agent tool.

### Agent A: `sdd:code-explorer` (sonnet)

Prompt:
```
You are analyzing a git diff to classify each changed file by its architectural role.

File list:
{/tmp/gamify-files.txt}

Full diff:
{/tmp/gamify-diff.txt}

For each file, output a JSON array:
[
  { "file": "path/to/file.php", "type": "ValueObject|Service|Interface|Controller|View|Test|Flag|Migration|Proto|Config|Frontend|Misc", "domain": "inferred domain name or null" }
]

Rules:
- ValueObject: immutable class wrapping a single concept, no side effects
- Service/Impl: business logic, orchestration, I/O
- Interface: abstract contracts, traits used as interfaces
- Controller: HTTP request handlers
- View: templates, HTML files
- Test: any test file (PHPUnit, Jest, Avesta)
- Flag: config/flags.ini
- Migration: data/upgrade/ SQL or PHP migration files
- Proto: .proto files
- Config: non-flag config files
- Frontend: web/js/src/ files
- Misc: anything else

Output only the JSON array. No explanation.
```

### Agent B: `sdd:software-architect` (opus)

Prompt:
```
You are proposing how to split a PR into smaller reviewable PRs.

File classifications:
{output from Agent A}

Full diff:
{/tmp/gamify-diff.txt}

Propose semantic groupings. Each group becomes one PR. Rules:
1. Flag definitions (flags.ini) → always their own PR, always first
2. Value Objects + their factories → one PR (they are incomplete without each other)
3. Service interfaces + implementations → one PR per domain
4. Controllers + Views → one PR per controller
5. Tests → can be their own PR if substantial, or bundled with what they test if small (<50 lines)
6. Frontend → one PR
7. Migrations → one PR, always last (schema changes deploy separately)
8. Never mix Flag PR with implementation code

For each group output:
{
  "order": 1,
  "title": "short descriptive title",
  "rationale": "one sentence — why these files belong together",
  "files": ["file1", "file2"],
  "can_compile_standalone": true|false,
  "notes": "any caveats"
}

Output a JSON array of groups ordered by recommended merge sequence.
```

### Agent C: `sdd:business-analyst` (opus)

Prompt:
```
You are evaluating whether proposed PR splits are independently reviewable.

Proposed groups:
{output from Agent B}

For each group, answer:
- Can a reviewer understand and approve this group WITHOUT seeing the other groups? (yes/no/partially)
- If partially or no: what context from another group is required?
- Is the group too small to be a meaningful PR? (fewer than 3 meaningful lines of logic)

Output JSON array matching the input groups, adding:
{
  "independently_reviewable": true|false,
  "requires_context_from": ["group title or null"],
  "too_small": true|false
}
```

Wait for all three agents to complete before proceeding.

---

## Step 3 — Judge consensus via `reflexion:critique`

Synthesize Agent A + B + C outputs into a proposed split plan. Then run three judges in parallel.

### Judge 1: Requirements Validator
- Does each proposed PR have exactly one purpose?
- Are any files misclassified?
- Score: 1–10

### Judge 2: Solution Architect
- Is the branch chain ordering correct? (flags before impl, migrations last)
- Does each split compile/run standalone without the others?
- Are there false dependencies or missing ones?
- Score: 1–10

### Judge 3: Code Quality Reviewer
- Are any splits too small to be meaningful (noise PRs)?
- Are any splits too large (should be further divided)?
- Score: 1–10

**Pass threshold: average score ≥ 7/10.**

If below threshold: revise the groupings using judge feedback and re-run judges (max 2 iterations). If still below after 2 iterations, proceed with a warning note in the plan.

---

## Step 4 — Present plan for approval

Display the consensus split plan:

```
Proposed split — {N} PRs (chained):

1. [{TICKET}-a] {title}
   Branch: {ticket}-{slug} (from main)
   Files: {file list}
   Rationale: {one sentence from architect agent}
   Jira: new sub-ticket — "{title}"

2. [{TICKET}-b] {title}
   Branch: {ticket}-{slug} (from PR 1 branch)
   Files: {file list}
   Rationale: {rationale}
   Jira: new sub-ticket — "{title}"

...

Judge consensus: {avg score}/10
Pace status: {current status} — {n} PRs in last 7 days

Accept this plan? You can say "accept", "swap 2 and 3", "drop #4", or describe any changes.
```

Wait for user response. Apply any adjustments, re-display, confirm once more before executing.

---

## Step 5 — Create Jira sub-tickets

For each split in the approved plan:

- **Parent link:** child of original ticket
- **Summary:** generated title for this split
- **Description:** 2–4 sentences scoped to this split's files only — do not copy parent description
- **Assignee:** current user
- **Sprint:** same sprint as parent
- **Story points:** proportional share of parent points (round to nearest 1, minimum 1)
- **Priority:** inherited from parent
- **Labels:** inherited from parent

Transition each sub-ticket to **In Progress** immediately after creation.

Store split index → Jira ticket key mapping for branch names and PR titles.

If Jira MCP is unavailable: skip sub-ticket creation, warn the user, continue with branches and PRs.

---

## Step 6 — Execute splits autonomously

For each split **in order**:

### 6a. Checkout branch
```bash
# Split 1: from main
git fetch origin
git checkout main && git pull origin main
git checkout -b {TICKET-KEY}-{slug}

# Splits 2+: from previous split's branch
git checkout -b {TICKET-KEY}-{slug} {previous-branch}
```

### 6b. Stage this split's files
```bash
git checkout {original-branch} -- {file1} {file2} ...
git add {file1} {file2} ...
```

### 6c. Implement gaps with `sdd:developer`

Launch `sdd:developer` (opus) with this prompt:
```
You are completing a PR split. The following files have been staged for this split:
{file list}

Original diff context:
{relevant section of /tmp/gamify-diff.txt}

Tasks:
- If any file is incomplete (stub, missing method, broken reference), implement it now
- Follow existing codebase patterns exactly
- Do not add features beyond what the diff shows
- If this is a test split, ensure tests cover the staged implementation files
- If this is a flag split, ensure flags.ini contains only the flag definition — no usage code

Report: list of changes made (or "no gaps found").
```

### 6d. Judge gate (3 judges in parallel)

Launch reflexion:critique judges on the staged changes:

**Judge 1: Requirements Validator**
- Does this split match its approved plan scope exactly?
- No extra files, no missing files?

**Judge 2: Solution Architect**
- Does it follow the codebase's established patterns?
- Are there any architectural concerns?

**Judge 3: Code Quality Reviewer**
- Code quality, naming, no obvious bugs?
- Tests present if this is an implementation split?

Pass threshold: average ≥ 7/10.

If below threshold: `sdd:developer` retries with judge feedback (max 3 iterations).
If still failing after 3 iterations: **pause**, show the diff, ask for guidance before continuing.

### 6e. Commit and push
```bash
git commit -m "[{JIRA-KEY}] {split title}"
git push origin {branch-name}
```

### 6f. Create PR
```bash
gh pr create \
  --title "[{JIRA-KEY}] {split title}" \
  --base {previous-branch-or-main} \
  --body "..."
```

PR body notes:
- Populate the repo's PR template if one exists
- Add: `**Part {N} of {total} — depends on: #{previous-pr-number}**`
- Base branch is the **previous split's branch**, not main

Print after each: `✅ PR {N}/{total} created: #{number} — {title} ({url})`

---

## Step 7 — Summary report

```
Gamify complete — {N} PRs created:

1. #{number} [{TICKET-A}] {title} → {url}
   Base: main | Judge score: {score}/10

2. #{number} [{TICKET-B}] {title} → {url}
   Base: {branch-1} | Judge score: {score}/10

...

Merge order: #1 → #2 → #3
After each merge, rebase the next: git rebase origin/{merged-branch} {next-branch}

Weekly pace: {n} PRs in last 7 days (+{N} just added) → {new-status}
```

Recompute and save `/tmp/pr-pace-state.json` after completion.

---

## Integration with pr-pace

`pr-pace` Step 3 (diff size inspection) should offer `/gamify` when thresholds are crossed:

> `Would you like me to run /gamify to split this into smaller PRs? (yes / no)`

If yes, invoke gamify in **Branch mode** directly.

---

## Error handling

- Diff too small (<3 files, <100 lines): exit with "no split needed"
- `gh` not authenticated: exit with clear error, do not proceed
- Branch already exists: append `-v2` suffix and continue
- `git checkout` or `git push` fails: stop immediately, report the exact failing command, do not continue to next split
- Jira unavailable: skip sub-tickets, warn, continue with branches and PRs
- Judge never passes after max iterations: pause and ask for guidance
- Never force-push. Never skip hooks.

---

## Changelog

- **v1.0** — Initial release: PR URL + branch modes, SDD parallel classification, reflexion judge consensus, autonomous execution with per-split judge gates, Jira sub-ticket creation, pr-pace integration
