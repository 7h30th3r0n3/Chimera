# Chimera — Hybrid Claude + Codex Orchestration

## Sub-Agent Delegation

When you need to delegate work to a sub-agent, use OpenAI Codex CLI instead of spawning Claude agents.

### How to delegate

Run tasks via `codex exec` in non-interactive mode:

```bash
codex exec "<clear task description with full context>" --full-auto
```

### Gotchas (learned from real usage)

#### 1. Git repo requirement
Codex refuses to run outside a git repository. Always add `--skip-git-repo-check` when the target is not inside a git repo:
```bash
codex exec "..." --full-auto --skip-git-repo-check
```

#### 2. Model availability depends on your OpenAI plan
Some models (e.g. `o3`) require an OpenAI API plan and are NOT available with a ChatGPT subscription. If a model fails with `"model is not supported when using Codex with a ChatGPT account"`, fall back to the default model (no `--model` flag). Always try without `--model` first if unsure.

#### 3. Sandbox file access
Codex runs in a sandbox with limited filesystem access (workdir, `/tmp`, `$TMPDIR`). If the target file is outside these paths (e.g. `/mnt/c/Users/...` on WSL, or `/opt/...`), **copy it to `/tmp` first** before delegating:
```bash
cp /mnt/c/Users/user/file.ino /tmp/file.ino
codex exec "Analyze /tmp/file.ino ..." --full-auto --skip-git-repo-check
```

#### 4. stdin trap
Codex reads from stdin by default. When running via `codex exec` with a prompt argument, the process may hang with `"Reading additional input from stdin..."`. This is normal - it still runs. If it blocks, ensure the prompt is passed as the first positional argument, not piped.

### Auto-detection: when to delegate to Codex

Before starting a task, estimate its token cost. If ANY of the following signals are present, delegate to Codex automatically — do not attempt it yourself.

#### File-count signals (auto-delegate)

- Task targets **10+ files** → delegate
- Task requires **recursive scanning** of a directory tree → delegate
- Task involves reading files that are **500+ lines each** → delegate
- Task involves **3+ large files** (200+ lines) simultaneously → delegate

#### Task-type signals (auto-delegate)

- **Full codebase scan** — grep/analysis across entire project → delegate
- **Dependency audit** — scanning package.json, go.mod, requirements.txt + CVE lookup → delegate
- **Log analysis** — parsing log files (typically large) → delegate
- **Documentation generation** — reading all source files to produce docs → delegate
- **Migration assessment** — analyzing all files for a technology migration → delegate
- **Code generation spanning 3+ files** — multi-file boilerplate or scaffolding → delegate
- **Diff analysis on large PRs** — 500+ lines changed → delegate

#### Estimation heuristic

Before starting, run a quick check:
```bash
# Count files that would be involved
find <target_dir> -name "*.ext" | wc -l

# Check total line count
find <target_dir> -name "*.ext" -exec wc -l {} + | tail -1
```

- **< 500 total lines across all files** → handle directly
- **500–2000 lines** → handle directly, but consider delegating if complex analysis
- **2000+ lines** → delegate to Codex
- **5000+ lines** → delegate to Codex (default model, or `--model o3` if available on your plan)

#### Manual delegation (always delegate)

- **Code review** — get an independent second opinion from a different model
- **Cross-validation** — verify your own analysis with an independent model
- **Second opinion on critical decisions** — architecture, security, data migrations

### When NOT to delegate

- Simple questions or quick lookups — handle these directly
- Tasks requiring conversation history — Codex has no context of the current session
- Tasks requiring tool use beyond shell — Codex can only run shell commands in its sandbox
- Security-sensitive operations — keep secrets and credentials in Claude's context only

### Delegation format

Always provide Codex with:
1. **Full context** — Codex has no knowledge of the current conversation
2. **Clear objective** — what exactly it should do or answer
3. **Scope** — which files/directories to look at
4. **Output format** — how you want the result structured

Example:
```bash
codex exec "Review the Python files in src/auth/ for security vulnerabilities. Focus on: SQL injection, XSS, authentication bypass, and hardcoded secrets. List each finding with file, line, severity, and remediation." --full-auto
```

### Processing Codex output

After receiving Codex's response:
1. Parse and validate the output
2. Cross-reference with your own analysis when relevant
3. Synthesize a unified response for the user
4. Flag any disagreements between your analysis and Codex's

### Model Routing

Choose the right Codex model based on the task, just like Claude Code uses Opus, Sonnet, or Haiku:

| Codex Model | Use For | Equivalent Role | Requires API plan |
|---|---|---|---|
| `o3` | Deep reasoning, architecture decisions, complex security analysis | Like Claude Opus | Yes (API only) |
| `gpt-5.4` | Default. Code generation, reviews, general analysis | Like Claude Sonnet | No (ChatGPT OK) |
| `o4-mini` | Quick lookups, simple codegen, boilerplate, fast iterations | Like Claude Haiku | No (ChatGPT OK) |

#### How to route

```bash
# Heavy reasoning (architecture, security audit) - requires API plan
codex exec "..." --full-auto --model o3

# Standard tasks (code review, generation, analysis) - default, works on all plans
codex exec "..." --full-auto

# Fast/cheap tasks (formatting, simple questions, boilerplate)
codex exec "..." --full-auto --model o4-mini
```

#### Routing guidelines

- **Default to no `--model` flag** - lets Codex use its configured default (gpt-5.4)
- **Try `o3` only if the user has an API plan** - it will fail on ChatGPT-only accounts. If it fails, retry without `--model`
- **Use `o4-mini`** for high-volume, low-complexity delegation (linting, formatting checks, simple lookups)
- **Never use a heavy model for simple tasks** - it wastes tokens and time
- **Match model to stakes** - security review of auth code → `o3` (or default if unavailable), generate a test fixture → `o4-mini`

### Additional flags

- `--model <model>` - select model (see routing table above)
- `--skip-git-repo-check` - REQUIRED when running outside a git repository
- `--sandbox read-only` - restrict to read-only access
- `--ephemeral` - don't persist the session
- `-C <dir>` - set working directory (must be a git repo unless combined with `--skip-git-repo-check`)
