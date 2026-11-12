@echo off
title Child Activity Monitor - reset demo data
cd /d "%~dp0"
echo This deletes all recorded activity and accounts, and loads fresh demo data:
echo   admin / admin123, teacher / teacher123, parent1, parent2, parent3 / parent123
echo Close the dashboard window first.
pause
".venv\Scripts\python.exe" scripts\seed_demo_data.py --reset
pause
