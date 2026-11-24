# Universal AI Project Setup

**One prompt → Complete 9-tool AI configuration for any project.**

This directory contains everything needed to bootstrap consistent AI tooling across 9 popular coding assistants.

---

## Tools Covered

| # | Tool | Type | Config Style |
|---|------|------|--------------|
| 1 | **Opencode** | CLI | JSON + Skills/Agents |
| 2 | **Kiro-CLI** | CLI | YAML + Agents/Skills |
| 3 | **Antigravity CLI** | CLI | TOML + Agents/Skills |
| 4 | **Claude CLI** | CLI | JSON + Markdown Agents |
| 5 | **Devin CLI** | CLI | YAML + Agents/Skills |
| 6 | **Aider** | CLI | YAML + Conventions |
| 7 | **Continue** | IDE/CLI | JSON + Commands |
| 8 | **Goose** | CLI | YAML + Extensions |
| 9 | **OpenHands** | Docker Agent | YAML + Agents |

---

## Quick Start

### 1. One-Time Setup (Global)

```bash
# Clone dotfiles (if not already)
git clone https://github.com/kathirr007/dotfiles-kathirr007.git
cd dotfiles-kathirr007

# Add your API keys
cat > ~/.local/share/ai-keys.sh <<'EOF'
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
export OPENROUTER_API_KEY="sk-or-..."
export GOOGLE_API_KEY="..."
EOF
chmod 600 ~/.local/share/ai-keys.sh

# Source in your shell rc (.bashrc, .zshrc, .config/fish/config.fish)
echo 'source ~/.local/share/ai-keys.sh' >> ~/.bashrc
source ~/.bashrc

# Test global sync (dry run)
./ai-tooling/universal-project-setup/sync-ai-config.sh --global --dry-run

# Apply global configs
./ai-tooling/universal-project-setup/sync-ai-config.sh --global --verify
```

### 2. Per-Project Setup

```bash
cd /path/to/your/project

# Run the universal prompt with ANY tool
opencode run "$(cat ~/dotfiles-kathirr007/ai-tooling/universal-project-setup/universal-project-setup-prompt.md)"
# OR
kiro run "$(cat ~/dotfiles-kathirr007/ai-tooling/universal-project-setup/universal-project-setup-prompt.md)"
# OR
claude -p "$(cat ~/dotfiles-kathirr007/ai-tooling/universal-project-setup/universal-project-setup-prompt.md)"
# etc.

# The prompt will:
# 1. Detect project stage (new vs existing)
# 2. Ask relevant questions
# 3. Generate .ai-project-config.yaml
# 4. Generate 9 tool-specific configs
# 5. Generate sync script

# Review output, then say: "apply"

# Sync project-local configs
~/dotfiles-kathirr007/ai-tooling/universal-project-setup/sync-ai-config.sh --project
```

### 3. Team Onboarding

New team member runs:

```bash
git clone https://github.com/kathirr007/dotfiles-kathirr007.git
cd dotfiles-kathirr007
./ai-tooling/universal-project-setup/sync-ai-config.sh --global --verify
```

Then in each project:

```bash
cd /path/to/project
~/dotfiles-kathirr007/ai-tooling/universal-project-setup/sync-ai-config.sh --project
```

---

## File Structure

```
ai-tooling/universal-project-setup/
├── README.md                              # This file
├── universal-project-setup-prompt.md      # 🎯 MAIN PROMPT (copy-paste this)
├── registry.yaml                          # Unified model registry (20+ models)
├── sync-ai-config.sh                      # Sync script (executable)
├── tools/                                 # Global config templates
│   ├── opencode/config.template
│   ├── kiro/config.template
│   ├── antigravity/config.template
│   ├── claude/config.template
│   ├── devin/config.template
│   ├── aider/config.template
│   ├── continue/config.template
│   ├── goose/config.template
│   └── openhands/config.template
└── project-configs/                       # Project-local configs (symlinked)
    ├── aider.conf.yml
    ├── continue/config.json
    ├── openhands/config.yaml
    ├── CLAUDE.md                          # Template for Claude memory
    ├── opencode/README.md
    ├── kiro/README.md
    ├── antigravity/README.md
    └── devin/README.md
```

---

## How the Prompt Works

### Step 1: Detect Project Stage
- **New**: < 5 source files, no config files
- **Existing**: Has source, configs, git history

### Step 2: Interactive Interview
| New Project | Existing Project |
|-------------|------------------|
| 8 questions (type, stack, users, arch, team, constraints, priorities) | Silent analysis → 5 targeted questions (pain points, conventions, off-limits, workflows) |

### Step 3: Generate Unified Spec
Outputs `.ai-project-config.yaml` with:
- Project metadata (tech stack, architecture, team)
- AI tooling priorities & desired workflows
- Model profiles (coding-fast, reasoning-deep, etc.)
- Skills & agents definitions
- Per-tool overrides

### Step 4: Tool-Specific Implementation
Generates exact configs for all 9 tools with:
- Config file paths & content
- Commands to install skills/agents
- Verification steps

### Step 5: Sync Script
Produces `sync-ai-config.sh` for team replication.

---

## Model Profiles (from registry.yaml)

| Profile | Primary | Fallback | Use Case |
|---------|---------|----------|----------|
| `coding-fast` | GPT-4o Mini | Qwen 2.5 Coder 14B | Quick edits, boilerplate |
| `reasoning-deep` | Claude Sonnet 4 | o1 Preview | Architecture, complex refactoring |
| `architecture` | Claude Opus 4 | Claude Sonnet 4 | System design, tech selection |
| `review-thorough` | Claude Sonnet 4 | GPT-4o | PR review, security audit |
| `local-only` | Qwen 2.5 Coder 32B | CodeLlama 34B | Private code, offline, free |
| `test-generation` | GPT-4o Mini | Qwen 2.5 Coder 14B | Unit/integration tests |
| `docs-writing` | Claude Sonnet 4 | GPT-4o | API docs, README, comments |
| `debugging` | Claude Sonnet 4 | o1 Mini | Root cause analysis |
| `learning` | Claude Sonnet 4 | Gemini 1.5 Flash | Code explanation, onboarding |

---

## Sync Script Usage

```bash
# Sync everything (default)
./sync-ai-config.sh

# Global only
./sync-ai-config.sh --global

# Project only
./sync-ai-config.sh --project

# With verification
./sync-ai-config.sh --verify

# Dry run (preview)
./sync-ai-config.sh --dry-run

# Combined
./sync-ai-config.sh --global --project --verify
```

### What It Does

| Mode | Action |
|------|--------|
| `--global` | Symlinks registry → `~/.config/ai-models/`, renders 9 global configs from templates |
| `--project` | Symlinks project configs (`.aider.conf.yml`, `.continue/`, `.openhands/`, `CLAUDE.md`, `.opencode/`, etc.) into current directory |
| `--verify` | Checks each installed tool starts and sees its config |

---

## Environment Variables

Create `~/.local/share/ai-keys.sh`:

```bash
# Required for cloud models
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
export OPENROUTER_API_KEY="sk-or-..."
export GOOGLE_API_KEY="..."

# Optional
export GITHUB_TOKEN="ghp_..."
export OLLAMA_BASE_URL="http://localhost:11434"
```

**Never commit this file.** Add to `.gitignore`.

---

## Adding to a New Project

### Option A: Run Prompt (Recommended for new projects)
```bash
cd /new/project
opencode run "$(cat ~/dotfiles/ai-tooling/universal-project-setup/universal-project-setup-prompt.md)"
# Answer questions → say "apply" → run sync
```

### Option B: Minimal Setup (Existing projects)
```bash
cd /existing/project
# Just sync project configs (uses defaults)
~/dotfiles/ai-tooling/universal-project-setup/sync-ai-config.sh --project

# Then customize .ai-project-config.yaml and re-run prompt if needed
```

### Option C: Copy Configs Manually
```bash
cd /project
# Copy specific configs you want
cp ~/dotfiles/ai-tooling/universal-project-setup/project-configs/aider.conf.yml .aider.conf.yml
cp ~/dotfiles/ai-tooling/universal-project-setup/project-configs/continue/config.json .continue/config.json
# etc.
```

---

## Customization

### Add Custom Models
Edit `registry.yaml`:
```yaml
models:
  my-custom-model:
    provider: openrouter
    model_id: my-org/my-model
    # ... rest of fields
```

### Add Custom Profiles
```yaml
profiles:
  my-profile:
    primary: my-custom-model
    fallback: gpt-4o-mini
```

### Tool-Specific Overrides
In `.ai-project-config.yaml`:
```yaml
tool_configs:
  opencode:
    default_model_profile: reasoning-deep
  aider:
    weak-model: gpt-4o-mini
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `envsubst: command not found` | Install gettext: `brew install gettext` / `apt install gettext` / `choco install gettext` |
| Tool not found in verification | Install the tool first, then re-run with `--verify` |
| API key errors | Check `~/.local/share/ai-keys.sh` is sourced and keys are valid |
| Symlink errors on Windows | Run terminal as Administrator, or use `mklink` manually |
| Docker errors for OpenHands | Ensure Docker is running, try `docker pull ghcr.io/all-hands-ai/openhands:latest` |

---

## Updating

```bash
cd ~/dotfiles-kathirr007
git pull
./ai-tooling/universal-project-setup/sync-ai-config.sh --global --verify
```

Then in each project:
```bash
cd /project
~/dotfiles-kathirr007/ai-tooling/universal-project-setup/sync-ai-config.sh --project
```

---

## Related Files

- `~/.config/opencode/config.json` — Opencode global config
- `~/.kiro/config.yaml` — Kiro global config
- `~/.antigravity/config.toml` — Antigravity global config
- `~/.claude/config.json` — Claude CLI global config
- `~/.devin/config.yaml` — Devin global config
- `~/.aider.conf.yml` — Aider global config
- `~/.continue/config.json` — Continue global config
- `~/.config/goose/config.yaml` — Goose global config
- `~/.openhands/config.yaml` — OpenHands global config
- `~/.config/ai-models/registry.yaml` — Unified model registry (symlinked)

---

## License

Part of [dotfiles-kathirr007](https://github.com/kathirr007/dotfiles-kathirr007) — MIT License