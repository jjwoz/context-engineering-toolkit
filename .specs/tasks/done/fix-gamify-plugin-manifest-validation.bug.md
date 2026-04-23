---
title: Fix gamify plugin manifest skills validation error
---

## Initial User Prompt

Help me fix this error for the gamify [Image #1]

Error shown:
Failed to install: Plugin temp_local_1776870212322_qqeyt9 has an invalid manifest file at /Users/jwozniak/.claude/plugins/cache/temp_local_1776870212322_qqeyt9/.claude-plugin/plugin.json.

Validation errors: skills: Invalid input

## Description

> **Required Skill**: You MUST use and analyse `claude-code-plugin-manifest` skill before doing any modification to task file or starting implementation of it!
>
> Skill location: `.claude/skills/claude-code-plugin-manifest/SKILL.md`

The `gamify` plugin currently fails to install from the marketplace with the error `Validation errors: skills: Invalid input`. Claude Code validates `plugin.json` against a strict Zod schema that only accepts `name`, `version`, `description`, and `author`; the `skills` array currently declared in `plugins/gamify/.claude-plugin/plugin.json` is not part of that schema. Claude Code auto-discovers skills from the `skills/<name>/SKILL.md` directory tree and commands from `commands/<name>.md`, so a `skills` (or `commands`) array in the manifest is both unnecessary and fatal to installation. The gamify manifest additionally declares `license` and `tokens` fields, which the `claude-code-plugin-manifest` skill (see `.claude/skills/claude-code-plugin-manifest/SKILL.md`) lists as invalid; no other plugin in this repo uses them.

The fix reduces `plugins/gamify/.claude-plugin/plugin.json` to the minimal `{name, version, description, author}` shape already used by every other plugin in the repo (git, tdd, sadd, sdd, code-review, customaize-agent, ddd, docs, fpf, kaizen, mcp, reflexion, tech-stack) and empirically confirmed as the only valid shape by the plugin-manifest skill. All three skill files — `skills/gamify/SKILL.md`, `skills/pr-pace/SKILL.md`, `skills/work-on/SKILL.md` — remain on disk unchanged, so built-in auto-discovery continues to surface the three skills after install. The plugin version is bumped from 1.0.0 to 1.0.1 (patch) via `just set-version gamify 1.0.1`, and the marketplace version is bumped one patch level via `just set-marketplace-version <next-patch>`, per the repo's Key Development Rules. Because the marketplace cache refreshes from the committed source, the fix must be committed (and pushed for marketplace users) for the install error to clear.

This is a packaging-only fix that restores the ability to install the gamify plugin end-to-end, without modifying any skill behavior, command, or documentation. End users get a working install; the maintainer gets a manifest consistent with the rest of the marketplace; and future contributors can confidently copy any peer plugin's manifest as the reference pattern.

**Scope**:

- Included:
  - Remove `skills`, `license`, and `tokens` keys from `plugins/gamify/.claude-plugin/plugin.json` so only `name`, `version`, `description`, `author` remain (per `claude-code-plugin-manifest` skill).
  - Bump plugin version 1.0.0 → 1.0.1 via `just set-version gamify 1.0.1`.
  - Bump marketplace version by one patch via `just set-marketplace-version <next-patch>`.
  - Verify local install succeeds via `claude --plugin-dir ./plugins/gamify`.
  - Verify the three skills (gamify, pr-pace, work-on) are auto-discovered after install.
  - Commit the fix so the marketplace cache can refresh from source.
- Excluded:
  - Changes to any SKILL.md or command file under `plugins/gamify/`.
  - Changes to any other plugin's manifest.
  - Edits to `CONTRIBUTING.md` to remove its misleading `commands`/`skills` array example (follow-up task recommended by the skill).
  - CI or pre-commit lint for plugin-manifest validation (follow-up task).
  - README or docs updates for the gamify plugin.
  - Any skill rename or refactor.

**User Scenarios**:

1. **Primary Flow**: A user installs the gamify plugin from the marketplace (or locally via `--plugin-dir`); the Zod-based manifest validator accepts the four-key file; Claude Code auto-discovers the three skills from the `skills/<name>/SKILL.md` directory tree; `gamify`, `pr-pace`, and `work-on` become invokable.
2. **Alternative Flow**: The maintainer runs `claude --plugin-dir ./plugins/gamify` locally during verification; sees no validation error; confirms the three skills are available.
3. **Error Handling**: If the validator still rejects the manifest after the fix, the error message identifies the remaining offending key, which is then removed to match the peer-plugin pattern described in the `claude-code-plugin-manifest` skill; if a SKILL.md file is missing or renamed, the corresponding skill does not appear after install and must be restored to `skills/<name>/SKILL.md`; if the version is not bumped or the fix is not committed, marketplace caches keep serving the stale, broken manifest until they refresh from source.

---

## Acceptance Criteria

### Functional Requirements

- [ ] **Manifest contains only the four valid top-level keys**
  - Given: `plugins/gamify/.claude-plugin/plugin.json` exists.
  - When: the file is parsed as JSON.
  - Then: the only top-level keys present are `name`, `version`, `description`, and `author` (matching the valid schema documented in `.claude/skills/claude-code-plugin-manifest/SKILL.md`).

- [ ] **Invalid fields are absent from the manifest**
  - Given: the previous manifest declared `skills`, `license`, and `tokens`.
  - When: the fix is applied.
  - Then: none of the keys `skills`, `commands`, `license`, or `tokens` appear in the parsed JSON.

- [ ] **Plugin version is bumped to 1.0.1 via the just recipe**
  - Given: the current gamify plugin version is `1.0.0`.
  - When: `just set-version gamify 1.0.1` is run.
  - Then: the `version` value in `plugins/gamify/.claude-plugin/plugin.json` equals `"1.0.1"`.

- [ ] **Marketplace version is bumped via the just recipe**
  - Given: the current marketplace `version` is recorded before the change.
  - When: `just set-marketplace-version <next-patch>` is run.
  - Then: the marketplace `version` in `.claude-plugin/marketplace.json` equals the next patch value.

- [ ] **All three SKILL.md files are preserved byte-for-byte**
  - Given: `plugins/gamify/skills/gamify/SKILL.md`, `plugins/gamify/skills/pr-pace/SKILL.md`, and `plugins/gamify/skills/work-on/SKILL.md` exist before the fix.
  - When: the fix is applied.
  - Then: all three files still exist and `git diff` reports no changes to any of them.

- [ ] **Local install completes with no validation error**
  - Given: the repo is checked out at the fix commit.
  - When: `claude --plugin-dir ./plugins/gamify` is launched.
  - Then: the session output contains no message matching `Validation errors` or `invalid manifest`, and the gamify plugin is reported as loaded/installed.

- [ ] **All three skills are auto-discovered after install**
  - Given: the plugin has been installed successfully (either locally or from the marketplace).
  - When: the user asks Claude Code to list the available skills in that session.
  - Then: `gamify`, `pr-pace`, and `work-on` each appear in the list as invokable skills, sourced from their `skills/<name>/SKILL.md` files.

- [ ] **Fix is committed so the marketplace cache can refresh**
  - Given: the manifest and version changes have been made in the working tree.
  - When: the changes are committed to the branch that feeds the marketplace.
  - Then: `git log` shows a commit touching `plugins/gamify/.claude-plugin/plugin.json` and both version files, with a message that names the root cause and the fix.

### Non-Functional Requirements

- [ ] **Consistency**: The gamify manifest shape matches the minimal `{name, version, description, author}` pattern used by the 12 peer plugins in this repository and documented in the `claude-code-plugin-manifest` skill.
- [ ] **Release hygiene**: Every version change is made through `just set-version` and `just set-marketplace-version`; no manual edits to version strings in `plugin.json` or `marketplace.json`.
- [ ] **Zero behavioral regression**: No file under `plugins/gamify/skills/` or `plugins/gamify/commands/` is modified as part of this fix; only the manifest and the two version files touched by the `just` recipes are changed.

### Definition of Done

- [ ] The `claude-code-plugin-manifest` skill has been read and its schema applied.
- [ ] All acceptance criteria pass.
- [ ] `plugins/gamify/.claude-plugin/plugin.json` is reduced to the four-key peer pattern.
- [ ] Plugin version bumped to 1.0.1 via `just set-version gamify 1.0.1`.
- [ ] Marketplace version bumped by one patch via `just set-marketplace-version <next-patch>`.
- [ ] Local install via `claude --plugin-dir ./plugins/gamify` verified to emit no validation error.
- [ ] The three skills verified as auto-discovered in a post-install Claude Code session.
- [ ] Change committed with a descriptive message naming the root cause (`skills` field rejected by validator) and the fix (manifest reduced to the schema-valid peer pattern).

---

## Solution Strategy

### References

- **Skill**: `.claude/skills/claude-code-plugin-manifest/SKILL.md`
- **Codebase Analysis**: `.specs/analysis/analysis-fix-gamify-plugin-manifest-validation.md`
- **Scratchpad**: `.specs/scratchpad/eb3435d7.md`

**Architecture Pattern**: **Convention-Driven Configuration (Declarative Manifest)** — classical runtime patterns (layered/hexagonal/onion/clean/event-driven/microkernel) do not apply because no runtime code is authored; the governing principle is conformance to an externally-enforced Zod schema plus the repo-local convention of peer plugins and `just` recipes.

**Approach**: Reduce `plugins/gamify/.claude-plugin/plugin.json` to the four-key minimal shape (`name`, `version`, `description`, `author`) that matches every peer plugin in the marketplace and is the only shape Claude Code's Zod validator accepts; bump the plugin version to `1.0.1` via `just set-version gamify 1.0.1` and the marketplace version by one patch via `just set-marketplace-version <next-patch>`; verify locally with `claude --plugin-dir ./plugins/gamify`; commit so the marketplace cache can refresh from source. The three SKILL.md files stay untouched because Claude Code auto-discovers them from `skills/<name>/SKILL.md`.

**Key Decisions**:

1. **Manifest shape = 4-key peer pattern**: Remove `license` and `tokens` (`skills[]` already removed in working tree) — because the task explicitly requires these four keys only, and all 12 peer plugins in the repo (git, tdd, sadd, sdd, code-review, customaize-agent, ddd, docs, fpf, kaizen, mcp, reflexion, tech-stack) use this shape with no `license` or `tokens`.
2. **Version bumps via `just` recipes only**: Never hand-edit version strings — because CLAUDE.md mandates `just set-version` / `just set-marketplace-version` for consistency and to keep `plugin.json` and `marketplace.json` in sync.
3. **No changes under `skills/` or `commands/`**: Rely on auto-discovery — because the skill explicitly states skills are auto-discovered from `skills/<name>/SKILL.md` and declaring them in the manifest is what caused the bug.
4. **Commit is part of the fix**: Marketplace cache refreshes from committed source — because the skill's "Marketplace cache stale" pitfall requires commit + push to clear cached invalid manifests on clients.

**Trade-offs Accepted**:

- **CONTRIBUTING.md stays misleading**: Its template still shows `skills[]` / `commands[]` as valid — accepting this recurrence risk in exchange for keeping this fix laser-focused; flagged as follow-up in the Excluded scope.
- **No automated lint for manifest validation**: Accepting manual verification via `--plugin-dir` in exchange for minimal scope; flagged as follow-up.

---

## Architecture Decomposition

**Files changed**:

| File | Responsibility | Dependencies |
|------|----------------|--------------|
| `plugins/gamify/.claude-plugin/plugin.json` | Declares the 4 schema-valid keys for gamify; `version: 1.0.1` | Validated by Claude Code Zod schema; referenced by `marketplace.json` via `source: ./plugins/gamify` |
| `.claude-plugin/marketplace.json` | Top-level `version: 2.2.4`; `plugins[].gamify.version: 1.0.1` | Updated by `just set-marketplace-version` (top-level) and `just set-version gamify 1.0.1` (plugin entry) |

**Interactions**:

```
User / claude CLI --> marketplace.json --> plugins/gamify/.claude-plugin/plugin.json
                             |                             |
                             |                             v
                             |                    Zod validator (accept)
                             |                             |
                             v                             v
                       just recipes                auto-discovery scanner
                    (set-version,                          |
                     set-marketplace-version)              v
                                              plugins/gamify/skills/<name>/SKILL.md
                                                  (gamify, pr-pace, work-on)
```

---

## Expected Changes

```
plugins/
  gamify/
    .claude-plugin/
      plugin.json          # UPDATE: remove `license`, remove `tokens`, bump version 1.0.0 -> 1.0.1 (via just set-version)

.claude-plugin/
  marketplace.json         # UPDATE: top-level version 2.2.3 -> 2.2.4 (via just set-marketplace-version);
                           #         gamify plugin entry version synced to 1.0.1 (via just set-version)

plugins/gamify/skills/gamify/SKILL.md       # UNCHANGED (auto-discovered)
plugins/gamify/skills/pr-pace/SKILL.md      # UNCHANGED (auto-discovered)
plugins/gamify/skills/work-on/SKILL.md      # UNCHANGED (auto-discovered)
```

Expected final shape of `plugins/gamify/.claude-plugin/plugin.json` after the fix:

```json
{
  "name": "gamify",
  "version": "1.0.1",
  "description": "PR velocity and gamified PR splitting skills. ...",
  "author": {
    "name": "John Wozniak",
    "email": "jwozniak.dev@gmail.com"
  }
}
```

---

## Workflow Steps

```
1. Edit plugin.json     -->  2. just set-version      -->  3. just set-marketplace-version
   (remove license,          gamify 1.0.1                  <next-patch>
    remove tokens)             |                             |
       |                       v                             v
       v                  plugin.json v1.0.1;          marketplace.json v2.2.4;
   4-key shape           marketplace.json entry        plugin entry v1.0.1
                         synced to 1.0.1
                               |                             |
                               +--------------+--------------+
                                              v
                          4. claude --plugin-dir ./plugins/gamify
                             (no validation errors; 3 skills discovered)
                                              |
                                              v
                          5. git diff --stat  (only 2 files touched)
                                              |
                                              v
                          6. git commit  (root cause + fix in message)
```

Phase dependencies (each phase depends only on prior phases):

- **Phase 1 — Manifest cleanup**: Remove `license` and `tokens` keys from `plugins/gamify/.claude-plugin/plugin.json`; verify JSON parses and only `name`, `version`, `description`, `author` remain.
- **Phase 2 — Plugin version bump** (needs Phase 1): `just set-version gamify 1.0.1`; verify both `plugin.json` and the gamify entry in `marketplace.json` read `1.0.1`.
- **Phase 3 — Marketplace version bump** (needs Phase 2): Confirm current top-level marketplace version; `just set-marketplace-version 2.2.4` (or `<current-patch + 1>` if drifted).
- **Phase 4 — Local install verification** (needs Phases 1–3): `claude --plugin-dir ./plugins/gamify`; confirm no `Validation errors` or `invalid manifest` and that `gamify`, `pr-pace`, `work-on` are discovered.
- **Phase 5 — Regression check** (needs Phase 4): `git diff --stat` touches only `plugins/gamify/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
- **Phase 6 — Commit** (needs Phases 1–5): Stage the two files only; commit with a message naming the root cause (invalid keys rejected by Zod validator) and the fix (reduced to 4-key peer pattern; versions bumped).

---

## Architecture Decisions

### Manifest Shape = 4-Key Peer Pattern

**Status**: Accepted

**Context**: Claude Code's Zod validator rejects `skills`, `commands` (as object arrays), and `tokens`. The `claude-code-plugin-manifest` skill notes `license` is technically schema-valid, but the task file mandates the four-key peer shape (and every peer plugin in the repo omits `license`).

**Options**:

1. Keep `license` (skill says it's schema-valid) and only remove `tokens`.
2. Remove `license`, `tokens`, `skills` -> 4-key shape matching all 12 peer plugins.
3. Overwrite the whole file with a byte-copy of `plugins/git/.claude-plugin/plugin.json` shape.

**Decision**: Option 2 — remove `license` and `tokens` via targeted Edits; keep existing `name`, `version`, `description`, `author` values.

**Consequences**:

- Manifest validates against the Zod schema and matches peer convention used by all 12 peer plugins.
- Diff is minimal (two field removals + recipe-driven version bumps), easing review.
- Any future "add `license` back" decision becomes an independent, repo-wide convention change — out of scope here.

### Version Bumps via `just` Recipes Only

**Status**: Accepted

**Context**: CLAUDE.md mandates `just set-version` and `just set-marketplace-version` for all version changes; the marketplace ships `plugins[].version` entries that must stay in sync with each plugin's own `plugin.json`.

**Options**:

1. Hand-edit version strings in both files.
2. Use `just` recipes exclusively.
3. Use the `bump-plugin` skill.

**Decision**: Option 2 — `just set-version gamify 1.0.1` then `just set-marketplace-version 2.2.4`.

**Consequences**:

- Single source of truth for version strings; no drift between `plugin.json` and `marketplace.json`.
- Aligns with the explicit repo rule; reviewers can verify by checking that only the recipe-managed lines changed.
- Bugfix -> patch bump (1.0.0 -> 1.0.1) follows the repo's "minor for features" convention, implying patch for bugfixes.

---

## Implementation Process

You MUST launch for each step a separate agent, instead of performing all steps yourself. And for each step marked as parallel, you MUST launch separate agents in parallel.

**CRITICAL:** For each agent you MUST:
1. Use the **Agent** type specified in the step (e.g., `haiku`, `opus`, `sdd:developer`)
2. Provide path to task file and prompt which step to implement
3. Require agent to implement exactly that step, not more, not less, not other steps

### Implementation Strategy

**Approach**: Bottom-Up (Building-Blocks-First)

**Rationale**: This is a packaging-only fix with no runtime workflow to orchestrate. The "building blocks" are two JSON files on disk, each independently testable (JSON parse, grepped value, `git diff`). Low-level correctness (manifest shape, version strings) must be in place before higher-level verification (install success) can possibly succeed. The dependency chain is strictly linear with a single read-only fan-out at baseline.

### Parallelization Overview

```
Step 1: Capture Baseline [haiku]
  (4 subtasks MUST be launched in parallel: read plugin.json, read marketplace.json,
   check SKILL.md files, capture git status/diff)
    |
    v
Step 2: Remove invalid keys from plugin.json [haiku]
  (Edit to remove license and tokens; verify JSON validity with jq)
    |
    v
Step 3: Version bumps - plugin then marketplace [haiku]
  (just set-version gamify 1.0.1 -> then -> just set-marketplace-version 2.2.4)
  (NOTE: two sub-commands are sequential within this step - both write marketplace.json)
    |
    v
Step 4: Verify install + regression check [opus]
  (claude --plugin-dir ./plugins/gamify verification launched alongside 3 parallel git diff
   checks; interpret all results and make pass/fail judgment)
  PARALLEL subtasks alongside CLI session:
    - git diff --stat
    - git diff -- plugins/gamify/skills/
    - git diff -- plugins/gamify/commands/
    |
    v
Step 5: Commit the fix [opus]
  (git add 2 specific files + git commit with descriptive message naming Zod validator
   and invalid keys; then PARALLEL: git log -1 --stat | git status)
```

**No step-level parallelism exists.** Steps 3's two `just` sub-commands both write `marketplace.json` and MUST be sequential within that step. Every subsequent step depends on all prior steps completing.

### Least-to-Most Decomposition Chain

| Level | Subproblem | Depends On |
|-------|------------|------------|
| 0 | Read current `plugin.json`, marketplace `version`, SKILL.md paths, git baseline | - |
| 1 | Reduce `plugin.json` to 4-key shape (remove `license`, `tokens`) | L0 |
| 2 | Bump plugin version 1.0.0 -> 1.0.1 AND marketplace version 2.2.3 -> 2.2.4 via `just` recipes | L1 |
| 3 | Local install verification + regression check | L2 |
| 4 | Commit with descriptive message (root cause + fix) | L3 |

---

### Step 1 — Capture baseline state

**Model:** haiku
**Agent:** haiku
**Depends on:** None
**Parallel with:** None (this is the first step)
**Note:** Individual subtasks MUST be launched in parallel by multiple agents.

**Goal**: Know exactly what is on disk before changing anything, so edits are targeted and diffs verifiable.

#### Expected Output

- Baseline note: `license` and `tokens` confirmed present in `plugins/gamify/.claude-plugin/plugin.json`; `skills` confirmed absent.
- Baseline note: `.claude-plugin/marketplace.json` top-level `version` recorded (expected `"2.2.3"`).
- Baseline note: all three `plugins/gamify/skills/{gamify,pr-pace,work-on}/SKILL.md` files exist.
- Baseline note: current `git status` / `git diff --stat` output.

#### Success Criteria

- [ ] Confirmed keys in `plugins/gamify/.claude-plugin/plugin.json`: `name`, `version`, `description`, `author`, `license`, `tokens`.
- [ ] Confirmed top-level `version` in `.claude-plugin/marketplace.json` equals `"2.2.3"` (or captured current value if drifted).
- [ ] Confirmed files exist: `plugins/gamify/skills/gamify/SKILL.md`, `plugins/gamify/skills/pr-pace/SKILL.md`, `plugins/gamify/skills/work-on/SKILL.md`.
- [ ] `git status` and `git diff --stat` baseline recorded.

#### Verification

**Level:** NOT NEEDED
**Rationale:** Pure read-only baseline capture. No artifact is produced; success is binary (files read and values recorded, or not). Schema-free data collection for later use — no judgment applicable.

#### Subtasks

The following subtasks have no interdependencies and MUST be launched in parallel:

| Sub-task | Description | Agent | Can Parallel |
|----------|-------------|-------|--------------|
| read-plugin-json | Read `/Users/jwozniak/code/context-engineering-toolkit/plugins/gamify/.claude-plugin/plugin.json` in full | haiku | Yes |
| read-marketplace-version | Read top-level `version` in `/Users/jwozniak/code/context-engineering-toolkit/.claude-plugin/marketplace.json` | haiku | Yes |
| verify-skill-files | Verify all three SKILL.md files exist via `ls /Users/jwozniak/code/context-engineering-toolkit/plugins/gamify/skills/*/SKILL.md` | haiku | Yes |
| capture-git-state | Capture `git status` and `git diff --stat` output | haiku | Yes |

#### Blockers

- None.

#### Risks

- None (read-only).

**Complexity**: Small | **Uncertainty**: Low | **Dependencies**: None

**Integration Points**: Filesystem (read only).

#### Definition of Done

- [ ] All baseline facts recorded; Step 2 can proceed with full knowledge of starting state.

---

### Step 2 — Remove `license` and `tokens` from `plugins/gamify/.claude-plugin/plugin.json`

**Model:** haiku
**Agent:** haiku
**Depends on:** Step 1
**Parallel with:** None

**Goal**: Reduce the manifest to the 4-key peer pattern (`name`, `version`, `description`, `author`) accepted by Claude Code's Zod validator.

#### Expected Output

- `plugins/gamify/.claude-plugin/plugin.json` containing exactly 4 top-level keys, syntactically valid JSON.

#### Success Criteria

- [X] File parses as valid JSON (e.g., `jq . plugins/gamify/.claude-plugin/plugin.json` exits 0).
- [X] Top-level keys are exactly `name`, `version`, `description`, `author`.
- [X] None of `skills`, `commands`, `license`, `tokens` appear as top-level keys.

#### Verification

**Level:** NOT NEEDED
**Rationale:** Simple JSON edit (remove two keys). Success is binary and mechanically verifiable: `jq .` validates syntax and `jq 'keys'` enumerates top-level keys against the exact 4-key target (`name`, `version`, `description`, `author`). No judgment needed beyond the mechanical checks already captured in Success Criteria.

#### Subtasks

**Note:** The two Edit operations below target the same file and MUST be performed sequentially (same-file constraint prevents parallelization).

- [X] Use Edit to remove `"license": "MIT",` line from `plugins/gamify/.claude-plugin/plugin.json`.
- [X] Use Edit to remove the entire `"tokens": { ... }` block from `plugins/gamify/.claude-plugin/plugin.json`.
- [X] Adjust the comma after `author` block so JSON stays valid.
- [X] Verify JSON validity with `jq . plugins/gamify/.claude-plugin/plugin.json` (or equivalent).
- [X] Read the file back and confirm the 4-key shape visually.

#### Blockers

- None.

#### Risks

- Trailing-comma invalidates JSON after removing trailing keys. Mitigation: read the file post-edit and run `jq .` to hard-parse.

**Complexity**: Small | **Uncertainty**: Low | **Dependencies**: Step 1

**Integration Points**: Indirectly — Claude Code Zod validator (final verification in Step 4).

#### Definition of Done

- [X] JSON parses cleanly.
- [X] Only 4 top-level keys present.
- [X] Read-back confirms shape.

---

### Step 3 — Version bumps: plugin 1.0.0 -> 1.0.1 and marketplace 2.2.3 -> 2.2.4

**Model:** haiku
**Agent:** haiku
**Depends on:** Step 2
**Parallel with:** None
**Note:** The two `just` sub-commands within this step MUST be run sequentially (both write to `marketplace.json`). Run `just set-version` first, then `just set-marketplace-version`.

**Goal**: Bump the gamify plugin version from `1.0.0` to `1.0.1` and the marketplace top-level version from `2.2.3` to `2.2.4`, using the single source-of-truth `just` recipes only.

#### Expected Output

- `plugins/gamify/.claude-plugin/plugin.json` shows `"version": "1.0.1"`.
- `.claude-plugin/marketplace.json` gamify entry shows `"version": "1.0.1"`.
- `.claude-plugin/marketplace.json` top-level `version` equals `"2.2.4"` (or current-patch + 1 if drifted).

#### Success Criteria

- [X] `grep '"version"' plugins/gamify/.claude-plugin/plugin.json` shows `"1.0.1"`.
- [X] `grep -A1 '"name": "gamify"' .claude-plugin/marketplace.json` shows `"version": "1.0.1"` on the next line.
- [X] `grep -n '"version"' .claude-plugin/marketplace.json | head -1` shows `"2.2.4"`.
- [X] No hand-edited version lines; only the `just` recipes touched them.

#### Verification

**Level:** NOT NEEDED
**Rationale:** Version string mutations driven by deterministic `just` recipes. Success is binary and grep-verifiable against exact expected values (`1.0.1` in two places, `2.2.4` at marketplace top-level). No judgment needed beyond the mechanical checks already captured in Success Criteria.

#### Subtasks

- [X] Run `just set-version gamify 1.0.1` from repo root.
- [X] Confirm recipe exit code is 0 and output has no errors.
- [X] Grep `plugins/gamify/.claude-plugin/plugin.json` for the new plugin version `"1.0.1"`.
- [X] Grep the gamify entry in `.claude-plugin/marketplace.json` for the new plugin version `"1.0.1"`.
- [X] Re-read top-level `version` in `.claude-plugin/marketplace.json` to confirm current value (expected `"2.2.3"`; recompute next patch if drifted).
- [X] Run `just set-marketplace-version 2.2.4` (or computed next-patch value).
- [X] Grep top-level `version` in `.claude-plugin/marketplace.json` to confirm `"2.2.4"`.

#### Blockers

- `just` must be installed locally (repo's `justfile` is the contract).

#### Risks

- Recipe fails if `plugin.json` is invalid after Step 2. Mitigation: Step 2 DoD validates JSON before this step.
- Marketplace version may have drifted. Mitigation: re-read immediately before running `just set-marketplace-version`.

**Complexity**: Small | **Uncertainty**: Low | **Dependencies**: Step 2

**Integration Points**: Writes to `plugins/gamify/.claude-plugin/plugin.json`, gamify entry in `.claude-plugin/marketplace.json`, and top-level `version` in `.claude-plugin/marketplace.json`.

#### Definition of Done

- [X] Both files show `"1.0.1"` for gamify.
- [X] Top-level marketplace `version` equals the computed next patch.
- [X] `git diff` shows only version-line changes (spot-check).

---

### Step 4 — Verify local install + regression check

**Model:** opus
**Agent:** opus
**Depends on:** Step 3
**Parallel with:** None
**Note:** The three `git diff` checks MUST be launched in parallel alongside the CLI session (they are pure filesystem reads with no dependency on the session result). Pass/fail judgment is made after all results are collected.

**Goal**: Empirically prove the Zod validator accepts the manifest and all three skills are auto-discovered; confirm only the two expected files changed.

#### Expected Output

- A local Claude Code session launched with `--plugin-dir ./plugins/gamify` with no validation errors and all three skills available.
- `git diff --stat` lists exactly `plugins/gamify/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` as modified, nothing else.

#### Success Criteria

- [ ] Session stdout/stderr contains no `Validation errors` or `invalid manifest` strings.
- [ ] `/help` (or equivalent) lists `gamify`, `pr-pace`, and `work-on` under the gamify plugin namespace.
- [ ] Direct invocation of any one of the three skills succeeds (does not emit "skill not found").
- [ ] `git diff --stat` shows exactly these two paths: `plugins/gamify/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
- [ ] `git diff -- plugins/gamify/skills/` produces empty output.
- [ ] `git diff -- plugins/gamify/commands/` produces empty output (if commands/ exists).

#### Verification

**Level:** Single Judge
**Artifact:** Verification evidence for `plugins/gamify/.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` (install session output, `/help` listing, `git diff --stat`, `git diff -- plugins/gamify/skills/`, `git diff -- plugins/gamify/commands/`)
**Threshold:** 4.0/5.0

**Rubric:**

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Install Validation | 0.30 | CLI session output contains no `Validation errors` or `invalid manifest` messages; gamify plugin reported as loaded/installed cleanly |
| Skill Auto-Discovery | 0.25 | All three skills (`gamify`, `pr-pace`, `work-on`) appear as invokable in the post-install session; direct invocation of at least one succeeds without "skill not found" |
| Diff Scope Integrity | 0.25 | `git diff --stat` shows exactly the two expected files (`plugins/gamify/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`); no stray changes to unrelated files |
| Zero Skills/Commands Regression | 0.15 | `git diff -- plugins/gamify/skills/` and `git diff -- plugins/gamify/commands/` both produce empty output (auto-discovered artifacts untouched) |
| Evidence Quality | 0.05 | Verification result recorded with specific evidence (session excerpt, diff stats) for traceability |

**Reference Pattern:** `.claude/skills/claude-code-plugin-manifest/SKILL.md` (authoritative source for valid manifest shape and failure modes)

#### Subtasks

The following subtasks MUST be launched in parallel (CLI session launch + all three git diff reads are independent):

| Sub-task | Description | Agent | Can Parallel |
|----------|-------------|-------|--------------|
| cli-session | Launch `claude --plugin-dir ./plugins/gamify`; inspect output for `Validation errors\|invalid manifest`; confirm `/help` lists all 3 skills | opus | Yes |
| git-diff-stat | Run `git diff --stat` and compare file list against the expected 2-file set | haiku | Yes |
| git-diff-skills | Run `git diff -- plugins/gamify/skills/` and confirm empty output | haiku | Yes |
| git-diff-commands | Run `git diff -- plugins/gamify/commands/` and confirm empty output | haiku | Yes |

After all parallel subtasks complete:

- [ ] Interpret CLI session result (pass/fail + evidence).
- [ ] Interpret all three diff results combined.
- [ ] Record overall verification result (pass/fail + evidence) in the task notes.
- [ ] If any stray change is found, stop and surface it to the user before deciding how to revert.

#### Blockers

- Claude CLI must be installed locally.

#### Risks

- Validator may still reject another field. Mitigation: if a new error appears, remove the named field to match the peer 4-key pattern and re-run.
- A SKILL.md file could have been moved. Mitigation: Step 1 confirms all three paths.
- Prior-session edits may have polluted the working tree. Mitigation: baseline in Step 1 should have surfaced these; if not, escalate before committing rather than running destructive `git checkout --`.

**Complexity**: Small | **Uncertainty**: Low | **Dependencies**: Step 3

**Integration Points**: Claude Code CLI, Zod validator, auto-discovery scanner, git working tree.

#### Definition of Done

- [ ] No validation error observed.
- [ ] All three skills auto-discovered.
- [ ] Evidence recorded.
- [ ] Only the two expected files show as modified.
- [ ] `skills/` diff confirmed empty.

---

### Step 5 — Commit the fix so the marketplace cache can refresh

**Model:** opus
**Agent:** opus
**Depends on:** Step 4
**Parallel with:** None
**Note:** After the commit lands, `git log -1 --stat` and `git status` MUST be run in parallel (both are read-only post-commit checks with no interdependency).

**Goal**: Persist the manifest fix and version bumps in a single well-described commit so downstream marketplace caches refresh from source.

#### Expected Output

- A commit touching exactly `plugins/gamify/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, with a message naming the root cause and the fix.

#### Success Criteria

- [ ] `git log -1 --stat` shows the commit touches only the two expected files.
- [ ] Commit message explicitly names the root cause (invalid `skills`/`tokens`/`license` keys rejected by Zod validator) and the fix (manifest reduced to 4-key peer pattern; plugin `1.0.0 -> 1.0.1`; marketplace `2.2.3 -> 2.2.4`).
- [ ] `git status` is clean w.r.t. the fix (unrelated untracked files may still exist).

#### Verification

**Level:** Single Judge
**Artifact:** Git commit object (verified via `git log -1 --stat` and commit message body) + working tree state (`git status`)
**Threshold:** 4.0/5.0

**Rubric:**

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Scope Correctness | 0.35 | `git log -1 --stat` shows commit touches exactly `plugins/gamify/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`; no other files staged in the commit |
| Root Cause Named | 0.25 | Commit message explicitly names the root cause (invalid `skills`/`tokens`/`license` keys rejected by Claude Code Zod validator) |
| Fix Described | 0.20 | Commit message describes the fix concretely (manifest reduced to 4-key peer pattern; plugin version `1.0.0 -> 1.0.1`; marketplace version `2.2.3 -> 2.2.4`) |
| Working Tree Clean | 0.10 | `git status` shows no leftover unstaged changes for the two fix files (the fix is fully committed, not partially staged) |
| Convention Adherence | 0.10 | Message follows CLAUDE.md/CONTRIBUTING convention (HEREDOC format, Co-Authored-By trailer, concise subject line) |

**Reference Pattern:** Recent commit messages visible via `git log --oneline -10` (establishes repo's commit-style baseline)

#### Subtasks

Sequential (must complete before post-commit checks):

- [ ] Stage explicit files: `git add plugins/gamify/.claude-plugin/plugin.json .claude-plugin/marketplace.json`.
- [ ] Create commit with a HEREDOC message (per CLAUDE.md/CONTRIBUTING convention); name the Zod validator as root cause and the 4-key peer pattern as the fix; include the Co-Authored-By trailer.
- [ ] If a pre-commit hook fails, fix the underlying issue and create a NEW commit (never `--amend`).

Post-commit verification (MUST be run in parallel after commit lands):

| Sub-task | Description | Agent | Can Parallel |
|----------|-------------|-------|--------------|
| git-log-stat | Run `git log -1 --stat` and verify only the two expected files appear | haiku | Yes |
| git-status | Run `git status` and verify no leftover unstaged changes for the two files | haiku | Yes |

#### Blockers

- None (local commit; push is out of scope unless user asks).

#### Risks

- Pre-commit hook failure. Mitigation: follow repo rule — fix the issue, re-stage, create a new commit.
- Accidentally staging unrelated files. Mitigation: explicit file list above.

**Complexity**: Small | **Uncertainty**: Low | **Dependencies**: Step 4

**Integration Points**: Git; marketplace cache (downstream refresh).

#### Definition of Done

- [ ] Commit exists with scoped diff and descriptive message.
- [ ] `git status` shows no leftover unstaged changes for the two files.

---

## Implementation Summary

| Step | Goal | Output | Agent | Est. Effort |
|------|------|--------|-------|-------------|
| 1 | Capture baseline of `plugin.json`, marketplace `version`, SKILL.md files, and git state | Recorded baseline facts | haiku | S |
| 2 | Remove `license` and `tokens` from gamify `plugin.json` | 4-key valid JSON | haiku | S |
| 3 | Bump gamify plugin version to `1.0.1` AND marketplace to `2.2.4` via `just` recipes | Both files updated with correct versions | haiku | S |
| 4 | Local install + skill auto-discovery verification + regression check | `claude --plugin-dir` clean; 3 skills discovered; only 2 files changed | opus | S |
| 5 | Commit with descriptive root-cause/fix message naming Zod validator and invalid keys | Commit pushed-ready in working branch | opus | S |

**Total Steps**: 5 (reduced from 7 by merging original Steps 3+4 and Steps 5+6)
**Critical Path**: Steps 1 -> 2 -> 3 -> 4 -> 5 (strictly linear; each depends on the previous).
**Parallel Opportunities**: Step 1's four internal read subtasks MUST be launched in parallel. Step 4's three `git diff` filesystem reads MUST be launched in parallel alongside the CLI session (they are independent of the session result). Step 5's two post-commit checks (`git log -1 --stat` and `git status`) MUST be launched in parallel after the commit lands. No step-level parallelism (sequential write constraint on `marketplace.json` prevents parallelizing Steps 3 sub-commands).

---

## Verification Summary

| Step | Verification Level | Judges | Threshold | Artifacts |
|------|--------------------|--------|-----------|-----------|
| 1 | NONE | - | - | Read-only baseline capture (no artifact produced) |
| 2 | NONE | - | - | `plugins/gamify/.claude-plugin/plugin.json` — schema-validated via `jq` + grep |
| 3 | NONE | - | - | `plugins/gamify/.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` — version strings grep-verifiable |
| 4 | Single Judge | 1 | 4.0/5.0 | Install session output + `/help` listing + `git diff --stat` + `git diff -- skills/` + `git diff -- commands/` |
| 5 | Single Judge | 1 | 4.0/5.0 | Git commit object (`git log -1 --stat` + commit message) + `git status` |

**Total Evaluations:** 2
**Implementation Command:** `/implement .specs/tasks/draft/fix-gamify-plugin-manifest-validation.bug.md`

---

## Risks & Blockers Summary

### High Priority

| Risk/Blocker | Impact | Likelihood | Mitigation |
|--------------|--------|------------|------------|
| Marketplace cache stale after fix | High (users keep seeing the install error) | High if not committed | Step 7 mandates a commit; user can push to clear downstream caches. |

### Medium Priority

| Risk/Blocker | Impact | Likelihood | Mitigation |
|--------------|--------|------------|------------|
| JSON syntax error after removing `license`/`tokens` (trailing comma) | Medium (blocks all downstream steps) | Low | Step 2 DoD runs `jq .` and visual read-back before proceeding. |
| Version drift between `plugin.json` and `marketplace.json` | Medium (release hygiene broken) | Low | Steps 3-4 use `just` recipes exclusively; no hand edits. |
| Validator rejects another unexpected field | Medium (Step 5 fails) | Low | Skill enumerates peer pattern; if new error, remove the named field and re-run. |

### Low Priority

| Risk/Blocker | Impact | Likelihood | Mitigation |
|--------------|--------|------------|------------|
| Stray working-tree edits pollute commit | Low | Low | Step 6 `git diff --stat` gate; explicit file staging in Step 7. |
| Pre-commit hook failure | Low | Low | Fix underlying issue and create a NEW commit (never `--amend`). |
| CONTRIBUTING.md template still shows `skills[]` | Low (future-recurrence) | Medium | Flagged as follow-up per task Excluded scope. |

---

## Definition of Done (Task Level)

- [X] `.claude/skills/claude-code-plugin-manifest/SKILL.md` read and its schema applied.
- [X] All 5 implementation steps completed.
- [X] All acceptance criteria in the parent task verified.
- [X] `plugins/gamify/.claude-plugin/plugin.json` contains only `name`, `version`, `description`, `author`.
- [X] Plugin version bumped to `1.0.1` via `just set-version gamify 1.0.1`.
- [X] Marketplace top-level version bumped to `2.2.4` via `just set-marketplace-version 2.2.4`.
- [ ] `claude --plugin-dir ./plugins/gamify` emits no validation errors.
- [ ] All three skills (`gamify`, `pr-pace`, `work-on`) auto-discovered in a post-install session.
- [X] `git diff --stat` touches only the two expected files; `skills/` diff empty.
- [X] Change committed with a descriptive message naming root cause and fix.
- [X] No high-priority risks left unaddressed.
