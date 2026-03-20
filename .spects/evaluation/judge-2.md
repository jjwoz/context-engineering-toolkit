Now I will return the final evaluation specification to the orchestrator.

---

Here is the complete evaluation specification for the task of updating `plugins/code-review/skills/review-local-changes/SKILL.md`:

**Scratchpad file**: `/workspaces/context-engineering-kit/.specs/scratchpad/9a18ed83.md`

**Reference files analyzed**:
- `/workspaces/context-engineering-kit/plugins/code-review/skills/review-pr/SKILL.md` (282 lines, the source of features to port)
- `/workspaces/context-engineering-kit/plugins/code-review/skills/review-local-changes/SKILL.md` (258 lines, the file to be updated)

```yaml
rrd_cycle_applied: true
self_verification_completed: true
evaluation_specification:
  metadata:
    user_prompt: "Analyse review-pr and review-local-changes skills. Port features from review-pr (impact estimation, command arguments, etc.) to review-local-changes. Update template to be shorter, show only filtered issues, base on review-pr inline comment format. Add --json argument with JSON template."
    artifact_type: "skill file in markdown format"
    artifact_path: "plugins/code-review/skills/review-local-changes/SKILL.md"
    reference_file: "plugins/code-review/skills/review-pr/SKILL.md"

  checklist:
    - id: "CK-001"
      question: "Does the file start with valid YAML frontmatter containing name (code-review:review-local-changes), description, and argument-hint fields?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Skill files must have valid frontmatter to be loaded by Claude Code"

    - id: "CK-002"
      question: "Does the frontmatter argument-hint include both --min-impact and --json arguments?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The argument-hint must reflect the new arguments for discoverability"

    - id: "CK-003"
      question: "Does Phase 3 include BOTH Confidence Score (0-100) AND Impact Score (0-100) with the same 5-level scales as review-pr?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The core requirement is to port impact estimation from review-pr"

    - id: "CK-004"
      question: "Does the file include the progressive confidence threshold table with 5 rows matching review-pr (Critical/50, High/65, Medium/75, Medium-Low/85, Low/95)?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The progressive threshold table is a key feature being ported from review-pr"

    - id: "CK-005"
      question: "Is --min-impact listed in the Command Arguments section with format '--min-impact <level>', default 'high', and all 5 level values (critical, high, medium, medium-low, low)?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The --min-impact argument must match review-pr's implementation"

    - id: "CK-006"
      question: "Is --json listed in the Command Arguments section as a boolean flag that switches output to JSON format?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The --json argument is explicitly requested in the user prompt"

    - id: "CK-007"
      question: "Is there a concrete JSON structure/template example showing expected output fields when --json is used?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The user explicitly requested a JSON template/example"

    - id: "CK-008"
      question: "Is the file valid markdown with proper heading hierarchy and correctly closed code blocks?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Invalid markdown will break rendering and agent parsing"

    - id: "CK-009"
      question: "Does the file include the Impact Level Mapping table with 5 levels matching review-pr (critical 81-100, high 61-80, medium 41-60, medium-low 21-40, low 0-20)?"
      category: "hard_rule"
      importance: "important"
      rationale: "Consistency with review-pr requires matching impact level definitions"

    - id: "CK-010"
      question: "Does the file include a Configuration Resolution section with pseudocode for parsing both --min-impact AND --json?"
      category: "hard_rule"
      importance: "important"
      rationale: "Configuration resolution pattern from review-pr must be ported and extended for --json"

    - id: "CK-011"
      question: "Is the output template significantly shorter than the original (~120 lines of template sections)?"
      category: "hard_rule"
      importance: "important"
      rationale: "User explicitly requested making the template shorter"

    - id: "CK-012"
      question: "Does the markdown output template use review-pr's emoji severity format (colored circle emoji + Critical/High/Medium/Low: brief description)?"
      category: "hard_rule"
      importance: "important"
      rationale: "User explicitly requested basing template on review-pr's inline comment template"

    - id: "CK-013"
      question: "Does the template explicitly state that only issues passing both impact and confidence filtering are listed?"
      category: "hard_rule"
      importance: "important"
      rationale: "User explicitly requested including only filtered issues"

    - id: "CK-014"
      question: "Does Phase 3 include explicit filtering instructions for both MIN_IMPACT level and confidence thresholds?"
      category: "hard_rule"
      importance: "important"
      rationale: "The filtering logic is the mechanism that makes the shorter template possible"

    - id: "CK-015"
      question: "Are the 6 review agents preserved (security-auditor, bug-hunter, code-quality-reviewer, contracts-reviewer, test-coverage-reviewer, historical-context-reviewer)?"
      category: "principle"
      importance: "important"
      rationale: "Review agents are core functionality that must be preserved"

    - id: "CK-016"
      question: "Are the false positive examples preserved from the original?"
      category: "principle"
      importance: "important"
      rationale: "False positive examples calibrate agent behavior and reduce noise"

    - id: "CK-017"
      question: "Does the file avoid PR-specific features (draft/closed PR check, GitHub API posting, PR eligibility recheck, PR description updating)?"
      category: "principle"
      importance: "important"
      rationale: "Local changes review has no PR context; PR features would be incorrect"

    - id: "CK-018"
      question: "Is there handling/template for when no issues are found after filtering?"
      category: "principle"
      importance: "important"
      rationale: "Must handle the empty result case gracefully"

    - id: "CK-019"
      question: "Does the JSON template include fields for file location, line numbers, severity/impact level, description, evidence, confidence score, and impact score?"
      category: "principle"
      importance: "important"
      rationale: "JSON output must be comprehensive for tooling integration"

    - id: "CK-020"
      question: "Does the file accidentally include PR-specific instructions such as 'post inline comments to GitHub', 'use gh api', 'check if PR is closed/draft', or 'add description to PR'?"
      category: "principle"
      importance: "pitfall"
      rationale: "PR-specific leakage would confuse the agent when reviewing local changes"

    - id: "CK-021"
      question: "Is the output template still excessively long (>80 lines of template content) despite the explicit requirement to shorten it?"
      category: "principle"
      importance: "pitfall"
      rationale: "Failing to shorten the template directly violates the user requirement"

    - id: "CK-022"
      question: "Does the file retain the old verbose template sections (Quality Assessment with scores, Failed Checklist Items table, Code Improvements & Simplifications) that should have been replaced?"
      category: "principle"
      importance: "pitfall"
      rationale: "Retaining old template structure contradicts the requirement to redesign based on review-pr format"

  rubric_dimensions:
    - name: "Feature Porting Completeness"
      description: "Has the implementation successfully ported all key features from review-pr to review-local-changes? Check for: (1) Impact Score 0-100 with 5-level scale identical to review-pr, (2) Progressive confidence threshold table with exact values, (3) --min-impact argument with level mapping, (4) Command Arguments section with definitions table, (5) Impact Level Mapping table, (6) Configuration Resolution pseudocode. Are the scoring scales, threshold values, and level definitions identical to review-pr?"
      scale: "1-5"
      weight: 0.28
      instruction: "Compare the updated review-local-changes against review-pr for each of the 6 enumerated features. Check that scoring scales, threshold values, and level definitions are identical. Score based on count of correctly ported features and accuracy of values."
      score_definitions:
        1: "Fewer than 2 of the 6 key features are ported from review-pr"
        2: "3-4 features ported but with incorrect values, missing details, or significant deviations from review-pr"
        3: "5-6 features ported with correct values matching review-pr"
        4: "All 6 features ported with identical scales, thresholds, and logic; wording matches review-pr where appropriate"
        5: "All features ported perfectly AND additional improvements or clarifications added that enhance the local-changes context beyond what review-pr offers"

    - name: "Context Adaptation Quality"
      description: "Has the implementation thoughtfully adapted PR-specific features for the local changes context rather than blindly copying? Check: (1) Draft/closed PR checks removed, (2) GitHub API posting removed/replaced with terminal output, (3) PR eligibility rechecks removed, (4) PR description updating removed, (5) Git commands use local diff (git diff, git diff --staged) not PR diff (git diff origin/master...HEAD), (6) Output is to terminal not GitHub, (7) Local-specific features preserved."
      scale: "1-5"
      weight: 0.18
      instruction: "Search the updated file for any remaining PR-specific references. Check git commands are appropriate for local context. Verify output method is terminal-based. Score based on thoroughness of adaptation."
      score_definitions:
        1: "PR-specific instructions remain in multiple places; file is a mechanical copy-paste of review-pr"
        2: "Most PR references removed but some leak through; local context partially adapted"
        3: "All PR-specific features removed; local context properly set up with correct git commands and terminal output"
        4: "Thoughtful adaptation where every section is tailored to local context; workflow feels native to local changes review"
        5: "Perfect adaptation plus added local-specific enhancements (e.g., staged vs unstaged distinction, pre-commit guidance)"

    - name: "Template Redesign Quality"
      description: "Has the output template been effectively redesigned? Check: (1) Template is significantly shorter than original ~120 lines, (2) Uses review-pr's emoji+severity format (colored circle + level + description), (3) Shows ONLY issues that passed filtering, (4) Includes evidence per issue, (5) No-issues-found case handled. Old sections (Quality Assessment, Required Actions, Found Issues, Security Vulnerabilities, Failed Checklist Items, Code Improvements) should be consolidated or removed."
      scale: "1-5"
      weight: 0.20
      instruction: "Count lines in old template vs new. Check for emoji+severity format. Verify only filtered issues shown. Check no-issues handling. Score based on brevity balanced with usefulness."
      score_definitions:
        1: "Template unchanged from original or longer; does not use review-pr format"
        2: "Template somewhat shorter but retains old verbose structure with multiple separate section tables; partially uses new format"
        3: "Template reduced to 40-60 lines of template content, uses emoji+severity format, shows only filtered issues with evidence"
        4: "Template under 40 lines with review-pr format, evidence per issue, no-issues handling, and clear structure"
        5: "Optimal template maximally concise while fully actionable, with creative format improvements beyond review-pr"

    - name: "JSON Output Design"
      description: "Has the --json argument been properly implemented? Check: (1) --json defined in argument definitions table, (2) --json included in configuration resolution pseudocode, (3) JSON template provided with complete fields (file, lines, severity, impact_score, confidence_score, description, evidence, category), (4) Conditional output logic specified, (5) JSON example is valid and realistic."
      scale: "1-5"
      weight: 0.19
      instruction: "Check all 5 aspects. Validate JSON example is syntactically correct. Check that conditional logic for format selection exists. Score based on completeness and design quality."
      score_definitions:
        1: "--json mentioned but no template provided, or template is invalid/unparseable JSON"
        2: "--json defined with basic JSON template missing key fields (e.g., no scores, no evidence)"
        3: "--json properly defined, parsed, with JSON template containing all essential fields (file, lines, severity, description, evidence, impact_score, confidence_score)"
        4: "Complete JSON design with realistic multi-issue example, all fields with proper types, clear conditional output logic, and summary metadata"
        5: "Exceptional JSON design with field descriptions, examples for both issues-found and no-issues cases, metadata fields, and schema documentation"

    - name: "Workflow and Instruction Clarity"
      description: "Are the workflow phases clear and executable by an LLM agent? Check: (1) Phases properly numbered, (2) Each step actionable and specific, (3) No contradictions, (4) Filtering logic unambiguous, (5) Output format selection (markdown vs JSON) has clear conditional, (6) Edge cases addressed (no changes, all issues filtered)."
      scale: "1-5"
      weight: 0.15
      instruction: "Read the entire skill as if executing it step-by-step. Identify confusion points, ambiguities, or contradictions. Score based on reliable executability."
      score_definitions:
        1: "Phases disordered or contradictory; agent would fail to execute"
        2: "Phases ordered but 2+ steps vague or ambiguous; agent would need to guess"
        3: "Clear phases with actionable steps; at most one minor ambiguity"
        4: "Unambiguous workflow with clear phase transitions, explicit conditions, all decision points clear"
        5: "Perfect clarity with edge case handling, fallback instructions, and explicit decision trees for every branch"

  scoring:
    default_score: 2
    threshold_pass: 3.0
    threshold_excellent: 4.0
    aggregation: "weighted_sum"
    total_weight: 1.0
```
