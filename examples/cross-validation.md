# Example: Cross-Model Validation

## Scenario

You're making a critical architectural decision or writing a database migration, and you want a second opinion from a completely independent AI system.

## What happens

1. You ask Claude Code: *"Is this database migration safe to run in production?"*

2. Claude analyzes the migration with its own reasoning

3. Claude asks Codex for an independent assessment:
   ```bash
   codex exec "Review the SQL migration in migrations/0042_add_user_email_index.sql. This will run on a PostgreSQL 15 database with ~50M rows in the users table, under live production traffic. Assess: will it lock the table? How long will it take? Is there data loss risk? Can it be rolled back? What's the safest way to apply it?" --full-auto --sandbox read-only
   ```

4. Claude compares both assessments:
   - If both agree it's safe → proceed with confidence
   - If both identify risks → definitely address them
   - If they disagree → flag for human decision with both perspectives

## Other validation use cases

### Architecture decisions
```bash
codex exec "We're choosing between Redis and PostgreSQL for a job queue handling 10k jobs/minute. Evaluate both options for: throughput, reliability, operational complexity, failure modes, and monitoring. Recommend one with justification." --full-auto
```

### Refactoring safety
```bash
codex exec "Review the refactoring diff in the current git staging area. Verify that the refactoring is behavior-preserving. Identify any cases where the new code could produce different results than the old code." --full-auto
```
