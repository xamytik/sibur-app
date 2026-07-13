<# : batch script
@echo off
setlocal
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%~f0"
pause
exit /b
: end batch / begin PowerShell #>

# ===== Vision Control - SIBUR Enterprise =====
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Vision Control - SIBUR Enterprise"

$pk = @{ ForegroundColor = 'Magenta' }
$gr = @{ ForegroundColor = 'DarkGray' }
$gn = @{ ForegroundColor = 'Green' }

Clear-Host

# ---- HEADER ----
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" @pk
Write-Host "  ║                                                        ║" @pk
Write-Host "  ║        VISION CONTROL  :  SIBUR Enterprise             ║" @pk
Write-Host "  ║                                                        ║" @pk
Write-Host "  ╚══════════════════════════════════════════════════════════╝" @pk
Write-Host ""

# ---- STEP 1: Virtual Environment ----
if (-not (Test-Path "venv")) {
    Write-Host "  [1/3] Creating virtual environment..." @pk
    & python -m venv venv
    if ($LASTEXITCODE -eq 0) {
        Write-Host "        Done!" @gn
    } else {
        Write-Host "        ERROR: Python not found. Install from python.org" -ForegroundColor Red
        Read-Host "  Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "  [1/3] Virtual environment ready" @gn
}

Write-Host ""

# ---- STEP 2: Dependencies ----
Write-Host "  [2/3] Installing dependencies..." @pk
. .\venv\Scripts\Activate.ps1
& pip install -q -r requirements.txt
Write-Host "        Done!" @gn

Write-Host ""

# ---- STEP 3: Launch ----
Write-Host "  [3/3] Launching application..." @pk
Write-Host ("  " + "-" * 58) @gr
Write-Host ""
Write-Host "              http://localhost:8501" @pk
Write-Host ""
Write-Host ("  " + "-" * 58) @gr
Write-Host ""

& python -m streamlit run app.py

# ---- FOOTER ----
Write-Host ""
Write-Host ("  " + "=" * 82) @gr
Write-Host ""
Write-Host "   ██████╗ ██╗   ██╗    ██╗  ██╗ █████╗ ███╗   ███╗██╗   ██╗████████╗██╗██╗  ██╗" @pk
Write-Host "   ██╔══██╗╚██╗ ██╔╝    ╚██╗██╔╝██╔══██╗████╗ ████║╚██╗ ██╔╝╚══██╔══╝██║██║ ██╔╝" @pk
Write-Host "   ██████╔╝ ╚████╔╝      ╚███╔╝ ███████║██╔████╔██║ ╚████╔╝    ██║   ██║█████╔╝ " @pk
Write-Host "   ██╔══██╗  ╚██╔╝       ██╔██╗ ██╔══██║██║╚██╔╝██║  ╚██╔╝     ██║   ██║██╔═██╗ " @pk
Write-Host "   ██████╔╝   ██║       ██╔╝ ██╗██║  ██║██║ ╚═╝ ██║   ██║      ██║   ██║██║  ██╗" @pk
Write-Host "   ╚═════╝    ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝   ╚═╝      ╚═╝   ╚═╝╚═╝  ╚═╝" @pk
Write-Host ""
Write-Host ("  " + "=" * 82) @gr
Write-Host ""