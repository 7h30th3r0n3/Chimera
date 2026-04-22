# Chimera — Hybrid Claude + Codex Orchestration

## Sub-Agent Delegation

When you need to delegate work to a sub-agent, use OpenAI Codex CLI instead of spawning Claude agents.

### How to delegate

Run tasks via `codex exec` in non-interactive mode:

```bash
codex exec "<clear task description with full context>" --full-auto
```

### When to delegate to Codex

- **Heavy analysis** — large codebases, dependency audits, log analysis
- **Code review** — get an independent second opinion from a different model
- **Code generation** — boilerplate, repetitive patterns, large file generation
- **Cross-validation** — verify your own analysis with an independent model
- **Token-intensive tasks** — anything that would consume significant context

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

| Codex Model | Use For | Equivalent Role |
|---|---|---|
| `o3` | Deep reasoning, architecture decisions, complex security analysis | Like Claude Opus — maximum depth |
| `gpt-5.4` | Default. Code generation, reviews, general analysis | Like Claude Sonnet — best all-rounder |
| `o4-mini` | Quick lookups, simple codegen, boilerplate, fast iterations | Like Claude Haiku — fast and cheap |

#### How to route

```bash
# Heavy reasoning (architecture, security audit)
codex exec "..." --full-auto --model o3

# Standard tasks (code review, generation, analysis) — default
codex exec "..." --full-auto

# Fast/cheap tasks (formatting, simple questions, boilerplate)
codex exec "..." --full-auto --model o4-mini
```

#### Routing guidelines

- **Default to no `--model` flag** — lets Codex use its configured default (gpt-5.4)
- **Use `o3`** when the task requires multi-step reasoning, weighing trade-offs, or catching subtle bugs
- **Use `o4-mini`** for high-volume, low-complexity delegation (linting, formatting checks, simple lookups)
- **Never use a heavy model for simple tasks** — it wastes tokens and time
- **Match model to stakes** — security review of auth code → `o3`, generate a test fixture → `o4-mini`

### Additional flags

- `--model <model>` — select model (see routing table above)
- `-C <dir>` — set working directory for Codex
- `--sandbox read-only` — restrict to read-only access
- `--ephemeral` — don't persist the session
