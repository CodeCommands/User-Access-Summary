# Managed Package Setup Guide

## Step 1: Register Namespace in Packaging Org

1. Log into your Developer Edition packaging org
2. Go to Setup → Develop → Create → Packages
3. Click "Edit" next to Developer Settings
4. Register a unique namespace (2-15 characters, letters/numbers only)
   - Suggested: `UserAccessApp` or `UASummary` or `UserAccess`
   - This will be permanent and cannot be changed

## Step 2: Update Project Configuration

Update sfdx-project.json with your namespace:

```json
{
  "packageDirectories": [
    {
      "path": "force-app",
      "default": true,
      "package": "UserAccessSummary",
      "versionName": "ver 1.0",
      "versionNumber": "1.0.0.NEXT"
    }
  ],
  "name": "User Access Summary",
  "namespace": "YOUR_NAMESPACE_HERE",
  "sfdcLoginUrl": "https://login.salesforce.com",
  "sourceApiVersion": "64.0",
  "packageAliases": {
    "UserAccessSummary": "0Ho..."
  }
}
```

## Step 3: Prepare Components for Managed Package

### Required Changes:

1. **API Names**: All custom components will get namespace prefix
2. **Permission Set**: Update API references
3. **Security**: Review sharing settings
4. **Dependencies**: Document any required permissions

### Components to Package:
- ✅ Apex Classes (8 classes)
- ✅ Lightning Web Components (2 components)
- ✅ Custom Application
- ✅ Custom Tab
- ✅ FlexiPage
- ✅ Permission Set
- ✅ Static Resource (SheetJS)

## Step 4: Create Package

```bash
# Connect to packaging org
sf org login web --set-default-dev-hub --alias packaging-org

# Create package
sf package create --name "User Access Summary" --description "Comprehensive user permissions auditing tool for Salesforce" --package-type Managed --path force-app --target-dev-hub packaging-org

# Create package version
sf package version create --package "User Access Summary" --installation-key-bypass --wait 10 --target-dev-hub packaging-org

# Promote to managed
sf package version promote --package "User Access Summary@1.0.0-1" --target-dev-hub packaging-org
```

## Step 5: Installation Instructions

### For End Users:
1. Install from AppExchange (once published)
2. Or install via package link
3. Assign "User Access Summary App User" permission set to users
4. Navigate to App Launcher → User Access Summary

### Required Permissions for Installing Org:
- System Administrator (for installation)
- Custom permissions will be included in permission set

## Step 6: Testing Installation

### Test in Fresh Org:
1. Create new Developer Edition org
2. Install your package
3. Assign permission set
4. Test all functionality
5. Test uninstallation process

## Step 7: AppExchange Listing (Optional)

### Requirements:
- Security review by Salesforce
- Documentation
- Support plan
- Pricing model (can be free)

### Benefits:
- Easy discovery
- Trusted installation
- Automatic updates
