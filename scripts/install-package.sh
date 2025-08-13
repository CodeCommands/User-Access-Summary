#!/bin/bash

# User Access Summary App - Package Installation Guide
# Package: UserAccessSummaryApp
# Version: 1.0.0-1

echo "📦 User Access Summary App - Package Installation"
echo "================================================="
echo ""
echo "🔗 Package Installation URL:"
echo "https://login.salesforce.com/packaging/installPackage.apexp?p0=04tgL0000004uI9QAI"
echo ""
echo "📋 Package Details:"
echo "• Package Name: UserAccessSummaryApp"
echo "• Version: 1.0.0-3"
echo "• Type: Unlocked Package"
echo "• Subscriber Package Version Id: 04tgL0000004uI9QAI"
echo "• Installation Key: Not required (bypassed)"
echo ""

# Alternative installation via CLI
echo "🛠️  Alternative: Install via Salesforce CLI"
echo "sf package install --package 04tgL0000004uI9QAI --installation-key-bypass --target-org YOUR_ORG_ALIAS"
echo ""

echo "📝 Post-Installation Steps:"
echo "1. Assign the 'User_Access_Summary_App_User' permission set to users"
echo "2. Navigate to App Launcher → User Access Summary"
echo "3. Ensure users have the required permissions to view user data"
echo ""

echo "🔐 Required Permissions (included in permission set):"
echo "• ViewAllUsers - Access all user records"
echo "• ViewSetup + ViewRoles - Access permission metadata"
echo "• Read access to: User, Profile, PermissionSet, etc."
echo ""

echo "✅ Installation Complete!"
echo "The app provides comprehensive user permission auditing capabilities."
