@echo off
REM User Access Summary App - New Version Creation Script
REM This script automates the package version creation process

setlocal enabledelayedexpansion

echo 🚀 User Access Summary App - New Version Creation
echo ==================================================
echo.

REM Configuration
set PACKAGE_NAME=UserAccessSummaryApp
set DEV_HUB=agentforce-devhub

REM Step 1: Verify prerequisites
echo 📋 Step 1: Verifying prerequisites...
echo Checking Dev Hub connection...
sf org display --target-org %DEV_HUB% >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Dev Hub connected successfully
) else (
    echo ❌ Dev Hub not connected. Please run: sf org login web --alias %DEV_HUB%
    exit /b 1
)

REM Step 2: Show current package versions
echo.
echo 📦 Step 2: Current package versions...
sf package version list --target-dev-hub %DEV_HUB% --packages %PACKAGE_NAME%

REM Step 3: Ask for confirmation
echo.
set /p "confirm=🤔 Do you want to create a new package version? (y/n): "
if /i not "%confirm%"=="y" (
    echo ❌ Operation cancelled
    exit /b 1
)

REM Step 4: Ask for validation preference
echo.
echo 🔧 Validation options:
echo 1. Full validation with code coverage (recommended for production)
echo 2. Skip validation (faster, for testing)
set /p "validation=Choose option (1 or 2): "

if "%validation%"=="1" (
    set VALIDATION_FLAG=--code-coverage
    echo ✅ Using full validation with code coverage
) else if "%validation%"=="2" (
    set VALIDATION_FLAG=--skip-validation
    echo ⚠️  Using skip validation (for testing only)
) else (
    echo ❌ Invalid option
    exit /b 1
)

REM Step 5: Create package version
echo.
echo 🔨 Step 3: Creating new package version...
echo This may take several minutes...

sf package version create --package %PACKAGE_NAME% --installation-key-bypass --wait 15 --target-dev-hub %DEV_HUB% %VALIDATION_FLAG% --json > temp_result.json

if %errorlevel% equ 0 (
    echo ✅ Package version created successfully
    
    REM Note: Manual extraction of JSON values needed
    echo.
    echo 🎉 Package version created! Please check the output above for:
    echo 📦 Package Version ID
    echo 🔗 Installation URL
    echo.
    echo 📝 Next Steps:
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo 1. Copy the Package Version ID from the output above
    echo 2. Update scripts/install-package.sh and scripts/install-package.bat
    echo 3. Update README.md with new installation URL
    echo 4. Update docs/UPDATE_GUIDE.md
    echo 5. Test the package installation
    echo 6. Commit and tag the release
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    REM Clean up temp file
    del temp_result.json >nul 2>&1
    
) else (
    echo ❌ Package version creation failed
    del temp_result.json >nul 2>&1
    exit /b 1
)

echo.
echo 🏁 Version creation process completed!
pause
