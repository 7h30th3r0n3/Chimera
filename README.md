# Chimera

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-compatible-green)](https://github.com/openai/codex)

```
   /\_/\      .-=-.       /\_/\
  ( o.o )----/  AI  \----( 0.0 )
   > ^ <    |Chimera |    > # <
             \Claude/
              `-=-'
             /Codex\
            /_/   \_\
```

> **Hybrid AI orchestration** - Claude Code as the brain, Codex CLI as the muscle.

Chimera turns Claude Code into a multi-model orchestrator by replacing its native sub-agents with OpenAI Codex CLI calls. Instead of spawning Claude agents for heavy tasks, Claude delegates to `codex exec`, combining the strengths of both systems.

## Why?

| | Claude Code | Codex CLI |
|---|---|---|
| **Strengths** | Orchestration, tool use, context management, reasoning | Sandboxed execution, large codegen, different model perspective |
| **Models** | Claude (Anthropic) | GPT (OpenAI) |
| **Mode** | Interactive + agents | `codex exec` non-interactive |

By combining them, you get:
- **Multi-model diversity** - two different AI architectures cross-checking each other
- **Cost optimization** - delegate token-heavy tasks to the most efficient model
- **Best of both worlds** - Claude's reasoning + Codex's sandboxed execution
- **Second opinion** - reduce blind spots by using independent model families

## Prerequisites

1. **Claude Code** installed and authenticated
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

2. **Codex CLI** installed and authenticated
   ```bash
   npm install -g @anthropic-ai/claude-code  # if not already
   npm install -g codex                       # OpenAI Codex CLI
   codex login
   ```

3. Both tools available in your `$PATH`

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

**Option 1 - Global** (all Claude Code sessions):
```bash
cp .claude/rules/chimera.md ~/.claude/rules/chimera.md
```

**Option 2 - Project** (current project only):
```bash
cp .claude/rules/chimera.md your-project/.claude/rules/chimera.md
```

**Option 3 - CLAUDE.md**: Append the content of `.claude/rules/chimera.md` to your project's `CLAUDE.md` file.

### Uninstall

```bash
cd Chimera
./scripts/uninstall.sh
```

Supports `--global`, `--project`, or `--all` flags. Interactive by default - detects where Chimera is installed and lets you choose what to remove.

## Auto-Detection

Chimera doesn't wait for you to ask - it estimates token cost before starting a task and automatically delegates to Codex when the workload is heavy.

### Signals that trigger auto-delegation

| Signal | Threshold | Action |
|---|---|---|
| File count | 10+ files targeted | Auto-delegate |
| Total lines | 2000+ lines to process | Auto-delegate |
| File size | 500+ lines per file | Auto-delegate |
| Recursive scan | Full directory tree | Auto-delegate |
| Large PR diff | 500+ lines changed | Auto-delegate |

### Estimation flow

Before starting work, Claude runs a quick size check:

```
Task received
    |
    v
Estimate scope (file count, line count)
    |
    |-- < 500 lines ---------> handle directly
    |-- 500-2000 lines ------> handle or delegate (based on complexity)
    |-- 2000-5000 lines -----> delegate to Codex (default model)
    |-- 5000+ lines ----------> delegate to Codex with --model o3
```

This means heavy tasks get offloaded automatically without you having to think about it.

## How it works

When Claude Code encounters a task that would normally be delegated to a sub-agent, it instead runs:

```bash
codex exec "<task description>" --full-auto
```

Codex executes the task in a sandboxed environment and returns the result. Claude then processes the output and continues its work.

### Flow

```
User Request
    |
    v
Claude Code (orchestrator)
    |
    |-- Simple tasks --> handles directly
    |
    |-- Heavy tasks --> codex exec "..." --full-auto
    |                       |
    |                       v
    |                   Codex (worker)
    |                       |
    |                   returns result
    |                       |
    |<----------------------'
    |
    v
Claude Code (synthesizes & responds)
```

## Examples

### Code Review (multi-model perspective)

Claude asks Codex to independently review the same code:
```
User: "Review this PR for security issues"
Claude: runs `codex exec "Review the code in src/ for security vulnerabilities. Focus on OWASP Top 10." --full-auto`
Claude: compares Codex's findings with its own analysis
Claude: presents a unified report
```

### Heavy Analysis

Delegate token-intensive work:
```
User: "Analyze all dependencies for known CVEs"
Claude: runs `codex exec "Scan package.json and go.mod for dependencies with known CVEs. List each with severity." --full-auto`
Claude: formats and prioritizes the results
```

### Cross-Model Validation

Use both models to validate critical decisions:
```
User: "Is this database migration safe?"
Claude: analyzes the migration itself
Claude: runs `codex exec "Review this SQL migration for data loss risks, locking issues, and rollback safety" --full-auto`
Claude: synthesizes both perspectives
```

See the [examples/](examples/) directory for more use cases.

## Model Routing

Like Claude Code lets you pick between Opus, Sonnet, and Haiku, Chimera routes tasks to the right Codex model:

| Task Type | Codex Model | Flag | Claude Equivalent |
|---|---|---|---|
| Deep reasoning, security audits, architecture | `o3` | `--model o3` | Opus |
| Code review, generation, general analysis | `gpt-5.4` | *(default)* | Sonnet |
| Quick lookups, boilerplate, formatting | `o4-mini` | `--model o4-mini` | Haiku |

```bash
# Deep analysis - use o3
codex exec "Audit this auth flow for subtle logic bugs" --full-auto --model o3

# Standard work - default model
codex exec "Review this PR for code quality" --full-auto

# Quick/cheap - use o4-mini
codex exec "Generate test fixtures for User model" --full-auto --model o4-mini
```

Match model to stakes: critical security review gets `o3`, boilerplate generation gets `o4-mini`.

## Configuration

The core Chimera rule is in [`.claude/rules/chimera.md`](.claude/rules/chimera.md). You can customize:

- **When to delegate** - adjust the criteria for what counts as a "heavy task"
- **Codex flags** - add `--model`, `--sandbox`, or other Codex CLI options
- **Scope** - limit delegation to specific task types (review, analysis, codegen)

## Limitations

- Codex CLI requires its own API key and authentication
- `codex exec` runs in a sandbox - it can read your workspace but writes are limited
- Network calls from Codex are sandboxed
- Token usage is billed separately by both Anthropic and OpenAI
- The two models don't share conversation context - each call is independent

## Extending Chimera

Chimera is designed to be extended. Some ideas:

- **Add more AI CLIs** - Gemini CLI, GitHub Copilot CLI, or local models via Ollama
- **Custom routing logic** - route by file type, language, or domain
- **Chain delegation** - Claude delegates to Codex, which delegates to a local model
- **Evaluation pipelines** - run both models on the same task and diff the results

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute.

## License

MIT - see [LICENSE](LICENSE)

---

*Built with the Chimera technique itself - Claude Code orchestrated, Codex contributed.*
