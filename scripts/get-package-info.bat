@echo off
REM Helper script to get package version information
REM Usage: get-package-info.bat

set PACKAGE_NAME=UserAccessSummaryApp
set DEV_HUB=agentforce-devhub

echo 📦 User Access Summary App - Package Information
echo ===============================================
echo.

REM Check Dev Hub connection
sf org display --target-org %DEV_HUB% >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Dev Hub not connected. Please run: sf org login web --alias %DEV_HUB%
    exit /b 1
)

echo 📋 All Package Versions:
echo.
sf package version list --target-dev-hub %DEV_HUB% --packages %PACKAGE_NAME%

echo.
echo 🔗 Installation URL Format:
echo https://login.salesforce.com/packaging/installPackage.apexp?p0=PACKAGE_VERSION_ID
echo.
echo 📝 Copy the Package Version ID ^(starts with 04t^) from above to create installation URLs
echo.
pause
