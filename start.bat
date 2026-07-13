@echo off
cd /d "%~dp0"
cls
color 0D
title Vision Control - SIBUR Enterprise

echo.
echo   ============================================================
echo.
echo          VISION CONTROL  :  SIBUR Enterprise
echo.
echo   ============================================================
echo.

if not exist venv (
    echo   [1/3] Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo.
        echo   ERROR: Python not found! Install from python.org
        echo.
        pause
        exit /b 1
    )
    echo         Done!
) else (
    echo   [1/3] Virtual environment ready
)

echo.
echo   [2/3] Installing dependencies...
call venv\Scripts\activate.bat
pip install -q -r requirements.txt
echo         Done!

echo.
echo   [3/3] Launching application...
echo   ------------------------------------------------------------
echo.
echo              http://localhost:8501
echo.
echo   ------------------------------------------------------------
echo.

python -m streamlit run app.py

echo.
echo   ============================================================
echo.
if exist "%~dp0banner.txt" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Content '%~dp0banner.txt' -Encoding UTF8 | ForEach-Object { Write-Host $_ -ForegroundColor Magenta }"
)
echo.
echo   ============================================================
echo.
pause