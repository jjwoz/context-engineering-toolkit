Now I have completed all stages of analysis. Let me deliver the final evaluation specification.

---

Here is the final evaluation specification for the task of updating `review-local-changes/SKILL.md`.

**Scratchpad file**: `/workspaces/context-engineering-kit/.specs/scratchpad/07fecff7.md`

**Key source files analyzed**:
- `/workspaces/context-engineering-kit/plugins/code-review/skills/review-pr/SKILL.md` (282 lines - the reference skill with improvements)
- `/workspaces/context-engineering-kit/plugins/code-review/skills/review-local-changes/SKILL.md` (258 lines - the skill to be updated)

---

```yaml
rrd_cycle_applied: true
self_verification_completed: true
evaluation_specification:
  metadata:
    user_prompt: "Analyse review-pr and review-local-changes skills. Port improvements from review-pr (impact estimation, filtering, command arguments). Update template to be shorter, issue-focused, based on review-pr inline comment format. Add --json argument support with JSON template."
    artifact_type: "skill file in markdown format"
    artifact_path: "plugins/code-review/skills/review-local-changes/SKILL.md"
    reference_file: "plugins/code-review/skills/review-pr/SKILL.md"

  checklist:
    - id: "CK-001"
      question: "Does Phase 3 include an Impact Score (0-100) rubric with 5 levels (Low 0-20, Medium-Low 21-40, Medium 41-60, High 61-80, Critical 81-100) matching review-pr?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Impact estimation is the core feature being ported from review-pr"

    - id: "CK-002"
      question: "Does Phase 3 retain the Confidence Score (0-100) rubric with the 5-point scale (0/25/50/75/100) matching review-pr?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Confidence scoring must match review-pr for consistency across the review system"

    - id: "CK-003"
      question: "Does Phase 3 include the progressive confidence/impact threshold table (Critical needs 50 confidence, High needs 65, Medium needs 75, Medium-Low needs 85, Low needs 95)?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The progressive threshold table is the key filtering mechanism that determines which issues survive"

    - id: "CK-004"
      question: "Is --min-impact defined in a Command Arguments section with default value 'high' and the same level values (critical, high, medium, medium-low, low) as review-pr?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicitly requested feature to port from review-pr"

    - id: "CK-005"
      question: "Is --json defined in the Command Arguments section as a boolean flag?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicitly requested new feature for JSON output support"

    - id: "CK-006"
      question: "Does the file include a JSON output template/example showing the expected JSON structure when --json is used?"
      category: "hard_rule"
      importance: "essential"
      rationale: "User explicitly requested a JSON template/example for this case"

    - id: "CK-007"
      question: "Does the markdown output template use the review-pr inline comment format with emoji severity indicators (red/orange/yellow/green circle + Critical/High/Medium/Low) followed by evidence and optional suggestion?"
      category: "hard_rule"
      importance: "essential"
      rationale: "User explicitly requested the template be based on review-pr inline comment template"

    - id: "CK-008"
      question: "Is the output template significantly shorter than the original (~130 lines of template sections in the old SKILL.md)?"
      category: "hard_rule"
      importance: "important"
      rationale: "User explicitly requested to make the template shorter"

    - id: "CK-009"
      question: "Does the YAML frontmatter argument-hint field include both --json and --min-impact?"
      category: "hard_rule"
      importance: "important"
      rationale: "Frontmatter must accurately reflect available arguments for discoverability"

    - id: "CK-010"
      question: "Does the file include a Configuration Resolution section showing how $ARGUMENTS are parsed into REVIEW_ASPECTS, MIN_IMPACT, MIN_IMPACT_SCORE, and JSON_OUTPUT variables?"
      category: "hard_rule"
      importance: "important"
      rationale: "Clear argument parsing instructions prevent the agent from misinterpreting user input"

    - id: "CK-011"
      question: "Does the file include the Impact Level Mapping table with correct score ranges (critical: 81-100, high: 61-80, medium: 41-60, medium-low: 21-40, low: 0-20)?"
      category: "hard_rule"
      importance: "important"
      rationale: "Required for the agent to correctly resolve --min-impact argument values to numeric scores"

    - id: "CK-012"
      question: "Does the file avoid including PR-specific features (draft/closed checks, PR eligibility re-checks, PR description generation, GitHub API inline comment posting via gh api)?"
      category: "principle"
      importance: "important"
      rationale: "PR-specific features are incorrect in local changes context and would confuse the agent"

    - id: "CK-013"
      question: "Are git commands appropriate for local changes context (using git diff and git status, not git diff origin/master...HEAD)?"
      category: "principle"
      importance: "important"
      rationale: "Wrong git commands would produce incorrect review scope for local uncommitted changes"

    - id: "CK-014"
      question: "Is the JSON template syntactically valid JSON (proper quoting, commas, brackets, no trailing commas)?"
      category: "hard_rule"
      importance: "important"
      rationale: "Invalid JSON template would cause the agent to produce broken output"

    - id: "CK-015"
      question: "Does the JSON template include fields for: file path, line numbers, issue description, evidence, impact score, confidence score, severity level, and suggested fix?"
      category: "principle"
      importance: "important"
      rationale: "JSON output must capture all essential issue information that the markdown format provides"

    - id: "CK-016"
      question: "Does the template explicitly state that it shows only issues that passed both impact and confidence filtering?"
      category: "hard_rule"
      importance: "important"
      rationale: "User explicitly required only filtered issues in the output, not all found issues"

    - id: "CK-017"
      question: "Is the confidence/impact scoring rubric language adapted for local changes context (saying 'changes' or 'local changes' instead of 'PR' or 'pull request')?"
      category: "principle"
      importance: "important"
      rationale: "Consistent terminology prevents agent confusion about what it is reviewing"

    - id: "CK-018"
      question: "Does the false positives examples list remain present in the file?"
      category: "principle"
      importance: "important"
      rationale: "False positive examples are critical for reducing review noise and should not be removed during the update"

    - id: "CK-019"
      question: "Does the file include a 'no issues found' output case with appropriate messaging?"
      category: "principle"
      importance: "important"
      rationale: "Agent needs guidance for the case when no issues survive filtering"

    - id: "CK-020"
      question: "Does the file include conditional instructions that output JSON only when --json is provided and markdown otherwise?"
      category: "hard_rule"
      importance: "important"
      rationale: "JSON output should only happen when --json flag is explicitly provided, markdown is the default"

    - id: "CK-021"
      question: "Are there broken or improperly nested markdown code blocks in the file (e.g., triple-backtick blocks inside other triple-backtick blocks without proper escaping)?"
      category: "principle"
      importance: "pitfall"
      rationale: "Nested code blocks in markdown are a common source of rendering errors that break agent parsing"

    - id: "CK-022"
      question: "Does the file still contain the old verbose template sections (Quality Assessment scores with X/Y format, separate Security Vulnerabilities table, separate Failed Checklist Items table, separate Code Improvements & Simplifications section)?"
      category: "principle"
      importance: "pitfall"
      rationale: "Retaining old template sections directly contradicts the explicit requirement to make the template shorter and issue-list-focused"

  rubric_dimensions:
    - name: "Feature Porting Accuracy"
      description: "Does the updated review-local-changes file accurately port the impact estimation and filtering features from review-pr? Specifically: Is the Impact Score (0-100) rubric present with all 5 levels and descriptions matching review-pr? Is the Confidence Score (0-100) rubric present with all 5 levels matching review-pr? Is the progressive confidence/impact threshold table present with correct values? Is the Impact Level Mapping table present? Is the --min-impact argument defined with correct format, default, and values? Is the MIN_IMPACT filtering logic present in the scoring/filtering phase? Is the Configuration Resolution pseudocode present?"
      scale: "1-5"
      weight: 0.30
      instruction: "Compare each scoring rubric, threshold table, and filtering instruction in the updated file against review-pr SKILL.md. Check for exact match of score ranges (0-20, 21-40, 41-60, 61-80, 81-100), confidence levels (0, 25, 50, 75, 100), threshold values (50, 65, 75, 85, 95), and filtering logic. Count how many of these 7 features are present and correct."
      score_definitions:
        1: "Impact scoring is missing entirely, or only the old confidence-only scoring exists without impact scoring added"
        2: "Impact scoring is present but with incorrect ranges or missing the threshold table or wrong filtering logic; OR --min-impact argument is missing; OR fewer than 4 of the 7 features are correctly ported"
        3: "All 7 features (impact rubric, confidence rubric, progressive threshold table, impact level mapping, --min-impact arg, MIN_IMPACT filtering, configuration resolution) are present and match review-pr. Minor wording differences acceptable."
        4: "All 7 features match review-pr exactly. Language in rubrics is properly adapted for local changes context (e.g., 'changes' instead of 'PR'). Configuration resolution includes JSON_OUTPUT variable."
        5: "Perfect port of all features with additional improvements beyond what was requested, such as better explanations of edge cases or additional helpful context for the scoring agents."

    - name: "Contextual Adaptation"
      description: "Does the file properly adapt PR-specific features for the local changes context? Are PR-only features correctly omitted (draft/closed checks, eligibility re-checks, GitHub API posting, PR description generation)? Are git commands appropriate for local uncommitted changes (git diff, git status rather than git diff origin/master...HEAD)? Is language consistently adapted ('local changes' or 'changes' instead of 'pull request')? Are the review agent descriptions adapted (e.g., historical-context-reviewer references commits not PRs)?"
      scale: "1-5"
      weight: 0.20
      instruction: "Scan the entire file for any PR-specific content copied verbatim without adaptation. Check: (1) Are there draft/closed checks? (2) Are there eligibility re-checks? (3) Are there GitHub API posting instructions? (4) Are there PR description generation instructions? (5) Do git commands use origin/master...HEAD? (6) Does the text say 'pull request' where it should say 'local changes'? Count violations."
      score_definitions:
        1: "Three or more PR-specific features are copied verbatim (draft checks, GitHub API posting, PR eligibility re-checks, PR description generation all remain)"
        2: "One or two PR-specific features remain, OR language references 'pull request' in multiple places, OR git commands still use origin/master...HEAD for scope determination"
        3: "All PR-specific features properly removed or adapted. Git commands correct for local changes. Language consistently uses 'local changes' terminology. At most one minor slip."
        4: "Zero traces of PR-specific content. All git commands, agent instructions, and language are fully appropriate for local changes review context."
        5: "Perfect adaptation plus new local-changes-specific improvements not present in review-pr, such as staged vs unstaged change handling or working tree considerations."

    - name: "Template Design"
      description: "Is the output template significantly shorter than the original 130+ line template? Does it focus exclusively on the list of issues that passed filtering? Does it use the review-pr inline comment format (emoji circle + severity level + brief description, followed by evidence, followed by optional code suggestion)? Is there a clear and concise 'no issues found' case? Is the template easy for the agent to fill in?"
      scale: "1-5"
      weight: 0.20
      instruction: "Count the lines in the output template section(s). Compare against the original ~130 lines. Verify the format matches review-pr's inline comment template. Check that the template explicitly restricts content to filtered issues only. Verify the no-issues case exists."
      score_definitions:
        1: "Template is the same length or longer than original, OR does not use review-pr's inline comment format at all"
        2: "Template is somewhat shorter but retains several old sections (quality assessment scores, separate security vulnerabilities table, separate checklist table, separate improvements section). Format only partially matches review-pr."
        3: "Template is significantly shorter (under 60 lines), uses the review-pr emoji+severity format, shows only filtered issues, and has a no-issues case."
        4: "Template is at most 40 lines for the issue list format, uses the exact review-pr emoji+severity format with evidence and suggestion, contains no unnecessary sections from the old template, and has a clear no-issues case."
        5: "Exceptionally concise template that achieves maximum clarity in minimal lines, with creative improvements to the review-pr format while remaining shorter than required."

    - name: "JSON Output Quality"
      description: "Is the --json argument properly defined in the Command Arguments section with correct format and description? Are there clear conditional instructions telling the agent to output JSON when --json is provided and markdown otherwise? Is the JSON template syntactically valid? Does it include all necessary fields (file, lines, description, evidence, impact_score, confidence_score, severity, suggestion)? Does it have a summary/metadata wrapper (e.g., total issues count, quality gate status)? Is the structure well-nested and logical?"
      scale: "1-5"
      weight: 0.20
      instruction: "Verify: (1) --json flag exists in argument definitions table, (2) conditional output instructions exist, (3) JSON template is syntactically valid (paste into a JSON validator mentally), (4) count fields present in each issue object, (5) check for metadata/summary wrapper."
      score_definitions:
        1: "--json argument is missing from the file, OR no JSON template/example exists anywhere in the file"
        2: "--json argument exists but JSON template is incomplete (missing 3+ key fields like impact_score, confidence_score, or evidence), OR is syntactically invalid JSON, OR there are no conditional instructions for when to use JSON vs markdown"
        3: "--json argument properly defined, conditional logic present, JSON template is syntactically valid and includes all essential per-issue fields (file, lines, description, evidence, impact_score, confidence_score, severity, suggestion)"
        4: "All of score 3 plus: JSON has a well-structured wrapper with metadata (total count, quality gate, min_impact_level used), issues are in a properly nested array, and field naming is consistent and follows JSON conventions (snake_case)"
        5: "All of score 4 plus additional structure exceeding requirements such as typed severity enums, separate arrays by severity level, or explicit field type documentation"

    - name: "Workflow Coherence"
      description: "Do all workflow phases reference each other correctly after the update? Is the overall flow logical (Preparation with argument parsing -> Issue Search -> Confidence & Impact Scoring & Filtering -> Output)? Does Phase 1 reference the Command Arguments section for parsing? Does Phase 3 reference the Impact Level Mapping for filtering? Does the output section reference Phase 3 filtering results? Are there any contradictions between the old scoring instructions (filter at confidence 80) and the new progressive threshold table? Do agent launch instructions consistently reference the right context?"
      scale: "1-5"
      weight: 0.10
      instruction: "Read through the entire workflow sequentially. Check: (1) Phase 1 references Command Arguments section, (2) Phase 3 heading updated to include impact (not just 'Confidence Scoring'), (3) No leftover 'filter at 80' instruction contradicting the new threshold table, (4) Output section references filtered results, (5) No dangling references to removed sections."
      score_definitions:
        1: "Workflow has broken references (e.g., references to removed template sections), missing phases, or direct contradictions (e.g., old 'filter at confidence 80' coexists with new progressive threshold table)"
        2: "Workflow is mostly intact but has at least one inconsistency: Phase 3 heading still says only 'Confidence Scoring' without mentioning impact, OR the old confidence-only filter instruction remains alongside the new threshold table, OR output section references old template structure"
        3: "Workflow is logically coherent with no contradictions. All cross-references between Command Arguments, Phase 3, and output work correctly. Phase 3 heading reflects both confidence and impact."
        4: "Workflow is perfectly coherent with explicit cross-references between sections (e.g., 'per the Command Arguments section above', 'using the threshold table below'). Clear phase transitions and consistent terminology throughout."
        5: "Workflow improvements beyond review-pr's structure, such as clearer phase summaries, better agent instructions, or streamlined parallel execution guidance."

  scoring:
    default_score: 2
    threshold_pass: 3.0
    threshold_excellent: 4.0
    aggregation: "weighted_sum"
    total_weight: 1.00
    essential_checklist_gate: "If any checklist item with importance 'essential' (CK-001 through CK-007) fails, overall score cannot exceed 2.0"
    pitfall_penalty: "If any checklist item with importance 'pitfall' (CK-021, CK-022) is YES (anti-pattern detected), reduce overall score by 0.5"
```
