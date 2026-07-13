import streamlit as st
import cv2
import numpy as np
import math
import tempfile
import os
import matplotlib.pyplot as plt


def calculate_area(mask, height_m, fov_deg, image_width_px, theta_deg=0.0):
    fov_rad = math.radians(fov_deg)
    w_ground = 2 * height_m * math.tan(fov_rad / 2)
    s_pixel = (w_ground / image_width_px) ** 2

    pixel_count = cv2.countNonZero(mask)
    s_real = pixel_count * s_pixel

    if theta_deg != 0:
        theta_rad = math.radians(theta_deg)
        s_real = s_real / math.cos(theta_rad)

    return s_real, pixel_count


def process_frame(frame, h_min, s_min, v_min, h_max, s_max, v_max):
    # Ужимаем кадр до 1080p для плавной трансляции видео в браузере
    if frame.shape[1] > 1920:
        scale_percent = 1920 / frame.shape[1]
        new_width = int(frame.shape[1] * scale_percent)
        new_height = int(frame.shape[0] * scale_percent)
        frame = cv2.resize(frame, (new_width, new_height), interpolation=cv2.INTER_AREA)

    img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    img_hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

    lower_bound = np.array([h_min, s_min, v_min])
    upper_bound = np.array([h_max, s_max, v_max])
    mask = cv2.inRange(img_hsv, lower_bound, upper_bound)

    kernel = np.ones((5, 5), np.uint8)
    mask_cleaned = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
    mask_cleaned = cv2.morphologyEx(mask_cleaned, cv2.MORPH_CLOSE, kernel)

    # Полупрозрачное наложение (Alpha Blending) для красивого эффекта на видео
    colored_mask = np.zeros_like(img_rgb)
    colored_mask[mask_cleaned > 0] = [0, 255, 0]  # Зеленый цвет

    # Смешиваем оригинальный кадр и зеленую маску
    result_overlay = cv2.addWeighted(img_rgb, 0.7, colored_mask, 0.4, 0)

    contours, _ = cv2.findContours(mask_cleaned, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    valid_contours = [cnt for cnt in contours if cv2.contourArea(cnt) > 50]
    cv2.drawContours(result_overlay, valid_contours, -1, (0, 255, 0), 2)

    return mask_cleaned, result_overlay, frame.shape[1]


def main():
    st.set_page_config(page_title="Vision-Control", layout="wide", page_icon="🚁")
    st.title("🚁 Vision-Контроль: СИБУР Enterprise")

    # === ПРЕДПОЛЕТНЫЙ ЧЕК-ЛИСТ ===
    st.info("✅ Система активирована. Выберите режим работы в боковом меню.")

    # --- БОКОВАЯ ПАНЕЛЬ ---
    st.sidebar.header("⚙️ Характеристики камеры")
    height_m = st.sidebar.number_input("Высота подвеса H (м)", min_value=1.0, value=30.0, step=0.5)
    fov_deg = st.sidebar.number_input("Угол обзора FOV (°)", min_value=10.0, value=85.0, step=1.0)
    theta_deg = st.sidebar.slider("Угол наклона камеры θ (°)", min_value=0, max_value=89, value=0)

    st.sidebar.markdown("---")
    st.sidebar.header("🎯 Режим мониторинга")
    work_mode = st.sidebar.selectbox("Тип работ:", [
        "1. Стройка/Земля (Коричневый грунт)",
        "2. Уборка снега (Очищенный асфальт)",
        "3. Покос травы",
        "4. Ручной режим"
    ])

    if "Земля" in work_mode:
        def_h = (10, 35);
        def_s = (40, 255);
        def_v = (50, 220)
    elif "Снег" in work_mode:
        def_h = (0, 179);
        def_s = (0, 50);
        def_v = (0, 90)
    elif "Трава" in work_mode:
        def_h = (30, 85);
        def_s = (40, 255);
        def_v = (40, 255)
    else:
        def_h = (0, 179);
        def_s = (0, 255);
        def_v = (0, 255)

    st.sidebar.header("🎨 Тонкая настройка (HSV)")
    h_min = st.sidebar.slider("Hue Min", 0, 179, def_h[0])
    h_max = st.sidebar.slider("Hue Max", 0, 179, def_h[1])
    s_min = st.sidebar.slider("Sat Min", 0, 255, def_s[0])
    s_max = st.sidebar.slider("Sat Max", 0, 255, def_s[1])
    v_min = st.sidebar.slider("Val Min", 0, 255, def_v[0])
    v_max = st.sidebar.slider("Val Max", 0, 255, def_v[1])

    # === ВКЛАДКИ ===
    tab1, tab2, tab3 = st.tabs(["📸 Калибровка (Фото)", "🎥 Live Демо (Видео)", "💰 Экономика"])

    # --- ВКЛАДКА 1: ФОТО (осталась для точной настройки) ---
    with tab1:
        st.header("Шаг 1. Калибровка цвета по одному кадру")
        uploaded_photo = st.file_uploader("Загрузите скриншот с видео", type=['jpg', 'jpeg', 'png'])
        if uploaded_photo:
            file_bytes = np.asarray(bytearray(uploaded_photo.read()), dtype=np.uint8)
            img_bgr = cv2.imdecode(file_bytes, 1)
            mask_cleaned, result_overlay, current_width = process_frame(img_bgr, h_min, s_min, v_min, h_max, s_max, v_max)
            area_m2, _ = calculate_area(mask_cleaned, height_m, fov_deg, current_width, theta_deg)

            st.metric("Площадь на фото", f"{area_m2:,.2f} м²")
            st.image(result_overlay, caption="Предпросмотр маски", use_container_width=True)

    # --- ВКЛАДКА 2: LIVE ВИДЕО (КИЛЛЕР-ФИЧА) ---
    with tab2:
        st.header("Шаг 2. Анализ видеопотока в реальном времени")
        uploaded_video = st.file_uploader("Загрузите короткое видео (до 50 МБ) для демо", type=['mp4', 'mov'])

        if uploaded_video:
            st.success("Видео загружено! Нажмите кнопку ниже для запуска Live-аналитики.")
            if st.button("▶️ Запустить Live Dashboard"):
                # Сохраняем видео во временный файл
                tfile = tempfile.NamedTemporaryFile(delete=False, suffix='.mp4')
                tfile.write(uploaded_video.read())
                tfile.close()

                cap = cv2.VideoCapture(tfile.name)

                # Создаем пустые контейнеры для обновления интерфейса
                video_placeholder = st.empty()
                metrics_placeholder = st.empty()

                while cap.isOpened():
                    ret, frame = cap.read()
                    if not ret:
                        st.balloons()
                        st.success("Анализ видео завершен!")
                        break

                    # Обрабатываем кадр
                    mask_cleaned, result_overlay, current_width = process_frame(frame, h_min, s_min, v_min, h_max, s_max, v_max)
                    area_m2, _ = calculate_area(mask_cleaned, height_m, fov_deg, current_width, theta_deg)

                    # Рисуем красивый HUD прямо на видеокадре
                    cv2.rectangle(result_overlay, (20, 20), (500, 100), (0, 0, 0), -1) # Черная плашка
                    cv2.putText(result_overlay, f"LIVE DETECT: {area_m2:,.1f} m2", (30, 70),
                                cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0, 255, 0), 3)

                    # Отправляем кадр в интерфейс Streamlit
                    video_placeholder.image(result_overlay, channels="RGB", use_container_width=True)

                    # Обновляем цифры под видео
                    with metrics_placeholder.container():
                        st.metric("Текущая видимая площадь работ", f"{area_m2:,.1f} м²")

                cap.release()
                os.unlink(tfile.name)

    # --- ВКЛАДКА 3: ЭКОНОМИКА ---
    with tab3:
        st.header("💰 Финансовый контроль подрядчиков")
        contractor_area = st.number_input("Заявлено подрядчиком (м²):", value=1500)
        actual_area = st.number_input("Факт по ИИ (м²):", value=1100)
        price_per_m2 = st.number_input("Цена 1 м² (руб):", value=50)

        diff = contractor_area - actual_area
        st.metric("Сэкономлено бюджетов", f"{diff * price_per_m2:,.2f} руб", delta=f"Приписка: {diff} м²", delta_color="inverse")

if __name__ == "__main__":
    main()