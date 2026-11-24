# Antigravity Project Config

This directory contains project-specific Antigravity configuration.
Symlinked to `.antigravity/` in project root.

## Structure

```
.antigravity/
├── agents/          # Custom agents
│   └── <agent-name>.toml
├── skills/          # Custom skills
│   └── <skill-name>/
│       └── skill.toml
└── hooks/           # Custom hooks
    └── <hook-name>.toml
```

## Usage

Run `antigravity` in project root to use project-specific config.
Global config at `~/.antigravity/config.toml` provides base settings.