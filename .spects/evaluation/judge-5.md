Now I will deliver the final evaluation specification.

Here is the complete evaluation specification, written to the scratchpad at `/workspaces/context-engineering-kit/.specs/scratchpad/56e96ffc.md`.

---

```yaml
rrd_cycle_applied: true
self_verification_completed: true
evaluation_specification:
  metadata:
    user_prompt: "Analyse review-pr and review-local-changes skills. Review PR had been improved over time with multiple features including impact estimation/filtering, command arguments, etc. Update review-local-changes with new functionality, adjust when possible. Update template to be shorter, include only list of issues that passed impact and confidence filtering, base it on current review-pr template for inline comments. Add support for --json argument param with JSON template/example."
    artifact_type: "skill file in markdown format (SKILL.md)"
    source_reference: "/workspaces/context-engineering-kit/plugins/code-review/skills/review-pr/SKILL.md"
    target_artifact: "/workspaces/context-engineering-kit/plugins/code-review/skills/review-local-changes/SKILL.md"

  checklist:
    - id: "CK-001"
      question: "Does Phase 3 include both Impact Score (0-100) AND Confidence Score (0-100) evaluation with full rubrics for each?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The core feature being ported from review-pr is the dual scoring system; without both scores the progressive threshold filtering cannot work"

    - id: "CK-002"
      question: "Does the skill contain a progressive threshold table mapping impact score ranges to minimum confidence requirements, matching review-pr?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The progressive threshold table is the mechanism that enables smart filtering - critical issues need less confidence, low issues need more"

    - id: "CK-003"
      question: "Is a --min-impact argument defined with the same level mapping (critical/high/medium/medium-low/low) and corresponding score ranges as review-pr?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The --min-impact argument is explicitly required to be ported from review-pr"

    - id: "CK-004"
      question: "Is a --json argument defined as a flag that switches output to JSON format?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicitly requested new feature - the user specifically asked for --json support"

    - id: "CK-005"
      question: "Does the skill include a JSON output template or example showing the expected structure when --json is used?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicitly requested - user said 'Add json template/example for this case'"

    - id: "CK-006"
      question: "Does the skill use git status/git diff for local uncommitted changes rather than PR-specific commands?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Fundamental context - this is a local changes review skill, not a PR review skill"

    - id: "CK-007"
      question: "Is the markdown output template significantly shorter than the original verbose template (specifically: are the verbose Quality Assessment section with scores, Security Vulnerabilities table, Failed Checklist Items table, and Code Improvements section removed or consolidated)?"
      category: "hard_rule"
      importance: "important"
      rationale: "Explicitly requested - user said 'Make it shorter and include only list of issues that passed impact and confidence filtering'"

    - id: "CK-008"
      question: "Does the issue format use review-pr inline comment style with emoji severity markers (red/orange/yellow/green circle + Critical/High/Medium/Low + brief description + evidence)?"
      category: "hard_rule"
      importance: "important"
      rationale: "Explicitly requested - user said 'make it based on current review-pr template for inline comments'"

    - id: "CK-009"
      question: "Does the YAML frontmatter argument-hint include both --min-impact and --json?"
      category: "hard_rule"
      importance: "important"
      rationale: "Frontmatter argument-hint should reflect all available arguments for plugin discoverability"

    - id: "CK-010"
      question: "Does the filtering logic in Phase 3 exclude issues below the MIN_IMPACT_SCORE threshold?"
      category: "hard_rule"
      importance: "important"
      rationale: "Without this filtering logic, the --min-impact argument definition has no effect"

    - id: "CK-011"
      question: "Are the Impact Score bands defined correctly matching review-pr (0-20 Low, 21-40 Medium-Low, 41-60 Medium, 61-80 High, 81-100 Critical)?"
      category: "hard_rule"
      importance: "important"
      rationale: "Score band definitions must be consistent with review-pr for cross-skill consistency"

    - id: "CK-012"
      question: "Are all 6 review agents (security-auditor, bug-hunter, code-quality-reviewer, contracts-reviewer, test-coverage-reviewer, historical-context-reviewer) preserved?"
      category: "hard_rule"
      importance: "important"
      rationale: "Review agents are the core of the multi-agent review system and must not be lost during the update"

    - id: "CK-013"
      question: "Is the Confidence Score rubric with 5 levels (0, 25, 50, 75, 100) preserved with full descriptions for each level?"
      category: "hard_rule"
      importance: "important"
      rationale: "Existing feature from original skill that must be retained for the dual scoring to work"

    - id: "CK-014"
      question: "Is the false positives example list preserved or an equivalent list maintained?"
      category: "principle"
      importance: "important"
      rationale: "False positive examples calibrate scoring agents and prevent noise in results"

    - id: "CK-015"
      question: "Does the skill include a Configuration Resolution block or equivalent showing how all arguments (review-aspects, --min-impact, --json) are parsed?"
      category: "hard_rule"
      importance: "important"
      rationale: "Configuration Resolution makes argument parsing unambiguous for the reviewing agent"

    - id: "CK-016"
      question: "Does the JSON template include at minimum these fields: file path, line numbers, severity/impact level, description, evidence, impact_score, confidence_score?"
      category: "principle"
      importance: "important"
      rationale: "JSON output must contain all meaningful issue data for programmatic consumption"

    - id: "CK-017"
      question: "Does the output template (both markdown and JSON) show ONLY issues that passed both impact and confidence filtering?"
      category: "principle"
      importance: "important"
      rationale: "User explicitly required to include only list of issues that passed impact and confidence filtering"

    - id: "CK-018"
      question: "Is there handling for the case when no issues pass filtering (both markdown and JSON output)?"
      category: "principle"
      importance: "optional"
      rationale: "Edge case that should produce clean output rather than an empty or broken template"

    - id: "CK-019"
      question: "Is the skill description in YAML frontmatter updated to reflect the new capabilities (impact scoring, JSON output)?"
      category: "principle"
      importance: "optional"
      rationale: "Description should accurately represent the skill after the update"

    - id: "CK-020"
      question: "Does the updated skill accidentally include PR-specific commands or references (gh api, PR number references, /pulls/ endpoints, /reviews endpoint, inline PR comment posting, MCP GitHub inline comment tools)?"
      category: "hard_rule"
      importance: "pitfall"
      rationale: "Common mistake when porting from review-pr - PR-specific functionality does not apply to local changes review"

    - id: "CK-021"
      question: "Does the skill reference impact-based filtering in Phase 3 without having first defined the Impact Score rubric earlier in Phase 3?"
      category: "hard_rule"
      importance: "pitfall"
      rationale: "Logical inconsistency where filtering depends on undefined scores would break the agent workflow"

  rubric_dimensions:
    - name: "Feature Porting Completeness"
      description: "Does the updated skill include ALL key improvements from review-pr? Check for these 6 specific features: (1) Impact Score (0-100) rubric with 5 bands matching review-pr (Low 0-20, Medium-Low 21-40, Medium 41-60, High 61-80, Critical 81-100), (2) --min-impact argument with level mapping table, (3) Progressive threshold table mapping impact levels to minimum confidence requirements, (4) MIN_IMPACT_SCORE filtering logic that excludes issues below configured level, (5) Configuration Resolution block showing argument parsing pseudocode, (6) Formal Command Arguments section with argument definitions table. Are all 6 present, complete, and matching review-pr definitions?"
      scale: "1-5"
      weight: 0.25
      instruction: "Enumerate each of the 6 key features and verify presence and correctness against the review-pr SKILL.md source file at /workspaces/context-engineering-kit/plugins/code-review/skills/review-pr/SKILL.md. A feature is 'correctly ported' if its definition matches review-pr and is adapted to local context where appropriate."
      score_definitions:
        1: "0-1 of the 6 key features are present, or features that are present contain significant errors or mismatches with review-pr definitions"
        2: "2-3 features are present but some have errors, incomplete definitions, or are inconsistent with review-pr (DEFAULT - must justify higher)"
        3: "4-5 features are present and correctly defined, with only minor deviations from review-pr (RARE - requires evidence listing each feature found)"
        4: "All 6 key features are present, correctly defined, and match review-pr definitions while being adapted to local context (IDEAL - requires evidence that all 6 are verified)"
        5: "All 6 features ported perfectly, plus additional useful adaptations beyond review-pr that enhance the local review experience (OVERLY PERFECT)"

    - name: "Template Conciseness and Format Alignment"
      description: "Has the output template been significantly shortened compared to the original verbose review-local-changes template? The original template had approximately 120 lines spanning Quality Assessment scores, Security Vulnerabilities table, Failed Checklist Items table, and Code Improvements section. Does the new template use the review-pr inline comment format with emoji severity markers (red/orange/yellow/green circle + Critical/High/Medium/Low + brief description + evidence)? Does the template show ONLY issues that passed both impact and confidence filtering, with no unfiltered issues in the output?"
      scale: "1-5"
      weight: 0.20
      instruction: "Compare the new template against the original review-local-changes template (which had ~120 lines of template content across 6+ sections). Check that the format matches review-pr's inline comment style with emoji + severity + description + evidence. Verify that the template explicitly states it shows only filtered issues."
      score_definitions:
        1: "Template is largely unchanged from the original verbose format, or does not use review-pr inline comment format at all"
        2: "Template is somewhat shorter but retains most verbose sections (Quality Assessment scores, multiple tables), or format inconsistently follows review-pr style (DEFAULT)"
        3: "Template is significantly shorter (under 60 lines), uses the review-pr emoji+severity format for each issue, shows only filtered issues with clear per-issue structure (RARE - requires evidence comparing old vs new length)"
        4: "Template is maximally concise using review-pr format, properly handles both issues-found and no-issues cases, clear severity grouping (IDEAL)"
        5: "Perfectly concise template that adds useful formatting improvements beyond review-pr such as summary counts or actionable grouping (OVERLY PERFECT)"

    - name: "JSON Output Quality"
      description: "Is the --json argument properly defined in the Command Arguments section? Is there a JSON output template showing the complete expected structure with meaningful field names? Does the JSON include all essential fields: file path, line numbers, severity/impact level, description, evidence, impact_score, confidence_score? Is there clear conditional logic explaining when to use JSON vs markdown output? Is the JSON example syntactically valid and realistic?"
      scale: "1-5"
      weight: 0.20
      instruction: "Locate the --json argument definition in the Command Arguments section. Find the JSON template/example. Validate JSON structure is well-formed (proper braces, brackets, commas, quotes). Check for essential fields. Verify conditional output logic is stated explicitly in the workflow."
      score_definitions:
        1: "--json argument is missing entirely, or JSON template is absent, or the template is not recognizable as JSON structure"
        2: "--json is defined but JSON template is incomplete (missing 2+ essential fields from: file, lines, severity, description, evidence, impact_score, confidence_score) or has structural issues (DEFAULT)"
        3: "--json is defined, JSON template has all essential fields, conditional logic for JSON vs markdown output is stated, example is valid JSON (RARE - requires verifying each field)"
        4: "JSON template is comprehensive with clear field names, consistent value types, includes metadata section (summary or issue counts), and conditional logic is explicit and unambiguous (IDEAL)"
        5: "JSON template includes multiple examples (issues found and no issues), field type descriptions, and handles all output scenarios (OVERLY PERFECT)"

    - name: "Context-Appropriate Adaptation"
      description: "Does the skill correctly preserve the local changes context rather than becoming a PR review clone? Specifically check: (1) Phase 1 uses git status and git diff for local uncommitted changes, not PR-specific commands like git diff origin/master...HEAD, (2) No references to GitHub API endpoints, PR numbers, inline PR comments, gh api commands, or MCP GitHub tools, (3) Language consistently uses 'local changes' or 'uncommitted changes' rather than 'pull request', (4) Output goes to terminal as markdown/JSON rather than being posted to GitHub, (5) The Determine Applicable Reviews section is appropriate for local context."
      scale: "1-5"
      weight: 0.20
      instruction: "Search the entire skill text for PR-specific references: 'pull request', 'PR', 'gh api', '/pulls/', '/reviews', '/comments', 'inline comment', 'mcp__github'. Verify Phase 1 uses local git commands (git status, git diff without origin/). Check output is terminal-based."
      score_definitions:
        1: "Multiple PR-specific references remain (3+); skill reads more like a PR review than a local review"
        2: "Most PR-specific content removed but 1-2 PR-specific references, commands, or language patterns remain (DEFAULT)"
        3: "All PR-specific content properly adapted; language consistently refers to local/uncommitted changes; git diff used for local changes throughout (RARE - requires evidence of zero PR references)"
        4: "Perfectly adapted to local context with local-specific refinements such as staged vs unstaged change handling or local-context evaluation guidelines (IDEAL)"
        5: "Adaptation includes local-specific enhancements not in review-pr that meaningfully improve the local review experience, such as pre-commit integration or working directory context (OVERLY PERFECT)"

    - name: "Workflow and Scoring Coherence"
      description: "Does the skill workflow flow logically from preparation through issue finding to scoring and filtering? Specifically: (1) Does Phase 3 define BOTH scoring rubrics (Confidence Score and Impact Score) BEFORE the filtering step references them? (2) Is the progressive threshold table placed correctly before the filtering logic that uses it? (3) Are argument values (MIN_IMPACT_SCORE, JSON flag) parsed before any phase uses them? (4) Are inputs to each phase clearly derived from outputs of previous phases? (5) Is the overall flow clear enough for an AI agent to follow step-by-step without ambiguity?"
      scale: "1-5"
      weight: 0.15
      instruction: "Read the skill from top to bottom. For each reference to a score, argument value, or prior result, verify it was defined earlier in the document. Trace the flow: arguments parsed -> Phase 1 preparation -> Phase 2 issue finding -> Phase 3 scoring -> filtering -> output. Check for forward references to undefined concepts."
      score_definitions:
        1: "Significant logical gaps: filtering references undefined scores, or phases are out of order, or argument values are used before parsing"
        2: "Phases exist and mostly flow correctly but some logical issues remain (e.g., a scoring rubric placed after the filtering step that uses it) (DEFAULT)"
        3: "Clean logical flow: arguments parsed before use, both scoring rubrics defined before filtering, phase inputs come from previous phase outputs (RARE - requires tracing the full flow)"
        4: "Perfect flow with no ambiguity; every reference resolves to a prior definition; conditional output (JSON vs markdown) is clearly gated; edge cases handled (IDEAL)"
        5: "Exceptionally clear with explicit state tracking between phases, numbered step dependencies, and comprehensive edge case handling for all paths (OVERLY PERFECT)"

  scoring:
    default_score: 2
    threshold_pass: 3.0
    threshold_excellent: 4.0
    aggregation: "weighted_sum"
    total_weight: 1.00
    essential_checklist_gate: "If any checklist item with importance 'essential' fails (answer is NO), the overall score cannot exceed 2.0 regardless of rubric dimension scores"
    pitfall_penalty: "If any checklist item with importance 'pitfall' is YES (anti-pattern detected), reduce the affected rubric dimension score by 1 point (minimum 1)"
```
