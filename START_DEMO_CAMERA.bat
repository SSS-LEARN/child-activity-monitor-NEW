@echo off
title Child Activity Monitor - demo camera (recorded clips)
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
  echo Run START_WINDOWS.bat first, once, to install everything.
  goto end
)

rem Use the clips in demo_clips\ if there are any, else the sample clip.
set SRC=docs\test-media\test_clip.mp4
dir /b /a-d demo_clips\*.mp4 demo_clips\*.mov demo_clips\*.avi demo_clips\*.mkv demo_clips\*.webm >nul 2>nul
if not errorlevel 1 set SRC=demo_clips

echo.
echo === Demo backup mode: playing %SRC% as if it were the live camera ===
echo === The clips loop until you press q in the video window.
echo === The dashboard's "Live camera", "Report" and "Class" pages update as usual.
".venv\Scripts\python.exe" -m monitor.pipeline --source "%SRC%" --loop --display

:end
echo.
pause
