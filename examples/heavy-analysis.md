# Example: Heavy Token Analysis

## Scenario

You need to analyze a large codebase, scan dependencies, or process large amounts of data — tasks that consume significant tokens.

## What happens

1. You ask Claude Code: *"Audit all npm dependencies for known vulnerabilities"*

2. Claude delegates the heavy lifting to Codex:
   ```bash
   codex exec "Analyze package.json and package-lock.json. For every dependency, check if there are known CVEs or security advisories. Output a markdown table with: package name, version, CVE ID, severity, description, and recommended fix version." --full-auto
   ```

3. Claude receives the raw analysis and:
   - Prioritizes findings by severity
   - Filters out false positives
   - Adds remediation steps
   - Presents a clean report

## Other heavy analysis use cases

### Log analysis
```bash
codex exec "Parse the log files in logs/ and identify: error patterns, anomalous request rates, failed auth attempts, and potential security incidents. Summarize findings." --full-auto
```

### Codebase migration assessment
```bash
codex exec "Analyze all .js files in src/ and assess the effort to migrate to TypeScript. List files by complexity, identify type-unsafe patterns, and estimate the migration order." --full-auto
```

### Documentation generation
```bash
codex exec "Read all Go files in pkg/ and generate API documentation in markdown format. Include function signatures, parameter descriptions, return values, and usage examples." --full-auto
```
