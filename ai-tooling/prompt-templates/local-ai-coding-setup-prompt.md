# Local AI Coding Setup Prompt

**Ready-to-copy prompt** for designing the best fully-local AI coding setup on the machine
you are running on. The agent collects the hardware profile itself — you paste nothing.

---

## Usage

```bash
# Run from ANY repo or empty directory — the agent inspects the machine itself
opencode run "$(cat ~/dotfiles-kathirr007/ai-tooling/prompt-templates/local-ai-coding-setup-prompt.md)"
# or
claude -p "$(cat ~/dotfiles-kathirr007/ai-tooling/prompt-templates/local-ai-coding-setup-prompt.md)"
# or
kiro run "$(cat ~/dotfiles-kathirr007/ai-tooling/prompt-templates/local-ai-coding-setup-prompt.md)"

# 1. The agent detects your OS and runs the embedded collector itself (Step 0)
# 2. It prints "PROFILE LOCKED" with the VRAM arithmetic — read this before continuing
# 3. You get a ranked install runbook, model matrix, and ready-to-write configs
```

**Nothing to install or paste beforehand.** Windows PowerShell, Linux and macOS collectors
are all embedded in the prompt.

---

## The Complete Prompt

Copy everything inside the code block below:

````markdown
ROLE: You are a local-LLM inference engineer. Recommend the best FULLY LOCAL AI coding
setup for the machine you are running on. Goal, in priority order:
  1. Best code-quality-per-token from a locally-runnable model
  2. Achievable tokens/sec on this specific hardware
  3. Zero API cost, zero rate limits, no code leaves the machine
  4. Low setup friction — everything must already exist or be one command away

──────────────────────────────────────────────────────────────
STEP 0 — COLLECT THE HARDWARE PROFILE YOURSELF (DO NOT ASK THE USER)
──────────────────────────────────────────────────────────────
Run the collector below with your shell tool. Do NOT ask the user to paste specs,
computer model, or "can you run this?" — you have a shell, use it. Capture the whole
output; you will reference it in every later step.

-- Detected OS, then run the matching block ---------------------------------------

▸ If Windows (powershell) — run as ONE command:

$p = Get-CimInstance Win32_Processor | Select-Object -First 1
"OS=Windows " + (Get-CimInstance Win32_OperatingSystem | ForEach-Object { "$($_.Caption) build $($_.BuildNumber) $($_.OSArchitecture)" })
"CPU=$($p.Name) cores=$($p.NumberOfCores) threads=$($p.NumberOfLogicalProcessors)"
"RAM_GB=" + [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)
$m = Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum
"RAM_SLOTS=" + $m.Count + " x " + [math]::Round($m.Sum/$m.Count/1GB) + " GB"
$n = nvidia-smi --query-gpu=name,memory.total,memory.used,driver_version --format=csv,noheader 2>$null
if ($n) { "GPU=" + ($n -join '; ') } else { "GPU=" + ((Get-CimInstance Win32_VideoController | ForEach-Object Name) -join '; ') + " | nvidia-smi UNAVAILABLE" }
"DISK=" + ((Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object { "$($_.DeviceID):$([math]::Round($_.FreeSize/1GB))G free of $([math]::Round($_.Size/1GB,1))G" }) -join ' | ')
foreach ($t in @('ollama','lm-studio','docker','podman','python','uv','node','git','wsl')) {
  $s = (Get-Command $t -ErrorAction SilentlyContinue).Source
  $v = if ($s -and $t -eq 'ollama') { ' ' + (ollama --version 2>$null) } else { '' }
  "TOOL $t=" + $(if ($s) { "present$v" } else { 'missing' })
}
"OLLAMA_HOST=" + $(if ($env:OLLAMA_HOST) { $env:OLLAMA_HOST } else { 'default 127.0.0.1:11434' })
"OLLAMA_MODELS=" + $(if ($env:OLLAMA_MODELS) { $env:OLLAMA_MODELS } else { 'default ~/.ollama/models' })
"OLLAMA_MODELS_PULLED:"; ollama list 2>$null
"VSCODE_AI_EXT=" + ((code --list-extensions 2>$null | Where-Object { $_ -match 'continue|cline|roo|kilocode|aider|copilot|windsurf|augment|cody|tabnine' }) -join ', ')

▸ If Linux — run as ONE command:

echo "OS=Linux $(. /etc/os-release && echo $PRETTY_NAME) kernel $(uname -r)"
echo "CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ *//') cores=$(nproc --all)"
echo "RAM_GB=$(awk '/MemTotal/{printf "%.1f", $2/1048576}' /proc/meminfo)"
if command -v nvidia-smi >/dev/null; then echo "GPU=$(nvidia-smi --query-gpu=name,memory.total,memory.used,driver_version --format=csv,noheader | tr '\n' ';')";
elif command -v rocm-smi >/dev/null; then echo "GPU=$(rocm-smi --showproductname --csv 2>/dev/null | tail -n +2 | tr '\n' ';')";
else echo "GPU=none detected | /dev/dri: $(ls /dev/dri 2>/dev/null | tr '\n' ' ')"; fi
echo "DISK=$(df -h --output=target,avail,size -x tmpfs -x devtmpfs 2>/dev/null | tail -n +2 | awk '{printf "%s %s/%s  ", $1,$2,$3}' | sed 's/  *$//')"
for t in ollama lm-studio docker podman python3 uv node git; do
  if command -v $t >/dev/null; then echo "TOOL $t=present $($t --version 2>/dev/null | head -1)"; else echo "TOOL $t=missing"; fi
done
echo "OLLAMA_HOST=${OLLAMA_HOST:-default 127.0.0.1:11434}"; echo "OLLAMA_MODELS=${OLLAMA_MODELS:-default ~/.ollama/models}"
echo "OLLAMA_MODELS_PULLED:"; ollama list 2>/dev/null
echo "VSCODE_AI_EXT=$(code --list-extensions 2>/dev/null | grep -Ei 'continue|cline|roo|kilocode|aider|copilot|windsurf|augment|cody|tabnine' | paste -sd, -)"

▸ If macOS — run as ONE command:

echo "OS=macOS $(sw_vers -productVersion) build $(sw_vers -buildVersion)"
echo "CPU=$(sysctl -n machdep.cpu.brand_string) cores=$(sysctl -n hw.physicalcpu) threads=$(sysctl -n hw.logicalcpu)"
echo "RAM_GB=$(echo "scale=1; $(sysctl -n hw.memsize) / 1073741824" | bc) UNIFIED_MEMORY=yes"
echo "GPU=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -E 'Chipset|VRAM|Total Number of Cores' | sed 's/^ *//' | tr '\n' ';')"
echo "DISK=$(df -h / | tail -1 | awk '{print $2" free of "$4" total, "$9" mount"}')"
for t in ollama lm-studio docker python3 uv node git brew; do
  if command -v $t >/dev/null; then echo "TOOL $t=present $($t --version 2>/dev/null | head -1)"; else echo "TOOL $t=missing"; fi
done
echo "OLLAMA_HOST=${OLLAMA_HOST:-default 127.0.0.1:11434}"; echo "OLLAMA_MODELS_PULLED:"; ollama list 2>/dev/null
echo "VSCODE_AI_EXT=$(code --list-extensions 2>/dev/null | grep -Ei 'continue|cline|roo|kilocode|aider|copilot|windsurf|augment|cody|tabnine' | paste -sd, -)"

▸ If NONE of the collectors run, ONLY THEN ask the user for these five items in one
  message: (a) OS + version, (b) CPU model + core/thread count, (c) RAM in GB,
  (d) GPU model + VRAM, (e) free disk on the main drive + whether Ollama is installed.
  Never guess these numbers; a wrong VRAM figure invalidates the whole plan.

Acknowledgement requirement: before proceeding, print "PROFILE LOCKED" plus a 6-row
table (CPU / RAM / GPU / VRAM budget after desktop overhead / disk / existing tooling),
and list any field the collector could not determine.

──────────────────────────────────────────────────────────────
STEP 1 — HARD CAPACITY ANALYSIS (show the arithmetic)
──────────────────────────────────────────────────────────────
- Usable VRAM for models = total VRAM − current in-use VRAM from the collector
  (desktop compositor typically holds 300–1500 MiB, more if it drives external panels).
  On laptops, also state the "display disconnected / lid closed" best case.
- Inference RAM budget = total RAM − 4–6 GB for OS, browser, IDE.
- Drive check: confirm the Ollama models dir is on a real SSD (not network / spinning /
  nearly full). If free space < model size × 2, say so.
- Per model tier, decide strategy and number of GPU layers:
  full GPU offload / partial (hybrid) offload / CPU-only (or unified memory on macOS).
- Give tok/s estimates for Q4_K_M, bandwidth-bound math, ±40% confidence, and say which
  number you are least sure about.

──────────────────────────────────────────────────────────────
STEP 2 — MODEL SELECTION
──────────────────────────────────────────────────────────────
Fill this matrix. One model per role, specific tag + quant, nothing that does not fit:

| Role | Model:tag | Params | Quant | Footprint | VRAM vs RAM split | num_ctx | Est. tok/s |
|:--|:--|--:|:--|--:|:--|--:|--:|
| Primary coding agent (multi-file, tools) | | | | | | | |
| Fast chat / edit | | | | | | | |
| Inline autocomplete / FIM | | | | | | | |
| Embedding (codebase RAG) | | | | | | | |

Rules I want applied, not just listed:
- Prefer a smaller model that runs fast over a larger one that thrashes swap.
- Prefer permissively licensed weights (Apache-2.0 / MIT / OpenRAIL-M style). Call out
  any pick with a commercial-restricted license and its consequence.
- Check the already-pulled models from STEP 0 first: reuse what is on disk whenever it is
  within ~15% of the best available option, and say so when reusing beats re-pulling.
- If a 30B+ coder is feasible, name the exact context length at which KV cache forces a
  layer offload (state the token count).

──────────────────────────────────────────────────────────────
STEP 3 — SERVING STACK
──────────────────────────────────────────────────────────────
- Server choice: Ollama vs llama.cpp server vs LM Studio — recommend ONE for this machine
  and one sentence why (Linux: llama.cpp often wins on CPU; Windows: Ollama wins on ops time).
- All environment variables to set, with the exact set/export command for this OS.
  At minimum address: model keep-alive, flash-attention, max loaded models, and a VRAM
  overhead floor so the desktop compositor is never squeezed out.
- A complete Modelfile (or CLI flags) for the primary model: num_ctx, num_gpu (or -ngl),
  num_batch, temperature, top_p, repeat_penalty, num_predict, and a system prompt tuned
  for coding (plan-before-edit, no fabricated APIs, minimal diffs).
- Model-switching policy so two large models never both sit in VRAM.
- Warmup / preload commands so the first prompt is not a 60s cold load.

──────────────────────────────────────────────────────────────
STEP 4 — CLIENT / EDITOR LAYER
──────────────────────────────────────────────────────────────
Wire everything to localhost — no cloud API key anywhere. For each: name, config, exact
file/JSON snippet, and which model+role it gets.
- Agentic editor extension (Continue / Roo Code / Cline / Kilo Code style) — give the
  actual config file content, including context/embedding provider and indexing.
- Inline autocomplete — model, FIM support, debounce/trigger settings.
- CLI pair programmer (aider) — full command line with autocommit, streaming and
  edit-format flags set for a slow-ish local model.
- Optional: embedding-based codebase Q&A, and how to index the repo (chunk size, paths to
  exclude so it does not eat node_modules / .git / dist).

──────────────────────────────────────────────────────────────
STEP 5 — DELIVERABLES, IN THIS ORDER
──────────────────────────────────────────────────────────────
1. "PROFILE LOCKED" hardware table + the VRAM/RAM budget arithmetic.
2. Model matrix table (STEP 2), fully filled.
3. Ranked install runbook — ordered, copy-pasteable, idempotent, with a one-line
   verification command after each step.
4. Final configs, complete and file-ready, no placeholders like <your-model>.
5. "Not worth doing on this machine" list (models, quantisations, concurrency, settings).
6. Tuning: the 3 knobs to turn first if generation is slow, and the 3 signs you are
   OOM-ing or thrashing.
7. Local vs cloud: cost of ~1000 similar coding sessions local (electricity only) vs the
   cheapest per-token API, and what you give up for going local.

TONE: concrete numbers over adjectives. If a recommendation is a judgement call, say
so and give the fallback. Do not recommend anything requiring a paid API or a
cloud account.
````

---

## License

Part of [dotfiles-kathirr007](https://github.com/kathirr007/dotfiles-kathirr007) — MIT License