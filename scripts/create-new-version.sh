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

RESULT=$(sf package version create \
    --package $PACKAGE_NAME \
    --installation-key-bypass \
    --wait 15 \
    --target-dev-hub $DEV_HUB \
    $VALIDATION_FLAG \
    --json)

if [ $? -eq 0 ]; then
    echo "✅ Package version created successfully"
    
    # Extract package version ID from JSON result
    PACKAGE_VERSION_ID=$(echo $RESULT | jq -r '.result.SubscriberPackageVersionId')
    VERSION_NUMBER=$(echo $RESULT | jq -r '.result.Version')
    INSTALLATION_URL="https://login.salesforce.com/packaging/installPackage.apexp?p0=$PACKAGE_VERSION_ID"
    
    echo ""
    echo "🎉 New Package Version Details:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Package: $PACKAGE_NAME"
    echo "🔢 Version: $VERSION_NUMBER"
    echo "🆔 Package Version ID: $PACKAGE_VERSION_ID"
    echo "🔗 Installation URL: $INSTALLATION_URL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Step 6: Ask if user wants to update documentation
    read -p "📝 Do you want to update project documentation automatically? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📝 Updating documentation files..."
        
        # Update install-package.sh
        if [ -f "scripts/install-package.sh" ]; then
            # Create backup
            cp scripts/install-package.sh scripts/install-package.sh.backup
            
            # Update URL and version
            sed -i "s|https://login.salesforce.com/packaging/installPackage.apexp?p0=.*|$INSTALLATION_URL\"|" scripts/install-package.sh
            sed -i "s|• Version: .*|• Version: $VERSION_NUMBER|" scripts/install-package.sh
            sed -i "s|• Subscriber Package Version Id: .*|• Subscriber Package Version Id: $PACKAGE_VERSION_ID|" scripts/install-package.sh
            sed -i "s|sf package install --package .* --installation-key-bypass|sf package install --package $PACKAGE_VERSION_ID --installation-key-bypass|" scripts/install-package.sh
            
            echo "✅ Updated scripts/install-package.sh"
        fi
        
        # Update install-package.bat
        if [ -f "scripts/install-package.bat" ]; then
            # Create backup
            cp scripts/install-package.bat scripts/install-package.bat.backup
            
            # Update URL and version
            sed -i "s|https://login.salesforce.com/packaging/installPackage.apexp?p0=.*|$INSTALLATION_URL|" scripts/install-package.bat
            sed -i "s|• Version: .*|• Version: $VERSION_NUMBER|" scripts/install-package.bat
            sed -i "s|• Subscriber Package Version Id: .*|• Subscriber Package Version Id: $PACKAGE_VERSION_ID|" scripts/install-package.bat
            sed -i "s|sf package install --package .* --installation-key-bypass|sf package install --package $PACKAGE_VERSION_ID --installation-key-bypass|" scripts/install-package.bat
            
            echo "✅ Updated scripts/install-package.bat"
        fi
        
        echo ""
        echo "📋 Manual Updates Required:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Please manually update these files:"
        echo "1. README.md - Update installation URL and version"
        echo "2. docs/UPDATE_GUIDE.md - Update latest version info"
        echo "3. Add release notes to RELEASE_NOTES.md"
        echo ""
    fi
    
    # Step 7: Show next steps
    echo "🎯 Next Steps:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. Test the new package in a scratch org:"
    echo "   sf package install --package $PACKAGE_VERSION_ID --installation-key-bypass --target-org test-org"
    echo ""
    echo "2. Update remaining documentation files manually"
    echo ""
    echo "3. Commit and tag the release:"
    echo "   git add ."
    echo "   git commit -m \"Release version $VERSION_NUMBER\""
    echo "   git tag -a v$VERSION_NUMBER -m \"Version $VERSION_NUMBER release\""
    echo ""
    echo "4. Share the installation URL with users:"
    echo "   $INSTALLATION_URL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
else
    echo "❌ Package version creation failed"
    exit 1
fi

echo ""
echo "🏁 Version creation process completed!"
