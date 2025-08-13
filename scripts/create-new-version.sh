#!/bin/bash

# User Access Summary App - New Version Creation Script
# This script automates the package version creation and documentation update process

set -e  # Exit on any error

echo "🚀 User Access Summary App - New Version Creation"
echo "=================================================="
echo ""

# Configuration
PACKAGE_NAME="UserAccessSummaryApp"
DEV_HUB="agentforce-devhub"

# Step 1: Verify prerequisites
echo "📋 Step 1: Verifying prerequisites..."
echo "Checking Dev Hub connection..."
sf org display --target-org $DEV_HUB > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Dev Hub connected successfully"
else
    echo "❌ Dev Hub not connected. Please run: sf org login web --alias $DEV_HUB"
    exit 1
fi

# Step 2: Show current package versions
echo ""
echo "📦 Step 2: Current package versions..."
sf package version list --target-dev-hub $DEV_HUB --packages $PACKAGE_NAME

# Step 3: Ask for confirmation
echo ""
read -p "🤔 Do you want to create a new package version? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Operation cancelled"
    exit 1
fi

# Step 4: Ask for validation preference
echo ""
echo "🔧 Validation options:"
echo "1. Full validation with code coverage (recommended for production)"
echo "2. Skip validation (faster, for testing)"
read -p "Choose option (1 or 2): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[1]$ ]]; then
    VALIDATION_FLAG="--code-coverage"
    echo "✅ Using full validation with code coverage"
elif [[ $REPLY =~ ^[2]$ ]]; then
    VALIDATION_FLAG="--skip-validation"
    echo "⚠️  Using skip validation (for testing only)"
else
    echo "❌ Invalid option"
    exit 1
fi

# Step 5: Create package version
echo ""
echo "🔨 Step 3: Creating new package version..."
echo "This may take several minutes..."

# Create package version and capture output
OUTPUT_FILE="temp_package_result.txt"
sf package version create \
    --package $PACKAGE_NAME \
    --installation-key-bypass \
    --wait 15 \
    --target-dev-hub $DEV_HUB \
    $VALIDATION_FLAG > $OUTPUT_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Package version created successfully"
    
    # Extract information from the output file (without jq dependency)
    echo ""
    echo "🎉 Package Version Created Successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Show the full output so user can see details
    cat $OUTPUT_FILE
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Try to extract Package Version ID from output
    PACKAGE_VERSION_ID=$(grep -o "04t[a-zA-Z0-9]\{15\}" $OUTPUT_FILE | head -1)
    
    if [ ! -z "$PACKAGE_VERSION_ID" ]; then
        INSTALLATION_URL="https://login.salesforce.com/packaging/installPackage.apexp?p0=$PACKAGE_VERSION_ID"
        echo "🔗 Installation URL: $INSTALLATION_URL"
        echo "🆔 Package Version ID: $PACKAGE_VERSION_ID"
        echo ""
        
        # Ask if user wants to update documentation
        read -p "📝 Do you want to update project documentation with the new version? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "📝 Please manually update the following files with:"
            echo "   Package Version ID: $PACKAGE_VERSION_ID"
            echo "   Installation URL: $INSTALLATION_URL"
            echo ""
            echo "Files to update:"
            echo "• scripts/install-package.sh"
            echo "• scripts/install-package.bat"
            echo "• README.md"
            echo "• docs/UPDATE_GUIDE.md"
        fi
    else
        echo "⚠️  Could not automatically extract Package Version ID."
        echo "Please check the output above for the Package Version ID and Installation URL."
    fi
    
    # Clean up temp file
    rm -f $OUTPUT_FILE
    
    # Step 7: Show next steps
    echo "🎯 Next Steps:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. Get the latest package versions:"
    echo "   sf package version list --target-dev-hub $DEV_HUB --packages $PACKAGE_NAME"
    echo ""
    echo "2. Test the new package in a scratch org:"
    echo "   sf package install --package PACKAGE_VERSION_ID --installation-key-bypass --target-org test-org"
    echo ""
    echo "3. Update remaining documentation files manually"
    echo ""
    echo "4. Commit and tag the release:"
    echo "   git add ."
    echo "   git commit -m \"Release new version\""
    echo "   git tag -a vX.X.X -m \"Version X.X.X release\""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
else
    echo "❌ Package version creation failed"
    echo "Error output:"
    cat $OUTPUT_FILE
    rm -f $OUTPUT_FILE
    exit 1
fi

echo ""
echo "🏁 Version creation process completed!"
