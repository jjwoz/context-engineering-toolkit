Now I will return the final evaluation specification.

```yaml
rrd_cycle_applied: true
self_verification_completed: true
evaluation_specification:
  metadata:
    user_prompt: "Analyse review-pr and review-local-changes skills. Review PR had been improved over time with features including impact estimation/filtering, command arguments, etc. Update review local changes with new functionality, adjust when possible. Also, update template to be shorter - include only list of issues that passed impact and confidence filtering, based on current review-pr template for inline comments. Additionally, add support for --json argument param for JSON output format with a template/example."
    artifact_type: "skill file in markdown format (SKILL.md)"
    scratchpad: "/workspaces/context-engineering-kit/.specs/scratchpad/17023dec.md"
    reference_files:
      - "/workspaces/context-engineering-kit/plugins/code-review/skills/review-pr/SKILL.md"
      - "/workspaces/context-engineering-kit/plugins/code-review/skills/review-local-changes/SKILL.md"

  checklist:
    - id: "CK-001"
      question: "Does Phase 3 include Impact Score (0-100) with the same 5 severity levels (Critical 81-100, High 61-80, Medium 41-60, Medium-Low 21-40, Low 0-20) as review-pr?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Core requirement: porting impact estimation from review-pr"

    - id: "CK-002"
      question: "Does Phase 3 retain the Confidence Score (0-100) with the same 5-point scale (0/25/50/75/100) matching review-pr's descriptions?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Confidence scoring must be upgraded to match review-pr's more detailed and nuanced scale"

    - id: "CK-003"
      question: "Does Phase 3 include the progressive confidence-impact threshold table with exact values (Critical:50, High:65, Medium:75, Medium-Low:85, Low:95)?"
      category: "hard_rule"
      importance: "essential"
      rationale: "The progressive threshold table is the key filtering mechanism ported from review-pr"

    - id: "CK-004"
      question: "Is the --min-impact argument defined with format (--min-impact <level>), default value (high), and all 5 level options matching review-pr?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicit requirement to port command arguments from review-pr"

    - id: "CK-005"
      question: "Is the Impact Level Mapping table present with correct score ranges matching review-pr (critical:81, high:61, medium:41, medium-low:21, low:0)?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Required for --min-impact argument to function correctly"

    - id: "CK-006"
      question: "Is the --json argument defined as a boolean flag in the Command Arguments section?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicit requirement to add --json support"

    - id: "CK-007"
      question: "Does the skill specify that when --json is provided, the agent outputs results in JSON format instead of markdown?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicit conditional behavior requirement from user prompt"

    - id: "CK-008"
      question: "Is there a concrete JSON template/example showing the complete structure for issue output with realistic sample data?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicit requirement for JSON template/example"

    - id: "CK-009"
      question: "Is the default (non-JSON) output template significantly shorter than the original ~120-line multi-section report, having removed the verbose Quality Assessment, Required Actions, Security Vulnerabilities, Failed Checklist, and Code Improvements sections?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicit requirement to make template shorter with only filtered issues"

    - id: "CK-010"
      question: "Does the default output template use the review-pr inline comment format with emoji severity indicator (red/orange/yellow/green circle), severity label, description, evidence, and optional code suggestion?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Explicit requirement to base template on review-pr inline comment format"

    - id: "CK-011"
      question: "Does the frontmatter argument-hint include both --min-impact and --json alongside review-aspects?"
      category: "hard_rule"
      importance: "important"
      rationale: "Frontmatter must reflect available arguments for command discoverability"

    - id: "CK-012"
      question: "Does the skill avoid PR-specific references (pull request, PR number, GitHub API comment endpoints, gh api commands) and consistently use local-changes terminology?"
      category: "hard_rule"
      importance: "important"
      rationale: "This skill is for local uncommitted changes, not pull requests"

    - id: "CK-013"
      question: "Is the skill name in frontmatter preserved as 'code-review:review-local-changes'?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Changing the name would break existing references to this skill"

    - id: "CK-014"
      question: "Is there a Configuration Resolution section showing how $ARGUMENTS are parsed for review-aspects, --min-impact, and --json?"
      category: "hard_rule"
      importance: "important"
      rationale: "Agent needs explicit parsing instructions for all three argument types"

    - id: "CK-015"
      question: "Does the JSON template include fields for file location, line numbers, severity/impact level, description, evidence, confidence score, and impact score?"
      category: "hard_rule"
      importance: "important"
      rationale: "JSON output must contain all relevant issue information for programmatic use"

    - id: "CK-016"
      question: "Are all 6 review agents preserved (security-auditor, bug-hunter, code-quality-reviewer, contracts-reviewer, test-coverage-reviewer, historical-context-reviewer)?"
      category: "principle"
      importance: "important"
      rationale: "Review agents are core functionality that must not be lost during update"

    - id: "CK-017"
      question: "Is the false positives examples section preserved with content matching review-pr?"
      category: "principle"
      importance: "important"
      rationale: "False positive guidance is critical for scoring quality and reducing noise"

    - id: "CK-018"
      question: "Does the skill handle the no-issues-found case for both default (markdown) and JSON output formats?"
      category: "principle"
      importance: "important"
      rationale: "Edge case that must be handled for a complete, robust implementation"

    - id: "CK-019"
      question: "Does the skill contain Thought/Action/Observation code block patterns that agents might mimic as output instead of executing?"
      category: "principle"
      importance: "pitfall"
      rationale: "Per CLAUDE.md, such patterns cause agents to generate text instead of using tools"

    - id: "CK-020"
      question: "Does the updated skill incorrectly add PR-specific posting mechanisms (gh api for inline comments, GitHub review endpoints) that are irrelevant for local changes?"
      category: "principle"
      importance: "pitfall"
      rationale: "Local changes review outputs to console, not to GitHub - PR mechanisms would be wrong"

    - id: "CK-021"
      question: "Does the skill lose existing Phase 1 preparation steps (git status, git diff, checking for no changes, finding instruction files)?"
      category: "principle"
      importance: "pitfall"
      rationale: "Preparation phase is essential for establishing local changes context"

    - id: "CK-022"
      question: "Is the YAML frontmatter valid with all required fields (name, description, argument-hint) and properly formatted?"
      category: "hard_rule"
      importance: "essential"
      rationale: "Invalid frontmatter would prevent the skill from loading in Claude Code"

  rubric_dimensions:
    - name: "Feature Porting Completeness"
      description: "How completely and accurately are review-pr features ported to review-local-changes? Does the updated skill include impact scoring with the same 5-level scale (Critical/High/Medium/Medium-Low/Low with score ranges 0-100), the progressive confidence-impact threshold table (Critical:50, High:65, Medium:75, Medium-Low:85, Low:95 minimum confidence), the --min-impact argument with level mapping, and the upgraded confidence scoring scale matching review-pr? Are features adapted appropriately for local changes context rather than blindly copied from PR context?"
      scale: "1-5"
      weight: 0.25
      instruction: "Compare the updated skill against review-pr's Phase 3 (Confidence & Impact Scoring), Command Arguments section, and Impact Level Mapping. Check that each feature is present with correct values and adapted for local context. Verify the progressive threshold table values exactly match review-pr. Check that the old flat confidence cutoff of 80 has been replaced with the progressive system."
      score_definitions:
        1: "Missing most features - no impact scoring, no --min-impact argument, no progressive threshold table, or confidence scoring unchanged from original flat cutoff of 80"
        2: "Some features ported but incomplete - e.g., has impact scoring but wrong scale/ranges, or missing threshold table, or --min-impact defined without level mapping, or confidence scale not updated to match review-pr's 5-point descriptions"
        3: "All major features ported (impact scoring with 5 levels and correct ranges, confidence scoring with 5-point scale, progressive threshold table with correct values, --min-impact with level mapping) with values matching review-pr"
        4: "All features ported with exact values AND appropriately adapted for local-changes context (no PR-specific references, console output instead of GitHub comments, local diff commands) with clear filtering instructions including MIN_IMPACT_SCORE exclusion"
        5: "All features ported, adapted, and enhanced beyond requirements - e.g., additional filtering options, improved threshold documentation, or clearer scoring instructions"

    - name: "Template Effectiveness"
      description: "Is the default (markdown) output template significantly shorter than the original ~120-line multi-section report? Does it include only the list of issues that passed impact and confidence filtering, removing the verbose Quality Assessment, Required Actions, Security Vulnerabilities, Failed Checklist, and Code Improvements sections? Does it use the review-pr inline comment format with emoji severity indicator (red/orange/yellow/green circle), severity label, brief description, evidence, and optional code suggestion? Is the condensed format still actionable?"
      scale: "1-5"
      weight: 0.25
      instruction: "Compare against: (1) original template length - the new template should be dramatically shorter, (2) review-pr inline comment template format at lines 212-222 of review-pr SKILL.md - should match the emoji+severity+description+evidence+suggestion structure, (3) content should only contain filtered issues, not categorized sections. Count removed sections: Quality Assessment, Required Actions, Found Issues table, Security Vulnerabilities table, Failed Checklist table, Code Improvements list."
      score_definitions:
        1: "Template is unchanged from original, or does not use inline comment format at all, or still includes the verbose Quality Assessment / Required Actions / Security Vulnerabilities / Failed Checklist / Code Improvements sections"
        2: "Template is somewhat shorter but retains 2 or more of the original verbose sections (Quality Assessment, Required Actions, Security Vulnerabilities, Failed Checklist, Code Improvements), or uses inline comment format only partially (missing emoji severity indicators, or missing evidence field, or missing suggestion block)"
        3: "Template is significantly shorter with all verbose sections removed, uses the review-pr inline comment format (emoji circle + severity label + description + evidence + optional suggestion), and shows only the list of filtered issues"
        4: "All of score 3 plus: handles both issues-found and no-issues cases clearly, includes a brief summary header (e.g., quality gate status and issue count), format is clean and consistent with review-pr conventions"
        5: "Template is optimally concise with perfect review-pr format alignment, handles all edge cases including varying numbers of issues, and includes additional helpful formatting beyond what was requested"

    - name: "JSON Output Quality"
      description: "Is the --json argument properly defined as a boolean flag? Does the skill contain clear conditional logic instructing the agent to output JSON when --json is provided? Is there a concrete JSON template/example with realistic sample data? Does the JSON structure include all relevant fields for each issue (file, lines, severity/impact level, description, evidence, confidence score, impact score)? Is the JSON schema suitable for programmatic consumption (properly nested, consistent field names, array of issues)?"
      scale: "1-5"
      weight: 0.20
      instruction: "Check for: (1) --json in argument definitions table as boolean flag with proper format, (2) explicit conditional output instructions in Phase 3 or output section, (3) JSON template presence with at least one complete example issue, (4) JSON field completeness - must have at minimum: file, lines, severity, description, evidence, confidence, impact, (5) valid JSON structure that could be parsed programmatically."
      score_definitions:
        1: "No --json argument defined, or no JSON template provided, or JSON template is obviously invalid or a trivial placeholder (e.g., just '{issues: []}' with no field definitions)"
        2: "--json defined but JSON template is incomplete (missing key fields like confidence score, impact score, or evidence) or has structural issues (would not parse as valid JSON, inconsistent nesting)"
        3: "--json properly defined as boolean flag, conditional logic present in workflow, JSON template includes all key fields (file, lines, severity, description, evidence, confidence, impact) in valid, well-structured JSON format with a realistic example"
        4: "All of score 3 plus: JSON handles both issues-found and no-issues cases, includes metadata fields (e.g., total issue count, min-impact setting used, review timestamp), structure uses consistent naming conventions suitable for API consumption"
        5: "All of score 4 plus: realistic example data showing multiple issues, additional metadata fields, clear documentation of field types and meanings, and demonstrates both output cases"

    - name: "Workflow Coherence"
      description: "Do the workflow phases flow logically from preparation through scoring to output? Is Phase 1 preserved with argument parsing integrated? Is Phase 2 (Searching for Issues) preserved with all review agents and determination logic? Is Phase 3 restructured to include both impact and confidence scoring with clear, sequential filtering steps? Is the output phase clearly separated with conditional format selection (markdown vs JSON based on --json flag)? Are there no contradictions, redundancies, leftover old content, or confusing instructions?"
      scale: "1-5"
      weight: 0.15
      instruction: "Read through the entire workflow from Phase 1 to output. Verify: (1) Phase transitions are clear and logical, (2) argument parsing is in Phase 1 before it is needed, (3) Phase 2 review agents and determination logic are complete and unchanged, (4) Phase 3 has both scoring dimensions with progressive filtering replacing the old flat cutoff, (5) output format selection (markdown vs JSON) is explicit and conditional on --json flag, (6) no contradictions between old content and new content, (7) no leftover references to the old flat confidence cutoff of 80."
      score_definitions:
        1: "Workflow is disjointed - phases missing, contradictory instructions (e.g., old flat cutoff of 80 alongside new progressive table), or old template content mixed with new content incoherently"
        2: "Basic phase structure preserved but transitions are unclear, some old content not updated (e.g., leftover references to flat confidence cutoff, or old template sections partially remaining), or minor contradictions between phases"
        3: "All phases present and logically ordered, argument parsing in Phase 1, Phase 3 has both confidence and impact scoring with progressive filtering, output format selection present and conditional on --json"
        4: "Clean workflow with clear phase transitions, no contradictions, no leftover old content, all phases consistently adapted for new features, output format branching is explicit with clear instructions for each format"
        5: "Exceptionally well-organized workflow with improvements to clarity and flow beyond what was required"

    - name: "Argument Handling Consistency"
      description: "Is the Command Arguments section consistent with review-pr conventions? Does it include an argument definitions table with Argument, Format, Default, and Description columns matching review-pr's format? Is --min-impact defined with level format and 'high' default? Is --json defined as a boolean flag with 'false' default? Is the Impact Level Mapping table present with all 5 levels and correct minimum score values? Is the Configuration Resolution pseudocode complete, showing parsing of all three argument types (review-aspects as free text, --min-impact as level with score lookup, --json as boolean) and resolution of MIN_IMPACT_SCORE from level name?"
      scale: "1-5"
      weight: 0.15
      instruction: "Compare the Command Arguments section structure against review-pr's (lines 23-62 of review-pr SKILL.md). Check: (1) table format matches with same column headers, (2) all three arguments defined correctly, (3) Impact Level Mapping table has same 5 levels and score values as review-pr, (4) Configuration Resolution pseudocode covers all arguments including --json boolean parsing."
      score_definitions:
        1: "No Command Arguments section, or arguments mentioned only in passing without structured table definitions"
        2: "Command Arguments section exists but incomplete - missing Impact Level Mapping table, or Configuration Resolution absent, or --json not defined in table, or table format differs significantly from review-pr (wrong columns, missing defaults)"
        3: "Complete Command Arguments section: argument definitions table with Argument/Format/Default/Description columns, Impact Level Mapping table with all 5 levels and correct score ranges, Configuration Resolution pseudocode covering review-aspects, --min-impact with score lookup, and --json"
        4: "All of score 3 plus: format exactly matches review-pr conventions, both argument types (level-based --min-impact and boolean --json) clearly distinguished with appropriate Format entries, default values explicit"
        5: "All of score 4 plus: additional argument documentation, validation instructions, or edge case handling beyond what review-pr provides"

  scoring:
    default_score: 2
    threshold_pass: 3.0
    threshold_excellent: 4.0
    aggregation: "weighted_sum"
    total_weight: 1.00
    essential_checklist_failure_cap: 2.0
    pitfall_score_reduction: 0.5
```
