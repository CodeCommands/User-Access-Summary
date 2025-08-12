@echo off
REM User Access Summary App Deployment Script for Windows
REM This script deploys the User Access Summary application to a Salesforce org

echo 🚀 User Access Summary App Deployment Script
echo =============================================

REM Check if sf CLI is installed
where sf >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Salesforce CLI is not installed. Please install it first.
    echo Visit: https://developer.salesforce.com/tools/sfdxcli
    pause
    exit /b 1
)

REM Get target org alias
if "%1"=="" (
    echo 📝 Please provide target org alias:
    set /p ORG_ALIAS="Org alias: "
) else (
    set ORG_ALIAS=%1
)

echo 🎯 Target org: %ORG_ALIAS%

REM Validate org connection
echo 🔍 Validating org connection...
sf org display --target-org "%ORG_ALIAS%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Cannot connect to org '%ORG_ALIAS%'. Please authenticate first:
    echo Run: sf org login web --alias %ORG_ALIAS%
    pause
    exit /b 1
)

echo ✅ Org connection validated

REM Run Apex tests before deployment
echo 🧪 Running Apex tests...
sf apex run test --target-org "%ORG_ALIAS%" --test-level RunLocalTests --wait 10
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Apex tests failed. Please fix test failures before deployment.
    pause
    exit /b 1
)

echo ✅ All tests passed

REM Deploy the application
echo 📦 Deploying User Access Summary App...
sf project deploy start --target-org "%ORG_ALIAS%" --wait 10
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Deployment failed. Please check the errors above.
    pause
    exit /b 1
)

echo ✅ Deployment successful

REM Final deployment summary
echo.
echo 🎉 User Access Summary App Deployment Complete!
echo ===============================================
echo ✅ Application deployed successfully
echo ✅ Permission set created
echo ✅ All tests passing
echo.
echo 📱 Next Steps:
echo 1. Open your Salesforce org
echo 2. Click the App Launcher (9 dots)
echo 3. Search for 'User Access Summary'
echo 4. Click to open the application
echo.
echo 🔧 Additional Setup:
echo - Assign 'User Access Summary App User' permission set to administrators
echo - Review app permissions in Setup → Permission Sets
echo - Customize app settings if needed
echo.
echo 📚 For help and documentation:
echo - README.md file in this project
echo - GitHub repository: https://github.com/CodeCommands/User-Access-Summary
echo.
echo Happy auditing! 🚀
pause
