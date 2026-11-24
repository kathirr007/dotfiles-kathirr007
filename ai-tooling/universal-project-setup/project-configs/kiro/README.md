# Kiro Project Config

This directory contains project-specific Kiro configuration.
Symlinked to `.kiro/` in project root.

## Structure

```
.kiro/
├── agents/          # Custom agents
│   └── <agent-name>.yaml
├── skills/          # Custom skills
│   └── <skill-name>/
│       └── skill.yaml
└── hooks/           # Custom hooks
    └── <hook-name>.yaml
```

## Usage

Run `kiro` in project root to use project-specific config.
Global config at `~/.kiro/config.yaml` provides base settings.