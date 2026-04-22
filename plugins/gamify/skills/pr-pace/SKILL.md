---
name: pr-pace
description: PR pace awareness — computes rolling 7-day PR count, emits pace status (On Fire / On Track / Falling Behind / Danger Zone), injects nudges into /work-on and /pr-create-from-commits, and can fully orchestrate PR splits end-to-end: proposes a split plan, creates scoped Jira sub-tickets, chains branches, implements code, and opens PRs autonomously.
---

# PR Pace

Always-on PR velocity awareness skill. Computes a rolling 7-day PR count, assigns a pace status, and injects contextual nudges at two key moments: when starting a ticket (`/work-on`) and when creating a PR (`/pr-create-from-commits`).

When an oversized branch is detected, it can go further: propose a split plan, get your approval, then fully orchestrate the split end-to-end — Jira sub-tickets, chained branches, implementation, commits, and PRs.

**Target:** 9–12 PRs per 7-day rolling window.

---

## State File

Pace data is cached at `/tmp/pr-pace-state.json`. Refresh if missing or older than 30 minutes.

```json
{
  "computed_at": "2026-04-20T10:00:00Z",
  "opened_7d": 6,
  "merged_7d": 4,
  "status": "Falling Behind",
  "primary_metric": "opened_7d"
}
```

---

## Step 1 — Load or refresh state

```bash
export GH_HOST=github.intuit.com

STATE_FILE="/tmp/pr-pace-state.json"
NEEDS_REFRESH=true

if [ -f "$STATE_FILE" ]; then
  FILE_AGE=$(( $(date +%s) - $(stat -f %m "$STATE_FILE" 2>/dev/null || stat -c %Y "$STATE_FILE") ))
  if [ "$FILE_AGE" -lt 1800 ]; then
    NEEDS_REFRESH=false
  fi
fi

if [ "$NEEDS_REFRESH" = "true" ]; then
  SINCE=$(date -u -v-7d +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "7 days ago" +"%Y-%m-%dT%H:%M:%SZ")

  OPENED=$(gh pr list --author @me --state all \
    --json number,createdAt \
    --jq "[.[] | select(.createdAt >= \"$SINCE\")] | length")

  MERGED=$(gh pr list --author @me --state merged \
    --json number,mergedAt \
    --jq "[.[] | select(.mergedAt != null and .mergedAt >= \"$SINCE\")] | length")

  PRIMARY="opened_7d"
  if [ "$OPENED" = "0" ] && [ "$MERGED" -gt "0" ]; then
    PRIMARY="merged_7d"
  fi

  COUNT=$OPENED
  if [ "$PRIMARY" = "merged_7d" ]; then COUNT=$MERGED; fi

  if [ "$COUNT" -ge 10 ]; then
    STATUS="On Fire"
  elif [ "$COUNT" -ge 7 ]; then
    STATUS="On Track"
  elif [ "$COUNT" -ge 4 ]; then
    STATUS="Falling Behind"
  else
    STATUS="Danger Zone"
  fi

  cat > "$STATE_FILE" <<EOF
{
  "computed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "opened_7d": $OPENED,
  "merged_7d": $MERGED,
  "status": "$STATUS",
  "primary_metric": "$PRIMARY"
}
EOF
fi
```

---

## Step 2 — Emit pace nudge (for `/work-on` integration)

Read the state file and emit a single callout block before the ticket summary.

```bash
STATE=$(cat /tmp/pr-pace-state.json)
STATUS=$(echo "$STATE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['status'])")
COUNT=$(echo "$STATE" | python3 -c "import sys,json; d=json.load(sys.stdin); m=d['primary_metric']; print(d[m])")
```

| Status | Nudge |
|---|---|
| **On Fire** | `📈 PR Pace — On Fire: {n} PRs in the last 7 days. Keep scoping tight and flag-guarded to maintain pace.` |
| **On Track** | `✅ PR Pace — On Track: {n} PRs in the last 7 days. Aim to scope this ticket to one shippable PR.` |
| **Falling Behind** | `⚠️ PR Pace — Falling Behind: {n} PRs in the last 7 days (target: 9–12). Consider shipping this ticket as 2 smaller PRs: flag definition first, implementation second.` |
| **Danger Zone** | `🚨 PR Pace — Danger Zone: {n} PRs in the last 7 days. Aggressively scope this ticket. Ideal split: flag-only PR → logic PR → cleanup PR. Ship each separately.` |

Emit as a markdown blockquote before the ticket summary. Keep to 1–2 lines.

---

## Step 3 — Inspect diff size (for `/pr-create-from-commits` integration)

```bash
FILE_COUNT=$(git diff origin/main --name-only | wc -l | tr -d ' ')

LINE_COUNT=$(git diff origin/main --stat | tail -1 | awk '{
  total = 0
  for (i=1; i<=NF; i++) {
    if ($i ~ /^[0-9]+$/) total += $i
  }
  print total
}')

HAS_FLAG_CHANGE=$(git diff origin/main --name-only | grep -c "config/flags.ini" || true)
OTHER_FILE_COUNT=$(git diff origin/main --name-only | grep -vc "config/flags.ini" || true)
```

**Thresholds:**

| Signal | Threshold | Flag |
|---|---|---|
| Files | > 10 | `FILE_OVERSIZED` |
| Lines | > 400 | `LINE_OVERSIZED` |
| flags.ini + other files | Any | `FLAG_SPLIT_NEEDED` |

**Combined pace + size output:**

| Pace | Size | Action |
|---|---|---|
| Any | Clean | Proceed silently |
| On Fire / On Track | Oversized | Soft suggestion + offer to orchestrate split |
| Falling Behind / Danger Zone | Oversized | Hard recommendation + offer to orchestrate split |
| Any | `FLAG_SPLIT_NEEDED` | Always hard recommendation + offer to orchestrate split |

When any split signal is triggered, after the nudge message append:

> `Would you like me to propose a split plan and execute it? (yes / no)`

If yes, proceed to **Step 4**.

---

## Step 4 — Propose split plan

Analyze `git diff origin/main --name-only` and group files into logical split PRs.

**Grouping rules (apply in order):**

1. `config/flags.ini` → always its own PR: "Flag definition"
2. `tests_phpunit/` or `tests/` only → "Test coverage" PR
3. Files under the same `app/lib/MC/{Domain}/` subtree → one PR per domain
4. `app/controllers/` or `app/views/` → "Controller/view layer" PR
5. `web/js/src/` → "Frontend" PR
6. Remaining files → "Miscellaneous" PR (if small enough); otherwise split further by directory prefix

**Branch chaining:** Each PR's branch is cut from the previous PR's branch, not from `main`. The first PR is always cut from `main`. This means:

- PR 1 branch: cut from `main`
- PR 2 branch: cut from PR 1 branch
- PR 3 branch: cut from PR 2 branch
- etc.

Each PR's diff only shows the delta introduced by that group — clean, reviewable.

**Present the plan as a numbered list:**

```
Proposed split (4 PRs, chained):

1. [TICKET-A] Flag definition
   Branch: {ticket}-flag-definition (from main)
   Files: config/flags.ini
   Jira: new sub-ticket under {parent} — "Flag definition for {feature}"

2. [TICKET-B] Core service implementation
   Branch: {ticket}-service-impl (from branch 1)
   Files: app/lib/MC/AudienceManagement/...
   Jira: new sub-ticket under {parent} — "Implement {feature} service layer"

3. [TICKET-C] Controller + view wiring
   Branch: {ticket}-controller (from branch 2)
   Files: app/controllers/..., app/views/...
   Jira: new sub-ticket under {parent} — "Wire {feature} into controller and view"

4. [TICKET-D] Test coverage
   Branch: {ticket}-tests (from branch 3)
   Files: tests_phpunit/...
   Jira: new sub-ticket under {parent} — "Test coverage for {feature}"

Story points: split proportionally from parent (total: {parent_points}).
All sub-tickets assigned to you, added to current sprint.

Accept this plan? You can say "accept", "swap 2 and 3", "drop #4", or describe any changes.
```

Wait for user response. Apply any adjustments they describe, re-display the modified plan, confirm once more before executing.

---

## Step 5 — Create Jira sub-tickets

For each split in the approved plan, create a Jira sub-ticket:

- **Parent link:** linked to the original ticket as a child/sub-task
- **Summary:** generated title specific to this split's scope
- **Description:** Claude writes a focused 2–4 sentence description covering exactly what this PR changes and why, scoped to the files in this split. Do not copy the parent description verbatim.
- **Assignee:** current user (from Jira auth context)
- **Sprint:** same sprint as parent ticket
- **Story points:** proportional share of parent points (round to nearest 1; minimum 1)
- **Priority:** inherited from parent
- **Labels:** inherited from parent

After creating each sub-ticket, transition it to **In Progress** immediately.

Store the mapping of split index → Jira ticket key in memory for use in branch names and PR titles.

---

## Step 6 — Execute splits autonomously

For each split in order:

### 6a. Checkout branch

```bash
# First split: cut from main
git fetch origin
git checkout main
git pull origin main
git checkout -b {ticket-key}-{slug}

# Subsequent splits: cut from previous split's branch
git checkout -b {ticket-key}-{slug} {previous-branch}
```

### 6b. Move files to branch

Cherry-pick or selectively stage only the files belonging to this split:

```bash
# Restore only this split's files from the working tree state
# (all changes are already present locally — just stage selectively)
git checkout {original-branch} -- {file1} {file2} ...
git add {file1} {file2} ...
```

For the **flag definition PR** specifically: only stage `config/flags.ini` changes. Ensure no implementation code is included.

For **implementation PRs**: verify `MC_Flag::isOn()` wraps all new behavior. If the flag PR is earlier in the chain, the flag will exist by the time this branch is reviewed.

### 6c. Implement any missing pieces

If a split's files are incomplete (e.g., an implementation file references a flag not yet defined in this branch's context, or a test file needs updating to match), implement the necessary additions now. Follow existing codebase patterns. Do not add features beyond the split's stated scope.

### 6d. Commit

```bash
git add {split-files}
git commit -m "[{JIRA-KEY}] {split title}"
```

### 6e. Push

```bash
git push origin {branch-name}
```

### 6f. Create PR

```bash
gh pr create \
  --title "[{JIRA-KEY}] {split title}" \
  --base {previous-branch-or-main} \
  --body "$(cat <<'EOF'
{populated PR template}

**Part {N} of {total} — depends on: #{previous-pr-number}**
EOF
)"
```

- Base branch is the **previous split's branch** (not main) — this is the chain.
- PR description notes which PR must merge first.
- Populate the full PR template as per `pr-create-from-commits` Step 4.

After each PR is created, print: `✅ PR {N}/{total} created: #{number} — {title} ({url})`

---

## Step 7 — Summary report

After all splits are executed, print a summary:

```
Split complete — {N} PRs created:

1. #{number} [TICKET-A] Flag definition → {url}
   Base: main | Jira: {TICKET-A}

2. #{number} [TICKET-B] Core service implementation → {url}
   Base: branch-1 | Jira: {TICKET-B}

3. #{number} [TICKET-C] Controller + view wiring → {url}
   Base: branch-2 | Jira: {TICKET-C}

Merge order: #1 → #2 → #3
After each merge, rebase the next branch: git rebase origin/{merged-branch} {next-branch}

Weekly pace: {n} PRs opened in 7 days (+{N} just added) → {new-status}
```

Recompute and save pace state after the split (these new PRs count).

---

## Integration Points

### In `/work-on`

Insert **after Step 1 (parse input)** and **before Step 3 (fetch ticket details)**:

> **PR Pace check:** Load or refresh `/tmp/pr-pace-state.json` (Step 1). Emit the pace nudge (Step 2) before displaying ticket context.

### In `/pr-create-from-commits`

Insert **after Step 1 (gather git context)** and **before the existing Step 2 (Jira status)**:

> **PR Pace check:** Load or refresh `/tmp/pr-pace-state.json` (Step 1). Run size inspection (Step 3). If any split signal is triggered, emit the nudge and offer to orchestrate a split. If user says yes, run Steps 4–7 instead of the normal PR creation flow.

---

## Error Handling

- If `gh` is not authenticated, skip pace check silently — do not block primary workflows.
- If Jira MCP is unavailable during split orchestration, skip sub-ticket creation, warn the user, and continue with branches and PRs.
- If a branch already exists during split execution, append `-v2` suffix and continue.
- If any split's `git checkout` or `git push` fails, stop and report the failure with the exact command that failed. Do not attempt to continue to the next split.
- Never force-push. Never skip hooks.

---

## Parameters / knobs

| Knob | Default | Effect |
|---|---|---|
| `--refresh` | off | Force refresh state file regardless of age |
| `--quiet` | off | Suppress nudge output (for scripting) |
| `--split` | off | Jump directly to split proposal for current branch |

---

## Changelog

- **v1.1** — Full split orchestration: plan proposal with user edit, Jira sub-ticket creation, branch chaining, autonomous implementation, PR creation, summary report
- **v1.0** — Rolling 7-day pace, four status levels, work-on and pr-create-from-commits integration, file/line size signals, natural split detection
