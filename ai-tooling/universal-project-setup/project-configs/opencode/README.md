# Opencode Project Config

This directory contains project-specific Opencode configuration.
Symlinked to `.opencode/` in project root.

## Structure

```
.opencode/
├── skill/           # Custom skills
│   └── <skill-name>/
│       ├── skill.yaml
│       └── prompt.md
├── agent/           # Custom agents
│   └── <agent-name>/
│       └── agent.yaml
└── hooks/           # Custom hooks
    └── <hook-name>.js
```

## Usage

Run `opencode` in project root to use project-specific config.
Global config at `~/.config/opencode/config.json` provides base settings.