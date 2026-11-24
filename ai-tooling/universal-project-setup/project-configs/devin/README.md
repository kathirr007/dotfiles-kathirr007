# Devin Project Config

This directory contains project-specific Devin configuration.
Symlinked to `.devin/` in project root.

## Structure

```
.devin/
├── agents/          # Custom agents
│   └── <agent-name>.yaml
├── skills/          # Custom skills
│   └── <skill-name>/
│       └── skill.yaml
└── config.yaml      # Project overrides for global config
```

## Usage

Run `devin` in project root to use project-specific config.
Global config at `~/.devin/config.yaml` provides base settings.
Team sync via `devin config pull/push`.