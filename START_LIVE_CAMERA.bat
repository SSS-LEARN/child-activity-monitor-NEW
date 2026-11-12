@echo off
title Child Activity Monitor - live camera
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
  echo Run START_WINDOWS.bat first, once, to install everything.
  goto end
)

echo.
echo === Starting the laptop webcam as the CCTV camera ===
echo === A video window opens. Press q in that window to stop.
echo === The dashboard's "Live camera" and "Class" pages show the same view.
echo === Classroom mode (2-3 children, names on boxes) is set on the Admin page.
".venv\Scripts\python.exe" -m monitor.pipeline --source 0 --display
if errorlevel 1 (
  echo.
  echo The camera could not start. Close other apps that use the camera, or edit this
  echo file and change --source 0 to --source 1.
)

:end
echo.
pause
