Here is the final evaluation specification:

```yaml
rrd_cycle_applied: true
self_verification_completed: true
evaluation_specification:
  metadata:
    user_prompt: "Analyse review-pr and review-local-changes skills. Review PR had been improved over time with features like impact estimation/filtering, command arguments, etc. Update review-local-changes with new functionality, adjust when possible. Update template to be shorter, include only list of issues that passed impact and confidence filtering, base it on current review-pr template for inline comments. Add support for --json argument param with JSON template/example."
    artifact_type: "skill file in markdown format (SKILL.md)"
    source_file: "/workspaces/context-engineering-kit/plugins/code-review/skills/review-pr/SKILL.md"
    target_file: "/workspaces/context-engineering-kit/plugins/code-review/skills/review-local-changes/SKILL.md"
    scratchpad: "/workspaces/context-engineering-kit/.specs/scratchpad/223505d9.md"

  checklist:
    - id: "CK-001"
      question: "Does Phase 3 include both Confidence Score (0-100) and Impact Score (0-100) with detailed rubrics?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Core feature being ported from review-pr; without impact scoring the filtering cannot work"

    - id: "CK-002"
      question: "Does the skill include the progressive confidence-impact threshold table matching review-pr (Critical/50, High/65, Medium/75, Medium-Low/85, Low/95)?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The progressive threshold is the key innovation from review-pr that must be ported"

    - id: "CK-003"
      question: "Does the skill define a --min-impact argument with levels critical, high, medium, medium-low, low and default value high?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicit requirement to port command arguments including impact filtering"

    - id: "CK-004"
      question: "Does the skill define a --json argument that triggers JSON output format?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicitly requested new feature"

    - id: "CK-005"
      question: "Does the skill include a concrete JSON template/example showing the expected output structure with fields for file, lines, severity, description, evidence, and scores?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicitly requested to add JSON template/example"

    - id: "CK-006"
      question: "Is the markdown output template significantly shorter than the original ~120-line verbose report template (removed Quality Assessment, Security Vulnerabilities, Checklist Items, Improvements sections)?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicitly requested to make template shorter"

    - id: "CK-007"
      question: "Does the output template use the emoji + severity + description + evidence format from review-pr inline comments (e.g., red/orange/yellow/green circle emoji + Critical/High/Medium/Low + brief description + evidence)?"
      category: "hard_rule"
      importance: "important"
      rationale: "Explicitly requested to base template on review-pr inline comments template"

    - id: "CK-008"
      question: "Does the template only show issues that passed both confidence threshold and MIN_IMPACT filtering (no unfiltered issues in output)?"
      category: "hard_rule"
      importance: "important"
      rationale: "Explicitly requested to include only filtered issues"

    - id: "CK-009"
      question: "Does the skill avoid including PR-specific features (GitHub API inline comments, PR eligibility checks, PR description generation, draft PR detection)?"
      category: "hard_rule"
      importance: "essential"
      rationale: "These features are specific to PR workflow and inappropriate for local changes review"

    - id: "CK-010"
      question: "Does the YAML frontmatter argument-hint include both --min-impact and --json?"
      category: "hard_rule"
      importance: "important"
      rationale: "Frontmatter must reflect available arguments for proper CLI integration"

    - id: "CK-011"
      question: "Is the YAML frontmatter valid with correct name field (code-review:review-local-changes)?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Invalid frontmatter or wrong name would break skill loading"

    - id: "CK-012"
      question: "Does the skill include the Impact Level Mapping table matching review-pr (critical: 81-100, high: 61-80, medium: 41-60, medium-low: 21-40, low: 0-20)?"
      category: "hard_rule"
      importance: "important"
      rationale: "Consistency with review-pr for the impact scoring system"

    - id: "CK-013"
      question: "Does the skill preserve all six review agent definitions (security-auditor, bug-hunter, code-quality-reviewer, contracts-reviewer, test-coverage-reviewer, historical-context-reviewer)?"
      category: "hard_rule"
      importance: "important"
      rationale: "Review agents are core functionality that should be preserved"

    - id: "CK-014"
      question: "Does the skill use local git commands (git status, git diff) rather than PR-based git commands (git diff origin/master)?"
      category: "hard_rule"
      importance: "essential"
      rationale: "This is a local changes review skill, not a PR review skill"

    - id: "CK-015"
      question: "Does the skill preserve the false positive examples section?"
      category: "principle"
      importance: "important"
      rationale: "False positive guidance is critical for reducing noise in reviews"

    - id: "CK-016"
      question: "Are all markdown code blocks properly opened and closed without nesting issues?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Broken markdown renders the skill unreadable by the agent"

    - id: "CK-017"
      question: "Does the skill include a Configuration Resolution section showing how --min-impact, --json, and review-aspects are parsed?"
      category: "hard_rule"
      importance: "important"
      rationale: "Clear parsing instructions ensure arguments are correctly handled"

    - id: "CK-018"
      question: "Does the skill incorrectly reference pull requests, PRs, or GitHub PR API in the context of local changes?"
      category: "principle"
      importance: "pitfall"
      rationale: "Terminology leak from review-pr would confuse the agent about scope"

    - id: "CK-019"
      question: "Does the skill contain duplicated sections or redundant instructions?"
      category: "principle"
      importance: "pitfall"
      rationale: "Token waste and potential confusion from duplicate content"

    - id: "CK-020"
      question: "Does the JSON template include a top-level summary or metadata field (e.g., total issues count, quality gate status)?"
      category: "principle"
      importance: "optional"
      rationale: "Good JSON API design includes summary metadata for quick consumption"

    - id: "CK-021"
      question: "Does the skill handle the no-issues-found case in both markdown and JSON output formats?"
      category: "principle"
      importance: "optional"
      rationale: "Good UX practice to handle the happy path explicitly in both formats"

    - id: "CK-022"
      question: "Does the Confidence Score rubric use the same scale points (0, 25, 50, 75, 100) adapted for local changes context (using 'changes' instead of 'PR')?"
      category: "hard_rule"
      importance: "important"
      rationale: "Consistency with review-pr scoring while adapted for local context"

  rubric_dimensions:
    - name: "Feature Adaptation Fidelity"
      description: "Does the updated skill faithfully port the key features from review-pr (impact scoring with 0-100 scale and 5-band rubric, progressive confidence-impact thresholds table, --min-impact argument with level mapping, configuration resolution pseudo-code) while correctly adapting them for local changes context? Does it avoid copying PR-specific elements (GitHub API posting, PR eligibility checks, PR description generation, draft PR detection)? Are scoring rubrics, impact level mappings, and threshold table values numerically consistent with review-pr?"
      scale: "1-5"
      weight: 0.28
      instruction: "Compare the updated skill against review-pr for each ported feature. Check: (1) Impact Score rubric with 0-20/21-40/41-60/61-80/81-100 bands and descriptions exists, (2) Progressive threshold table exists with values Critical/50, High/65, Medium/75, Medium-Low/85, Low/95, (3) --min-impact argument with default 'high' and all 5 levels, (4) Configuration Resolution pseudo-code for all arguments, (5) No PR-specific elements (search for 'pull request', 'PR', 'gh api', 'draft', 'closed'). Score based on completeness and accuracy of adaptation."
      score_definitions:
        1: "No features ported from review-pr, or PR-specific features (GitHub API, PR checks) blindly copied into local changes context"
        2: "Some features ported but missing key elements: either no Impact Score rubric, or no progressive threshold table, or no --min-impact argument, or PR terminology/features leak through"
        3: "All four key features ported (impact scoring rubric, progressive thresholds, --min-impact argument, configuration resolution) and correctly adapted for local context with no PR-specific leaks"
        4: "All features ported with exact numerical consistency with review-pr values, thoughtful local adaptation (e.g., 'changes' instead of 'PR'), no PR leaks, and unambiguous agent instructions"
        5: "Perfect adaptation that also improves upon review-pr patterns where appropriate for local context, adding clarity or better organization not present in review-pr"

    - name: "Template Conciseness and Format"
      description: "Is the new markdown output template significantly shorter than the original ~120-line verbose report (which had Quality Assessment, Required Actions, Found Issues, Security Vulnerabilities, Failed Checklist Items, and Code Improvements sections)? Does it replace those sections with a focused list using the review-pr inline comment format (emoji severity indicator + level + brief description + evidence + optional code suggestion)? Does the template only include issues that passed both impact and confidence filtering? Is a no-issues case handled?"
      scale: "1-5"
      weight: 0.25
      instruction: "Measure old template length (~lines 111-238 in original = ~127 lines) vs new template length. Check if verbose sections (Quality Assessment scores, Security table, Checklist table, Improvements list) are removed. Verify emoji + severity format matches review-pr pattern. Confirm template explicitly states it shows only filtered issues. Check for no-issues-found case."
      score_definitions:
        1: "Template unchanged or barely modified from original verbose format with multiple sections retained"
        2: "Template somewhat shorter but retains most verbose sections (Quality Assessment, Security, Checklist), or does not use the emoji + severity inline comment format from review-pr"
        3: "Template significantly shorter (at least 50% line reduction), uses emoji + severity inline format from review-pr, explicitly presents only filtered issues, and handles no-issues case"
        4: "Template maximally concise while retaining all essential information, perfectly follows review-pr inline format with emoji + level + description + evidence, clear filtered-only presentation, clean no-issues case"
        5: "Exceptionally concise and well-designed template that goes beyond requirements with formatting innovations that improve readability"

    - name: "JSON Output Quality"
      description: "Does the skill define a --json argument in the command arguments section with proper format and description? Does it clearly instruct the agent to produce JSON output instead of markdown when --json is provided? Does the JSON template/example include all relevant fields (file path, line numbers, severity level, description, evidence, impact score, confidence score)? Is the JSON structurally valid with proper types, nesting, and suitable for programmatic consumption (e.g., by CI tools)?"
      scale: "1-5"
      weight: 0.25
      instruction: "Verify: (1) --json appears in argument definitions table with format, default, and description, (2) Behavior when --json is provided is clearly described in workflow or output section, (3) JSON template/example exists with concrete example values (not just field names), (4) Required fields present: file, lines, severity, description, evidence, impact_score, confidence_score, (5) JSON is syntactically valid. Check if no-issues case is covered in JSON."
      score_definitions:
        1: "No --json argument defined in command arguments, or no JSON template/example provided anywhere in the skill"
        2: "--json argument defined but JSON template is minimal (missing 3+ key fields like scores or evidence), or JSON example is malformed/invalid"
        3: "--json defined in arguments table, JSON template includes all key fields (file, lines, severity, description, evidence, impact_score, confidence_score), and example contains valid JSON with concrete values"
        4: "Complete --json implementation with well-structured JSON array/object schema, all fields with appropriate types, concrete example values, covers both issues-found and no-issues-found cases"
        5: "Exceptional JSON design with additional metadata (timestamp, review summary, total counts), clear schema documentation, and structure anticipating downstream CI/tool integration"

    - name: "Workflow Coherence"
      description: "Do the workflow phases flow logically from preparation (argument parsing, git status/diff, change analysis) through review (parallel agents) to scoring (confidence + impact scoring) and output (filtered, formatted per --json flag)? Are arguments parsed in the Configuration Resolution section correctly referenced later in Phase 3 filtering (MIN_IMPACT_SCORE, OUTPUT_FORMAT)? Does the output template match what the filtering phase produces? Are there any contradictions, dangling references, or gaps between phases?"
      scale: "1-5"
      weight: 0.22
      instruction: "Read the skill end-to-end as an agent would execute it. Trace each argument from parsing through to usage: (1) Does --min-impact get parsed to MIN_IMPACT_SCORE? (2) Is MIN_IMPACT_SCORE referenced in Phase 3 filtering? (3) Does --json get parsed and checked before output? (4) Does output template expect fields that scoring produces? (5) Are there any references to undefined variables or sections? Look for contradictions between phases."
      score_definitions:
        1: "Phases are disjointed or contradictory; arguments parsed but never used in filtering; template expects data not produced by scoring; --json never checked after parsing"
        2: "Phases loosely connected with noticeable gaps: either --json is parsed but output section does not conditionally check for it, or filtering references variables not defined in parsing, or template fields do not match scoring output"
        3: "Phases flow logically: arguments parsed and used in filtering, template matches scoring output, --json conditional clearly handled at output, no contradictions between phases"
        4: "Seamless workflow with explicit phase transitions, all arguments traced from parsing to usage, --json and --min-impact both clearly flow through the entire pipeline, no ambiguity for the agent"
        5: "Exceptionally coherent workflow with clear decision trees at each phase, explicit edge case handling (no changes, no issues, invalid arguments), and perfect traceability from input to output"

  scoring:
    default_score: 2
    threshold_pass: 3.0
    threshold_excellent: 4.0
    aggregation: "weighted_sum"
    total_weight: 1.0
    essential_checklist_failure_cap: 2.0
```

**Key files referenced:**
- Source (review-pr): `/workspaces/context-engineering-kit/plugins/code-review/skills/review-pr/SKILL.md`
- Target (review-local-changes): `/workspaces/context-engineering-kit/plugins/code-review/skills/review-local-changes/SKILL.md`
- Scratchpad: `/workspaces/context-engineering-kit/.specs/scratchpad/223505d9.md`

**Summary of the evaluation specification:**

The specification evaluates 4 rubric dimensions (weighted sum = 1.0) and 22 checklist items:

- **Feature Adaptation Fidelity (0.28)** - Checks that impact scoring, progressive thresholds, --min-impact argument, and configuration resolution are ported from review-pr while PR-specific features are excluded
- **Template Conciseness and Format (0.25)** - Checks that the verbose ~120-line report template is replaced with a short list using review-pr's emoji + severity inline comment format showing only filtered issues
- **JSON Output Quality (0.25)** - Checks that --json argument is defined, JSON template exists with all required fields, and the example is valid and well-structured
- **Workflow Coherence (0.22)** - Checks that phases flow logically, arguments are traced from parsing through filtering to output, and there are no contradictions or dangling references

Essential checklist items (9 items) cover: impact scoring in Phase 3, progressive thresholds, --min-impact argument, --json argument, JSON template, shorter template, no PR-specific features, valid frontmatter, proper markdown formatting, and local git commands. Failure of any essential item caps the overall score at 2.0.
