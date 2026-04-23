---
name: Claude Code Plugin Manifest Schema
description: Valid plugin.json schema for Claude Code plugins - what fields are supported and how skills/commands are discovered
topics: claude-code, plugin, manifest, plugin.json, skills, validation
created: 2026-04-22
updated: 2026-04-22
scratchpad: .specs/scratchpad/2dbd7757.md
---

# Claude Code Plugin Manifest Schema

## Overview

Claude Code validates plugin.json manifests against a strict Zod schema. Skills and commands are auto-discovered from the directory structure - they must NOT be declared as arrays of objects in plugin.json. Declaring `skills` or `commands` as arrays of objects (the CONTRIBUTING.md pattern) causes a "Validation errors: skills: Invalid input" error on install. The `tokens` field is also unsupported. Fields like `license`, `homepage`, `repository`, and `keywords` are valid per the official schema.

---

## Key Concepts

- **Auto-discovery**: Claude Code reads skills from `skills/<name>/SKILL.md` and commands from `commands/<name>.md` directories automatically - no manifest declaration needed
- **Strict schema**: The manifest is Zod-validated; `skills`/`commands` as arrays of objects, and `tokens`, cause install failure - but standard metadata fields like `license` are valid
- **CONTRIBUTING.md is outdated**: The project's CONTRIBUTING.md template shows `skills[]` and `commands[]` as valid plugin.json fields - this is incorrect for the current Claude Code version

---

## Valid plugin.json Schema

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

| Field | Required | Type | Notes |
|-------|----------|------|-------|
| name | YES | string | Must match directory name |
| version | NO | string | Semver recommended |
| description | NO | string | One-sentence summary |
| author | NO | object | Contains name and/or email |
| author.name | NO | string | Author display name |
| author.email | NO | string | Author email |

### Invalid Usage (causes validation failure)

| Field | Invalid Form | Correct Form |
|-------|-------------|--------------|
| skills | Array of objects `[{name, path}]` | Omit (auto-discovery) or use path string `"./skills/"` |
| commands | Array of objects `[{name, path}]` | Omit (auto-discovery) or use path string `"./commands/"` |
| tokens{} | Any form | Remove entirely - not part of schema |

**Note**: `license`, `homepage`, `repository`, and `keywords` ARE valid metadata fields per the official schema. Only `tokens` and the CONTRIBUTING.md-style object arrays for skills/commands are invalid.

---

## Directory Auto-Discovery

Claude Code discovers plugin contents from the file system:

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # ONLY the fields above
├── skills/
│   └── <skill-name>/
│       └── SKILL.md          # Auto-discovered
├── commands/
│   └── <command-name>.md     # Auto-discovered
└── agents/
    └── <agent-name>.md       # Auto-discovered
```

Skills do NOT need to be listed in plugin.json. The `skills/` subdirectory name becomes the skill identifier.

---

## Common Pitfalls

| Issue | Impact | Solution |
|-------|--------|----------|
| skills[] as array of objects in plugin.json | Plugin fails to install with "skills: Invalid input" | Remove the skills array entirely (use auto-discovery) or change to path string |
| commands[] as array of objects in plugin.json | Plugin fails to install | Remove the commands array entirely (use auto-discovery) or change to path string |
| tokens{} field in manifest | Fails validation | Remove - not part of the official schema |
| Missing SKILL.md in skills/<name>/ directory | Skill silently not discovered after install; no error shown | Create skills/<name>/SKILL.md at exact path; verify with --plugin-dir |
| Outdated CONTRIBUTING.md template | Developer adds invalid object arrays following docs | Follow this skill, not CONTRIBUTING.md |
| Marketplace cache stale | Old invalid manifest cached after fix | Must commit + push; cache refreshes from source |

---

## Recommendations

1. **Minimal manifest**: Only include name, version, description, and author. Do not add anything else unless you need custom component paths.
2. **Trust auto-discovery**: Place skills in `skills/<name>/SKILL.md` and commands in `commands/<name>.md` - Claude Code finds them automatically.
3. **After fixing plugin.json**: Commit and push the fix. The marketplace cache must be refreshed from the updated source.
4. **Update CONTRIBUTING.md**: The project template showing skills[] in plugin.json must be removed to prevent recurrence.

---

## Verification

### Test a plugin locally without installing

```bash
# Load plugin for current session only - no install required
claude --plugin-dir ./plugins/<plugin-name>

# Load multiple plugins at once
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

### Reload plugins after changes in an active session

```
/reload-plugins
```

### Verify skills are discovered after load

After launching with `--plugin-dir`, run `/help` to see skills listed under the plugin namespace, or invoke a skill directly:

```
/<plugin-name>:<skill-name>
```

If a skill is missing after install, confirm `skills/<skill-name>/SKILL.md` exists at exactly that path in the plugin directory.

---

## Verified Working plugin.json Examples

All of these plugins install successfully with this minimal schema (verified April 2026, Claude Code 2.1.117):

- plugins/sdd, plugins/sadd, plugins/code-review, plugins/customaize-agent, plugins/git
- Official: hookify, code-simplifier, github, plugin-dev, skill-creator, example-plugin

None of them declare skills or commands in plugin.json.

---

## Sources & Verification

| Source | Type | Last Verified |
|--------|------|---------------|
| https://code.claude.com/docs/en/plugins-reference | Official/Primary | 2026-04-22 |
| https://code.claude.com/docs/en/plugins | Official/Primary | 2026-04-22 |
| ~/.claude/plugins/cache/ (15+ plugins inspected) | Empirical | 2026-04-22 |
| ~/.claude/plugins/marketplaces/claude-plugins-official/ | Empirical | 2026-04-22 |
| git log plugins/gamify/.claude-plugin/plugin.json | Historical | 2026-04-22 |
| Claude Code CLI 2.1.117 error output | Error trace | 2026-04-22 |

---

## Changelog

| Date | Changes |
|------|---------|
| 2026-04-22 | Initial creation for task: fix-gamify-plugin-manifest-validation.bug |
| 2026-04-22 | Updated: corrected license field status (valid per official docs); added missing SKILL.md pitfall; added Verification section with --plugin-dir examples; replaced absolute paths with ~/.claude/ notation; added official docs to Sources |