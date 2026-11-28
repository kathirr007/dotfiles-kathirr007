# Prompt Templates

Reusable, copy-paste prompt templates that live in the dotfiles repo and can be run with
any AI coding tool on any machine.

---

## Templates

| Template | What it does |
|----------|--------------|
| [`local-ai-coding-setup-prompt.md`](./local-ai-coding-setup-prompt.md) | Agent profiles your hardware itself and designs the best **fully local** AI coding setup — Ollama/LM Studio models, quantisation, VRAM/RAM budget, autocomplete + agentic configs |

---

## Quick Start

```bash
# Run any template with ANY tool — the agent does the machine inspection itself
opencode run "$(cat ~/dotfiles-kathirr007/ai-tooling/prompt-templates/local-ai-coding-setup-prompt.md)"
claude   -p "$(cat ~/dotfiles-kathirr007/ai-tooling/prompt-templates/local-ai-coding-setup-prompt.md)"
kiro run   "$(cat ~/dotfiles-kathirr007/ai-tooling/prompt-templates/local-ai-coding-setup-prompt.md)"
```

---

## How `local-ai-coding-setup-prompt.md` Works

| Step | What happens | Output |
|------|--------------|--------|
| **0** | Agent detects the OS and runs a **single self-contained collector command** for it | Raw profile: CPU, cores, RAM + slots, GPU + VRAM *and current in-use VRAM*, disks, Ollama/py/node/docker presence, already-pulled model list, installed AI editor extensions |
| **0b** | `PROFILE LOCKED` acknowledgement | 6-row hardware table + VRAM budget *after desktop-compositor overhead* |
| **1** | Capacity arithmetic | Usable VRAM for models, usable inference RAM, per-tier offload strategy, tok/s estimates with confidence |
| **2** | Model matrix | One model per role (coding agent / fast chat / autocomplete FIM / embeddings) with tag, quant, footprint, VRAM-vs-RAM split, context, est. tok/s |
| **3** | Serving stack | Env vars for this OS, a complete `Modelfile` (`num_ctx`, `num_gpu`, temperature, coding system prompt), model-switching policy, warmup commands |
| **4** | Client layer | Continue/Roo/Cline config file content, autocomplete settings, `aider` CLI flags, codebase-indexing rules |
| **5** | Deliverables | Ranked idempotent runbook with per-step verification, configs with no placeholders, "not worth doing on this machine", OOM/thrash signs, local vs cloud cost |

### Collector coverage (Step 0)

| Field | Windows | Linux | macOS |
|-------|---------|-------|-------|
| CPU / cores / threads | CIM | `/proc/cpuinfo` | `sysctl` |
| RAM | CIM + `Win32_PhysicalMemory` slots | `/proc/meminfo` | `sysctl -n hw.memsize` (+ unified-memory flag) |
| GPU + live VRAM | `nvidia-smi` (WMI fallback) | `nvidia-smi` → `rocm-smi` → `/dev/dri` | `system_profiler SPDisplaysDataType` |
| Disk free | LogicalDisk (all drives) | `df` | `df` |
| Serving tools | `ollama` / `lm-studio` / `docker` / `python` / `uv` / `node` | same | + `brew` |
| Ollama state | version + `OLLAMA_HOST` + `OLLAMA_MODELS` + full `ollama list` | same | same |
| Existing AI tooling | VS Code AI extensions | same | same |

---

## File Structure

```
ai-tooling/prompt-templates/
├── README.md                                # This file
└── local-ai-coding-setup-prompt.md          # 🎯 MAIN PROMPT (copy-paste this)
```

---

## Example: what `PROFILE LOCKED` looks like

Run on an MSI Katana 15 (i7-13620H, 64 GB RAM, RTX 4050 Laptop 6 GB, Ollama 0.40.19):

| Field | Collected value |
|-------|-----------------|
| CPU | Intel i7-13620H, 10C / 16T |
| RAM | 64.0 GB (2 × 32 GB slots) |
| GPU | RTX 4050 Laptop, 6 GB VRAM, **3,971 MiB already in use** |
| VRAM budget | ~2 GB now (≈4.5 GB with displays free) → **hybrid offload machine** |
| Disk | C: 130 GB free — models dir OK |
| Tooling | Ollama present, Continue + Roo Cline installed, Aider configured |

Resulting recommendation: `qwen3-coder:30b` (Q4_K_M, ~18 GB, hybrid offload ≈6–12 tok/s) as
the primary coding model, `qwen3:8b` for fast chat, `qwen2.5-coder:1.5b-base` for inline
autocomplete, `nomic-embed-text` for codebase RAG — all via Ollama on `localhost:11434`.

---

## Notes

- Step 0 deliberately reads **currently used VRAM**, not just total — on a laptop GPU that
  is driving panels, total VRAM overstates what a model can actually claim.
- The prompt reuses already-pulled models when they are within ~15% of the best available
  option, so you don't re-download 18 GB you already own.
- If no collector runs on the host, the prompt asks for exactly five items rather than
  guessing — a wrong VRAM number invalidates the whole plan.

---

## License

Part of [dotfiles-kathirr007](https://github.com/kathirr007/dotfiles-kathirr007) — MIT License