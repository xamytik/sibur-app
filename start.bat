@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set "P=!ESC![38;2;255;182;193m"
set "B=!ESC![1m"
set "R=!ESC![0m"
set "G=!ESC![90m"

cls

echo.
echo !P!!B!  oooooo     oooo ooooo  .oooooo..o ooooo   .oooooo.   ooooo      ooo!R!
echo !P!!B!   '888.     .8'  '888' d8P'    'Y8  '888'  d8P'  'Y8b  '888b.   .8888'!R!
echo !P!!B!    '888.   .8'    888  Y88bo.        888  888      888   8 'Y88. .P888'!R!
echo !P!!B!     '888. .8'     888   '"Y8888o.    888  888      888   8   '888'  888!R!
echo !P!!B!      '888.8'      888       '"Y88b   888  888      888   8    Y88   888!R!
echo !P!!B!       '888'       888  oo     .d8P   888  '88b    d88'   8     Y8   888!R!
echo !P!!B!        '8'       o888o 8""88888P'   o888o  'Y8bood8P'   o8o     Y   o888o!R!
echo.
echo !P!!B!          ~~~ Vision-Control : SIBUR Enterprise ~~~!R!
echo !G!  ================================================================!R!
echo.

if not exist venv (
    echo !P!  ^> [1/3] Sozdayu virtualnoe okruzhenie...!R!
    python -m venv venv
    echo !P!  [OK] Okruzhenie sozdano!!R!
) else (
    echo !P!  [OK] [1/3] Virtualnoe okruzhenie uzhe suschestvuet!R!
)

echo.
echo !P!  ^> [2/3] Aktiviruju okruzhenie i ustanavlivaju biblioteki...!R!
call venv\Scripts\activate.bat
pip install -q -r requirements.txt
echo !P!  [OK] Vse biblioteki ustanovleny!!R!

echo.
echo !P!  ^> [3/3] Zapuskayu prilozhenie...!R!
echo !G!  ================================================================!R!
echo.
echo !P!!B!            http://localhost:8501!R!
echo.
echo !G!  ================================================================!R!
echo.

python -m streamlit run app.py

echo.
echo !G!  ================================================================!R!
echo.
echo !P!!B!   ██████╗ ██╗   ██╗    ██╗  ██╗ █████╗ ███╗   ███╗██╗   ██╗████████╗██╗██╗  ██╗!R!
echo !P!!B!   ██╔══██╗╚██╗ ██╔╝    ╚██╗██╔╝██╔══██╗████╗ ████║╚██╗ ██╔╝╚══██╔══╝██║██║ ██╔╝!R!
echo !P!!B!   ██████╔╝ ╚████╔╝      ╚███╔╝ ███████║██╔████╔██║ ╚████╔╝    ██║   ██║█████╔╝!R!
echo !P!!B!   ██╔══██╗  ╚██╔╝       ██╔██╗ ██╔══██║██║╚██╔╝██║  ╚██╔╝     ██║   ██║██╔═██╗!R!
echo !P!!B!   ██████╔╝   ██║       ██╔╝ ██╗██║  ██║██║ ╚═╝ ██║   ██║      ██║   ██║██║  ██╗!R!
echo !P!!B!   ╚═════╝    ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝   ╚═╝      ╚═╝   ╚═╝╚═╝  ╚═╝!R!
echo.
echo !G!  ================================================================!R!
echo.
pause