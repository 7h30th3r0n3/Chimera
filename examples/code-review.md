# Example: Cross-Model Code Review

## Scenario

You want a security review of your authentication module. Instead of relying on a single model's perspective, Chimera gets both Claude and Codex to review independently.

## What happens

1. You ask Claude Code: *"Review src/auth/ for security issues"*

2. Claude analyzes the code itself (using its own reasoning)

3. Claude delegates to Codex for an independent review:
   ```bash
   codex exec "Review all files in src/auth/ for security vulnerabilities. Check for: authentication bypass, session management issues, injection flaws, hardcoded credentials, insecure crypto, and OWASP Top 10 issues. For each finding, provide: file path, line number, severity (CRITICAL/HIGH/MEDIUM/LOW), description, and fix." --full-auto --sandbox read-only
   ```

4. Claude compares both sets of findings:
   - Findings both models agree on → high confidence
   - Findings only one model caught → worth investigating
   - Contradictions → require manual review

5. Claude presents a unified report with confidence levels

## Why this is powerful

- Different model architectures have different blind spots
- A vulnerability missed by Claude might be caught by GPT (and vice versa)
- Agreement between independent models increases confidence
- Disagreement flags areas that need human attention
