---
title: Codebase Impact Analysis - Fix gamify plugin manifest skills validation error
task_file: .specs/tasks/draft/fix-gamify-plugin-manifest-validation.bug.md
scratchpad: .specs/scratchpad/ac3d3b77.md
created: 2026-04-22
status: complete
---

# Codebase Impact Analysis: Fix gamify plugin manifest skills validation error

## Summary

- **Files to Modify**: 2 files
- **Files to Create**: 0 files
- **Files to Delete**: 0 files
- **Test Files Affected**: 0 files
- **Risk Level**: Low

---

## Files to be Modified/Created

### Primary Changes

```
plugins/
└── gamify/
    └── .claude-plugin/
        └── plugin.json          # UPDATE: Remove license and tokens fields (skills[] already removed)

.claude-plugin/
└── marketplace.json             # UPDATE: Bump version via just set-marketplace-version <next-patch>
```

Note: The skills[] array was already removed from plugins/gamify/.claude-plugin/plugin.json in the working tree (confirmed via git diff HEAD). The remaining invalid fields are license (line 9) and tokens (lines 10-13). The version in plugin.json also needs bumping from 1.0.0 to 1.0.1 via just set-version gamify 1.0.1.

The just set-version recipe also updates the version in .claude-plugin/marketplace.json for the plugin entry; just set-marketplace-version then bumps the top-level marketplace version.

### Documentation Updates

```
CONTRIBUTING.md                  # RISK (out of scope for this task, follow-up recommended):
                                 # Template shows skills[] and commands[] as valid plugin.json
                                 # fields - this is incorrect and causes future recurrence
```

---

## Useful Resources for Implementation

### Pattern References

```
plugins/
├── git/
│   └── .claude-plugin/
│       └── plugin.json          # Reference: minimal 4-key schema (name, version, description, author)
├── tdd/
│   └── .claude-plugin/
│       └── plugin.json          # Reference: minimal 4-key schema
└── sadd/
    └── .claude-plugin/
        └── plugin.json          # Reference: minimal 4-key schema
```

---

## Key Interfaces & Contracts

### Valid plugin.json Schema (enforced by Claude Code Zod validator)

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "One-sentence description.",
  "author": {
    "name": "Author Name",
    "email": "author@example.com"
  }
}
```

### Field Reference

| Field | Required | Type | Valid |
|-------|----------|------|-------|
| name | YES | string | YES |
| version | NO | string | YES |
| description | NO | string | YES |
| author | NO | object | YES |
| author.name | NO | string | YES |
| author.email | NO | string | YES |
| skills[] | - | array | NO - auto-discovered from skills/<name>/SKILL.md |
| commands[] | - | array | NO - auto-discovered from commands/<name>.md |
| license | - | string | NO - remove entirely |
| tokens{} | - | object | NO - remove entirely |

### Fields to Modify

| Location | Field | Current State | Change Required |
|----------|-------|---------------|-----------------|
| plugins/gamify/.claude-plugin/plugin.json:9 | license | "MIT" | Remove field entirely |
| plugins/gamify/.claude-plugin/plugin.json:10-13 | tokens | {estimated:2500, description:...} | Remove field entirely |
| plugins/gamify/.claude-plugin/plugin.json:3 | version | "1.0.0" | Bump to "1.0.1" via just set-version gamify 1.0.1 |
| .claude-plugin/marketplace.json (top-level) | version | "2.2.3" | Bump to "2.2.4" via just set-marketplace-version 2.2.4 |
| .claude-plugin/marketplace.json:157 | gamify version | "1.0.0" | Updated automatically by just set-version gamify 1.0.1 |

---

## Integration Points

Files that interact with affected code and may need updates:

| File | Relationship | Impact | Action Needed |
|------|--------------|--------|---------------|
| .claude-plugin/marketplace.json | References gamify plugin at source ./plugins/gamify and version 1.0.0 | Medium | Bump top-level version via just set-marketplace-version; just set-version also syncs the gamify entry version |
| .claude/skills/claude-code-plugin-manifest/SKILL.md | Documents the valid schema and invalid fields | None | Read-only reference; no changes needed |
| plugins/gamify/skills/gamify/SKILL.md | Auto-discovered by Claude Code from filesystem | None | Must remain at skills/gamify/SKILL.md - no changes needed |
| plugins/gamify/skills/pr-pace/SKILL.md | Auto-discovered by Claude Code from filesystem | None | Must remain at skills/pr-pace/SKILL.md - no changes needed |
| plugins/gamify/skills/work-on/SKILL.md | Auto-discovered by Claude Code from filesystem | None | Must remain at skills/work-on/SKILL.md - no changes needed |
| CONTRIBUTING.md | Contains outdated plugin.json template with skills[] and commands[] arrays | Low (follow-up) | Out of scope for this fix; future-recurrence risk |

### Skill Auto-Discovery Verification

All three gamify skills exist and will be auto-discovered after install:

| Skill | Path | Status |
|-------|------|--------|
| gamify | plugins/gamify/skills/gamify/SKILL.md | EXISTS |
| pr-pace | plugins/gamify/skills/pr-pace/SKILL.md | EXISTS |
| work-on | plugins/gamify/skills/work-on/SKILL.md | EXISTS |

---

## Similar Implementations

### Pattern 1: Minimal valid plugin.json (git plugin)

- **Location**: plugins/git/.claude-plugin/plugin.json
- **Why relevant**: Uses exactly the 4-key schema; installs without error
- **Key files**: plugin.json - 9-line minimal manifest (name, version, description, author)

### Pattern 2: Minimal valid plugin.json (sadd plugin)

- **Location**: plugins/sadd/.claude-plugin/plugin.json
- **Why relevant**: Has multiple skills auto-discovered without any manifest skills declaration
- **Key files**: plugin.json - 9-line minimal manifest; skills in skills/ are auto-found

### Pattern 3: Minimal valid plugin.json (tdd plugin)

- **Location**: plugins/tdd/.claude-plugin/plugin.json
- **Why relevant**: Peer plugin confirming the standard shape
- **Key files**: plugin.json - 9-line minimal manifest with 4 keys only

---

## Test Coverage

### Existing Tests to Update

None. This repo has no automated test files for plugin manifests.

### New Tests Needed

| Test Type | Location | Coverage Target |
|-----------|----------|-----------------|
| Manual | CLI | claude --plugin-dir ./plugins/gamify must emit no "Validation errors" message |
| Manual | CLI | All three skills (gamify, pr-pace, work-on) appear in session after install |

---

## Risk Assessment

### High Risk Areas

| Area | Risk | Mitigation |
|------|------|------------|
| Marketplace cache staleness | After fixing plugin.json, users with cached old manifest still see the error until cache refreshes | Must commit and push the fix; marketplace cache refreshes from source commit |
| CONTRIBUTING.md template | Future contributors see skills[] in the template and add it to new plugins, causing the same error | Follow-up task to remove skills[] and commands[] from the CONTRIBUTING.md plugin.json example |

### Low Risk Areas

| Area | Risk | Mitigation |
|------|------|------------|
| Skill auto-discovery | Removing skills[] from manifest could break skill availability | Verified: all three SKILL.md files exist at correct paths; Claude Code auto-discovers them |
| Version recipes | just set-version or just set-marketplace-version could update wrong file | Both recipes validate file existence before writing; use exact plugin name gamify |

---

## Recommended Exploration

Before implementation, developer should read:

1. .claude/skills/claude-code-plugin-manifest/SKILL.md - Authoritative schema reference; lists all valid and invalid fields with rationale
2. plugins/git/.claude-plugin/plugin.json - Canonical minimal manifest pattern to copy
3. plugins/gamify/.claude-plugin/plugin.json - Current (partially fixed) state; shows license and tokens still present

---

## Verification Summary

| Check | Status | Notes |
|-------|--------|-------|
| All affected files identified | OK | 2 files to modify: plugin.json and marketplace.json |
| Integration points mapped | OK | marketplace.json version sync, Zod validator, CONTRIBUTING.md risk |
| Similar patterns found | OK | 3 patterns: git, tdd, sadd - all use 4-key minimal schema |
| Test coverage analyzed | OK | No automated tests; manual CLI verification required |
| Risks assessed | OK | Marketplace cache staleness (commit+push), CONTRIBUTING.md recurrence risk |

Limitations/Caveats:
- The working tree already has skills[] removed (git diff confirmed); implementation only needs to remove license and tokens, then bump versions.
- The marketplace version bump amount (2.2.3 -> 2.2.4) should be confirmed against current marketplace.json at implementation time in case it changed.
- CONTRIBUTING.md is explicitly out of scope for this fix per task spec; it is flagged here as a follow-up recommendation only.
