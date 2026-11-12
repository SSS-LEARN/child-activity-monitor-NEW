@echo off
title Child Activity Monitor - dashboard
cd /d "%~dp0"

where python >nul 2>nul
if errorlevel 1 (
  echo.
  echo Python was not found.
  echo Install Python 3.12 from https://www.python.org/downloads/
  echo and tick "Add Python to PATH" on the first installer screen.
  echo Then double-click this file again.
  goto end
)

if not exist ".venv\Scripts\python.exe" (
  echo.
  echo === First-time setup: creating the Python environment ===
  python -m venv .venv
  if errorlevel 1 goto fail
)

rem Install or update the libraries whenever requirements.txt has changed.
fc /b requirements.txt ".venv\requirements.installed" >nul 2>nul
if errorlevel 1 (
  echo.
  echo === Installing libraries. The first time this takes 5-10 minutes. ===
  ".venv\Scripts\python.exe" -m pip install --upgrade pip
  ".venv\Scripts\python.exe" -m pip install -r requirements.txt
  if errorlevel 1 goto fail
  copy /y requirements.txt ".venv\requirements.installed" >nul
)

if not exist "models\ssd_mobilenet_v2_coco.pb" (
  echo.
  echo === Downloading the AI models ===
  ".venv\Scripts\python.exe" scripts\download_models.py
  if errorlevel 1 goto fail
)

if not exist "models\face_recognition_sface_2021dec.onnx" (
  echo.
  echo === Downloading the face models for name tags, optional ===
  ".venv\Scripts\python.exe" scripts\download_models.py --faces
)

if not exist "data\activity.db" (
  ".venv\Scripts\python.exe" scripts\seed_demo_data.py
)

echo.
echo === Starting the dashboard. Your browser will open http://localhost:5000 ===
echo === Sign in with admin / admin123 (or teacher / teacher123, parent1 / parent123)
echo === Keep this window open. Close it to stop the app.
start "" cmd /c "timeout /t 5 >nul & start http://localhost:5000"
".venv\Scripts\python.exe" -m dashboard.app
goto end

:fail
echo.
echo Something went wrong. Take a screenshot of this window and send it.

:end
echo.
pause
