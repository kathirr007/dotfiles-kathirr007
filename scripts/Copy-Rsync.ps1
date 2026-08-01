# Usage for each platform (script lives at C:\Users\Admin\Copy-Rsync.ps1; on macOS/Linux copy it anywhere, e.g. ~/Copy-Rsync.ps1):
# Windows - PowerShell
# & "C:\Users\Admin\Copy-Rsync.ps1" -Source "J:\Tuts\MyFolder" -Destination "\\K007VAULT\DataPart1\Softwares\MyFolder" -Threads 128
# Windows - cmd.exe
# powershell -ExecutionPolicy Bypass -File "C:\Users\Admin\Copy-Rsync.ps1" -Source "J:\Tuts\MyFolder" -Destination "\\K007VAULT\DataPart1\Softwares\MyFolder" -Threads 128
# macOS / Linux - Terminal (needs PowerShell Core + rsync installed)
# pwsh -File ~/Copy-Rsync.ps1 -Source "/home/user/MyFolder" -Destination "/mnt/vault/Softwares/MyFolder"

# Notes:
# - All use the same params: -Source, -Destination, optional -Threads (Windows only).
# - Include the folder name in -Destination to copy the whole folder (as discussed).
# - If pwsh isn't installed on macOS/Linux: brew install powershell or apt install powershell; rsync comes preinstalled on macOS, apt install rsync on Linux.

param(
  [Parameter(Mandatory = $true)][string]$Source,
  [Parameter(Mandatory = $true)][string]$Destination,
  [int]$Threads = 128
)

$ErrorActionPreference = 'Stop'

$isWindows = ($PSVersionTable.PSEdition -eq 'Desktop') -or $IsWindows -or ($env:OS -eq 'Windows_NT')

$srcRoot = $Source.TrimEnd('\', '/')
$dstRoot = $Destination.TrimEnd('\', '/')

if (-not (Test-Path -LiteralPath $srcRoot)) { throw "Source not found: $srcRoot" }
if (-not (Test-Path -LiteralPath $dstRoot)) { New-Item -ItemType Directory -Path $dstRoot -Force | Out-Null }

function Format-Size([long]$b) {
  if ($b -ge 1GB) { return '{0:N1} GB' -f ($b / 1GB) }
  if ($b -ge 1MB) { return '{0:N1} MB' -f ($b / 1MB) }
  return '{0:N0} KB' -f ($b / 1KB)
}

function Format-Eta([double]$s) {
  if ($s -lt 0 -or [double]::IsNaN($s) -or [double]::IsInfinity($s)) { return "--:--:--" }
  $t = [timespan]::FromSeconds([int]$s)
  return ('{0:00}:{1:00}:{2:00}' -f [int]$t.TotalHours, $t.Minutes, $t.Seconds)
}

if ($isWindows) {
  # ---------- Windows: robocopy + polling progress ----------
  $files = @(Get-ChildItem -LiteralPath $srcRoot -Recurse -File)
  if (-not $files) { throw "No files found under source." }

  $pairs = foreach ($f in $files) {
    $rel = $f.FullName.Substring($srcRoot.Length + 1)
    [pscustomobject]@{ Src = $f.FullName; SrcLen = $f.Length; Dst = (Join-Path $dstRoot $rel) }
  }
  $total = ($pairs | Measure-Object SrcLen -Sum).Sum

  $log = Join-Path $env:TEMP "rc-$([guid]::NewGuid().ToString('N')).log"
  $rcArgs = @("`"$srcRoot`"", "`"$dstRoot`"", "/E", "/MT:$Threads", "/J", "/R:0", "/W:0", "/COPY:DAT", "/NP", "/NFL", "/NDL", "/NJH", "/NJS", "/LOG:`"$log`"")
  $proc = Start-Process -FilePath "robocopy.exe" -ArgumentList $rcArgs -PassThru -WindowStyle Hidden

  try { $width = [Console]::BufferWidth } catch { $width = 120 }
  if ($width -lt 60 -or $width -gt 400) { $width = 120 }

  function Get-RobocopyInstance([int]$targetPid) {
    $samples = Get-Counter -Counter "\Process(*)\ID Process" -ErrorAction SilentlyContinue
    $match = $samples.CounterSamples | Where-Object { [int]$_.CookedValue -eq $targetPid } | Select-Object -First 1
    if ($match) { return $match.InstanceName }
    return $null
  }

  $sw = [Diagnostics.Stopwatch]::StartNew()
  $copied = 0.0
  $lastTick = 0.0
  $lastRate = 0.0
  $currentFile = $null
  $sampled = 0

  while (-not $proc.HasExited) {
    if ($sampled -gt 0) {
      $instance = Get-RobocopyInstance $proc.Id
      if ($instance) {
        $c = Get-Counter -Counter "\Process($instance)\IO Write Bytes/sec" -SampleInterval 1 -MaxSamples 1 -ErrorAction SilentlyContinue
        if ($c) { $lastRate = $c.CounterSamples[0].CookedValue }
      }
    }
    $sampled++

    $el = $sw.Elapsed.TotalSeconds
    $delta = $el - $lastTick
    if ($delta -gt 0) {
      $copied += $lastRate * $delta
      $lastTick = $el
    }
    $pct = [math]::Min(100.0, $copied * 100.0 / $total)
    $eta = if ($lastRate -gt 0) { ($total - $copied) / $lastRate } else { -1 }
    $line = ('{0,5:0.0}%  {1,10} / {2,-10}  {3,9}/s  ETA {4}' -f $pct, (Format-Size ([long]$copied)), (Format-Size $total), (Format-Size ([long]$lastRate)), (Format-Eta $eta))
    [Console]::Write("`r" + $line.PadRight($width - 1))
    if (-not $proc.HasExited) { Start-Sleep -Milliseconds 300 }
  }
  $proc.WaitForExit()
  $code = $proc.ExitCode
  $sw.Stop()
  [Console]::WriteLine("")
  $finalSpeed = if ($sw.Elapsed.TotalSeconds -gt 0) { $copied / $sw.Elapsed.TotalSeconds } else { 0 }
  $summary = "Complete: {0} copied in {1} at {2}/s  (robocopy exit code {3})" -f @((Format-Size ([long]$copied)), $sw.Elapsed.ToString('hh\:mm\:ss'), (Format-Size ([long]$finalSpeed)), $code)
  [Console]::WriteLine($summary)
}
else {
  # ---------- macOS / Linux: rsync with native progress2 ----------
  if (-not (Get-Command rsync -ErrorAction SilentlyContinue)) {
    throw "rsync not found. Install it (e.g. 'apt install rsync' / 'brew install rsync') and try again."
  }
  $srcSpec = $srcRoot.TrimEnd('/') + '/'
  $dstSpec = $dstRoot.TrimEnd('/') + '/'
  Write-Host "Using rsync: $srcSpec -> $dstSpec"
  & rsync -a --info=progress2 --stats "$srcSpec" "$dstSpec"
  $code = $LASTEXITCODE
  Write-Host ""
  Write-Host "rsync exit code: $code"
}
