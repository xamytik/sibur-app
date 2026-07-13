@echo off
echo === Настройка и запуск проекта Vision-Контроль ===

if not exist venv (
    echo [1/3] Создаю новое виртуальное окружение...
    python -m venv venv
)

echo [2/3] Активирую окружение и проверяю библиотеки...
call venv\Scripts\activate.bat
pip install streamlit opencv-python numpy

echo [3/3] Запускаю интерфейс...
python -m streamlit run app.py
pause