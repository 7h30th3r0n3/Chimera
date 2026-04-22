# Chimera

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-compatible-green)](https://github.com/openai/codex)

<div align="center">

```
   /\_/\      .-=-.       /\_/\
  ( o.o )----/  AI  \----( 0.0 )
   > ^ <    |Chimera |    > # <
  Codex     \       /     Claude  
              `-=-'
             /     \
            /_/   \_\
```

**Hybrid AI orchestration**

*Claude Code as the brain, Codex CLI as the muscle.*

</div>

---

## What is Chimera?

Chimera turns Claude Code into a **multi-model orchestrator** by replacing its native sub-agents with OpenAI Codex CLI calls.

Instead of spawning Claude agents for heavy tasks, Claude delegates to `codex exec`, combining the strengths of both AI systems.

### Why use two AIs?

- **Multi-model diversity** - two different architectures cross-checking each other
- **Cost optimization** - delegate token-heavy tasks to the most efficient model
- **Best of both worlds** - Claude's reasoning + Codex's sandboxed execution
- **Second opinion** - reduce blind spots by using independent model families

### Claude Code vs Codex CLI

**Claude Code** excels at:
> Orchestration, tool use, context management, deep reasoning

**Codex CLI** excels at:
> Sandboxed execution, large codegen, different model perspective

**Chimera** combines both.

---

## Prerequisites

**1. Claude Code** installed and authenticated:
```bash
npm install -g @anthropic-ai/claude-code
```

**2. Codex CLI** installed and authenticated:
```bash
npm install -g codex
codex login
```

**3.** Both tools available in your `$PATH`

---

## Installation

### Quick install (recommended)

```bash
git clone https://github.com/7h30th3r0n3/Chimera.git
cd Chimera
chmod +x scripts/install.sh
./scripts/install.sh
```

The installer checks prerequisites and lets you choose global or project-level installation.

### Manual install

**Global** (all Claude Code sessions):
```bash
cp .claude/rules/chimera.md \
   ~/.claude/rules/chimera.md
```

**Project only** (current project):
```bash
cp .claude/rules/chimera.md \
   your-project/.claude/rules/chimera.md
```

**CLAUDE.md**: Append the content of the rule file to your project's `CLAUDE.md`.

### Copy-paste install

If you don't want to clone the repo, copy the full rule from the [Chimera Rule section](#chimera-rule---full-content) below directly into your `~/.claude/rules/chimera.md` or `CLAUDE.md`.

### Uninstall

```bash
cd Chimera
./scripts/uninstall.sh
```

Supports `--global`, `--project`, or `--all` flags.

---

## How it works

```
User Request
     |
     v
Claude Code (orchestrator)
     |
     |-- Small task -----> handles directly
     |
     |-- Heavy task -----> codex exec "..." --full-auto
     |                          |
     |                          v
     |                      Codex (worker)
     |                          |
     |                      returns result
     |                          |
     |<-------------------------'
     |
     v
Claude Code (synthesizes & responds)
```

---

## Auto-Detection

Chimera estimates token cost **before** starting a task and automatically delegates to Codex when the workload is heavy.

### Thresholds

**Auto-delegate when:**

- 10+ files targeted
- 2000+ total lines to process
- 500+ lines per file
- Full directory tree scan
- 500+ lines changed in a PR diff

### Decision flow

```
< 500 lines    --> handle directly
500-2000 lines --> depends on complexity
2000-5000      --> delegate to Codex
5000+          --> delegate to Codex
               (o3 if API plan available)
```

---

## Model Routing

Like Claude Code picks between Opus, Sonnet, and Haiku, Chimera routes to the right Codex model.

### `o3` - Deep reasoning
> Architecture, security audits, complex analysis
>
> Equivalent: Claude Opus
>
> **Requires OpenAI API plan** (not ChatGPT)

```bash
codex exec "..." --full-auto --model o3
```

### `gpt-5.4` - Default (all-rounder)
> Code review, generation, general analysis
>
> Equivalent: Claude Sonnet
>
> Works on all plans

```bash
codex exec "..." --full-auto
```

### `o4-mini` - Fast and cheap
> Quick lookups, boilerplate, formatting
>
> Equivalent: Claude Haiku
>
> Works on all plans

```bash
codex exec "..." --full-auto --model o4-mini
```

---

## Examples

### Code review (multi-model)

```
User: "Review this PR for security issues"

Claude: analyzes the code itself
Claude: runs codex exec "Review src/ for
        security vulnerabilities. Focus on
        OWASP Top 10." --full-auto
Claude: compares both findings
Claude: presents unified report
```

### Heavy analysis

```
User: "Analyze all dependencies for CVEs"

Claude: runs codex exec "Scan package.json
        for dependencies with known CVEs.
        List each with severity." --full-auto
Claude: formats and prioritizes results
```

### Cross-model validation

```
User: "Is this migration safe?"

Claude: analyzes the migration itself
Claude: runs codex exec "Review this SQL
        migration for data loss risks and
        locking issues" --full-auto
Claude: synthesizes both perspectives
```

See the [examples/](examples/) directory for more.

---

## Troubleshooting

These are **real issues** encountered during Chimera development:

### "Not inside a trusted directory"

**Cause:** Codex requires a git repo by default

**Fix:** Add `--skip-git-repo-check`

---

### "model is not supported with ChatGPT account"

**Cause:** `o3` needs an OpenAI API plan

**Fix:** Remove `--model` flag, use default

---

### "Reading additional input from stdin..."

**Cause:** Codex waits for stdin

**Fix:** Normal behavior, it still runs. Pass prompt as positional argument.

---

### File not found in sandbox

**Cause:** File is outside sandbox paths

**Fix:** Copy to `/tmp` first:
```bash
cp /mnt/c/Users/.../file /tmp/file
codex exec "Analyze /tmp/file" \
  --full-auto --skip-git-repo-check
```

---

### Hangs on WSL paths

**Cause:** Sandbox can't access `/mnt/c/`

**Fix:** Same as above, copy to `/tmp`

---

## Limitations

- Codex CLI requires its own authentication
- `codex exec` runs in a sandbox with limited write access
- Network calls from Codex are sandboxed
- Token usage billed separately (Anthropic + OpenAI)
- Models don't share conversation context
- `o3` requires OpenAI API plan (not ChatGPT)
- Must run inside a git repo or use `--skip-git-repo-check`

---

## Extending Chimera

Some ideas:

- **More AI CLIs** - Gemini CLI, Copilot CLI, Ollama
- **Custom routing** - route by file type, language, or domain
- **Chain delegation** - Claude > Codex > local model
- **Eval pipelines** - run both models, diff results

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute.

---

## Chimera Rule - Full Content

Below is the complete rule file. Copy-paste it into `~/.claude/rules/chimera.md` or your project's `CLAUDE.md` to enable Chimera without cloning this repo.

<details>
<summary><b>Click to expand the full Chimera rule</b></summary>

```markdown
# Chimera - Hybrid Claude + Codex Orchestration

## Sub-Agent Delegation

When you need to delegate work to a sub-agent, use OpenAI Codex CLI instead of spawning Claude agents.

### How to delegate

Run tasks via codex exec in non-interactive mode:

codex exec "<clear task description with full context>" --full-auto

### Gotchas (learned from real usage)

#### 1. Git repo requirement
Codex refuses to run outside a git repository. Always add --skip-git-repo-check when the target is not inside a git repo:

codex exec "..." --full-auto --skip-git-repo-check

#### 2. Model availability depends on your OpenAI plan
Some models (e.g. o3) require an OpenAI API plan and are NOT available with a ChatGPT subscription. If a model fails with "model is not supported when using Codex with a ChatGPT account", fall back to the default model (no --model flag). Always try without --model first if unsure.

#### 3. Sandbox file access
Codex runs in a sandbox with limited filesystem access (workdir, /tmp, $TMPDIR). If the target file is outside these paths (e.g. /mnt/c/Users/... on WSL, or /opt/...), copy it to /tmp first before delegating:

cp /mnt/c/Users/user/file.ino /tmp/file.ino
codex exec "Analyze /tmp/file.ino ..." --full-auto --skip-git-repo-check

#### 4. stdin trap
Codex reads from stdin by default. When running via codex exec with a prompt argument, the process may hang with "Reading additional input from stdin...". This is normal - it still runs. If it blocks, ensure the prompt is passed as the first positional argument, not piped.

### Auto-detection: when to delegate to Codex

Before starting a task, estimate its token cost. If ANY of the following signals are present, delegate to Codex automatically - do not attempt it yourself.

#### File-count signals (auto-delegate)

- Task targets 10+ files -> delegate
- Task requires recursive scanning of a directory tree -> delegate
- Task involves reading files that are 500+ lines each -> delegate
- Task involves 3+ large files (200+ lines) simultaneously -> delegate

#### Task-type signals (auto-delegate)

- Full codebase scan - grep/analysis across entire project -> delegate
- Dependency audit - scanning package.json, go.mod, requirements.txt + CVE lookup -> delegate
- Log analysis - parsing log files (typically large) -> delegate
- Documentation generation - reading all source files to produce docs -> delegate
- Migration assessment - analyzing all files for a technology migration -> delegate
- Code generation spanning 3+ files - multi-file boilerplate or scaffolding -> delegate
- Diff analysis on large PRs - 500+ lines changed -> delegate

#### Estimation heuristic

Before starting, run a quick check:

find <target_dir> -name "*.ext" | wc -l
find <target_dir> -name "*.ext" -exec wc -l {} + | tail -1

- < 500 total lines across all files -> handle directly
- 500-2000 lines -> handle directly, but consider delegating if complex analysis
- 2000+ lines -> delegate to Codex
- 5000+ lines -> delegate to Codex (default model, or --model o3 if available on your plan)

#### Manual delegation (always delegate)

- Code review - get an independent second opinion from a different model
- Cross-validation - verify your own analysis with an independent model
- Second opinion on critical decisions - architecture, security, data migrations

### When NOT to delegate

- Simple questions or quick lookups - handle these directly
- Tasks requiring conversation history - Codex has no context of the current session
- Tasks requiring tool use beyond shell - Codex can only run shell commands in its sandbox
- Security-sensitive operations - keep secrets and credentials in Claude's context only

### Delegation format

Always provide Codex with:
1. Full context - Codex has no knowledge of the current conversation
2. Clear objective - what exactly it should do or answer
3. Scope - which files/directories to look at
4. Output format - how you want the result structured

### Processing Codex output

After receiving Codex's response:
1. Parse and validate the output
2. Cross-reference with your own analysis when relevant
3. Synthesize a unified response for the user
4. Flag any disagreements between your analysis and Codex's

### Model Routing

Choose the right Codex model based on the task:

- o3: Deep reasoning, architecture, complex security (API plan required)
- gpt-5.4: Default. Code generation, reviews, general analysis (all plans)
- o4-mini: Quick lookups, simple codegen, boilerplate (all plans)

Routing:
- Default to no --model flag (uses gpt-5.4)
- Try o3 only if user has API plan. If it fails, retry without --model
- Use o4-mini for high-volume, low-complexity delegation
- Match model to stakes

### Additional flags

- --model <model> : select model
- --skip-git-repo-check : REQUIRED outside a git repo
- --sandbox read-only : restrict to read-only access
- --ephemeral : don't persist the session
- -C <dir> : set working directory
```

</details>

---

## License

MIT - see [LICENSE](LICENSE)

---

*Built with the Chimera technique itself - Claude Code orchestrated, Codex contributed.*
