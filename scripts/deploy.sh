#!/bin/bash

# User Access Summary App Deployment Script
# This script deploys the User Access Summary application to a Salesforce org

echo "🚀 User Access Summary App Deployment Script"
echo "============================================="

# Check if sf CLI is installed
if ! command -v sf &> /dev/null; then
    echo "❌ Salesforce CLI is not installed. Please install it first."
    echo "Visit: https://developer.salesforce.com/tools/sfdxcli"
    exit 1
fi

# Get target org alias
if [ -z "$1" ]; then
    echo "📝 Please provide target org alias:"
    read -p "Org alias: " ORG_ALIAS
else
    ORG_ALIAS=$1
fi

echo "🎯 Target org: $ORG_ALIAS"

# Validate org connection
echo "🔍 Validating org connection..."
if ! sf org display --target-org "$ORG_ALIAS" &> /dev/null; then
    echo "❌ Cannot connect to org '$ORG_ALIAS'. Please authenticate first:"
    echo "Run: sf org login web --alias $ORG_ALIAS"
    exit 1
fi

echo "✅ Org connection validated"

# Run Apex tests before deployment
echo "🧪 Running Apex tests..."
if ! sf apex run test --target-org "$ORG_ALIAS" --test-level RunLocalTests --wait 10; then
    echo "❌ Apex tests failed. Please fix test failures before deployment."
    exit 1
fi

echo "✅ All tests passed"

# Deploy the application
echo "📦 Deploying User Access Summary App..."
if ! sf project deploy start --target-org "$ORG_ALIAS" --wait 10; then
    echo "❌ Deployment failed. Please check the errors above."
    exit 1
fi

echo "✅ Deployment successful"

# Check if permission set exists
echo "🔑 Checking permission set..."
PERM_SET_ID=$(sf data query --query "SELECT Id FROM PermissionSet WHERE Name='User_Access_Summary_App_User' LIMIT 1" --target-org "$ORG_ALIAS" --json | jq -r '.result.records[0].Id // empty')

if [ -z "$PERM_SET_ID" ]; then
    echo "❌ Permission set 'User_Access_Summary_App_User' not found."
    echo "Please check the deployment logs."
    exit 1
fi

echo "✅ Permission set found: $PERM_SET_ID"

# Assign permission set to current user
echo "👤 Assigning permission set to current user..."
CURRENT_USER_ID=$(sf org display --target-org "$ORG_ALIAS" --json | jq -r '.result.id')

if sf data create record --sobject PermissionSetAssignment --values "AssigneeId=$CURRENT_USER_ID PermissionSetId=$PERM_SET_ID" --target-org "$ORG_ALIAS" &> /dev/null; then
    echo "✅ Permission set assigned to current user"
else
    echo "⚠️  Permission set assignment failed (may already be assigned)"
fi

# Final deployment summary
echo ""
echo "🎉 User Access Summary App Deployment Complete!"
echo "==============================================="
echo "✅ Application deployed successfully"
echo "✅ Permission set created and assigned"
echo "✅ All tests passing"
echo ""
echo "📱 Next Steps:"
echo "1. Open your Salesforce org"
echo "2. Click the App Launcher (9 dots)"
echo "3. Search for 'User Access Summary'"
echo "4. Click to open the application"
echo ""
echo "🔧 Additional Setup:"
echo "- Assign 'User Access Summary App User' permission set to other administrators"
echo "- Review app permissions in Setup → Permission Sets"
echo "- Customize app settings if needed"
echo ""
echo "📚 For help and documentation:"
echo "- README.md file in this project"
echo "- GitHub repository: https://github.com/CodeCommands/User-Access-Summary"
echo ""
echo "Happy auditing! 🚀"
