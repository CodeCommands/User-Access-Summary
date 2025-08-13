#!/bin/bash

# Helper script to get package version information
# Usage: ./get-package-info.sh

PACKAGE_NAME="UserAccessSummaryApp"
DEV_HUB="agentforce-devhub"

echo "📦 User Access Summary App - Package Information"
echo "==============================================="
echo ""

# Check Dev Hub connection
sf org display --target-org $DEV_HUB > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Dev Hub not connected. Please run: sf org login web --alias $DEV_HUB"
    exit 1
fi

echo "📋 All Package Versions:"
echo ""
sf package version list --target-dev-hub $DEV_HUB --packages $PACKAGE_NAME

echo ""
echo "🔗 Latest Installation URLs:"
echo ""

# Get the latest versions and show installation URLs
sf package version list --target-dev-hub $DEV_HUB --packages $PACKAGE_NAME --concise | grep -E "04t[a-zA-Z0-9]{15}" | while read -r line; do
    # Extract package version ID (starts with 04t)
    PACKAGE_ID=$(echo $line | grep -o "04t[a-zA-Z0-9]\{15\}")
    if [ ! -z "$PACKAGE_ID" ]; then
        VERSION=$(echo $line | awk '{print $4}')
        echo "Version $VERSION: https://login.salesforce.com/packaging/installPackage.apexp?p0=$PACKAGE_ID"
    fi
done

echo ""
echo "📝 To update documentation, use the latest Package Version ID from above."
