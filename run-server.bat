@echo off
SET "NODE_PATH=C:\Program Files\nodejs\node.exe"
SET "NPM_PATH=C:\Program Files\nodejs\npm.cmd"

echo ⚡ Starting AI Converter Server...
echo.

if not exist "%NODE_PATH%" (
    echo ❌ ERROR: Node.js was not found at %NODE_PATH%
    echo Checking your system path instead...
    where node >nul 2>&1
    if %errorlevel% neq 0 (
        echo Node.js is still not detected. Please restart your computer.
        pause
        exit /b
    )
    SET "NODE_PATH=node"
    SET "NPM_PATH=npm"
)

if not exist "node_modules\express" (
    echo 📦 Installing dependencies...
    call "%NPM_PATH%" install express cors axios fs-extra
)

echo 🚀 Server is starting on http://localhost:8082
echo 💡 Keep this window open while using the tool!
echo.
"%NODE_PATH%" server.js
pause
