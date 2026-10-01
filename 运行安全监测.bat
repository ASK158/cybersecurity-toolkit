@echo off
chcp 65001 >nul 2>&1
title 个人电脑网络安全监测

echo.
echo   正在启动网络安全监测...
echo   请以管理员权限运行以获得完整信息
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0网络安全监测.ps1"

echo.
echo   按任意键退出...
pause >nul
