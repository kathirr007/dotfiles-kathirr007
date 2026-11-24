# Universal AI Project Setup Prompt

**Ready-to-copy prompt** for configuring 9 AI coding tools in any project.

---

## Tools Covered

| # | Tool | Website |
|---|------|---------|
| 1 | **Opencode** | opencode.ai |
| 2 | **Kiro-CLI** | kiro.dev |
| 3 | **Antigravity CLI** | antigravity.dev |
| 4 | **Claude CLI** | claude.ai/code |
| 5 | **Devin CLI** | devin.ai |
| 6 | **Aider** | aider.chat |
| 7 | **Continue** | continue.dev |
| 8 | **Goose** | block.github.io/goose |
| 9 | **OpenHands** | github.com/All-Hands-AI/OpenHands |

---

## Usage

```bash
# 1. In your project root, run with ANY tool:
opencode run "$(cat /path/to/universal-project-setup-prompt.md)"
# or
kiro run "$(cat /path/to/universal-project-setup-prompt.md)"
# or
claude -p "$(cat /path/to/universal-project-setup-prompt.md)"
# etc.

# 2. Answer questions interactively (Step 1 → Step 2)

# 3. Review generated .ai-project-config.yaml + 9 tool configs

# 4. Say "apply" to write files

# 5. Commit .ai-project-config.yaml to repo

# 6. Team members run:
./sync-ai-config.sh --global --project --verify
```

---

## The Complete Prompt

Copy everything inside the code block below:

````markdown
You are an AI tooling configurator. I use **9 AI coding tools**:

1. **Opencode** (opencode.ai)
2. **Kiro-CLI** (kiro.dev)
3. **Antigravity CLI** (antigravity.dev)
4. **Claude CLI** (claude.ai/code)
5. **Devin CLI** (devin.ai)
6. **Aider** (aider.chat)
7. **Continue** (continue.dev)
8. **Goose** (block.github.io/goose)
9. **OpenHands** (github.com/All-Hands-AI/OpenHands)

I need a **single unified setup** for this project that works across all tools.

**PROJECT ROOT:** <current working directory>

---

### STEP 1: DETECT PROJECT STAGE

Analyze the project root and determine:
- **NEW/INITIAL** — No significant code, no package.json/pyproject.toml/Cargo.toml, or < 5 source files
- **EXISTING/MID-STAGE** — Has source code, config files, git history, dependencies, structure

**Output:** `PROJECT_STAGE: "new" | "existing"` + brief evidence (file count, key files found, git commits)

---

### STEP 2: GATHER CONTEXT (ask me questions, ONE section at a time)

#### IF NEW PROJECT:
Ask these **sequentially** (wait for my answer before next):

1. **PROJECT TYPE** — What are you building? (web app, CLI, library, API, mobile, ML, infra, other)
2. **TECH STACK** — Language(s), framework(s), runtime, build tool, package manager, database, ORM, testing, linting, CI/CD
3. **TARGET USERS** — Internal team, external developers, end consumers, enterprise, open source
4. **USAGE PATTERN** — Real-time/interactive, batch/background, high-throughput, low-latency, data-intensive, AI/ML-heavy
5. **ARCHITECTURE STYLE** — Monolith, microservices, serverless, modular monolith, plugin-based, other
6. **TEAM SIZE & WORKFLOW** — Solo, small team (2-5), large team; trunk-based, feature branches, PR-heavy, pair programming
7. **CONSTRAINTS** — Performance budgets, compliance, offline/local-first, existing infra, budget limits
8. **AI TOOLING PRIORITIES** — What matters most: code generation, refactoring, test writing, docs, architecture review, debugging, learning?

#### IF EXISTING PROJECT:
**First, analyze silently** (no questions yet):
- Scan all config files (package.json, pyproject.toml, Cargo.toml, go.mod, pom.xml, etc.)
- Map directory structure → infer modules, layers, boundaries
- Detect: languages, frameworks, test setup, lint/format, CI, DB, ORM, API style, auth, deploy targets
- Read README, CLAUDE.md, AGENTS.md, .github/, docs/ for conventions
- Check git log for recent activity, contributors, branching pattern

**Then ask targeted questions:**

1. **PAIN POINTS** — Where do you want AI help most? (legacy code, test coverage, refactoring, onboarding, docs, bugs, performance)
2. **CURRENT AI USAGE** — Already using any tools? What works/doesn't?
3. **TEAM CONVENTIONS** — Any unwritten rules? (naming, error handling, state management, component patterns)
4. **OFF-LIMITS AREAS** — Code AI should not touch? (secrets, generated, vendor, critical paths)
5. **DESIRED WORKFLOWS** — Which of these to enable: PR review agent, test generator, refactoring assistant, docs writer, architecture guard, onboarding guide, migration helper?

---

### STEP 3: GENERATE UNIFIED CONFIG SPEC

Output a **single YAML spec** (save as `.ai-project-config.yaml` in project root) with:

```yaml
project:
  name: <slug>
  stage: new | existing
  type: <web|cli|lib|api|mobile|ml|infra|other>
  tech_stack:
    languages: [...]
    frameworks: [...]
    runtime: <node|python|go|rust|jvm|...>
    package_manager: <npm|pnpm|yarn|pip|poetry|cargo|maven|...>
    build_tool: <vite|webpack|esbuild|turbo|...>
    database: <postgres|sqlite|mongodb|...>
    orm: <prisma|drizzle|sqlalchemy|gorm|...>
    testing: <vitest|jest|pytest|...>
    lint_format: <eslint|prettier|ruff|biome|...>
    ci_cd: <github-actions|gitlab|circleci|...>
    deploy: <vercel|aws|gcp|fly|docker|...>
  architecture:
    style: <monolith|microservices|serverless|modular-monolith|plugin>
    modules: [<inferred or stated module names>]
    boundaries: [<enforced layer boundaries>]
  team:
    size: <solo|small|large>
    workflow: <trunk|feature-branch|pr-heavy|pair>
  targets:
    users: <internal|external-dev|consumer|enterprise|oss>
    usage: <realtime|batch|high-throughput|low-latency|data-intensive|ai-heavy>
  constraints: [...]

ai_tooling:
  priorities: [...]
  pain_points: [...]
  off_limits: [...]
  desired_workflows:
    - pr-review
    - test-generation
    - refactoring
    - docs-writing
    - architecture-guard
    - onboarding
    - migration

models:
  # Reference your unified registry (from earlier)
  profiles:
    coding-fast: <model-alias>
    reasoning-deep: <model-alias>
    architecture: <model-alias>
    review-thorough: <model-alias>
    local-only: <model-alias>

skills:
  - name: <skill-id>
    description: <what it does>
    trigger: <auto|manual|pattern>
    applies_to: [<file-patterns>]
    config: {...}

agents:
  - name: <agent-id>
    role: <reviewer|test-writer|refactorer|documenter|architect|onboarder>
    model_profile: <coding-fast|reasoning-deep|...>
    instructions: <detailed prompt>
    tools: [<allowed-tools>]
    scope: <project|directory|file-pattern>

tool_configs:
  opencode:       { ... }
  kiro:           { ... }
  antigravity:    { ... }
  claude:         { ... }
  devin:          { ... }
  aider:          { ... }
  continue:       { ... }
  goose:          { ... }
  openhands:      { ... }
```

---

### STEP 4: TOOL-SPECIFIC IMPLEMENTATION GUIDE

For **each of the 9 tools**, provide:

1. **Config file(s) to create/update** (paths relative to project root or ~/.config)
2. **Exact content** (JSON/YAML/TOML) mapping the unified spec → tool's schema
3. **Commands to run** to install/enable skills, agents, hooks
4. **Any tool-specific quirks** (see reference below)
5. **How to verify** it's working

---

### TOOL-SPECIFIC REFERENCE (use when generating Step 4)

#### **Opencode** 
- Config: `~/.config/opencode/config.json` (global) + `.opencode/` (project)
- Skills: `.opencode/skill/<name>/skill.yaml` + `.opencode/skill/<name>/prompt.md`
- Agents: `.opencode/agent/<name>/agent.yaml`
- Model aliases in config: `model_profiles`
- Env vars: `${ENV_VAR}` substitution

#### **Kiro-CLI**
- Config: `~/.kiro/config.yaml` (global) + `.kiro/` (project)
- Agents: `.kiro/agents/<name>.yaml`
- Skills: `.kiro/skills/<name>/skill.yaml`
- Model presets in config

#### **Antigravity CLI**
- Config: `~/.antigravity/config.toml` (global) + `.antigravity/` (project)
- Agents: `.antigravity/agents/<name>.toml`
- Skills: `.antigravity/skills/<name>/`
- Keychain integration for secrets

#### **Claude CLI**
- Config: `~/.claude/config.json` (global) + `CLAUDE.md` (project memory)
- Agents: `.claude/agents/<name>.md` (markdown with frontmatter)
- `apiKeyHelper` command for dynamic keys
- Hooks: `.claude/hooks/`

#### **Devin CLI**
- Config: `~/.devin/config.yaml` (global) + `.devin/` (project)
- Agents: `.devin/agents/<name>.yaml`
- Skills: `.devin/skills/<name>/`
- Team config sync via `devin config pull/push`

#### **Aider** (NEW)
- Config: `.aider.conf.yml` (project, committed) + `~/.aider.conf.yml` (global)
- No agents/skills system — uses **conventions** via prompt files
- Convention files: `.aider/` dir with `conventions.md`, `prompt.md`
- Model switching: `/model` command or `--model` flag
- Weak model for commits: `--weak-model`
- Keys via env: `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `OPENROUTER_API_KEY`, etc.

#### **Continue** (NEW)
- Config: `~/.continue/config.json` (global) + `.continue/config.json` (project)
- Custom commands: `.continue/commands/*.json`
- Context providers: codebase, terminal, diff, docs, grep, etc.
- Tab autocomplete model separate from chat model
- Keys via env var substitution: `${ENV_VAR}`
- Works headless via `continue` CLI

#### **Goose** (NEW)
- Config: `~/.config/goose/config.yaml` (global) + `.goose/` (project)
- Extensions: filesystem, git, shell, browser, custom MCP servers
- Profiles in config for model routing
- Agents via extensions (custom agents as extensions)
- Keys via env var substitution
- `goose configure` for interactive setup

#### **OpenHands** (NEW)
- Config: `.openhands/config.yaml` (project) + `~/.openhands/config.yaml` (global)
- Agents: `CodeActAgent` (default), `BrowsingAgent`, custom via `agenthub/`
- Runtime: Docker-based (`.openhands/Dockerfile`)
- Memory: conversation persistence in `.openhands/memory/`
- Security: confirmation mode, allowed commands list
- Keys via env: `LLM_API_KEY`, `LLM_BASE_URL`, `LLM_MODEL`

---

### STEP 5: GENERATE SYNC SCRIPT

Output a **`sync-ai-config.sh`** script that:
1. Symlinks unified registry `ai-models/registry.yaml` → `~/.config/ai-models/`
2. Renders each tool's global config from templates + env vars
3. Symlinks project-local configs (`.aider.conf.yml`, `.continue/config.json`, `.openhands/config.yaml`, `CLAUDE.md`, `.devin/`, etc.) into project root
4. Runs any tool-specific install commands (e.g., `opencode skill install`, `goose extension add`)
5. Verifies each tool can start and see its config

---

### EXECUTION MODE

- Run **Step 1** immediately (analyze project root)
- Run **Step 2** interactively (ask me questions, one section at a time)
- After I answer all, run **Step 3** (output `.ai-project-config.yaml`)
- Then run **Step 4** (output 9 tool-specific configs + commands)
- Then run **Step 5** (output `sync-ai-config.sh`)
- **Do not write files unless I say "apply"**
````

---

## Quick Reference

### Environment Setup
```bash
# ~/.local/share/ai-keys.sh (source in shell rc)
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
export OPENROUTER_API_KEY="sk-or-..."
# Local models need no keys
```

### Sync Script Usage
```bash
./sync-ai-config.sh [--global] [--project] [--verify]
# --global   : Sync global configs to ~/.config/
# --project  : Symlink project configs into current dir
# --verify   : Check each tool starts correctly
```

### Template Directory Structure
```
ai-tooling/universal-project-setup/
├── universal-project-setup-prompt.md
├── registry.yaml
├── sync-ai-config.sh
└── tools/
    ├── opencode/config.template
    ├── kiro/config.template
    ├── antigravity/config.template
    ├── claude/config.template
    ├── devin/config.template
    ├── aider/config.template
    ├── continue/config.template
    ├── goose/config.template
    └── openhands/config.template
```