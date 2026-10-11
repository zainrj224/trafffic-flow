@echo off
rem Double-click or run .\run_chrome.bat  -> opens the game in Chrome, no device prompt.
cd /d "%~dp0"
call flutter pub get
call flutter run -d chrome --web-port 8080
